# M06: reproduce item-level scoring and uncertainty

Run from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m06-items.R
```

The script finds its own location,loads R/m06-items.R,and writes29CSV tables plus provenance/session information to outputs/m06-items/. Installing the project as a package is unnecessary. See [setup and locked dependencies](../../REPRODUCIBILITY.md). Each input is synthetic;no patients,instrument norms or diagnostic decisions are analyzed.

## Follow the calculation

You can also inspect one result interactively in R:

```r
source("supplement/R/m06-items.R")
result <- m06_posterior(u = c(1, 0))
result$summary
```

`c(1, 0)` joins the two observed answers into a vector. `<-` stores the returned object under a name, and `$summary` selects its table. The default item slopes are `c(1, 2)`, difficulties are `c(0, 1)`, and the normal prior has mean 0 and variance 1. Changing that prior changes the experiment; it is not an innocuous display setting.

1. Read `pattern-law.csv` before `total-law.csv`. A row records one possible observation. `probability` means the chance of that observation at the supplied coordinate;`derivative` means how that probability changes per coordinate unit. The likelihood uses the observation actually retained.
2. `m06_law()` enumerates patterns;`m06_total()` independently adds one item at a time. The information table compares full-pattern information,reported-total information and a moment lower bound. Their units are inverse-squared coordinate units;shares have no units. Equal slopes are a special sufficiency case.
3. `m06_posterior()` multiplies likelihood by a declared normal prior and integrates. R's `integrate()` evaluates a definite integral numerically. `uniroot()` finds where a CDF equals the required quantile. Normal prior variance1or4 does not make the posterior normal. `NA` for a total-only mode means not calculated;infinite extreme-pattern MLEs are part of the result.
4. Confidence intervals repeat responses at fixed h;credible intervals condition on one observation/prior. Prediction targets a fresh response vector and integrates its complete joint law. Do not substitute the posterior mean into each item curve or multiply posterior predictive marginal probabilities.
5. Floor reports are bins. `floor-inference.csv` compares the actual bin likelihood with an incorrect exact-cutpoint shortcut. The latter is included only to expose the changed experiment.
6. Calibration is harder. Paired anchor readings learn a distribution for each calibration coordinate;joint item patterns are integrated over it. The case likelihood also updates nuisance weights. `m06_calibration()` integrates7nuisance dimensions with shifted Halton points and each person's normal coordinate by Gaussian quadrature. This is numerical integration of a continuous model,not a finite discrete prior or a plug-in fit. The proper cone-restricted priors and all synthetic data are explicit in code and chapter.

R's `tibble::tibble()` creates a table;`dplyr::bind_rows()` stacks compatible tables;`readr::write_csv()` writes them. The pipe `|>` passes the preceding value to the next function. Names such as `mean`,`variance` and `probability` change targets between experiments;the table map below states which one. Binary pattern strings preserve leading zeros.

## Table-to-chapter and column dictionary

| CSV | Stable passage | Columns | Meaning/units/target |
|---|---|---|---|
| anchor-confidence.csv | sec-m06-noisy-anchor-confidence | parameter, lower, upper | Marginal intervals for mu,t=v+s/2 and s;alphaA=.01 divided among3intervals. Physical t>=s/2 intersection still required;rows alone are not a product posterior. |
| binary-facet.csv | sec-m06-binary-facet | fresh_task_mean, link_at_task_mean, shared_covariance, shared_difference_variance_times_J, separate_difference_variance_times_J, scored_reliability, underlying_reliability | Fresh-task success probability versus link at mean task;shared task covariance and difference variance times J;scored versus underlying reliability fractions. |
| calibrated-density-scale1.csv | sec-m06-fitted-calibration-example | h, density | Approximate marginal density per coordinate unit on grid h=-8to8;full case-updated noisy-anchor posterior,prior multiplier1. Trapezoidal CDF grid gives reported companion quantiles,not a normal posterior approximation. |
| calibrated-density-scale2.csv | sec-m06-fitted-calibration-example | h, density | Approximate marginal density per coordinate unit on grid h=-8to8;full case-updated noisy-anchor posterior,prior multiplier2. Trapezoidal CDF grid gives reported companion quantiles,not a normal posterior approximation. |
| calibrated-future-scale1.csv | sec-m06-fitted-calibration-example | pattern, probability | Four full joint posterior predictive pattern probabilities under prior multiplier1;stable same H/items,fresh response errors. |
| calibrated-future-scale2.csv | sec-m06-fitted-calibration-example | pattern, probability | Four full joint posterior predictive pattern probabilities under prior multiplier2;stable same H/items,fresh response errors. |
| calibrated-parameters-scale1.csv | sec-m06-fitted-calibration-example | parameter, mean, SD | Case-updated posterior mean/SD of mu,v,anchor_error=s,slopes a1/a2 and difficulties b1/b2;prior SD multiplier1. v/s are variances,SD column is posterior uncertainty of that parameter. |
| calibrated-parameters-scale2.csv | sec-m06-fitted-calibration-example | parameter, mean, SD | Case-updated posterior mean/SD of mu,v,anchor_error=s,slopes a1/a2 and difficulties b1/b2;prior SD multiplier2. v/s are variances,SD column is posterior uncertainty of that parameter. |
| calibrated-person-refinements.csv | sec-m06-fitted-calibration-example | points, shift, prior_scale, quadrature_order, grid_step, mean, variance, within, between, lower, upper, density_mass_in_grid, calibration_only_mean, weight_ESS | Points,deterministic shift,prior SD multiplier,normal quadrature order,grid step;full joint posterior mean/variance and within/between terms,approximate95%endpoints,density mass in[-8,8],calibration-only-weight comparison and importance-weight ESS diagnostic. |
| categories-at-zero.csv | sec-m06-category-likelihood | category, probability, derivative, information_term | Normal performance variance1,cuts(-1,1),h=0;bin probabilities,derivatives and exact scored-information contributions. |
| conditional-future-pairs.csv | sec-m06-conditional-prediction | first, future, pooled, difference, weight, inclusive_tail, included, alpha | Indices1–4 mean00,01,10,11;pooled weighted statistic,absolute discrepancy,conditional unnormalized weights,inclusive tail and inclusion at alpha=.05. |
| confidence-by-total.csv | sec-m06-tail-confidence | total, lower, upper, alpha | Known-item conservative95%inclusive-tail intervals for fixed h;infinite endpoints intentional,not missing values. |
| confidence-witness-bounds.csv | sec-m06-fitted-calibration-example | calibration_event_error_bound, calibration_tail_lower_bound, case_tail_lower_bound, restricted_confidence_lower, restricted_confidence_upper | Coupling event-error bound and retained tail lower bounds prove a feasible weak-slope witness for every h. Restricted-family outer interval uses external a>=.5,abs(b)<=2 and alphaC=.02. |
| dependent-kernel.csv | sec-m06-dependence | pattern, probability, derivative, information_term | Two-item shared-occasion mixture at h=0,D=plus/minus log3; derivative/information terms from correct joint kernel. |
| fair-column-tails.csv | sec-m06-fitted-calibration-example | statistic, observed, lower_tail, upper_tail | Reference fair-response tails for observed counts/rank statistics used in analytic witness,not observed calibration fit. |
| fixed-coordinate-coverage.csv | sec-m06-finite-coverage-boundary | h, credible_coverage, confidence_coverage | Fixed true h and exact finite-pattern sampling coverage of central credible and inclusive confidence intervals;not conditional posterior probabilities. |
| floor-inference.csv | sec-m06-category-inference | mean, variance, lower, upper, confidence_lower, confidence_upper, imputed_cut_mean, imputed_cut_variance | Only Y<=-1 observed;posterior moments/central95%quantiles under N(0,1),fixed-h confidence endpoints and incorrect point-at-cut shortcut for comparison. |
| future-patterns.csv | sec-m06-full-prediction | pattern, total, probability | Future observed patterns after first10,known items,normal prior variance1;posterior predictive probabilities. |
| future-summary.csv | sec-m06-full-prediction | mean, variance, expected_conditional_variance, variance_of_expected_score, item1_probability, item2_probability, item_covariance, plug_in_mean | Future total mean/variance,expected conditional score variance,variance of expected score,item marginal probabilities/covariance and plug-in total mean;not latent-coordinate variance. |
| information-at-zero.csv | sec-m06-information | h, pattern_information, total_information, moment_bound, total_share, moment_share | h,exact pattern/total information and moment lower bound in inverse-squared coordinate units;shares are fractions of full-pattern information. |
| pattern-law.csv | sec-m06-information | pattern, total, weighted, probability, derivative, score | Each complete binary pattern; probability, derivative w.r.t. h and derivative score; total counts successes,weighted sums item slopes. |
| person-posteriors.csv | sec-m06-person-posterior | observation, prior_mean, prior_variance, normalizer, mean, variance, lower, upper, MAP, MLE | Observed pattern or total;normal prior mean/variance;likelihood normalizer;posterior mean/variance,central95%quantiles,MAP and unpenalized MLE. Infinite MLEs intentional;NA modes/MLE for total-only not calculated. |
| pointwise-variance.csv | sec-m06-pointwise-variance | response, predictive_mass, posterior_mean, posterior_variance | Binary response,prior-predictive mass,posterior mean and variance under the stated three-point prior. |
| probit-pattern-law.csv | sec-m06-probit | pattern, total, weighted, probability, derivative, score | Three known probit items at h=.4;slopes(.7,1.2,2),difficulties(-1,.3,1).Binary patterns,probabilities and coordinate derivatives. |
| recoding.csv | sec-m06-weighted-report | experiment, exact_information, moment_bound | One-to-one X-squared report retains exact information1/2 while its moment bound is4/9. |
| separated-peaks.csv | sec-m06-floors | h, pattern_information, total_information, moment_bound, total_share, moment_share | Slopes(4,4),difficulties(-3,3),five h values;two informative regions,not universal unimodality. |
| total-law.csv | sec-m06-sufficiency | total, probability, derivative | Attainable count and its probability/derivative from dynamic recursion. |
| uncertain-sufficiency.csv | sec-m06-uncertain-sufficiency | observation, probability_H1 | Separate finite prior experiment,H=plus/minus1 and difficulty vectors(0,0),(-1,2)equally likely;posterior P(H=1)for10,01,total1. |
| weighted-report.csv | sec-m06-weighted-report | pattern, total, weighted, probability, derivative, score | All eight patterns for slopes(1,1,2),difficulties(0,.5,1),h=0;exact weighted score may group patterns with different ordinary totals. |

## Accuracy, checks and limits

Known-item probabilities/conditional tails are exact finite expressions evaluated in floating-point arithmetic. Scalar posterior moments use adaptive quadrature with relative tolerance1e-10;central quantiles use CDF inversion. Enumeration is intentionally limited to16items;dynamic total recursion has no exponential pattern enumeration but can still lose precision at numerical saturation. Invalid positive-slope/variance designs and numerically saturated category probabilities are rejected,not silently normalized. This is teaching code,not a production extreme-tail solver.

The calibration run uses32768points,normal quadrature order32 and density grid step.025 on[-8,8],with shifts1and2 under each prior. These sizes do not reproduce the chapter's original higher-order scrambled/rejection protocol exactly. Compare shifts and the retained density mass;ESS is an integration-weight diagnostic,not a clinical sample size or guaranteed error estimate. Refinement differences are not error bounds. The chapter's rounded hierarchical numbers remain approximate;the companion teaches the same posterior experiment. Wider normal SDs change slope arithmetic means as well as dispersion. Known-parameter sufficiency can fail after nuisance integration;not every uncertain-parameter model must fail.

Retained reproducible table baselines are in M06_DATA/. Unit tests compare dynamic recursion with enumeration,mixture identities,independent integrals,finite prediction spaces,known normal moments and invalid/boundary inputs. Current-run Python checks provide an additional implementation of the worked known-item/floor examples. Uniform coverage is established by the chapter arguments,not a grid of checks. Figures have a separate m06-items-figure.R entry point and inst/figures/m06-items/record. A successful computation does not validate a construct,response pattern,disease interpretation or action.
