# M09 R companion: records, targets and uncertainty

All observations are synthetic. These functions reproduce model calculations; they do not score patients or prescribe clinical cutoffs. The source-based companion uses the recorded dependency lock; no package installation of neuropsychmethods is advertised.

From the repository root run:

```sh
Rscript --vanilla supplement/inst/examples/m09-administration.R
Rscript --vanilla supplement/run_checks.R
```

The example sources `supplement/R/m09-administration.R` and writes 29 numerical CSVs into `supplement/outputs/m09-administration/`. Retained full-precision baselines are in [M09_DATA](M09_DATA/). [M09_COLUMNS.csv](M09_COLUMNS.csv) defines every column and its target; the table below explains the computation families. `NA` means unobserved, not zero.

## Start with the record

The screening rule inspects the first two independent standard-normal scores and omits the third only when both are negative. Compare the stopped pair with a fixed pair: scatter changes, while squared-radius tails survive sign conditioning. Keep the expected scatter and flag probabilities separate. `m09_screening()` calculates these quantities directly.

The fitted example uses all 60 first-score/pattern records. The second score exists in the declared full protocol but is observed only 36 times. `m09_records()` retains all first scores and flags, generates the stated twelve-decimal synthetic response inputs, and leaves omissions as `NA`. `m09_mar_fit()` fits only recorded responses; the cell law still uses everyone. A known category does not need composition averaging, while `m09_population()` integrates it.

Use `m09_pattern()` for six-cell posterior estimation, `m09_case()` for a conditional mean or actual response, and `m09_profile()` for actual scatter. A mean-confidence interval and a response prediction interval have different noise terms. A mean-filled scatter is not expected scatter. `m09_joint_profile()` integrates one shared coefficient/variance posterior for two omitted people; independently sampled marginal distributions would change the joint event.

The support-gap outputs use a separate protocol with no low-category second responses. `support-gap-mean-sensitivity` concerns an unknown mean and excludes individual response noise. `support-gap-response-sensitivity` predicts the actual response scatter and includes that noise. A line restriction or external departure radius supplies an assumption; the missing group does not estimate it.

For adaptive administration, `m09_adaptive()` integrates all possible reference-state allocations and both case states. The three noisy anchors are observations, not true states. The saved choice can add evidence. `m09_adaptive_summary()` restores stop coins and sums all 10 possible case paths for the actual three-reference dataset before grouping by total. The resulting average posterior risks are conditional on those reference records, not the chapter’s global average over all possible reference datasets.

In `m09_crossing()`, at each step split the surviving mass between failure and success, remove the mass that crosses, and carry only survivors forward. A known-null comparison, a denominator estimated from one reference response, and stopping when a central posterior interval excludes .5 are distinct procedures. `m09_stopped_record()` keeps response order before choosing the actual observed prefix.

`m09_censoring()` treats each saved deadline as a survival probability and each completed time as a density. Its normalized-likelihood confidence construction differs from its gamma credible interval. The matched-prior table changes retained data while holding each rate prior fixed. `m09_missing_flag()` instead models a well-defined binary flag that was sometimes unrecorded; its population parameter, new-person probability and actual-cohort prediction have different denominators. Four positive retrieved flags out of five update the missing-group prior but never change the initial-status counts. Retrieval conjugacy is implemented only on the full beta probability scale.

## Output map

