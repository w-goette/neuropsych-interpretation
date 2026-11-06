testthat::test_that("inclusive confidence handles endpoints and random group counts", {
  testthat::expect_equal(m09_cp(0, 0), c(lower = 0, upper = 1))
  for (n in 1:12) for (p in c(0, .01, .2, .5, .9, 1)) {
    intervals <- vapply(0:n, function(k) m09_cp(k, n), numeric(2))
    covered <- intervals[1, ] <= p & intervals[2, ] >= p
    testthat::expect_gte(sum(stats::dbinom(0:n, n, p)[covered]) + 1e-12, .95)
  }
  testthat::expect_error(m09_cp(3, 2)); testthat::expect_error(m09_cp(0, 1, 0))
  for (m in 0:12) testthat::expect_equal(m09_rank_size(m), 0)
  testthat::expect_equal(m09_rank_size(5, rank = FALSE), .077493296875, tolerance = 1e-13)
  weights <- stats::dbinom(0:12, 12, .4)
  testthat::expect_lt(abs(sum(weights * vapply(0:12, function(m) m09_rank_size(m, rank = FALSE), numeric(1))) - .09435147), 5e-9)
})

testthat::test_that("beta quadrature integrates polynomial benchmarks, including singular endpoint weights", {
  for (ab in list(c(1, 1), c(.5, .5), c(2, 5), c(17, 10))) {
    q <- m09_beta_rule(12, ab[1], ab[2])
    testthat::expect_true(all(q$node > 0 & q$node < 1)); testthat::expect_true(all(q$weight >= 0))
    for (power in 0:8) testthat::expect_equal(sum(q$weight * q$node^power), exp(lbeta(ab[1] + power, ab[2]) - lbeta(ab[1], ab[2])), tolerance = 1e-12)
  }
  testthat::expect_error(m09_beta_rule(1)); testthat::expect_error(m09_beta_rule(5, 0, 1))
})

testthat::test_that("screening law has independent half-normal and tail integrations", {
  s <- m09_screening()
  mean <- stats::integrate(function(z) 2 * z * stats::dnorm(z), -Inf, 0)$value
  second <- stats::integrate(function(z) 2 * z^2 * stats::dnorm(z), -Inf, 0)$value
  testthat::expect_equal(s$selected_negative_pair[1], second - mean^2, tolerance = 1e-10)
  c <- stats::qchisq(.95, 1)
  tail <- stats::integrate(function(z) 8 * stats::dnorm(z) * stats::pnorm(z - sqrt(2 * c)), -Inf, 0, rel.tol = 1e-11)$value
  testthat::expect_equal(s$selected_negative_pair[2], tail, tolerance = 1e-12)
  testthat::expect_equal(s$selected_negative_pair[3], .05)
})

testthat::test_that("derived pattern targets retain posterior dependence and stable integrals", {
  p <- m09_pattern(); x <- p$summary
  testthat::expect_equal(x$contrast_mean, 8 / 27, tolerance = 1e-14)
  testthat::expect_equal(x$contrast_variance, .0048310103589263, tolerance = 1e-13)
  testthat::expect_equal(x$contrast_variance, x$wrong_independent_variance - 2 * x$shared_covariance, tolerance = 1e-14)
  testthat::expect_equal(c(p$cdf(-1), p$cdf(1)), c(0, 1), tolerance = 1e-13)
  testthat::expect_equal(p$cdf(c(x$lower, x$upper)), c(.025, .975), tolerance = 1e-10)
  high <- m09_pattern(order = 96)$summary
  testthat::expect_equal(x$lower, high$lower, tolerance = 1e-9); testthat::expect_equal(x$upper, high$upper, tolerance = 1e-9)
  testthat::expect_error(m09_pattern(prior = matrix(0, 3, 2)))
  empty <- m09_pattern(counts = matrix(0, 3, 2))
  testthat::expect_equal(empty$mechanism$mean, rep(.5, 3))
})

