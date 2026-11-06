testthat::test_that("M00 complete laws give distinct expectations for the same observation", {
  x <- m00_evaluate_replication(m00_replication_law())
  testthat::expect_equal(x$summary$expected_score, c(35, 38), tolerance = 1e-12)
  testthat::expect_equal(x$summary$observed_score, c(35, 35))
  testthat::expect_equal(x$summary$observed_residual, c(0, -3), tolerance = 1e-12)
  testthat::expect_equal(x$summary$mean_residual, c(0, 0), tolerance = 1e-12)
  testthat::expect_equal(x$law$expected_score + x$law$residual, x$law$score)
})
testthat::test_that("M00 expectation respects weights, affine scales and degeneracy", {
  law <- m00_replication_law()[1:3, ]; law$probability <- c(.2, .3, .5)
  x <- m00_evaluate_replication(law)
  testthat::expect_equal(x$summary$expected_score, 35.9, tolerance = 1e-12)
  testthat::expect_equal(x$summary$mean_residual, 0, tolerance = 1e-12)
  for (b in c(-2, .5, 3)) {
    transformed <- law; transformed$score <- 7 + b * law$score
    y <- m00_evaluate_replication(transformed, observed = 7 + b * 35)
    testthat::expect_equal(y$summary$expected_score, 7 + b * 35.9, tolerance = 1e-12)
    testthat::expect_equal(y$summary$observed_residual, b * (35 - 35.9), tolerance = 1e-12)
  }
  point <- tibble::tibble(universe = "fixed", score = 35, probability = 1)
  testthat::expect_equal(m00_evaluate_replication(point)$summary$observed_residual, 0)
  with_zero <- dplyr::bind_rows(point, tibble::tibble(universe = "fixed", score = 999, probability = 0))
  testthat::expect_equal(m00_evaluate_replication(with_zero)$summary$expected_score, 35)
})
testthat::test_that("M00 invalid or incompatible supplied laws are rejected", {
  law <- m00_replication_law()
  for (prob in list(rep(0, 6), rep(1, 6), c(-1, rep(.4, 5)), c(NA, rep(.2, 5)), c(Inf, rep(.2, 5)))) {
    invalid <- law; invalid$probability <- prob
    testthat::expect_error(m00_evaluate_replication(invalid))
  }
  for (obs in list(NA_real_, Inf, c(35, 38), "35", 99)) testthat::expect_error(m00_evaluate_replication(law, obs))
  testthat::expect_error(m00_evaluate_replication(law[FALSE, ]))
  testthat::expect_error(m00_evaluate_replication(law[, -2]))
  testthat::expect_error(m00_evaluate_replication(dplyr::bind_rows(law, law[1, ])))
  invalid <- law; invalid$score[1] <- Inf
  testthat::expect_error(m00_evaluate_replication(invalid))
  invalid <- law; invalid$universe[1] <- ""
  testthat::expect_error(m00_evaluate_replication(invalid))
  invalid <- law; invalid$probability[2] <- 0; invalid$probability[1] <- 2/3
  testthat::expect_error(m00_evaluate_replication(invalid), "positive probability")
})
