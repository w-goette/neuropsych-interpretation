# Synthetic M03 comparisons. These functions describe observed reference scores,
# not latent ability, a person's retest distribution, or diagnostic probability.

m03_matrix <- function(x, p, positive = TRUE) {
  if (!is.matrix(x) || !identical(dim(x), c(as.integer(p), as.integer(p))) ||
      any(!is.finite(x)) || !isTRUE(all.equal(x, t(x), tolerance = 1e-12))) {
    stop("Supply a finite symmetric matrix with the stated dimensions.", call. = FALSE)
  }
  eigenvalues <- eigen(x, symmetric = TRUE, only.values = TRUE)$values
  if ((positive && min(eigenvalues) <= 0) || (!positive && min(eigenvalues) < -1e-10)) {
    stop("Matrix does not satisfy the required positivity condition.", call. = FALSE)
  }
  invisible(x)
}

m03_inputs <- function() {
  list(mean = c(50, 50), covariance = matrix(c(100, 60, 60, 100), 2),
       profiles = rbind(A = c(35, 50), B = c(35, 35)), cutoff = c(40, 40), n = 20L)
}

m03_linear <- function(y, weights, mean, covariance) {
  p <- length(mean)
  m03_matrix(covariance, p)
  if (length(y) != p || length(weights) != p || any(!is.finite(c(y, weights, mean))) || all(weights == 0)) {
    stop("Use matching finite vectors and nonzero fixed weights.", call. = FALSE)
  }
  value <- sum(weights * y)
  center <- sum(weights * mean)
  variance <- as.numeric(crossprod(weights, covariance %*% weights))
  z <- (value - center) / sqrt(variance)
  tibble::tibble(value = value, reference_mean = center, reference_variance = variance,
                z = z, lower_tail = stats::pnorm(z), two_sided_tail = 2 * stats::pnorm(-abs(z)))
}

m03_conditional <- function(y, mean, covariance, target = 1L, conditioning = 2L) {
  p <- length(mean)
  m03_matrix(covariance, p)
  index <- c(target, conditioning)
  if (length(y) != p || any(!is.finite(c(y, mean))) || !length(target) || !length(conditioning) ||
      length(index) != p || anyDuplicated(index) || !setequal(index, seq_len(p))) {
    stop("Target and conditioning indices must partition the finite observed profile.", call. = FALSE)
  }
  coefficient <- covariance[target, conditioning, drop = FALSE] %*%
    solve(covariance[conditioning, conditioning, drop = FALSE])
  center <- as.numeric(mean[target] + coefficient %*% (y[conditioning] - mean[conditioning]))
  residual_covariance <- covariance[target, target, drop = FALSE] -
    coefficient %*% covariance[conditioning, target, drop = FALSE]
  residual <- y[target] - center
  distance <- as.numeric(crossprod(residual, solve(residual_covariance, residual)))
  list(mean = center, covariance = residual_covariance, residual = residual,
       distance = distance, radial_tail = stats::pchisq(distance, length(target), lower.tail = FALSE))
}

m03_bvn <- function(a, b, rho, method = c("conditional", "factor")) {
  method <- match.arg(method)
  if (length(rho) != 1L || any(!is.finite(c(a, b, rho))) || abs(rho) >= 1) {
    stop("Use finite standardized cutoffs and -1 < rho < 1.", call. = FALSE)
  }
  if (method == "factor" && rho < 0) stop("The real common-factor construction requires rho >= 0.", call. = FALSE)
  integral <- if (method == "conditional") {
    stats::integrate(function(x) stats::dnorm(x) * stats::pnorm((b - rho * x) / sqrt(1 - rho^2)),
                     -Inf, a, rel.tol = 1e-10, abs.tol = 1e-11, subdivisions = 1000L)
  } else {
    stats::integrate(function(u) stats::dnorm(u) *
                       stats::pnorm((a - sqrt(rho) * u) / sqrt(1 - rho)) *
                       stats::pnorm((b - sqrt(rho) * u) / sqrt(1 - rho)),
                     -Inf, Inf, rel.tol = 1e-10, abs.tol = 1e-11, subdivisions = 1000L)
  }
  list(probability = integral$value, quadrature_error = integral$abs.error)
}

