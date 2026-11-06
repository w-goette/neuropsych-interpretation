# Run Rscript --vanilla supplement/inst/examples/m08-change.R.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R/m06-items.R"))
source(file.path(supplement_root, "R/m08-change.R"))
output <- file.path(supplement_root, "outputs/m08-change")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
write_table <- function(x, name) readr::write_csv(x, file.path(output, paste0(name, ".csv")))
# 1. Start with observed performances under the declared SAME-PERSON law.
write_table(m08_joint(c(20, 35, 50)), "joint-comparisons")
# 2. Fit all regression coefficients and residual variance from six records.
x <- cbind(1, c(-1, -1, 0, 0, 1, 1)); y <- c(38, 42, 49, 47, 54, 58)
fit <- m08_regression(x, y, c(48, 8), diag(c(100, 25)), 3, 9)
write_table(fit$coefficient_table, "scalar-reference-coefficients")
write_table(m08_prediction(fit, c(1, -1.5)), "scalar-retest-prediction")
# Add the case and a distinct offset coefficient; refit the whole proper model.
stacked <- rbind(cbind(x, 0), c(1, -1.5, 1))
offset <- m08_regression(stacked, c(y, 32), c(48, 8, 0), diag(c(100, 25, 4)), 3, 9)
write_table(offset$coefficient_table, "scalar-offset-joint-update")
# 3. Fitting repeated-reference covariance retains the direction-wise uncertainty.
records <- readr::read_csv(file.path(supplement_root, "inst/examples/M08_INPUTS/state-records.csv"), show_col_types = FALSE)
y_state <- as.matrix(records[, -1])
write_table(dplyr::bind_rows(lapply(3:4, function(t) m08_state_confidence(y_state[, seq_len(t)]))), "state-finite-confidence")
write_table(tibble::as_tibble(stats::cov(y_state), .name_repair = ~paste0("visit", seq_along(.x))), "state-sample-covariance")
# A population covariance with only three lags has an entire equivalent family.
rho <- c(.25, .5, 11 / 14)
a <- 1.5 / (rho * (1 - rho)); k <- 7 - a * rho; e <- 13 - k - a
write_table(tibble::tibble(rho = rho, stable_total = k, state_variance = a, noise_variance = e,
  lag1 = k + a * rho, lag2 = k + a * rho^2, lag3 = k + a * rho^3), "serial-equivalence-family")
# 4. Latent Gaussian change and a NEW noisy contrast are different targets.
g <- m08_normal_update(diag(2), c(50, 42), diag(9, 2), c(50, 50), matrix(c(25, 20, 20, 25), 2))
contrast <- c(-1, 1); mean <- sum(contrast * g$mean); variance <- drop(crossprod(contrast, g$covariance %*% contrast))
write_table(tibble::tibble(mean_change = mean, variance_change = variance,
  decline_probability = stats::pnorm(-mean / sqrt(variance)),
  new_difference_variance = variance + 18,
  negative_new_difference_probability = stats::pnorm(-mean / sqrt(variance + 18))), "gaussian-latent-change")
