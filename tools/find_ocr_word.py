#!/usr/bin/env python3
import csv
import re
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print('usage: find_ocr_word.py <tsv> <pattern>', file=sys.stderr)
        return 2

    tsv_path = Path(sys.argv[1])
    pattern = re.compile(sys.argv[2], re.IGNORECASE)
    with tsv_path.open(
        'r', encoding='utf-8', errors='replace', newline=''
    ) as handle:
        reader = csv.DictReader(handle, delimiter='\t')
        for row in reader:
            text = (row.get('text') or '').strip()
            if not pattern.search(text):
                continue
            try:
                left = int(row['left'])
                top = int(row['top'])
                width = int(row['width'])
                height = int(row['height'])
            except (KeyError, TypeError, ValueError) as error:
                print(f'invalid tesseract TSV row: {error}', file=sys.stderr)
                return 2
            print(left + width // 2, top + height // 2)
            return 0
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
