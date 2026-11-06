#' Compute the known-law M01 tie-rule example
#'
#' The reference probabilities are specified, not estimated. Integer counts out
#' of 100 keep cutoff comparisons exact for this particular illustration.
#' Ranks describe a comparison at a score; flagged fractions sum the masses of
#' all score categories satisfying the rank rule. They are different quantities.
#'
#' @return A list of tibbles: law (one row per score), decisions (one row per
#'   convention and score), and summary (one row per convention). Fractions are
#'   on the zero-to-one scale; columns ending in _percent are percentages.
#' @export
m01_process_data <- function() {
  law <- tibble::tibble(score = 0:3, people = c(10L, 20L, 40L, 30L)) |>
    dplyr::mutate(
      mass = .data$people / 100,
      inclusive_percent = cumsum(.data$people),
      strict_percent = .data$inclusive_percent - .data$people,
      midpoint_percent = .data$strict_percent + .data$people / 2
    )

  conventions <- c("Inclusive", "Midpoint", "Strict")
  rank_columns <- c("inclusive_percent", "midpoint_percent", "strict_percent")
  decisions <- dplyr::bind_rows(lapply(seq_along(conventions), function(i) {
    law |>
      dplyr::mutate(
        convention = conventions[[i]],
        rank_percent = .data[[rank_columns[[i]]]],
        cutoff_percent = 5,
        selected = .data$rank_percent <= .data$cutoff_percent,
        selected_mass = .data$mass * .data$selected
      ) |>
      dplyr::select(dplyr::all_of(c("convention", "score", "mass", "rank_percent",
                                  "cutoff_percent", "selected", "selected_mass")))
  }))
  summary <- decisions |>
    dplyr::group_by(.data$convention) |>
    dplyr::summarise(flagged_fraction = sum(.data$selected_mass), .groups = "drop") |>
    dplyr::mutate(convention = factor(.data$convention, levels = conventions)) |>
    dplyr::arrange(.data$convention) |>
    dplyr::mutate(convention = as.character(.data$convention)) |>
    dplyr::left_join(
      decisions |>
        dplyr::filter(.data$score == 0) |>
        dplyr::select(dplyr::all_of(c("convention", "rank_percent", "selected"))),
      by = "convention"
    )
  list(law = law, decisions = decisions, summary = summary)
}

