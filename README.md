# Neuropsychological Test Interpretation

An applied mathematical framework for reference comparisons, measurement, change and clinical interpretation.

This source distribution contains all fourteen chapters in their intended order, with the source-based R companion and retained synthetic teaching data. The HTML book is the primary publication format.

## Read and reproduce the chapters

[M00](book/chapters/00-interpretation.md) specifies interpretation targets, score meanings and uncertainty. Its [R guide](supplement/inst/examples/M00_GUIDE.md) and [figure guide](supplement/inst/figures/m00-replication/README.md) explain two complete finite repeat laws for one fixed synthetic person, without a norm percentile or clinical conclusion.

The chapter source is [book/chapters/01-one-performance.md](book/chapters/01-one-performance.md). Its numbered process figure distinguishes assigned percentile ranks from the fraction of peers flagged by a cutoff. [The R guide](supplement/inst/examples/M01_GUIDE.md) reproduces the synthetic normal, tied-score and fixed-event examples. [The process guide](supplement/inst/examples/M01_PROCESS_GUIDE.md) explains the figure.

[M02](book/chapters/02-finite-reference.md) distinguishes future-score prediction, fixed-score percentiles, fitted-rule content, population quantiles and SD. Its [R guide](supplement/inst/examples/M02_GUIDE.md) reproduces the scalar/regression examples, and its [figure guide](supplement/inst/figures/m02-cutoff/README.md) explains the two achieved-content laws.

[M03](book/chapters/03-correlated-battery.md) compares composites, discrepancies, conditional scores, profile distances, count regions and finite-reference predictions. Its [R guide](supplement/inst/examples/M03_GUIDE.md) reproduces the nine worked units; the [figure guide](supplement/inst/figures/m03-conditional/README.md) explains three conditional-slice panels.

[M04](book/chapters/04-level-and-shape.md) distinguishes declared level and residual shape, observed dispersion, paired reproducibility and target-specific information loss. Its [R guide](supplement/inst/examples/M04_GUIDE.md) reproduces13 synthetic tables; the [figure guide](supplement/inst/figures/m04-level-shape/README.md) explains four geometry/population-shift panels.

[M05](book/chapters/05-measurement-and-replication.md) connects replication designs, variance components and target-specific intervals. Its [R guide](supplement/inst/examples/M05_GUIDE.md) reproduces 23 synthetic tables; the [figure guide](supplement/inst/figures/m05-interval/README.md) explains intervals and repeated-data coverage.

[M06](book/chapters/06-items-and-scoring.md) distinguishes response-pattern information, total-score information and a moment bound, then develops person inference, prediction, coarsening and uncertain calibration. Its [R guide](supplement/inst/examples/M06_GUIDE.md) reproduces 29 synthetic tables; the [figure guide](supplement/inst/figures/m06-items/README.md) explains three responsive panels.

[M07](book/chapters/07-norms-invariance-linking.md) separates reference comparisons, measurement invariance and scale conversion. Its [R guide](supplement/inst/examples/M07_GUIDE.md) reproduces 27 synthetic tables; the [figure notes](supplement/inst/figures/m07-norms/README.md) explain five reference/calibration panels.

[M08](book/chapters/08-change.md) distinguishes raw differences, conditional retest innovation, anchored latent change, trajectories, historical baselines and causal effects. Its [R guide](supplement/inst/examples/M08_GUIDE.md) provides selected worked examples across the six units with explicit coverage and numerical limits; the [figure guide](supplement/inst/figures/m08-two-comparisons/README.md) explains two responsive comparison panels.

[M09](book/chapters/09-administration-and-missingness.md) keeps selected references, likelihood, missing-response prediction, adaptive histories, stopping and noncompletion distinct. Its [R guide](supplement/inst/examples/M09_GUIDE.md) explains 29 synthetic tables; the [figure guide](supplement/inst/figures/m09-screening/README.md) explains the screening rule, selected score plane and separate numeric readouts.

[M10](book/chapters/10-heterogeneity-and-robustness.md) examines tails, mixture membership, stable scale, copulas, covariance learning, sensitivity and calibration. Its [R guide](supplement/inst/examples/M10_GUIDE.md) maps22 synthetic tables across nine units; its [figure guide](supplement/inst/figures/m10-one-cutoff/README.md) distinguishes the supplied-law and fitted-reference experiments.

[M11](book/chapters/11-clinical-targets-and-decisions.md) moves from reference rarity to external-target probability, verification, loss and value of information. Its [R guide](supplement/inst/examples/M11_GUIDE.md) maps 28 synthetic tables; the [figure guide](supplement/inst/figures/m11-flag-to-action/README.md) distinguishes observed-rate prevalence effects from an integrated new-case loss comparison.

