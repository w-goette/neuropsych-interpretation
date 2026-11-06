# M07: norms, invariance and linking in R

These are synthetic teaching calculations under declared models. They do not analyze patients, validate norms or implement diagnoses. The chapter and this guide distinguish observed performance, population percentile, expected coordinate and future observed reading.

## First run

Use the source-based [setup](../../README.md) and [reproducibility notes](../../REPRODUCIBILITY.md). From the source repository root run:

```sh
Rscript --vanilla supplement/inst/examples/m07-norms.R
Rscript --vanilla supplement/inst/examples/m07-norms-figure.R
Rscript --vanilla supplement/run_checks.R
```

The first script writes 27 CSV tables under outputs/m07-norms/. Retained comparison values and provenance are in [M07_DATA/](M07_DATA/). The script finds its companion directory from its own path, so a full script path also works from another working directory. It does not require installing neuropsychmethods as a package. Tested R/runtime versions are recorded in M07_DATA/session-info.txt; package availability and graphics output can vary across platforms.

## Read one result before studying the functions

Open references.csv. Every row holds score 35 fixed; changing reference changes its percentile. Next open ties.csv: a tied category occupies a rank interval, and randomization spreads its probability over that interval. anchor-offsets.csv changes a different assumption: whether an anchor may have a direct group offset. The common posterior mean across symmetric offset bounds does not mean the extra uncertainty disappeared.

In R, a tibble is a rectangular table. A function packages a calculation; `x <- ...` gives its result a name. `dplyr::bind_rows()` joins rows, and `readr::write_csv()` writes a table without discarding decimal precision. `|>` passes one result into the next operation. `stats::pnorm()` expects an SD, so code explicitly square-roots model variances before calling it. `stats::integrate()` evaluates a declared integral; `stats::uniroot()` finds a quantile by solving a CDF equation. These numerical operations do not prove a statistical guarantee.

## Priors and what repeats

Known-anchor beta prior is N(0,4). Unknown anchor variance uses IG(3,72), d|u~N(0,u/2.25); offset sensitivities add an independent uniform[-Gamma,Gamma] in d/offset coordinates. Selected-only q has symmetric Dirichlet shape 1 or .5; screening cells always have Dirichlet(1,1,4) and change only the excluded split Beta(a,4-a). Paired joint probabilities have Dirichlet(1,1,1,1). Shape priors use symmetric Dirichlet 1 or .5 and independent composition Beta(1,1).

The regression example uses b0=(50,-5),V0=diag(100,25),IG(3,9). Known-source affine calibration uses untruncated N2((10,2),diag(100,4)), conditioned on B>0. Noisy-source prior: t~IG(3,3),mu|t~N(0,t/.25),s~IG(3,.6) or IG(3,1.8),q~IG(3,1),psi|q~N2((10,1.2),q*diag(25,4)), then condition jointly on physical restrictions. These are stipulated teaching priors, not hyperparameters learned from the illustrated outcomes.

Frequentist procedures repeat their named reference/paired/anchor experiment at fixed parameters; noisy-case confidence additionally holds the case coordinate fixed. Bayesian analyses condition on actual observations and priors; the noisy-case posterior adds the stated population prior for that coordinate and updates parameters with its readings. Expected K and future observation Z share a mean but have different variances/intervals.

## Every output and its columns

### [references.csv](M07_DATA/references.csv)

Chapter location: `sec-m07-conditional / sec-m07-pooled`. Known continuous peer laws at score 35; reference labels identify two strata, two pools and an explicitly different moment-matched normal. Percentile is a lower-tail probability, not a latent score.

Columns: `reference`, `score`, `percentile`.

### [ties.csv](M07_DATA/ties.csv)

Chapter location: `sec-m07-rank-boundaries`. Known three-category mass for each group. strict excludes the observed category, inclusive includes it, midpoint averages those endpoints. mass is the category probability; no personal randomizer is drawn.

