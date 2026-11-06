testthat::test_that("M12 figure uses exact original integer experiments and redundant marks", {
  d <- m12_figure_data();testthat::expect_equal(nrow(d$h1),18L);testthat::expect_equal(nrow(d$contrast),27L)
  for(k in 0:8) {
    h <- d$h1[d$h1$added==k,];c <- d$contrast[d$contrast$added==k,]
    testthat::expect_equal(h$h1_variance,c(1/(2+k),.5),tolerance=1e-14)
    testthat::expect_equal(c$contrast_variance[1],1+1/(2+k),tolerance=1e-14)
    testthat::expect_equal(c$contrast_variance[2],.5+1/(1+k),tolerance=1e-14)
    testthat::expect_equal(c$contrast_variance[3],min(vapply(0:k,function(j)1/(2+j)+1/(1+k-j),numeric(1))),tolerance=1e-14)
  }
  testthat::expect_equal(d$readout$variance_gain,c(1/6,0,1/6,1/2),tolerance=1e-14)
  for(gray in c(FALSE,TRUE)) {
    plots <- plot_m12_next_observation(d,gray);testthat::expect_equal(length(plots),2L)
    for(i in 1:2) {
      b <- ggplot2::ggplot_build(plots[[i]]);line <- b$data[[if(i==1)1 else 2]];points <- b$data[[if(i==1)2 else 3]]
      testthat::expect_equal(nrow(line),if(i==1)18L else 27L);testthat::expect_equal(nrow(points),nrow(line))
      testthat::expect_equal(length(unique(line$linetype)),if(i==1)2L else 3L);testthat::expect_equal(length(unique(points$shape)),if(i==1)2L else 3L)
      testthat::expect_true(all(is.finite(line$x)) && all(is.finite(line$y)));testthat::expect_equal(sort(unique(line$x)),as.numeric(0:8))
    }
  }
})
