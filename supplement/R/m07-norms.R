# Synthetic M07 experiments. These functions do not score patients or diagnose disease.
# All normal arguments below are SDs when passed to R's dnorm/pnorm/rnorm.
# Chapter model variances are square-rooted explicitly before that conversion.
m07_probability <- function(x, name = "probability") {
  if (length(x) != 1 || !is.finite(x) || x <= 0 || x >= 1) stop(name, " must lie strictly between 0 and 1")
  invisible(x)
}
m07_cp <- function(k, n, alpha = .05) {
  m07_probability(alpha, "alpha")
  if (length(n) != 1 || !is.finite(n) || n < 1 || n != floor(n) || any(!is.finite(k) | k < 0 | k > n | k != floor(k))) stop("Use integer counts between 0 and positive n")
  lo <- rep(0, length(k)); hi <- rep(1, length(k))
  lo[k > 0] <- stats::qbeta(alpha / 2, k[k > 0], n - k[k > 0] + 1)
  hi[k < n] <- stats::qbeta(1 - alpha / 2, k[k < n] + 1, n - k[k < n])
  tibble::tibble(count = k, n = n, lower = lo, upper = hi)
}
m07_references <- function(y = 35) {
  f0 <- stats::pnorm(y, 50, 10); f1 <- stats::pnorm(y, 40, 5)
  tibble::tibble(reference = c("C0", "C1", "Pool_equal", "Pool_70_30", "Normal_matching_equal_pool_moments"),
    score = y, percentile = c(f0, f1, (f0 + f1) / 2, .7 * f0 + .3 * f1, stats::pnorm(y, 45, sqrt(87.5))))
}
m07_ties <- function() {
  dplyr::bind_rows(lapply(0:1, function(g) {
    p <- if (g == 0) c(.1, .7, .2) else c(.2, .4, .4)
    tibble::tibble(group = g, score = 0:2, mass = p, strict = c(0, head(cumsum(p), -1)), inclusive = cumsum(p), midpoint = cumsum(p) - p / 2)
  }))
}
m07_anchor <- function(lambda = 2, Gamma = 0) {
  if (length(lambda) != 1 || !is.finite(lambda) || lambda == 0 || !is.finite(Gamma) || Gamma < 0) stop("Nonzero finite loading and nonnegative finite offset bound required")
  delta <- 4; c_delta <- 1 / 50 + 1 / 50; nu <- 98; s2 <- 36
  k <- 2.25 + 1 / c_delta; m <- (delta / c_delta) / k
  a <- 3 + (nu + 1) / 2; b <- 72 + .5 * (3528 + 2.25 / (1 + 2.25 * c_delta) * delta^2)
  se <- sqrt(s2 * c_delta) / abs(lambda)
  scale_d <- sqrt(b / (a * k))
  # The offset is independent of the learned contrast, not independent of beta.
  cdf <- function(x) {
    if (Gamma == 0) return(stats::pt((x - m / lambda) / (scale_d / abs(lambda)), 2 * a))
    stats::integrate(function(g) {
      z <- stats::pt((lambda * x + g - m) / scale_d, 2 * a)
      if (lambda > 0) z else 1 - z
    }, -Gamma, Gamma, rel.tol = 1e-11)$value / (2 * Gamma)
  }
  center <- m / lambda; radius <- 20 + Gamma / abs(lambda)
  quantile <- function(p) stats::uniroot(function(x) cdf(x) - p, center + c(-radius, radius), tol = 1e-11)$root
  tibble::tibble(loading = lambda, offset_bound = Gamma, estimate = delta / lambda, sampling_se = se,
    confidence_lower = delta / lambda - stats::qt(.975, nu) * se - Gamma / abs(lambda),
    confidence_upper = delta / lambda + stats::qt(.975, nu) * se + Gamma / abs(lambda),
    posterior_mean = center, posterior_variance = b / ((a - 1) * k * lambda^2) + Gamma^2 / (3 * lambda^2),
    lower = quantile(.025), upper = quantile(.975), posterior_d_mean = m, posterior_d_precision = k,
    posterior_variance_shape = a, posterior_variance_scale = b)
}
m07_anchor_known <- function() {
  omega <- 36 * .04; V <- 1 / (.25 + 4 / omega); m <- V * 8 / omega
  tibble::tibble(estimate = 2, se = .6, lower = 2 - stats::qnorm(.975) * .6, upper = 2 + stats::qnorm(.975) * .6,
    posterior_mean = m, posterior_variance = V,
    coverage_if_offset_2 = stats::pnorm(stats::qnorm(.975) - 1 / .6) - stats::pnorm(-stats::qnorm(.975) - 1 / .6))
}
# Vertices of a four-coordinate probability box intersected with sum(q)=1.
# Set all but one coordinate to a bound; solve the remaining coordinate.
m07_vertices <- function(lower, upper) {
  if (length(lower) != 4 || length(upper) != 4 || any(lower < 0 | upper > 1 | lower > upper)) stop("Four valid coordinate bounds required")
  choices <- expand.grid(rep(list(0:1), 4)); result <- list()
  for (i in seq_len(nrow(choices))) for (free in 1:4) {
    q <- ifelse(as.numeric(choices[i, ]) == 0, lower, upper)
    q[free] <- 1 - sum(q[-free])
    if (all(q >= lower - 1e-12 & q <= upper + 1e-12)) result[[length(result) + 1]] <- q
  }
  if (!length(result)) return(matrix(numeric(), 0, 4))
  unique(round(do.call(rbind, result), 12))
}
m07_selection <- function(counts = c(6, 12, 9, 3), weights = c(.25, .5, 1, 1), alpha = .05) {
  if (length(weights) != 4 || any(!is.finite(weights) | weights <= 0 | weights > 1) || length(counts) != 4 || sum(counts) < 1) stop("Four counts and known strictly positive inclusion probabilities required")
  cp <- m07_cp(counts, sum(counts), alpha / 4)
  q <- counts / sum(counts); p <- (q / weights) / sum(q / weights)
  vertices <- m07_vertices(cp$lower, cp$upper)
  band <- dplyr::bind_rows(lapply(0:2, function(k) {
    value <- if (nrow(vertices)) apply(vertices, 1, function(q) sum((q / weights)[seq_len(k + 1)]) / sum(q / weights)) else c(0, 1)
    tibble::tibble(threshold = k, lower = min(value), upper = max(value))
  }))
  list(fitted = tibble::tibble(score = 0:3, count = counts, inclusion_probability = weights, selected_probability = q, target_probability = p),
    band = band, vertices = vertices, inclusion_fraction = 1 / sum(q / weights))
}
m07_selection_posterior <- function(prior_shape = 1) {
  if (!is.finite(prior_shape) || prior_shape <= 0) stop("Positive prior shape required")
  A <- c(6, 12, 9, 3) + prior_shape; omega <- c(4, 2, 1, 1)
  laplace <- function(t, order = 1) vapply(t, function(x) {
    P <- prod((1 + omega * x)^(-A)); M <- sum(A[1:2] * omega[1:2] / (1 + omega[1:2] * x))
    V <- sum(A[1:2] * omega[1:2]^2 / (1 + omega[1:2] * x)^2)
    if (order == 1) M * P else x * (M^2 + V) * P
  }, numeric(1))
  mean <- stats::integrate(laplace, 0, Inf, rel.tol = 1e-11)$value
  second <- stats::integrate(function(t) laplace(t, 2), 0, Inf, rel.tol = 1e-11)$value
  cdf <- function(f) stats::integrate(function(r) stats::pbeta(f / ((2 + 2 * r) * (1 - f) + f), sum(A[1:2]), sum(A[3:4])) * stats::dbeta(r, A[1], A[2]), 0, 1, rel.tol = 1e-11)$value
  quant <- function(p) stats::uniroot(function(f) cdf(f) - p, c(1e-8, 1 - 1e-8), tol = 1e-11)$root
  tibble::tibble(prior_shape = prior_shape, posterior_mean = mean, posterior_variance = second - mean^2,
    lower = quant(.025), upper = quant(.975), transformed_mean_q = sum((A * omega)[1:2]) / sum(A * omega))
}
m07_screening <- function(a = 2, b = 2) {
  if (a <= 0 || b <= 0 || a + b != 4) stop("This finite-mixture example requires positive a,b summing to4")
  m <- a / (a + b); v <- a * b / ((a + b)^2 * (a + b + 1)); A <- c(11, 21, 24); total <- sum(A)
  mean <- (A[1] + m * A[3]) / total
  variance <- A[3] * (A[3] + 1) / (total * (total + 1)) * v + ((A[1] + m^2 * A[3]) / total - mean^2) / (total + 1)
  k <- 0:20; wk <- exp(lchoose(20, k) + lbeta(a + k, b + 20 - k) - lbeta(a, b))
  cdf <- function(f) sum(wk * stats::pbeta(f, 11 + a + k, 21 + b + 20 - k))
  quant <- function(p) stats::uniroot(function(x) cdf(x) - p, c(0, 1), tol = 1e-11)$root
  tibble::tibble(split_a = a, split_b = b, posterior_mean = mean, posterior_variance = variance,
    lower = quant(.025), upper = quant(.975), mixture_weight_sum = sum(wk), empirical_lower = .2, empirical_upper = .6,
    set_confidence_lower = stats::qbeta(.025, 10, 41), set_confidence_upper = 1 - stats::qbeta(.025, 20, 31))
}
m07_screen_correlation <- function(rho = .8) {
  if (!is.finite(rho) || abs(rho) >= 1) stop("Absolute correlation must be below1")
  variance <- c(1 - 2 / pi, 1 + stats::dnorm(1) / stats::pnorm(1, lower.tail = FALSE))
  tibble::tibble(screen = c("X_positive", "absolute_X_above_1"), screening_variance = variance,
    correlation = rho * sqrt(variance) / sqrt(1 - rho^2 + rho^2 * variance))
}
m07_paired <- function() {
  counts <- c(12, 18); total <- c(20, 20); cp <- m07_cp(counts, 20, .025)
  tibble::tibble(source = 0:1, row_n = total, successes = counts, posterior_a = counts + 1, posterior_b = total - counts + 1,
    posterior_mean = (counts + 1) / (total + 2), lower = stats::qbeta(.025, counts + 1, total - counts + 1),
    upper = stats::qbeta(.975, counts + 1, total - counts + 1), confidence_lower = cp$lower, confidence_upper = cp$upper)
}
m07_regression <- function() {
  X <- cbind(1, rep(0:2, each = 2)); y <- c(52, 48, 43, 47, 39, 41); x <- c(1, 1); y0 <- 42
  estimate <- solve(crossprod(X), crossprod(X, y)); nu <- 4; s2 <- sum((y - X %*% estimate)^2) / nu
  leverage <- drop(t(x) %*% solve(crossprod(X), x)); mhat <- sum(x * estimate)
  delta <- 1 - sqrt(.95); z <- stats::qnorm(1 - delta / 2)
  limits <- sqrt(nu * s2 / stats::qchisq(c(1 - delta / 2, delta / 2), nu)); d <- y0 - mhat
  V0 <- diag(c(100, 25)); b0 <- c(50, -5); V <- solve(solve(V0) + crossprod(X)); b <- V %*% (solve(V0, b0) + crossprod(X, y))
  a <- 6; scale <- 9 + .5 * (sum(y^2) + drop(t(b0) %*% solve(V0, b0)) - drop(t(b) %*% solve(V, b)))
  mean <- sum(x * b); h <- drop(t(x) %*% V %*% x)
  cdf <- function(p) stats::integrate(function(v) stats::pnorm((mean - y0 + sqrt(v) * stats::qnorm(p)) / sqrt(v * h)) * stats::dgamma(1 / v, a, rate = scale) / v^2,
    0, Inf, rel.tol = 1e-10, subdivisions = 400)$value
  quant <- function(p) stats::uniroot(function(q) cdf(q) - p, c(1e-10, 1 - 1e-10), tol = 1e-11)$root
  tibble::tibble(intercept = estimate[1], slope = estimate[2], residual_variance = s2, df = nu, fitted_mean = mhat,
    leverage = leverage, fitted_percentile = stats::pnorm(d / sqrt(s2)), confidence_lower = stats::pnorm(min(d / limits) - z * sqrt(leverage)),
    confidence_upper = stats::pnorm(max(d / limits) + z * sqrt(leverage)), posterior_shape = a, posterior_scale = scale,
    posterior_mean = stats::pt((y0 - mean) / sqrt(scale / a * (1 + h)), 2 * a), median = quant(.5), lower = quant(.025), upper = quant(.975))
}
# Gauss-Legendre nodes/weights integrate a function on (0,1); no extension package.
m07_gl <- function(n = 96) {
  if (n < 4 || n != floor(n)) stop("Use at least4 integer quadrature nodes")
  k <- seq_len(n - 1); beta <- k / sqrt(4 * k^2 - 1); J <- matrix(0, n, n)
  J[cbind(k, k + 1)] <- beta; J[cbind(k + 1, k)] <- beta
  eig <- eigen(J, symmetric = TRUE); ord <- order(eig$values)
  list(x = (eig$values[ord] + 1) / 2, w = eig$vectors[1, ord]^2)
}
m07_shape_bands <- function(alpha = .05) {
  counts <- rbind(c(8, 16, 4, 12), c(12, 4, 16, 8)); bounds <- lapply(1:2, function(g) m07_cp(counts[g, ], 40, alpha / 9))
  theta <- m07_cp(20, 60, alpha / 9); result <- list()
  for (k in 0:2) {
    lo <- hi <- numeric(2)
    for (g in 1:2) {
      idx <- seq_len(k + 1); cp <- bounds[[g]]
      lo[g] <- max(sum(cp$lower[idx]), 1 - sum(cp$upper[-idx])); hi[g] <- min(sum(cp$upper[idx]), 1 - sum(cp$lower[-idx]))
    }
    pooled_lo <- min(theta$lower * lo[1] + (1 - theta$lower) * lo[2], theta$upper * lo[1] + (1 - theta$upper) * lo[2])
    pooled_hi <- max(theta$lower * hi[1] + (1 - theta$lower) * hi[2], theta$upper * hi[1] + (1 - theta$upper) * hi[2])
    result[[k + 1]] <- tibble::tibble(threshold = k, F0_lower = lo[1], F0_upper = hi[1], F1_lower = lo[2], F1_upper = hi[2],
      pool_lower = pooled_lo, pool_upper = pooled_hi, contrast_lower = lo[1] - hi[2], contrast_upper = hi[1] - lo[2], theta_lower = theta$lower, theta_upper = theta$upper)
  }
  dplyr::bind_rows(result)
}
m07_shape_posterior <- function(prior_shape = 1, nodes = 96) {
  if (prior_shape <= 0) stop("Positive prior shape required")
  A0 <- c(8, 16, 4, 12) + prior_shape; A1 <- c(12, 4, 16, 8) + prior_shape
  a0 <- sum(A0[1:2]); b0 <- sum(A0[3:4]); a1 <- sum(A1[1:2]); b1 <- sum(A1[3:4])
  m0 <- a0 / (a0 + b0); m1 <- a1 / (a1 + b1); mt <- 21 / 62; vt <- 21 * 41 / (62^2 * 63)
  variance <- function(a, b) a * b / ((a + b)^2 * (a + b + 1))
  gl <- m07_gl(nodes); x <- gl$x; w <- gl$w
  weighted <- (w * stats::dbeta(x, 21, 41)) %o% (w * stats::dbeta(x, a1, b1))
  cdf_pool <- function(f) sum(stats::pbeta(outer(x, x, function(q, y) (f - (1 - q) * y) / q), a0, b0) * weighted)
  cdf_difference <- function(d) stats::integrate(function(x) stats::pbeta(d + x, a0, b0) * stats::dbeta(x, a1, b1), 0, 1, rel.tol = 1e-10)$value
  quant_pool <- function(p) stats::uniroot(function(x) cdf_pool(x) - p, c(0, 1), tol = 1e-10)$root
  quant_difference <- function(p) stats::uniroot(function(x) cdf_difference(x) - p, c(-1, 1), tol = 1e-10)$root
  tibble::tibble(prior_shape = prior_shape, nodes = nodes, F0_mean = m0, F1_mean = m1,
    F0_lower = stats::qbeta(.025, a0, b0), F0_upper = stats::qbeta(.975, a0, b0), F1_lower = stats::qbeta(.025, a1, b1), F1_upper = stats::qbeta(.975, a1, b1),
    pooled_mean = mt * m0 + (1 - mt) * m1,
    pooled_variance = (vt + mt^2) * variance(a0, b0) + (vt + (1 - mt)^2) * variance(a1, b1) + vt * (m0 - m1)^2,
    median = quant_pool(.5), lower = quant_pool(.025), upper = quant_pool(.975), contrast_lower = quant_difference(.025), contrast_upper = quant_difference(.975), probability_contrast_positive = 1 - cdf_difference(0))
}
m07_shape_functionals <- function() {
  variance_mean <- 1 / 36; EV <- 11 / 9; mt <- 21 / 62; vt <- 21 * 41 / (62^2 * 63)
  Vpool <- (vt + mt^2 + vt + (1 - mt)^2) * variance_mean
  tibble::tibble(population = c("C0", "C1", "Pooled"), posterior_mean_score = 1.5,
    variance_of_mean = c(variance_mean, variance_mean, Vpool), expected_population_variance = c(EV, EV, 1.25 - Vpool), predictive_score_variance = 1.25)
}
m07_link <- function() {
  V_A <- 1 / (1 / 100 + 3); V_B <- 1 / (1 / 4 + 2); sdB <- sqrt(V_B); normalizer <- stats::pnorm(2 / sdB)
  cdf <- function(k) stats::integrate(function(b) stats::pnorm((k - .5 * b - 10) / sqrt(V_A)) * stats::dnorm(b, 2, sdB), 0, Inf, rel.tol = 1e-11)$value / normalizer
  quant <- function(p) stats::uniroot(function(k) cdf(k) - p, c(0, 22), tol = 1e-10)$root
  ratio <- stats::dnorm(2 / sdB) / normalizer; EB <- 2 + sdB * ratio; VB <- V_B * (1 - (2 / sdB) * ratio - ratio^2)
  half <- sqrt(stats::qchisq(.95, 2) * (1 / 3 + .25 / 2))
  tibble::tibble(intercept = 10, slope = 2, confidence_lower = 11 - half, confidence_upper = 11 + half, untruncated_A_variance = V_A, untruncated_B_variance = V_B,
    positive_slope_probability = normalizer, lower = quant(.025), upper = quant(.975), posterior_mean_B = EB, posterior_variance_B = VB,
    independent_source_target_mean = 10 + .5 * EB, independent_source_target_variance = V_A + .25 * VB + .25 * (VB + EB^2))
}
# Radical-inverse coordinates and a fixed shift provide a reproducible integration grid.
# No random number generator is used; different shifts diagnose integration sensitivity.
m07_halton <- function(n, base) {
  index <- seq_len(n); value <- numeric(n); factor <- 1 / base
  while (any(index > 0)) { value <- value + factor * (index %% base); index <- floor(index / base); factor <- factor / base }
  value
}
m07_noisy <- function(n_points = 262144, shift = 1, source_error_scale = .6, case_update = TRUE) {
  if (n_points < 128 || n_points != floor(n_points) || source_error_scale <= 0 || !is.finite(source_error_scale) || !shift %in% 1:2) stop("Positive scale, at least128 integer points, and shift1or2required")
  n <- 24; Mc <- .5; QM <- 28.75; QD <- if (case_update) 7.24 else 7.2
  N <- if (case_update) 25 else 24; M <- if (case_update) .5 / 25 else 0
  Q <- QM + if (case_update) 24 / 25 * .5^2 else 0
  k <- .25 + N; mu <- N * M / k; at <- 3 + N / 2; dt <- 3 + .5 * (Q + .25 * N * M^2 / k)
  as <- 3 + N / 2; ds <- source_error_scale + QD / 2
  Va <- 1 / (1 / 25 + n); Vb <- 1 / (1 / 4 + QM); mb <- Vb * (1.2 / 4 + 1.1 * QM)
  aq <- 15; dq <- 1 + .5 * (n * 100 + 1.21 * QM + 11 + 100 / 25 + 1.2^2 / 4 - 100 / Va - mb^2 / Vb)
  shifts <- if (shift == 1) c(.137, .419, .733, .281) else c(.691, .173, .357, .823)
  U <- sapply(c(2, 3, 5, 7), function(base) m07_halton(n_points, base)); U <- sweep(U, 2, shifts, "+") %% 1
  U[] <- pmin(1 - 1e-12, pmax(1e-12, U))
  t <- 1 / stats::qgamma(U[, 1], at, rate = dt); q <- 1 / stats::qgamma(U[, 2], aq, rate = dq)
  # First truncate source noise to s<2t, then slope to its physical interval.
  p_s <- stats::pgamma(1 / (2 * t), as, rate = ds, lower.tail = FALSE)
  s <- 1 / stats::qgamma(U[, 3] * p_s, as, rate = ds, lower.tail = FALSE)
  v <- t - s / 2; g <- v / t
  max_b <- sqrt(q * (2 * t - s) / (t * s)); sd_b <- sqrt(q * Vb)
  p0 <- stats::pnorm(0, mb, sd_b); p1 <- stats::pnorm(max_b, mb, sd_b); prob_b <- pmax(0, p1 - p0)
  b <- stats::qnorm(p0 + U[, 4] * prob_b, mb, sd_b)
  weight <- p_s * prob_b; normalizer <- mean(weight); weight <- weight / sum(weight)
  stopifnot(all(is.finite(b)), all(v > 0), all(b > 0), all(b < max_b))
  means <- list(H = g * Mc + (1 - g) * mu, K = 10 + b * Mc, Future = 10 + b * Mc,
    Fixed_link = 10 + b * (.5 / g + mu * (1 - 1 / g)))
  variances <- list(H = v * s / (2 * t) + (1 - g)^2 * t / k, K = q * Va + b^2 * t * s / (2 * v),
    Future = q * (1 + Va), Fixed_link = q * Va + b^2 * (1 - 1 / g)^2 * t / k)
  summary <- dplyr::bind_rows(lapply(names(means), function(target) {
    m <- means[[target]]; vv <- variances[[target]]; average <- sum(weight * m)
    variance <- sum(weight * (vv + (m - average)^2))
    cdf <- function(x) sum(weight * stats::pnorm(x, m, sqrt(vv)))
    quant <- function(p) stats::uniroot(function(x) cdf(x) - p, average + c(-30, 30), tol = 1e-8)$root
    tibble::tibble(target = target, mean = average, variance = variance, median = quant(.5), lower = quant(.025), upper = quant(.975))
  }))
  summary |> dplyr::mutate(points = n_points, shift = shift, source_error_scale = source_error_scale, case_update = case_update, physical_probability = normalizer)
}
m07_noisy_confidence <- function(alpha = .05, include_case_uncertainty = TRUE) {
  m07_probability(alpha, "alpha")
  n <- 24; delta <- 1 - (1 - alpha)^(1 / 6); z <- stats::qnorm(1 - delta / 2); c <- stats::qchisq(1 - delta, 2)
  interval <- function(Q, df) Q / stats::qchisq(c(1 - delta / 2, delta / 2), df)
  t <- interval(28.75, 23); s <- interval(7.24, 25); q <- interval(11, 22)
  g <- c(1 - s[2] / (2 * t[1]), 1 - s[1] / (2 * t[2]))
  if (g[1] <= 0) return(tibble::tibble(lower = -Inf, upper = Inf))
  mu <- c(-1, 1) * z * sqrt(t[2] / n); h <- if (include_case_uncertainty) .5 + c(-1, 1) * z * sqrt(s[2] / 2) else .5
  box <- expand.grid(mu = mu, g = g, h = h); xi <- range(box$mu + (box$h - box$mu) / box$g)
  lower <- min(10 + 1.1 * xi - sqrt(c * q[2] * (1 / n + xi^2 / 28.75)))
  upper <- max(10 + 1.1 * xi + sqrt(c * q[2] * (1 / n + xi^2 / 28.75)))
  tibble::tibble(alpha = alpha, case_uncertainty = include_case_uncertainty, z = z, chi_square = c,
    t_lower = t[1], t_upper = t[2], s_lower = s[1], s_upper = s[2], q_lower = q[1], q_upper = q[2], g_lower = g[1], g_upper = g[2], lower = lower, upper = upper)
}
