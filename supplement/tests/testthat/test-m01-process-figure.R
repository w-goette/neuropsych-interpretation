testthat::test_that("M01 ranks and cutoff selection differ in their meanings", {
  data <- m01_process_data()
  testthat::expect_equal(data$law$inclusive_percent, c(10, 30, 70, 100))
  testthat::expect_equal(data$law$midpoint_percent, c(5, 20, 50, 85))
  testthat::expect_equal(data$law$strict_percent, c(0, 10, 30, 70))
  testthat::expect_equal(data$summary$rank_percent, c(10, 5, 0))
  testthat::expect_equal(data$summary$flagged_fraction, c(0, .1, .1), tolerance = 1e-14)
  testthat::expect_equal(sum(data$law$mass), 1)
  # Equality belongs in the rule: excluding it changes the midpoint result.
  midpoint <- data$decisions[data$decisions$convention == "Midpoint", ]
  testthat::expect_true(midpoint$selected[midpoint$score == 0])
  testthat::expect_equal(sum(midpoint$mass[midpoint$rank_percent < 5]), 0)
  testthat::expect_false(any(data$decisions$selected[data$decisions$score > 0]))
  testthat::expect_equal(nrow(data$decisions), 12L)
})
