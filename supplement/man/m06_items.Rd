\name{m06_items}
\alias{m06_items}\alias{m06_law}\alias{m06_total}\alias{m06_information}\alias{m06_posterior}\alias{m06_confidence}\alias{m06_prediction}\alias{m06_calibration}
\title{Synthetic fixed-battery and noisy-anchor calculations for M06}
\description{Source-based teaching helpers for exact finite response laws,known-item person inference,category coarsening and numerical noisy-anchor posterior integration.}
\details{Source R/m06-items.R and follow inst/examples/M06_GUIDE.md. Inputs,units,priors,positive-support assumptions,infinite MLE boundaries and numerical limitations are explicit in the guide and chapter. Calibration uses deterministic shifted Halton integration and normal quadrature,not a fitted-normal posterior or a clinical scoring algorithm. No project package installation is required.}
\value{Functions return tibbles or named lists of summaries,densities and numerical diagnostics.}
