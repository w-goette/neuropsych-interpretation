# M08 teaching calculations. Variances, Student scales and new-observation
# variances are kept separate. No function selects a clinical action.

m08_probability <- function(alpha) {
  if (length(alpha) != 1L || !is.finite(alpha) || alpha <= 0 || alpha >= 1) {
    stop("alpha must lie strictly between zero and one.", call. = FALSE)
  }
}

m08_spd <- function(x) {
  x <- as.matrix(x)
  if (nrow(x) != ncol(x) || any(!is.finite(x)) ||
      max(abs(x - t(x))) > 1e-10) stop("Matrix must be finite and symmetric.")
  tryCatch(chol(x), error = function(e) stop("Matrix must be positive definite."))
  invisible(x)
}

# Known two-occasion law: one row for every fixed first score.
m08_joint <- function(first, retest = 36, alpha = .05) {
  m08_probability(alpha)
  expected <- 52 + .8 * (first - 50)
  cutoff <- stats::qnorm(1 - alpha / 2) * sqrt(40)
  # Under a fixed first score the difference has SD 6, not sqrt(40).
  shift <- expected - first - 2
  tibble::tibble(first = first, retest = retest, expected_retest = expected,
    difference = retest - first, standardized_difference = (retest - first - 2) / sqrt(40),
    innovation = retest - expected, standardized_innovation = (retest - expected) / 6,
    marginal_rule_conditional_error = stats::pnorm((-cutoff - shift) / 6) +
      stats::pnorm((shift - cutoff) / 6), conditional_rule_error = alpha)
}

# GLS and full normal/inverse-gamma update, including fitted noise scale.
# IG(a,d) means that 1/v has Gamma(shape=a, rate=d) law.
m08_regression <- function(x, y, prior_mean, prior_factor, a0, d0,
                           correlation = diag(length(y)), alpha = .05) {
  m08_probability(alpha)
  x <- as.matrix(x); y <- as.numeric(y); p <- ncol(x); n <- nrow(x)
  if (length(y) != n || length(prior_mean) != p || n <= p ||
      qr(x)$rank != p || any(!is.finite(c(x, y, prior_mean))) ||
      !is.finite(a0) || !is.finite(d0) || a0 <= 0 || d0 <= 0) stop("Invalid full-rank regression inputs.")
  if (!identical(dim(prior_factor), c(p, p)) || !identical(dim(correlation), c(n, n))) stop("Matrix dimensions do not match.")
  m08_spd(prior_factor); m08_spd(correlation)
  precision <- solve(correlation); info <- crossprod(x, precision %*% x)
  factor <- solve(info); estimate <- drop(factor %*% crossprod(x, precision %*% y))
  residual <- y - drop(x %*% estimate)
  q <- drop(crossprod(residual, precision %*% residual)); df <- n - p
  prior_precision <- solve(prior_factor)
  posterior_factor <- solve(prior_precision + info)
  posterior_mean <- drop(posterior_factor %*% (prior_precision %*% prior_mean + crossprod(x, precision %*% y)))
  # Evaluate the nonnegative completed-square minimum without subtracting
  # large squared fitted values; this also limits cancellation error.
  e <- y - drop(x %*% posterior_mean); b <- posterior_mean - prior_mean
  d <- d0 + .5 * drop(crossprod(e, precision %*% e) + crossprod(b, prior_precision %*% b))
  a <- a0 + n / 2
  list(estimate = estimate, factor = factor, residual_quadratic = q, df = df,
    variance_estimate = q / df, posterior_mean = posterior_mean,
    posterior_factor = posterior_factor, shape = a, scale = d,
    coefficient_table = tibble::tibble(coefficient = seq_len(p), estimate = estimate,
      confidence_lower = if (q > 0) estimate - stats::qt(1 - alpha / 2, df) * sqrt(q / df * diag(factor)) else -Inf,
      confidence_upper = if (q > 0) estimate + stats::qt(1 - alpha / 2, df) * sqrt(q / df * diag(factor)) else Inf,
      posterior_mean = posterior_mean, student_df = 2 * a,
      student_scale = sqrt(d / a * diag(posterior_factor)),
      credible_lower = posterior_mean - stats::qt(1 - alpha / 2, 2 * a) * sqrt(d / a * diag(posterior_factor)),
      credible_upper = posterior_mean + stats::qt(1 - alpha / 2, 2 * a) * sqrt(d / a * diag(posterior_factor))))
}

