# The two existing M07 figures, re-created as five independently readable panels.
# No illustration data, comparison population, score or measurement model changes.
m07_figure_data <- function() {
  y <- seq(5, 85, .05)
  density <- tibble::tibble(score = y, C0 = stats::dnorm(y, 50, 10), C1 = stats::dnorm(y, 40, 5),
    Pool = .5 * stats::dnorm(y, 50, 10) + .5 * stats::dnorm(y, 40, 5), Moment_normal = stats::dnorm(y, 45, sqrt(87.5)))
  h <- seq(-3, 3, .02)
  measurement <- dplyr::bind_rows(lapply(0:1, function(g) tibble::tibble(h = h, group = paste0("Group ", g), observed = h + 2 * g, report = h)))
  # report=h is an algebraic identity, not a numerical separation of equal curves.
  list(density = density, measurement = measurement, probabilities = m07_references())
}
plot_m07_norms <- function(input = m07_figure_data(), grayscale = FALSE, family = book_font_family()) {
  tokens <- book_tokens(); navy <- tokens[["brand_navy"]]; blue <- tokens[["plot_blue"]]; orange <- tokens[["plot_orange"]]
  if (grayscale) { navy <- tokens[["text_light"]]; blue <- tokens[["text_light"]]; orange <- tokens[["text_light"]] }
  common <- book_theme(base_size = 14, base_family = family) + ggplot2::theme(
    plot.title = ggplot2::element_text(size = 14, face = "bold"), plot.subtitle = ggplot2::element_text(size = 11),
    axis.text = ggplot2::element_text(size = 12), plot.margin = ggplot2::margin(12, 12, 12, 12),
    legend.position = "bottom", legend.text = ggplot2::element_text(size = 11), legend.key.width = grid::unit(1.5, "lines"))
  density_plot <- function(variable, title, subtitle, probability, type, color) {
    d <- input$density; d$density <- d[[variable]]
    p <- ggplot2::ggplot(d, ggplot2::aes(score, density)) +
      ggplot2::geom_area(data = d[d$score <= 35, ], fill = "#D9E2E9", color = NA) +
      ggplot2::geom_line(linewidth = .9, linetype = type, color = color) +
      ggplot2::geom_vline(xintercept = 35, linewidth = .6, color = navy) +
      ggplot2::annotate("text", x = if (variable == "C1") 52 else 37, y = .074, label = sprintf("Below 35\n%.3f", probability), hjust = 0, size = 4.2, color = navy, family = family) +
      ggplot2::scale_x_continuous(limits = c(5, 85), breaks = c(20, 35, 50, 65, 80)) +
      ggplot2::scale_y_continuous(limits = c(0, .085), breaks = c(0, .02, .04, .06, .08)) +
      ggplot2::labs(title = title, subtitle = subtitle, x = "Observed score y", y = "Reference density\n(per score unit)") + common
    if (variable == "Pool") p <- p +
      ggplot2::geom_line(ggplot2::aes(y = Moment_normal), color = orange, linewidth = .8, linetype = "longdash") +
      ggplot2::annotate("text", x = 64, y = .055, label = "Moment-matched\nnormal: 0.143", hjust = .5, size = 3.7, family = family, color = orange)
    p
  }
  a <- density_plot("C0", "A  Peers with C = 0", "Mean 50; SD 10", input$probabilities$percentile[1], "solid", navy)
  b <- density_plot("C1", "B  Peers with C = 1", "Mean 40; SD 5", input$probabilities$percentile[2], "dashed", blue)
  c <- density_plot("Pool", "C  Equal-weight pool", "Same score; different reference law", input$probabilities$percentile[3], "dotted", navy)
  colors <- c("Group 0" = navy, "Group 1" = orange); types <- c("Group 0" = "solid", "Group 1" = "dashed")
  d <- ggplot2::ggplot(input$measurement, ggplot2::aes(h, observed, color = group, linetype = group)) +
    ggplot2::geom_line(linewidth = .9) +
    ggplot2::annotate("point", x = c(0, 0), y = c(0, 2), shape = 21, size = 3, fill = "white", color = navy) +
    ggplot2::annotate("segment", x = 0, xend = 0, y = 0, yend = 2, color = navy, arrow = grid::arrow(ends = "both", length = grid::unit(.1, "inches"))) +
    ggplot2::annotate("text", x = .5, y = -.9, label = "At the same h = 0:\nscores 0 and 2", hjust = 0, size = 3.8, family = family, color = navy) +
    ggplot2::scale_color_manual(values = colors) + ggplot2::scale_linetype_manual(values = types) +
    ggplot2::scale_x_continuous(limits = c(-3, 3), breaks = -3:3) +
    ggplot2::scale_y_continuous(limits = c(-3.2, 5.2), breaks = seq(-3, 5, 2)) +
    ggplot2::labs(title = "A  Measurement relation differs", subtitle = "Observed Y = h + 2C", x = "Latent coordinate h", y = "Observed score Y", color = NULL, linetype = NULL) + common
  # Draw the solid curve first and the thinner dashed curve over it: exact overlap.
  e <- ggplot2::ggplot(input$measurement, ggplot2::aes(h, report)) +
    ggplot2::geom_line(data = input$measurement[input$measurement$group == "Group 0", ], color = if (grayscale) "#6B7280" else navy, linewidth = 1.9) +
    ggplot2::geom_line(data = input$measurement[input$measurement$group == "Group 1", ], color = orange, linetype = "dashed", linewidth = .8) +
    ggplot2::annotate("text", x = -2.8, y = 2.4, label = "Both groups:\nreport = h\nExact overlap", hjust = 0, size = 4, family = family, color = navy) +
    ggplot2::scale_x_continuous(limits = c(-3, 3), breaks = -3:3) +
    ggplot2::scale_y_continuous(limits = c(-3.2, 3.2), breaks = -3:3) +
    ggplot2::labs(title = "B  Calibrated report is identical", subtitle = "Correct conditional percentile,
then normal quantile", x = "Latent coordinate h", y = "Normalized report") + common
  list(a, b, c, d, e)
}
