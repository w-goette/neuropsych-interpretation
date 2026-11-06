testthat::test_that("finite moments and heavy-tail probabilities have independent benchmarks", {
  m <- m10_moments(); testthat::expect_equal(m$formula, m$enumeration, tolerance = 1e-11)
  for (nu in c(3, 5, 10, 30)) {
    p <- stats::integrate(function(t) stats::pchisq(stats::qchisq(.95, 5) * nu * t / (nu - 2), 5, lower.tail = FALSE) * stats::dgamma(t, nu / 2, rate = nu / 2), 0, Inf, rel.tol = 1e-11)$value
    testthat::expect_equal(m10_student_rate(nu), p, tolerance = 1e-10)
  }
  testthat::expect_gt(m10_student_rate(5), m10_student_rate(3))
  testthat::expect_equal(m10_student_rate(1e8), .05, tolerance = 1e-7)
  testthat::expect_error(m10_student_rate(2)); testthat::expect_error(m10_plugin_rate(5)); testthat::expect_error(m10_student_rate(5, alpha = 1))
  x <- m10_conditional_student(); testthat::expect_equal(x$scale_squared, c(.875, .375), tolerance = 1e-12)
  # Direct bivariate Student density divided by the actual marginal density.
  Omega <- .6 * matrix(c(1, .5, .5, 1), 2); inv <- solve(Omega)
  joint <- function(z, b) {
    q <- inv[1, 1] * z^2 + 2 * inv[1, 2] * z * b + inv[2, 2] * b^2
    exp(lgamma(3.5) - lgamma(2.5)) / (5 * pi * sqrt(det(Omega))) * (1 + q / 5)^(-3.5)
  }
  for (i in 1:2) {
    b <- x$companion_score[i]; direct <- stats::integrate(function(z) joint(z, b), -Inf, -2, rel.tol = 1e-11)$value / (stats::dt(b / sqrt(.6), 5) / sqrt(.6))
    testthat::expect_equal(direct, x$lower_tail_at_minus2[i], tolerance = 1e-10)
  }
})
testthat::test_that("mixture integration sums uncertain assignments and updates on the case", {
  z <- c(-2.5, -1.8, -.7, 0, .4, 1); bits <- as.matrix(expand.grid(rep(list(0:1), 6))); k <- rowSums(bits)
  likelihood <- apply(bits, 1, function(g) prod(ifelse(g == 1, stats::dnorm(z + 2), stats::dnorm(z))))
  mass <- likelihood * exp(lbeta(k + 1, 7 - k)); mass <- mass / sum(mass)
  mean <- sum(mass * (k + 1) / 8); x <- m10_weight()
  testthat::expect_equal(x$weight_mean, mean, tolerance = 1e-10)
  testthat::expect_equal(x$correct_membership, mean * stats::dnorm(.5) / ((1 - mean) * stats::dnorm(-1.5) + mean * stats::dnorm(.5)), tolerance = 1e-12)
  testthat::expect_gt(x$correct_membership, x$reference_only_average)
  testthat::expect_equal(m10_mixture()$case_component2, .749451, tolerance = 5e-7)
  testthat::expect_error(m10_weight(numeric()))
})
testthat::test_that("personal variance, observed low events and finite Gaussian prediction retain their targets", {
  x <- m10_person_scale(); testthat::expect_equal(x$posterior_mean, 9 / 11, tolerance = 1e-13)
  testthat::expect_equal(stats::pchisq(6 / x$confidence_lower, 8) - stats::pchisq(6 / x$confidence_upper, 8), .95, tolerance = 1e-12)
  testthat::expect_equal(x$population_squared_dispersion_correlation, 4 / 7)
  testthat::expect_true(is.na(m10_person_scale(nu = 3)$population_squared_dispersion_correlation))
  testthat::expect_error(m10_person_scale(p = 1)); testthat::expect_error(m10_person_scale(energy = -1))
  for (rho in c(0, .5)) {
    a <- m10_copula(rho = rho); testthat::expect_equal(a$gaussian_any + a$gaussian_both, .1)
    testthat::expect_equal(a$student_any + a$student_both, .1); testthat::expect_gt(a$student_both, a$gaussian_both)
  }
  # Independent normals mixed over a common Gamma precision at rho=0.
  threshold <- stats::qt(.05, 4)
  direct <- stats::integrate(function(t) stats::pnorm(threshold * sqrt(t))^2 * stats::dgamma(t, 2, rate = 2), 0, Inf, rel.tol = 1e-11)$value
  testthat::expect_equal(m10_copula()$student_both, direct, tolerance = 1e-10)
  testthat::expect_error(m10_copula(rho = 1))
  cell <- m10_cells(); testthat::expect_equal(cell$posterior_mean, 9 / 104)
  testthat::expect_equal(m10_cp(0, 0), c(lower = 0, upper = 1)); testthat::expect_error(m10_cp(4, 3))
  for (p in c(.01, .05, .2, .5, .95)) {
    ci <- vapply(0:10, function(k) m10_cp(k, 10), numeric(2)); mass <- stats::dbinom(0:10, 10, p)
    testthat::expect_gte(sum(mass[ci[1, ] <= p & p <= ci[2, ]]) + 1e-12, .95)
  }
  finite <- m10_covariance(); testthat::expect_equal(finite$finite_F_cutoff, 33.8052268177, tolerance = 1e-10)
  testthat::expect_equal(finite$exact_plugin_rate, .3620337848218, tolerance = 1e-12)
  testthat::expect_equal(finite$predictive_radial_tail, .63752639855, tolerance = 1e-10)
  # Normal--inverse-gamma scalar prediction independently integrates the variance.
  Psi <- finite$predictive_first_scale * 13 * 16 / 14
  direct <- stats::integrate(function(v) stats::pnorm((-1.5 + 12 * .4 / 13) / sqrt(v * 14 / 13)) * stats::dgamma(1 / v, 8, rate = Psi / 2) / v^2, 0, Inf, rel.tol = 1e-10)$value
  testthat::expect_equal(direct, finite$predictive_first_lower_tail, tolerance = 1e-9)
})
testthat::test_that("bounds and contamination integrations have boundary and refinement checks", {
  x <- m10_sensitivity(); testthat::expect_equal(x$radius_lower, 2.9^2 / 1.2)
  testthat::expect_equal(x$radius_upper, 3.1^2 / .8); testthat::expect_equal(m10_sensitivity(9, 0, 0)$radius_lower, 9)
  testthat::expect_error(m10_sensitivity(eta = 1)); testthat::expect_error(m10_uniform_rule(1))
  rule <- m10_uniform_rule(12)
  for (j in 0:12) testthat::expect_equal(sum(rule$weight * rule$node^j), 1 / (j + 1), tolerance = 1e-12)
  for (e in list(0, .05, "uniform")) {
    a <- m10_contamination(e, 60); b <- m10_contamination(e, 80)
    testthat::expect_equal(a$posterior_mean, b$posterior_mean, tolerance = 1e-10)
    testthat::expect_equal(a$posterior_lower, b$posterior_lower, tolerance = 1e-9)
    testthat::expect_equal(a$posterior_upper, b$posterior_upper, tolerance = 1e-9)
  }
  a <- m10_contamination(0); testthat::expect_equal(a$posterior_mean, 9 / 102, tolerance = 1e-12)
  testthat::expect_equal(c(a$posterior_lower, a$posterior_upper), stats::qbeta(c(.025, .975), 9, 93), tolerance = 1e-10)
  # Independent incomplete-beta integral for fixed contamination fraction.
  marginal <- function(q) (stats::pbeta(.95 * q + .05, 9, 93) - stats::pbeta(.95 * q, 9, 93)) / .05
  direct <- stats::integrate(function(q) q * marginal(q), 0, 1, rel.tol = 1e-11)$value / stats::integrate(marginal, 0, 1, rel.tol = 1e-11)$value
  testthat::expect_equal(m10_contamination(.05)$posterior_mean, direct, tolerance = 1e-10)
})
testthat::test_that("learned procedures repeat folds, retain raw-scale likelihoods and saturating transforms", {
  input <- function(name) as.matrix(readr::read_csv(testthat::test_path("..", "..", "inst/examples/M10_INPUTS", name), show_col_types = FALSE))
  x <- input("learned-reference.csv"); fit <- m10_fit(x)
  testthat::expect_equal(c(fit$nu, fit$lambda), c(10, .4))
  g <- m10_grid(x); testthat::expect_equal(sum(g$weight), 1, tolerance = 1e-13)
  testthat::expect_lt(abs(sum(g$weight * g$event_probability) - .0431971), 5e-8)
  # In one dimension the multivariate t log-density reduces to R's scalar density.
  testthat::expect_equal(m10_log_density(matrix(c(-2, 0, 1), ncol = 1), .3, matrix(2, 1), 5), stats::dt((c(-2, 0, 1) - .3) / sqrt(1.2), 5, log = TRUE) - log(sqrt(1.2)), tolerance = 1e-12)
  train <- input("rank-training.csv"); cal <- input("rank-calibration.csv"); fit <- m10_fit(train, TRUE)
  testthat::expect_equal(fit$lambda, .1); cs <- m10_score(cal, fit)
  testthat::expect_equal(sort(cs)[95], 15.81545889122452, tolerance = 1e-10)
  low <- fit$transform(matrix(-1e6, 1, 5), train); lower <- fit$transform(matrix(-1e9, 1, 5), train)
  testthat::expect_equal(low, lower); testthat::expect_true(all(is.finite(low)))
  constant <- m10_fit(matrix(1, 4, 2), TRUE); testthat::expect_true(all(eigen(constant$covariance)$values > 0))
  testthat::expect_error(m10_fit(matrix(1, 2, 2)))
})
testthat::test_that("inclusive calibration is valid for finite tied populations and infinite ranks", {
  for (m in c(1, 3, 5)) for (alpha in c(.05, .25, .5)) {
    words <- as.matrix(expand.grid(rep(list(0:1), m + 1))); prob <- apply(words, 1, function(x) prod(ifelse(x, .2, .8)))
    ans <- lapply(seq_len(nrow(words)), function(i) m10_conformal(words[i, 1:m], words[i, m + 1], alpha))
    testthat::expect_gte(sum(prob * vapply(ans, function(x) x$included, logical(1))) + 1e-12, 1 - alpha)
    for (a in c(.1, .25, .5)) testthat::expect_lte(sum(prob[vapply(ans, function(x) x$calibrated_tail, numeric(1)) <= a]), a + 1e-12)
  }
  testthat::expect_true(m10_conformal(numeric(), 7)$included); testthat::expect_equal(m10_conformal(c(1, 1, 1), 1, .5)$calibrated_tail, 1)
  testthat::expect_error(m10_conformal(c(1, NA), 0)); testthat::expect_error(m10_conformal(1, 2, 0))
  x <- m10_calibration_laws(); testthat::expect_equal(x$tolerance_rank_m99, 98)
  testthat::expect_lt(stats::pbinom(96, 99, .95), .95)
  testthat::expect_equal(stats::pbeta(.95, 19, 1), x$realized_content_below95_m19)
})
