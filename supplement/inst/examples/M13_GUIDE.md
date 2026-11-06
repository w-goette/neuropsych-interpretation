# M13: reference curves, tied-score tables and fitted scales

These synthetic examples reproduce the main calculations in *Reference curves, tables, and transformations*. They are teaching computations, not a clinical scoring system. Start from the source repository root after the existing companion setup:

```sh
Rscript --vanilla supplement/inst/examples/m13-reference-curves.R
```

The script writes 16 CSV tables to `supplement/outputs/m13-reference-curves/`. Retained comparison data are in [M13_DATA](M13_DATA/); [M13_COLUMNS.csv](M13_COLUMNS.csv) defines every column. Read a table with `readr::read_csv("supplement/outputs/m13-reference-curves/joint_regions.csv")`. A CSV is an ordinary rectangular table: each row is one declared input/target combination, and each column is one named quantity. The source entry point contains three steps: construct inputs, calculate each target, write the tables. Functions are in `supplement/R/m13-reference-curves.R`; the M02 normal–inverse-gamma helpers are explicitly sourced first. Installing the project as an R package is unnecessary.

## 1. Keep each experiment's inputs together

The normal reference illustration constructs 20 scores `50 ± j * sqrt(190/77)`, for `j=1,...,10`. Their sample mean is 50 and unbiased SD is 10. Neither is a supplied true population parameter. `raw_inputs.csv` records the observations; `normal_posteriors.csv` records the reference update and the proper teaching prior update. The latter starts with mean 50, mean multiplier 5, inverse-gamma shape 3 and scale 200. Its updated values are center 50, multiplier 25, shape 13 and scale 1150. Scale here means the inverse-gamma coefficient in `exp(-b/v)`, not a score SD.

The tied-score illustration instead uses known attainable scores 0,1,2,3 and ten observed persons, with counts 1,2,4,3. A Dirichlet(1,1,1,1) prior is uniform over the probability simplex, not over every cumulative proportion. The transformation illustration reuses the 20 raw scores but changes the observed population model and the meaning of the prior: origin 50/unit 10 are externally fixed; transformed-parameter prior is center 0, multiplier 1, shape 2 and scale 1. Two separate uniform shape ranges, [.5,2] and [.25,4], assess that new model's prior sensitivity. Never substitute the raw-normal prior on this dimensionless scale without redefining the experiment.

## 2. Make one whole-curve region and its envelopes

`joint_regions.csv` records the coupled candidate mean/SD region, with component probabilities both `sqrt(.95)`. Candidate mean limits depend on candidate SD. For the reference branch this is the stated exact .95 confidence region and matching reference-posterior region; the proper-prior region has its own .95 posterior probability and no universal fixed-parameter confidence guarantee. `simultaneous_score_bounds.csv` evaluates each full-curve band at 35,50,65; these are three evaluations of one simultaneous event.

Use `m13_joint_region()` to obtain the region and `m13_envelope()` to evaluate its analytic envelope formulas. Plotting a finite score grid does not prove coverage over all real scores. The [figure guide](../figures/m13-region/README.md) explains how the region maps to the band and why different candidate curves determine the lower envelope on either side of the sample mean.

## 3. Separate range content from uniform curve error

`range_fraction.csv` concerns the population fraction in the **fixed** range(35,65]. Its posterior mean is a new-person predictive event probability. Its equal-tailed interval comes from the induced fraction posterior; the transferred bounds come from the simultaneous region and have at least nominal coverage/mass. The code solves the conditional mean-distance root and integrates over precision; it does not subtract two marginal percentile quantiles.

`fitted_curve_error.csv` gives the distribution of the largest probability-scale discrepancy anywhere between the frozen plug-in normal CDF and the population CDF. Reference repetition refits from new norms; the posterior instead varies candidate population parameters around the same realized fit. Reference-law agreement is specific to this target and prior. Proper-prior results do not become sampling confidence statements. `calibrated_band.csv` applies the reference .95 radius to the unchanged fit. Its bounds are probability bounds and need not themselves have CDF tail limits. Radius 0.1913317 means about 19 percentage points of maximum percentile-curve error, not an outcome probability for a patient.

