# Deterministic numerical kernels for the M02 normal-reference experiment.
# These evaluate the chapter's exact integral representations numerically.
# They do not establish normality, representativeness, clinical validity or proofs.
m02_positive <- function(x, name) {
  if (length(x) != 1L || !is.numeric(x) || !is.finite(x) || x <= 0) stop(name, " must be one finite positive number.", call. = FALSE)
}
m02_level <- function(p) {
  if (any(!is.finite(p) | p <= 0 | p >= 1)) stop("Probability levels must lie strictly between 0 and 1.", call. = FALSE)
}
m02_n <- function(n) {
  if (length(n) != 1L || !is.finite(n) || n < 2 || n != as.integer(n)) stop("n must be an integer at least 2.", call. = FALSE)
}
# Integrate over the square root of chi-square, rather than q itself, to
# remove the q^(-1/2) endpoint singularity at one degree of freedom.
# The omitted upper mixing tail is 1e-13. For bounded CDF integrands its
# contribution is at most 1e-13; integrate()'s reported error is additional.
m02_chi_expect <- function(fun, df) {
  m02_positive(df, "df")
  upper <- sqrt(stats::qchisq(1e-13, df, lower.tail = FALSE))
  log_constant <- (1 - df / 2) * log(2) - lgamma(df / 2)
  integrand <- function(s) fun(s) * exp(log_constant + (df - 1) * log(s) - s^2 / 2)
  stats::integrate(integrand, 0, upper, subdivisions = 600L,
    rel.tol = 2e-10, abs.tol = 2e-11, stop.on.error = TRUE)$value
}
m02_H <- function(t, df, ncp = 0) {
  if (length(t) != 1L || length(ncp) != 1L || !is.finite(t) || !is.finite(ncp)) stop("t and ncp must be finite scalars.", call. = FALSE)
  m02_chi_expect(function(s) stats::pnorm(t * s / sqrt(df) - ncp), df)
}
# Expand a bracket before solving, rather than silently returning a boundary.
m02_root <- function(fun) {
  extent <- 2
  for (i in seq_len(20L)) {
    lo <- fun(-extent); hi <- fun(extent)
    if (is.finite(lo) && is.finite(hi) && lo * hi <= 0) return(stats::uniroot(fun, c(-extent, extent), tol = 1e-10)$root)
    extent <- extent * 2
  }
  stop("Root could not be bracketed; inspect the input and numerical tail.", call. = FALSE)
}
m02_nct_quantile <- function(p, df, ncp) {
  m02_level(p)
  vapply(p, function(r) m02_root(function(t) m02_H(t, df, ncp) - r), numeric(1))
}
m02_posterior <- function(n, mean, sd, prior = NULL) {
  m02_n(n); m02_positive(sd, "sd")
  if (length(mean) != 1L || !is.finite(mean)) stop("mean must be finite.", call. = FALSE)
  if (is.null(prior)) return(list(m = mean, kappa = n, a = (n - 1) / 2, b = (n - 1) * sd^2 / 2))
  for (name in c("kappa", "a", "b")) m02_positive(prior[[name]], name)
  if (length(prior$m) != 1L || !is.finite(prior$m)) stop("prior$m must be finite.", call. = FALSE)
  kn <- prior$kappa + n
  list(m = (prior$kappa * prior$m + n * mean) / kn, kappa = kn,
       a = prior$a + n / 2,
       b = prior$b + ((n - 1) * sd^2 + prior$kappa * n / kn * (mean - prior$m)^2) / 2)
}
m02_predict <- function(post, y0, levels = c(.025, .975), h = 1 / post$kappa) {
  m02_level(levels)
  if (length(h) != 1L || !is.finite(h) || h < 0) stop("h must be finite and nonnegative.", call. = FALSE)
  scale <- sqrt(post$b / post$a * (1 + h)); df <- 2 * post$a
  list(mean_location = post$m, scale = scale, df = df,
    lower_tail = stats::pt((y0 - post$m) / scale, df),
    interval = post$m + scale * stats::qt(levels, df))
}
m02_percentile <- function(post, y0, levels = c(.025, .5, .975), h = 1 / post$kappa) {
  m02_level(levels); m02_positive(h, "h")
  df <- 2 * post$a; t <- (y0 - post$m) / sqrt(post$b / post$a * h)
  lambda <- vapply(levels, function(r) m02_root(function(x) m02_H(t, df, x) - (1 - r)), numeric(1))
  stats::pnorm(sqrt(h) * lambda)
}
m02_quantile <- function(post, u = .05, levels = c(.025, .5, .975)) {
  m02_level(c(u, levels)); z <- stats::qnorm(u)
  post$m + sqrt(post$b / (post$a * post$kappa)) * m02_nct_quantile(levels, 2 * post$a, sqrt(post$kappa) * z)
}
m02_scale <- function(post, levels = c(.025, .5, .975)) {
  m02_level(levels)
  sqrt(2 * post$b / stats::qchisq(levels, 2 * post$a, lower.tail = FALSE))
}
m02_sd_moment <- function(post, order = 1) {
  m02_positive(order, "order")
  if (order >= 2 * post$a) return(Inf)
  exp(order / 2 * log(post$b) + lgamma(post$a - order / 2) - lgamma(post$a))
}
m02_content_cdf <- function(p, zeta, n = 20) {
  m02_n(n); m02_level(p)
  vapply(p, function(value) m02_chi_expect(function(s) stats::pnorm(sqrt(n) * (stats::qnorm(value) - zeta * s / sqrt(n - 1))), n - 1), numeric(1))
}
m02_content_quantile <- function(levels, zeta, n = 20) {
  m02_level(levels)
  vapply(levels, function(r) stats::pnorm(m02_root(function(x) {
    m02_chi_expect(function(s) stats::pnorm(sqrt(n) * (x - zeta * s / sqrt(n - 1))), n - 1) - r
  })), numeric(1))
}
m02_cutoffs <- function(n = 20, u = .05, gamma = .95) {
  m02_n(n); m02_level(c(u, gamma))
  c(content = m02_nct_quantile(1 - gamma, n - 1, sqrt(n) * stats::qnorm(u)) / sqrt(n),
    joint = sqrt(1 + 1 / n) * stats::qt(u, n - 1))
}
m02_content_density <- function(p, zeta, n = 20) {
  m02_n(n); m02_level(p)
  vapply(p, function(value) {
    z <- stats::qnorm(value)
    m02_chi_expect(function(s) sqrt(n) * stats::dnorm(sqrt(n) * (z - zeta * s / sqrt(n - 1))) / stats::dnorm(z), n - 1)
  }, numeric(1))
}
m02_regression <- function(X, y, x0, prior = NULL) {
  X <- as.matrix(X); n <- nrow(X); k <- ncol(X)
  if (length(y) != n || length(x0) != k || n <= k || any(!is.finite(c(X, y, x0))) || qr(X)$rank != k) stop("Need finite full-rank design, n>k, conformable y/x0.", call. = FALSE)
  M <- crossprod(X); fit <- as.numeric(solve(M, crossprod(X, y)))
  rss <- sum((y - X %*% fit)^2); m02_positive(rss, "residual sum of squares")
  leverage <- as.numeric(t(x0) %*% solve(M, x0))
  if (is.null(prior)) return(list(m = sum(x0 * fit), kappa = if (leverage > 0) 1 / leverage else Inf,
    a = (n - k) / 2, b = rss / 2, h = leverage, coefficients = fit, sd = sqrt(rss / (n - k))))
  K0 <- as.matrix(prior$K)
  if (!all(dim(K0) == c(k, k)) || !isTRUE(all.equal(K0, t(K0))) || min(eigen(K0, symmetric = TRUE)$values) <= 0) stop("Prior K must be symmetric positive definite.", call. = FALSE)
  for (name in c("a", "b")) m02_positive(prior[[name]], name)
  if (length(prior$m) != k || any(!is.finite(prior$m))) stop("Prior m must match coefficient dimension.", call. = FALSE)
  Kn <- K0 + M; mn <- as.numeric(solve(Kn, K0 %*% prior$m + crossprod(X, y)))
  hn <- as.numeric(t(x0) %*% solve(Kn, x0))
  bn <- prior$b + (sum((y - X %*% mn)^2) + as.numeric(t(mn - prior$m) %*% K0 %*% (mn - prior$m))) / 2
  list(m = sum(x0 * mn), kappa = if (hn > 0) 1 / hn else Inf, a = prior$a + n / 2,
       b = bn, h = hn, coefficients = mn, sd = sqrt(rss / (n - k)))
}

# Percentile-parameter CDF: compute the survival via normal reflection, avoiding
# subtraction from one near a tail. h=0 needs the direct variance-only branch.
m02_percentile_cdf <- function(post, y0, p, h = 1 / post$kappa) {
  m02_level(p); m02_positive(h, "h")
  t <- (y0 - post$m) / sqrt(post$b / post$a * h)
  vapply(p, function(value) m02_H(-t, 2 * post$a, -stats::qnorm(value) / sqrt(h)), numeric(1))
}
