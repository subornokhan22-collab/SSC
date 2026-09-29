#!/usr/bin/env python3
"""Question Bank Health report (review item #35).

Runs on every CI build and locally (python3 tool/bank_health.py).
Checks the bundled bank the way a shipping guard should:

  * totals per file / type
  * missing or out-of-range answer keys
  * duplicate ids
  * duplicate question stems (exact, normalized)
  * invalid options (not 4, not distinct, empty)
  * empty explanations
  * subject/chapter distribution (so a lost chapter stands out)

Exit code 0 = bank is healthy (warnings allowed), 1 = hard problems.
"""
import json
import os
import re
import sys
import collections

ROOT = os.path.join(os.path.dirname(__file__), "..")
QDIR = os.path.join(ROOT, "assets", "questions")

HARD = []
WARN = []


def norm(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "")).strip().lower()


def main() -> int:
    manifest = json.load(open(os.path.join(QDIR, "manifest.json"), encoding="utf-8"))
    files = manifest["files"]
    if not os.path.isdir(QDIR):
        print("bank directory missing:", QDIR)
        return 1

    by_id = collections.Counter()
    by_stem = collections.Counter()
    total = 0
    per_file = collections.Counter()
    per_type = collections.Counter()
    dist = collections.Counter()
    empty_chapters = []

    for name in files:
        path = os.path.join(QDIR, name)
        rows = json.load(open(path, encoding="utf-8"))
        per_file[name] = len(rows)
        for r in rows:
            total += 1
            t = r.get("type")
            per_type[t] += 1
            qid = r.get("id")
            by_id[qid] += 1
            payload = r.get("payload") or {}
            if t == "mcq":
                opts = payload.get("options") or []
                key = payload.get("correctIndex")
                stem = norm(payload.get("questionText"))
                by_stem[(r.get("subjectId"), t, stem)] += 1
                if not stem:
                    HARD.append(f"{qid}: empty question text")
                if len(opts) != 4:
                    HARD.append(f"{qid}: {len(opts)} options (expected 4)")
                elif len(set(norm(o) for o in opts)) != 4:
                    HARD.append(f"{qid}: options not distinct")
                if any(norm(o) == "" for o in opts):
                    HARD.append(f"{qid}: empty option")
                if not isinstance(key, int) or not (0 <= key < len(opts)):
                    HARD.append(f"{qid}: invalid correctIndex {key!r}")
                elif not norm(opts[key]):
                    HARD.append(f"{qid}: correct option is empty")
                if norm(payload.get("explanation")) == "":
                    WARN.append(f"{qid}: empty explanation")
                dist[(r.get("subjectId"), r.get("chapter"), t)] += 1
            else:
                stem = norm(payload.get("questionText") or payload.get("stem"))
                by_stem[(r.get("subjectId"), t, stem)] += 1
                if not stem:
                    HARD.append(f"{qid}: empty question text")
                if t == "saq":
                    if norm(payload.get("answer")) == "":
                        HARD.append(f"{qid}: empty answer")
                    if norm(payload.get("explanation")) == "":
                        WARN.append(f"{qid}: empty explanation")
                if t == "cq":
                    # The bank legitimately ships two CQ shapes (both
                    # rendered by paper_pdf.dart, both covered by the
                    # guard tests): math "solution-check" questions are
                    # three-part (ক খ গ, marks 2-4-4, no ঘ) and the
                    # classic creative question is four-part (1-2-3-4).
                    # Check internal consistency instead of one shape.
                    for k in ("questionK", "questionKh", "questionG"):
                        if norm(payload.get(k)) == "":
                            HARD.append(f"{qid}: empty {k}")
                    gh = norm(payload.get("questionGh")) != ""
                    marks = payload.get("marks")
                    if gh:
                        if marks != [1, 2, 3, 4]:
                            HARD.append(f"{qid}: 4 parts but marks {marks!r}")
                    else:
                        if marks != [2, 4, 4]:
                            HARD.append(f"{qid}: 3 parts but marks {marks!r}")
            ch = r.get("chapter")
            if not ch:
                HARD.append(f"{qid}: missing chapter")

    for qid, n in by_id.items():
        if n > 1:
            HARD.append(f"duplicate id: {qid} (x{n})")
    for (sub, t, stem), n in by_stem.items():
        if n > 1 and stem:
            WARN.append(f"duplicate stem ({sub}, {t}): {stem[:60]!r} (x{n})")

    # chapter distribution (per subject, MCQs) — a dropped chapter shows up
    print("Question Bank Health")
    print("====================")
    print(f"total questions: {total}")
    for t in sorted(per_type):
        print(f"  {t}: {per_type[t]}")
    print("\nper file:")
    for name in files:
        want = manifest.get("counts", {}).get(name)
        got = per_file[name]
        flag = "" if want in (None, got) else f"  <-- manifest says {want}"
        print(f"  {name}: {got}{flag}")
    if manifest.get("total") != total:
        HARD.append(f"manifest total {manifest.get('total')} != actual {total}")

    print("\nsubject / chapter (MCQs):")
    by_sub_ch = collections.Counter()
    for (sub, ch, t), n in dist.items():
        if t == "mcq" and ch:
            by_sub_ch[(sub, ch)] += n
    for (sub, ch), n in sorted(by_sub_ch.items(), key=lambda kv: (kv[0][0] or "", kv[0][1] or "")):
        print(f"  {sub} :: {ch}: {n}")

    print()
    if WARN:
        print(f"warnings ({len(WARN)}):")
        for w in WARN[:50]:
            print("  -", w)
        if len(WARN) > 50:
            print(f"  ... and {len(WARN) - 50} more")
    if HARD:
        print(f"\nPROBLEMS ({len(HARD)}):")
        for h in HARD[:80]:
            print("  !", h)
        if len(HARD) > 80:
            print(f"  ... and {len(HARD) - 80} more")
        print("\nBANK UNHEALTHY")
        return 1
    print("bank healthy ✓" + (f" ({len(WARN)} warnings)" if WARN else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
