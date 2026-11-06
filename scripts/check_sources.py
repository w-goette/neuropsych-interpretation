#!/usr/bin/env python3
"""Check that all configured book sources and shared resources are present."""
import argparse
import json
import re
from pathlib import Path
from update_manifest import verify

root = Path(__file__).resolve().parents[1]
verify(root)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--require-complete-book', action='store_true')
parser.add_argument('--github-output', type=Path)
args = parser.parse_args()
config = (root / 'book/_quarto.yml').read_text()
paths = re.findall(r'^\s*- (?!part:|href:)([^\n]+\.(?:md|qmd))\s*$', config, re.M)
missing = [p for p in paths if not (root / 'book' / p).is_file()]
shared = ['book/references.bib', 'book/styles/light.scss', 'book/styles/dark.scss',
          'book/styles/components.scss', 'book/styles/_tokens.scss', 'book/styles/navigation.html']
missing.extend(p for p in shared if not (root / p).is_file())
complete = not missing
print(json.dumps({'configured_sources': len(paths), 'missing_sources': missing,
                  'full_book_source_complete': complete}, indent=2))
if args.github_output:
    with args.github_output.open('a') as stream:
        stream.write('complete=' + str(complete).lower() + '\n')
if args.require_complete_book and not complete:
    raise SystemExit('Required book source files are missing.')