m08_prediction <- function(fit, x0, alpha = .05) {
  m08_probability(alpha)
  if (length(x0) != length(fit$estimate) || any(!is.finite(x0))) stop("Invalid external predictor.")
  leverage <- drop(crossprod(x0, fit$factor %*% x0))
  center <- sum(x0 * fit$estimate)
  frequentist_scale <- sqrt(fit$variance_estimate * (1 + leverage))
  mean <- sum(x0 * fit$posterior_mean)
  scale <- sqrt(fit$scale / fit$shape * (1 + drop(crossprod(x0, fit$posterior_factor %*% x0))))
  tibble::tibble(fitted_mean = center, leverage = leverage,
    prediction_lower = center - stats::qt(1 - alpha / 2, fit$df) * frequentist_scale,
    prediction_upper = center + stats::qt(1 - alpha / 2, fit$df) * frequentist_scale,
    posterior_predictive_mean = mean, student_df = 2 * fit$shape, student_scale = scale,
    predictive_lower = mean - stats::qt(1 - alpha / 2, 2 * fit$shape) * scale,
    predictive_upper = mean + stats::qt(1 - alpha / 2, 2 * fit$shape) * scale)
}

# Gaussian kernel with a proper normal prior. This also allows a deficient
# design for posterior inference; it does not assert likelihood identification.
m08_normal_update <- function(design, observations, noise, mean, covariance) {
  design <- as.matrix(design)
  if (nrow(design) != length(observations) || ncol(design) != length(mean) ||
      any(!is.finite(c(design, observations, mean)))) stop("Invalid Gaussian kernel.")
  if (!identical(dim(noise), c(nrow(design), nrow(design))) ||
      !identical(dim(covariance), c(ncol(design), ncol(design)))) stop("Matrix dimensions do not match.")
  m08_spd(noise); m08_spd(covariance)
  precision <- solve(noise); prior_precision <- solve(covariance)
  v <- solve(prior_precision + crossprod(design, precision %*% design))
  list(mean = drop(v %*% (prior_precision %*% mean + crossprod(design, precision %*% observations))), covariance = v)
}

# Simultaneous direction-wise variance bands for unknown serial covariance.
# This returns analytic OUTER component bounds, not sharp inverse-region extrema.
m08_state_confidence <- function(records, alpha = .05) {
  m08_probability(alpha); records <- as.matrix(records)
  n <- nrow(records); visits <- ncol(records)
  if (n < 2 || visits < 2 || any(!is.finite(records))) stop("Need independent complete reference records.")
  centered <- sweep(records, 2, colMeans(records)); s <- crossprod(centered)
  pairs <- utils::combn(visits, 2)
  directions <- rbind(diag(visits), t(vapply(seq_len(ncol(pairs)), function(j) {
    z <- numeric(visits); z[pairs[1, j]] <- 1; z[pairs[2, j]] <- -1; z
  }, numeric(visits))))
  q <- rowSums((directions %*% s) * directions); m <- nrow(directions)
  lower <- q / stats::qchisq(1 - alpha / (2 * m), n - 1)
  upper <- q / stats::qchisq(alpha / (2 * m), n - 1)
  vu <- min(upper[seq_len(visits)]); bl <- max(lower[-seq_len(visits)]) / 2
  tibble::tibble(visits = visits, people = n, directions = m,
    common_variance_lower = max(lower[seq_len(visits)]), common_variance_upper = vu,
    noise_upper = min(upper[-seq_len(visits)]) / 2,
    stable_upper = vu - bl, trait_share_upper = 1 - bl / vu,
    necessarily_empty = bl > vu)
}

# Inclusive Clopper-Pearson endpoints; coordinate error is supplied explicitly.
m08_binomial_interval <- function(k, n, alpha = .05) {
  m08_probability(alpha)
  if (length(k) != 1L || length(n) != 1L || !is.finite(k) || !is.finite(n) ||
      n < 1 || n != as.integer(n) || k < 0 || k > n || k != as.integer(k)) stop("Invalid binomial count.")
  c(lower = if (k == 0) 0 else stats::qbeta(alpha / 2, k, n - k + 1),
    upper = if (k == n) 1 else stats::qbeta(1 - alpha / 2, k + 1, n - k))
}

# Exact finite conditional count law, evaluated with log-sum stabilization.
m08_conditional_items <- function(first, second, items = 4L, alpha = .05) {
  m08_binomial_interval(first, items, alpha); m08_binomial_interval(second, items, alpha)
  total <- first + second; support <- max(0, total - items):min(items, total)
  probability <- function(delta) {
    lw <- lchoose(items, support) + lchoose(items, total - support) + delta * support
    w <- exp(lw - max(lw)); w / sum(w)
  }
  if (length(support) == 1L) return(tibble::tibble(lower = -Inf, upper = Inf, null_p = 1))
  root <- function(tail) {
    radius <- 8
    while ((tail(-radius) - alpha / 2) * (tail(radius) - alpha / 2) > 0 && radius < 1024) radius <- radius * 2
    stats::uniroot(function(d) tail(d) - alpha / 2, c(-radius, radius), tol = 1e-11)$root
  }
  lower <- if (second == min(support)) -Inf else root(function(d) sum(probability(d)[support >= second]))
  upper <- if (second == max(support)) Inf else root(function(d) sum(probability(d)[support <= second]))
  p <- probability(0)
  tibble::tibble(lower = lower, upper = upper,
    null_p = min(1, 2 * min(sum(p[support <= second]), sum(p[support >= second]))))
}

