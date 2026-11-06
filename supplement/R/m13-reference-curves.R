# M13: deterministic teaching calculations for stated reference experiments.
# Exact mathematical laws are evaluated numerically. No patient scoring is provided.
# Entry points source m02-finite-reference.R for its checked NIG update helpers.
m13_scalar <- function(x, name, positive = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || (positive && x <= 0)) stop(name, " must be one finite", if (positive) " positive" else "", " number.", call. = FALSE)
}
m13_level <- function(p) {
  if (!is.numeric(p) || any(!is.finite(p) | p <= 0 | p >= 1)) stop("Levels must be strictly between zero and one.", call. = FALSE)
}
m13_post <- function(post) {
  m13_scalar(post$m, "posterior center")
  for (name in c("kappa", "a", "b")) m13_scalar(post[[name]], name, TRUE)
}
# For bounded Gamma expectations, omitted probability is at most 2*tail.
# integrate() error is additional; it is not a proof of the total numerical error.
m13_gamma_expect <- function(fun, shape, lower = 0, upper = Inf, tail = 1e-12) {
  m13_scalar(shape, "Gamma shape", TRUE)
  lo <- max(lower, stats::qgamma(tail, shape)); hi <- min(upper, stats::qgamma(tail, shape, lower.tail = FALSE))
  if (lo >= hi) return(0)
  stats::integrate(function(t) {
    u <- exp(t); vapply(u, fun, numeric(1)) * exp(stats::dgamma(u, shape, log = TRUE) + t)
  }, log(lo), log(hi), subdivisions = 500L, rel.tol = 2e-8, abs.tol = 2e-10)$value
}
m13_normal_gap <- function(lo, hi) {
  if (lo > 0) stats::pnorm(lo, lower.tail = FALSE) - stats::pnorm(hi, lower.tail = FALSE) else stats::pnorm(hi) - stats::pnorm(lo)
}
# The posterior factorization also describes the stated confidence region when
# post is the reference NIG update. A proper prior does not gain that guarantee.
m13_joint_region <- function(post, level = .95) {
  m13_post(post); m13_level(level)
  if (length(level) != 1L) stop("One region level required.")
  component <- sqrt(level); tail <- (1 - component) / 2
  tibble::tibble(center = post$m, coefficient = stats::qnorm((1 + component) / 2) / sqrt(post$kappa), sd_lower = sqrt(2 * post$b / stats::qchisq(tail, 2 * post$a, lower.tail = FALSE)), sd_upper = sqrt(2 * post$b / stats::qchisq(tail, 2 * post$a)), level = level, component_probability = component)
}
m13_envelope <- function(scores, region) {
  if (!is.numeric(scores) || any(!is.finite(scores)) || nrow(region) != 1L || region$sd_lower <= 0 || region$sd_upper < region$sd_lower) stop("Finite scores and one ordered positive-SD region required.")
  delta <- scores - region$center
  tibble::tibble(score = scores, lower = stats::pnorm(delta / ifelse(delta < 0, region$sd_lower, region$sd_upper) - region$coefficient), upper = stats::pnorm(delta / ifelse(delta < 0, region$sd_upper, region$sd_lower) + region$coefficient))
}
m13_range_mass <- function(mean, sd, lower, upper) {
  m13_scalar(mean, "mean"); m13_scalar(sd, "SD", TRUE)
  if (!is.finite(lower) || !is.finite(upper) || lower >= upper) stop("Finite ordered range endpoints required.")
  m13_normal_gap((lower - mean) / sd, (upper - mean) / sd)
}
m13_range_bounds <- function(region, lower, upper) {
  m13_range_mass(region$center, region$sd_lower, lower, upper)
  e <- m13_envelope(c(lower, upper), region)
  c(lower = max(0, e$lower[2] - e$upper[1]), upper = min(e$upper[2] - e$lower[1], 2 * stats::pnorm((upper - lower) / (2 * region$sd_lower)) - 1))
}
# Complement the conditional mean-interval probability; do not subtract two
# marginal percentile quantiles. Inputs are fixed endpoints, not learned cutoffs.
m13_range_cdf <- function(p, post, lower = 35, upper = 65) {
  m13_post(post); m13_range_mass(post$m, 1, lower, upper); m13_scalar(p, "fraction")
  if (p <= 0) return(0)
  if (p >= 1) return(1)
  center <- (lower + upper) / 2; half <- (upper - lower) / 2
  vp <- (half / stats::qnorm((1 + p) / 2))^2
  survival <- m13_gamma_expect(function(u) {
    v <- post$b / u
    if (v >= vp) return(0)
    # This upper bracket makes even the nearer normal tail less than p.
    bound <- half - sqrt(v) * stats::qnorm(p / 2)
    d <- stats::uniroot(function(distance) m13_range_mass(center + distance, sqrt(v), lower, upper) - p, c(0, bound), tol = 1e-10)$root
    m13_normal_gap((center - d - post$m) * sqrt(post$kappa / v), (center + d - post$m) * sqrt(post$kappa / v))
  }, post$a, lower = post$b / vp)
  min(1, max(0, 1 - survival))
}
m13_range_summary <- function(post, lower = 35, upper = 65) {
  m13_post(post); scale <- sqrt(post$b / post$a * (1 + 1 / post$kappa))
  quantiles <- vapply(c(.025, .5, .975), function(p) stats::uniroot(function(q) m13_range_cdf(q, post, lower, upper) - p, c(1e-9, 1 - 1e-9), tol = 1e-8)$root, numeric(1))
  bounds <- m13_range_bounds(m13_joint_region(post), lower, upper)
  tibble::tibble(range_lower = lower, range_upper = upper, posterior_mean = stats::pt((upper - post$m) / scale, 2 * post$a) - stats::pt((lower - post$m) / scale, 2 * post$a), credible_lower = quantiles[1], posterior_median = quantiles[2], credible_upper = quantiles[3], transferred_lower = unname(bounds[1]), transferred_upper = unname(bounds[2]))
}
# Exact finite stationary-point characterization, numerically evaluated with
# stable quadratic roots. A finite plotting/search grid is not the supremum.
m13_normal_distance <- function(shift, scale_ratio) {
  m13_scalar(shift, "shift"); m13_scalar(scale_ratio, "scale ratio", TRUE)
  h <- abs(shift); r <- scale_ratio
  if (r == 1) return(2 * stats::pnorm(h / 2) - 1)
  a2 <- expm1(2 * log(r)); a1 <- 2 * h; a0 <- -h^2 - 2 * r^2 * log(r)
  disc <- sqrt(a1^2 - 4 * a2 * a0); w <- -(a1 + disc) / 2
  roots <- c(w / a2, a0 / w)
  max(vapply(roots, function(t) abs(m13_normal_gap(min(t, (t - h) / r), max(t, (t - h) / r))), numeric(1)))
}
m13_shift_bound <- function(p, r) {
  d0 <- m13_normal_distance(0, r)
  if (p <= d0) return(0)
  hi <- 1
  while (m13_normal_distance(hi, r) < p) { hi <- hi * 2; if (hi > 1e8) stop("Shift bracket exceeds supported numerical range.") }
  stats::uniroot(function(h) m13_normal_distance(h, r) - p, c(0, hi), tol = 1e-10)$root
}
# Keep the realized fit unchanged while candidate population parameters vary.
m13_error_cdf <- function(p, post, fitted_mean = 50, fitted_sd = 10) {
  m13_scalar(p, "error"); m13_post(post); m13_scalar(fitted_mean, "fitted mean"); m13_scalar(fitted_sd, "fitted SD", TRUE)
  if (p <= 0) return(0)
  if (p >= 1) return(1)
  lo <- 0; hi <- Inf
  if (p < .5) {
    extent <- 2
    while (m13_normal_distance(0, extent) < p) extent <- extent * 2
    rmax <- stats::uniroot(function(r) m13_normal_distance(0, r) - p, c(1, extent), tol = 1e-10)$root
    lo <- post$b / fitted_sd^2 / rmax^2; hi <- post$b / fitted_sd^2 * rmax^2
  }
  delta <- (post$m - fitted_mean) / fitted_sd
  m13_gamma_expect(function(u) {
    r <- fitted_sd * sqrt(u / post$b); bound <- m13_shift_bound(p, r)
    m13_normal_gap(sqrt(post$kappa) * (-bound + delta * r), sqrt(post$kappa) * (bound + delta * r))
  }, post$a, lo, hi)
}
m13_error_summary <- function(post, fitted_mean = 50, fitted_sd = 10) {
  q <- vapply(c(.5, .95), function(p) stats::uniroot(function(x) m13_error_cdf(x, post, fitted_mean, fitted_sd) - p, c(1e-5, .99999), tol = 1e-8)$root, numeric(1))
  tibble::tibble(median_error = q[1], upper_error_95 = q[2], probability_error_at_most_point20 = m13_error_cdf(.2, post, fitted_mean, fitted_sd))
}
# Known attainable support is supplied separately from counts; zero counts are
# retained. The inclusive empirical cutoff is frozen for posterior content.
m13_discrete <- function(counts = c(1, 2, 4, 3), support = 0:3, prior = rep(1, length(counts)), u = .2, alpha = .05) {
  m <- length(counts)
  if (m < 2 || length(support) != m || length(prior) != m || any(!is.finite(c(counts, support, prior))) || any(counts < 0 | counts != floor(counts)) || any(diff(support) <= 0) || any(prior <= 0) || sum(counts) < 1) stop("Supply ordered known support, nonnegative integer counts, positive prior shapes and positive sample size.")
  m13_level(c(u, alpha)); n <- sum(counts); k <- cumsum(counts); b <- prior + counts; total <- sum(b); B <- cumsum(b)
  cp <- t(vapply(k[-m], function(x) c(if (x == 0) 0 else stats::qbeta(alpha / (2 * (m - 1)), x, n - x + 1), if (x == n) 1 else stats::qbeta(1 - alpha / (2 * (m - 1)), x + 1, n - x)), numeric(2)))
  lower <- c(cp[, 1], 1); upper <- c(cp[, 2], 1)
  tail <- c(1, stats::pbeta(u, B[-m], total - B[-m]), 0)
  J <- max(c(0, which(k / n <= u)))
  selected <- if (J == 0) c(0, 0, 0) else c(B[J] / total, stats::qbeta(c(.025, .975), B[J], total - B[J]))
  list(cdf = tibble::tibble(score = support, count = counts, empirical_inclusive = k / n, confidence_lower = lower, confidence_upper = upper, posterior_mean_cdf = B / total, posterior_shape = b),
       quantile = tibble::tibble(level = u, score = support, posterior_quantile_mass = tail[-length(tail)] - tail[-1]),
       selected = tibble::tibble(level = u, selected_index = J, largest_flagged_score = if (J == 0) NA_real_ else support[J], posterior_content_mean = selected[1], credible_lower = selected[2], credible_upper = selected[3], simultaneous_lower = if (J == 0) 0 else lower[J], simultaneous_upper = if (J == 0) 0 else upper[J]))
}
# Enumerate the complete four-category training experiment for the supplied
# population probabilities. These probabilities are not inferred from counts.
m13_discrete_refitting <- function(n = 10L, probability = c(.1, .2, .4, .3), u = .2) {
  if (length(probability) != 4 || any(!is.finite(probability) | probability < 0) || abs(sum(probability) - 1) > 1e-12 || length(n) != 1 || !is.finite(n) || n < 1 || n != floor(n) || n > 60) stop("Four probabilities summing to one and integer 1<=n<=60 required.")
  m13_level(u)
  grid <- expand.grid(count0 = 0:n, count1 = 0:n, count2 = 0:n)
  grid <- grid[rowSums(grid) <= n, , drop = FALSE]; grid$count3 <- n - rowSums(grid)
  rows <- lapply(seq_len(nrow(grid)), function(i) {
    k <- as.numeric(grid[i, ]); J <- max(c(0, which(cumsum(k) / n <= u)))
    tibble::tibble(count0 = k[1], count1 = k[2], count2 = k[3], count3 = k[4], selected_index = J, achieved_content = c(0, cumsum(probability))[J + 1], training_probability = stats::dmultinom(k, prob = probability))
  })
  dplyr::bind_rows(rows)
}
# Gauss-Legendre rule on a finite shape interval; weights integrate Lebesgue
# measure before multiplication by the shape prior and full marginal likelihood.
m13_shape_rule <- function(n = 64L, lower = .5, upper = 2) {
  if (length(n) != 1 || n < 2 || n != floor(n) || !is.finite(n) || !is.finite(lower) || !is.finite(upper) || lower <= 0 || lower >= upper) stop("Positive compact shape bounds and integer nodes>=2 required.")
  i <- 1:(n - 1); J <- matrix(0, n, n); J[cbind(i, i + 1)] <- i / sqrt(4 * i^2 - 1); J <- J + t(J)
  e <- eigen(J, symmetric = TRUE); ix <- order(e$values)
  tibble::tibble(shape = (upper + lower) / 2 + (upper - lower) / 2 * e$values[ix], integration_weight = (upper - lower) * e$vectors[1, ix]^2)
}
m13_shape_fit <- function(raw, lower = .5, upper = 2, nodes = 64L, origin = 50, unit = 10, prior = list(m = 0, kappa = 1, a = 2, b = 1)) {
  if (!is.numeric(raw) || any(!is.finite(raw)) || length(raw) < 2) stop("At least two finite raw observations required.")
  m13_scalar(origin, "external origin"); m13_scalar(unit, "external unit", TRUE); m13_post(prior)
  rule <- m13_shape_rule(nodes, lower, upper); x <- (raw - origin) / unit
  rows <- lapply(seq_len(nrow(rule)), function(i) {
    omega <- rule$shape[i]; t <- asinh(x / omega); post <- m02_posterior(length(raw), mean(t), stats::sd(t), prior)
    tibble::tibble(shape = omega, center = post$m, kappa = post$kappa, a = post$a, b = post$b, log_jacobian = -length(raw) * log(unit) - .5 * sum(log(omega^2 + x^2)))
  })
  d <- dplyr::bind_rows(rows); logw <- d$log_jacobian - d$a * log(d$b)
  # Uniform shape-prior density is constant within each separately chosen range.
  w <- rule$integration_weight * exp(logw - max(logw)); d$posterior_weight <- w / sum(w)
  list(grid = d, origin = origin, unit = unit, shape_lower = lower, shape_upper = upper, nodes = nodes)
}
m13_shape_cdf <- function(fit, value, target = c("prediction", "percentile", "quantile"), case_score = 35, level = .05) {
  target <- match.arg(target); m13_scalar(value, "CDF argument"); m13_scalar(case_score, "case score"); m13_level(level)
  d <- fit$grid
  if (target == "percentile" && value <= 0) return(0)
  if (target == "percentile" && value >= 1) return(1)
  transform <- function(y) asinh((y - fit$origin) / (fit$unit * d$shape))
  probability <- switch(target,
    prediction = stats::pt((transform(value) - d$center) / sqrt(d$b / d$a * (1 + 1 / d$kappa)), 2 * d$a),
    percentile = {
      t <- sqrt(d$kappa) * (transform(case_score) - d$center) * sqrt(d$a / d$b)
      ncp <- sqrt(d$kappa) * stats::qnorm(value)
      vapply(seq_len(nrow(d)), function(i) m02_chi_expect(function(s) stats::pnorm(ncp[i] - t[i] * s / sqrt(2 * d$a[i])), 2 * d$a[i]), numeric(1))
    },
    quantile = {
      t <- (transform(value) - d$center) / sqrt(d$b / (d$a * d$kappa)); ncp <- sqrt(d$kappa) * stats::qnorm(level)
      vapply(seq_len(nrow(d)), function(i) m02_chi_expect(function(s) stats::pnorm(t[i] * s / sqrt(2 * d$a[i]) - ncp[i]), 2 * d$a[i]), numeric(1))
    })
  sum(d$posterior_weight * probability)
}
m13_shape_quantiles <- function(fit, target, probabilities = c(.025, .5, .975), case_score = 35, level = .05) {
  m13_level(probabilities)
  vapply(probabilities, function(p) {
    fun <- function(q) m13_shape_cdf(fit, q, target, case_score, level) - p
    if (target == "percentile") bracket <- c(1e-10, 1 - 1e-10) else {
      width <- fit$unit * 4; bracket <- fit$origin + c(-width, width)
      for (i in seq_len(16)) {
        if (fun(bracket[1]) <= 0 && fun(bracket[2]) >= 0) break
        width <- width * 2; bracket <- fit$origin + c(-width, width)
      }
      if (fun(bracket[1]) > 0 || fun(bracket[2]) < 0) stop("Raw-score mixture quantile not bracketed.")
    }
    stats::uniroot(fun, bracket, tol = 1e-8)$root
  }, numeric(1))
}
m13_shape_summary <- function(fit, case_score = 35) {
  p <- m13_shape_quantiles(fit, "percentile", case_score = case_score)
  q <- m13_shape_quantiles(fit, "quantile")
  new <- m13_shape_quantiles(fit, "prediction", c(.025, .975))
  tibble::tibble(shape_lower = fit$shape_lower, shape_upper = fit$shape_upper, nodes = fit$nodes, posterior_shape_mean = sum(fit$grid$shape * fit$grid$posterior_weight), predictive_tail = m13_shape_cdf(fit, case_score), percentile_lower = p[1], percentile_median = p[2], percentile_upper = p[3], fifth_score_lower = q[1], fifth_score_median = q[2], fifth_score_upper = q[3], new_score_lower = new[1], new_score_upper = new[2])
}
# Raw order-statistic band, not numerical projection over the shape parameter
# set. Ties are excluded because this benchmark assumes a continuous law.
m13_order_benchmark <- function(raw, score = 35, alpha = .05) {
  if (length(raw) < 2 || any(!is.finite(raw)) || anyDuplicated(raw)) stop("Distinct finite continuous-score observations required.")
  m13_scalar(score, "evaluation score"); m13_level(alpha); n <- length(raw); ordered <- sort(raw); j <- sum(ordered <= score)
  lower <- c(0, stats::qbeta(alpha / (2 * n), 1:n, n:1))
  upper <- c(stats::qbeta(1 - alpha / (2 * n), 1:n, n:1), 1)
  tibble::tibble(score = score, scores_at_or_below = j, confidence_lower = lower[j + 1], confidence_upper = upper[j + 1], minmax_prediction_coverage = (n - 1) / (n + 1), one_infinite_endpoint_coverage = n / (n + 1))
}
# Selected asinh-family regression example. This returns posterior prediction;
# no local optimizer is advertised as a global confidence projection.
m13_transformed_regression <- function(nodes = 64L, x0 = c(1, 3), case_score = 45) {
  x <- c(-5:-1, 1:5); X <- cbind(1, x); raw <- 50 + 2 * x + sqrt(50 / 187) * (x^2 - 11)
  if (length(x0) != 2 || any(!is.finite(x0))) stop("Two finite externally supplied predictor entries required.")
  K0 <- diag(c(1, 10)); K <- K0 + crossprod(X); ell <- drop(crossprod(x0, solve(K, x0))); a <- 7
  rule <- m13_shape_rule(nodes); rows <- lapply(rule$shape, function(omega) {
    t <- asinh((raw - 50) / (10 * omega)); m <- solve(K, crossprod(X, t)); b <- 1 + .5 * (sum((t - X %*% m)^2) + drop(crossprod(m, K0 %*% m)))
    tibble::tibble(shape = omega, center = sum(x0 * m), b = b, log_jacobian = -10 * log(10) - .5 * sum(log(omega^2 + ((raw - 50) / 10)^2)))
  }); d <- dplyr::bind_rows(rows); logw <- d$log_jacobian - a * log(d$b); w <- rule$integration_weight * exp(logw - max(logw)); w <- w / sum(w)
  y <- asinh((case_score - 50) / (10 * d$shape)); p <- stats::pt((y - d$center) / sqrt(d$b / a * (1 + ell)), 2 * a)
  alternate <- vapply(seq_len(nrow(d)), function(i) m13_gamma_expect(function(u) stats::pnorm((y[i] - d$center[i]) * sqrt(u / d$b[i]) / sqrt(1 + ell)), a), numeric(1))
  tibble::tibble(nodes = nodes, case_score = case_score, x0_intercept = x0[1], x0_predictor = x0[2], coefficient_variance_multiplier = ell, predictive_tail = sum(w * p), normal_precision_tail = sum(w * alternate))
}
m13_tables <- function(nodes = 64L) {
  raw <- c(50 - (1:10) * sqrt(190 / 77), 50 + (1:10) * sqrt(190 / 77))
  posts <- list(reference = m02_posterior(20, mean(raw), stats::sd(raw)), proper_teaching = m02_posterior(20, mean(raw), stats::sd(raw), list(m = 50, kappa = 5, a = 3, b = 200)))
  bind_branch <- function(fun) dplyr::bind_rows(lapply(names(posts), function(branch) dplyr::mutate(fun(posts[[branch]]), branch = branch, .before = 1)))
  region <- bind_branch(m13_joint_region)
  curves <- bind_branch(function(post) m13_envelope(c(35, 50, 65), m13_joint_region(post)))
  errors <- bind_branch(m13_error_summary); radius <- errors$upper_error_95[1]
  scores <- c(35, 50, 65); plug <- stats::pnorm((scores - mean(raw)) / stats::sd(raw))
  discrete <- m13_discrete(); refit <- m13_discrete_refitting()
  fits <- list(narrow = m13_shape_fit(raw, nodes = nodes), wide = m13_shape_fit(raw, .25, 4, nodes))
  shape <- dplyr::bind_rows(lapply(fits, m13_shape_summary))
  grids <- dplyr::bind_rows(lapply(names(fits), function(branch) dplyr::mutate(fits[[branch]]$grid, branch = branch, .before = 1)))
  list(raw_inputs = tibble::tibble(person = seq_along(raw), raw_score = raw),
       normal_posteriors = bind_branch(function(p) tibble::as_tibble(p)),
       joint_regions = region, simultaneous_score_bounds = curves,
       range_fraction = bind_branch(m13_range_summary), fitted_curve_error = errors,
       calibrated_band = tibble::tibble(score = scores, fitted_percentile = plug, confidence_lower = pmax(0, plug - radius), confidence_upper = pmin(1, plug + radius), radius = radius),
       discrete_cdf = discrete$cdf, discrete_quantile = discrete$quantile, discrete_selected_content = discrete$selected,
       discrete_refitting = refit,
       discrete_refitting_summary = tibble::tibble(training_count_vectors = nrow(refit), probability_mass_sum = sum(refit$training_probability), probability_content_at_most_point20 = sum(refit$training_probability[refit$achieved_content <= .2]), mean_content_across_refitting = sum(refit$training_probability * refit$achieved_content)),
       shape_sensitivity = shape, shape_posterior_grid = grids,
       order_statistic_benchmark = m13_order_benchmark(raw),
       transformed_regression = m13_transformed_regression(nodes))
}
