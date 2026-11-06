\name{m07-norms}
\alias{m07_cp}
\alias{m07_anchor}
\alias{m07_selection}
\alias{m07_regression}
\alias{m07_shape_posterior}
\alias{m07_noisy}
\title{Synthetic norm, selection and link experiments for M07}
\description{Source-based teaching functions for the experiments and explicit priors in the M07 chapter. Not patient scoring or clinical validation.}
\usage{
m07_cp(k, n, alpha = .05)
m07_anchor(lambda = 2, Gamma = 0)
m07_selection(counts = c(6,12,9,3), weights = c(.25,.5,1,1), alpha = .05)
m07_regression()
m07_shape_posterior(prior_shape = 1, nodes = 96)
m07_noisy(n_points = 262144, shift = 1, source_error_scale = .6, case_update = TRUE)
}
\arguments{
\item{k, n}{Binomial success counts and positive sample size.}
\item{alpha}{Total procedure error probability.}
\item{lambda, Gamma}{Known nonzero anchor loading and allowed direct-offset bound.}
\item{counts, weights}{Selected category counts and known positive inclusion probabilities.}
\item{prior_shape, nodes}{Positive symmetric Dirichlet shape and Gauss-Legendre integration order.}
\item{n_points, shift}{Deterministic integration size and fixed shift 1 or 2.}
\item{source_error_scale}{Inverse-gamma prior scale for source-error variance; not an SD.}
\item{case_update}{Include case readings in parameter weights; FALSE is a declared comparator.}
}
\value{A tibble of synthetic summaries, or a list containing fitted probabilities, confidence bounds and vertices.}
\details{See inst/examples/M07_GUIDE.md for all 27 output dictionaries, priors, conditioning, numerical tolerances and limitations. Noisy inference uses coupled physical constraints; scalar posterior integrals are not normal approximations.}
