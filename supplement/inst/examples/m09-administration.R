# Run with Rscript --vanilla supplement/inst/examples/m09-administration.R.
# All observations are synthetic. Read M09_GUIDE.md before interpreting a column.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R/m09-administration.R"))
output <- file.path(supplement_root, "outputs/m09-administration")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
write_table <- function(x, name) readr::write_csv(x, file.path(output, paste0(name, ".csv")))
# 1. The same stopping rule selects a different observed-score distribution.
write_table(m09_screening(), "screening-law")
counts <- m09_pattern_counts()
write_table(tibble::tibble(first_category = -1:1, abbreviated = counts[, 1], full = counts[, 2]), "score-pattern-counts")
priors <- list(baseline = matrix(1, 3, 2), stronger = matrix(4, 3, 2), high_abbreviated = matrix(c(1, 1, 8, 1, 1, 1), 3, 2))
patterns <- lapply(priors, function(prior) m09_pattern(prior = prior))
write_table(dplyr::bind_rows(lapply(names(patterns), function(name) dplyr::mutate(patterns[[name]]$summary, prior = name))), "pattern-prior-sensitivity")
write_table(patterns$baseline$mechanism, "mechanism-posterior")
write_table(dplyr::bind_rows(lapply(c(32, 64, 96), function(n) dplyr::mutate(m09_pattern(order = n)$summary, order = n))), "pattern-integration-refinement")
write_table(dplyr::bind_rows(lapply(0:12, function(m) tibble::tibble(observed_count = m, plugin_size = m09_rank_size(m, rank = FALSE), inclusive_rank_size = m09_rank_size(m), count_mass = stats::dbinom(m, 12, .4)))), "new-case-rank-calibration")
# 2. Retain all X/R while fitting only observed second responses.
records <- m09_records(); write_table(records, "observed-mar-records")
fits <- list(baseline = m09_mar_fit(records), stronger_slope = m09_mar_fit(records, V0 = diag(c(100, 1))))
write_table(dplyr::bind_rows(lapply(names(fits), function(name) dplyr::mutate(m09_case(fits[[name]]), prior = name))), "conditional-mean-and-response")
populations <- list()
for (name in names(fits)) for (population in c("full", "abbreviated")) {
  shape <- if (population == "full") c(22, 22, 22) else c(17, 7, 3)
  populations[[paste(name, population)]] <- dplyr::mutate(m09_population(fits[[name]], shape), prior = name, population = population)
}
for (population in c("full", "abbreviated")) {
  shape <- if (population == "full") c(28, 28, 28) else c(20, 10, 6)
  populations[[paste("stronger_cells", population)]] <- dplyr::mutate(m09_population(fits$baseline, shape), prior = "stronger_cells", population = population)
}
write_table(dplyr::bind_rows(populations), "population-composition")
# 3. A nonlinear summary needs the full missing-response distribution.
write_table(dplyr::bind_rows(lapply(names(fits), function(name) dplyr::mutate(m09_profile(fits[[name]]), prior = name)), dplyr::mutate(m09_profile(fits$baseline), prior = "stronger_cells")), "fitted-scatter")
write_table(dplyr::bind_rows(lapply(c(32, 64, 96), function(n) m09_joint_profile(fits$baseline, n))), "shared-missing-responses")
write_table(dplyr::bind_rows(lapply(list(c(0, 0), c(-4, 0), c(4, 0), c(0, 2), c(0, 5)), function(x) m09_profile(fits$baseline, x[1], x[2]))), "mnar-response-departures")
gap <- dplyr::mutate(records, second_score_recorded = ifelse(first_category == -1, 0L, second_score_recorded), second_score = ifelse(first_category == -1, NA_real_, second_score))
write_table(gap, "support-gap-records")
write_table(dplyr::bind_rows(lapply(c(0, 2, 5), function(g) m09_profile(m09_mar_fit(gap), radius = g))), "support-gap-response-sensitivity")
write_table(dplyr::bind_rows(lapply(c(0, 2, 5), function(g) m09_support_mean(m09_mar_fit(gap), g))), "support-gap-mean-sensitivity")
# 4. Sum hidden allocations, and only then normalize the case posterior.
write_table(tibble::tibble(person = 1:3, anchor = c(0, 1, 1), U0 = c(0, 1, 1), UA = c(0, 1, 1), UB = c(0, 0, 1), recommended_item = "B"), "adaptive-reference-records")
actual <- m09_paths()[[3]]
write_table(tibble::tibble(stage = c("first response", "saved choice", "chosen response"), probability_H1 = vapply(c("first", "choice", "response"), function(prefix) m09_adaptive(actual, prefix)$probability_H1, numeric(1))), "adaptive-case-updates")
write_table(dplyr::bind_rows(lapply(list(list(name = "baseline", shape = 1, anchor = c(.1, .9)), list(name = "shapes2", shape = 2, anchor = c(.1, .9)), list(name = "weaker_anchor", shape = 1, anchor = c(.2, .8))), function(x) {
  fit <- m09_adaptive(actual, shape = x$shape, anchor = x$anchor)
  wrong <- m09_adaptive(actual, shape = x$shape, anchor = x$anchor, omit_choice = TRUE)
  score <- m09_adaptive_summary(x$shape, x$anchor)$scores
  tibble::tibble(analysis = x$name, full_path_probability_H1 = fit$probability_H1, wrong_omitted_choice = wrong$probability_H1, only_total1 = score$probability_H1[score$total == 1])
})), "adaptive-sensitivity")
adaptive <- m09_adaptive_summary(); write_table(adaptive$paths, "adaptive-path-law"); write_table(adaptive$scores, "adaptive-total-law"); write_table(adaptive$risks, "adaptive-record-risk")
# 5. First-crossing recursion removes paths after their first rejection.
known <- m09_crossing(); fitted <- (m09_crossing(denominator = 1 / 3)$cumulative_crossing + m09_crossing(denominator = 2 / 3)$cumulative_crossing) / 2
credible <- m09_crossing(credible = TRUE)$cumulative_crossing
write_table(dplyr::mutate(known, smoothed_fitted_null_crossing = fitted, repeated_credible_exclusion = credible), "stopping-crossings")
write_table(dplyr::bind_rows(
  dplyr::mutate(m09_stopped_record(c(rep(1, 9), 0)), record = "nine successes then failure"),
  dplyr::mutate(m09_stopped_record(c(0, rep(1, 9))), record = "failure then nine successes")), "stopped-record-order")