m03_count2 <- function(cutoff, mean, covariance) {
  m03_matrix(covariance, 2L)
  if (length(cutoff) != 2L || length(mean) != 2L || any(!is.finite(c(cutoff, mean)))) {
    stop("This helper is for two finite coordinate cutoffs.", call. = FALSE)
  }
  sd <- sqrt(diag(covariance))
  z <- (cutoff - mean) / sd
  rho <- covariance[1, 2] / prod(sd)
  both <- m03_bvn(z[1], z[2], rho)
  marginal <- stats::pnorm(z)
  mass <- c(1 - sum(marginal) + both$probability,
            sum(marginal) - 2 * both$probability, both$probability)
  tibble::tibble(count = 0:2, mass = mass, inclusive_tail = rev(cumsum(rev(mass))),
                quadrature_error = both$quadrature_error)
}

m03_family2 <- function(t, rho = .6) {
  if (length(t) != 1L || !is.finite(t) || t < 0 || t > 1 || !is.finite(rho) || abs(rho) >= 1) {
    stop("Use one t in [0,1] and -1 < rho < 1.", call. = FALSE)
  }
  if (t == 0 || t == 1) return(t)
  2 * t - m03_bvn(stats::qnorm(t), stats::qnorm(t), rho)$probability
}

m03_family_level <- function(alpha = .05, rho = .6) {
  if (length(alpha) != 1L || !is.finite(alpha) || alpha <= 0 || alpha >= 1) stop("alpha must be in (0,1).", call. = FALSE)
  stats::uniroot(function(t) m03_family2(t, rho) - alpha, c(alpha / 2, alpha), tol = 1e-12)$root
}

m03_vector_predict <- function(y, mean, covariance, n) {
  p <- length(mean)
  m03_matrix(covariance, p)
  if (length(n) != 1L || !is.finite(n) || n != as.integer(n) || n <= p ||
      length(y) != p || any(!is.finite(c(y, mean)))) stop("Ordinary prediction needs n > p and matching finite vectors.", call. = FALSE)
  distance <- as.numeric(crossprod(y - mean, solve(covariance, y - mean)))
  m <- n - 1
  h <- 1 + 1 / n
  df <- n - p
  statistic <- df * distance / (p * m * h)
  tibble::tibble(distance = distance, F_statistic = statistic, denominator_df = df,
                predictive_tail = stats::pf(statistic, p, df, lower.tail = FALSE),
                critical_distance_95 = p * m * h / df * stats::qf(.95, p, df))
}

m03_niw <- function(mean, covariance, n, prior_mean, kappa, nu, psi) {
  p <- length(mean)
  m03_matrix(covariance, p, positive = FALSE)
  m03_matrix(psi, p)
  if (length(prior_mean) != p || any(!is.finite(c(mean, prior_mean, n, kappa, nu))) ||
      n < 1 || n != as.integer(n) || kappa <= 0 || nu <= p - 1) stop("Invalid normal-inverse-Wishart prior or sample summaries.", call. = FALSE)
  kappa_n <- kappa + n
  delta <- mean - prior_mean
  psi_n <- psi + (n - 1) * covariance + kappa * n / kappa_n * tcrossprod(delta)
  df <- nu + n - p + 1
  list(mean = (kappa * prior_mean + n * mean) / kappa_n,
       scale = (1 + 1 / kappa_n) * psi_n / df, df = df, psi = psi_n,
       kappa = kappa_n, nu = nu + n)
}

