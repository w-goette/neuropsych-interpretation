testthat::test_that("shared palette and font metadata are available without a network", {
  tokens <- book_tokens()
  testthat::expect_equal(unname(book_palette(1)), unname(tokens["plot_blue"]))
  testthat::expect_equal(length(book_palette()), 6L)
  testthat::expect_error(book_palette(7), "six|integer")
  testthat::expect_true(nzchar(book_font_family()))
  testthat::expect_s3_class(book_theme(), "theme")
})