Columns: `group`, `score`, `mass`, `strict`, `inclusive`, `midpoint`.

### [randomized-ranks.csv](M07_DATA/randomized-ranks.csv)

Chapter location: `eq-m07-discrete-rank-cdf`. threshold is a rank cutoff from 0 to 1; achieved_probability is the total interval length below it, summing contributions from ALL score categories. It equals the cutoff under either supplied law.

Columns: `group`, `threshold`, `achieved_probability`.

### [anchor-known.csv](M07_DATA/anchor-known.csv)

Chapter location: `sec-m07-anchor-contrast`. Known variance/known nonzero loading. estimate,se,lower,upper are fixed-parameter normal estimate, sampling SE and 95% confidence limits. posterior fields use proper N(0,4); coverage_if_offset_2 is ACTUAL assumed-model interval coverage under a supplied offset violation.

Columns: `estimate`, `se`, `lower`, `upper`, `posterior_mean`, `posterior_variance`, `coverage_if_offset_2`.

### [anchor-offsets.csv](M07_DATA/anchor-offsets.csv)

Chapter location: `sec-m07-anchor-unknown-variance / sec-m07-anchor-offset-sensitivity`. Unknown variance and bounded independent uniform offset prior. confidence_lower/upper cover the WHOLE identified set. lower/upper are central 95% posterior quantiles of beta, using a Student/uniform mixture. posterior_d_mean/precision and variance_shape/scale specify the updated normal/IG contrast law; scale is inverse-gamma scale, not SD.

Columns: `loading`, `offset_bound`, `estimate`, `sampling_se`, `confidence_lower`, `confidence_upper`, `posterior_mean`, `posterior_variance`, `lower`, `upper`, `posterior_d_mean`, `posterior_d_precision`, `posterior_variance_shape`, `posterior_variance_scale`.

### [selected-fit.csv](M07_DATA/selected-fit.csv)

Chapter location: `sec-m07-selection-example`. count is a SELECTED-only count, inclusion_probability supplied by design. selected_probability divides by 30; target_probability inverts selection and renormalizes. The inferred inclusion fraction is .5; no excluded counts were observed.

Columns: `score`, `count`, `inclusion_probability`, `selected_probability`, `target_probability`.

### [selected-band.csv](M07_DATA/selected-band.csv)

Chapter location: `eq-m07-selected-simplex-confidence`. threshold is an ordinal score threshold 0,1,2. lower/upper are simultaneous conservative confidence bounds obtained by transforming a joint box/simplex region; they are NOT posterior intervals.

Columns: `threshold`, `lower`, `upper`.

### [selected-posterior.csv](M07_DATA/selected-posterior.csv)

Chapter location: `eq-m07-selected-percentile-moments / eq-m07-selected-percentile-cdf`. prior_shape defines a Dirichlet prior in SELECTED q coordinates. posterior mean/variance and lower/upper central 95% quantiles concern target F(1). transformed_mean_q is the different plug-in transformation of E(q). Laplace moments and beta-ratio CDF use separate exact integral representations.

Columns: `prior_shape`, `posterior_mean`, `posterior_variance`, `lower`, `upper`, `transformed_mean_q`.

### [screening-posterior.csv](M07_DATA/screening-posterior.csv)

Chapter location: `sec-m07-finite-selection-bounds`. Data are 10 selected-low,20 selected-high,20 excluded out of 50. split_a/b change ONLY the unlearned excluded split prior with sum 4. lower/upper are central 95% posterior quantiles. empirical bounds are[.2,.6]; set_confidence bounds cover the true entire identified interval, with finite observed-cell uncertainty. mixture_weight_sum checks normalization, not learned missing labels.

Columns: `split_a`, `split_b`, `posterior_mean`, `posterior_variance`, `lower`, `upper`, `mixture_weight_sum`, `empirical_lower`, `empirical_upper`, `set_confidence_lower`, `set_confidence_upper`.

