# M10 observed-profile teaching experiments. No patient scoring or package install.
# Every covariance, prior, event and numerical target is declared below.
m10_reference <- function() {
  R <- matrix(.36, 5, 5); R[1:3, 1:3] <- .61; R[4:5, 4:5] <- .61; diag(R) <- 1
  R
}
m10_probability <- function(x) {
  if (length(x) != 1L || !is.finite(x) || x <= 0 || x >= 1) stop("Require a scalar probability strictly between zero and one.")
  invisible(x)
}
m10_student_rate <- function(nu, p = 5L, alpha = .05) {
  m10_probability(alpha)
  if (any(!is.finite(nu) | nu <= 2) || length(p) != 1 || p < 1 || p != floor(p)) stop("Covariance matching requires nu > 2 and integer p >= 1.")
  stats::pf(nu * stats::qchisq(1 - alpha, p) / (p * (nu - 2)), p, nu, lower.tail = FALSE)
}
m10_plugin_rate <- function(n, p = 5L, alpha = .05) {
  m10_probability(alpha)
  if (any(!is.finite(n) | n <= p | n != floor(n)) || length(p) != 1 || p < 1 || p != floor(p)) stop("Require integer n > p >= 1.")
  stats::pf((n - p) * stats::qchisq(1 - alpha, p) / (p * (n - 1) * (1 + 1 / n)), p, n - p, lower.tail = FALSE)
}
m10_cp <- function(k, n, error = .05) {
  m10_probability(error)
  if (length(k) != 1 || length(n) != 1 || !is.finite(k + n) || k < 0 || n < k || k != floor(k) || n != floor(n)) stop("Require integers 0 <= k <= n.")
  c(lower = if (k == 0) 0 else stats::qbeta(error / 2, k, n - k + 1),
    upper = if (k == n) 1 else stats::qbeta(1 - error / 2, k + 1, n - k))
}
# Exact finite probability law, compared with explicit weighted enumeration.
m10_moments <- function() {
  x <- matrix(c(-2, 1, 0, -1, 1, 2, 3, 0), 4, 2, byrow = TRUE); w <- c(.15, .25, .4, .2)
  mu <- colSums(x * w); e <- sweep(x, 2, mu); R <- crossprod(e * sqrt(w)); delta <- c(.7, -.2)
  B <- matrix(c(1, .3, .3, .8), 2); h <- drop(B %*% delta); b <- c(.4, -.8)
  Q <- rowSums((sweep(e, 2, delta, "+") %*% B) * sweep(e, 2, delta, "+")); linear <- drop(e %*% b)
  centered_quadratic <- rowSums((e %*% B) * e)
  third <- sum(w * drop(e %*% h) * centered_quadratic)
  fourth_contraction <- sum(w * centered_quadratic^2) - sum(diag(B %*% R))^2 - 2 * sum(diag(B %*% R %*% B %*% R))
  expected <- sum(diag(B %*% R)) + drop(t(delta) %*% B %*% delta)
  variance <- 2 * sum(diag(B %*% R %*% B %*% R)) + fourth_contraction + 4 * drop(t(h) %*% R %*% h) + 4 * third
  covariance <- 2 * drop(t(b) %*% R %*% B %*% delta) + sum(w * linear * centered_quadratic)
  tibble::tibble(quantity = c("mean", "variance", "linear_covariance"), formula = c(expected, variance, covariance),
    enumeration = c(sum(w * Q), sum(w * (Q - sum(w * Q))^2), sum(w * (Q - sum(w * Q)) * linear)))
}
m10_conditional_student <- function() {
  z <- c(-2, 0); omega <- .6; rho <- .5; nu <- 5; d <- z^2 / omega
  scale2 <- (nu + d) / (nu + 1) * omega * (1 - rho^2)
  tibble::tibble(companion_score = z, conditional_location = rho * z, scale_squared = scale2,
    conditional_variance = scale2 * 6 / 4, lower_tail_at_minus2 = stats::pt((-2 - rho * z) / sqrt(scale2), 6))
}
m10_mixture <- function() {
  R <- m10_reference(); delta <- c(rep(-1.5, 3), 0, 0); distance <- drop(t(delta) %*% solve(R, delta))
  tail <- .7 * stats::pnorm(-1.5) + .3 * .5
  tibble::tibble(distance = distance, case_component2 = stats::plogis(log(.3 / .7) + distance / 2),
    event_probability = tail, moment_normal_probability = stats::pnorm((-1.5 + .45) / sqrt(1 + .21 * 1.5^2)))
}
m10_weight <- function(scores = c(-2.5, -1.8, -.7, 0, .4, 1)) {
  if (!length(scores) || any(!is.finite(scores))) stop("Require finite observed scores.")
  ratio <- stats::dnorm(scores + 2) / stats::dnorm(scores)
  kernel <- function(w) vapply(w, function(v) prod(1 - v + v * ratio), numeric(1))
  integral <- function(fun, upper = 1) stats::integrate(fun, 0, upper, rel.tol = 1e-11)$value
  Z <- integral(kernel); mean <- integral(function(w) w * kernel(w)) / Z
  quantile <- function(p) stats::uniroot(function(w) integral(kernel, w) / Z - p, c(0, 1), tol = 1e-11)$root
  limits <- vapply(c(.025, .975), quantile, numeric(1)); f0 <- stats::dnorm(-1.5); f1 <- stats::dnorm(.5)
  q0 <- stats::pnorm(-1.5); q1 <- stats::pnorm(.5)
  mle <- stats::optimize(function(w) -sum(log(1 - w + w * ratio)), c(0, 1), tol = 1e-11)$minimum
  tibble::tibble(weight_mean = mean, weight_lower = limits[1], weight_upper = limits[2], weight_mle = mle,
    event_mean = q0 + (q1 - q0) * mean, event_lower = q0 + (q1 - q0) * limits[1], event_upper = q0 + (q1 - q0) * limits[2],
    correct_membership = mean * f1 / ((1 - mean) * f0 + mean * f1),
    reference_only_average = integral(function(w) kernel(w) * w * f1 / ((1 - w) * f0 + w * f1)) / Z)
}
m10_person_scale <- function(energy = 6, p = 5L, nu = 5, beta = 1, error = .05) {
  m10_probability(error)
  if (length(energy) != 1 || length(p) != 1 || length(nu) != 1 || length(beta) != 1 ||
      any(!is.finite(c(energy, p, nu, beta))) || energy <= 0 || p < 2 || p != floor(p) || nu <= 2 || beta <= 0) stop("Require energy > 0, integer p >= 2, nu > 2 and beta > 0.")
  d <- 2 * (p - 1); a <- (nu + d) / 2; rate <- ((nu - 2) * beta + energy) / 2
  tibble::tibble(energy = energy, dimension = d, confidence_lower = energy / stats::qchisq(1 - error / 2, d),
    confidence_upper = energy / stats::qchisq(error / 2, d), posterior_mean = rate / (a - 1),
    posterior_lower = rate / stats::qgamma(1 - error / 2, a), posterior_upper = rate / stats::qgamma(error / 2, a),
    population_squared_dispersion_correlation = if (nu > 4) (p - 1) / (p + nu - 3) else NA_real_)
}
m10_copula <- function(u = .05, rho = 0, nu = 4) {
  m10_probability(u)
  if (length(rho) != 1 || length(nu) != 1 || !is.finite(rho + nu) || abs(rho) >= 1 || nu <= 0) stop("Require |rho| < 1 and nu > 0.")
  a <- stats::qt(u, nu); b <- stats::qnorm(u)
  student <- stats::integrate(function(x) stats::dt(x, nu) * stats::pt((a - rho * x) / sqrt((nu + x^2) * (1 - rho^2) / (nu + 1)), nu + 1), -Inf, a, rel.tol = 1e-11, abs.tol = 1e-12)
  normal <- stats::integrate(function(x) stats::dnorm(x) * stats::pnorm((b - rho * x) / sqrt(1 - rho^2)), -Inf, b, rel.tol = 1e-11, abs.tol = 1e-12)
  tibble::tibble(rho = rho, u = u, gaussian_both = normal$value, student_both = student$value,
    gaussian_any = 2 * u - normal$value, student_any = 2 * u - student$value,
    student_tail_coefficient = 2 * stats::pt(-sqrt((nu + 1) * (1 - rho) / (1 + rho)), nu + 1),
    student_quadrature_error_estimate = student$abs.error, gaussian_quadrature_error_estimate = normal$abs.error)
}
m10_cells <- function() {
  ci <- m10_cp(8, 100)
  tibble::tibble(count = 8L, total = 100L, empirical_both = .08, empirical_independence_product = .20 * .18,
    posterior_shape1 = 9, posterior_shape2 = 95, posterior_mean = 9 / 104,
    posterior_lower = stats::qbeta(.025, 9, 95), posterior_upper = stats::qbeta(.975, 9, 95),
    confidence_lower = ci[1], confidence_upper = ci[2])
}
m10_covariance <- function() {
  p <- 5; n <- 12; R <- m10_reference(); mean <- c(-.4, -.2, 0, .1, .2); z <- c(-1.5, -1.5, -1.5, 0, 0)
  Psi <- 2 * diag(p) + (n - 1) * R + n / (n + 1) * tcrossprod(mean)
  center <- n * mean / (n + 1); df <- 8 + n - p + 1; scale <- (n + 2) / ((n + 1) * df) * Psi
  radius <- drop(t(z - center) %*% solve(scale, z - center))
  tibble::tibble(chi_cutoff = stats::qchisq(.95, p), finite_F_cutoff = p * (n - 1) * (1 + 1 / n) / (n - p) * stats::qf(.95, p, n - p),
    exact_plugin_rate = m10_plugin_rate(n), smallest_shrunk_eigenvalue = .8 * .01 + .2,
    shrunk_condition_number = 1.8 / .208, predictive_df = df, predictive_first_scale = scale[1, 1], predictive_radius = radius,
    predictive_radial_tail = stats::pf(radius / p, p, df, lower.tail = FALSE),
    predictive_first_lower_tail = stats::pt((-1.5 - center[1]) / sqrt(scale[1, 1]), df))
}
m10_sensitivity <- function(q = 9, eta = .2, epsilon = .1) {
  if (any(!is.finite(c(q, eta, epsilon))) || q < 0 || eta < 0 || eta >= 1 || epsilon < 0) stop("Require q >= 0, 0 <= eta < 1 and epsilon >= 0.")
  tibble::tibble(radius_lower = max(sqrt(q) - epsilon, 0)^2 / (1 + eta), radius_upper = (sqrt(q) + epsilon)^2 / (1 - eta),
    efficiency_lower = 1 - eta^2, KL_bound_eta01 = .5 * 5 * (1 / .9 - 1 + log(.9)),
    absolute_event_bound_eta01 = sqrt(.25 * 5 * (1 / .9 - 1 + log(.9))),
    cantelli_at1645 = 1 / (1 + 1.645^2), frechet_both_lower = 0, frechet_both_upper = .05,
    three_test_two_low_lower = 0, three_test_two_low_upper = .15)
}
# Normalized Gauss--Legendre integration on [0,1]; weights already sum to one.
m10_uniform_rule <- function(n = 60L) {
  if (length(n) != 1 || n < 2 || n != floor(n)) stop("Require integer quadrature order >= 2.")
  k <- seq_len(n - 1); off <- k / sqrt(4 * k^2 - 1); J <- matrix(0, n, n)
  J[cbind(k, k + 1)] <- off; J[cbind(k + 1, k)] <- off
  eig <- eigen(J, symmetric = TRUE); i <- order(eig$values)
  list(node = (eig$values[i] + 1) / 2, weight = eig$vectors[1, i]^2)
}
m10_contamination <- function(epsilon = .05, order = 60L) {
  rule <- m10_uniform_rule(order); h <- rule$node; hw <- rule$weight
  uniform <- identical(epsilon, "uniform")
  if (!uniform && (length(epsilon) != 1 || !is.numeric(epsilon) || !is.finite(epsilon) || epsilon < 0 || epsilon >= 1)) stop("Require epsilon in [0,1), or 'uniform' for Uniform(0,.05).")
  es <- if (uniform) .05 * rule$node else epsilon; ew <- if (uniform) rule$weight else 1
  weights <- as.vector(outer(hw, ew)); H <- rep(h, times = length(es)); E <- rep(es, each = length(h))
  likelihood <- function(q) vapply(q, function(x) sum(weights * stats::dbinom(8, 100, (1 - E) * x + E * H)), numeric(1))
  integral <- function(upper = 1, moment = FALSE) {
    q <- upper * rule$node
    upper * sum(rule$weight * likelihood(q) * if (moment) q else 1)
  }
  Z <- integral(); limits <- vapply(c(.025, .975), function(p) stats::uniroot(function(q) integral(q) / Z - p, c(0, 1), tol = 1e-11)$root, numeric(1))
  ci <- m10_cp(8, 100)
  tibble::tibble(epsilon_model = if (uniform) "uniform_0_.05" else as.character(epsilon), posterior_mean = integral(moment = TRUE) / Z,
    posterior_lower = limits[1], posterior_upper = limits[2],
    sensitivity_lower = max(0, (.08 - .05) / .95), sensitivity_upper = .08 / .95,
    confidence_envelope_lower = max(0, (ci[1] - .05) / .95), confidence_envelope_upper = min(1, ci[2] / .95))
}
# Multivariate observed-score log density, with covariance-to-Student-scale conversion.
m10_log_density <- function(data, mean, covariance, nu = Inf) {
  data <- as.matrix(data); p <- ncol(data)
  C <- covariance * if (is.infinite(nu)) 1 else (nu - 2) / nu
  L <- chol(C); d <- t(backsolve(L, t(sweep(data, 2, mean)), transpose = TRUE)); q <- rowSums(d^2); logdet <- 2 * sum(log(diag(L)))
  if (is.infinite(nu)) return(-.5 * (p * log(2 * pi) + logdet + q))
  lgamma((nu + p) / 2) - lgamma(nu / 2) - .5 * (p * log(nu * pi) + logdet) - (nu + p) / 2 * log1p(q / nu)
}
m10_fit <- function(data, rank_transform = FALSE) {
  data <- as.matrix(data)
  if (nrow(data) < 3 || ncol(data) < 1 || any(!is.finite(data))) stop("Require at least three complete finite profiles.")
  lams <- c(.1, .4, .8, 1); nus <- if (rank_transform) Inf else c(3, 5, 10, 30, Inf)
  transform <- function(x, raw) {
    x <- as.matrix(x)
    out <- vapply(seq_len(ncol(raw)), function(j) vapply(x[, j], function(z) stats::qnorm((sum(raw[, j] < z) + .5 * sum(raw[, j] == z) + .5) / (nrow(raw) + 1)), numeric(1)), numeric(nrow(x)))
    matrix(out, nrow(x), ncol(raw))
  }
  cv <- matrix(0, length(nus), length(lams))
  for (i in seq_len(nrow(data))) {
    raw <- data[-i, , drop = FALSE]; train <- if (rank_transform) transform(raw, raw) else raw
    case <- if (rank_transform) transform(data[i, , drop = FALSE], raw) else data[i, , drop = FALSE]
    mean <- colMeans(train); S <- as.matrix(stats::cov(train)); tau <- max(mean(diag(S)), 1e-6)
    for (a in seq_along(nus)) for (b in seq_along(lams)) cv[a, b] <- cv[a, b] - sum(m10_log_density(case, mean, (1 - lams[b]) * S + lams[b] * tau * diag(ncol(data)), nus[a]))
  }
  # Candidate order is nu first, lambda second; exact ties retain that order.
  grid <- dplyr::bind_rows(lapply(seq_along(nus), function(i) tibble::tibble(nu = nus[i], lambda = lams, criterion = cv[i, ])))
  selected <- grid[which.min(grid$criterion), ]; train <- if (rank_transform) transform(data, data) else data
  S <- as.matrix(stats::cov(train)); tau <- max(mean(diag(S)), 1e-6); C <- (1 - selected$lambda) * S + selected$lambda * tau * diag(ncol(data))
  list(mean = colMeans(train), covariance = C, nu = selected$nu, lambda = selected$lambda, criterion = grid,
    raw = data, transform = transform, ranked = rank_transform)
}
m10_score <- function(data, fit) {
  x <- if (fit$ranked) fit$transform(data, fit$raw) else as.matrix(data)
  d <- sweep(x, 2, fit$mean); rowSums(d * t(solve(fit$covariance, t(d))))
}
m10_grid <- function(data, gaussian_prior = .2) {
  m10_probability(gaussian_prior); data <- as.matrix(data); R <- m10_reference(); v <- c(1, 1, 1, 0, 0)
  grid <- dplyr::bind_rows(lapply(c(-.5, 0, .5), function(m) dplyr::bind_rows(lapply(c(.7, 1, 1.5), function(s) tibble::tibble(location = m, covariance_scale = s, nu = c(3, 5, 10, 30, Inf))))))
  grid$log_likelihood <- vapply(seq_len(nrow(grid)), function(i) sum(m10_log_density(data, grid$location[i] * v, grid$covariance_scale[i] * R, grid$nu[i])), numeric(1))
  prior <- ifelse(is.infinite(grid$nu), gaussian_prior, (1 - gaussian_prior) / 4) / 9
  w <- exp(grid$log_likelihood + log(prior) - max(grid$log_likelihood + log(prior))); grid$weight <- w / sum(w)
  grid$event_probability <- vapply(seq_len(nrow(grid)), function(i) {
    z <- (-1.5 - grid$location[i]) / sqrt(grid$covariance_scale[i])
    if (is.infinite(grid$nu[i])) stats::pnorm(z) else stats::pt(z / sqrt((grid$nu[i] - 2) / grid$nu[i]), grid$nu[i])
  }, numeric(1)); grid
}
m10_conformal <- function(calibration_scores, new_score, alpha = .05) {
  m10_probability(alpha)
  if (length(new_score) != 1 || any(!is.finite(c(calibration_scores, new_score)))) stop("Scores must be finite; one new score is required.")
  m <- length(calibration_scores); k <- ceiling((m + 1) * (1 - alpha)); cutoff <- if (k > m) Inf else sort(calibration_scores)[k]
  tibble::tibble(calibration_size = m, rank = k, cutoff = cutoff, new_score = new_score, included = new_score <= cutoff,
    calibrated_tail = (1 + sum(calibration_scores >= new_score)) / (m + 1))
}
m10_calibration_laws <- function() {
  candidates <- 1:99; k <- candidates[stats::pbinom(candidates - 1, 99, .95) >= .95][1]
  tibble::tibble(minority_coverage = 1 - .95^9, marginal_coverage = 1 - .05 * .95^9,
    realized_content_below95_m19 = .95^19, content_sampling_lower_m99 = stats::qbeta(.025, 95, 5),
    content_sampling_upper_m99 = stats::qbeta(.975, 95, 5), tolerance_rank_m99 = k,
    tolerance_content_probability = stats::pbinom(k - 1, 99, .95))
}
m10_computation_laws <- function() {
  q <- c(.05, .5); w <- c(.3, .7); mean <- sum(w * q)
  tibble::tibble(zero_hits_budget = 10000L, zero_hits_one_sided_upper = -expm1(log(.05) / 10000),
    relative_error01_budget_at0001 = 1 / (.1^2 * .0001),
    nested_outer_variance_M1 = sum(w * (q - mean)^2), nested_inner_variance_M1_B2 = sum(w * q * (1 - q)) / 2,
    radius_quantile_MC_content_B2000 = stats::pbinom(1919, 2000, .95) - stats::pbinom(1879, 2000, .95))
}
