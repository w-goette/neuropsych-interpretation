# Figure geometry is computed from the same synthetic known law as m08_joint.
m08_figure_data <- function() {
  theta <- seq(0, 2 * pi, length.out = 400)
  circle <- cbind(cos(theta), sin(theta))
  covariance <- matrix(c(100, 80, 80, 100), 2)
  ellipse <- dplyr::bind_rows(lapply(c(.5, .95), function(level) {
    xy <- sweep(sqrt(stats::qchisq(level, 2)) * circle %*% chol(covariance), 2, c(50, 52), "+")
    tibble::tibble(level = level, first = xy[, 1], retest = xy[, 2])
  }))
  lines <- tibble::tibble(first = rep(c(15, 85), 2),
    retest = c(17, 87, 24, 80),
    comparison = rep(c("First score + average gain", "Expected retest given first"), each = 2))
  list(ellipses = ellipse, lines = lines,
    errors = m08_joint(seq(10, 90, length.out = 801)),
    readout = m08_joint(c(20, 35, 50)),
    conditional_interval = tibble::tibble(first = 35, expected = 40,
      lower = 40 - stats::qnorm(.975) * 6, upper = 40 + stats::qnorm(.975) * 6))
}

m08_plots <- function(data = m08_figure_data(), grayscale = FALSE) {
  # Position/line type/shape repeat information carried by color.
  ink <- if (grayscale) rep(unname(book_tokens()[["text_light"]]), 2) else unname(book_palette(2))
  a <- ggplot2::ggplot() +
    ggplot2::geom_path(data = data$ellipses, ggplot2::aes(first, retest, group = level), colour = "grey50", linewidth = .5) +
    ggplot2::geom_segment(data = data$conditional_interval,
      ggplot2::aes(x = first, xend = first, y = lower, yend = upper), linewidth = 4, colour = "grey55") +
    ggplot2::geom_line(data = data$lines, ggplot2::aes(first, retest, linetype = comparison, colour = comparison), linewidth = .8) +
    ggplot2::geom_point(ggplot2::aes(35, 40), shape = 95, size = 8) +
    ggplot2::geom_point(ggplot2::aes(35, 36), shape = 21, fill = "white", size = 3, stroke = 1) +
    ggplot2::annotate("text", x = 43, y = 19, label = "Case: 35 then 36", size = 4, hjust = 0) +
    ggplot2::scale_linetype_manual(values = c("Expected retest given first" = "solid", "First score + average gain" = "dashed"), name = NULL) +
    ggplot2::scale_colour_manual(values = stats::setNames(ink, c("Expected retest given first", "First score + average gain")), name = NULL) +
    ggplot2::coord_fixed(xlim = c(15, 85), ylim = c(15, 85), expand = FALSE) +
    ggplot2::scale_x_continuous(breaks = seq(20, 80, 20)) +
    ggplot2::scale_y_continuous(breaks = seq(20, 80, 20)) +
    ggplot2::labs(title = "A. Compare the same record", x = "First score", y = "Retest score") +
    book_theme(base_size = 13.5) +
    ggplot2::theme(legend.position = "bottom", legend.direction = "vertical",
      legend.text = ggplot2::element_text(size = 11.5), plot.title = ggplot2::element_text(size = 14, face = "bold"))
  points <- data$readout
  points$vjust <- c(-1, -1, 1.8)
  points$label <- sprintf("%.3f", points$marginal_rule_conditional_error)
  b <- ggplot2::ggplot(data$errors, ggplot2::aes(first, marginal_rule_conditional_error)) +
    ggplot2::geom_line(colour = ink[1], linewidth = .9) +
    ggplot2::geom_hline(yintercept = .05, linetype = "dashed", linewidth = .7, colour = ink[2]) +
    ggplot2::geom_point(data = points, shape = 21, fill = "white", size = 2.6, stroke = 1) +
    ggplot2::geom_text(data = points, ggplot2::aes(label = label, vjust = vjust), size = 4) +
    ggplot2::annotate("text", x = 50, y = .229, label = "Solid: marginal difference rule", size = 4) +
    ggplot2::annotate("text", x = 50, y = .207, label = "Dashed: conditional rule (0.05)", size = 4) +
    ggplot2::scale_x_continuous(breaks = seq(10, 90, 20), limits = c(10, 90), expand = ggplot2::expansion(mult = .02)) +
    ggplot2::scale_y_continuous(breaks = seq(0, .25, .05), limits = c(0, .25), labels = function(x) sprintf("%.2f", x)) +
    ggplot2::labs(title = "B. Hold the first score fixed", x = "First score (held fixed)", y = "Null probability of flagging change") +
    book_theme(base_size = 13.5) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 14, face = "bold"))
  list(a = a, b = b)
}
