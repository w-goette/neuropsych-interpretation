#!/usr/bin/env python3
"""Create or verify the book distribution's source-file inventories."""
from pathlib import Path
import argparse
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]


def source_files(root):
    files = []
    for path in root.rglob('*'):
        if not path.is_file():
            continue
        rel = path.relative_to(root)
        if any(part in {'.git', '.quarto', '_book', 'outputs', '__pycache__', 'site_libs'} for part in rel.parts):
            continue
        if rel.parts[:2] == ('supplement', 'renv') and len(rel.parts) > 2 and rel.parts[2] != 'settings.json':
            continue
        if path.name in {'.DS_Store', 'Rplots.pdf', 'MANIFEST.sha256'}:
            continue
        if path.suffix == '.html' and rel.as_posix() != 'book/styles/navigation.html':
            continue
        files.append(path)
    return sorted(files)


def verify(root=ROOT):
    manifest = root / 'MANIFEST.sha256'
    if not manifest.is_file():
        raise SystemExit('MANIFEST.sha256 is missing. Transfer the complete repository contents.')
    expected = {}
    for line in manifest.read_text().splitlines():
        if not re.fullmatch(r'[0-9a-f]{64}  .+', line):
            raise SystemExit('Invalid repository manifest entry.')
        digest, rel = line.split('  ', 1)
        if Path(rel).is_absolute() or '..' in Path(rel).parts or rel in expected:
            raise SystemExit('Invalid or duplicate repository manifest path.')
        expected[rel] = digest
    actual_files = {p.relative_to(root).as_posix(): p for p in source_files(root)}
    problems = [f'Missing: {rel}' for rel in expected.keys() - actual_files.keys()]
    problems += [f'Unexpected source file: {rel}' for rel in actual_files.keys() - expected.keys()]
    for rel in expected.keys() & actual_files.keys():
        if hashlib.sha256(actual_files[rel].read_bytes()).hexdigest() != expected[rel]:
            problems.append(f'Changed: {rel}')
    if problems:
        raise SystemExit('\n'.join(['The repository file set is incomplete or changed:', *sorted(problems)[:30],
                                    'Transfer the complete repository contents. After deliberate source edits, run scripts/update_manifest.py.']))
    print(f'Verified {len(expected)} repository source and data files.')


def update(root=ROOT):
    supplement = root / 'supplement'
    paths = [p for p in source_files(root) if p.is_relative_to(supplement) and p.name != 'FILES.md5']
    (supplement / 'FILES.md5').write_text(''.join(
        f'{hashlib.md5(p.read_bytes()).hexdigest()}  {p.relative_to(supplement).as_posix()}\n' for p in paths))
    (root / 'MANIFEST.sha256').write_text(''.join(
        f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.relative_to(root).as_posix()}\n' for p in source_files(root)))
    verify(root)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Verify without changing the inventories.')
    args = parser.parse_args()
    verify() if args.check else update()
