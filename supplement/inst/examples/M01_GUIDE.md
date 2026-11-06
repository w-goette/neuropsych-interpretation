# Reproduce one observed-performance comparison (M01)

These are synthetic teaching inputs. The normal model, four-score law and event counts are three separate examples; they are not one dataset, fitted norms or a diagnostic tool.

Use R and the dependencies listed in the supplement README. Open a terminal at the repository root and run:

```sh
Rscript supplement/run_checks.R
Rscript supplement/inst/examples/m01-observed-event.R
```

The same commands work from any directory if the script path is supplied correctly. No package installation/build is required for these source-based examples; the companion is run directly from source, without installing the project as an R package. Actual installed versions and session information accompany the output. No random seed is needed: nothing is sampled.

The second command writes `supplement/outputs/m01-observed-event/`. Open the CSV files in R or a text/spreadsheet viewer. Every probability is a proportion from zero to one; multiply by 100 for a percentage. A value of .30 means 30%, not .30%.

## Read the calculation in steps

1. `m01_reference_table()` places the four possible scores in increasing order, then accumulates their supplied probabilities with `cumsum()`. The previous cumulative total is the strict lower tail, the current total is the inclusive lower tail, and their midpoint allocates half of a tied score's mass. Upper tails use the appropriate complement. The table preserves the original score units.
2. `m01_flagging_curve()` asks a different question: for a fixed rule level, which scores are selected, and how much population mass do those scores carry? It adds the known masses rather than counting a simulated sample. Its machine-equality guard prevents .1+.2 rounding from excluding an intended .3 boundary; levels within eight machine epsilons of a jump are numerically indistinguishable in this implementation. Tests check intended equalities and both sides of the jumps.
3. The coarsening pipeline labels scores 0/1 as one category and 2/3 as another, then sums masses within categories. The retained .3/.7 category law does not recover the original within-category split.
4. `m01_frequency()` takes a fixed event count and denominator. Confidence endpoints use the chapter's beta-quantile representation of binomial tail inversion. Bayesian endpoints use an explicitly supplied proper beta prior, updated by occurrences/nonoccurrences. These similarly named beta calculations have different guarantees. `qbeta()` evaluates the specified quantiles numerically; it does not simulate probabilities.
5. The normal row uses supplied mean 50 and SD 10. `pnorm()` evaluates the known-law CDF at standardized score -1.5. Treating 50/10 as estimates would require the different experiment in M02.

At zero occurrences, the exact confidence lower endpoint is zero; the proper-beta credible lower endpoint is positive. At no observations (`n=0,k=0`), empirical frequency is `NA`, [0,1] records no sampling information, and the posterior remains the prior. This is not an application of the chapter's `n>=1` confidence theorem. An output labeled predictive concerns one new independent reference person, not this patient's repeated performance.

## Files, column meanings and manuscript mapping

| File / columns | Meaning / units | M01 anchors |
|---|---|---|
| normal.csv: case_score, known_mean, known_sd; standardized_score; lower_tail, upper_tail, two_sided_event | Original score units; z units; proportions for declared known-normal events | sec-m01-normal-example, eq-m01-normal-example |
| reference.csv: score, probability, strict_lower, inclusive_lower, strict_upper, inclusive_upper, midpoint | Finite support; mass/tail/rank proportions | sec-m01-discrete-example, prp-m01-tails, eq-m01-midpoint |
| coarsening.csv: category, category_probability | Retained category and its mass | sec-m01-coarsening, eq-m01-coarsening |
| flagging.csv: convention, level, flagged_fraction | Rank convention, fixed threshold u, sum of reference masses flagged | sec-m01-flagging, prp-m01-tail-calibration |
| frequency.csv: n, k, prior_a, prior_b, level | Fixed denominator/count; proper prior shapes; nominal coverage/posterior interval mass | sec-m01-frequency, sec-m01-bayes |
| frequency.csv: empirical_frequency, confidence_lower/upper | Observed k/n; repeated-sampling confidence procedure endpoints | thm-m01-confidence, eq-m01-confidence-beta |
| frequency.csv: posterior_a/b, posterior_mean, credible_lower/upper, predictive_reference_event | Updated shapes, posterior summaries and new-reference-person prediction | prp-m01-beta-posterior, eq-m01-predictive-event, sec-m01-frequency-example |

The chapter proves its claims. Code checks compare rounded examples with exact formula specifications, finite-sum root inversion, boundary cases and invalid input handling. Numerical checks do not establish sampling assumptions, peer suitability, clinical validity or a theorem by simulation.


## Follow the decision process

Run `Rscript supplement/inst/examples/m01-process-figure.R`. [The process guide](M01_PROCESS_GUIDE.md) explains why ranks and selected population fractions differ. The accepted figure tracks the same tied category through rank assignment, the cutoff comparison and the resulting population mass.