### [screening-correlation.csv](M07_DATA/screening-correlation.csv)

Chapter location: `sec-m07-screening`. screen identifies the half-line or two-sided tail rule. screening_variance is Var(X|included). correlation is the selected Pearson correlation at supplied rho=.8; neither screen is universally preferable.

Columns: `screen`, `screening_variance`, `correlation`.

### [couplings.csv](M07_DATA/couplings.csv)

Chapter location: `sec-m07-discrete-coupling`. t is P(Y_A=1,Y_B=1), NOT a variance. J00/J01/J10/J11 are four compatible joint probabilities with unchanged margins. success_after_source 0/1 are actual conditional probabilities permitted by each coupling; the rank-map coupling takes t=.5.

Columns: `t`, `J00`, `J01`, `J10`, `J11`, `success_after_source0`, `success_after_source1`.

### [coupling-priors.csv](M07_DATA/coupling-priors.csv)

Chapter location: `eq-m07-coupling-prior-prediction`. prior_a/b specify beta prior on s=4 t-1. The two success probabilities average that prior; supplied margins alone do not update it. Rows are assumptions, not evidence about paired scores.

Columns: `prior_a`, `prior_b`, `success_after_source0`, `success_after_source1`.

### [paired-calibration.csv](M07_DATA/paired-calibration.csv)

Chapter location: `sec-m07-paired-score-calibration`. source is the new binary form-A value; row_n/successes are observed paired row counts. posterior_a/b are updated beta shapes. lower/upper are marginal 95% credible intervals; confidence bounds jointly cover BOTH row probabilities at least 95%. Their conditioning is different.

Columns: `source`, `row_n`, `successes`, `posterior_a`, `posterior_b`, `posterior_mean`, `lower`, `upper`, `confidence_lower`, `confidence_upper`.

### [affine-anchors.csv](M07_DATA/affine-anchors.csv)

Chapter location: `sec-m07-affine-link`. source/target slopes and difficulties are supplied common-item parameters under intercept 10,slope 2. They satisfy full-curve slope and difficulty constraints. They are NOT noisy measurements or fitted clinical item parameters.

Columns: `source_slope`, `source_difficulty`, `target_slope`, `target_difficulty`, `link_intercept`, `link_slope`.

### [regression-percentile.csv](M07_DATA/regression-percentile.csv)

Chapter location: `sec-m07-fitted-norms`. Six-person fixed-design normal norm; score 42 at C=1 is external to fitting. intercept/slope, residual_variance,df,fitted_mean and leverage summarize the fit. confidence bounds are joint-region images for a fixed percentile. posterior_shape/scale specify IG variance law. posterior_mean is also the predictive Student CDF value; median/lower/upper refer to the percentile POSTERIOR, not a new-score interval.

Columns: `intercept`, `slope`, `residual_variance`, `df`, `fitted_mean`, `leverage`, `fitted_percentile`, `confidence_lower`, `confidence_upper`, `posterior_shape`, `posterior_scale`, `posterior_mean`, `median`, `lower`, `upper`.

### [shape-counts.csv](M07_DATA/shape-counts.csv)

Chapter location: `sec-m07-shape-example`. Observed fixed-stratum counts/proportions on scores 0–3. Equal mean 1.5 and variance 1.25 do not equate F(1). Population composition comes from its separate 20 of 60 observations, not equal recruitment of 40 per stratum.

Columns: `group`, `score`, `count`, `observed_proportion`.

### [shape-bands.csv](M07_DATA/shape-bands.csv)

Chapter location: `eq-m07-shape-mixture-extrema`. All lower/upper fields are images of one nine-coordinate finite confidence region. F0/F1 refer to conditional CDFs, pool to target-composition mixture, contrast to F0-F1 and theta to population C0 weight. They cover all thresholds together; arbitrary endpoint combinations need not describe one law.

