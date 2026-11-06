#' Read shared HTML and plot design tokens
#'
#' Installed packages find the tokens in inst/style. Source-based runs set
#' options(neuropsychmethods.tokens = <path>) in their entry point. The CSV is
#' also compiled into Quarto SCSS by scripts/design.py; do not copy colors into
#' individual plots.
#' @param path Optional path to the shared design-tokens.csv.
#' @return A named character vector of design tokens.
#' @export
book_tokens <- function(path = getOption(
    "neuropsychmethods.tokens",
    system.file("style", "design-tokens.csv", package = "neuropsychmethods")
)) {
  if (!nzchar(path) || !file.exists(path)) {
    stop("Set options(neuropsychmethods.tokens = <design-tokens.csv path>) for source-based runs.", call. = FALSE)
  }
  tokens <- readr::read_csv(path, show_col_types = FALSE)
  if (anyDuplicated(tokens$name)) {
    stop("Design token names must be unique.", call. = FALSE)
  }
  stats::setNames(tokens$value, tokens$name)
}

#' Choose an available font consistent with the HTML fallback stack
#' @return Font family name. Record this in figure provenance.
#' @export
book_font_family <- function() {
  preferred <- unname(book_tokens()[["font_plot"]])
  if (requireNamespace("systemfonts", quietly = TRUE)) {
    available <- unique(systemfonts::system_fonts()$family)
    choices <- c(preferred, "Helvetica Neue", "Helvetica", "Liberation Sans", "DejaVu Sans")
    found <- choices[choices %in% available]
    if (length(found)) return(found[[1]])
  }
  # The graphics device resolves this generic family on the current platform.
  # It can differ from a browser's local font; record the device/environment.
  "sans"
}

#' Shared accessible categorical color choices
#' @param n Number of categories, from one to six. Also distinguish categories
#'   by labels, shape or line type; these colors alone do not prove accessibility.
#' @return Named vector of six or fewer hex colors.
#' @export
book_palette <- function(n = 6L) {
  if (length(n) != 1L || !is.numeric(n) || !is.finite(n) || n < 1 || n > 6 || n != as.integer(n)) {
    stop("n must be an integer from one to six.", call. = FALSE)
  }
  tokens <- book_tokens()
  names <- c("plot_blue", "plot_orange", "plot_teal", "plot_purple", "plot_red", "plot_slate")
  tokens[names[seq_len(n)]]
}

#' Shared HTML-first ggplot2 theme
#' @param base_size Figure text size in points; inspect at the final HTML width.
#' @param base_family Font family; defaults to a recorded available fallback.
#' @return A ggplot2 theme. Figures retain an opaque light canvas in dark HTML.
#' @export
book_theme <- function(base_size = 12, base_family = book_font_family()) {
  tokens <- book_tokens()
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = tokens[["text_light"]]),
      plot.background = ggplot2::element_rect(fill = tokens[["canvas_light"]], colour = NA),
      panel.background = ggplot2::element_rect(fill = tokens[["canvas_light"]], colour = NA),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = tokens[["border_light"]], linewidth = 0.3),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.caption = ggplot2::element_text(hjust = 0, colour = tokens[["muted_light"]]),
      legend.position = "bottom"
    )
}
