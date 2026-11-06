# Figure data evaluate the supplied joint law and conditional slices.
m03_figure_data <- function() {
  law <- m03_inputs()
  theta <- seq(0, 2 * pi, length.out = 400)
  lower <- t(chol(law$covariance))
  ellipses <- dplyr::bind_rows(lapply(c(.5, .95), function(level) {
    xy <- 50 + sqrt(stats::qchisq(level, 2)) * lower %*% rbind(cos(theta), sin(theta))
    tibble::tibble(level = level, angle = theta, score2 = xy[1, ], score1 = xy[2, ])
  }))
  # Keep the original 900 points, adding the exact observed score as a boundary.
  grid <- sort(unique(c(seq(8, 85, length.out = 900), 35)))
  densities <- dplyr::bind_rows(lapply(c(50, 35), function(conditioning_score) {
    center <- 50 + .6 * (conditioning_score - 50)
    tibble::tibble(conditioning_score = conditioning_score, score1 = grid,
                  conditional_density = stats::dnorm(grid, center, 8),
                  marginal_density = stats::dnorm(grid, 50, 10))
  }))
  summaries <- tibble::tibble(conditioning_score = c(50, 35), conditional_mean = c(50, 41),
    conditional_sd = c(8, 8), observed_score1 = c(35, 35),
    conditional_tail = stats::pnorm((35 - c(50, 41)) / 8), marginal_tail = stats::pnorm(-1.5),
    omitted_conditional_lower_mass = stats::pnorm((8 - c(50, 41)) / 8),
    omitted_conditional_upper_mass = stats::pnorm((c(50, 41) - 85) / 8),
    omitted_marginal_lower_mass = stats::pnorm((8 - 50) / 10),
    omitted_marginal_upper_mass = stats::pnorm((50 - 85) / 10))
  slices <- tibble::tibble(score2 = c(50, 35), center = c(50, 41), low = c(34, 25), high = c(66, 57))
  profiles <- tibble::tibble(profile = c("A", "B"), score2 = c(50, 35), score1 = c(35, 35))
  list(ellipses = ellipses, densities = densities, summaries = summaries, slices = slices, profiles = profiles)
}

plot_m03_conditional <- function(input, grayscale = FALSE, family = book_font_family()) {
  tokens <- book_tokens()
  main <- if (grayscale) unname(tokens[["text_light"]]) else unname(book_palette(1)[[1]])
  neutral <- unname(tokens[["muted_light"]])
  blend <- .8 * grDevices::col2rgb(tokens[["canvas_light"]]) + .2 * grDevices::col2rgb(main)
  shade <- grDevices::rgb(blend[1]/255, blend[2]/255, blend[3]/255)
  slice_rgb <- .2 * grDevices::col2rgb(tokens[["canvas_light"]]) + .8 * grDevices::col2rgb(neutral)
  slice_colour <- grDevices::rgb(slice_rgb[1]/255, slice_rgb[2]/255, slice_rgb[3]/255)
  theme <- book_theme(base_size = 12, base_family = family) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 13, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 11), plot.caption = ggplot2::element_text(size = 11, hjust = 0),
      axis.text = ggplot2::element_text(size = 10.5), axis.title = ggplot2::element_text(size = 11),
      legend.text = ggplot2::element_text(size = 10), legend.title = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(8, 9, 8, 8))
  regression <- tibble::tibble(score2 = seq(22, 78, length.out = 10))
  regression$score1 <- 50 + .6 * (regression$score2 - 50)
  joint <- ggplot2::ggplot() +
    ggplot2::geom_path(data = input$ellipses,
      ggplot2::aes(x = score2, y = score1, group = level, linetype = factor(level)), colour = neutral, linewidth = .6) +
    ggplot2::scale_linetype_manual(values = c("dotted", "solid"), labels = c("50% region", "95% region")) +
    ggplot2::geom_line(data = regression, ggplot2::aes(score2, score1), colour = main, linewidth = .8) +
    ggplot2::geom_segment(data = input$slices, ggplot2::aes(x = score2, xend = score2, y = low, yend = high), colour = slice_colour, linewidth = 2.2) +
    ggplot2::geom_point(data = input$profiles, ggplot2::aes(score2, score1, shape = profile), colour = main, size = 2.6) +
    ggplot2::scale_shape_manual(values = c(A = 16, B = 0), guide = "none") +
    ggplot2::annotate("text", x = c(58, 28), y = c(23, 23), label = c("A: (35, 50)", "B: (35, 35)"), size = 3.2, family = family, colour = tokens[["text_light"]]) +
    ggplot2::scale_x_continuous(limits = c(20, 80), breaks = seq(20, 80, 20)) +
    ggplot2::scale_y_continuous(limits = c(20, 80), breaks = seq(20, 80, 20)) +
    ggplot2::coord_fixed() +
    ggplot2::labs(title = "1. Choose the peer slice", subtitle = "Same first score; different second score",
      x = "Score 2 (conditioning)", y = "Score 1 (target)",
      caption = "Vertical bars: slice mean +/- 2 SD\nLine: conditional mean; slice SD = 8") + theme
  panels <- list(joint)
  for (i in 1:2) {
    row <- input$summaries[i, ]
    data <- dplyr::filter(input$densities, conditioning_score == row$conditioning_score)
    shaded <- dplyr::filter(data, score1 <= 35)
    panels[[i + 1]] <- ggplot2::ggplot(data, ggplot2::aes(x = score1)) +
      ggplot2::geom_ribbon(data = shaded, ggplot2::aes(ymin = 0, ymax = conditional_density),
                           stat = "identity", position = "identity", fill = shade) +
      ggplot2::geom_line(ggplot2::aes(y = marginal_density, linetype = "All peers"), colour = neutral, linewidth = .65) +
      ggplot2::geom_line(ggplot2::aes(y = conditional_density, linetype = "Same score 2"), colour = main, linewidth = .85) +
      ggplot2::geom_vline(xintercept = 35, linetype = "dotted", colour = neutral, linewidth = .6) +
      ggplot2::scale_linetype_manual(values = c("All peers" = "longdash", "Same score 2" = "solid")) +
      ggplot2::scale_x_continuous(limits = c(8, 85), breaks = c(10, 35, 50, 65, 80), expand = ggplot2::expansion(mult = c(0, .01))) +
      ggplot2::scale_y_continuous(limits = c(0, .06), breaks = c(0, .02, .04, .06), expand = ggplot2::expansion(mult = c(0, .02))) +
      ggplot2::labs(title = paste0(i + 1, ". Given score 2 = ", row$conditioning_score),
        subtitle = paste0("Conditional mean ", row$conditional_mean, "; SD 8"),
        x = "Score 1", y = "Reference density",
        caption = sprintf("At or below 35: %.2f%% of slice peers\nAll peers: %.2f%% (dashed)",
                          100 * row$conditional_tail, 100 * row$marginal_tail)) + theme
  }
  panels
}