| CSV | Target and computation |
|---|---|
| `screening-law.csv` | Known fixed/selected screening law: means and two distinct flag probabilities. |
| `score-pattern-counts.csv` | All 60 first-category/pattern counts; denominators include abbreviated records. |
| `pattern-prior-sensitivity.csv` | Proper joint-cell posterior contrast, shared covariance and conservative finite confidence enclosure. |
| `mechanism-posterior.csv` | Unknown continuation probability by first category, with central 95% posterior interval. |
| `pattern-integration-refinement.csv` | Same joint-cell target at three quadrature orders; observed convergence only. |
| `new-case-rank-calibration.csv` | Finite conditional errors at each random abbreviated reference count; binomial count weights. |
| `observed-mar-records.csv` | All 60 synthetic first scores/indicators and the 36 actually observed second scores. |
| `conditional-mean-and-response.csv` | Known-category kernel mean versus actual omitted response; confidence/prediction versus proper posterior. |
| `population-composition.csv` | Full-population or abbreviated-population mean, integrating unknown composition and response parameters. |
| `fitted-scatter.csv` | Actual missing two-score scatter under baseline/response/cell priors; cell factor cancels for known category. |
| `shared-missing-responses.csv` | One/two-person scatter-tail integrals under a shared coefficient/variance posterior. |
| `mnar-response-departures.csv` | Same observed response fit, declared unlearned point or uniform missing-response departure. |
| `support-gap-records.csv` | Separate protocol with no low-category second response; no absent score inserted. |
| `support-gap-response-sensitivity.csv` | Actual omitted response scatter under the separate support-gap protocol. |
| `support-gap-mean-sensitivity.csv` | Conditional low-category mean departure; excludes individual response noise. |
| `adaptive-reference-records.csv` | Three noisy anchors, full item responses and recommendations; no true latent states supplied. |
| `adaptive-case-updates.csv` | Case state posterior as first response, saved choice and chosen response arrive. |
| `adaptive-sensitivity.csv` | Full saved path, wrongly dropped policy factor and coarsened total under three priors/anchors. |
| `adaptive-path-law.csv` | All 10 stopped paths conditional on the actual three reference records; restores known stop coins. |
| `adaptive-total-law.csv` | Policy-path probabilities summed by total, not a fixed-battery binomial law. |
| `adaptive-record-risk.csv` | Prior-predictive conditional-on-reference average posterior squared-error risk and coarsening loss. |
| `stopping-crossings.csv` | Exact finite recursion over all Bernoulli response orders; known/fitted denominators and credible stopping differ. |
| `stopped-record-order.csv` | Same terminal counts in different orders; actual observed prefix at first crossing or horizon. |
| `fixed-censored-records.csv` | Six meaningful completion times and four saved administrative limits. |
| `completion-rate.csv` | Full time/indicator gamma posterior, normalized-LR confidence set and new-person completion probability. |
| `matched-censoring-priors.csv` | Times versus indicator-only data compared while holding each rate prior fixed. |
| `missing-flag-sensitivity-and-validation.csv` | Unknown population flag probability, new missing person and actual-cohort fraction under declared assumptions. |
| `missing-flag-identified-sets.csv` | Empirical identified ranges and finite entire-set enclosures; restrictions externally supplied. |
| `cohort-completion-law.csv` | Actual cohort: only ten unrecorded flags random; beta-binomial uniform completion count. |

## Numerical status and reproducibility

All outputs are deterministic; there is no Monte Carlo seed to set. Normal/Student/beta/gamma CDFs and finite sums use R statistics functions. Gauss–Jacobi beta quadrature is built from a symmetric recurrence matrix; shared-response integration uses normal/gamma recurrence matrices. The order columns count nodes per coordinate. `pattern-integration-refinement` and `shared-missing-responses` show observed refinement changes. Root solving targets the numerically integrated CDF. These are convergence diagnostics, not certified bounds on total error. Fixed missing-group endpoints 0/1 use exact beta marginal reductions.

Independent tests compare polynomial moments, a direct raw-prior adaptive likelihood integral, full binary-word crossing enumeration, Student moment integrals, confidence coverage over finite binomial experiments and invalid/empty-record cases. Same-host CSV/PNG reproduction does not certify other operating systems or font devices. Session versions and provenance are saved with outputs.

This companion reproduces the core calculations in every chapter unit. The dependent-prior/shared-parameter, selected-only five-dimensional transport and exhaustive calibration-clock/stopping-policy calculations are documented in the manuscript but are outside these R examples. Large-sample repeated-imputation simulations are also outside this companion. Numerical examples are not proofs.

Rebuild the screening figure with `m09-screening-figure.R`; its [figure guide](../figures/m09-screening/README.md) records data, panels, vector masters and device details.