m03_student_count2 <- function(z, df, rho = .6) {
  if (any(!is.finite(c(z, df, rho))) || df <= 0 || abs(rho) >= 1) stop("Invalid Student count inputs.", call. = FALSE)
  crossing_integral <- stats::integrate(function(x) stats::dt(x, df) * stats::pt(
    (z - rho * x) / sqrt((df + x^2) * (1 - rho^2) / (df + 1)), df + 1),
    -Inf, z, rel.tol = 1e-10, abs.tol = 1e-11, subdivisions = 1000L)
  tibble::tibble(at_least_one = 2 * stats::pt(z, df) - crossing_integral$value,
                both = crossing_integral$value, quadrature_error = crossing_integral$abs.error)
}

m03_content_outer <- function(n, p, coefficient = -1, k = 1L, gamma = .05) {
  if (any(!is.finite(c(n, p, coefficient, k, gamma))) || n != as.integer(n) || p != as.integer(p) ||
      p < 1 || n <= p || k < 1 || k > p || k != as.integer(k) || gamma <= 0 || gamma >= 1) {
    stop("Use n > p >= 1, an integer 1 <= k <= p, and gamma in (0,1).", call. = FALSE)
  }
  m <- n - 1
  c_mu <- stats::qchisq(1 - gamma / 3, p)
  b_sigma <- stats::qchisq(1 - gamma / 3, m * p)
  determinant_lower <- prod(stats::qchisq(gamma / (3 * p), m - seq_len(p) + 1))
  a_sigma <- determinant_lower / b_sigma^(p - 1)
  ell <- min(coefficient * sqrt(c(a_sigma, b_sigma) / m)) - sqrt(c_mu / n)
  upper_z <- max(coefficient * sqrt(c(a_sigma, b_sigma) / m)) + sqrt(c_mu / n)
  tibble::tibble(k = k, confidence_lower = max(0, (p * stats::pnorm(ell) - k + 1) / (p - k + 1)),
                confidence_upper = min(1, p * stats::pnorm(upper_z) / k))
}

m03_weighted_tail <- function(value, weights = c(1.6, .4)) {
  if (length(value) != 1L || !is.finite(value) || value < 0 || length(weights) != 2L ||
      any(!is.finite(weights)) || min(weights) <= 0) stop("Use a nonnegative distance and two positive weights.", call. = FALSE)
  out <- stats::integrate(function(angle) exp(-value / (2 *
    (weights[1] * cos(angle)^2 + weights[2] * sin(angle)^2))), 0, pi / 2,
    rel.tol = 1e-10, abs.tol = 1e-11)
  list(probability = 2 / pi * out$value, quadrature_error = 2 / pi * out$abs.error)
}

