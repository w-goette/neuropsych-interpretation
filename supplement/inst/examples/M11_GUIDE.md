# M11: clinical targets and decisions in R

These examples follow the chapter from a positive flag to an external-target probability, its uncertainty and a loss-based action. All observations, priors, populations and costs are synthetic teaching inputs. They do not supply instrument norms, clinical cutoffs or patient recommendations.

## Run and inspect

1. Keep this supplement folder intact. From its parent folder run `Rscript --vanilla supplement/inst/examples/m11-clinical-targets.R` using the existing R 4.6.1/locked setup in REPRODUCIBILITY.md. Installing this source tree as a package is not required.
2. The entry point reads the two supplied [observation files](M11_INPUTS/README.md), sources the functions and writes 28 CSV tables to `outputs/m11-clinical-targets/`. Each comment explains why an operation is needed. Count records and priors are written explicitly inside their named functions.
3. For example, enter `x <- readr::read_csv("supplement/outputs/m11-clinical-targets/flag_risk.csv")`, then `x`. A CSV is a rectangular table; a column has one defined meaning. Probabilities are fractions 0–1; multiply by 100 only for percentages. [Column definitions](M11_COLUMNS.csv) explain every field, and M11_DATA/ retains the checked results.
4. Run `Rscript --vanilla supplement/run_checks.R` for the companion tests. Figure command: `Rscript --vanilla supplement/inst/examples/m11-flag-figure.R`; [figure guide](../figures/m11-flag-to-action/README.md) gives panel/data/provenance details.

## Table-to-question map

| Table | Target and experiment |
|---|---|
| `rarity.csv` | Same nontarget rarity and prevalence, three different target-event laws (sec-m11-rarity). |
| `score_vs_tail.csv` | Exact observed score versus retained tail event; different likelihood ratios and post-test probabilities (sec-m11-rarity). |
| `operating_bridge.csv` | Independent latent/noise CTT example: reliability and target discrimination differ (sec-m11-measurement-bridge). |
| `flag_parameters.csv` | Three independent training samples, uniform probability priors and simultaneous binomial bounds (sec-m11-finite). |
| `flag_risk.csv` | Unknown population Q posterior and confidence image, alongside random-new-positive-person prediction (sec-m11-case-update). |
| `function_fit.csv` | Six supplied observed outcomes, full-rank fixed design and explicit proper normal/IG prior (sec-m11-function). |
| `function_intervals.csv` | Conditional mean versus new outcome, frequentist pivots versus proper-prior posteriors (sec-m11-function). |
| `horizon.csv` | Twelve full censored records; exponential model, Gamma(2,2) shape/rate prior and fixed comparison density (sec-m11-horizon). |
| `known_states.csv` | Supplied joint target/response-process states; indicator independence assumed only in this example (sec-m11-joint-validity). |
| `fitted_states.csv` | Five independent Dirichlet(1,1,1,1) priors updated from composition and four conditional records (sec-m11-fitted-validity). |
| `conditional_counts.csv` | All sixteen observed conditional indicator-cell counts underlying the fitted-state example. |
| `state_readout.csv` | Target and alternative-process predictive probabilities for two separate state experiments. |
| `spectrum.csv` | Known source/target class-specific mixture spectra at fixed prevalence .1 (sec-m11-spectrum). |
| `transport_parameters.csv` | All seven independent binomial records and proper beta updates (sec-m11-fitted-transport). |
| `transport_vertices.csv` | All 128 vertices of simultaneous seven-coordinate confidence rectangle; risk image uses transported mixture laws. |
| `transported_risk.csv` | Integrated new-positive-person risk and the seven-coordinate confidence enclosure; not a full parameter posterior interval. |
| `calibration.csv` | Two equal groups with true risks .1/.9 and constant report .5; Brier/log losses and ranking-preserving squared report (sec-m11-calibration). |
| `imperfect_reference.csv` | Two observationally equivalent label-prevalence models, different true target prevalence (sec-m11-imperfect-target). |
| `missing_verification.csv` | Initial (30,50,20) status counts, two missing-group priors and uniformly retrieved seven targets of ten (sec-m11-missing-target). |
| `actions.csv` | Both cost pairs, case predictive risk and a robust interval criterion based on the simultaneous confidence image (sec-m11-flag-to-action). |
| `evaluation_cells.csv` | Independent complete 100-person evaluation and Dirichlet(1,1,1,1) prior over four outcome/action cells (sec-m11-risk-evaluation). |
| `evaluation_summary.csv` | Population rule loss and net-benefit posterior summaries; bounded-loss confidence radius under a fixed rule. |
| `optimality_counterexample.csv` | Posterior probability an action is parameterwise optimal differs from posterior expected-loss choice (sec-m11-decision-uncertainty). |
| `branches.csv` | Known .8/.1 next-test kernel conditional on the current .3 record; first-result probabilities and two-step actions. |
| `policy_values.csv` | Backward induction with at most 0/1/2 further tests, each costing .1 (sec-m11-sequential-decision). |
| `terminal_paths.csv` | Complete optimal two-test policy paths, conditional on one fixed target draw; stop after first positive. |
| `value_summary.csv` | Known-kernel information and stopping results; exact enumeration under costs(1,4) (sec-m11-information-example). |
| `uncertain_repeated_test.csv` | Ordered same-person Bernoulli paths integrating Beta(1,1) sensitivity; f=.1 and q=.3 (sec-m11-uncertain-information). |

