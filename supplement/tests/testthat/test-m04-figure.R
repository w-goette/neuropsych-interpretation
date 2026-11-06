testthat::test_that("M04 plots preserve every source population and the projection endpoints", {
  x <- m04_figure_data();testthat::expect_equal(nrow(x$ellipses),1600L)
  testthat::expect_equal(x$steps$xend,c(-.75,-1.5));testthat::expect_equal(x$steps$yend,c(-.75,0))
  testthat::expect_equal(x$steps$x[2],x$steps$xend[1]);testthat::expect_equal(x$steps$y[2],x$steps$yend[1])
  testthat::expect_equal(unname(x$shifts$delta1),c(-1,-1,-1));testthat::expect_equal(unname(x$shifts$delta2),c(-1,0,1))
  testthat::expect_equal(x$shifts$level_squared,c(1.25,.3125,0));testthat::expect_equal(x$shifts$shape_noncentrality,c(0,1.25,5))
  # Independent inverse of the two-dimensional covariance; every ellipse point.
  u <- x$ellipses$score1-x$ellipses$center1;v <- x$ellipses$score2-x$ellipses$center2
  testthat::expect_lt(max(abs((u^2-1.2*u*v+v^2)/.64-stats::qchisq(.95,2))),1e-12)
  for(gray in c(FALSE,TRUE)) {
    plots <- plot_m04_level_shape(x,grayscale=gray);testthat::expect_length(plots,4)
    built <- lapply(plots,function(p) {testthat::expect_no_warning(ggplot2::ggplot_build(p));ggplot2::ggplot_build(p)})
    testthat::expect_equal(built[[1]]$data[[7]]$xend,-.75);testthat::expect_equal(built[[1]]$data[[7]]$yend,-.75)
    testthat::expect_equal(built[[1]]$data[[8]]$xend,-1.5);testthat::expect_equal(built[[1]]$data[[8]]$yend,0)
    for(i in 1:3) {
      testthat::expect_equal(built[[i+1]]$data[[7]]$xend,-1)
      testthat::expect_equal(built[[i+1]]$data[[7]]$yend,c(-1,0,1)[i])
      testthat::expect_equal(built[[i+1]]$data[[8]]$y,c(-1,0,1)[i])
      testthat::expect_equal(built[[i+1]]$data[[6]]$y,x$ellipses$score2[x$ellipses$population==x$shifts$population[i]])
    }
  }
})
