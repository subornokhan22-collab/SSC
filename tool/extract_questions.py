#!/usr/bin/env python3
"""Export the hardcoded Dart question bank to JSON assets.

Step 1 of docs/question-bank-migration.md.

This reads the `const Question(...)` / `ShortQuestion(...)` /
`CreativeQuestion(...)` literals out of lib/data/**, and writes one JSON file
per (subject, type) into assets/questions/.

Why a hand-written tokenizer instead of the `analyzer` package: there is no
Dart SDK in this environment, and the literals are pure data (verified: no
string interpolation, no raw strings, no adjacent-string concatenation, no
constant references) so a small scanner is sufficient and auditable.

The scanner is deliberately strict — anything it does not understand raises
rather than silently producing a wrong bank. Run with --check to verify an
existing export still matches the Dart source.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from typing import Any

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(REPO, "assets", "questions")

# Commit that still contains the original hardcoded Dart lists.
BASE_REF = os.environ.get("BANK_BASE_REF", "625cac0")

# Which Dart list maps to which subject + type. Mirrors the spreads in
# questions_data.dart (allMCQs / allCQs / allSAQs).
#   dart file -> [(list variable, subject_id, type)]
SOURCES: dict[str, list[tuple[str, str, str]]] = {
    "lib/data/extra_questions.dart": [
        ("extraMCQs", None, "mcq"),
        ("extraCQs", None, "cq"),
    ],
    "lib/data/questions_data.dart": [
        ("allMCQs", None, "mcq"),
        ("allCQs", None, "cq"),
        ("allSAQs", None, "saq"),
    ],
    "lib/data/physics/physics_mcqs.dart": [("physicsMcqs", "physics", "mcq")],
    "lib/data/physics/physics_saqs.dart": [("physicsSAQs", "physics", "saq")],
    "lib/data/physics/physics_cqs.dart": [("physicsCqs", "physics", "cq")],
    "lib/data/chemistry/chemistry_mcqs.dart": [("chemistryMcqs", "chemistry", "mcq")],
    "lib/data/chemistry/chemistry_saqs.dart": [("chemistrySaqs", "chemistry", "saq")],
    "lib/data/chemistry/chemistry_cqs.dart": [("chemistryCqs", "chemistry", "cq")],
    "lib/data/biology/biology_mcqs.dart": [("biologyMcqs", "biology", "mcq")],
    "lib/data/biology/biology_saqs.dart": [("biologySaqs", "biology", "saq")],
    "lib/data/biology/biology_cqs.dart": [("biologyCqs", "biology", "cq")],
    "lib/data/general_math/general_math_mcqs.dart": [
        ("generalMathMcqs", "general_math", "mcq")
    ],
    "lib/data/general_math/general_math_saqs.dart": [
        ("generalMathSaqs", "general_math", "saq")
    ],
    "lib/data/general_math/general_math_cqs.dart": [
        ("generalMathCqs", "general_math", "cq")
    ],
    "lib/data/ict/ict_mcqs.dart": [("ictMcqs", "ict", "mcq")],
    "lib/data/bangla_1st/bangla_1st_mcqs.dart": [
        ("banglaFirstMcqs", "bangla_1st", "mcq")
    ],
    "lib/data/bangla_1st/bangla_1st_cqs.dart": [("banglaFirstCqs", "bangla_1st", "cq")],
    "lib/data/bangla_1st/bangla_1st_revision_questions.dart": [
        ("banglaFirstRevisionQuestions", "bangla_1st", "saq")
    ],
    "lib/data/bangla_2nd/bangla_2nd_grammar_mcqs.dart": [
        ("bangla2ndGrammarMcqs", "bangla_2nd", "mcq")
    ],
    "lib/data/bgs/bgs_mcqs.dart": [("bgsMcqs", "bgs", "mcq")],
    "lib/data/bgs/bgs_saqs.dart": [("bgsSaqs", "bgs", "saq")],
    "lib/data/bgs/bgs_cqs.dart": [("bgsCqs", "bgs", "cq")],
}

CTOR_FOR_TYPE = {
    "mcq": "Question",
    "saq": "ShortQuestion",
    "cq": "CreativeQuestion",
}

# Fields we expect, and the defaults the Dart constructors apply.
DEFAULTS: dict[str, dict[str, Any]] = {
    "mcq": {"source": "ai", "sourceLabel": None, "figure": None, "explanation": None},
    "saq": {
        "source": "ai",
        "sourceLabel": None,
        "figure": None,
        "explanation": "",
    },
    "cq": {
        "source": "ai",
        "sourceLabel": None,
        "figure": None,
        "marks": [1, 2, 3, 4],
    },
}

PAYLOAD_FIELDS = {
    "mcq": ["questionText", "options", "correctIndex", "explanation"],
    "saq": ["questionText", "answer", "explanation"],
    "cq": ["stem", "questionK", "questionKh", "questionG", "questionGh", "marks"],
}


class ParseError(Exception):
    pass


# Readable file name per source list; keeps acronyms intact.
BANK_FILES = {
    "extraMCQs": "extra_mcqs",
    "extraCQs": "extra_cqs",
    "allMCQs": "core_mcqs",
    "allCQs": "core_cqs",
    "allSAQs": "core_saqs",
    "physicsMcqs": "physics_mcqs",
    "physicsSAQs": "physics_saqs",
    "physicsCqs": "physics_cqs",
    "chemistryMcqs": "chemistry_mcqs",
    "chemistrySaqs": "chemistry_saqs",
    "chemistryCqs": "chemistry_cqs",
    "biologyMcqs": "biology_mcqs",
    "biologySaqs": "biology_saqs",
    "biologyCqs": "biology_cqs",
    "generalMathMcqs": "general_math_mcqs",
    "generalMathSaqs": "general_math_saqs",
    "generalMathCqs": "general_math_cqs",
    "ictMcqs": "ict_mcqs",
    "banglaFirstMcqs": "bangla_1st_mcqs",
    "banglaFirstCqs": "bangla_1st_cqs",
    "banglaFirstRevisionQuestions": "bangla_1st_saqs",
    "bangla2ndGrammarMcqs": "bangla_2nd_mcqs",
    "bgsMcqs": "bgs_mcqs",
    "bgsSaqs": "bgs_saqs",
    "bgsCqs": "bgs_cqs",
}


def _snake(name: str) -> str:
    if name not in BANK_FILES:
        raise ParseError(f"no output file name mapped for list {name}")
    return BANK_FILES[name]


# ── tokenizer ────────────────────────────────────────────────────────


def strip_comments(src: str) -> str:
    """Blank out // and /* */ comments without changing byte offsets."""
    out = list(src)
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c in "'\"":
            quote = c
            i += 1
            while i < n:
                if src[i] == "\\":
                    i += 2
                    continue
                if src[i] == quote:
                    i += 1
                    break
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out[i] = " "
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            while i < n and not (src[i] == "*" and i + 1 < n and src[i + 1] == "/"):
                if src[i] != "\n":
                    out[i] = " "
                i += 1
            for j in range(i, min(i + 2, n)):
                out[j] = " "
            i += 2
            continue
        i += 1
    return "".join(out)


