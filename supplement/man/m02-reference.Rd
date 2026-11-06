\name{m02-reference}
\alias{m02_posterior}
\alias{m02_predict}
\alias{m02_percentile}
\alias{m02_percentile_cdf}
\alias{m02_quantile}
\alias{m02_scale}
\alias{m02_cutoffs}
\alias{m02_content_cdf}
\alias{m02_content_quantile}
\alias{m02_content_density}
\alias{m02_sd_moment}
\alias{m02_regression}
\title{Synthetic finite-reference normal-model calculations for M02}
\description{Source-based deterministic teaching helpers. See inst/examples/M02_GUIDE.md for arguments, units, experiments, data dictionaries and worked calls. No clinical diagnostic model is implemented.}
\details{The inverse-gamma exponent is -b/v. Integrals and root equations are evaluated numerically. Positive-leverage percentile calculations exclude x0=0, which needs a variance-only transformation. Reference-prior agreement is target-specific; proper priors do not inherit fixed-parameter coverage.}
\value{Posterior parameter lists, predictive summaries, or numerical probability/score quantiles depending on the function.}
