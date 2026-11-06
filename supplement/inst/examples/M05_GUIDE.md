# M05: measurement and replication in R

This source-based companion rebuilds synthetic teaching calculations. It does not fit a real instrument, analyze patients or recommend a clinical cutoff. Installing the project as a package is unnecessary. The [reproduction guide](../../REPRODUCIBILITY.md) explains the R environment.

## First run

1. Open the source repository folder and use R4.6.1 with the recorded dependencies. If needed, follow `Rscript --vanilla supplement/restore.R` from the repository root (the restore script locates its own folder).
2. Run `Rscript --vanilla supplement/inst/examples/m05-measurement.R`. `Rscript` runs the saved script; the script locates its own supplement folder, reads explicit inputs and writes23 CSVs to `supplement/outputs/m05-measurement/`. Running it twice replaces only those generated files.
3. Open `scalar-intervals.csv`. Each row is a different procedure applied to the same observed35. Read target and center before lower/upper; expected score and next performance are different quantities.
4. Open `scalar-coverage.csv`. Its tau column is the **fixed true expectation in a repeated-data calculation**, not the observed score35. The prior density has units per score point; the coverage columns are probabilities. Do not interpret the density as a fourth coverage curve.
5. Compare `gt-designs.csv` with the later calibration tables. Supplied components permit exact design predictions. Constructed observed mean squares are data summaries with uncertain components. `person-mixtures.csv` integrates that uncertainty and, for the new case, its own likelihood.
6. Run `Rscript --vanilla supplement/run_checks.R` for all existing companion checks plus M05. Run `Rscript --vanilla supplement/inst/examples/m05-interval-figure.R` for the figure; its guide and provenance explain the two panels. No random seed is needed: these examples and the shifted-Halton coordinates are deterministic.

To inspect a table in an interactive R session, use `readr::read_csv("supplement/outputs/m05-measurement/scalar-intervals.csv")`. `read_csv` reads rows/columns into a tibble; `dplyr::filter` can select a named procedure. The reader script shows the sequence explicitly with comments. Functions are in `R/m05-measurement.R`; they return tibbles or named lists, leaving printing and file writing to the example script.

## Inputs, targets and columns

All numeric values are stipulated. Scores/means/SDs are points, variance/covariance components are squared points, coefficients/shares/coverage/probabilities are fractions, and counts/degrees of freedom are dimensionless. All intervals use95% unless a row names a simultaneous construction. Lower/upper concern the target identified by that table, never an already observed score. The person population and replication universe are part of the calculation.

### binary.csv

Count2/8 under independent same-person Bernoulli repeats and predetermined Beta(2,2) prior. Confidence tails are Clopper–Pearson; credible tails and predictive mean use Beta(4,8). Fractions0–1.

Columns: `success`, `repeats`, `confidence_lower`, `confidence_upper`, `posterior_a`, `posterior_b`, `posterior_mean`, `credible_lower`, `credible_upper`, `population_single_reliability`, `average_reliability`.

### crossed-component-box.csv

Seven lower/upper component bounds from simultaneous chi-square eigenvalue rectangle, inverted with signs and nonnegativity. Outer conservative box, not sharp extrema.

Columns: `component`, `lower`, `upper`.

### crossed-constructed-data.csv

160 deterministic scored cells with explicit person/task/rater IDs and orthogonal construction. No patient records or random sample. Projecting recovers the seven summaries and person1 average35.9092228745.

Columns: `person`, `task`, `rater`, `score`.

### crossed-design-confidence.csv

Images of the same component box for4x2,8x2,4x4. Original design additionally uses analytic nonnegative-interaction bound. Endpoints unrounded; manuscript displays outward rounding.

Columns: `J`, `K`, `lower`, `relative_upper`, `absolute_upper`.

### crossed-posterior.csv

Proper full seven-component prior-importance integration, component orderP,T,R,PT,PR,TR,e. Shape3/8 priors have the same stipulated component means. Original and alternative design coefficients are integrated ratios, not ratios of mean components.

Columns: `shape`, `points`, `J`, `K`, `relative_mean`, `absolute_mean`, `relative_lower`, `relative_upper`, `absolute_lower`, `absolute_upper`.

### dependent-items.csv

