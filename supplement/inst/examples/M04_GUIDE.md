# M04: level, shape, replication and information

All inputs are synthetic teaching experiments. These programs do not infer a person's latent ability, diagnose disease, validate a battery or recommend a cutoff. Every target below keeps its stated reference population, scale, observations and prior. A reference tail, a confidence set, a posterior probability and prospective power are different outputs.

## First run

Use the companion setup in README.md/REPRODUCIBILITY.md. From the source repository root (the directory containing book/ and supplement/), run:

```r
# In a terminal, not the R console:
Rscript supplement/inst/examples/m04-level-shape.R
Rscript supplement/run_checks.R
```

The example sources R/m04-level-shape.R, creates outputs/m04-level-shape/, and writes 13 CSVs. The functions are sourced directly. The command locates its own supplement directory, so a correctly supplied script path also works from another directory. Read a result from R with `readr::read_csv("supplement/outputs/m04-level-shape/profiles.csv")`. A CSV row is an experiment output, not a patient record; `NA` may be a deliberate unavailable target and `Inf` the normal-limit degrees of freedom.

1. Start with profiles.csv and shifts.csv. For A, ell=−.75 and Q_v=2.8125; coefficient sign and squared residual answer different questions. Geometry uses standardized scores, while the score columns keep raw inputs.
2. Read dispersion and floor outputs before interpreting spread. Cross-coordinate variance is not the standard error of a personal mean. A small spread can arise at a floor.
3. Compare power.csv only within its declared alternatives/procedure. A different optimal direction is used for each known-law row. Finite-norm rows repeat independent norms and a new person.
4. Paired outputs require known zero contrast means. N=12 is not the degrees of freedom of a centered unknown-mean Pearson correlation. General unknown-mean reproducibility remains a separate exact integral/region-image specification in the chapter.
5. Training-average outputs redraw training studies; training_posterior.csv conditions on a separate realized training sample and freezes its fitted weights. Its class probability also needs the supplied prevalence.

## Tables and dictionaries

### profiles.csv

Chapter `sec-m04-geometry-example`. Two observed A/B profiles; standardized covariance-weighted projection and reference tails.

Columns: `profile`, `score1`, `score2`, `coefficient`, `level`, `shape`, `total`, `level_lower_tail`, `shape_upper_tail`, `radial_upper_tail`.

profile names A/B; score1/score2 are raw higher-is-better units; coefficient is ell; level is signed standardized L; shape is Q_v; total is full squared distance; level_lower_tail is Phi(L); shape_upper_tail is chi-square(p−1) upper tail; radial_upper_tail is chi-square(p) upper tail.

### shifts.csv

Chapter `sec-m04-geometry-example`. Three stipulated shifted populations, not observed patients.

Columns: `shift`, `delta1`, `delta2`, `level_squared`, `shape_noncentrality`, `total_noncentrality`, `flat_retained_fraction`.

shift names global/focal/opposing; delta1/delta2 are standardized population mean changes; level_squared is lambda_L²; shape_noncentrality is lambda_Q; total_noncentrality is deltaᵀR⁻¹delta; flat_retained_fraction is level_squared/total_noncentrality.

### displacement.csv

Chapter `sec-m04-displacement-confidence`. Population-mean displacement from profile A, known covariance; unit prior variances.

Columns: `level_posterior_mean`, `level_posterior_sd`, `level_confidence_lower`, `level_confidence_upper`, `shape_confidence_lower`, `shape_confidence_upper`, `shape_posterior_mean`, `shape_credible_lower`, `shape_credible_upper`.

level_posterior_mean/level_posterior_sd concern theta_L; level_confidence_lower/upper are 95% sampling bounds; shape_confidence_lower/upper invert the noncentral CDF for squared mean shape; shape_posterior_mean and shape_credible_lower/upper concern that same squared parameter under b=.5.

### dispersion.csv

Chapter `sec-m04-dispersion`. Observed within-profile variance on stated standardized origin; central moment benchmark.

Columns: `origin`, `expectation`, `variance`, `observed_A`, `observed_B`, `nonflat_covariance`.

origin labels the analysis center; expectation/variance are moments of s² across people; observed_A/observed_B are the two observed variances; nonflat_covariance is Cov(wᵀX,s²)=.5 in the separate diagonal(2,1),delta(1,0),w=(.5,.5) example.

### battery_length.csv

Chapter `sec-m04-gaussian-length`. Specified stable Gaussian domain-factor sequence.

Columns: `number_scores`, `squared_spread_correlation`, `single_score_retest`, `within_domain_correlation`, `between_domain_correlation`.

number_scores is even p; squared_spread_correlation is paired Corr(s1²,s2²); single_score_retest is .45 throughout; within_domain_correlation=.45 and between_domain_correlation=.27 are observed within-occasion correlations.

### floors.csv

Chapter `sec-m04-floor`. Two deterministic trajectories through the same common floor −10.

Columns: `trajectory`, `time`, `score1`, `score2`, `within_profile_variance`.

trajectory 1 uses a=(0,0),b=(1,2); trajectory 2 uses a=(4,0),b=(3,1); time is t; score1/score2 are clamped coordinate values; within_profile_variance uses divisor p−1. Neither t nor the curves is an empirically validated severity scale.

### coefficient_of_variation.csv

Chapter `sec-m04-count-cov`. Raw positive-origin CoV; unavailable after standardization for these two profiles.

Columns: `profile`, `raw_mean`, `raw_sd`, `raw_cov`, `standardized_mean`, `standardized_cov`.

profile is A/B; raw_mean/raw_sd are score-unit summaries; raw_cov=raw_sd/raw_mean is dimensionless; standardized_mean=(raw_mean−50)/10; standardized_cov=NA because both standardized means are nonpositive, not a numerical failure.