Columns: `threshold`, `F0_lower`, `F0_upper`, `F1_lower`, `F1_upper`, `pool_lower`, `pool_upper`, `contrast_lower`, `contrast_upper`, `theta_lower`, `theta_upper`.

### [shape-posterior.csv](M07_DATA/shape-posterior.csv)

Chapter location: `sec-m07-shape-posterior / sec-m07-shape-example`. prior_shape is the common Dirichlet shape; composition prior stays Beta(1,1). nodes is quadrature order. F0/F1 fields summarize their marginal beta posteriors. pooled fields, median and lower/upper summarize the POOL percentile; contrast fields and probability_contrast_positive concern F0-F1. Comparing 96 and 192 nodes diagnoses quadrature stability.

Columns: `prior_shape`, `nodes`, `F0_mean`, `F1_mean`, `F0_lower`, `F0_upper`, `F1_lower`, `F1_upper`, `pooled_mean`, `pooled_variance`, `median`, `lower`, `upper`, `contrast_lower`, `contrast_upper`, `probability_contrast_positive`.

### [shape-functionals.csv](M07_DATA/shape-functionals.csv)

Chapter location: `sec-m07-shape-location-scale`. population identifies C0,C1 or pooled. posterior_mean_score is E(mu); variance_of_mean is Var(mu); expected_population_variance is E(V); their sum is predictive_score_variance. These are in score/score-squared units, not percentile uncertainty.

Columns: `population`, `posterior_mean_score`, `variance_of_mean`, `expected_population_variance`, `predictive_score_variance`.

### [fitted-rank-calibration.csv](M07_DATA/fitted-rank-calibration.csv)

Chapter location: `eq-m07-fitted-rank-law`. reference_n is the number of fitted intercept-only reference scores. fitted_rank_threshold is the reported-rank cutoff. repeated_reference_probability is its actual achieved sampling frequency including norm fitting; unequal columns show lack of known-CDF uniformity.

Columns: `reference_n`, `fitted_rank_threshold`, `repeated_reference_probability`.

### [known-source-link.csv](M07_DATA/known-source-link.csv)

Chapter location: `sec-m07-link-uncertainty / sec-m07-joint-link-uncertainty`. Three known source coordinates and independent known target SDs 1. confidence bounds are the simultaneous line band at fixed h=.5; lower/upper are pointwise transformed-coordinate posterior quantiles. untruncated variances belong to the Gaussian before B>0 conditioning. positive_slope_probability normalizes it; posterior_B fields use the truncated law. independent_source_target fields add an explicitly independent source posterior with mean .5, variance .25; moments alone do not specify a density.

Columns: `intercept`, `slope`, `confidence_lower`, `confidence_upper`, `untruncated_A_variance`, `untruncated_B_variance`, `positive_slope_probability`, `lower`, `upper`, `posterior_mean_B`, `posterior_variance_B`, `independent_source_target_mean`, `independent_source_target_variance`.

### [noisy-calibration-readings.csv](M07_DATA/noisy-calibration-readings.csv)

Chapter location: `sec-m07-source-link-example`. person labels 24 constructed observed triples. source1/source2 and numeric target are readings, not true latent coordinates. We center/scale M to sample variance 1.25, use contrasts±sqrt(.3), and orthogonalize a residual to sum of squares 11. These constructed teaching observations match the stated sufficient summaries; they are not patient data.

Columns: `person`, `source1`, `source2`, `target`.

### [noisy-confidence.csv](M07_DATA/noisy-confidence.csv)

Chapter location: `sec-m07-source-link-confidence`. alpha=.05; case_uncertainty toggles a fixed input versus an unknown fixed case coordinate. z/chi_square are the six-event cutoffs. t/s/q bounds concern source-average/source-error/conditional-target variances; g bounds are reliability gain. lower/upper are conservative outer confidence outputs. No Bayesian population prior for the case is used here.