# 6. Time censoring and missing well-defined flags need different likelihoods.
censored <- m09_censoring(); write_table(censored$records, "fixed-censored-records"); write_table(censored$full, "completion-rate"); write_table(censored$matched_priors, "matched-censoring-priors")
missing <- list(baseline = m09_missing_flag(), low_beta = m09_missing_flag(1, 9), high_beta = m09_missing_flag(9, 1), low_range = m09_missing_flag(lo = 0, hi = .2), high_range = m09_missing_flag(lo = .8, hi = 1), independent_recording = m09_missing_flag(linked = TRUE), retrieved4of5 = m09_missing_flag(retrieved = 5, positive = 4))
write_table(dplyr::bind_rows(lapply(names(missing), function(name) dplyr::mutate(missing[[name]], analysis = name))), "missing-flag-sensitivity-and-validation")
write_table(dplyr::bind_rows(m09_missing_set(), m09_missing_set(0, .2), m09_missing_set(.8, 1)), "missing-flag-identified-sets")
write_table(tibble::tibble(missing_flags = 0:10, posterior_probability = 1 / 11, completed_cohort_fraction = (3 + 0:10) / 25), "cohort-completion-law")
writeLines(c("Synthetic inputs; no patient data or clinical scoring.", "Response records are rounded to twelve decimals before fitting.", "Beta/normal/gamma deterministic quadrature; compare refinement output, not a certified error bound.", "Known-null crossing and fitted-null crossing are different repeated experiments.", "Full calibration-clock enumeration and exact 7/10 tie analysis are outside these R examples."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
message("M09 tables saved to ", output)
