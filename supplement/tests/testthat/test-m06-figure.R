testthat::test_that("M06 figure quantities preserve their experiment and mixture", {
  d<-m06_figure_data()
  testthat::expect_equal(nrow(d$information),1101L)
  testthat::expect_equal(nrow(d$density),3404L)
  testthat::expect_true(all(d$information$moment_bound<=d$information$total_information+1e-12))
  testthat::expect_true(all(d$information$total_information<=d$information$pattern_information+1e-12))
  testthat::expect_true(all(d$information$total_share<=1+1e-12))
  info<-d$information |> dplyr::filter(abs(h)<1e-10)
  testthat::expect_lt(abs(info$total_share-.922),.0005)
  testthat::expect_equal(d$means$h,c(.066734798165279,.624989808733197,.156717874836195),tolerance=1e-10)
  testthat::expect_equal(d$mle$h,c(.333568759776733,1.230136198604455),tolerance=1e-9)
  p<-plot_m06_items(d);gray<-plot_m06_items(d,grayscale=TRUE)
  testthat::expect_length(p,3);testthat::expect_length(gray,3)
  for(i in 1:3) {
    colored<-ggplot2::ggplot_build(p[[i]])$data
    monochrome<-ggplot2::ggplot_build(gray[[i]])$data
    testthat::expect_length(colored,length(monochrome))
    for(j in seq_along(colored)) for(k in intersect(c("x","y","xend","yend"),names(colored[[j]])))
      testthat::expect_equal(colored[[j]][[k]],monochrome[[j]][[k]],tolerance=1e-13)
  }
})
