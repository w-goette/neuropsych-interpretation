testthat::test_that("normal reference calculations match independent analytic landmarks", {
  curve <- normal_reference_curve(c(-1.959963984540054, 0, 1.959963984540054))
  testthat::expect_equal(curve$lower_tail, c(0.025, 0.5, 0.975), tolerance = 1e-12)
  shifted <- normal_reference_curve(c(80, 100, 120), mean = 100, sd = 20)
  standard <- normal_reference_curve(c(-1, 0, 1))
  testthat::expect_equal(shifted$lower_tail, standard$lower_tail)
  testthat::expect_error(normal_reference_curve(1, sd = 0), "positive")
  testthat::expect_error(normal_reference_curve(NA_real_), "finite")
})

testthat::test_that("figure export retains nonvisual description and exact plotting data", {
  folder <- tempfile("reference-figure-")
  dir.create(folder)
  on.exit(unlink(folder, recursive = TRUE))
  curve <- normal_reference_curve(seq(-3, 3, length.out = 101))
  plot <- save_reference_figure(curve, folder)
  testthat::expect_match(ggplot2::get_alt_text(plot), "fraction")
  testthat::expect_true(all(file.exists(file.path(folder, paste0(
    "reference-curve", c(".pdf", ".png", "-data.csv", "-alt.txt")
  )))))
  saved <- readr::read_csv(file.path(folder, "reference-curve-data.csv"), show_col_types = FALSE)
  testthat::expect_equal(saved$lower_tail, curve$lower_tail, tolerance = 1e-14)
})
