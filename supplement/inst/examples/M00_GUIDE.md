# M00: the expected score depends on the declared repeats

This small example implements the expected-score and residual definitions in *The interpretation problem*. It is a synthetic teaching calculation for one fixed person. The numbers are possible repeated performances under two stipulated laws, not measurements from six people or evidence about a clinical population.

## Run and inspect

Use the companion setup in [REPRODUCIBILITY.md](../../REPRODUCIBILITY.md). From the source repository root run:

```sh
Rscript --vanilla supplement/inst/examples/m00-replication.R
```

The script uses `source()` to read the functions in R/m00-replication.R. A tibble is a table. Each input row names a possible score and its probability within a declared repeat universe. `group_by()` keeps the two universes separate; `summarise()` calculates one expectation per universe. Multiplication weights each possible score by its probability, and `sum()` adds those contributions. No random draw is made, so no seed is needed.

The observed score is 35 in both universes. Universe 1 supplies 32, 35, 38 with probabilities 1/3 each. Their weighted sum is 35. Universe 2 supplies 35, 38, 41 with probabilities 1/3 each, giving 38. Subtracting the expected score from the observed 35 gives residual 0 or −3, respectively. Across *all possible repeats within either universe*, weighted residuals average zero. A particular residual need not equal zero.

Inputs are complete probability laws. The function does not normalize arbitrary weights, fit a distribution, estimate a latent ability, calculate a reference percentile or choose a clinical action. The observed score must be possible with positive probability in each supplied finite law. The score scale is held fixed; no claim says these two artificial laws describe any actual test, person, practice effect or change.

## Output dictionaries

The two CSV files are written to outputs/m00-replication/. Retained copies in M00_DATA/ are exact baselines, not another dataset.

| File / column | Meaning and units |
|---|---|
| law.csv / universe | Which declared repeat law; character label, not a person group |
| law.csv / score | Possible single repeated performance, in score units |
| law.csv / probability | Supplied probability of that value within its universe; sums to 1 per universe |
| law.csv / expected_score | Probability-weighted expected performance of the fixed person in that universe |
| law.csv / contribution | score × probability, an additive part of the expectation; score units |
| law.csv / residual | score − expected_score for this possible repeat; score units |
| summary.csv / universe | Corresponding repeat-law label |
| summary.csv / expected_score | Weighted expectation 35 or 38, in score units |
| summary.csv / mean_residual | Weighted mean over all possible residuals; zero up to floating-point error |
| summary.csv / observed_score | Fixed observed performance 35, in score units |
| summary.csv / observed_residual | Fixed observation minus that universe's expectation;0 or −3 score units |

There is no sample size, standard error, confidence interval or posterior: all probabilities are stipulated. This finite definition needs no distinct frequentist/Bayesian calculation. To infer an expected score from data, a measurement/repeat design and its assumptions are needed, as developed in Measurement and replication.

## Checks and limits

The finite sum is exact algebra; R stores probabilities as floating-point numbers. Tolerance 1e-12 is used for these small score values. Scoped tests also cover unequal probabilities, negative/positive affine scale changes, degenerate laws, zero-mass support values and rejection of missing/nonfinite/negative/unnormalized/duplicate inputs or an impossible observation. Complete supplied laws are not estimates, and deterministic arithmetic checks are not clinical validation.

## Figure

Run `Rscript --vanilla supplement/inst/examples/m00-replication-figure.R` to draw the same supplied laws. The [figure guide](../figures/m00-replication/README.md) explains the three diagram rows, geometry columns, color/grayscale assets and vector masters. It is a definition illustration, not an empirical model or a diagnostic pipeline.
