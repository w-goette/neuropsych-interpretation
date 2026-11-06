# Figure fig-m10-one-cutoff: preserve the two experiments and their probabilities.
m10_figure_data <- function() {
  nu <- exp(seq(log(2.02), log(200), length.out = 600)); n <- 6:400
  list(student = tibble::tibble(nu = nu, probability = m10_student_rate(nu)),
    gaussian = tibble::tibble(n = n, probability = m10_plugin_rate(n)),
    student_points = tibble::tibble(nu = c(3, 5, 10, 30), probability = m10_student_rate(c(3, 5, 10, 30)), label_y = c(.064, .098, .090, .073)),
    estimated_points = tibble::tibble(n = c(12, 12), probability = c(m10_plugin_rate(12), .1346), method = c("Unregularized plug-in", "Shrinkage simulation")),
    benchmarks = tibble::tibble(panel = c("A supplied Gaussian", "B exact finite-reference F cutoff"), probability = c(.05, .05), status = c("exact supplied law", "exact over independent reference samples and peers")))
}
plot_m10_cutoff <- function(data = m10_figure_data(), gray = FALSE, family = book_font_family()) {
  token <- book_tokens(); colors <- if (gray) c(grDevices::gray(.15), grDevices::gray(.45)) else unname(book_palette(2)); muted <- token[["muted_light"]]
  theme <- book_theme(14, family) + ggplot2::theme(plot.title = ggplot2::element_text(size = 15, face = "bold"),
    plot.subtitle = ggplot2::element_text(size = 11), plot.margin = ggplot2::margin(20, 30, 20, 30),
    axis.title = ggplot2::element_text(size = 15), axis.text = ggplot2::element_text(size = 16))
  a <- ggplot2::ggplot(data$student, ggplot2::aes(nu, probability)) +
    ggplot2::geom_hline(yintercept = .05, linetype = "dashed", colour = muted, linewidth = .6) +
    ggplot2::geom_line(colour = colors[1], linewidth = .9) +
    ggplot2::geom_point(data = data$student_points, shape = 21, size = 3.2, fill = "white", colour = colors[1], stroke = .9) +
    ggplot2::geom_text(data = data$student_points, ggplot2::aes(y = label_y, label = sprintf("%s: %.3f", nu, probability), hjust = ifelse(nu == 3, 0, .5)), family = family, size = 5, colour = token[["text_light"]]) +
    ggplot2::annotate("text", x = 10, y = .043, label = "Gaussian peers: 0.05", hjust = 0, family = family, size = 5, colour = muted) +
    ggplot2::scale_x_log10(breaks = c(2, 3, 5, 10, 30, 100, 200), labels = c("2", "3", "5", "10", "30", "100", "200")) +
    ggplot2::scale_y_continuous(breaks = seq(0, .10, .02)) +
    ggplot2::coord_cartesian(xlim = c(2, 200), ylim = c(0, .105), expand = FALSE) +
    ggplot2::labs(title = "A. Supplied Student law", subtitle = "Same covariance; Gaussian radius cutoff", x = "Degrees of freedom (log scale)", y = "Peer flagging probability") + theme
  points <- data$estimated_points
  b <- ggplot2::ggplot(data$gaussian, ggplot2::aes(n, probability)) +
    ggplot2::geom_hline(yintercept = .05, linetype = "dashed", colour = muted, linewidth = .6) +
    ggplot2::geom_line(colour = colors[1], linewidth = .9) +
    ggplot2::geom_point(data = points[1, ], shape = 21, size = 3.4, fill = "white", colour = colors[1], stroke = .9) +
    ggplot2::geom_point(data = points[2, ], shape = 22, size = 3.4, fill = colors[2], colour = token[["text_light"]], stroke = .8) +
    ggplot2::annotate("text", x = 15, y = .42, label = "n=12: 0.362", hjust = 0, family = family, size = 4) +
    ggplot2::annotate("text", x = 30, y = .25, label = "Shrinkage at n=12:\n0.135 (simulated)", hjust = 0, family = family, size = 5, colour = colors[2]) +
    ggplot2::annotate("segment", x = 12.3, xend = 28, y = .1346, yend = .22, colour = colors[2], linewidth = .45) +
    ggplot2::annotate("text", x = 55, y = .025, label = "F cutoff: 0.05", hjust = 0, family = family, size = 5, colour = muted) +
    ggplot2::annotate("text", x = 24, y = .60, label = "Solid: fitted radius,\nchi-square cutoff", hjust = 0, family = family, size = 5, colour = colors[1]) +
    ggplot2::scale_x_log10(breaks = c(6, 12, 30, 100, 400), labels = c("6", "12", "30", "100", "400")) +
    ggplot2::scale_y_continuous(breaks = seq(0, .8, .1)) +
    ggplot2::coord_cartesian(xlim = c(6, 400), ylim = c(0, .8), expand = FALSE) +
    ggplot2::labs(title = "B. Fitted Gaussian reference", subtitle = "Three score/cutoff choices", x = "Reference sample size (log scale)", y = "Peer flagging probability") + theme
  list(student = a, estimated = b)
}