write_table(dplyr::bind_rows(lapply(list(c(3, 1), c(4, 0), c(0, 0), c(4, 4)), function(s) {
  dplyr::mutate(m08_conditional_items(s[1], s[2]), first = s[1], second = s[2])
})), "conditional-item-confidence")
rectangle <- rbind(m08_binomial_interval(3, 4, .025), m08_binomial_interval(1, 4, .025))
write_table(tibble::tibble(occasion = 1:2, lower = stats::qlogis(rectangle[, 1]), upper = stats::qlogis(rectangle[, 2])), "item-coordinate-confidence")
item_rows <- list()
for (order in c(128L, 256L)) for (prior in list(c(1, .5), c(2, .5), c(1, 0))) {
  item_rows[[length(item_rows) + 1L]] <- m08_item_posterior(prior[1], prior[2], order)
}
write_table(dplyr::bind_rows(item_rows), "known-item-posterior-refinement")
# 5. Fit the PERSONAL noise scale separately from any reference variance.
time <- 0:5; personal <- c(51, 47, 46, 44, 41, 41); design <- cbind(1, time - 2.5)
slopes <- list()
for (model in c("independent", "AR05", "strong-slope-prior")) {
  correlation <- if (model == "AR05") .5^abs(outer(time, time, "-")) else diag(6)
  slope_factor <- if (model == "strong-slope-prior") .5 else 4
  f <- m08_regression(design, personal, c(45, 0), diag(c(25, slope_factor)), 3, 2, correlation)
  slopes[[model]] <- dplyr::mutate(f$coefficient_table[2, ], model = model,
    residual_quadratic = f$residual_quadratic, mean_variance = f$scale / (f$shape - 1))
}
write_table(dplyr::bind_rows(slopes), "personal-slope-sensitivity")
# External curvature is not learned from the same two endpoint readings.
endpoint <- m08_normal_update(diag(2), c(50, 48), diag(4, 2), c(50, 50), matrix(c(25, 20, 20, 25), 2))
midmean <- mean(endpoint$mean); midvar <- sum(endpoint$covariance) / 4
curve <- lapply(c(0, 4, 8), function(bound) {
  radius <- bound / 8
  cdf <- function(z) if (radius == 0) stats::pnorm(z, midmean, sqrt(midvar)) else
    stats::integrate(function(u) stats::pnorm(z - u, midmean, sqrt(midvar)), -radius, radius, rel.tol = 1e-10)$value / (2 * radius)
  tibble::tibble(curvature_bound = bound, posterior_mean_midpoint = midmean,
    confidence_lower = 49 - stats::qnorm(.975) * sqrt(2) - radius,
    confidence_upper = 49 + stats::qnorm(.975) * sqrt(2) + radius,
    credible_lower = stats::uniroot(function(z) cdf(z) - .025, c(30, 70), tol = 1e-9)$root,
    credible_upper = stats::uniroot(function(z) cdf(z) - .975, c(30, 70), tol = 1e-9)$root)
})
write_table(dplyr::bind_rows(curve), "curvature-sensitivity")
# 6. Proxy assumptions change what historical change is identified.
proxy <- m08_normal_update(rbind(c(1, 0), c(1, 1)), c(55, 40), diag(c(16, 9)), c(50, 0), diag(c(100, 25)))
write_table(tibble::tibble(target = c("premorbid", "change"), posterior_mean = proxy$mean,
  posterior_variance = diag(proxy$covariance)), "proxy-independent-prior")
write_table(tibble::tibble(bias_sd = c(0, 6), mean_change = proxy$mean[2],
  variance_change = proxy$covariance[2, 2] + c(0, 36),
  lower = proxy$mean[2] - stats::qnorm(.975) * sqrt(proxy$covariance[2, 2] + c(0, 36)),
  upper = proxy$mean[2] + stats::qnorm(.975) * sqrt(proxy$covariance[2, 2] + c(0, 36))), "proxy-operational-bias-prior")
# Trial marginals identify an average, not individual counterfactual pairings.
write_table(m08_beta_difference(c(4, 10), c(8, 6)), "randomized-average-effect")
benefit <- list()
for (order in c(160L, 320L)) for (prior in list(c(1, 1), c(8, 2), c(2, 8))) {
  benefit[[length(benefit) + 1L]] <- m08_benefit(prior, order)
}
write_table(dplyr::bind_rows(benefit), "unlearned-coupling-refinement")
cp0 <- m08_binomial_interval(3, 12, .025); cp1 <- m08_binomial_interval(7, 12, .025)
write_table(tibble::tibble(average_lower = cp1[1] - cp0[2], average_upper = cp1[2] - cp0[1],
  benefit_set_lower = max(0, cp1[1] - cp0[2]), benefit_set_upper = min(cp1[2], 1 - cp0[1])), "trial-entire-set-confidence")
# Missing-outcome priors have no likelihood update. Means are exact here;
# the full advanced posterior intervals remain in the manuscript archive.
write_table(tibble::tibble(missing_assumption = c("uniform", "treated-low-control-high", "within-arm independence"),
  mean_effect = c(9 / 23 + 9 / 23 * .5 - 6 / 23 - 6 / 23 * .5,
    9 / 23 + 9 / 23 * .2 - 6 / 23 - 6 / 23 * .8, 9 / 14 - 6 / 17)), "noncompletion-exact-means")
low <- function(k) m08_binomial_interval(k, 20, .05 / 4)[1]
write_table(tibble::tibble(plugin_lower = 8 / 20 + 10 / 20 - 1,
  plugin_upper = 1 - 4 / 20 - 5 / 20,
  confidence_lower = low(8) + low(10) - 1,
  confidence_upper = 1 - low(4) - low(5)), "noncompletion-entire-set-confidence")
writeLines(c("Synthetic teaching inputs; no clinical validation.",
  "Deterministic formulas, adaptive quadrature and midpoint probability quadrature are separately documented in M08_GUIDE.md.",
  "Raw state records are the supplied constructed observations in inst/examples/M08_INPUTS/state-records.csv, not posterior results."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
