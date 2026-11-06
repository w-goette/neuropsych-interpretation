testthat::test_that("M00 plot coordinates retain different statistical objects", {
  result <- m00_evaluate_replication(m00_replication_law())
  data <- m00_replication_figure_data(result)
  testthat::expect_equal(nrow(data), 10L)
  testthat::expect_equal(data$score[data$role == "Possible repeats"], result$law$score)
  testthat::expect_equal(data$probability[data$role == "Possible repeats"], result$law$probability)
  testthat::expect_equal(data$score[data$role == "Expected score"], result$summary$expected_score)
  testthat::expect_equal(data$score[data$role == "Observed score"], rep(35, 2))
  plots <- plot_m00_replication(data, family = "Helvetica")
  gray <- plot_m00_replication(data, grayscale = TRUE, family = "Helvetica")
  for (i in 1:2) {
    b <- ggplot2::ggplot_build(plots[[i]])$data[[1]]
    g <- ggplot2::ggplot_build(gray[[i]])$data[[1]]
    testthat::expect_equal(sort(b$x), sort(data$score[data$universe == paste("Universe", i)]))
    testthat::expect_equal(b$x, g$x)
    testthat::expect_equal(b$y, g$y)
    testthat::expect_equal(length(unique(b$shape)), 3L)
  }
})

testthat::test_that("M00 fixed figure rejects unequal probabilities and extra repeat outcomes", {
  data <- m00_replication_figure_data()
  bad <- data; bad$probability[1:3] <- c(.2, .3, .5)
  testthat::expect_error(plot_m00_replication(bad), "probability 1/3")
  bad <- dplyr::bind_rows(data, data[1, ])
  testthat::expect_error(plot_m00_replication(bad), "exactly three")
})
