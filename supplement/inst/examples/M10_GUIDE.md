# M10: heterogeneity and robustness in R

These are synthetic teaching calculations for observed-profile comparisons. They do not score patients, infer diagnoses or validate a population law. The nine chapter units use different targets: a peer event frequency, a model component, personal replication variance, and realized prediction-region content must remain distinct.

## Run the examples

1. Keep the `supplement` folder intact. From its parent directory run `Rscript --vanilla supplement/inst/examples/m10-robustness.R`. R 4.6.1 and the locked dependencies are the tested environment; setup instructions remain in the companion README. Installing this source tree as a package is not required.
2. The script sources the functions in `R/m10-robustness.R`, reads three CSV files of stipulated synthetic profiles, then writes 22 tables into `outputs/m10-robustness/`. Each numbered script comment explains why the next operation is needed.
3. Open a table with, for example, `x <- readr::read_csv("supplement/outputs/m10-robustness/student-radial-rates.csv")`; enter `x` to inspect it. Probabilities are fractions between zero and one; multiply by100 only for percentages.
4. Read the target beside its table below and the complete [column definitions](M10_COLUMNS.csv). Rerun `Rscript --vanilla supplement/run_checks.R` for analytic, enumeration and implementation checks. Retained deterministic reference outputs are in `M10_DATA/`; raw inputs and provenance are in `M10_INPUTS/`.

The two profile datasets preserve the exact raw observations used by the manuscript's Python-generated seed 271006 and seed 271007 examples. They are supplied values here; this R script does not claim that R's random-number generator reproduces Python's seeded sequence. PROVENANCE.json identifies the supplied files, their hashes, fields, and synthetic status. The R calculations fit the models to these raw inputs.

## Table-to-chapter map

| Output table | Question, target and important condition |
|---|---|
| `quadratic-moments.csv` | Fixed finite asymmetric observed-score distribution; exact enumeration and moment identities. |
| `student-radial-rates.csv` | Known five-score covariance-matched Student population; chi-square .95 radius cutoff. |
| `conditional-student.csv` | Known bivariate Student law nu=5, unit marginal variances, rho=.5; target score <=-2 given companion. |
| `five-score-mixture.csv` | Known .7 N(0,R)+.3 N(-1.5 v_M,R); case z=-1.5 v_M and event Z1<=-1.5. |
| `weight-uncertainty.csv` | Six observed scalar scores, fixed N(0,1)/N(-2,1) components, Beta(1,1) weight prior. |
| `gaussian-replication.csv` | Stable Gaussian general/domain factors with fresh occasion errors, as p grows. |
| `personal-scale.csv` | Fixed two-occasion contrast energy6, p5; fixed-person confidence versus IG population-prior posterior, nu5 beta1. |
| `copula-low-events.csv` | Known Gaussian/Student copulas, Student nu4; margins fixed at low probability .05. rho=.5 matches copula parameter, not observed Pearson correlation. |
| `ordinal-cell-counts.csv` | Raw observed synthetic two-test low/high counts from100 independent peers. |
| `ordinal-both-low.csv` | Saturated four-cell Dirichlet(1,1,1,1) prior versus exact binomial confidence for observed both-low event. |
| `finite-reference-and-niw.csv` | Gaussian n12 p5 frequentist new-case radius plus separate proper NIW example m0=0,kappa0=1,nu0=8,Psi0=2I; stipulated mean and S=R. |
| `sensitivity-bounds.csv` | Deterministic declared neighborhoods; no fitted confidence interpretation. Separate defaults q9 eta.2 epsilon.1; KL example eta.1 p5 no mean shift. |
| `contamination-posterior.csv` | 8 both-low events/100; independent uniform clean and contamination event priors. Posterior epsilon assumption varies; all sensitivity/envelope columns hold epsilon_max=.05 fixed. |
| `computation-error.csv` | Finite fixed simulation-budget laws and independent nested posterior/indicator variance identity; no draws generated. |
| `learned-density-criterion.csv` | Literal leave-one-person-out raw-score density criterion with mean/covariance/target refitted each fold; nu then lambda candidate order. |
| `learned-density-fit.csv` | Refit selected Student/shrinkage model on all 30 raw profiles; fixed event Z1<=-1.5. |
| `grid-posterior.csv` | Same30 raw profiles; equal prior masses on45 location/covariance-scale/nu models with restricted shape R. |
| `grid-posterior-gaussian-prior.csv` | Same45 models/data; prior Gaussian family mass.8, other four family masses.05 each. |
| `rank-training-criterion.csv` | Training-only leave-one-person-out transformed Gaussian score; empirical margins and covariance/target refitted within every fold. |
| `calibration-scores.csv` | 99 independent calibration profiles evaluated by one fixed map fitted on30 independent training profiles. |
| `rank-calibration-rule.csv` | Inclusive rank95 of99 at alpha.05; illustrative new observed profile zero; all fitting remains training-only. |
| `calibration-content-laws.csv` | Exact subgroup example, continuous-score order-content sampling laws and stronger tolerance objective; not posteriors for the empirical rank map. |

