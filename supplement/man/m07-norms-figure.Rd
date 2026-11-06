\name{m07_figure_data}
\alias{m07_figure_data}
\alias{plot_m07_norms}
\title{Synthetic reference and calibration panels for M07}
\description{Recreates supplied reference densities and exact response/calibration lines. Source-based helpers; no patient data or estimation.}
\usage{m07_figure_data()
plot_m07_norms(input = m07_figure_data(), grayscale = FALSE, family = book_font_family())}
\arguments{\item{input}{List of density, measurement and probability tables from m07_figure_data.}\item{grayscale}{Use redundant monochrome line encodings.}\item{family}{Font family available on this system.}}
\value{A list of synthetic data tables, or a list of five ggplot objects.}
