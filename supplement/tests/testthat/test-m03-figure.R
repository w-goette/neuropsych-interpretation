testthat::test_that("M03 figure represents the law, geometry and tail meaning", {
  x <- m03_figure_data()
  testthat::expect_equal(nrow(x$ellipses),800L)
  testthat::expect_equal(nrow(x$densities),1802L)
  testthat::expect_equal(nrow(x$summaries),2L)
  testthat::expect_true(all(x$summaries$conditional_sd==8))
  testthat::expect_equal(x$summaries$conditional_mean,c(50,41))
  testthat::expect_lt(max(abs(x$summaries$conditional_tail-c(.0303964,.2266274))),5e-8)
  testthat::expect_equal(x$summaries$marginal_tail,rep(stats::pnorm(-1.5),2))
  testthat::expect_equal(x$slices$high-x$slices$low,c(32,32))
  testthat::expect_equal((x$slices$high+x$slices$low)/2,x$slices$center)
  # Full correlated distance is constant around each supplied central ellipse.
  e<-x$ellipses;u<-(e$score1-50)/10;v<-(e$score2-50)/10
  radius<-(u*u-1.2*u*v+v*v)/.64
  testthat::expect_lt(max(abs(radius-stats::qchisq(e$level,2))),1e-12)
  testthat::expect_true(all(c(35,seq(8,85,length.out=900)) %in% x$densities$score1))
  testthat::expect_true(all(x$summaries$omitted_conditional_lower_mass>0))
  testthat::expect_true(all(x$summaries$omitted_conditional_upper_mass>0))
  plots<-plot_m03_conditional(x)
  gray<-plot_m03_conditional(x,grayscale=TRUE)
  testthat::expect_length(plots,3)
  testthat::expect_length(gray,3)
  for(i in 1:3) {
    testthat::expect_s3_class(plots[[i]],'ggplot')
    testthat::expect_s3_class(gray[[i]],'ggplot')
    testthat::expect_no_warning(ggplot2::ggplot_build(plots[[i]]))
    testthat::expect_no_warning(ggplot2::ggplot_build(gray[[i]]))
  }
  built2<-ggplot2::ggplot_build(plots[[2]])
  built3<-ggplot2::ggplot_build(plots[[3]])
  testthat::expect_equal(built2$data[[2]]$y,built3$data[[2]]$y)
  testthat::expect_false(isTRUE(all.equal(built2$data[[3]]$y,built3$data[[3]]$y)))
})
