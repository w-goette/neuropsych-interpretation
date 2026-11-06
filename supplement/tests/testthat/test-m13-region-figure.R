testthat::test_that("M13 figure carries the same candidate laws through both panels", {
  d <- m13_figure_data(); r <- d$region
  testthat::expect_equal(d$candidates$mean, r$center + r$coefficient * d$candidates$sd)
  testthat::expect_equal(d$candidates$sd, c(r$sd_lower, r$sd_upper))
  testthat::expect_equal(d$anchors$lower[2], stats::pnorm(-r$coefficient), tolerance = 1e-14)
  for (i in 1:2) {
    t <- d$curves[d$curves$candidate == d$candidates$candidate[i], ]
    testthat::expect_equal(t$fraction, stats::pnorm((t$score - d$candidates$mean[i]) / d$candidates$sd[i]), tolerance = 1e-14)
    ix <- if (i == 1) t$score <= 50 else t$score >= 50
    testthat::expect_equal(t$fraction[ix], d$band$lower[ix], tolerance = 1e-14)
  }
  testthat::expect_true(all(d$band$lower <= d$band$upper))
})
