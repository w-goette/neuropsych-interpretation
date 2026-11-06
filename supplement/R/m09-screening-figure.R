# Migrate the known-law screening figure; no new model or simulation.
m09_figure_data <- function() {
  law <- m09_screening(); c <- law$scatter_cutoff[1]; r <- sqrt(law$radius_squared_cutoff[1]); lim <- 3.6
  circle <- tibble::tibble(angle = seq(0, 2 * pi, length.out = 721), x = r * cos(angle), y = r * sin(angle), boundary = "Radius boundary")
  bands <- dplyr::bind_rows(lapply(c(-1, 1), function(sign) tibble::tibble(x = c(-lim, lim), y = c(-lim, lim) + sign * sqrt(2 * c), boundary = "Scatter boundaries", side = sign)))
  hatches <- dplyr::bind_rows(lapply(seq(-lim, lim, .35), function(offset) {
    lo <- max(-lim, -lim - offset); hi <- min(0, -offset)
    tibble::tibble(x = lo, xend = hi, y = lo + offset, yend = hi + offset)
  }))
  boxes <- tibble::tibble(xmin = c(1.1, 1.1, .4, 5.6, .5), xmax = c(8.9, 8.9, 4.4, 9.6, 9.5),
    ymin = c(9.4, 7, 4.2, 4.2, 1.1), ymax = c(11, 8.6, 6.2, 6.2, 3.5),
    label = c("1. Record tests 1 and 2\nfor everyone", "2. Are both recorded\nscores negative?",
      "Yes: stop\nretain tests 1 and 2\nStop pattern: 1/4", "No: give test 3\nretain all three tests",
      "3. Compare retained scores\namong stopped records\nMissing Y3 is still standard normal,\ngiven recorded scores and pattern"), kind = c("record", "rule", "stop", "continue", "comparison"))
  boxes <- dplyr::mutate(boxes, x = (xmin + xmax) / 2, y = (ymin + ymax) / 2)
  arrows <- tibble::tibble(x = c(5, 4, 6, 2.4), y = c(9.4, 7, 7, 4.2), xend = c(5, 2.4, 7.6, 5), yend = c(8.6, 6.2, 6.2, 3.5))
  readout <- dplyr::mutate(law,
    label = c("Expected scatter\n(squared standard units)", "Scatter upper-tail rule\n(probability flagged)", "Radius upper-tail rule\n(probability flagged)"),
    y = c(3, 1.9, .8),
    fixed_label = c(formatC(fixed_pair[1], digits = 0, format = "f"), sprintf("%.2f%%", 100 * fixed_pair[2:3])),
    selected_label = c(formatC(selected_negative_pair[1], digits = 3, format = "f"), sprintf("%.2f%%", 100 * selected_negative_pair[2:3])))
  list(law = law, circle = circle, bands = bands, hatches = hatches, boxes = boxes, arrows = arrows, readout = readout)
}

m09_tint <- function(colour, white, amount = .90) {
  x <- grDevices::col2rgb(colour); w <- grDevices::col2rgb(white)
  grDevices::rgb((x[1] * (1 - amount) + w[1] * amount) / 255,
    (x[2] * (1 - amount) + w[2] * amount) / 255, (x[3] * (1 - amount) + w[3] * amount) / 255)
}

