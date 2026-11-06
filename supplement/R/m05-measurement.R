# M05 synthetic measurement calculations. All variances are in squared score units.
# Functions are sourced by the reader script; no project package installation needed.

m05_positive <- function(x, label, zero = FALSE) {
  if (!is.numeric(x) || any(!is.finite(x)) || any(if (zero) x < 0 else x <= 0)) {
    stop(label, if (zero) " must be finite and nonnegative." else " must be finite and positive.", call. = FALSE)
  }
  invisible(x)
}

# Four procedures in exactly the same scalar observation/target experiment.
m05_scalar <- function(y = 35, mean = 50, stable = 64, noise = 36, level = .95) {
  m05_positive(c(stable, noise), "Variances")
  if (length(y) != 1 || !is.finite(y) || length(mean) != 1 || !is.finite(mean) ||
      length(level) != 1 || !is.finite(level) || level <= 0 || level >= 1) stop("Invalid scalar input.")
  gain <- stable / (stable + noise)
  center <- mean + gain * (y - mean)
  variance <- gain * noise
  z <- stats::qnorm((1 + level) / 2)
  tibble::tibble(
    procedure = c("Likelihood confidence", "Credible", "Likelihood prediction", "Posterior predictive"),
    target = c("Expected score", "Expected score", "Next score", "Next score"),
    center = c(y, center, y, center),
    variance = c(noise, variance, 2 * noise, variance + noise)
  ) |>
    dplyr::mutate(lower = center - z * sqrt(variance), upper = center + z * sqrt(variance), level = level)
}

# Coverage repeats data at fixed tau; it does not condition on the observed y=35.
m05_coverage <- function(tau = seq(0, 100, by = .25), mean = 50, stable = 64, noise = 36, level = .95) {
  m05_positive(c(stable, noise), "Variances")
  if (any(!is.finite(tau)) || level <= 0 || level >= 1) stop("Invalid coverage input.")
  gain <- stable / (stable + noise)
  z <- stats::qnorm((1 + level) / 2)
  bias <- (1 - gain) * (mean - tau)
  half <- z * sqrt(gain * noise)
  credible <- stats::pnorm((half - bias) / (gain * sqrt(noise))) -
    stats::pnorm((-half - bias) / (gain * sqrt(noise)))
  pred_sd <- sqrt(noise * (1 + gain^2))
  pred_half <- z * sqrt(noise * (1 + gain))
  pred_bias <- -bias
  predictive <- stats::pnorm((pred_half - pred_bias) / pred_sd) -
    stats::pnorm((-pred_half - pred_bias) / pred_sd)
  tibble::tibble(tau = tau, confidence_and_likelihood_prediction = level,
                 credible = credible, posterior_predictive = predictive,
                 prior_density = stats::dnorm(tau, mean, sqrt(stable)))
}

m05_replication <- function(stable = 64, noise = 36, repeats = 4, common = 0) {
  m05_positive(c(stable, noise), "Variances", zero = TRUE)
  if (length(repeats) != 1 || repeats < 2 || repeats != as.integer(repeats) ||
      common < -noise / (repeats - 1) || common > noise || stable + noise <= 0) stop("Invalid finite-repeat covariance.")
  error <- noise / repeats + (repeats - 1) * common / repeats
  tibble::tibble(stable = stable, noise = noise, repeats = repeats, common = common,
    single_reliability = stable / (stable + noise), repeat_correlation = (stable + common) / (stable + noise),
    average_error_variance = error, average_reliability = stable / (stable + error), error_sd = sqrt(error))
}

m05_binary <- function(success = 2, repeats = 8, a = 2, b = 2, level = .95) {
  m05_positive(c(a, b), "Beta shapes")
  if (repeats < 1 || repeats != as.integer(repeats) || success < 0 || success > repeats ||
      success != as.integer(success) || level <= 0 || level >= 1) stop("Invalid binomial input.")
  tail <- (1 - level) / 2
  tibble::tibble(success = success, repeats = repeats,
    confidence_lower = if (success == 0) 0 else stats::qbeta(tail, success, repeats - success + 1),
    confidence_upper = if (success == repeats) 1 else stats::qbeta(1 - tail, success + 1, repeats - success),
    posterior_a = a + success, posterior_b = b + repeats - success,
    posterior_mean = (a + success) / (a + b + repeats),
    credible_lower = stats::qbeta(tail, a + success, b + repeats - success),
    credible_upper = stats::qbeta(1 - tail, a + success, b + repeats - success),
    population_single_reliability = 1 / (a + b + 1), average_reliability = repeats / (repeats + a + b))
}

