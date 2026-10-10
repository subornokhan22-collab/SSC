#!/usr/bin/env python3
"""Expose analyzer errors via GitHub checks as well as downloadable log artifacts."""
import re
import sys
from pathlib import Path


def escape(value: str) -> str:
    return value.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')


def main() -> None:
    text = Path(sys.argv[1]).read_text(encoding='utf-8', errors='replace')
    if 'Could not format because' in text:
        print(f'::error::{escape(text[-12000:])}')
    lines = text.splitlines()
    for i, line in enumerate(lines):
        parts = [p.strip() for p in line.split('•')]
        if len(parts) >= 4 and parts[0] == 'error':
            location = re.fullmatch(r'(.+):(\d+):(\d+)', parts[-2])
            if location:
                path, row, column = location.groups()
                path = escape(path).replace(',', '%2C').replace(':', '%3A')
                print(f'::error file={path},line={row},col={column}::{escape(parts[1])}')
                continue
        if re.search(r'\bError:|\[E\]|Some tests failed', line):
            detail = '\n'.join(lines[max(0, i-16):i+8]) if '[E]' in line else line
            print(f'::error::{escape(detail[-10000:])}')


if __name__ == '__main__':
    main()
