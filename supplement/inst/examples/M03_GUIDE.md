# M03: one profile, several reference questions

This companion reproduces the synthetic running example in *A correlated battery*. It contains no patient data or diagnostic thresholds. Higher scores indicate better performance. The two profiles are A=(35,50) and B=(35,35); the supplied population has means 50/50, SDs 10/10 and correlation 0.6. The cutoff 40 is a teaching convention. A separate hypothetical sample of 20 reference people has summaries numerically equal to those population inputs. Matching printed numbers does not make fitted norms known.

## Run it

Use the setup in [the companion README](../../README.md) and [environment guide](../../REPRODUCIBILITY.md). From the source repository root, run:

```sh
Rscript supplement/inst/examples/m03-correlated-battery.R
Rscript supplement/run_checks.R
```

The first command writes 11 CSV tables to `supplement/outputs/m03-correlated-battery/`. The second runs the companion checks, including earlier chapters. The retained example CSVs are in `M03_DATA/`. No random seed is needed: these are deterministic CDF, quantile, quadrature and matrix calculations. The [figure guide](../figures/m03-conditional/README.md) explains the separate entry point, `Rscript supplement/inst/examples/m03-conditional-figure.R`.

In R, a function is a named calculation. `source()` loads the function definitions without installing this project as a package. `m03_inputs()` returns a list: a container with named components such as `mean` and `profiles`. A matrix is a rectangular arrangement of numbers; here each profile is a row, while the 2×2 covariance matrix describes how the two observed scores vary together. `solve(covariance, residual)` solves a linear system; it does not estimate a covariance from the two assessed cases.

The entry script performs three steps. It supplies fixed teaching inputs, calls `m03_example_results()`, then saves each named result table using `readr::write_csv()`. Keep the full precision in these files; round numbers only for display. The commands accept paths and work from a different current directory because the script locates its own supplement directory.

## Read the outputs by their question

| CSV | Chapter unit and meaning | Important columns |
|---|---|---|
| `linear.csv` | Unit 1: marginal, average, discrepancy or conditional score | `profile`, `comparison`; score `value`, reference `reference_mean` and `reference_variance`; dimensionless `z`; `lower_tail` and `two_sided_tail` |
| `quadratic.csv` | Unit 2: whole-profile and conditional residual distance | `distance` is squared Mahalanobis distance; `upper_tail` uses chi-square 2. `conditioning_distance` plus `residual_distance` gives the total; `residual_two_sided` uses chi-square 1 |
| `count_probabilities.csv` | Unit 3: reference distribution of the cutoff 40 count | `correlation` declares 0.6 or an explicitly changed independent law 0; integer `count`, probability `mass`, inclusive `inclusive_tail` and numerical `quadrature_error` |
| `conditional_count.csv` | Unit 4: target cutoff crossing given score 2 | `conditioning_score`, target `target_mean`/`target_sd`, known conditioning crossing, observed target/full counts, and `target_crossing_probability` |
| `vector_prediction.csv` | Unit 5: independent new vector under fitted norms | squared `distance`, scaled `F_statistic`, `denominator_df`, `predictive_tail`,95% `critical_distance_95`; `proper_radial_tail` uses the separately stipulated proper prior |
| `family_values.csv` | Unit 6: two named lower-tail comparisons | `coordinate`1/2; `marginal` rank, `bonferroni`, `dependence_adjusted`; `overall_adjusted` repeats the minimum-based family comparison for clarity |
| `family_levels.csv` | Unit 6: coordinate level versus union flagging frequency | `correlation`0.6/0/−0.5; `marginal_05_frequency`, `bonferroni_frequency`, `calibrated_level`, its `calibrated_frequency`, and score-unit `raw_cutoff` |
| `fitted_count_predictive.csv` | Unit 7: posterior means of frozen count-rule content | `prior` comparison/proper; `at_least_one`, `both` and numerical `quadrature_error`. These probabilities are not content quantiles |
| `content_outer.csv` | Unit 7: simple conservative confidence enclosure | fixed integer `k`1/2; `confidence_lower` and `confidence_upper` concern the frozen rule's population fraction, not an individual's score |
| `conditional_prediction.csv` | Unit 8: regression target prediction with finite norms | `fitted_mean`, `leverage_multiplier`, `predictive_scale_squared`, `lower_tail`, `radial_two_sided`, `proper_lower_tail` |
| `metric.csv` | Unit 9: changed weighting while true dependence stays fixed | `original_distance`, `diagonal_distance`, correct `weighted_upper_tail`, numerical `quadrature_error`, and deliberately naive `naive_chisquare_tail` |

