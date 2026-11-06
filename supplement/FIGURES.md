# Figure data and reproduction

Each figure folder contains the teaching inputs or plotting coordinates, caption, alternative text, and graphics-device information. The R entry points reproduce the figures under `supplement/outputs/`. Color and grayscale PNGs support on-screen reading; EPS files provide vector graphics where supplied.

| Module | Figure guide |
|---|---|
| M00 | [Interpretation](inst/figures/m00-replication/README.md) |
| M01 | [One performance](inst/figures/m01-process/README.md) |
| M02 | [Finite reference](inst/figures/m02-cutoff/README.md) |
| M03 | [Correlated battery](inst/figures/m03-conditional/README.md) |
| M04 | [Level and shape](inst/figures/m04-level-shape/README.md) |
| M05 | [Measurement and replication](inst/figures/m05-interval/README.md) |
| M06 | [Items and scoring](inst/figures/m06-items/README.md) |
| M07 | [Norms invariance linking](inst/figures/m07-norms/README.md) |
| M08 | [Change](inst/figures/m08-two-comparisons/README.md) |
| M09 | [Administration and missingness](inst/figures/m09-screening/README.md) |
| M10 | [Heterogeneity and robustness](inst/figures/m10-one-cutoff/README.md) |
| M11 | [Clinical targets and decisions](inst/figures/m11-flag-to-action/README.md) |
| M12 | [Design and validation](inst/figures/m12-next-observation/README.md) |
| M13 | [Reference curves](inst/figures/m13-region/README.md) |

Run the command in each guide from the repository root after [restoring the R environment](REPRODUCIBILITY.md). The [figure index](inst/figures/registry.csv) lists source scripts and generated assets. Chapter images are under `book/chapters/figures/`.

Figures distinguish observed scores, expected scores, reference probabilities, parameter uncertainty, and decision losses. Captions state the supplied model and identify numerical or simulated quantities. Line types, shapes, and direct labels supplement color; panel-level descriptions provide a textual reading route.