# Component order is always P,T,R,PT,PR,TR,e. J/K are future design sizes.
m05_gt <- function(theta = c(64, 9, 4, 16, 9, 4, 36), J = 4, K = 2, fixed_raters = FALSE) {
  m05_positive(theta, "Components", zero = TRUE)
  if (length(theta) != 7 || J < 1 || K < 1 || J != as.integer(J) || K != as.integer(K)) stop("Invalid GT design.")
  p <- theta[1] + if (fixed_raters) theta[5] / K else 0
  relative <- theta[4] / J + theta[7] / (J * K) + if (fixed_raters) 0 else theta[5] / K
  absolute <- relative + theta[2] / J + theta[6] / (J * K) + if (fixed_raters) 0 else theta[3] / K
  if (p + relative <= 0 || p + absolute <= 0) stop("Undefined coefficient denominator.")
  tibble::tibble(J = J, K = K, fixed_raters = fixed_raters, person_variance = p,
    relative_error = relative, absolute_error = absolute, relative_coefficient = p / (p + relative),
    absolute_coefficient = p / (p + absolute), absolute_sd = sqrt(absolute))
}

m05_crossed_map <- function(n = 20, J = 4, K = 2) {
  if (any(c(n, J, K) < 2) || any(c(n, J, K) != as.integer(c(n, J, K)))) stop("Crossed calibration needs at least two levels per factor.")
  A <- rbind(c(0, 0, 0, 0, 0, 0, 1), c(0, 0, 0, K, 0, 0, 1),
    c(0, 0, 0, 0, J, 0, 1), c(0, 0, 0, 0, 0, n, 1),
    c(J * K, 0, 0, K, J, 0, 1), c(0, n * K, 0, K, 0, n, 1),
    c(0, 0, n * J, 0, J, n, 1))
  dimnames(A) <- list(c("e", "PT", "PR", "TR", "P", "T", "R"), c("P", "T", "R", "PT", "PR", "TR", "e"))
  list(A = A, df = c((n - 1) * (J - 1) * (K - 1), (n - 1) * (J - 1),
    (n - 1) * (K - 1), (J - 1) * (K - 1), n - 1, J - 1, K - 1),
    v0_weights = c(1/n, 1/J, 1/K, 1/(n*J), 1/(n*K), 1/(J*K), 1/(n*J*K)))
}

# Signed inverse-map box, not an unchecked optimizer or a sharp confidence region.
m05_crossed_box <- function(mean_squares = c(36, 68, 72, 116, 616, 508, 472), alpha = .05, n = 20, J = 4, K = 2) {
  m05_positive(mean_squares, "Mean squares")
  if (length(mean_squares) != 7 || alpha <= 0 || alpha >= 1) stop("Invalid confidence inputs.")
  design <- m05_crossed_map(n, J, K)
  epsilon <- 1 - (1 - alpha)^(1/7)
  lower <- design$df * mean_squares / stats::qchisq(1 - epsilon/2, design$df)
  upper <- design$df * mean_squares / stats::qchisq(epsilon/2, design$df)
  inverse <- solve(design$A)
  plus <- pmax(inverse, 0); minus <- pmin(inverse, 0)
  lo <- pmax(0, as.vector(plus %*% lower + minus %*% upper))
  hi <- as.vector(plus %*% upper + minus %*% lower)
  list(component = tibble::tibble(component = colnames(design$A), lower = lo, upper = hi),
    lambda_lower = lower, lambda_upper = upper, epsilon = epsilon, empty = any(hi < lo))
}

m05_box_design <- function(box, J = 4, K = 2, sharpen_original = FALSE) {
  if (box$empty) return(tibble::tibble(J = J, K = K, lower = NA_real_, relative_upper = NA_real_, absolute_upper = NA_real_))
  lo <- box$component$lower; hi <- box$component$upper
  low_error <- m05_gt(lo, J, K); high_error <- m05_gt(hi, J, K)
  ru <- hi[1] / (hi[1] + low_error$relative_error)
  au <- hi[1] / (hi[1] + low_error$absolute_error)
  if (sharpen_original) {
    bound <- 1 - max(box$lambda_lower[2:3]) / box$lambda_upper[5]
    ru <- min(ru, bound); au <- min(au, bound)
  }
  tibble::tibble(J = J, K = K, lower = lo[1] / (lo[1] + high_error$absolute_error), relative_upper = ru, absolute_upper = au)
}

