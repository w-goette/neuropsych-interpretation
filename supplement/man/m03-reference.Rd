\name{m03-reference}
\alias{m03_inputs}
\alias{m03_linear}
\alias{m03_conditional}
\alias{m03_bvn}
\alias{m03_count2}
\alias{m03_family2}
\alias{m03_family_level}
\alias{m03_vector_predict}
\alias{m03_niw}
\alias{m03_student_count2}
\alias{m03_content_outer}
\alias{m03_weighted_tail}
\alias{m03_example_results}
\title{Synthetic correlated-battery reference comparisons}
\description{Source-based helpers for the known-law, finite-norm, named-family, fitted-count and changed-metric examples in M03. No patient data or diagnostic rule.}
\details{Source R/m03-correlated-battery.R, then call m03_example_results(). It returns eleven named tibbles, with probabilities on the zero-to-one scale and separate conditioning, predictive and content targets. Read inst/examples/M03_GUIDE.md for each function's arguments, input dimensions, sample/rank domains, prior parameters, output columns and numerical limits. Quadrature error estimates are numerical estimates, not certified uncertainty bounds. No optimized confidence extrema or posterior content quantiles are computed.}
\value{m03_example_results returns a named list of eleven tibbles. m03_inputs supplies the fixed teaching inputs. The other helpers return declared reference summaries, probabilities or prior/posterior parameters documented in the guide and source.}
\examples{\dontrun{source("supplement/R/m03-correlated-battery.R")
results <- m03_example_results()
results$linear}}