Columns: `alpha`, `case_uncertainty`, `z`, `chi_square`, `t_lower`, `t_upper`, `s_lower`, `s_upper`, `q_lower`, `q_upper`, `g_lower`, `g_upper`, `lower`, `upper`.

### [noisy-future-confidence.csv](M07_DATA/noisy-future-confidence.csv)

Chapter location: `sec-m07-source-link-confidence`. alpha=.025 for joint-region failure, plus.025 for future target noise. lower/upper concern expected K; prediction_lower/upper include future observation noise for at least 95% overall coverage. These broad conservative intervals are not posterior quantiles.

Columns: `alpha`, `case_uncertainty`, `z`, `chi_square`, `t_lower`, `t_upper`, `s_lower`, `s_upper`, `q_lower`, `q_upper`, `g_lower`, `g_upper`, `lower`, `upper`, `prediction_lower`, `prediction_upper`.

### [noisy-posterior.csv](M07_DATA/noisy-posterior.csv)

Chapter location: `sec-m07-source-link-posterior / sec-m07-source-link-example`. target labels H(case source coordinate),K(case expected target),Future(new target reading),Fixed_link(link at supplied.5). mean/variance/median/lower/upper are constrained posterior summaries; lower/upper are central 95% credible quantiles. points/shift define deterministic integration; source_error_scale is the IG prior scale, not the error variance; case_update TRUE includes actual case likelihood, FALSE is the explicitly different calibration-only comparator. physical_probability is the unrestricted product posterior mass of the valid physical domain.

Columns: `target`, `mean`, `variance`, `median`, `lower`, `upper`, `points`, `shift`, `source_error_scale`, `case_update`, `physical_probability`.

### [noisy-refinement.csv](M07_DATA/noisy-refinement.csv)

Chapter location: `sec-m07-source-link-example`. Same columns as noisy-posterior, baseline prior/case update only. Compare 65536 versus 262144 points and two fixed shifts. Finite normal-mixture integrands integrate a,mu analytically; no latent/person values are sampled. Refinement variation diagnoses error without proving a bound.

Columns: `target`, `mean`, `variance`, `median`, `lower`, `upper`, `points`, `shift`, `source_error_scale`, `case_update`, `physical_probability`.

### [one-source-nonidentification.csv](M07_DATA/one-source-nonidentification.csv)

Chapter location: `sec-m07-source-link-identification`. v=true-coordinate variance,s=single source error variance,B=conversion slope,tau=target noise variance. Both rows have same single-source variance 1.5, target variance 2.21, covariance 1.1 but different B. Independent repeats distinguish their v; one reading does not.

Columns: `v`, `s`, `B`, `tau`, `single_source_variance`, `target_variance`, `covariance`.

## Numerical limits and checks

Finite masses, beta/Student quantiles and linear algebra evaluate exact model formulas. Adaptive scalar integrals are used for offset/selection/regression/link CDFs; the shape integral uses 96/192-point Gauss-Legendre rules on each axis. Noisy posterior summaries use 262144 deterministic shifted-Halton points in four dimensions, importance weights for physical truncation, and analytic normal integration of a and mu. 65536 points and a second fixed shift diagnose sensitivity. These are integration diagnostics, not rigorous deterministic error bounds. Fixed-link moments can be sensitive to low reliability; its manuscript comparison uses median/quantiles.

No random generator is used in the example or figures. An independent gamma-draw benchmark in the tests uses seed 771 and 100000 draws, with sampling-error tolerances; that benchmark is separate from the deterministic output. Rounded six-decimal manuscript comparisons use absolute 5e-7 tolerance; other precisions and noisy integration comparisons use explicitly stated tolerances. CSVs preserve more digits than the book prints; extra digits do not create empirical precision.


No representative clinical sample, anchor validity, transport guarantee or optimal equating design is established here. Full calibration likelihoods and their restrictions matter. The accompanying [figure notes](../figures/m07-norms/README.md) record the exact old-to-R mapping, plotted data and accessible panel conventions.