## Follow the operations

The moment example calculates the same quantities two ways: sum the full finite probability law, then use its moments. The Student example keeps covariance fixed while changing tails; its conditional scale is converted separately to an actual variance. Mixture membership integrates joint and total case density before dividing; the reference-only responsibility average is included as an explicitly different calculation.

Personal variance uses paired contrast energy: the confidence interval repeats errors at a fixed variance, whereas the posterior uses the specified inverse-Gamma population prior. The covariance table separates an exact repeated-reference F cutoff from a proper-prior Student prediction. Neither is a confidence interval for a person's latent ability.

Contamination posterior rows use different epsilon assumptions and uniform q,h priors. The repeated sensitivity/envelope columns always use epsilon_max=.05, independent of the posterior row's epsilon model. A narrower fixed-epsilon sensitivity set would be a different calculation. The clean event prior differs from the saturated four-cell prior, which is why their both-low posteriors differ.

For fitting, `m10_fit()` leaves one whole person out, fits each candidate on the other profiles and sums held-out negative log scores. It refits the final model on all training people only after selection. In rank mode it also refits empirical margins within every fold. The calibration sample then sees the fixed full-training map; it never selects lambda. Ties are accepted inclusively. The illustrative new profile is the zero vector, chosen for a transparent score demonstration, not a new clinical dataset.

`m10_grid()` is a different analysis of the same 30 raw reference profiles: it integrates45 supplied laws with fixed covariance shape R, location m and multiplier s. Its posterior weights are not bootstrap selection frequencies. To calculate its posterior predictive fixed-event probability, read `grid-posterior.csv` and use `sum(x$weight * x$event_probability)`. The Gaussian-favouring prior table changes only prior family masses, not the data or candidate support.

## Numerical scope and limits

All22 outputs are deterministic. Named CDFs/quantiles, finite sums, one-dimensional adaptive quadrature and finite-dimensional Gauss--Legendre rules are labelled by their target. Copula error columns are reported adaptive error estimates, not guaranteed bounds. Contamination uses60 nodes per integrated uniform coordinate; tests compare80 nodes and an independent incomplete-beta integral. Its polynomial likelihood has degree 100 per coordinate, so the60-node rule is exact for that polynomial integral in exact arithmetic; floating-point arithmetic and posterior root solving still need numerical checks. Defaults report absolute comparison tolerances, with rounded manuscript values allowing half a final printed unit.

The companion implements selected calculations in every unit, including both complete training/tuning algorithms and the45-law event posterior. It does not rerun the 100,000 covariance simulation,10,000 learned-rule repetitions,2,000+2,000 bootstrap experiments,5,000 complete calibration repetitions, or millions of region-content predictive draws. These larger resampling studies are separate from the selected R calculations. Analytic inputs, fitted results, counts, and Monte Carlo bounds retain their distinct meanings. Full unrestricted Student/mixture/copula posteriors, global Neyman inversions, population scale-hyperparameter integration and general pattern LPs remain advanced manuscript definitions or separate calculations, not advertised R implementations here. No numerical demonstration is a proof or empirical clinical validation.

The figure entry point is `m10-cutoff-figure.R`; its [figure guide](../figures/m10-one-cutoff/README.md) explains the two panels, raw probabilities, grayscale versions and device provenance.
