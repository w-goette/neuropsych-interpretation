# Data and plots for the finite definition illustration, not a clinical model.
m00_replication_figure_data <- function(result = m00_evaluate_replication(m00_replication_law())) {
  inputs <- dplyr::transmute(result$law, universe = .data$universe,
    role = "Possible repeats", row = 3, score = .data$score, probability = .data$probability)
  expected <- dplyr::transmute(result$summary, universe = .data$universe,
    role = "Expected score", row = 2, score = .data$expected_score, probability = NA_real_)
  observed <- dplyr::transmute(result$summary, universe = .data$universe,
    role = "Observed score", row = 1, score = .data$observed_score, probability = NA_real_)
  dplyr::mutate(dplyr::bind_rows(inputs, expected, observed), label = format(.data$score, trim = TRUE))
}

plot_m00_replication <- function(data = m00_replication_figure_data(), grayscale = FALSE,
                                 family = book_font_family()) {
  required <- c("universe", "role", "row", "score", "probability", "label")
  if (!is.data.frame(data) || !all(required %in% names(data)) ||
      !setequal(unique(data$universe), c("Universe 1", "Universe 2"))) {
    stop("This figure requires the two named supplied repeat universes.", call. = FALSE)
  }
  possible <- data[data$role == "Possible repeats", , drop = FALSE]
  counts <- table(factor(possible$universe, levels = c("Universe 1", "Universe 2")))
  if (any(counts != 3L) || anyNA(possible$probability) ||
      any(!is.finite(possible$probability)) || any(abs(possible$probability - 1/3) > 1e-12)) {
    stop("This figure labels exactly three possible repeats, each with probability 1/3.", call. = FALSE)
  }
  roles <- c("Possible repeats", "Expected score", "Observed score")
  colors <- if (grayscale) stats::setNames(rep(unname(book_tokens()[["text_light"]]), 3), roles) else
    stats::setNames(unname(book_palette(3)), roles)
  shapes <- stats::setNames(c(16, 18, 17), roles)
  lapply(c("Universe 1", "Universe 2"), function(universe) {
    panel <- dplyr::filter(data, .data$universe == .env$universe)
    expected <- panel$score[panel$role == "Expected score"]
    observed <- panel$score[panel$role == "Observed score"]
    ggplot2::ggplot(panel, ggplot2::aes(x = .data$score, y = .data$row,
                                      shape = .data$role, color = .data$role)) +
      ggplot2::geom_point(size = 4) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label), vjust = -1.1,
                         size = 5.2, family = family, show.legend = FALSE) +
      ggplot2::scale_color_manual(values = colors) +
      ggplot2::scale_shape_manual(values = shapes) +
      ggplot2::scale_x_continuous(limits = c(30, 43), breaks = c(32, 35, 38, 41)) +
      ggplot2::scale_y_continuous(limits = c(.6, 3.6), breaks = 1:3,
        labels = c("3. Observed score", "2. Expected score", "1. Possible repeats\n(each probability 1/3)"),
        expand = ggplot2::expansion(mult = 0)) +
      ggplot2::labs(title = universe, subtitle = "A supplied repeat law for one fixed person",
        x = "Score units", y = NULL,
        caption = paste0("Observed residual: ", observed, " - ", expected, " = ", observed - expected,
                         " score units")) +
      book_theme(base_size = 16, base_family = family) +
      ggplot2::theme(legend.position = "none", panel.grid.major.y = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(size = 18, face = "bold"),
        axis.text.y = ggplot2::element_text(size = 15),
        plot.caption = ggplot2::element_text(size = 13.5),
        plot.margin = ggplot2::margin(12, 16, 12, 8))
  })
}