m05_oneway <- function(B = 144, W = 36, n = 20, m = 3, alpha = .05) {
  m05_positive(c(B, W), "Mean squares")
  if (length(n) != 1 || length(m) != 1 || any(!is.finite(c(n,m))) || any(c(n,m) != as.integer(c(n,m))) || n < 2 || m < 2 || alpha <= 0 || alpha >= 1) stop("Invalid one-way design.")
  quantile <- stats::qf(c(alpha/2, 1 - alpha/2), n - 1, n * (m - 1))
  upper <- (B / W / quantile[1] - 1) / m
  lower <- max(0, (B / W / quantile[2] - 1) / m)
  if (upper < 0) lower <- NA_real_
  tibble::tibble(eta_lower = lower, eta_upper = if (upper < 0) NA_real_ else upper,
    empty = upper < 0, reliability_lower = lower / (1 + lower),
    reliability_upper = if (upper < 0) NA_real_ else upper / (1 + upper),
    mean_reliability_lower = m * lower / (1 + m * lower),
    mean_reliability_upper = if (upper < 0) NA_real_ else m * upper / (1 + m * upper))
}

m05_weighted_quantile <- function(x, weight, probs = c(.025, .5, .975)) {
  if (length(x) != length(weight) || any(weight < 0) || sum(weight) <= 0) stop("Invalid integration weights.")
  order <- order(x); cumulative <- cumsum(weight[order]); cumulative <- cumulative / tail(cumulative, 1)
  stats::approx(cumulative, x[order], xout = probs, rule = 2, ties = "ordered")$y
}

# A finite log-scale grid is a quadrature approximation; Jacobian a*e is included.
m05_oneway_posterior <- function(points = 801) {
  if (points < 100 || points != as.integer(points)) stop("At least100 grid points required.")
  a <- exp(seq(log(.001), log(2000), length.out = points))
  e <- exp(seq(log(5), log(200), length.out = points))
  grid <- tidyr::expand_grid(a = a, e = e)
  lambda <- grid$e + 3 * grid$a
  log_weight <- -19/2 * log(lambda) - 19*144/(2*lambda) - 40/2*log(grid$e) - 40*36/(2*grid$e) +
    stats::dnorm(50, 50, sqrt(400 + lambda/60), log = TRUE) +
    stats::dgamma(1/grid$a, 3, rate = 128, log = TRUE) - 2*log(grid$a) +
    stats::dgamma(1/grid$e, 3, rate = 72, log = TRUE) - 2*log(grid$e) + log(grid$a) + log(grid$e)
  weight <- exp(log_weight - max(log_weight)); weight <- weight / sum(weight)
  rho <- grid$a / (grid$a + grid$e)
  q <- m05_weighted_quantile(rho, weight)
  tibble::tibble(points_per_axis = points, mean = sum(weight * rho), lower = q[1], median = q[2], upper = q[3])
}

m05_state_calibration <- function() {
  epsilon <- 1 - sqrt(.95)
  u <- 209 / stats::qchisq(c(1 - epsilon/2, epsilon/2), 19)
  r <- 80 / stats::qchisq(c(1 - epsilon/2, epsilon/2), 20)
  scale <- 48/253
  normalization <- stats::pf(1/scale, 26, 26)
  density <- function(x) stats::df(x/scale, 26, 26) / scale / normalization
  h <- function(x) (1 - x) / (1 + x)
  cdf <- function(z) {
    cut <- (1 - z) / (1 + z)
    stats::integrate(function(x) pmin(1, z/h(x)) * density(x), 0, cut, rel.tol = 1e-10)$value +
      stats::integrate(density, cut, 1, rel.tol = 1e-10)$value
  }
  q <- vapply(c(.025, .5, .975), function(p) stats::uniroot(function(z) cdf(z) - p, c(1e-10, 1 - 1e-10), tol = 1e-10)$root, numeric(1))
  mean_h <- stats::integrate(function(x) h(x) * density(x), 0, 1, rel.tol = 1e-10)$value
  tibble::tibble(u_lower = u[1], u_upper = u[2], r_lower = r[1], r_upper = r[2],
    share_confidence_lower = 0, share_confidence_upper = (u[2] - r[1]/2) / (u[2] + r[1]/2),
    unrestricted_probability = normalization, uniform_split_mean = .5 * mean_h,
    uniform_split_lower = q[1], uniform_split_median = q[2], uniform_split_upper = q[3], beta82_split_mean = .8 * mean_h)
}