[M12](book/chapters/12-design-and-validation.md) compares target precision, identification, feasible allocation, complete-procedure validation, transport and verification. Its [R guide](supplement/inst/examples/M12_GUIDE.md) maps 23 selected synthetic tables and states the advanced-computation limits; the [figure guide](supplement/inst/figures/m12-next-observation/README.md) explains the two target-variance panels.

[M13](book/chapters/13-reference-curves.md) develops whole-curve bands, fixed-range fractions, fitted-curve error, tied-score tables and fitted transformations. Its [R guide](supplement/inst/examples/M13_GUIDE.md) explains 16 selected synthetic tables and computational limits; the [figure guide](supplement/inst/figures/m13-region/README.md) carries a coupled parameter region into its CDF envelopes.

Install R 4.6.1 for the tested environment, Python3 for the source/design checks, and Quarto1.10.18 for HTML. No project package installation is required. Restore the source companion from supplement/:

```sh
cd supplement
Rscript --vanilla restore.R
cd ..
Rscript --vanilla supplement/run_checks.R
Rscript --vanilla supplement/inst/examples/m00-replication.R
Rscript --vanilla supplement/inst/examples/m00-replication-figure.R
Rscript --vanilla supplement/inst/examples/m01-observed-event.R
Rscript --vanilla supplement/inst/examples/m01-process-figure.R
Rscript --vanilla supplement/inst/examples/m02-finite-reference.R
Rscript --vanilla supplement/inst/examples/m02-cutoff-figure.R
Rscript --vanilla supplement/inst/examples/m03-correlated-battery.R
Rscript --vanilla supplement/inst/examples/m03-conditional-figure.R
Rscript --vanilla supplement/inst/examples/m04-level-shape.R
Rscript --vanilla supplement/inst/examples/m04-level-shape-figure.R
Rscript --vanilla supplement/inst/examples/m05-measurement.R
Rscript --vanilla supplement/inst/examples/m05-interval-figure.R
Rscript --vanilla supplement/inst/examples/m06-items.R
Rscript --vanilla supplement/inst/examples/m06-items-figure.R
Rscript --vanilla supplement/inst/examples/m07-norms.R
Rscript --vanilla supplement/inst/examples/m07-norms-figure.R
Rscript --vanilla supplement/inst/examples/m08-change.R
Rscript --vanilla supplement/inst/examples/m08-change-figure.R
Rscript --vanilla supplement/inst/examples/m09-administration.R
Rscript --vanilla supplement/inst/examples/m09-screening-figure.R
Rscript --vanilla supplement/inst/examples/m10-robustness.R
Rscript --vanilla supplement/inst/examples/m10-cutoff-figure.R
Rscript --vanilla supplement/inst/examples/m11-clinical-targets.R
Rscript --vanilla supplement/inst/examples/m11-flag-figure.R
Rscript --vanilla supplement/inst/examples/m12-design.R
Rscript --vanilla supplement/inst/examples/m12-next-observation-figure.R
Rscript --vanilla supplement/inst/examples/m13-reference-curves.R
Rscript --vanilla supplement/inst/examples/m13-region-figure.R
python3 scripts/check_reproduction.py
python3 scripts/design.py --check
python3 scripts/check_sources.py
```

[Reproduction details](supplement/REPRODUCIBILITY.md) record the locked environment, tested platform, numerical tolerances and font/device differences. Inputs are synthetic specified examples, not clinical observations. Probability calculations do not establish diagnosis, latent deficit or a treatment recommendation.

## HTML book build

Run `python3 scripts/check_sources.py --require-complete-book` to check the configured source files, then run `quarto render book --to html`; output goes to `book/_book/`. Preview locally with `quarto preview book --to html`. Quarto’s HTML uses MathJax4 and an ES6 polyfill from public CDNs, so first-time browser math rendering needs network access. Full-book HTML is the primary format.

The [GitHub Actions workflow](.github/workflows/check.yml) runs the R examples, checks the teaching data and source files, and builds the HTML book.

## Design and reuse

[DESIGN.md](DESIGN.md) describes shared HTML/ggplot tokens and [figure guidance](supplement/FIGURES.md). [COPYRIGHT.md](COPYRIGHT.md) records the CC BY-NC 4.0 terms for original text, figures, teaching data and R code. [Third-party dependencies](THIRD_PARTY.md) retain their own licenses.