plot_m09_screening <- function(data = m09_figure_data(), gray = FALSE, family = book_font_family()) {
  token <- book_tokens(); palette <- if (gray) c(grDevices::gray(.15), grDevices::gray(.40)) else unname(book_palette(2))
  white <- token[["canvas_light"]]; text <- token[["text_light"]]; pale <- m09_tint(palette[1], white)
  theme <- book_theme(14, family) + ggplot2::theme(plot.title = ggplot2::element_text(size = 15, face = "bold"),
    plot.margin = ggplot2::margin(12, 12, 12, 12), legend.text = ggplot2::element_text(size = 12))
  flow <- ggplot2::ggplot() +
    ggplot2::geom_rect(data = data$boxes, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = white, colour = palette[1], linewidth = .6) +
    ggplot2::geom_rect(data = dplyr::filter(data$boxes, kind %in% c("rule", "stop")), ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = pale, colour = palette[1], linewidth = .9) +
    ggplot2::geom_text(data = data$boxes, ggplot2::aes(x = x, y = y, label = label), size = 5.2, lineheight = 1, family = family, colour = text) +
    ggplot2::geom_segment(data = data$arrows, ggplot2::aes(x = x, y = y, xend = xend, yend = yend), colour = palette[1], linewidth = .6, arrow = grid::arrow(length = grid::unit(.12, "inches"), type = "closed")) +
    ggplot2::coord_cartesian(xlim = c(0, 10), ylim = c(.5, 11.5), expand = FALSE) +
    ggplot2::labs(title = "A. How the record is selected") + theme + ggplot2::theme_void(base_family = family) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 15, face = "bold", colour = text), plot.margin = ggplot2::margin(12, 12, 12, 12), plot.background = ggplot2::element_rect(fill = white, colour = NA))
  plane <- ggplot2::ggplot() +
    ggplot2::annotate("rect", xmin = -3.6, xmax = 0, ymin = -3.6, ymax = 0, fill = pale) +
    ggplot2::geom_segment(data = data$hatches, ggplot2::aes(x = x, xend = xend, y = y, yend = yend), colour = palette[1], linewidth = .25) +
    ggplot2::geom_hline(yintercept = 0, colour = token[["muted_light"]], linewidth = .3) +
    ggplot2::geom_vline(xintercept = 0, colour = token[["muted_light"]], linewidth = .3) +
    ggplot2::geom_path(data = data$bands, ggplot2::aes(x = x, y = y, group = side, colour = boundary, linetype = boundary), linewidth = .7) +
    ggplot2::geom_path(data = data$circle, ggplot2::aes(x = x, y = y, colour = boundary, linetype = boundary), linewidth = .8) +
    ggplot2::annotate("label", x = -2.05, y = -2.8, label = "Stopped\nrecords", size = 4.8, family = family, colour = text, fill = white, linewidth = 0) +
    ggplot2::scale_colour_manual(values = stats::setNames(palette, c("Scatter boundaries", "Radius boundary")), name = NULL) +
    ggplot2::scale_linetype_manual(values = c("Scatter boundaries" = "dashed", "Radius boundary" = "dotted"), name = NULL) +
    ggplot2::coord_fixed(xlim = c(-3.6, 3.6), ylim = c(-3.6, 3.6), expand = FALSE) +
    ggplot2::labs(title = "B. Compare within the selected pattern", x = "First score Y1 (standard units)", y = "Second score Y2 (standard units)") + theme +
    ggplot2::theme(panel.grid.major = ggplot2::element_blank(), legend.position = "bottom") +
    ggplot2::guides(colour = ggplot2::guide_legend(nrow = 2, byrow = TRUE), linetype = ggplot2::guide_legend(nrow = 2, byrow = TRUE))
  readout <- ggplot2::ggplot(data$readout) +
    ggplot2::geom_text(ggplot2::aes(x = .1, y = y, label = label), hjust = 0, size = 5.2, lineheight = 1.05, family = family, colour = text) +
    ggplot2::geom_text(ggplot2::aes(x = 4.25, y = y, label = fixed_label), size = 5.8, family = family, colour = text) +
    ggplot2::geom_text(ggplot2::aes(x = 6.8, y = y, label = selected_label), size = 5.8, family = family, colour = palette[1]) +
    ggplot2::annotate("text", x = c(4.25, 6.8), y = 4, label = c("Fixed pair", "Stopped pair"), size = 5, family = family, fontface = "bold", colour = text) +
    ggplot2::coord_cartesian(xlim = c(0, 8), ylim = c(.25, 4.3), expand = FALSE) +
    ggplot2::labs(title = "C. Different quantities, different units") + ggplot2::theme_void(base_family = family) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 15, face = "bold", colour = text), plot.margin = ggplot2::margin(12, 12, 12, 12), plot.background = ggplot2::element_rect(fill = white, colour = NA))
  list(flow = flow, plane = plane, readout = readout)
}