# Deterministic shifted Halton integration of independent unit uniforms.
# This is NOT an independent sample of posterior draws, nor a coverage proof.
m05_halton <- function(points, skip = 128, shift = 1) {
  if (points < 2 || points != as.integer(points) || skip < 0 || skip != as.integer(skip)) stop("Invalid integration size.")
  primes <- c(2, 3, 5, 7, 11, 13, 17)
  vapply(seq_along(primes), function(j) {
    index <- seq_len(points) + skip; value <- numeric(points); factor <- 1 / primes[j]
    while (any(index > 0)) {
      value <- value + (index %% primes[j]) * factor
      index <- floor(index / primes[j]); factor <- factor / primes[j]
    }
    (value + (sqrt(primes[j]) * shift) %% 1) %% 1
  }, numeric(points))
}

m05_mixture <- function(mean, variance, weight) {
  m05_positive(variance, "Conditional variances")
  weight <- weight / sum(weight)
  center <- sum(mean * weight)
  within <- sum(variance * weight); between <- sum(weight * (mean - center)^2)
  limits <- c(min(mean - 12 * sqrt(variance)), max(mean + 12 * sqrt(variance)))
  q <- vapply(c(.025, .975), function(p) stats::uniroot(function(x)
    sum(weight * stats::pnorm((x - mean)/sqrt(variance))) - p, limits, tol = 1e-7)$root, numeric(1))
  tibble::tibble(mean = center, variance = within + between, within = within, between = between, lower = q[1], upper = q[2])
}

m05_crossed_posterior <- function(points = 2^18, shape = 3, shift = 1, person = TRUE) {
  m05_positive(shape, "Inverse-gamma shape")
  if (shape <= 2) stop("This companion uses finite-second-moment priors with shape>2.")
  component_mean <- c(64, 9, 4, 16, 9, 4, 36)
  u <- m05_halton(points, shift = shift)
  theta <- vapply(seq_len(7), function(j) (shape - 1) * component_mean[j] /
    stats::qgamma(1 - u[, j], shape), numeric(points))
  design <- m05_crossed_map()
  lambda <- theta %*% t(design$A)
  v0 <- as.vector(theta %*% design$v0_weights)
  ms <- c(36, 68, 72, 116, 616, 508, 472)
  ll <- as.vector(-.5 * log(lambda) %*% design$df - .5 * (1/lambda) %*% (design$df * ms)) +
    stats::dnorm(50, 50, sqrt(400 + v0), log = TRUE)
  weight <- exp(ll - max(ll)); weight <- weight / sum(weight)
  error <- function(J, K, absolute = FALSE) {
    value <- theta[,4]/J + theta[,5]/K + theta[,7]/(J*K)
    if (absolute) value <- value + theta[,2]/J + theta[,3]/K + theta[,6]/(J*K)
    value
  }
  coefficients <- dplyr::bind_rows(lapply(list(c(4,2), c(8,2), c(4,4)), function(jk) {
    rel <- theta[,1]/(theta[,1] + error(jk[1],jk[2]))
    abs <- theta[,1]/(theta[,1] + error(jk[1],jk[2],TRUE))
    rq <- m05_weighted_quantile(rel, weight, c(.025,.975)); aq <- m05_weighted_quantile(abs, weight, c(.025,.975))
    tibble::tibble(shape = shape, points = points, J = jk[1], K = jk[2],
      relative_mean = sum(weight*rel), absolute_mean = sum(weight*abs),
      relative_lower = rq[1], relative_upper = rq[2], absolute_lower = aq[1], absolute_upper = aq[2])
  }))
  ordering <- tibble::tibble(shape = shape, points = points,
    relative_probability = sum(weight * (theta[,5] > theta[,4]/2)),
    absolute_probability = sum(weight * (theta[,5] + theta[,3] > (theta[,4] + theta[,2])/2)),
    effective_weight_count = 1/sum(weight^2))
  person_table <- tibble::tibble()
  if (person) {
    ybar1 <- 50 + sqrt(19*616) * (-9.5/sqrt(665)) / sqrt(8)
    gain <- 8 * theta[,1] / lambda[,5]
    mean1 <- 50 + gain * (ybar1 - 50)
    variance1 <- 400 + theta[,1] - (400 + theta[,1]/20)^2/(400 + v0) -
      (8 - 8/20) * theta[,1]^2 / lambda[,5]
    calibrated <- m05_mixture(mean1, variance1, weight) |> dplyr::mutate(target = "Calibrated person", observed_average = ybar1)
    smu2 <- 1/(1/400 + 1/v0)
    A <- theta[,1] + smu2; b <- error(4,2,TRUE)
    # Case contributes its likelihood to component learning; do not freeze calibration weights.
    case_weight <- weight * stats::dnorm(35, 50, sqrt(A + b)); case_weight <- case_weight / sum(case_weight)
    center <- 50 + A/(A+b) * (35-50); variance <- A*b/(A+b)
    new_person <- m05_mixture(center, variance, case_weight) |> dplyr::mutate(target = "New person target", observed_average = 35)
    future <- m05_mixture(center, variance+b, case_weight) |> dplyr::mutate(target = "Fresh facet average", observed_average = 35)
    person_table <- dplyr::bind_rows(calibrated,new_person,future) |> dplyr::mutate(shape = shape, points = points)
  }
  list(coefficients = coefficients, ordering = ordering, person = person_table,
       component_means = colSums(theta * weight), method = "Deterministic shifted Halton prior-importance integration; not posterior draws")
}

