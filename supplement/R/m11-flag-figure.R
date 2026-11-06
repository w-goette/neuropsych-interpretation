# Preserve both original scientific operations; export separate legible panels.
m11_figure_data <- function() {
  pi <- seq(.005, .6, length.out = 400); q <- seq(0, 1, length.out = 401); case <- 51 / 116
  list(prevalence = tibble::tibble(prevalence = pi, target_probability = m11_risk(.8, .1, pi)),
    losses = dplyr::bind_rows(tibble::tibble(q = q, loss = 4 * q, action = "a0: baseline"), tibble::tibble(q = q, loss = 1 - q, action = "a1: alternative"), tibble::tibble(q = q, loss = .2, action = "Ideal referral")),
    readout = tibble::tibble(quantity = c("observed_prevalence", "observed_sensitivity", "observed_false_positive", "plugin_risk", "new_case_predictive", "decision_threshold", "referral_lower", "referral_upper", "case_loss_a0", "case_loss_a1", "case_loss_referral"), value = c(.1, .8, .1, 8 / 17, case, .2, .05, .8, 4 * case, 1 - case, .2)),
    case_points = tibble::tibble(q = case, loss = c(4 * case, 1 - case, .2), action = c("a0: baseline", "a1: alternative", "Ideal referral")))
}
plot_m11_flag <- function(data = m11_figure_data(), gray = FALSE, family = book_font_family()) {
  token <- book_tokens(); ink <- token[["text_light"]]; muted <- token[["muted_light"]]
  palette <- if (gray) c(grDevices::gray(.1), grDevices::gray(.35), grDevices::gray(.45)) else c(unname(book_palette(2)), muted)
  actions <- c("a0: baseline", "a1: alternative", "Ideal referral"); names(palette) <- actions
  theme <- book_theme(17, family) + ggplot2::theme(plot.title = ggplot2::element_text(size = 18, face = "bold"), plot.subtitle = ggplot2::element_text(size = 13), axis.title = ggplot2::element_text(size = 15), axis.text = ggplot2::element_text(size = 14), plot.margin = ggplot2::margin(12, 15, 12, 12), legend.position = "bottom", legend.title = ggplot2::element_blank(), legend.text = ggplot2::element_text(size = 13))
  a <- ggplot2::ggplot(data$prevalence, ggplot2::aes(prevalence, target_probability)) +
    ggplot2::geom_hline(yintercept = .8, linetype = "dashed", colour = muted, linewidth = .7) +
    ggplot2::geom_line(colour = palette[1], linewidth = 1) +
    ggplot2::geom_point(data = tibble::tibble(prevalence = .1, target_probability = 8 / 17), shape = 21, fill = "white", colour = palette[1], size = 3.5, stroke = 1) +
    ggplot2::annotate("text", x = .59, y = .75, label = "Sensitivity 0.80", hjust = 1, colour = muted, family = family, size = 4.6) +
    ggplot2::annotate("segment", x = .105, xend = .18, y = 8 / 17 - .01, yend = .30, colour = ink, linewidth = .5) +
    ggplot2::annotate("text", x = .20, y = .22, label = "80 of 170 positive flags\nper 1,000 referrals: 0.47", hjust = 0, family = family, size = 4.5, colour = ink) +
    ggplot2::scale_x_continuous(breaks = seq(0, .6, .1), labels = function(x) sprintf("%.1f", x)) +
    ggplot2::scale_y_continuous(breaks = seq(0, 1, .2), limits = c(0, 1)) +
    ggplot2::coord_cartesian(xlim = c(0, .6), expand = FALSE) +
    ggplot2::labs(title = "A. One flag, different populations", subtitle = "Sensitivity 0.80; false-positive probability 0.10", x = "Target prevalence in referrals", y = "Target probability after a positive flag") + theme
  pts <- data$case_points; pts$label <- sprintf("%.2f", pts$loss)
  b <- ggplot2::ggplot(data$losses, ggplot2::aes(q, loss, colour = action, linetype = action)) +
    ggplot2::annotate("rect", xmin = .05, xmax = .8, ymin = 0, ymax = 4, fill = "grey94", alpha = 1) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_vline(xintercept = .2, colour = muted, linetype = "longdash", linewidth = .45) +
    ggplot2::geom_vline(xintercept = 51 / 116, colour = ink, linetype = "dotdash", linewidth = .55) +
    ggplot2::geom_point(data = pts, shape = 21, fill = "white", size = 3, stroke = .9) +
    ggplot2::geom_label(data = pts, ggplot2::aes(label = label), x = 51 / 116 + .035, hjust = 0, family = family, size = 4.7, fill = "white", colour = ink, linewidth = 0, label.padding = grid::unit(.05, "lines"), show.legend = FALSE) +
    ggplot2::annotate("text", x = .035, y = 3.7, label = "Threshold\n0.20", hjust = 0, family = family, size = 4.3, colour = muted) +
    ggplot2::annotate("text", x = .45, y = 3.5, label = "New case: 51/116\n(about 0.44)", hjust = 0, family = family, size = 4.3, colour = ink) +
    ggplot2::scale_colour_manual(values = palette, breaks = actions) +
    ggplot2::scale_linetype_manual(values = stats::setNames(c("solid", "dashed", "dotted"), actions), breaks = actions) +
    ggplot2::scale_x_continuous(breaks = seq(0, 1, .2)) +
    ggplot2::scale_y_continuous(breaks = 0:4) +
    ggplot2::coord_cartesian(xlim = c(0, 1), ylim = c(0, 4), expand = FALSE) +
    ggplot2::guides(colour = ggplot2::guide_legend(ncol = 1, override.aes = list(shape = NA))) +
    ggplot2::labs(title = "B. Compare declared consequences", subtitle = "Costs: false positive 1, false negative 4\nShading: referral best for 0.05 < q < 0.80", x = "Target probability for the case", y = "Expected loss (teaching units)") + theme
  list(prevalence = a, losses = b)
}