testthat::test_that("MAR fitting separates kernel mean, response noise and composition", {
  records <- m09_records(); fit <- m09_mar_fit(records); case <- m09_case(fit)
  testthat::expect_equal(nrow(records), 60); testthat::expect_equal(sum(is.na(records$second_score)), 24)
  direct <- stats::lm(second_score ~ first_category, data = records)
  testthat::expect_equal(unname(stats::coef(direct)), fit$frequent$b, tolerance = 1e-11)
  testthat::expect_equal(fit$frequent$b, c(50, 10), tolerance = 1e-11)
  testthat::expect_equal(fit$frequent$s2, 4, tolerance = 1e-10)
  testthat::expect_equal(case$mean_location, 40.0334705126858, tolerance = 1e-10)
  testthat::expect_equal(case$predictive_scale, 2.06126147835486, tolerance = 1e-11)
  testthat::expect_lt(case$response_lower, case$mean_lower); testthat::expect_gt(case$response_upper, case$mean_upper)
  testthat::expect_equal(case$prediction_upper, 44.3478545990321, tolerance = 1e-10)
  population <- m09_population(fit); abbreviated <- m09_population(fit, c(17, 7, 3))
  testthat::expect_equal(population$mean, fit$b[1]); testthat::expect_gt(population$variance, fit$Ev * fit$V[1, 1])
  testthat::expect_equal(population$lower, 47.898336, tolerance = 5e-7)
  testthat::expect_lt(abbreviated$mean, population$mean)
  empty <- dplyr::mutate(records, second_score_recorded = 0L, second_score = NA_real_)
  prior <- m09_mar_fit(empty); testthat::expect_equal(prior$b, c(50, 0)); testthat::expect_null(prior$frequent)
  bad <- records; bad$second_score[1] <- 0; testthat::expect_error(m09_mar_fit(bad))
})

testthat::test_that("nonlinear scatter matches direct Student integrals and shared calibration", {
  fit <- m09_mar_fit(); x <- m09_profile(fit); c <- m09_case(fit)
  power_integral <- function(k) stats::integrate(function(z) (((c$mean_location + c$predictive_scale * z - 40)^2 / 2)^k) * stats::dt(z, c$df), -Inf, Inf, rel.tol = 1e-10)$value
  testthat::expect_equal(x$mean, power_integral(1), tolerance = 1e-9)
  testthat::expect_equal(x$variance + x$mean^2, power_integral(2), tolerance = 1e-8)
  testthat::expect_gt(x$mean, x$mean_filled)
  testthat::expect_equal(x$probability_over8, .0590740185209653, tolerance = 1e-12)
  j <- m09_joint_profile(fit, 64); j2 <- m09_joint_profile(fit, 96)
  testthat::expect_equal(j$one, x$probability_over8, tolerance = 1e-10)
  testthat::expect_equal(j$both, j2$both, tolerance = 1e-10)
  testthat::expect_gt(j$both, j$wrong_product)
  testthat::expect_lt(abs(j$both - .00478979), 5e-9)
  testthat::expect_equal(m09_profile(fit, radius = 2)$mean - x$mean, 2 / 3, tolerance = 1e-12)
  testthat::expect_gt(m09_profile(fit, radius = 5)$probability_over8, x$probability_over8)
  low <- fit; low$a <- 2; testthat::expect_error(m09_profile(low))
})