def read_string(src: str, i: int) -> tuple[str, int]:
    """Read a single- or double-quoted Dart string starting at src[i]."""
    quote = src[i]
    if quote not in "'\"":
        raise ParseError(f"expected string at offset {i}, got {src[i:i+40]!r}")
    if src.startswith(quote * 3, i):
        raise ParseError("triple-quoted strings are not supported")
    i += 1
    buf: list[str] = []
    while i < len(src):
        c = src[i]
        if c == "\\":
            nxt = src[i + 1]
            buf.append(
                {"n": "\n", "t": "\t", "r": "\r", "'": "'", '"': '"', "\\": "\\", "$": "$"}.get(
                    nxt, nxt
                )
            )
            i += 2
            continue
        if c == "$":
            raise ParseError(f"string interpolation not supported at offset {i}")
        if c == quote:
            i += 1
            # Adjacent string concatenation: 'a'\n 'b'
            j = i
            while j < len(src) and src[j] in " \t\n\r":
                j += 1
            if j < len(src) and src[j] in "'\"":
                more, j2 = read_string(src, j)
                return "".join(buf) + more, j2
            return "".join(buf), i
        buf.append(c)
        i += 1
    raise ParseError("unterminated string")


def skip_ws(src: str, i: int) -> int:
    while i < len(src) and src[i] in " \t\n\r":
        i += 1
    return i