# Deterministic Gaussian quadrature for the known-kernel two-count posterior.
# Smooth moments/predictions use two-dimensional Gauss-Hermite sums. Change
# CDF/quantiles use adaptive scalar integration over a prior-average GH sum.
m08_item_posterior <- function(sigma = 1, rho = .5, order = 32L) {
  if (!is.finite(sigma) || sigma <= 0 || !is.finite(rho) || abs(rho) >= 1 || order < 8) stop("Invalid state prior/quadrature order.")
  gh <- m06_normal_quadrature(order)
  average <- gh$nodes * sigma * sqrt((1 + rho) / 2)
  delta_sd <- sigma * sqrt(2 * (1 - rho))
  integrated_likelihood <- function(delta) vapply(delta, function(d) {
    sum(gh$weights * stats::dbinom(3, 4, stats::plogis(average - d / 2)) * stats::dbinom(1, 4, stats::plogis(average + d / 2)))
  }, numeric(1))
  density <- function(d) integrated_likelihood(d) * stats::dnorm(d, sd = delta_sd)
  integrate <- function(f, upper = Inf) stats::integrate(f, -Inf, upper, rel.tol = 1e-9, subdivisions = 300L)$value
  evidence <- integrate(density)
  cdf <- function(d) integrate(density, d) / evidence
  quantile <- function(p) stats::uniroot(function(d) cdf(d) - p, c(-12 * sigma, 12 * sigma), tol = 1e-8)$root
  grid <- tibble::as_tibble(expand.grid(average_index = seq_len(order), delta_index = seq_len(order)))
  d <- delta_sd * gh$nodes[grid$delta_index]; a <- average[grid$average_index]
  p1 <- stats::plogis(a - d / 2); p2 <- stats::plogis(a + d / 2)
  w <- gh$weights[grid$average_index] * gh$weights[grid$delta_index] * stats::dbinom(3, 4, p1) * stats::dbinom(1, 4, p2)
  negative_new <- vapply(seq_along(d), function(i) sum(stats::dbinom(0:4, 4, p1[i]) * stats::pbinom((0:4) - 1, 4, p2[i])), numeric(1))
  tibble::tibble(sigma = sigma, rho = rho, order = order, evidence = evidence,
    mean_change = integrate(function(d) d * density(d)) / evidence,
    lower = quantile(.025), upper = quantile(.975), decline_probability = cdf(0),
    expected_total_difference = sum(w * 4 * (p2 - p1)) / sum(w),
    negative_new_total_probability = sum(w * negative_new) / sum(w),
    quadrature_evidence = sum(w))
}

# Beta difference CDF: all uncertainty in both arm probabilities is integrated.
m08_beta_difference <- function(control, treated) {
  if (length(control) != 2 || length(treated) != 2 || any(!is.finite(c(control, treated))) || any(c(control, treated) <= 0)) stop("Positive beta shapes required.")
  cdf <- function(d) stats::integrate(function(x) stats::dbeta(x, control[1], control[2]) *
    stats::pbeta(pmax(0, pmin(1, x + d)), treated[1], treated[2]), 0, 1,
    rel.tol = 1e-10, subdivisions = 300L)$value
  tibble::tibble(mean_effect = treated[1] / sum(treated) - control[1] / sum(control),
    lower = stats::uniroot(function(d) cdf(d) - .025, c(-1, 1), tol = 1e-10)$root,
    upper = stats::uniroot(function(d) cdf(d) - .975, c(-1, 1), tol = 1e-10)$root,
    positive_probability = 1 - cdf(0))
}

# Conditional beta integration for the unidentified benefit fraction.
# Midpoint probability quadrature integrates learned marginals; order doubling
# is a numerical diagnostic, not an exact bound on integration error.
m08_benefit <- function(coupling = c(1, 1), order = 160L) {
  if (length(coupling) != 2 || any(!is.finite(coupling)) || any(coupling <= 0) || order < 20) stop("Invalid coupling/order.")
  u <- (seq_len(order) - .5) / order
  grid <- tibble::as_tibble(expand.grid(p0 = stats::qbeta(u, 4, 10), p1 = stats::qbeta(u, 8, 6)))
  l <- pmax(0, grid$p0 + grid$p1 - 1); upper <- pmin(grid$p0, grid$p1)
  width <- upper - l; top <- grid$p1 - l
  cdf <- function(d) mean(stats::pbeta(pmax(0, pmin(1, (top - d) / width)), coupling[1], coupling[2], lower.tail = FALSE))
  tibble::tibble(coupling_a = coupling[1], coupling_b = coupling[2], order = order,
    mean_benefit = mean(top - width * coupling[1] / sum(coupling)),
    lower = stats::uniroot(function(d) cdf(d) - .025, c(0, 1), tol = 1e-8)$root,
    upper = stats::uniroot(function(d) cdf(d) - .975, c(0, 1), tol = 1e-8)$root)
}
