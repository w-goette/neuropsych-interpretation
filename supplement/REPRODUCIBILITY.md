# Reproducing the examples

The recorded environment is R 4.6.1 on macOS arm64 with Quarto 1.10.18 for HTML. `renv.lock` specifies renv 1.3.1 and 59 other contributed packages. `environment-versions.csv` and the accompanying session-information files describe the execution environment.

From the repository root:

```sh
cd supplement
Rscript --vanilla restore.R
cd ..
Rscript --vanilla supplement/run_checks.R
```

Restoring creates a local library under `supplement/renv/`. Internet access and compatible package binaries or build tools are required. Examples source the supplied R functions directly.

Run the numerical and figure scripts listed in the [companion guide](README.md), then compare generated tables with the supplied teaching values:

```sh
python3 scripts/check_reproduction.py
python3 scripts/design.py --check
python3 scripts/check_sources.py --require-complete-book
quarto render book --to html
```

Generated results are written to `supplement/outputs/`; reference tables are supplied under `inst/examples/M00_DATA/` through `inst/examples/M13_DATA/`, where present, and `inst/figures/`. The [chapter guides](README.md) explain each table's target, units, conditioning, prior, numerical method, and implemented scope.

Deterministic table comparisons use an absolute tolerance of 1e-12. Tests of rounded printed values allow their stated rounding tolerance; integral, root, and identity checks use the tolerances specified in the corresponding tests. Quadrature refinement differences are sensitivity diagnostics unless a rigorous error bound is stated. Monte Carlo error and uncertainty about a population parameter are different quantities.

PNG output depends on fonts, graphics devices, and platform. EPS uses a Helvetica fallback and includes a creation timestamp. Identical data and geometry need not produce identical image bytes across environments. The figure folders contain plotting data, captions, alternative text, and device information.

All teaching inputs are synthetic and their observation designs remain separate. Confidence coverage, conditional posterior probability, and new-person prediction answer different questions. Reproducing numerical values does not establish clinical validity or benefit.
