# R companion

The companion provides synthetic teaching examples, numerical calculations, and figures for all fourteen chapters. The chapter guides explain the experiment, inputs, priors, output columns, and computational limitations. Scores and observations are constructed examples, not patient records or instrument norms.

Install R and restore the recorded dependencies:

```sh
cd supplement
Rscript --vanilla restore.R
cd ..
```

Run an example from the repository root by supplying its path, for example:

```sh
Rscript --vanilla supplement/inst/examples/m01-observed-event.R
Rscript --vanilla supplement/inst/examples/m01-process-figure.R
Rscript --vanilla supplement/run_checks.R
```

Scripts write results under `supplement/outputs/`. They source the functions directly; installing this project as an R package is unnecessary. For beginners, `<-` saves a value, `source()` loads a function file, and `readr::read_csv()` reads a generated table.

| Module | Guide | Numerical script | Figure script |
|---|---|---|---|
| M00 | [Interpretation](inst/examples/M00_GUIDE.md) | `m00-replication.R` | `m00-replication-figure.R` |
| M01 | [One performance](inst/examples/M01_GUIDE.md) | `m01-observed-event.R` | `m01-process-figure.R` |
| M02 | [Finite reference](inst/examples/M02_GUIDE.md) | `m02-finite-reference.R` | `m02-cutoff-figure.R` |
| M03 | [Correlated battery](inst/examples/M03_GUIDE.md) | `m03-correlated-battery.R` | `m03-conditional-figure.R` |
| M04 | [Level and shape](inst/examples/M04_GUIDE.md) | `m04-level-shape.R` | `m04-level-shape-figure.R` |
| M05 | [Measurement and replication](inst/examples/M05_GUIDE.md) | `m05-measurement.R` | `m05-interval-figure.R` |
| M06 | [Items and scoring](inst/examples/M06_GUIDE.md) | `m06-items.R` | `m06-items-figure.R` |
| M07 | [Norms invariance linking](inst/examples/M07_GUIDE.md) | `m07-norms.R` | `m07-norms-figure.R` |
| M08 | [Change](inst/examples/M08_GUIDE.md) | `m08-change.R` | `m08-change-figure.R` |
| M09 | [Administration and missingness](inst/examples/M09_GUIDE.md) | `m09-administration.R` | `m09-screening-figure.R` |
| M10 | [Heterogeneity and robustness](inst/examples/M10_GUIDE.md) | `m10-robustness.R` | `m10-cutoff-figure.R` |
| M11 | [Clinical targets and decisions](inst/examples/M11_GUIDE.md) | `m11-clinical-targets.R` | `m11-flag-figure.R` |
| M12 | [Design and validation](inst/examples/M12_GUIDE.md) | `m12-design.R` | `m12-next-observation-figure.R` |
| M13 | [Reference curves](inst/examples/M13_GUIDE.md) | `m13-reference-curves.R` | `m13-region-figure.R` |

All scripts in the table are under `supplement/inst/examples/`. [Reproduction details](REPRODUCIBILITY.md) describe the environment and output comparisons. [Figure documentation](FIGURES.md) links to plotting data, captions, and alternative text. The guides distinguish exact formulas, numerical integration, approximation, and simulation; selected R examples do not implement every advanced calculation defined in the chapters.
