# Two-stage process: one coupled mean/SD region -> all-score CDF envelopes.
# Same source data, fixed allocation and candidate identities in both panels.
m13_figure_data <- function() {
  region <- m13_joint_region(m02_posterior(20, 50, 10))
  lower <- region$sd_lower; upper <- region$sd_upper; k <- region$coefficient
  candidates <- tibble::tibble(candidate = c("1  Lower SD", "2  Upper SD"), id = c("1", "2"), mean = 50 + k * c(lower, upper), sd = c(lower, upper))
  polygon <- tibble::tibble(mean = 50 + c(-k * lower, k * lower, k * upper, -k * upper), sd = c(lower, lower, upper, upper))
  scores <- seq(20, 80, by = .1)
  band <- m13_envelope(scores, region)
  curves <- dplyr::bind_rows(lapply(seq_len(nrow(candidates)), function(i) tibble::tibble(score = scores, fraction = stats::pnorm((scores - candidates$mean[i]) / candidates$sd[i]), candidate = candidates$candidate[i])))
  anchors <- m13_envelope(c(35, 50, 65), region)
  list(region = region, polygon = polygon, candidates = candidates, band = band, curves = curves, anchors = anchors)
}
plot_m13_region <- function(data = m13_figure_data(), gray = FALSE, family = book_font_family()) {
  tokens <- book_tokens(); ink <- tokens[["text_light"]]; muted <- tokens[["muted_light"]]
  blue <- if (gray) grDevices::gray(.35) else unname(book_palette(1))
  color <- if (gray) c(grDevices::gray(.15), grDevices::gray(.5)) else unname(book_palette(4)[c(2, 4)])
  keys <- c("1  Lower SD", "2  Upper SD"); names(color) <- keys
  rgb <- as.numeric(grDevices::col2rgb(blue)) / 255 * .13 + .87; pale <- grDevices::rgb(rgb[1], rgb[2], rgb[3])
  shape <- stats::setNames(c(21, 24), keys); lty <- stats::setNames(c("dashed", "dotdash"), keys)
  theme <- book_theme(21, family) + ggplot2::theme(plot.title = ggplot2::element_text(size = 23, face = "bold"), plot.subtitle = ggplot2::element_text(size = 16), axis.title = ggplot2::element_text(size = 20), axis.text = ggplot2::element_text(size = 18), legend.position = "bottom", legend.title = ggplot2::element_blank(), legend.text = ggplot2::element_text(size = 18), plot.margin = ggplot2::margin(12, 16, 12, 12))
  a <- ggplot2::ggplot(data$polygon, ggplot2::aes(mean, sd)) +
    ggplot2::geom_polygon(fill = pale, colour = blue, linewidth = .9) +
    ggplot2::geom_vline(xintercept = 50, colour = muted, linetype = "dotted", linewidth = .45) +
    ggplot2::geom_point(data = data$candidates, ggplot2::aes(colour = candidate, shape = candidate), fill = "white", size = 4.2, stroke = 1.2) +
    ggplot2::geom_text(data = data$candidates, ggplot2::aes(label = id), colour = ink, vjust = -1.4, family = family, size = 6) +
    ggplot2::scale_colour_manual(values = color, breaks = keys) + ggplot2::scale_shape_manual(values = shape, breaks = keys) +
    ggplot2::scale_x_continuous(breaks = c(40, 50, 60)) + ggplot2::scale_y_continuous(breaks = c(8, 12, 16)) +
    ggplot2::coord_cartesian(xlim = c(40, 60), ylim = c(6, 18), expand = FALSE) +
    ggplot2::guides(colour = ggplot2::guide_legend(ncol = 1)) +
    ggplot2::labs(title = "1. Keep mean and SD coupled", subtitle = "20 synthetic peers: mean 50, SD 10\nFixed .95 joint-region construction", x = "Candidate mean", y = "SD (score units)") + theme
  points <- dplyr::bind_rows(tibble::tibble(score = 35, fraction = data$anchors$lower[1], candidate = keys[1], id = "1"), tibble::tibble(score = 65, fraction = data$anchors$lower[3], candidate = keys[2], id = "2"))
  b <- ggplot2::ggplot(data$band, ggplot2::aes(score)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lower, ymax = upper), fill = pale) +
    ggplot2::geom_line(ggplot2::aes(y = lower), colour = blue, linewidth = .7) +
    ggplot2::geom_line(ggplot2::aes(y = upper), colour = blue, linewidth = .7) +
    ggplot2::geom_vline(xintercept = 50, colour = muted, linetype = "dotted", linewidth = .45) +
    ggplot2::geom_line(data = data$curves, ggplot2::aes(y = fraction, colour = candidate, linetype = candidate), linewidth = 1) +
    ggplot2::geom_point(data = points, ggplot2::aes(y = fraction, colour = candidate, shape = candidate), fill = "white", size = 4.2, stroke = 1.2, show.legend = FALSE) +
    ggplot2::geom_text(data = points, ggplot2::aes(y = fraction, label = id), vjust = -1.3, colour = ink, family = family, size = 6) +
    ggplot2::scale_colour_manual(values = color, breaks = keys) + ggplot2::scale_linetype_manual(values = lty, breaks = keys) + ggplot2::scale_shape_manual(values = shape, breaks = keys) +
    ggplot2::scale_x_continuous(breaks = c(20, 35, 50, 65, 80)) + ggplot2::scale_y_continuous(limits = c(0, 1), breaks = c(0, .5, 1)) +
    ggplot2::coord_cartesian(xlim = c(20, 80), ylim = c(-.04, 1.04), expand = FALSE) +
    ggplot2::guides(colour = ggplot2::guide_legend(ncol = 1)) +
    ggplot2::labs(title = "2. Take scorewise extremes", subtitle = "Same candidates; shaded full CDF band\nCandidate 1 is lower left of 50; 2 right", x = "Observed score", y = "CDF fraction") + theme
  list(region = a, envelope = b)
}