# The output list follows the chapter units; every row is synthetic.
m03_example_results <- function() {
  input <- m03_inputs()
  mean <- input$mean
  covariance <- input$covariance
  n <- input$n
  rows <- lapply(seq_len(nrow(input$profiles)), function(i) {
    y <- input$profiles[i, ]
    label <- rownames(input$profiles)[i]
    cond <- m03_conditional(y, mean, covariance)
    sd <- sqrt(cond$covariance[1, 1])
    linear <- dplyr::bind_rows(
      dplyr::mutate(m03_linear(y, c(1, 0), mean, covariance), comparison = "marginal"),
      dplyr::mutate(m03_linear(y, c(.5, .5), mean, covariance), comparison = "average"),
      dplyr::mutate(m03_linear(y, c(1, -1), mean, covariance), comparison = "discrepancy"),
      tibble::tibble(comparison = "conditional", value = y[1], reference_mean = cond$mean,
                    reference_variance = sd^2, z = cond$residual / sd,
                    lower_tail = stats::pnorm(cond$residual / sd), two_sided_tail = cond$radial_tail))
    distance <- as.numeric(crossprod(y - mean, solve(covariance, y - mean)))
    quadratic <- tibble::tibble(distance = distance, upper_tail = stats::pchisq(distance, 2, lower.tail = FALSE),
                               conditioning_distance = ((y[2] - 50) / 10)^2,
                               residual_distance = cond$distance, residual_two_sided = cond$radial_tail)
    conditional_count <- tibble::tibble(conditioning_score = y[2], target_mean = cond$mean,
      target_sd = sd, known_conditioning_count = as.integer(y[2] <= 40),
      observed_target_count = as.integer(y[1] <= 40), observed_full_count = sum(y <= 40),
      target_crossing_probability = stats::pnorm((40 - cond$mean) / sd))
    vector <- m03_vector_predict(y, mean, covariance, n)
    prior <- m03_niw(mean, covariance, n, c(50, 50), 1, 5, 2 * covariance)
    proper_Q <- as.numeric(crossprod(y - prior$mean, solve(prior$scale, y - prior$mean)))
    vector <- dplyr::mutate(vector, proper_radial_tail = stats::pf(proper_Q / 2, 2, prior$df, lower.tail = FALSE))
    q <- stats::pnorm((y - mean) / sqrt(diag(covariance)))
    family <- tibble::tibble(coordinate = 1:2, marginal = q, bonferroni = pmin(1, 2 * q),
                            dependence_adjusted = vapply(q, m03_family2, numeric(1)),
                            overall_adjusted = m03_family2(min(q)))
    h <- 1 + 1 / n + (y[2] - 50)^2 / 1900
    scale_squared <- h * 1216 / 18
    z <- (y[1] - cond$mean) / sqrt(scale_squared)
    h_proper <- 1 + 1 / 21 + (y[2] - 50)^2 / 2000
    regression <- tibble::tibble(fitted_mean = cond$mean, leverage_multiplier = h,
      predictive_scale_squared = scale_squared, lower_tail = stats::pt(z, 18),
      radial_two_sided = 2 * stats::pt(-abs(z), 18),
      proper_lower_tail = stats::pt((y[1] - cond$mean) / sqrt(56 * h_proper), 24))
    changed_distance <- sum(((y - mean) / 10)^2)
    metric_tail <- m03_weighted_tail(changed_distance)
    metric <- tibble::tibble(original_distance = distance, diagonal_distance = changed_distance,
      weighted_upper_tail = metric_tail$probability, quadrature_error = metric_tail$quadrature_error,
      naive_chisquare_tail = stats::pchisq(changed_distance, 2, lower.tail = FALSE))
    lapply(list(linear = linear, quadratic = quadratic, conditional_count = conditional_count,
                vector_prediction = vector, family_values = family, conditional_prediction = regression,
                metric = metric), function(df) dplyr::mutate(df, profile = label, .before = 1))
  })
  out <- lapply(names(rows[[1]]), function(name) dplyr::bind_rows(lapply(rows, `[[`, name)))
  names(out) <- names(rows[[1]])
  out$count_probabilities <- dplyr::bind_rows(lapply(c(.6, 0), function(rho) {
    dplyr::mutate(m03_count2(c(40, 40), mean, matrix(c(100, 100 * rho, 100 * rho, 100), 2)),
                  correlation = rho, .before = 1)
  }))
  out$family_levels <- dplyr::bind_rows(lapply(c(.6, 0, -.5), function(rho) {
    level <- m03_family_level(.05, rho)
    tibble::tibble(correlation = rho, marginal_05_frequency = m03_family2(.05, rho),
      bonferroni_frequency = m03_family2(.025, rho), calibrated_level = level,
      calibrated_frequency = m03_family2(level, rho), raw_cutoff = 50 + 10 * stats::qnorm(level))
  }))
  out$fitted_count_predictive <- dplyr::bind_rows(
    dplyr::mutate(m03_student_count2(-1 / sqrt(133 / 120), 18), prior = "comparison"),
    dplyr::mutate(m03_student_count2(-1 / sqrt(11 / 12), 24), prior = "proper"))
  out$content_outer <- dplyr::bind_rows(lapply(1:2, function(k) m03_content_outer(n, 2, k = k)))
  out
}