Each row is a response pattern at p=.25/.75 and dependence0/.1. Full kernel probabilities are computed, not fitted. Conditional sum variance includes2d; repeated draws retain H but redraw response kernel.

Columns: `p`, `dependence`, `pattern`, `probability`, `expected_sum`, `conditional_variance`, `replication_reliability`.

### design-ordering.csv

Posterior probability that4x4 improves over8x2, obtained using exact component inequalities under the same integration weights. Effective weight count diagnoses quadrature concentration, not independent draws or a rigorous uncertainty estimate.

Columns: `shape`, `points`, `relative_probability`, `absolute_probability`, `effective_weight_count`.

### factor-shares.csv

Single-test and two-test-mean variance decomposition: common loading6, stable specificity28 and transient36 per test. Replication includes stable specificity; factor share excludes it.

Columns: `score`, `factor_variance`, `specificity_variance`, `transient_variance`, `observed_variance`, `replication_reliability`, `factor_share`.

### gt-designs.csv

Supplied components(64,9,4,16,9,4,36); future random designs4x2,8x2,4x4 and fixed-rater4x2. Fixed-rater target includes person–rater terms, so its numerator changes.

Columns: `J`, `K`, `fixed_raters`, `person_variance`, `relative_error`, `absolute_error`, `relative_coefficient`, `absolute_coefficient`, `absolute_sd`.

### gt-mean-squares.csv

Seven effect rows in e,PT,PR,TR,P,T,R order, calibration20 people,4 tasks,2 raters. Means/sums concern components, not160 independent rater observations.

Columns: `effect`, `degrees_of_freedom`, `expected_mean_square`.

### integration-convergence.csv

Change between131072 and524288 deterministic shifted Halton points for each prior shape. These are observed numerical sensitivities, not guaranteed error bounds or Monte Carlo standard errors.

Columns: `shape`, `coarse_points`, `fine_points`, `relative_mean_change`, `absolute_mean_change`, `relative_ordering_change`, `absolute_ordering_change`.

### moment-counterexample.csv

Two finite tau populations with kernel P(Y=2|tau)=(tau+2)/4. Same first/second moments and single-score law, different positive-tau posterior. Y2 here means the value positive2, not a second occasion.

Columns: `population`, `mean_tau`, `variance_tau`, `probability_Y2`, `variance_Y`, `average_error_variance`, `reliability`, `posterior_positive_tau`.

### new-person-confidence.csv

Independent new4x2 average35, entire facets fresh. Calibration box at delta=1−sqrt(.95), independent standardized case error event; huge bounds are conservative, not a lower bound on achievable precision.

Columns: `observed_average`, `upper_absolute_error_variance`, `lower`, `upper`.

### oneway-confidence.csv

20 people,3 repeats,B144,W36. Exact central F confidence set for eta=a/e and its reliability maps. Empty set remains empty, including in the helper boundary tests.

Columns: `eta_lower`, `eta_upper`, `empty`, `reliability_lower`, `reliability_upper`, `mean_reliability_lower`, `mean_reliability_upper`.

### oneway-posterior.csv

Unknown one-way a,e,mu with IG(3,128),IG(3,72),N(50,400). Two log-grid approximations501/1001 per axis. Scalar ratio posterior, not a person interval; grid endpoints/truncation are fixed numerical choices.

Columns: `points_per_axis`, `mean`, `lower`, `median`, `upper`.

### person-mixtures.csv

Calibrated person1, independently observed new person average35, and fresh-facet future average after35. Conditional normals integrated using actual CDF. New case likelihood updates component weights. within+between equals total variance; no general plug-in ordering is asserted.

Columns: `mean`, `variance`, `within`, `between`, `lower`, `upper`, `target`, `observed_average`, `shape`, `points`.

### prior-sensitivity.csv

Only the supplied prior variance changes16/64/256; prior mean50 and error variance36 remain fixed. These are alternative populations/priors, not estimated models.

Columns: `prior_variance`, `posterior_mean`, `posterior_variance`.

### replication.csv

Four parallel repetitions under independent, shared-positive and finite-negative error covariance. Stable/noise inputs are variances; error SD is in points. The stable9 row changes the person population, keeping noise fixed.

