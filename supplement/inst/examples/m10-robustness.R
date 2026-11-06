# Run from the candidate root: Rscript --vanilla supplement/inst/examples/m10-robustness.R
# All observations are synthetic; read M10_GUIDE.md for targets and limitations.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
source(file.path(supplement_root, "R/m10-robustness.R"))
output <- file.path(supplement_root, "outputs/m10-robustness")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
write_table <- function(x, name) readr::write_csv(x, file.path(output, paste0(name, ".csv")))
read_profiles <- function(name) as.matrix(readr::read_csv(file.path(supplement_root, "inst/examples/M10_INPUTS", name), show_col_types = FALSE))
# 1. Enumerate a finite score law; compare with the moment identities.
write_table(m10_moments(), "quadratic-moments")
nu <- c(3, 5, 10, 30)
write_table(tibble::tibble(nu = nu, exceedance_probability = m10_student_rate(nu)), "student-radial-rates")
write_table(m10_conditional_student(), "conditional-student")
# 2. Components and personal replication scales answer different questions.
write_table(m10_mixture(), "five-score-mixture")
write_table(m10_weight(), "weight-uncertainty")
p <- c(4, 16, 64, 128)
write_table(tibble::tibble(tests = p, squared_dispersion_correlation = (.09 * p)^2 / ((.09 * p + .55)^2 + (p - 2) * .55^2)), "gaussian-replication")
write_table(m10_person_scale(), "personal-scale")
# 3. Joint low events need dependence and the correct observation resolution.
write_table(dplyr::bind_rows(m10_copula(rho = 0), m10_copula(rho = .5)), "copula-low-events")
write_table(tibble::tibble(cell = c("both", "first_only", "second_only", "neither"), count = c(8L, 12L, 10L, 70L)), "ordinal-cell-counts")
write_table(m10_cells(), "ordinal-both-low")
# 4. Stabilization, prediction, sensitivity and numerical precision are separate.
write_table(m10_covariance(), "finite-reference-and-niw")
write_table(m10_sensitivity(), "sensitivity-bounds")
write_table(dplyr::bind_rows(m10_contamination(0), m10_contamination(.05), m10_contamination("uniform")), "contamination-posterior")
write_table(m10_computation_laws(), "computation-error")
# 5. Refit each training fold, including every fitted transformation.
raw <- read_profiles("learned-reference.csv"); fit <- m10_fit(raw)
write_table(fit$criterion, "learned-density-criterion")
threshold <- (-1.5 - fit$mean[1]) / sqrt(fit$covariance[1, 1])
write_table(tibble::tibble(selected_nu = fit$nu, selected_lambda = fit$lambda,
  fixed_event_estimate = if (is.infinite(fit$nu)) stats::pnorm(threshold) else stats::pt(threshold / sqrt((fit$nu - 2) / fit$nu), fit$nu)), "learned-density-fit")
for (prior in c(.2, .8)) write_table(m10_grid(raw, prior), if (prior == .2) "grid-posterior" else "grid-posterior-gaussian-prior")
# 6. Fix the learned score, then calibrate on entirely separate peers.
training <- read_profiles("rank-training.csv"); calibration <- read_profiles("rank-calibration.csv")
ranked <- m10_fit(training, rank_transform = TRUE)
write_table(ranked$criterion, "rank-training-criterion")
write_table(tibble::tibble(profile = seq_len(nrow(calibration)), score = m10_score(calibration, ranked)), "calibration-scores")
write_table(dplyr::mutate(m10_conformal(m10_score(calibration, ranked), m10_score(matrix(0, 1, 5), ranked)), selected_lambda = ranked$lambda), "rank-calibration-rule")
write_table(m10_calibration_laws(), "calibration-content-laws")
# Record the actual host and package versions; no fresh restoration is implied.
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote", length(list.files(output, pattern = "[.]csv$")), "synthetic M10 tables to", output, "\n")
