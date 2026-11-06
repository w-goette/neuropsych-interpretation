#!/usr/bin/env python3
"""Compare rebuilt M00–M13 CSVs with the retained synthetic teaching values."""
import csv, math
from pathlib import Path
root = Path(__file__).resolve().parents[1]
pairs = []
for baseline in (root/'supplement/inst/examples/M01_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m01-observed-event'/baseline.name))
for baseline in (root/'supplement/inst/figures/m01-process').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m01-process-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M02_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m02-reference'/baseline.name))
for baseline in (root/'supplement/inst/figures/m02-cutoff').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m02-cutoff'/baseline.name))
for baseline in (root/'supplement/inst/examples/M03_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m03-correlated-battery'/baseline.name))
for baseline in (root/'supplement/inst/figures/m03-conditional').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m03-conditional'/baseline.name))
for baseline in (root/'supplement/inst/examples/M04_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m04-level-shape'/baseline.name))
for baseline in (root/'supplement/inst/figures/m04-level-shape').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m04-level-shape-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M05_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m05-measurement'/baseline.name))
for baseline in (root/'supplement/inst/figures/m05-interval').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m05-interval-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M06_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m06-items'/baseline.name))
for baseline in (root/'supplement/inst/figures/m06-items').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m06-items-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M07_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m07-norms'/baseline.name))
for baseline in (root/'supplement/inst/figures/m07-norms').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m07-norms-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M08_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m08-change'/baseline.name))
for baseline in (root/'supplement/inst/figures/m08-two-comparisons').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m08-two-comparisons'/baseline.name))
for baseline in (root/'supplement/inst/examples/M09_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m09-administration'/baseline.name))
for baseline in (root/'supplement/inst/figures/m09-screening').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m09-screening'/baseline.name))
for baseline in (root/'supplement/inst/examples/M10_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m10-robustness'/baseline.name))
for baseline in (root/'supplement/inst/figures/m10-one-cutoff').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m10-cutoff-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M11_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m11-clinical-targets'/baseline.name))
for baseline in (root/'supplement/inst/figures/m11-flag-to-action').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m11-flag-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M12_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m12-design'/baseline.name))
for baseline in (root/'supplement/inst/figures/m12-next-observation').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m12-next-observation-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M00_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m00-replication'/baseline.name))
for baseline in (root/'supplement/inst/figures/m00-replication').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m00-replication-figure'/baseline.name))
for baseline in (root/'supplement/inst/examples/M13_DATA').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m13-reference-curves'/baseline.name))
for baseline in (root/'supplement/inst/figures/m13-region').glob('*.csv'):
    pairs.append((baseline, root/'supplement/outputs/m13-region-figure'/baseline.name))
checked = 0
for baseline, rebuilt in pairs:
    with baseline.open() as stream: left = list(csv.reader(stream))
    with rebuilt.open() as stream: right = list(csv.reader(stream))
    assert len(left) == len(right), baseline
    for expected, actual in zip(left, right):
        assert len(expected) == len(actual), baseline
        for a, b in zip(expected, actual):
            try: x, y = float(a), float(b)
            except ValueError: assert a == b, (baseline, a, b)
            else: assert math.isclose(x, y, rel_tol=0, abs_tol=1e-12), (baseline, a, b)
            checked += 1
print(f'PASS: {len(pairs)} retained CSV files, {checked} cells; numeric absolute tolerance 1e-12.')
