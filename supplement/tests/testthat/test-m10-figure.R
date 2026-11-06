testthat::test_that("R figure preserves original experiments and redundant encodings", {
  d <- m10_figure_data(); testthat::expect_equal(d$student_points$probability, c(.0750173, .0890964, .0801801, .0629253), tolerance = 1e-6)
  testthat::expect_lt(abs(d$estimated_points$probability[1] - .3620338), 5e-8)
  testthat::expect_equal(d$estimated_points$probability[2], .1346)
  testthat::expect_equal(d$benchmarks$probability, c(.05, .05))
  testthat::expect_false(d$benchmarks$status[1] == d$benchmarks$status[2])
  color <- plot_m10_cutoff(d); gray <- plot_m10_cutoff(d, gray = TRUE)
  for (i in 1:2) {
    a <- ggplot2::ggplot_build(color[[i]])$data; b <- ggplot2::ggplot_build(gray[[i]])$data
    for (j in seq_along(a)) {
      if ("x" %in% names(a[[j]])) testthat::expect_equal(a[[j]]$x, b[[j]]$x)
      if ("y" %in% names(a[[j]])) testthat::expect_equal(a[[j]]$y, b[[j]]$y)
    }
  }
  # The simulation point remains a square, distinct from the exact open circle.
  b <- ggplot2::ggplot_build(color$estimated)$data
  testthat::expect_equal(b[[3]]$shape, 21); testthat::expect_equal(b[[4]]$shape, 22)
  testthat::expect_equal(b[[1]]$linetype, "dashed")
})
