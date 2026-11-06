\name{m04-level-shape-figure}
\alias{m04_figure_data}
\alias{plot_m04_level_shape}
\title{Observed level-shape geometry and stipulated population mean shifts}
\description{Plot the synthetic teaching law in four ggplot2 panels, including grayscale alternatives.}
\usage{m04_figure_data()
plot_m04_level_shape(input, grayscale = FALSE, family = book_font_family())}
\arguments{\item{input}{Named plotting-data list returned by m04_figure_data.}\item{grayscale}{Logical; retain redundant line and point encodings.}\item{family}{Resolved plot font family, recorded separately for the vector fallback.}}
\value{A named list of plotting tibbles, or a list of four ggplot objects.}
\details{See inst/figures/m04-level-shape/README.md. The four panels preserve a fixed observed reference covariance, projection endpoints and stipulated shifts. The ellipse is a population region, not a power or diagnostic-accuracy curve.}
