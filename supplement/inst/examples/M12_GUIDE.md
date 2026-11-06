# M12: buying information and assessing the procedure in R

These are separate synthetic teaching experiments. The functions do not supply instrument norms, diagnostic scoring or recommendations for a clinic. A variance is a squared score quantity; an SD is its square root. Probabilities lie between 0 and 1; multiply by 100 only when reporting percentages.

## Run, read and compare

1. Keep this supplement folder intact and use the source-based R 4.6.1 setup and renv.lock, as explained in [REPRODUCIBILITY.md](../../REPRODUCIBILITY.md). From the source root run `Rscript --vanilla supplement/inst/examples/m12-design.R`. No project package installation is required.
2. The script sources R/m12-design.R. A function groups a calculation so that its inputs and output are explicit. `tables <- m12_tables()` assigns a named list of rectangular tables to `tables`; `tables$anchor_summary` selects one. The loop writes 23 CSVs to outputs/m12-design/. M12_DATA/ retains the checked outputs for comparison.
3. To inspect a result, run `x <- readr::read_csv("supplement/outputs/m12-design/gt_designs.csv")`, then `dplyr::arrange(x, posterior_mse)`. A smaller MSE is better for this raw-average squared-error target. It does not establish a better clinical action or uniform sampling-risk dominance.
4. For each field, read [M12_COLUMNS.csv](M12_COLUMNS.csv). It records table, column, units, definition, target and stable chapter section. A confidence endpoint repeats a sampling experiment; a credible endpoint conditions on the stated prior and data. Do not pool rows from different experiments merely because the columns have similar names.
5. Run `Rscript --vanilla supplement/run_checks.R` for the full companion tests. `Rscript --vanilla supplement/inst/examples/m12-next-observation-figure.R` rebuilds the two figure panels; the [figure record](../figures/m12-next-observation/README.md) explains their data, alt text and interpretation.

## Table-to-question map

| Table | Question / experiment | Chapter section |
|---|---|---|
| `precision_paths.csv` | Posterior target variance after independent unit-error coordinate observations | `sec-m12-bayesian-design` |
| `coordinate_allocation.csv` | Continuous effort for a fixed linear contrast and supplied noise SDs | `sec-m12-budget` |
| `gt_designs.csv` | Finite-grid posterior error of a future raw task/rater average; equal grid prior | `sec-m12-gt-posterior` |
| `gt_components.csv` | Posterior means of the seven unknown variance components | `sec-m12-gt-posterior` |
| `gt_tilted_designs.csv` | Same future GT raw average under half/base/double probabilities 0.6/0.3/0.1 | `sec-m12-gt-posterior` |
| `item_designs.csv` | Unknown calibration integrated before state-classification action | `sec-m12-calibrated-battery` |
| `item_patterns.csv` | Full separate counts from two item types; unit beta priors | `sec-m12-calibrated-battery` |
| `item_information.csv` | Fixed-person moment bound, total-score information and full-response information | `sec-m12-item-information` |
| `operating_criteria.csv` | Local population shift, global binary AUC and stated operating loss | `sec-m12-global-design` |
| `correlated_allocation.csv` | Supplied-law separation along precision1+precision2=2; correlation0.6 and shift(1,0) | `sec-m12-kkt` |
| `pilot_allocations.csv` | 1081 feasible independent final-sample allocations after the eight-per-stratum pilot | `sec-m12-norm-pilot` |
| `pilot_selected.csv` | Different selected allocations for supplied variance, unshrunk MSE, posterior mean risk and upper variance | `sec-m12-norm-pilot` |
| `regression_observations.csv` | 20 deterministic admissible raw-score observations | `sec-m12-regression-design` |
| `regression_intervals.csv` | At x=0: mean versus new observed score; confidence versus explicit NIG posterior | `sec-m12-regression-design` |
| `anchor_summary.csv` | Independent noisy calibration differences and four case repeats; bounded drift2 | `sec-m12-anchor-drift` |
| `anchor_allocations.csv` | Prospective budget40, calibrator cost1 and repeat cost2, posterior variance means | `sec-m12-anchor-drift` |
| `paired_comparison.csv` | Frozen A/B errors on the same100 people and unit Dirichlet priors | `sec-m12-paired-validation` |
| `power_assurance.csv` | Fixed alternative two-sided power versus favorable-direction posterior assurance | `sec-m12-assurance` |
| `majority_learning.csv` | Nine-person future majority learning risk, pilot12/40 and proper uniform prior | `sec-m12-learning-posterior` |
| `transport.csv` | Unknown source-stratum errors and target survey weights; no drift | `sec-m12-target-weights` |
| `missing_verification.csv` | Unrestricted missing-label identified set and two unlearned missing-error priors | `sec-m12-verification-design` |
| `random_verification.csv` | Two equally weighted strata; known outcome-independent verification probabilities | `sec-m12-random-verification` |
| `precision_sizes.csv` | Independent-person counts for three different prespecified precision requirements | `sec-m12-tail-design` |

