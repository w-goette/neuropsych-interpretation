#' Evaluate a supplied normal reference distribution
#'
#' This is a synthetic teaching calculation with known parameters. It calculates
#' the lower-tail fraction of reference peers, not a disease probability or a
#' posterior distribution for a person's ability.
#'
#' @param scores Finite numeric scores at which to evaluate the reference CDF.
#' @param mean One finite reference mean, in the same units as scores.
#' @param sd One strictly positive, finite reference standard deviation.
#' @return A tibble containing score, standardized score and lower-tail fraction.
#' @importFrom rlang .data
#' @export
normal_reference_curve <- function(scores, mean = 0, sd = 1) {
  if (!is.numeric(scores) || any(!is.finite(scores))) {
    stop("scores must be a finite numeric vector.", call. = FALSE)
  }
  if (!is.numeric(mean) || length(mean) != 1L || !is.finite(mean)) {
    stop("mean must be one finite number.", call. = FALSE)
  }
  if (!is.numeric(sd) || length(sd) != 1L || !is.finite(sd) || sd <= 0) {
    stop("sd must be one strictly positive finite number.", call. = FALSE)
  }

  # Keep the original measurement units beside the transformed score. Explicit
  # column names make the calculation visible to readers learning R.
  tibble::tibble(score = scores) |>
    dplyr::mutate(
      standardized_score = (.data$score - mean) / sd,
      lower_tail = stats::pnorm(.data$standardized_score)
    )
}

#' Plot a known reference CDF with redundant visual annotations
#'
#' @param curve A tibble from normal_reference_curve().
#' @return A ggplot object. No clinical cutoff is implied.
#' @export
plot_reference_curve <- function(curve) {
  ggplot2::ggplot(curve, ggplot2::aes(x = .data$score, y = .data$lower_tail)) +
    ggplot2::geom_line(colour = unname(book_palette(1)[[1]]), linewidth = 0.9) +
    ggplot2::labs(
      title = "A score's position in a supplied reference distribution",
      subtitle = "Synthetic known-parameter normal reference",
      x = "Score in the supplied reference units",
      y = "Fraction of reference peers at or below the score",
      caption = "The curve describes reference rarity; it is not a disease probability.",
      alt = paste(
        "An increasing S-shaped curve shows the fraction of normal reference",
        "peers at or below each score. The fraction rises from near zero at",
        "low scores to near one at high scores and equals one half at the mean.",
        "The horizontal axis is score; the vertical axis is a fraction from zero to one."
      )
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
    book_theme()
}

#' Save a reference figure and its reproducibility companions
#'
#' @param curve A tibble from normal_reference_curve().
#' @param directory Output directory inside the supplement.
#' @param stem Stable figure basename, containing letters, numbers or hyphens.
#' @return Invisibly, the ggplot object. Writes PDF, PNG, CSV and alt text.
#' @export
save_reference_figure <- function(curve, directory, stem = "reference-curve") {
  if (!is.character(stem) || length(stem) != 1L ||
      !grepl("^[A-Za-z0-9-]+$", stem)) {
    stop("stem must use letters, numbers and hyphens only.", call. = FALSE)
  }
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  plot <- plot_reference_curve(curve)
  # PNG is the HTML reading copy. The secondary PDF uses Helvetica, a
  # portable base-PDF font, rather than assuming Cairo can load on this host.
  # The returned plot and PNG retain the shared resolved HTML-oriented family.
  for (extension in c("pdf", "png")) {
    ggplot2::ggsave(
      filename = file.path(directory, paste0(stem, ".", extension)),
      plot = if (extension == "pdf") plot + ggplot2::theme(text = ggplot2::element_text(family = "Helvetica")) else plot,
      width = 7.5, height = 4.5, units = "in", dpi = 300,
      device = if (extension == "png" && requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else extension,
      bg = unname(book_tokens()[["canvas_light"]])
    )
  }
  readr::write_csv(curve, file.path(directory, paste0(stem, "-data.csv")))
  writeLines(ggplot2::get_alt_text(plot), file.path(directory, paste0(stem, "-alt.txt")))
  invisible(plot)
}