# Reconstruct all160 cells using exactly the chapter's orthogonal contrasts.
m05_crossed_data <- function() {
  n <- 20; J <- 4; K <- 2
  linear <- function(d) { x <- seq_len(d) - (d+1)/2; x/sqrt(sum(x^2)) }
  constant <- function(d) rep(1/sqrt(d), d)
  effects <- c("PTR","PT","PR","TR","P","T","R")
  ms <- c(36,68,72,116,616,508,472); df <- m05_crossed_map()$df
  y <- rep(50,n*J*K)
  for (k in seq_along(effects)) {
    vector <- kronecker(kronecker(if (grepl("P",effects[k])) linear(n) else constant(n),
      if (grepl("T",effects[k])) linear(J) else constant(J)),
      if (grepl("R",effects[k])) linear(K) else constant(K))
    y <- y + sqrt(df[k] * ms[k]) * vector
  }
  tidyr::expand_grid(person = seq_len(n), task = seq_len(J), rater = seq_len(K)) |> dplyr::mutate(score = as.vector(y))
}

m05_gaussian <- function(y, intercept, loading, residual, prior_mean, prior_covariance) {
  loading <- as.matrix(loading); residual <- as.matrix(residual); prior_covariance <- as.matrix(prior_covariance)
  p <- length(y); q <- length(prior_mean)
  if (length(intercept) != p || !all(dim(loading) == c(p,q)) ||
      !all(dim(residual) == c(p,p)) || !all(dim(prior_covariance) == c(q,q)) ||
      any(!is.finite(c(y,intercept,loading,residual,prior_mean,prior_covariance)))) stop("Incompatible Gaussian inputs.")
  if (!isTRUE(all.equal(residual,t(residual))) || !isTRUE(all.equal(prior_covariance,t(prior_covariance)))) stop("Covariances must be symmetric.")
  chol(residual); chol(prior_covariance)
  covariance <- solve(solve(prior_covariance) + t(loading) %*% solve(residual,loading))
  center <- covariance %*% (solve(prior_covariance,prior_mean) + t(loading) %*% solve(residual,y-intercept))
  list(mean = as.vector(center), covariance = covariance)
}

m05_moment_counterexample <- function() {
  distributions <- list(A=list(tau=c(-1,1),mass=c(.5,.5)), B=list(tau=c(-2,0,2),mass=c(.125,.75,.125)))
  dplyr::bind_rows(lapply(names(distributions),function(name) {
    x <- distributions[[name]]; response <- (x$tau+2)/4
    mt <- sum(x$tau*x$mass); vt <- sum((x$tau-mt)^2*x$mass)
    py <- sum(x$mass*response); my <- 4*py-2; vy <- 4-my^2
    tibble::tibble(population=name,mean_tau=mt,variance_tau=vt,probability_Y2=py,
      variance_Y=vy,average_error_variance=sum((4-x$tau^2)*x$mass),reliability=vt/vy,
      posterior_positive_tau=sum(x$mass*response*(x$tau>0))/py)
  }))
}
