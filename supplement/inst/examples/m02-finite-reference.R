# Reproduce M02's synthetic finite-reference comparisons. No random draws.
# Run from any directory by supplying the correct path to this script.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- sub("^--file=", "", argument[[1]])
if (!file.exists(script_path)) script_path <- gsub("~+~", " ", script_path, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script_path, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R", "m02-finite-reference.R"))
output <- file.path(supplement_root, "outputs", "m02-reference")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
write_table <- function(data, name) readr::write_csv(data, file.path(output, paste0(name, ".csv")))

# 1. Build the same20 numbers used by the chapter, then calculate their summaries.
reference_scores <- 50 + as.vector(outer(c(-1, 1), 1:10)) * sqrt(190 / 77)
write_table(tibble::tibble(person = seq_along(reference_scores), score = reference_scores), "reference-scores")
reference <- m02_posterior(length(reference_scores), mean(reference_scores), stats::sd(reference_scores))
proper <- m02_posterior(20, 50, 10, list(m = 50, kappa = 5, a = 3, b = 200))
posts <- list(reference = reference, proper = proper)

# 2. Prediction includes another person's residual variation. Percentile intervals
# instead describe uncertainty about the population fraction below fixed score35.
prediction_row <- function(post, name, y0, model = "scalar") {
  value <- m02_predict(post, y0)
  tibble::tibble(model = model, prior = name, y0 = y0, location = value$mean_location,
    scale = value$scale, df = value$df, lower_tail = value$lower_tail,
    two_sided = 2 * min(value$lower_tail, 1 - value$lower_tail),
    lower = value$interval[[1]], upper = value$interval[[2]])
}
percentile_row <- function(post, name, y0, model = "scalar") {
  bounds <- m02_percentile(post, y0)
  tibble::tibble(model = model, prior = name, y0 = y0,
    plugin = if (name == "reference") pnorm((y0 - post$m) / sqrt(post$b / post$a)) else NA_real_,
    posterior_mean = m02_predict(post, y0)$lower_tail,
    lower = bounds[[1]], median = bounds[[2]], upper = bounds[[3]])
}
write_table(dplyr::bind_rows(lapply(names(posts), function(name) prediction_row(posts[[name]], name, 35))), "scalar-prediction")
write_table(dplyr::bind_rows(lapply(names(posts), function(name) percentile_row(posts[[name]], name, 35))), "scalar-percentile")

# 3. Fit the fixed design with an intercept and centered predictor. This is
# another constructed experiment, not a subset of the20-person example.
cp <- c(-5,-4,-3,-2,-1,1,2,3,4,5)
X <- cbind(intercept = 1, predictor = cp)
y <- 50 + 2 * cp + sqrt(50 / 187) * (cp^2 - 11)
write_table(tibble::tibble(person = seq_along(y), predictor = cp, score = y), "regression-scores")
reg <- m02_regression(X, y, c(1,3))
reg_proper <- m02_regression(X, y, c(1,3), list(m = c(48,1), K = diag(c(2,10)), a = 3, b = 50))
regs <- list(reference = reg, proper = reg_proper)
write_table(dplyr::bind_rows(lapply(names(regs), function(name) prediction_row(regs[[name]], name, 45, "regression"))), "regression-prediction")
write_table(dplyr::bind_rows(lapply(names(regs), function(name) percentile_row(regs[[name]], name, 45, "regression"))), "regression-percentile")
write_table(dplyr::bind_rows(lapply(names(regs), function(name) {
  post <- regs[[name]]
  tibble::tibble(prior = name, intercept = post$coefficients[[1]], slope = post$coefficients[[2]],
    target_mean = post$m, variance_multiplier = post$h, shape = post$a, rate = post$b)
})), "regression-posterior-inputs")

# 4. Fitting a rule changes its actual population content across norm studies.
# Compare controlling the95th content percentile with controlling its mean.
zeta <- m02_cutoffs()
write_table(tibble::tibble(rule = names(zeta), coefficient = as.numeric(zeta),
  realized_cutoff = 50 + 10 * zeta), "cutoff-coefficients")
content_rows <- lapply(names(zeta), function(rule) {
  coefficient <- zeta[[rule]]; cutoff <- 50 + 10 * coefficient
  dplyr::bind_rows(lapply(names(posts), function(name) {
    post <- posts[[name]]
    bounds <- m02_percentile(post, cutoff, c(.025,.5,.975,.95))
    tibble::tibble(rule = rule, prior = name, sampling_law_matches = name == "reference",
      mean = m02_predict(post, cutoff)$lower_tail, median = bounds[[2]],
      lower = bounds[[1]], upper = bounds[[3]], q95 = bounds[[4]],
      probability_content_at_most_05 = m02_percentile_cdf(post, cutoff, .05))
  }))
})
write_table(dplyr::bind_rows(content_rows), "cutoff-content")

# 5. A population quantile and population SD are score-valued parameters.
write_table(dplyr::bind_rows(lapply(names(posts), function(name) {
  post <- posts[[name]]; bounds <- m02_quantile(post); one <- m02_quantile(post, levels = c(.05,.95))
  tibble::tibble(prior = name, level = .05, plugin = if(name=="reference") 50+10*qnorm(.05) else NA_real_,
    posterior_mean = post$m + qnorm(.05) * m02_sd_moment(post),
    lower = bounds[[1]], median = bounds[[2]], upper = bounds[[3]],
    lower_one95 = one[[1]], upper_one95 = one[[2]])
})), "quantile-parameter")
write_table(dplyr::bind_rows(lapply(names(posts), function(name) {
  post <- posts[[name]]; bounds <- m02_scale(post); one <- m02_scale(post,c(.05,.95))
  tibble::tibble(prior = name, mean = m02_sd_moment(post),
    posterior_sd = sqrt(m02_sd_moment(post,2)-m02_sd_moment(post)^2),
    lower = bounds[[1]], median = bounds[[2]], upper = bounds[[3]],
    lower_one95 = one[[1]], upper_one95 = one[[2]],
    variance_lower = bounds[[1]]^2, variance_upper = bounds[[3]]^2)
})), "population-sd")

# 6. Repeat the opening calculations at n=20 and2000, holding summaries fixed.
write_table(dplyr::bind_rows(lapply(c(20,2000),function(n) {
  post <- m02_posterior(n,50,10);pred <- m02_predict(post,35);pr <- m02_percentile(post,35,c(.025,.975))
  tibble::tibble(n=n, predictive_tail=pred$lower_tail,prediction_lower=pred$interval[[1]],
    prediction_upper=pred$interval[[2]],percentile_lower=pr[[1]],percentile_upper=pr[[2]])
})), "two-clinics")
writeLines(c(
  "M02 synthetic normal-reference calculations; no RNG or empirical patient data.",
  "Reference scores exactly50 +/- j*sqrt(190/77),j=1,...,10. Case score35.",
  "Proper scalar prior m50,kappa5,a3,b200. Regression design, outcomes and prior match M02.",
  "Source equations: normal predictive pivot; percentile noncentrality inversion; regression projection/posterior; fitted-content law; quantile parameter and scale posterior laws.",
  "Reference/prior labels preserve different conditioning. sampling_law_matches applies only to equivariant fitted content under the stipulated reference prior.",
  "Exact representations are evaluated by numerical quadrature/root finding; finite upper mixing tail1e-13, absolute integrate tolerance2e-11; bounded CDF-tail truncation <=1e-13.",
  "No accuracy guarantee for arbitrarily extreme floating-point tails or untested inputs. Inspect defining integrals and inversion residuals.",
  "No clinical validation, sample-size recommendation, same-patient retest model or diagnostic rule."
),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote M02 numerical tables to",output,"\n")
