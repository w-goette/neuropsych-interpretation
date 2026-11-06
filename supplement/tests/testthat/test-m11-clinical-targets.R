testthat::test_that("M11 finite confidence and beta-weighted integration preserve their targets", {
  testthat::expect_equal(m11_cp(0, 0), c(lower = 0, upper = 1))
  testthat::expect_equal(m11_cp(0, 20)[1], c(lower = 0))
  testthat::expect_equal(m11_cp(20, 20)[2], c(upper = 1))
  testthat::expect_error(m11_cp(21, 20))
  testthat::expect_error(m11_risk(0, 0, .5))
  testthat::expect_equal(m11_risk(.8, .1, c(0, 1)), c(0, 1))
  for (shape in list(c(1, 1), c(.5, .5), c(.2, .8), c(17, 5), c(5, 37), c(11, 91))) {
    rule <- m11_beta_rule(32, shape[1], shape[2]); a <- shape[1]; b <- shape[2]
    testthat::expect_equal(sum(rule$weight), 1, tolerance = 1e-13)
    testthat::expect_equal(sum(rule$weight * rule$node), a / (a + b), tolerance = 1e-13)
    testthat::expect_equal(sum(rule$weight * rule$node^2), a * (a + 1) / ((a + b) * (a + b + 1)), tolerance = 1e-13)
  }
  low <- m11_flag(48)$risk; high <- m11_flag(96)$risk
  testthat::expect_equal(low$parameter_mean, high$parameter_mean, tolerance = 1e-12)
  testthat::expect_equal(low$credible_lower, high$credible_lower, tolerance = 1e-9)
  testthat::expect_equal(low$credible_upper, high$credible_upper, tolerance = 1e-9)
  testthat::expect_equal(high$case_predictive, 51 / 116, tolerance = 1e-14)
  testthat::expect_equal(high$parameter_mean, .453299, tolerance = 5e-7)
  testthat::expect_equal(high$probability_Q_gt_half, .348790, tolerance = 5e-7)
  testthat::expect_gt(abs(high$parameter_mean - high$case_predictive), .01)
})
testthat::test_that("M11 outcome, time and state calculations retain actual experiments", {
  f <- m11_function(); testthat::expect_equal(f$fit$intercept, 10, tolerance = 1e-12)
  testthat::expect_equal(f$fit$slope, 2, tolerance = 1e-12)
  testthat::expect_equal(f$fit$leverage, 19 / 105, tolerance = 1e-14)
  testthat::expect_gt(diff(f$intervals$confidence_or_prediction_upper), 0)
  testthat::expect_lt(abs(f$fit$posterior_predictive_below_ten - .064153), 5e-7)
  # Integrate the actual normal/IG predictive law independently of its t CDF.
  an <- f$fit$posterior_shape; bn <- f$fit$posterior_scale
  Kn <- diag(2) + crossprod(cbind(1, -2:3)); q0 <- drop(crossprod(c(1, 1), solve(Kn, c(1, 1))))
  location <- f$fit$posterior_intercept + f$fit$posterior_slope
  direct <- stats::integrate(function(v) stats::pnorm((10 - location) / sqrt(v * (1 + q0))) * exp(an * log(bn) - lgamma(an) - (an + 1) * log(v) - bn / v), 0, Inf, rel.tol = 1e-9)$value
  testthat::expect_equal(direct, f$fit$posterior_predictive_below_ten, tolerance = 1e-8)
  h <- m11_horizon(); testthat::expect_equal(h$exposure_person_years, 21)
  direct <- stats::integrate(function(rate) -expm1(-2 * rate) * stats::dgamma(rate, 5, rate = 23), 0, Inf, rel.tol = 1e-10)$value
  testthat::expect_equal(direct, h$risk_predictive, tolerance = 1e-10)
  testthat::expect_gt(h$rate_confidence_upper, h$rate_mle)
  v <- m11_validity(); testthat::expect_equal(sum(v$known_states$state_posterior), 1)
  testthat::expect_equal(v$state_readout$target_probability, c(316 / 613, 90 / 204), tolerance = 1e-14)
  testthat::expect_equal(v$state_readout$alternative_process_probability, c(576 / 613, 152 / 204), tolerance = 1e-14)
  tr <- m11_transport(); testthat::expect_equal(nrow(tr$vertices), 128)
  testthat::expect_equal(tr$summary$new_positive_predictive, 33 / 98, tolerance = 1e-14)
  testthat::expect_lt(abs(tr$summary$confidence_lower - .026116), 5e-7)
  testthat::expect_equal(tr$summary$confidence_upper, .918108, tolerance = 5e-7)
  missing <- m11_missing(); testthat::expect_equal(missing$population_risk_mean, c(41.5, 33.1, 45) / 103, tolerance = 1e-14)
})
testthat::test_that("M11 information evaluation enumerates the whole policy", {
  info <- m11_information(); paths <- info$terminal_paths
  testthat::expect_equal(sum(paths$probability_given_target), 1)
  testthat::expect_equal(sum(paths$probability_given_nontarget), 1)
  sensitivity <- sum(paths$terminal_a1 * paths$probability_given_target)
  fp <- sum(paths$terminal_a1 * paths$probability_given_nontarget)
  count <- sum(paths$measurements * (.3 * paths$probability_given_target + .7 * paths$probability_given_nontarget))
  testthat::expect_equal(c(sensitivity, fp, count), c(.96, .19, 1.69), tolerance = 1e-14)
  total <- 4 * .3 * (1 - sensitivity) + .7 * fp + .1 * count
  testthat::expect_equal(total, info$policy_values$optimal_total_loss[3], tolerance = 1e-14)
  testthat::expect_equal(info$policy_values$optimal_total_loss, c(.7, .41, .35), tolerance = 1e-14)
  u <- m11_uncertain_test(); testthat::expect_equal(sum(u$count_predictive_probability), 1, tolerance = 1e-14)
  testthat::expect_equal(u$integrated_target_probability[3], 100 / 107, tolerance = 1e-14)
  testthat::expect_equal(u$plugin_target_probability[3], 75 / 82, tolerance = 1e-14)
  testthat::expect_equal(m11_uncertain_test(length = 0)$integrated_target_probability, .3)
  testthat::expect_error(m11_uncertain_test(a = 0))
  testthat::expect_error(m11_policy_value(.3, remaining = -1))
  testthat::expect_error(m11_next(.5, 2))
  # Validate both score identities directly on the four Bernoulli cells.
  v <- m11_validation()$calibration
  testthat::expect_equal(sum(v$weight * v$constant_brier), .25)
  testthat::expect_equal(sum(v$weight * v$best_brier), .09)
  testthat::expect_equal(sum(v$weight * v$constant_log_loss), log(2))
})

testthat::test_that("M11 terminal policy rejects unsupported probability/cost inputs", {
  testthat::expect_error(m11_policy_value(-.1, remaining=0))
  testthat::expect_error(m11_policy_value(1.1, remaining=0))
  testthat::expect_error(m11_policy_value(NaN, remaining=0))
  testthat::expect_error(m11_policy_value(.3, cost=Inf))
})