Columns: `stable`, `noise`, `repeats`, `common`, `single_reliability`, `repeat_correlation`, `average_error_variance`, `average_reliability`, `error_sd`.

### scalar-coverage.csv

401 fixed tau coordinates0–100 in .25-point increments. confidence_and_likelihood_prediction is one coincident.95 curve; other columns are repeated-data coverage; prior_density is a density per point, not coverage.

Columns: `tau`, `confidence_and_likelihood_prediction`, `credible`, `posterior_predictive`, `prior_density`.

### scalar-intervals.csv

Known Y|tau~N(tau,36),tau~N(50,64),y35. Four95% procedures. variance is the variance used by that procedure; confidence and prediction variance are sampling constructions, not posterior moments.

Columns: `procedure`, `target`, `center`, `variance`, `lower`, `upper`, `level`.

### state-calibration.csv

20 independent people/two occasions, mean0, S_M²11,Q_D80. Simultaneous variance confidence rectangle and outer trait share. Restricted IG(13,126.5),IG(13,48) posterior with uniform or Beta(8,2) trait split; no split learned from data.

Columns: `u_lower`, `u_upper`, `r_lower`, `r_upper`, `share_confidence_lower`, `share_confidence_upper`, `unrestricted_probability`, `uniform_split_mean`, `uniform_split_lower`, `uniform_split_median`, `uniform_split_upper`, `beta82_split_mean`.

### state-equivalence.csv

Components(g,s,a,e)=(4,5,1,3) and(8,1,3,1). Both total variance13/covariance9 but different current target G+A posterior at centered score−3.

Columns: `g`, `s`, `a`, `e`, `variance`, `cross_occasion_covariance`, `current_target_variance`, `posterior_mean`, `posterior_variance`.

### two-test-prediction.csv

Profile(35,50), common factor N(0,1),loadings6,specificity28I,transient36I. Same-specificity prediction retains stable S; fresh-specificity prediction redraws it. Mean scores in points; covariance/variance in squared points.

Columns: `experiment`, `mean1`, `mean2`, `variance1`, `variance2`, `covariance12`, `factor_mean`, `factor_variance`.

## Numerical interpretation and limits

Exact algebra and named quantiles are distinguished from numerical integration. State inference uses adaptive1D quadrature/root finding; the updated IG totals are restricted to u>r/2, while split priors remain unchanged. One-way posterior uses finite log grids on a∈[.001,2000],e∈[5,200],with the correct a·e Jacobian; endpoints converge more slowly than its mean. The two grid resolutions are printed rather than disguising discretization as exact inversion.

The seven-component posterior uses inverse-gamma transforms of deterministic shifted Halton points (bases2,3,5,7,11,13,17;skip128;shift from fractional square roots;no random seed). Likelihood weights include all seven contrast spaces and the uncertain grand mean. Coarse/fine comparisons use2^17 versus2^19 points. The numerical CDF has finite-weight approximation error; printed manuscript rounding may differ at the last digit. Practical comparison tolerances for this example: coefficient means.0001, quantile endpoints.002, design probabilities.004,person means.02/variances.03/interval endpoints.03; these are verification tolerances against independent computations, **not mathematical error guarantees**. The observed resolution differences are in integration-convergence.csv. For more precise tail or ordering statements, increase integration resolution and compare distinct shifts/another method; do not treat weight concentration as a Monte Carlo standard error. The chapter calculations use scrambled Sobol integration and rejection checks. This R calculation uses a different approximation and does not reproduce the same random sequence.

A calibrated person's posterior, an unobserved new person's calibration-informed population distribution, and an observed new case's joint posterior are different. The new case reweights component probabilities; fresh-facet prediction adds future absolute error. Known Gaussian and estimated-component experiments are not interchangeable. Continuous positive IG priors exclude exactly zero components; a point-null question needs explicit boundary mass. No routine here supplies construct validity, empirical model fit, population transport, response validity, diagnosis, change or action.

Retained deterministic baselines are beside this guide in M05_DATA/. PROVENANCE.txt records algorithms and parameter order; each run writes session-info.txt with its environment. Reproduction compares computed data and same-host images; cross-platform fonts/devices may change image bytes. The supplied data and scripts are sufficient to run these examples.
