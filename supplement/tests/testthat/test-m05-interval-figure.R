testthat::test_that("figure preserves the two different observation operations", {
  x <- m05_interval_figure_data()
  testthat::expect_equal(nrow(x$intervals),4)
  testthat::expect_equal(nrow(x$coverage),1203)
  testthat::expect_equal(nrow(x$marked),6)
  testthat::expect_equal(sort(unique(x$marked$tau)),c(20,35,50))
  fixed <- x$coverage[x$coverage$procedure=="Confidence + likelihood prediction",]
  testthat::expect_true(all(fixed$coverage==.95))
  testthat::expect_equal(max(x$prior$scaled_shape),.18)
  testthat::expect_equal(x$prior$density[x$prior$tau==50],stats::dnorm(50,50,8))
  # Rounded source labels stay on the endpoints of the exact four procedures.
  testthat::expect_equal(round(x$intervals$lower,1),c(23.2,31.0,18.4,25.3))
  testthat::expect_equal(round(x$intervals$upper,1),c(46.8,49.8,51.6,55.5))
  for(gray in c(FALSE,TRUE)) {
    plots <- plot_m05_intervals(x,grayscale=gray)
    testthat::expect_length(plots,2)
    built <- ggplot2::ggplot_build(plots[[2]])
    testthat::expect_equal(nrow(built$data[[3]]),1203)
    testthat::expect_equal(nrow(built$data[[4]]),6)
  }
})