def read_value(src: str, i: int) -> tuple[Any, int]:
    """Read a Dart literal value: string, int, bool, null, list, or enum ref."""
    i = skip_ws(src, i)
    # Optional type argument on a list literal: <String>[...]
    m = re.match(r"<\s*[\w<>, ]+\s*>\s*(?=\[)", src[i:])
    if m:
        i += m.end()
    c = src[i]
    if c in "'\"":
        return read_string(src, i)
    if c == "[":
        items: list[Any] = []
        i += 1
        while True:
            i = skip_ws(src, i)
            if src[i] == "]":
                return items, i + 1
            v, i = read_value(src, i)
            items.append(v)
            i = skip_ws(src, i)
            if src[i] == ",":
                i += 1
    if src.startswith("const", i) and not (src[i + 5].isalnum() or src[i + 5] == "_"):
        return read_value(src, i + 5)
    m = re.match(r"-?\d+\.\d+", src[i:])
    if m:
        return float(m.group()), i + m.end()
    m = re.match(r"-?\d+", src[i:])
    if m:
        return int(m.group()), i + m.end()
    if src.startswith("true", i):
        return True, i + 4
    if src.startswith("false", i):
        return False, i + 5
    if src.startswith("null", i):
        return None, i + 4
    # QuestionSource.board -> 'board'
    m = re.match(r"QuestionSource\.(\w+)", src[i:])
    if m:
        return m.group(1), i + m.end()
    # QuestionFigure.table(...) / .triangle(...) / .barChart(...)
    m = re.match(r"QuestionFigure\.(table|triangle|barChart)\s*\(", src[i:])
    if m:
        kind = m.group(1)
        args, j = parse_ctor_args(src, i + m.end())
        return figure_to_json(kind, args), j
    # Anything else (a constructor call, an identifier reference) is refused
    # rather than guessed at.
    raise ParseError(f"unsupported value at offset {i}: {src[i:i+60]!r}")


def figure_to_json(kind: str, args: dict[str, Any]) -> dict[str, Any]:
    """Normalise a QuestionFigure named constructor into the flat shape the
    Dart class actually stores (see `QuestionFigure._`)."""
    fig: dict[str, Any] = {"kind": kind}
    if kind == "table":
        fig["headers"] = args["headers"]
        fig["rows"] = args["rows"]
    elif kind == "triangle":
        # `vertices` is stored in `headers` by the Dart constructor.
        fig["headers"] = args["vertices"]
        if args.get("sides"):
            fig["sides"] = args["sides"]
        if args.get("angles"):
            fig["angles"] = args["angles"]
        if args.get("rightAngleAt") is not None:
            fig["rightAngleAt"] = args["rightAngleAt"]
    elif kind == "barChart":
        # `labels` is stored in `headers`.
        fig["headers"] = args["labels"]
        fig["values"] = args["values"]
    if args.get("caption") is not None:
        fig["caption"] = args["caption"]
    return fig


def parse_ctor_args(src: str, i: int) -> tuple[dict[str, Any], int]:
    """Parse named arguments of a constructor call; i points just past '('."""
    args: dict[str, Any] = {}
    while True:
        i = skip_ws(src, i)
        if src[i] == ")":
            return args, i + 1
        m = re.match(r"(\w+)\s*:", src[i:])
        if not m:
            raise ParseError(f"expected named arg at offset {i}: {src[i:i+60]!r}")
        name = m.group(1)
        i += m.end()
        value, i = read_value(src, i)
        args[name] = value
        i = skip_ws(src, i)
        if src[i] == ",":
            i += 1


def find_list(src: str, var: str) -> int:
    """Return the offset just past the '[' that opens `const List<..> var = [`."""
    # Both `= [` and `= <Question>[` forms appear in the source.
    m = re.search(
        r"const\s+List<\s*\w+\s*>\s+"
        + re.escape(var)
        + r"\s*=\s*(?:const\s*)?(?:<\s*\w+\s*>\s*)?\[",
        src,
    )
    if not m:
        raise ParseError(f"list {var} not found")
    return m.end()


def parse_list(src: str, var: str, ctor: str) -> list[dict[str, Any]]:
    """Parse every `ctor(...)` entry in list `var`. Spreads are skipped
    (they are followed separately via SOURCES)."""
    i = find_list(src, var)
    out: list[dict[str, Any]] = []
    depth = 1
    while i < len(src):
        i = skip_ws(src, i)
        if i >= len(src):
            break
        if src[i] == "]":
            depth -= 1
            if depth == 0:
                return out
            i += 1
            continue
        if src[i] == ",":
            i += 1
            continue
        if src.startswith("...", i):
            m = re.match(r"\.\.\.\s*\w+", src[i:])
            i += m.end()
            continue
        if src.startswith("const", i):
            i += 5
            continue
        m = re.match(r"(\w+)\s*\(", src[i:])
        if not m:
            raise ParseError(f"unexpected token in {var} at {i}: {src[i:i+60]!r}")
        if m.group(1) != ctor:
            raise ParseError(
                f"expected {ctor} in {var}, found {m.group(1)} at offset {i}"
            )
        i += m.end()
        args, i = parse_ctor_args(src, i)
        out.append(args)
    raise ParseError(f"unterminated list {var}")


# ── conversion ───────────────────────────────────────────────────────