`profile` is A or B wherever a case is evaluated. All probability/tail/frequency columns use 0–1, not percent; multiply by 100 to report percentages. Score means, SDs, values and raw cutoffs use the teaching score scale. Variances and squared predictive scales have squared-score units. Standardizations, leverage multipliers and quadratic distances are dimensionless. A Student scale is not generally its SD. Integer count/coordinate/df fields are labels or degrees of freedom, not probabilities. `quadrature_error` is the numerical integrator's estimated absolute error for its underlying joint integral; it is not a rigorous certified enclosure, uncertainty about a population model or uncertainty about latent ability. A derived count mass/union may accumulate more than that single integral's error.

For the first profile, the marginal lower tail is 6.68%, the average lower tail 20.09%, the two-sided gap comparison 9.35%, and the conditional first-score tail 3.04%. Use the column matching the question: the discrepancy's `lower_tail` asks about a signed gap, while `two_sided_tail` asks about a gap in either direction. The second profile has no gap, so its two-sided discrepancy tail is 1. Its one-sided gap rank is 0.5. These numbers are compatible.

Conditional count probabilities use the cutoff 40, not the observed target 35. The known conditioning crossing is fixed: for B it is already 1, so the possible full counts are 1 or 2. The target crossing probabilities are 10.56% for A's peer slice and 45.03% for B's. They are neither the conditional score tails nor the unconditional count tails.

## What the functions require

`m03_linear()` accepts fixed nonzero weights on matching score units. `m03_conditional()` requires a fixed partition of all score indices into target and conditioning coordinates. Both require a positive-definite covariance on the observed scale. The helper `m03_bvn()` evaluates a bivariate normal lower orthant by conditioning; the alternative real common-factor method is available only for nonnegative correlation. A negative admissible correlation is valid for the conditional method. Correlation±1 is outside this full-rank model.

`m03_count2()` and the named-family helpers intentionally cover the two-test example, not arbitrary large batteries. They do not silently assume independent tests. Family calibration is under the complete known reference law, not strong control under every combination of true and false component hypotheses. The minimum-based family comparisons tie A and B even though their counts and global distances differ.

`m03_vector_predict()` requires an integer n>p and an ordinary unbiased positive-definite sample covariance. It excludes the assessed case from fitting. With n=p+1 the law exists but is very heavy-tailed; n≤p does not permit the ordinary inverse/scaled-F rule. `m03_niw()` instead specifies a proper normal–inverse-Wishart posterior: its positive prior scale can yield a proper prediction with singular sample scatter. That does not rescue the original frequentist rule. Its returned `scale` is a Student scale matrix. The example's proper center and proportional scale happen to preserve the original ordering; a general proper prior need not do so.

The proper joint prior is fixed before the hypothetical norms: mean(50,50), kappa 1, nu 5, and Psi twice the fixed example covariance. It is not learned by copying the observed sample summaries. The conditional-regression example uses a separately declared proper prior, not the conditional distribution of that joint prior: coding(1,(c−50)/10), B0=(50,6), V0=I, nu 0=4, Psi 0=128. The comparison-regression scale uses residual scatter 1216 with 18 residual degrees of freedom. Leverage widens prediction for the more unusual conditioning score.

`m03_content_outer()` returns the elementary confidence enclosure from the chapter, with coverage at least 1−gamma under its normal sampling experiment. It does not solve the optimized min/max problem. No posterior content quantile is calculated. `m03_student_count2()` produces a Student predictive region probability, which equals a posterior mean of content for the unchanged frozen count event. A posterior mean is not a credible interval.

`m03_weighted_tail()` integrates the exact two-dimensional polar representation for positive weights. The diagonal metric changes which profile is farther away. Its correct weighted-law tail is different from plugging that changed distance into a chi-square table; invertibility alone does not calibrate a fitted/shrunken/selected procedure.

## Checks and scientific limits

Tests compare the displayed examples with their stated precision, verify independent orthant and Student-mixture representations, unit transformations, count normalization/mean, calibrated family roots, valid small-sample boundaries, and rejection of singular/out-of-domain inputs. `PROVENANCE.txt` and `session-info.txt` record inputs, output interpretation and actual environment.

No output is a disease or impairment probability, measurement precision, personal change estimate or recommended action. Model suitability, population/protocol transport, response validity and clinical utility require their own evidence. Studying a fixed rule on new validation people and studying its whole refitting procedure are different experiments.