testthat::test_that("finite adaptive posterior matches direct raw-prior polynomial quadrature", {
  # No allocation expansion here: integrate raw likelihood over nine parameters.
  q <- m09_beta_rule(3); qp <- m09_beta_rule(3, 2, 2)
  grid <- as.matrix(expand.grid(rep(list(1:3), 9))); prevalence <- qp$node[grid[, 1]]
  parameters <- matrix(q$node[grid[, -1]], nrow(grid), 8)
  weights <- qp$weight[grid[, 1]] * apply(matrix(q$weight[grid[, -1]], nrow(grid), 8), 1, prod)
  D <- rbind(c(0, 0, 0, 0, 0), c(1, 1, 1, 0, 1), c(1, 1, 1, 1, 1))
  ref <- rep(1, nrow(grid))
  for (i in 1:3) {
    law <- matrix(0, nrow(grid), 2)
    for (h in 0:1) {
      P <- parameters[, (1:4) + 4 * h]
      K <- ifelse(matrix(D[i, 2:5], nrow(grid), 4, byrow = TRUE) == 1, P, 1 - P)
      anchor <- if (D[i, 1] == 1) c(.1, .9)[h + 1] else 1 - c(.1, .9)[h + 1]
      law[, h + 1] <- anchor * apply(K, 1, prod)
    }
    ref <- ref * ((1 - prevalence) * law[, 1] + prevalence * law[, 2])
  }
  evidence <- numeric(2)
  for (h in 0:1) {
    P <- parameters[, (1:4) + 4 * h]
    likelihood <- (1 - P[, 1]) * P[, 4] * P[, 2] # fail, choose A, succeed
    evidence[h + 1] <- sum(weights * ref * likelihood * if (h == 1) prevalence else 1 - prevalence)
  }
  testthat::expect_equal(m09_adaptive()$probability_H1, evidence[2] / sum(evidence), tolerance = 1e-12)
  testthat::expect_equal(m09_adaptive()$probability_H1, .703242639332852, tolerance = 1e-12)
  testthat::expect_equal(m09_adaptive(prefix = "first")$probability_H1, .343773184949656, tolerance = 1e-12)
  testthat::expect_equal(m09_adaptive(prefix = "choice")$probability_H1, .528470171293562, tolerance = 1e-12)
  law <- m09_adaptive_summary()
  testthat::expect_equal(sum(law$paths$mass), 1, tolerance = 1e-12)
  testthat::expect_equal(sum(law$scores$mass), 1, tolerance = 1e-12)
  mapped <- law$scores$probability_H1[match(law$paths$total, law$scores$total)]
  loss <- sum(law$paths$mass * (law$paths$probability_H1 - mapped)^2)
  testthat::expect_equal(law$risks$loss, loss, tolerance = 1e-12)
  testthat::expect_equal(law$risks$score_risk, .204424791290532, tolerance = 1e-12)
  testthat::expect_error(m09_adaptive(shape = 0)); testthat::expect_error(m09_adaptive(anchor = c(0, 1)))
})

testthat::test_that("first-crossing recursion matches full binary-word enumeration", {
  words <- as.matrix(expand.grid(rep(list(0:1), 10)))
  hit <- apply(words, 1, function(x) any(vapply(1:10, function(t) 2^t / ((t + 1) * choose(t, sum(x[1:t]))), numeric(1)) >= 20))
  x <- m09_crossing(horizon = 10)
  testthat::expect_equal(tail(x$cumulative_crossing, 1), mean(hit), tolerance = 1e-14)
  testthat::expect_equal(x$cumulative_crossing + x$survival, rep(1, 10), tolerance = 1e-13)
  for (p in c(0, .1, .5, .9, 1)) testthat::expect_lte(tail(m09_crossing(p, p, 50)$cumulative_crossing, 1), .05 + 1e-12)
  fitted <- (m09_crossing(denominator = 1 / 3)$cumulative_crossing + m09_crossing(denominator = 2 / 3)$cumulative_crossing) / 2
  testthat::expect_equal(fitted[c(10, 20, 100)], c(.0751953125, .1450462341308594, .724726416622038), tolerance = 5e-7)
  testthat::expect_gt(fitted[100], .7)
  testthat::expect_equal(m09_stopped_record(c(rep(1, 9), 0))$actual_stopped_length, 8)
  testthat::expect_equal(m09_stopped_record(c(0, rep(1, 9)))$actual_stopped_length, 10)
  testthat::expect_equal(m09_ratio(10, 0, 0), 1 / 11, tolerance = 1e-14)
  testthat::expect_true(is.infinite(m09_ratio(10, 1, 0)))
  testthat::expect_error(m09_ratio(2, 3, .5)); testthat::expect_error(m09_crossing(horizon = 0))
})