#' Draw the three stages of the M01 tie-rule process
#'
#' @param data The unmodified output of m01_process_data().
#' @param grayscale Use dark gray for the highlighted group instead of blue.
#' @param family Font family; use Helvetica for portable base-PDF output.
#' @return Three ggplot objects in reading order. Panel coordinates are layout
#'   coordinates; probability bars have explicitly stated proportional scales.
#' @export
plot_m01_process <- function(data = m01_process_data(), grayscale = FALSE,
                             family = book_font_family()) {
  tokens <- book_tokens()
  ink <- tokens[["text_light"]]
  blue <- if (grayscale) ink else unname(book_palette(1))
  gray <- tokens[["border_light"]]
  # Labels and open/filled marks carry meaning in addition to color.
  text <- function(x, y, label, size = 5.1, bold = FALSE, hjust = 0) {
    ggplot2::annotate("text", x = x, y = y, label = label, hjust = hjust,
                      size = size, colour = ink, family = family,
                      fontface = if (bold) "bold" else "plain", lineheight = 1.1)
  }
  base <- ggplot2::ggplot() +
    ggplot2::annotate("rect", xmin = 0, xmax = 3.2, ymin = 0, ymax = 6.3,
                      fill = tokens[["surface_light"]], colour = NA) +
    ggplot2::coord_cartesian(xlim = c(0, 3.2), ylim = c(0, 6.3), expand = FALSE) +
    book_theme(base_size = 15, base_family = family) +
    ggplot2::theme_void(base_family = family) +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = "white", colour = NA),
                    plot.margin = ggplot2::margin(8, 8, 8, 8))

  law <- data$law
  rows <- data$summary |>
    dplyr::mutate(y = c(4.25, 2.85, 1.45))
  first <- base +
    text(.17, 5.82, "1  Start with the\nknown population", 5.5, TRUE) +
    text(.17, 4.94, "Score probabilities", 4.9) +
    ggplot2::geom_rect(data = law, ggplot2::aes(
      xmin = .3 + .71 * .data$score, xmax = .83 + .71 * .data$score,
      ymin = 2.5, ymax = 2.5 + 4.6 * .data$mass, fill = .data$score == 0
    ), colour = NA) +
    ggplot2::scale_fill_manual(values = c("TRUE" = blue, "FALSE" = gray), guide = "none") +
    ggplot2::geom_text(data = law, ggplot2::aes(
      x = .565 + .71 * .data$score, y = 2.67 + 4.6 * .data$mass,
      label = paste0(100 * .data$mass, "%")
    ), size = 4.9, family = family, colour = ink) +
    ggplot2::geom_text(data = law, ggplot2::aes(
      x = .565 + .71 * .data$score, y = 2.2, label = .data$score
    ), size = 5.2, family = family, colour = ink) +
    text(1.6, 1.78, "Observed score", 5, hjust = .5) +
    text(.17, .87, "Score 0 contains\n10 of every 100 people.\nTrack this same group.", 5)

  second <- base +
    text(.17, 5.82, "2  Assign a rank\nto score 0", 5.5, TRUE) +
    text(.17, 4.94, "Same tied group", 4.9) +
    ggplot2::annotate("segment", x = 1.6, xend = 1.6, y = .9, yend = 4.5,
                      colour = ink, linetype = "dashed", linewidth = .6) +
    ggplot2::geom_text(data = rows, ggplot2::aes(x = .17, y = .data$y, label = .data$convention),
                        hjust = 0, size = 5, family = family, colour = ink) +
    ggplot2::geom_segment(data = rows, ggplot2::aes(x = .4, xend = 2.8,
                                                  y = .data$y - .43, yend = .data$y - .43),
                           colour = gray, linewidth = .6) +
    ggplot2::geom_point(data = rows, ggplot2::aes(
      x = .4 + .24 * .data$rank_percent, y = .data$y - .43, shape = .data$selected
    ), size = 3.6, colour = blue) +
    ggplot2::scale_shape_manual(values = c("TRUE" = 16, "FALSE" = 1), guide = "none") +
    ggplot2::geom_label(data = rows, ggplot2::aes(
      x = .4 + .24 * .data$rank_percent, y = .data$y - .76,
      label = paste0(.data$rank_percent, "%")
    ), size = 5.1, family = family, colour = ink, fill = tokens[["surface_light"]],
      linewidth = 0, label.padding = grid::unit(.05, "lines")) +
    text(1.6, .37, "Dashed line: 5% cutoff", 4.6, hjust = .5)

  # Every outcome strip spans 100% of the population; selection is all-or-none
  # for each category. No person-level random tie breaking is performed.
  rows <- rows |>
    dplyr::mutate(
      comparison = paste0(.data$rank_percent, "% ", ifelse(.data$selected, "<=", ">"), " 5%"),
      outcome = ifelse(.data$selected, "Include all 10 people", "Exclude all 10 people"),
      result = paste0("Flagged: ", 100 * .data$flagged_fraction, "% of population")
    )
  third <- base +
    text(.17, 5.82, "3  Apply the rule;\ncount people flagged", 5.3, TRUE) +
    text(.17, 4.94, "Flag if rank <= 5%", 4.9) +
    ggplot2::geom_text(data = rows, ggplot2::aes(
      x = .17, y = .data$y + .03,
      label = paste0(.data$convention, ": ", .data$comparison)
    ), hjust = 0, size = 4.9, family = family, colour = ink, fontface = "bold") +
    ggplot2::geom_text(data = rows, ggplot2::aes(x = .17, y = .data$y - .36, label = .data$outcome),
                        hjust = 0, size = 4.9, family = family, colour = ink) +
    ggplot2::geom_rect(data = rows, ggplot2::aes(
      xmin = .17, xmax = 3.03, ymin = .data$y - .76, ymax = .data$y - .58
    ), fill = gray, colour = NA) +
    ggplot2::geom_rect(data = rows, ggplot2::aes(
      xmin = .17, xmax = .17 + 2.86 * .data$flagged_fraction,
      ymin = .data$y - .76, ymax = .data$y - .58
    ), fill = blue, colour = NA) +
    ggplot2::geom_text(data = rows, ggplot2::aes(x = .17, y = .data$y - 1.01, label = .data$result),
                        hjust = 0, size = 4.55, family = family, colour = ink) +
    text(.17, .14, "Full bar = 100% of people", 4.5)
  list(first, second, third)
}