## Follow the reasoning

The flag has three data sources:16/20 positive among verified targets,4/40 among verified nontargets and 10/100 targets in a separate representative referral sample. Independent uniform priors on sensitivity, false-positive probability and prevalence give beta posteriors(17,5),(5,37),(11,91). `flag_risk` averages the risk function over all three to obtain its population-parameter distribution. A new randomly drawn person whose flag is positive instead contributes the flag-event likelihood; integrate the target/event joint mass and total event mass before dividing. The resulting 51/116 is a different target from the parameter mean or its chance of exceeding.5. `plugin` supplies the explicitly different observed-proportion comparison 8/17.

The function example predicts from an observed predictor, not latent error-free ability. Mean and new-outcome intervals differ because a new outcome adds residual noise. The time example retains all twelve censored/event records; its random exposure is not a fixed Poisson window. Its full-time confidence set uses a normalized comparison density fixed before data; the gamma posterior is a different inferential operation even though both use the same teaching Gamma(2,2).

The fitted validity example estimates five independent simplexes, not independent indicators within a state. Known-law and fitted-state records are separate experiments. Transport updates all seven quantities, retaining target-site spectra as well as prevalence; its confidence enclosure evaluates every 128 vertex. The new-case transport prediction can use products of posterior means only because the independent factorization is explicit here.

Missing verification leaves the initially unverified target fraction unidentified. Two prior rows change an assumption, not the observed likelihood. Uniformly retrieving ten of those records with seven targets contributes actual binomial evidence, updating the missing-group beta while retaining the initial-status Dirichlet. Population prevalence and a new known-missing person's risk are different columns. No completed fixed-cohort probability is substituted for either.

Costs(1,4) and(4,1) can reverse actions at the same case probability. `evaluation_summary` averages over a separate 100-person evaluation, rather than the flagged-case data. Net benefit expresses loss reduction for declared preferences; the chapter's causal counterexample still prevents interpreting prognosis as intervention benefit. `policy_values` minimizes future test cost plus terminal loss by backward induction. `terminal_paths` retains the complete stopping experiment, allowing sensitivity, false-positive probability and expected test count to be recomputed without pretending that everyone took two tests.

## Numerical scope

Outputs are deterministic. Beta-weighted Gauss–Jacobi quadrature uses 64 nodes per probability coordinate; tests compare 48/96, beta moments and separate analytic/integral representations. Credible endpoints use the exact defining risk CDF followed by numerical root solving. Confidence intervals are conservative finite-experiment constructions; numerical evaluation is not an extra coverage guarantee. Tail probabilities and CDFs use base R; pointwise printed decimals allow absolute 5 e-7 at six digits. Analytic and cross-language checks use their tighter explicit tolerances.

The companion implements selected examples across the chapter. It does not advertise a general clinical decision package, arbitrary joint-model fitter, full five-simplex or seven-coordinate parameter-risk posterior intervals, general imperfect-label posterior inference, unrestricted competing-risk fitting, causal treatment identification or a general unknown-kernel sequential optimizer. Those are manuscript definitions or further implementations requiring their actual designs and priors. No simulation or successful numerical check proves a theorem or validates a clinical model.
