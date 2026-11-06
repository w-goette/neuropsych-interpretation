# M02: finite reference information in R

This guide reproduces the synthetic examples in **Finite reference information**. Start with the question: another peer's score, a fraction below a fixed score, the content of a fitted rule, a fixed population quantile, or population SD. All these targets use the same stipulated scalar sample; the regression branch is a different constructed fixed-design experiment. None predicts this patient's retest or supplies a disease probability.

## Run the examples

Use the source-based setup in the companion README/REPRODUCIBILITY guide. From the source repository root run:

```sh
Rscript supplement/run_checks.R
Rscript supplement/inst/examples/m02-finite-reference.R
```

Rscript runs a saved R file. It loads the functions from R/m02-finite-reference.R and writes CSV tables into outputs/m02-reference/. No patient file, random seed or sampling step is required. Read the numbered comments in the entry script in order. To explore interactively, source the function file in an R console and use:

```r
source("supplement/R/m02-finite-reference.R")
reference <- m02_posterior(n = 20, mean = 50, sd = 10)
m02_predict(reference, y0 = 35)
m02_percentile(reference, y0 = 35)
```

The first function constructs the reference-prior posterior, conditional on the reference scores. Its list contains m (mean location), kappa (conditional precision multiplier), a (inverse-gamma shape), b (exponent numerator). These are distribution parameters, not a declaration that the population mean and SD are known. m02_predict returns a new-person lower tail and score interval; m02_percentile returns .025/.5/.975 quantiles of the population fraction below fixed35. That fraction's posterior mean equals the predictive lower tail, but its interval has probability units and is not a new-score interval.

For sensitivity, replace the posterior with m02_posterior(20,50,10,list(m=50,kappa=5,a=3,b=200)). The added list is the stipulated proper teaching prior, not an instrument recommendation. Its credible probabilities need not have fixed-parameter confidence coverage.

## Files and columns

| CSV | What it contains / units |
|---|---|
| reference-scores | person index and20 constructed observed scores; score units |
| scalar-prediction | model/prior/y0, predictive location and scale (not SD), df, lower_tail and two_sided probabilities, lower/upper95% new-person bounds in score units |
| scalar-percentile | model/prior/y0, plugin only for reference row, posterior_mean and lower/median/upper summaries for the population fraction; probability units |
| regression-scores | separate ten-person constructed fixed predictor/score pairs |
| regression-prediction | same prediction columns, conditional on fixed design and x0=(1,3) |
| regression-percentile | same fraction columns, conditional on fixed x0 and score45 |
| regression-posterior-inputs | prior, coefficient center, target_mean, variance_multiplier (leverage or posterior coefficient multiplier), shape and rate (b in exp(-b/v), squared-score units) |
| cutoff-coefficients | rule name, dimensionless coefficient and realized score cutoff |
| cutoff-content | rule/prior, sampling_law_matches flag, achieved-content mean/median/lower/upper/q95 and probability_content_at_most_05; probability units. lower/upper are central95%; q95 is one-sided. Proper rows concern the same frozen cutoff and its posterior content only. |
| quantile-parameter | prior, supplied level, plugin, parameter posterior_mean/lower/median/upper and one-sided95% lower/upper bounds; score units |
| population-sd | prior, mean/median/95% bounds/one-sided95% bounds of population SD, posterior_sd of that parameter (all score units), variance_lower/upper (squared-score units) |
| two-clinics | n with fixed mean50,SD10; predictive tail/score interval and fixed-score percentile interval, showing different limits as information grows |

Missing plugin values in proper rows are intentional: the plug-in fitted normal estimate belongs to the original sample summaries; the proper posterior is not another frequentist plug-in fit. `sampling_law_matches` is a label for the proved equivariant cutoff identity, not software checking clinical adequacy.

## Match computations to the chapter

Scalar prediction and its reference/proper updates map to eq-m02-predictive-pivot, reference-posterior and proper-update. Percentile root inversion maps to eq-m02-percentile-inversion and percentile-proper-cdf. Regression uses the full-rank fixed-X model, leverage and positive residual df. The percentile helper requires positive leverage; at x0=0 the conditional mean is known and the variance-only branch must be transformed directly (y0=0 gives percentile1/2). Prediction still has residual variation at zero leverage. Quantile/SD helpers implement eq-m02-quantile-reference-cdf and scale-posterior-quantiles. m02_sd_moment returns Inf at the stated existence boundary; finite quantiles can still exist.

For fitted content, m02_content_cdf integrates over repeated norm samples at fixed population parameters; m02_percentile_cdf at the realized cutoff instead integrates parameter uncertainty. Their equality here is a special reference-prior identity. m02_cutoffs contrasts controlling the content95th percentile with controlling its mean. The R figure guide keeps those denominators explicit.

## Numerical and scientific limits

The formulas in the chapter are exact under the model. These scripts evaluate them numerically with adaptive quadrature and root finding. Integrating over sqrt(chi-square) avoids the df1 endpoint singularity. The upper mixing tail excluded is1e-13; for bounded CDF integrands its omitted contribution is no more than1e-13, in addition to integration error. Absolute integration tolerance2e-11 and relative2e-10 do not imply arbitrary extreme-tail accuracy. Roots are bracketed by expansion; failure is an error, not a silently returned zero or one. Compare native special-function output with defining integrals and residuals when extending examples.

No generic regression/model-selection engine, fitted transformation, nonnormal robustness method or clinical validation is supplied. Preserve independent persons, fixed design/score/level/rule, positive variance/df, likelihood and prior before applying these calculations. More norms improve estimation, not by themselves measurement precision or population transport.