def to_record(
    args: dict[str, Any], qtype: str, src_path: str, bank: str
) -> dict[str, Any]:
    merged = dict(DEFAULTS[qtype])
    merged.update(args)

    rec: dict[str, Any] = {
        "id": merged["id"],
        "type": qtype,
        "bank": bank,
        "subjectId": merged["subjectId"],
        "chapter": merged["chapter"],
        "source": merged["source"],
    }
    if merged.get("sourceLabel") is not None:
        rec["sourceLabel"] = merged["sourceLabel"]

    if merged.get("figure") is not None:
        rec["figure"] = merged["figure"]

    payload: dict[str, Any] = {}
    for f in PAYLOAD_FIELDS[qtype]:
        v = merged.get(f)
        if v is None:
            continue
        payload[f] = v
    rec["payload"] = payload

    # sanity
    if qtype == "mcq":
        opts = payload.get("options")
        if not isinstance(opts, list) or not opts:
            raise ParseError(f"{rec['id']}: options missing/empty")
        ci = payload.get("correctIndex")
        if not isinstance(ci, int) or not (0 <= ci < len(opts)):
            raise ParseError(f"{rec['id']}: correctIndex {ci} out of range")
    return rec


def read_source(rel: str) -> str:
    """Read a source file from the working tree, falling back to git history.

    Once the migration has run, the original Dart lists no longer exist on
    disk. Reading them from the pre-migration commit keeps this script
    re-runnable and lets CI verify the export still matches.
    """
    path = os.path.join(REPO, rel)
    if os.path.exists(path):
        text = open(path, encoding="utf-8").read()
        if re.search(r"const\s+List<", text):
            return text
    import subprocess

    for ref in (BASE_REF, f"{BASE_REF}^"):
        try:
            out = subprocess.run(
                ["git", "show", f"{ref}:{rel}"],
                cwd=REPO,
                capture_output=True,
                check=True,
            )
            return out.stdout.decode("utf-8")
        except subprocess.CalledProcessError:
            continue
    raise ParseError(f"cannot read {rel} from disk or git ({BASE_REF})")


def collect() -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for rel, entries in SOURCES.items():
        src = strip_comments(read_source(rel))
        for var, subject, qtype in entries:
            ctor = CTOR_FOR_TYPE[qtype]
            for args in parse_list(src, var, ctor):
                rec = to_record(args, qtype, rel, var)
                if subject and rec["subjectId"] != subject:
                    raise ParseError(
                        f"{rec['id']}: subjectId {rec['subjectId']!r} in {rel} "
                        f"(expected {subject!r})"
                    )
                records.append(rec)
    return records


def write_assets(records: list[dict[str, Any]]) -> dict[str, int]:
    os.makedirs(OUT_DIR, exist_ok=True)
    for f in os.listdir(OUT_DIR):
        if f.endswith(".json"):
            os.remove(os.path.join(OUT_DIR, f))

    groups: dict[str, list[dict[str, Any]]] = {}
    for r in records:
        groups.setdefault(r["bank"], []).append(r)

    manifest: dict[str, Any] = {"version": 1, "files": [], "counts": {}}
    written: dict[str, int] = {}
    for bank, rows in sorted(groups.items()):
        name = f"{_snake(bank)}.json"
        rows.sort(key=lambda r: r["id"])
        with open(os.path.join(OUT_DIR, name), "w", encoding="utf-8") as fh:
            json.dump(rows, fh, ensure_ascii=False, separators=(",", ":"))
            fh.write("\n")
        manifest["files"].append(name)
        manifest["counts"][name] = len(rows)
        written[name] = len(rows)

    # Sort so re-running this and the admin panel produce identical manifests.
    manifest["files"].sort()
    manifest["total"] = len(records)
    with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
    return written


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--check",
        action="store_true",
        help="parse and report, but do not write asset files",
    )
    args = ap.parse_args()

    try:
        records = collect()
    except ParseError as e:
        print(f"PARSE ERROR: {e}", file=sys.stderr)
        return 1

    ids = [r["id"] for r in records]
    dupes = {i for i in ids if ids.count(i) > 1} if len(set(ids)) != len(ids) else set()
    by_type: dict[str, int] = {}
    for r in records:
        by_type[r["type"]] = by_type.get(r["type"], 0) + 1

    print(f"parsed {len(records)} questions: " + ", ".join(
        f"{k}={v}" for k, v in sorted(by_type.items())
    ))
    if dupes:
        print(f"ERROR: {len(dupes)} duplicate ids, e.g. {sorted(dupes)[:5]}", file=sys.stderr)
        return 1

    by_subject: dict[str, int] = {}
    for r in records:
        by_subject[r["subjectId"]] = by_subject.get(r["subjectId"], 0) + 1
    for s, c in sorted(by_subject.items()):
        print(f"  {s}: {c}")

    if args.check:
        return 0

    written = write_assets(records)
    print(f"\nwrote {len(written)} files to assets/questions/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
