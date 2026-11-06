\name{m04-level-shape}
\alias{m04_geometry}
\alias{m04_quadratic_moments}
\alias{m04_quadratic_correlation}
\alias{m04_sd_correlation}
\alias{m04_shape_confidence}
\alias{m04_correlation_cdf}
\alias{m04_paired_summary}
\alias{m04_power}
\alias{m04_training_average}
\alias{m04_training_posterior}
\alias{m04_example_results}
\title{Synthetic M04 level, shape and information experiments}
\description{Source-based observed-score teaching calculations, with distinct known-reference, paired-occasion, finite-norm and class-training experiments. No clinical diagnostic model is supplied.}
\details{See inst/examples/M04_GUIDE.md for every output, input and parameter domain. Geometry requires a positive-definite reference covariance and nonzero fixed direction. Paired inference requires known zero contrast means; the worked intervals are 95 percent. Power is the two-dimensional fixed-procedure example with n>2 or Inf. The angular training helper requires positive finite dstar and integer group sizes at least two, with dstar/sqrt(1/n0+1/n1)<=8. Shape confidence inversion can return an empty set; no clamping at zero. All integral tolerances are explicit in the source. The unrestricted paired posterior pushforward and globally optimized region-image bounds are not evaluated by these helpers.}
\value{Tibbles for geometry, moments, confidence bounds, paired summaries, power or training results; scalar numeric correlations/CDFs; m04_example_results returns 13 named tibbles. See the guide for units, priors and NA/Inf conventions.}
\examples{R <- matrix(c(1,.6,.6,1),2)
m04_geometry(c(-1.5,0), R)
m04_sd_correlation(.75)
}
