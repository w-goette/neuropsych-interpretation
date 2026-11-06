# Run: Rscript --vanilla supplement/inst/examples/m07-norms.R
# Locate the source companion relative to this script.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R/m07-norms.R"))
output <- file.path(supplement_root, "outputs/m07-norms")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
write_table <- function(data, name) readr::write_csv(data, file.path(output, paste0(name, ".csv")))
# 1. Hold the performance fixed; change only its declared peer population.
write_table(m07_references(), "references")
ties <- m07_ties(); write_table(ties, "ties")
rank_check <- dplyr::bind_rows(lapply(0:1, function(g) {
  p <- ties$mass[ties$group == g]; before <- c(0, head(cumsum(p), -1)); grid <- seq(0, 1, .1)
  tibble::tibble(group = g, threshold = grid, achieved_probability = vapply(grid, function(t) sum(pmin(p, pmax(0, t - before))), numeric(1)))
}))
write_table(rank_check, "randomized-ranks")
# 2. Same observed anchor contrast; different variance/offset assumptions.
write_table(m07_anchor_known(), "anchor-known")
write_table(dplyr::bind_rows(lapply(0:2, function(Gamma) m07_anchor(Gamma = Gamma))), "anchor-offsets")
# 3. Selected-only records and complete screening counts are different experiments.
selected <- m07_selection(); write_table(selected$fitted, "selected-fit"); write_table(selected$band, "selected-band")
write_table(dplyr::bind_rows(lapply(c(1, .5), m07_selection_posterior)), "selected-posterior")
write_table(dplyr::bind_rows(lapply(1:3, function(a) m07_screening(a, 4 - a))), "screening-posterior")
write_table(m07_screen_correlation(), "screening-correlation")
# 4. Margins alone leave an entire family of paired probabilities.
t <- seq(.25, .5, .0625)
write_table(tibble::tibble(t = t, J00 = t - .25, J01 = .75 - t, J10 = .5 - t, J11 = t,
  success_after_source0 = 1.5 - 2 * t, success_after_source1 = 2 * t), "couplings")
a <- c(1, 1, 3, 19); b <- c(1, 3, 1, 1)
write_table(tibble::tibble(prior_a = a, prior_b = b, success_after_source0 = 1 - a / (2 * (a + b)),
  success_after_source1 = .5 * (1 + a / (a + b))), "coupling-priors")
write_table(m07_paired(), "paired-calibration")
write_table(tibble::tibble(source_slope = c(1, 1.5), source_difficulty = c(-1, 1),
  target_slope = c(.5, .75), target_difficulty = c(8, 12), link_intercept = 10, link_slope = 2), "affine-anchors")
# 5. Reference-only fitting: fixed case is never added to the norm likelihood.
write_table(m07_regression(), "regression-percentile")
write_table(dplyr::bind_rows(lapply(0:1, function(g) {
  count <- if (g == 0) c(8, 16, 4, 12) else c(12, 4, 16, 8)
  tibble::tibble(group = g, score = 0:3, count = count, observed_proportion = count / 40)
})), "shape-counts")
write_table(m07_shape_bands(), "shape-bands")
shape <- dplyr::bind_rows(lapply(c(1, .5), function(prior) dplyr::bind_rows(lapply(c(96, 192), function(nodes) m07_shape_posterior(prior, nodes)))))
write_table(shape, "shape-posterior")
write_table(m07_shape_functionals(), "shape-functionals")
write_table(dplyr::bind_rows(lapply(c(6, 20, 100), function(n) {
  p <- c(.01, .05, .1, .5, .9, .95, .99)
  tibble::tibble(reference_n = n, fitted_rank_threshold = p,
    repeated_reference_probability = stats::pt(stats::qnorm(p) / sqrt(1 + 1 / n), n - 1))
})), "fitted-rank-calibration")
# 6. A known source, an uncertain source and a future response are distinct targets.
write_table(m07_link(), "known-source-link")
# Construct ONE dataset with exactly the manuscript's sufficient summaries.
# No unobserved true H is supplied, and this is not a recovered historical dataset.
n <- 24; M <- as.numeric(scale(seq_len(n))) * sqrt(1.25); D <- (-1)^seq_len(n) * sqrt(.3)
residual <- qr.resid(qr(cbind(1, M)), sin(seq_len(n))); residual <- residual * sqrt(11 / sum(residual^2))
Z <- 10 + 1.1 * M + residual
write_table(tibble::tibble(person = seq_len(n), source1 = M + D / sqrt(2), source2 = M - D / sqrt(2), target = Z), "noisy-calibration-readings")
write_table(dplyr::bind_rows(lapply(c(FALSE, TRUE), function(case) m07_noisy_confidence(include_case_uncertainty = case))), "noisy-confidence")
prediction <- m07_noisy_confidence(.025, TRUE)
prediction$prediction_lower <- prediction$lower - stats::qnorm(1 - .025 / 2) * sqrt(prediction$q_upper)
prediction$prediction_upper <- prediction$upper + stats::qnorm(1 - .025 / 2) * sqrt(prediction$q_upper)
write_table(prediction, "noisy-future-confidence")
# Smooth normal-mixture integrands avoid drawing a person's latent coordinate.
# Four shifted Halton dimensions integrate t,q,s,b; a and mu integrate analytically.
cat("Integrating baseline repeated-source posterior\n")
base <- m07_noisy(); alternative <- m07_noisy(source_error_scale = 1.8)
calibration_only <- m07_noisy(case_update = FALSE)
write_table(dplyr::bind_rows(base, alternative, calibration_only), "noisy-posterior")
cat("Checking independent deterministic shifts and point counts\n")
write_table(dplyr::bind_rows(m07_noisy(65536), base, m07_noisy(262144, 2)), "noisy-refinement")
write_table(tibble::tibble(v = c(1, .8), s = c(.5, .7), B = c(1.1, 1.375), tau = c(1, .6975)) |>
  dplyr::mutate(single_source_variance = v + s, target_variance = B^2 * v + tau, covariance = B * v), "one-source-nonidentification")
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
writeLines(c("All inputs are synthetic chapter defaults, not patient records. Priors and conditioning are declared in M07_GUIDE.md.",
  "Exact finite laws, adaptive scalar quadrature, finite Gauss-Legendre quadrature and deterministic shifted-Halton integration are separately identified.",
  "No random generator or seed is used. Two fixed shifts and point-count refinement are diagnostics, not a rigorous integration-error bound.",
  "Noisy calibration readings are constructed teaching observations matching the stated sufficient summaries.",
  "Entry point uses the source-based companion setup."), file.path(output, "PROVENANCE.txt"))
cat("M07 synthetic CSV tables written to", output, "\n")
