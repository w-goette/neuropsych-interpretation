\name{m13_tables}
\alias{m13_tables}
\alias{m13_joint_region}
\alias{m13_envelope}
\alias{m13_range_summary}
\alias{m13_error_summary}
\alias{m13_discrete}
\alias{m13_discrete_refitting}
\alias{m13_shape_fit}
\alias{m13_shape_summary}
\alias{m13_order_benchmark}
\alias{m13_transformed_regression}
\title{Synthetic reference-curve and fitted-scale examples}
\usage{m13_tables(nodes = 64L)}
\arguments{\item{nodes}{Number of finite Gaussian quadrature nodes for the declared compact shape mixture.}}
\description{Source-based teaching calculations for whole-curve normal regions, fixed-range population fractions, maximum fitted-CDF error, ordered finite supports and fitted sinh transformations. Source m02-finite-reference.R before this module.}
\value{A named list of sixteen tidy tables. The entry point writes CSVs; M13_GUIDE.md and M13_COLUMNS.csv explain every target, column and numerical limitation.}
\details{Reference-only confidence, posterior uncertainty at the frozen fit, repeated fitted-table content and new-person prediction have different conditioning. Shape weights retain the full raw-data Jacobian. Numerical roots and quadratures do not establish proofs, clinical usefulness or exact global confidence projections over shapes. Examples use no patient data and are not clinical scoring rules.}