## Why these operations are used

For precision_paths, one H1 observation has already changed covariance to diag(1/2,1). Each new unit-error observation adds one unit of precision to its coordinate. Compute each target variance after that update. The best split enumerates all integer allocations at that total count; its H1-only variance belongs to the contrast-optimal allocation and is not asserted to minimize H1 variance.

For gt_designs, enumerate 39 feasible task/rater pairs at cost 2J+3K+JK≤40. The calibration likelihood is evaluated on all 2187 positive variance-grid states and includes the integrated grand-mean prior. Normalize positive weights before averaging future raw-average MSE. Compare the equal grid prior and the half/base/double probabilities 0.6/0.3/0.1. This restrictive finite prior is not the broad simultaneous chi-square confidence region.

For item_patterns, retain the separate A and B counts. Independent calibration beta posteriors are integrated into beta-binomial future pattern masses. Compare weighted predictive masses only after that integration. Repeating A uses beta moments; replacing q by its mean before taking powers gives another experiment. The anchored states are operational ability labels, not disease.

For pilot_allocations, the sixteen pilot people are separate from the final sample. Counts40/15,44/14 and56/11 optimize different inputs or estimators; their loss values cannot be ranked as though they were the same fitted method. For anchors, calibration differences and case repeats remove different error terms; adding only one kind leaves the other. Drift±2 is an assumption, not learned from those data.

For paired_comparison and power_assurance, the two frozen rules share validation people. The four observed counts are 70/15/5/10 in 00/01/10/11 order. Conditioning on discordance gives the exact null test; the Dirichlet posterior also integrates the concordant share. A favorable-direction assurance averages unknown future rates, unlike two-sided power at one supplied alternative.

For majority_learning, regenerate the nine-person training sample conceptually before assessing a new person; the finite sums integrate that training variation. A beta posterior for the error of one currently frozen rule would answer a different question. For transport and verification, independent target covariates learn mixture weights, while missing outcomes leave an unlearned error component. No number of identical incomplete records makes that sensitivity prior disappear.

## Numerical methods and deliberate limits

Finite enumerations and beta/binomial sums are exact expressions evaluated in floating point. Anchor and paired intervals use adaptive one-dimensional integration and root finding; their numerical values are not proofs of coverage. Independent numerical benchmarks, refinement and domain tests check the supplied calculations. The same-host CSVs and PNGs are reproduced separately from mathematical verification.

This entry point implements selected core calculations across the chapter, not every advanced computation. The full crossed-GT confidence-region linear optimization,81-state correlated predictive-mixture quadrature, continuous noisy-item calibration, population-shift mixture information, drift posterior quantiles and full adaptive six-score/NIW simulation are not advertised R outputs. The manuscript labels the larger adaptive pipeline results as numerical experiments with all fitting and selection repeated. They are outside this source-based R entry point. The public majority learner supplies a fully evaluated same-target repeated-learning example. New clinical data, anchor validity, transport and causal benefit remain outside these synthetic calculations.