### finite_comparison.csv

Chapter `sec-m04-finite`. Same observed15-point gap under three explicitly different reference experiments.

Columns: `experiment`, `df`, `squared_scale`, `two_sided_tail`.

experiment labels known law,comparison prior/sampling,proper prior; df is Student degrees (Inf denotes the known normal limit); squared_scale is scale², not generally variance; two_sided_tail is the unchanged gap event probability under each experiment.

### power.csv

Chapter `sec-m04-finite-power; sec-m04-power-example`. Prospective rejection rates at size .05 for fixed alternatives.

Columns: `experiment`, `shift`, `flat_level`, `shape`, `full_radius`, `optimal_discriminant`.

experiment known law versus independent n=20 norms/new person; shift selects the declared population; flat_level is lower-tail power; shape/full_radius are upper radial powers; optimal_discriminant is row-specific oracle power only in known-law rows,NA in finite rows because that rule was not the finite-norm procedure.

### paired.csv

Chapter `sec-m04-paired-contrast-example`. Known zero contrast means; N=12,uncentered scatter(12,9;9,12),proper IW(4,2I) prior.

Columns: `contrast_correlation`, `plugin_square_correlation`, `plugin_sd_correlation`, `posterior_square_mean`, `posterior_sd_mean`, `nu_posterior`, `scale_correlation`, `rho_confidence_lower`, `rho_confidence_upper`, `square_confidence_lower`, `square_confidence_upper`, `square_credible_lower`, `square_posterior_median`, `square_credible_upper`, `sd_credible_lower`, `sd_credible_upper`.

contrast_correlation is r_W; plugin_square_correlation and plugin_sd_correlation evaluate the two population functions at r_W; posterior_square_mean/posterior_sd_mean integrate different functions; nu_posterior and scale_correlation parameterize the posterior kernel; rho_confidence_lower/upper invert the exact sampling CDF; square_confidence_lower/upper are the mapped confidence set; square_credible_lower/upper and square_posterior_median are posterior quantiles; sd_credible_lower/upper transform the same absolute-correlation quantiles.

### prior_sensitivity.csv

Chapter `sec-m04-paired-contrast-example`. Same paired observations, four predetermined teaching priors.

Columns: `nu0`, `prior_scale_diagonal`, `prior_mean_variance`, `posterior_square_mean`.

nu0 and prior_scale_diagonal define IW prior; prior_mean_variance=scale/(nu0−3); posterior_square_mean is integrated E(rho²|data). First pair means 2 and10/9 differ; second pair has matched mean 1 but different concentration. Priors were not tuned from outcomes.

### training_average.csv

Chapter `sec-m04-trained-example`. Repeated fresh two-group training studies with population distance 1.25,5 per group.

Columns: `oracle_auc`, `known_covariance_training_average`, `estimated_covariance_training_average`, `reversed_known_direction_probability`, `angle_density_integral`, `scatter_angle_density_integral`.

oracle_auc uses true direction/covariance; known_covariance_training_average learns only direction; estimated_covariance_training_average fits pooled covariance too; reversed_known_direction_probability pertains only to the known-covariance branch; angle_density_integral/scatter_angle_density_integral are normalization checks.

### training_posterior.csv

Chapter `sec-m04-trained-posterior`. Separate realized summaries xbar0=0,xbar1=(1.25,0),S_P=I;proper NIW prior.

Columns: `nu_posterior`, `mean 1_first`, `scale_first`, `scale_second`, `auc_posterior_mean`, `auc_credible_lower`, `auc_posterior_median`, `auc_credible_upper`, `class1_probability`, `external_prevalence`.

nu_posterior,mean 1_first,scale_first/second describe the completed-square posterior; auc_posterior_mean/median and auc_credible_lower/upper condition on fixed observed weights; class1_probability uses the two Student class predictions at new x=(1.25,0); external_prevalence=.2 is supplied independently of training fractions.

## Numerical status and scope

Normal/chi-square/Student/F evaluations and small matrix operations use base R statistics. Shape-displacement confidence sets invert the noncentral chi-square CDF; a sufficiently small q can return `empty=TRUE` with NA bounds, and is never replaced by {0}. Paired correlation uses nested deterministic angular quadrature and root inversion; 95% intervals are fixed in this worked helper. Absolute/relative integration tolerances are stated beside each operation (typically 1e−8 to1e−11), with scalar root tolerances1e−9 to1e−11. The r=sin(t) substitution removes endpoint singularities in the sampling density. Tests check the rho=0 beta-angle law independently and the defining confidence endpoints. No local numerical optimum is reported as a globally guaranteed confidence bound.

Training averages integrate two angular densities, including covariance-estimation randomness. The helper explicitly limits effect/sqrt(mean-difference variance) to 8; larger effects require a stabilized numerical implementation. The AUC posterior instead integrates a chi-square precision coordinate; its mean is checked against the Student formula. These are exact integral representations evaluated numerically, not simulation or empirical validation. Six-decimal printed values allow 5e−7 absolute rounding error; full-precision cross-language/defining-identity comparisons use tighter stated tolerances. Same-host deterministic CSV reproduction is checked.

The code does not calculate the unrestricted unknown-mean paired posterior's general correlation quantiles or globally optimize its confidence-region image. It does not implement an arbitrary selected-direction procedure, singular-covariance pseudoinverse, regularized classifier or deployed clinical model. No such guarantee is inherited from these examples. The paired-prior comparison distinguishes differences in prior concentration from differences in prior mean covariance.

The [figure guide](../figures/m04-level-shape/README.md) describes the figure command and provenance. Source functions and supported domains are documented in man/m04-level-shape.Rd. Original code/data reuse follows the shared project terms.