## 4. Retain ties, known support and the complete fitted rule

`discrete_cdf.csv` gives inclusive empirical proportions, simultaneous Clopper–Pearson bounds and posterior means. Cumulative counts are dependent; the simultaneous guarantee uses a union bound, not multiplication. `discrete_quantile.csv` gives posterior masses for a **score-valued** population .2 quantile. Its credible sets need not have exactly .95 mass.

`discrete_selected_content.csv` freezes the observed rule that flags inclusive empirical percentile ≤ .2; score 0 is its largest selected category. Its unknown population content has a Beta(2,12) posterior. In contrast, `discrete_refitting.csv` enumerates all 286 count vectors for a **separately stipulated** truth (.1,.2,.4,.3), refitting the whole table and rule each time. `discrete_refitting_summary.csv` aggregates that repeated-training experiment; its mean content 0.1701736292 and content-control probability 0.6172172136 need not equal .2. Observed counts do not establish the stipulated truth. Zero counts are retained; they are not structural zeros. The all-score table analysis requires the instrument's full known support.

## 5. Integrate the fitted scale and conditional mean

`shape_posterior_grid.csv` retains shape nodes, their normalized integration weights, full raw Jacobian and conditional NIG updates. These weights integrate both likelihood and a uniform shape prior. `shape_sensitivity.csv` reports predictive tails, posterior percentile/quantile intervals and new-score prediction intervals. Different columns answer different questions. The raw inverse sinh predictive law has no finite positive absolute moments under these priors; report CDFs and finite quantiles, not a raw predictive mean.

`order_statistic_benchmark.csv` uses the directly computable raw order-statistic confidence band, not an optimized projection over all shapes. It also gives the min-to-max new-score coverage 19/21 and one-infinite-endpoint coverage 20/21 under iid continuous sampling. Those guarantees have weaker assumptions and different targets than a Bayesian shape mixture. Ties require a different observation model.

`transformed_regression.csv` uses M02's ten synthetic conditional outcomes and externally fixed predictor (1,3), with case 45. It implements the specific asinh family and proper coefficient prior stated in the chapter. Its predictive tail is also calculated as a conditional normal/precision mixture. This is not a general automatic transformation fitting program. The manuscript's arbitrary-family confidence projections, rigorous global outer optimization, rounded-score likelihood fitting and empirical transport assessment are not advertised implementations here. Fixing a local estimated shape, using a finite shape grid as a confidence set, or sorting raw outcomes across different predictor rows would answer a different experiment.

## Numerical checks and supported boundaries

The root/integral definitions are exact under the declared models; their computer values are numerical. Bounded Gamma integrals omit at most 2e-12 probability, plus adaptive-quadrature/root errors. Noncentral parameter CDFs use the conditional normal/chi-square integral with upper omitted probability 1e-13, avoiding noncentral-Student tail precision warnings at root brackets. Shape integration is 64-node Gauss–Legendre quadrature; a 128-node refinement and independent Python representations check the worked values. Refinement agreement is not a rigorous quadrature error bound.

Printed seven-decimal values allow 5.1e-8 absolute rounding difference; ten-decimal values allow 5.1e-11. The tests use explicit absolute comparisons for printed numbers, preserving stricter representation/identity checks. Normal-reference functions require n≥2 and positive observed SD; this selected transformed-scale entry point also uses the positive sample-variance helper. Prior parameters, units and compact shape limits must be positive; support/count/predictor inputs are checked. Very extreme finite arguments may exceed these double-precision algorithms; no all-input numerical accuracy is promised.

Run `Rscript --vanilla supplement/run_checks.R` for the source-based tests. Source provenance and the actual tested R/package versions are retained with outputs.