testthat::test_that("time confidence uses normalized record likelihood rather than a false exposure pivot", {
  x <- m09_censoring(); f <- x$full
  logZ <- lgamma(8) - 8 * log(9)
  for (end in c(f$confidence_lower, f$confidence_upper)) testthat::expect_equal(6 * log(end) - 8 * end, log(.05) + logZ, tolerance = 1e-10)
  testthat::expect_lt(f$confidence_lower, f$lower); testthat::expect_gt(f$confidence_upper, f$upper)
  testthat::expect_lt(abs(f$confidence_lower - .167942), 5e-7)
  testthat::expect_equal(stats::pgamma(c(f$lower, f$upper), 8, rate = 9), c(.025, .975), tolerance = 1e-12)
  indicator <- dplyr::filter(x$matched_priors, prior_shape == 1, retained == "indicators only")
  testthat::expect_equal(indicator$mean_rate, sum(1 / (5:11)), tolerance = 1e-10)
  testthat::expect_equal(f$new_completion_probability, 1 - .9^8, tolerance = 1e-14)
})

testthat::test_that("missing flags keep population, cohort and retrieval denominators separate", {
  x <- m09_missing_flag(); v <- m09_missing_flag(retrieved = 5, positive = 4)
  testthat::expect_equal(x$population_mean, 19 / 56, tolerance = 1e-14)
  testthat::expect_equal(x$cohort_fraction_mean, .32, tolerance = 1e-14)
  testthat::expect_equal(x$cohort_fraction_variance, .016, tolerance = 1e-14)
  testthat::expect_equal(v$population_mean, .423469387755102, tolerance = 1e-14)
  testthat::expect_equal(v$cohort_fraction_mean, (7 + 5 * 5 / 7) / 25, tolerance = 1e-14)
  testthat::expect_equal(c(v$missing_shape_a, v$missing_shape_b), c(5, 2))
  # Endpoint mixtures have independent exact Dirichlet marginal beta laws.
  for (point in 0:1) {
    z <- m09_missing_flag(lo = point, hi = point)
    shape <- if (point == 0) c(4, 24) else c(15, 13)
    testthat::expect_equal(c(z$lower, z$upper), stats::qbeta(c(.025, .975), shape[1], shape[2]), tolerance = 1e-9)
  }
  testthat::expect_equal(m09_missing_flag(linked = TRUE)$population_mean, 4 / 17)
  soft <- m09_missing_flag(1, 9); hard <- m09_missing_flag(lo = 0, hi = .2)
  testthat::expect_equal(soft$population_mean, hard$population_mean); testthat::expect_gt(soft$variance, hard$variance)
  testthat::expect_error(m09_missing_flag(retrieved = 11)); testthat::expect_error(m09_missing_flag(lo = -.1))
  testthat::expect_error(m09_missing_flag(lo = 0, hi = .2, retrieved = 1, positive = 0))
})

testthat::test_that("support-gap mean intervals and missing-set enclosures keep their targets", {
  records <- m09_records()
  gap <- dplyr::mutate(records, second_score_recorded = ifelse(first_category == -1, 0L, second_score_recorded), second_score = ifelse(first_category == -1, NA_real_, second_score))
  fit <- m09_mar_fit(gap); zero <- m09_support_mean(fit); radius <- m09_support_mean(fit, 2)
  testthat::expect_equal(zero$mean, 40.078924, tolerance = 5e-8)
  testthat::expect_equal(radius$entire_mean_set_confidence_lower, zero$entire_mean_set_confidence_lower - 2)
  testthat::expect_lt(radius$lower, zero$lower); testthat::expect_gt(radius$upper, zero$upper)
  response <- m09_case(fit)
  testthat::expect_gt(response$response_upper - response$response_lower, zero$upper - zero$lower)
  testthat::expect_error(m09_support_mean(fit, -1))
  low <- m09_missing_set(0, .2); high <- m09_missing_set(.8, 1); unrestricted <- m09_missing_set()
  testthat::expect_equal(c(low$empirical_lower, low$empirical_upper), c(.12, .20))
  testthat::expect_equal(c(high$empirical_lower, high$empirical_upper), c(.44, .52))
  testthat::expect_lt(abs(low$entire_set_confidence_lower - .019573), 5e-7)
  testthat::expect_lt(abs(high$entire_set_confidence_upper - .745307), 5e-7)
  testthat::expect_equal(unrestricted$entire_set_confidence_lower, m09_missing_flag()$entire_set_confidence_lower)
  testthat::expect_error(m09_missing_set(.9, .1))
})
