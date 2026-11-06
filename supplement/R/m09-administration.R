# M09: synthetic observed-record experiments. Source this file; no package install.
# A reference probability, an unknown population parameter and a realized missing
# response are different targets. Functions return named lists/tidy data frames.

# Inclusive Clopper--Pearson convention, including an empty observed group.
m09_cp <- function(k, n, error = .05) {
  if (length(k) != 1L || length(n) != 1L || !is.finite(k + n) ||
      k != floor(k) || n != floor(n) || k < 0 || k > n || error <= 0 || error >= 1) {
    stop("Require integer 0 <= k <= n and 0 < error < 1.")
  }
  if (n == 0) return(c(lower = 0, upper = 1))
  c(lower = if (k == 0) 0 else stats::qbeta(error / 2, k, n - k + 1),
    upper = if (k == n) 1 else stats::qbeta(1 - error / 2, k + 1, n - k))
}

# Normalized Gauss--Jacobi rule for a beta law, via a symmetric recurrence matrix.
# Weights sum to one; they already include the beta density, not Lebesgue measure.
m09_beta_rule <- function(n = 64L, a = 1, b = 1) {
  if (n < 2 || n != floor(n) || min(a, b) <= 0 || !all(is.finite(c(n, a, b)))) stop("Invalid beta rule.")
  alpha <- b - 1; beta <- a - 1; k <- 0:(n - 1); z <- 2 * k + alpha + beta
  diagonal <- (beta^2 - alpha^2) / (z * (z + 2))
  if (abs(alpha + beta) < 1e-14) diagonal[1] <- (beta - alpha) / (alpha + beta + 2)
  k <- 1:(n - 1); z <- 2 * k + alpha + beta
  off2 <- 4 * k * (k + alpha) * (k + beta) * (k + alpha + beta) / (z^2 * (z^2 - 1))
  if (abs(alpha + beta + 1) < 1e-14) off2[1] <- 4 * (1 + alpha) * (1 + beta) / ((2 + alpha + beta)^2 * (3 + alpha + beta))
  J <- diag(diagonal); J[cbind(k, k + 1)] <- sqrt(off2); J[cbind(k + 1, k)] <- sqrt(off2)
  e <- eigen(J, symmetric = TRUE); ix <- order(e$values)
  tibble::tibble(node = (e$values[ix] + 1) / 2, weight = e$vectors[1, ix]^2)
}

# Known screening law. Same experiment, distinct scatter and radius events.
m09_screening <- function(alpha = .05) {
  if (alpha <= 0 || alpha >= 1) stop("alpha must be between zero and one.")
  cutoff <- stats::qchisq(1 - alpha, 1)
  tibble::tibble(quantity = c("Expected scatter", "Scatter upper-tail probability", "Radius upper-tail probability"),
    unit = c("squared standard-score units", "probability", "probability"),
    fixed_pair = c(1, alpha, alpha), selected_negative_pair = c(1 - 2 / pi, 4 * stats::pnorm(-sqrt(cutoff))^2, alpha),
    pattern_probability = .25, scatter_cutoff = cutoff, radius_squared_cutoff = stats::qchisq(1 - alpha, 2))
}

m09_pattern_counts <- function() matrix(c(16, 6, 2, 4, 14, 18), 3, 2,
  dimnames = list(c("-1", "0", "1"), c("abbreviated", "full")))

# Update all six cells, then regroup. Derived probabilities share these draws.
m09_pattern <- function(counts = m09_pattern_counts(), prior = matrix(1, 3, 2), order = 64L) {
  if (!identical(dim(counts), c(3L, 2L)) || !identical(dim(prior), c(3L, 2L)) ||
      any(!is.finite(c(counts, prior))) || any(counts < 0 | counts != floor(counts)) || any(prior <= 0)) stop("Invalid joint cells/prior.")
  A <- counts + prior; a <- unname(A[, 1]); b <- unname(A[, 2]); ar <- sum(a); br <- sum(b)
  er <- ar / (ar + br); vr <- ar * br / ((ar + br)^2 * (ar + br + 1))
  es <- a[1] / ar; vs <- a[1] * (ar - a[1]) / (ar^2 * (ar + 1))
  et <- b[1] / br; vt <- b[1] * (br - b[1]) / (br^2 * (br + 1))
  eu <- sum(A[1, ]) / sum(A); vu <- eu * (1 - eu) / (sum(A) + 1)
  ed <- (1 - er) * (es - et)
  vd <- ((1 - er)^2 + vr) * (vs + vt + (es - et)^2) - ed^2
  r <- m09_beta_rule(order, ar, br); t <- m09_beta_rule(order, b[1], br - b[1])
  weight <- outer(r$weight, t$weight)
  cdf <- function(d) vapply(d, function(z) sum(weight * stats::pbeta(pmin(1, pmax(0,
    outer(1 / (1 - r$node), rep(z, order)) + matrix(t$node, order, order, byrow = TRUE))), a[1], ar - a[1])), numeric(1))
  quantile <- function(p) stats::uniroot(function(d) cdf(d) - p, c(-1, 1), tol = 1e-11)$root
  mechanism <- tibble::tibble(first_category = -1:1, mean = b / (a + b),
    lower = stats::qbeta(.025, b, a), upper = stats::qbeta(.975, b, a))
  selected <- m09_cp(counts[1, 1], sum(counts[, 1]), .025)
  population <- m09_cp(sum(counts[1, ]), sum(counts), .025)
  list(shapes = A, mechanism = mechanism, cdf = cdf,
    summary = tibble::tibble(selected_low_mean = es, population_low_mean = eu, contrast_mean = ed,
      contrast_variance = vd, shared_covariance = er * vs, wrong_independent_variance = vs + vu,
      lower = quantile(.025), upper = quantile(.975), probability_contrast_positive = 1 - cdf(0),
      confidence_lower = selected[1] - population[2], confidence_upper = selected[2] - population[1]))
}

m09_rank_size <- function(m, probabilities = c(.15, .35, .50), alpha = .05, rank = TRUE) {
  if (m < 0 || m != floor(m) || any(probabilities < 0) || abs(sum(probabilities) - 1) > 1e-12) stop("Invalid rank experiment.")
  if (m == 0) return(0)
  threshold <- if (rank) floor(alpha * (m + 1) - 1 + 1e-12) else floor(alpha * m + 1e-12)
  sum(probabilities * stats::pbinom(threshold, m, cumsum(probabilities)))
}

# Generate the chapter's retained records. NA means no response was recorded.
# Rounded twelve-decimal observations match the archived synthetic input precision.
m09_records <- function() {
  rows <- list(); person <- 0L
  for (x in -1:1) for (r in 0:1) {
    n <- m09_pattern_counts()[x + 2, r + 1]
    for (i in seq_len(n)) {
      person <- person + 1L
      y <- if (r == 1) round(50 + 10 * x + c(-1, 1)[(i - 1) %% 2 + 1] * sqrt(34) / 3, 12) else NA_real_
      rows[[person]] <- tibble::tibble(person = person, first_category = x, first_score_points = 50 + 10 * x,
        second_score_recorded = r, second_score = y)
    }
  }
  dplyr::bind_rows(rows)
}

# Response fitting uses only recorded Y; all X/R remain in the cell likelihood.
m09_mar_fit <- function(records = m09_records(), b0 = c(50, 0), V0 = diag(c(100, 25)), a0 = 3, d0 = 8) {
  if (min(a0, d0) <= 0 || length(b0) != 2 || !identical(dim(V0), c(2L, 2L)) || min(eigen(V0, symmetric = TRUE)$values) <= 0) stop("Invalid proper response prior.")
  keep <- records$second_score_recorded == 1
  if (any(is.na(records$second_score[keep])) || any(!is.na(records$second_score[!keep]))) stop("Observed/missing flags disagree with responses.")
  Z <- cbind(rep(1, sum(keep)), records$first_category[keep]); y <- records$second_score[keep]
  V <- solve(solve(V0) + crossprod(Z)); b <- drop(V %*% (solve(V0, b0) + crossprod(Z, y)))
  a <- a0 + length(y) / 2; d <- d0 + .5 * (sum((y - Z %*% b)^2) + drop(crossprod(b - b0, solve(V0, b - b0))))
  rank_ok <- nrow(Z) > 2 && qr(Z)$rank == 2
  frequent <- NULL
  if (rank_ok) {
    Vf <- solve(crossprod(Z)); bhat <- drop(Vf %*% crossprod(Z, y)); Q <- sum((y - Z %*% bhat)^2)
    frequent <- list(V = Vf, b = bhat, Q = Q, df = length(y) - 2, s2 = Q / (length(y) - 2))
  }
  list(b = b, V = V, a = a, d = d, Ev = if (a > 1) d / (a - 1) else Inf,
    observed = length(y), frequent = frequent, records = records)
}

m09_case <- function(fit, x = -1, error = .05) {
  f <- c(1, x); mu <- sum(f * fit$b); h <- drop(crossprod(f, fit$V %*% f)); scale <- sqrt(fit$d / fit$a * (1 + h))
  z <- stats::qt(1 - error / 2, 2 * fit$a)
  fp <- fit$frequent; confidence <- prediction <- c(-Inf, Inf)
  if (!is.null(fp) && fp$Q > 0) {
    hf <- drop(crossprod(f, fp$V %*% f)); m <- sum(f * fp$b); t <- stats::qt(1 - error / 2, fp$df) * sqrt(fp$s2)
    confidence <- m + c(-1, 1) * t * sqrt(hf); prediction <- m + c(-1, 1) * t * sqrt(1 + hf)
  }
  tibble::tibble(x = x, mean_location = mu, predictive_scale = scale, df = 2 * fit$a,
    mean_lower = mu - z * sqrt(fit$d / fit$a * h), mean_upper = mu + z * sqrt(fit$d / fit$a * h),
    response_lower = mu - z * scale, response_upper = mu + z * scale,
    confidence_lower = confidence[1], confidence_upper = confidence[2],
    prediction_lower = prediction[1], prediction_upper = prediction[2], probability_response_below45 = stats::pt((45 - mu) / scale, 2 * fit$a))
}

# The composition is another posterior distribution, not fixed observed balance.
m09_population <- function(fit, shape = c(22, 22, 22), order = 64L) {
  g1 <- m09_beta_rule(order, shape[1], sum(shape[-1])); g2 <- m09_beta_rule(order, shape[2], shape[3])
  W <- outer(1 - 2 * g1$node, rep(1, order)) - outer(1 - g1$node, g2$node)
  weight <- outer(g1$weight, g2$weight); loc <- fit$b[1] + fit$b[2] * W
  scale <- sqrt(fit$d / fit$a * (fit$V[1, 1] + 2 * W * fit$V[1, 2] + W^2 * fit$V[2, 2]))
  cdf <- function(z) sum(weight * stats::pt((z - loc) / scale, 2 * fit$a))
  qu <- function(p) stats::uniroot(function(z) cdf(z) - p, c(-1000, 1000), tol = 1e-10)$root
  p <- shape / sum(shape); mw <- sum(p * (-1:1)); vw <- (sum(p * (-1:1)^2) - mw^2) / (sum(shape) + 1)
  variance <- fit$Ev * (fit$V[1, 1] + 2 * mw * fit$V[1, 2] + (vw + mw^2) * fit$V[2, 2]) + fit$b[2]^2 * vw
  tibble::tibble(mean = fit$b[1] + fit$b[2] * mw, variance = variance, lower = qu(.025), upper = qu(.975), composition_mean = mw, composition_variance = vw)
}

# Transform the entire Student prediction through both roots of the square.
m09_profile <- function(fit, shift = 0, radius = 0, order = 64L) {
  if (radius < 0 || fit$a <= 2) stop("Nonnegative radius and finite fourth response moment required.")
  f <- c(1, -1); h <- drop(crossprod(f, fit$V %*% f)); delta <- sum(f * fit$b) - 40 + shift
  M1 <- fit$d / (fit$a - 1); M2 <- fit$d^2 / ((fit$a - 1) * (fit$a - 2)); scale <- sqrt(fit$d / fit$a * (1 + h))
  u <- m09_beta_rule(order); departure <- radius * (2 * u$node - 1)
  cdf_y <- function(y) if (radius == 0) stats::pt((y - 40 - delta) / scale, 2 * fit$a) else sum(u$weight * stats::pt((y - 40 - delta - departure) / scale, 2 * fit$a))
  cdf <- function(s) vapply(s, function(z) if (z <= 0) 0 else cdf_y(40 + sqrt(2 * z)) - cdf_y(40 - sqrt(2 * z)), numeric(1))
  e2 <- delta^2 + (1 + h) * M1 + radius^2 / 3
  e4 <- delta^4 + 6 * delta^2 * (1 + h) * M1 + 3 * (1 + h)^2 * M2 +
    2 * (delta^2 + (1 + h) * M1) * radius^2 + radius^4 / 5
  upper <- stats::uniroot(function(s) cdf(s) - .95, c(0, 10000), tol = 1e-10)$root
  tibble::tibble(shift = shift, radius = radius, mean_filled = delta^2 / 2, mean = e2 / 2,
    variance = (e4 - e2^2) / 4, probability_over8 = 1 - cdf(8), upper95 = upper,
    h = h, delta = delta, M1 = M1, M2 = M2)
}

# Direct normal/gamma quadrature for the shared-parameter two-person event.
m09_joint_profile <- function(fit, order = 48L) {
  if (fit$a <= 2) stop("Finite second scatter moment required.")
  k <- 1:(order - 1); Jn <- matrix(0, order, order); Jn[cbind(k, k + 1)] <- sqrt(k); Jn[cbind(k + 1, k)] <- sqrt(k)
  Jg <- diag(2 * (0:(order - 1)) + fit$a); off <- sqrt(k * (k + fit$a - 1)); Jg[cbind(k, k + 1)] <- off; Jg[cbind(k + 1, k)] <- off
  en <- eigen(Jn, symmetric = TRUE); eg <- eigen(Jg, symmetric = TRUE)
  p <- m09_profile(fit); v <- fit$d / eg$values; D <- outer(sqrt(v * p$h), en$values) + p$delta
  noise_sd <- matrix(sqrt(v), order, order); prob <- stats::pnorm((-4 - D) / noise_sd) + stats::pnorm((D - 4) / noise_sd)
  w <- outer(eg$vectors[1, ]^2, en$vectors[1, ]^2)
  tibble::tibble(order = order, one = sum(w * prob), both = sum(w * prob^2), wrong_product = sum(w * prob)^2,
    covariance_response = p$h * p$M1, correlation_response = p$h / (1 + p$h))
}

m09_paths <- function() {
  p <- list(); i <- 0L
  for (u in 0:1) {
    i <- i + 1L; p[[i]] <- list(u0 = u, stop = TRUE, J = NA_integer_, u1 = NA_integer_, V = NA_integer_, coin = c(.25, .5)[u + 1], total = u)
    for (j in 2:3) for (y in 0:1) {
      i <- i + 1L; p[[i]] <- list(u0 = u, stop = FALSE, J = j, u1 = y, V = as.integer((u == 0 && j == 2) || (u == 1 && j == 3)), coin = 1 - c(.25, .5)[u + 1], total = u + y)
    }
  }
  p
}

# Full finite posterior: hidden reference allocations are integrated, never filled.
m09_adaptive <- function(path = m09_paths()[[3]], prefix = "response", shape = 1, anchor = c(.1, .9), omit_choice = FALSE) {
  if (shape <= 0 || length(anchor) != 2 || any(anchor <= 0 | anchor >= 1) || !prefix %in% c("reference", "first", "choice", "response")) stop("Invalid finite model.")
  D <- rbind(c(0, 0, 0, 0, 0), c(1, 1, 1, 0, 1), c(1, 1, 1, 1, 1))
  allocations <- as.matrix(expand.grid(z1 = 0:1, z2 = 0:1, z3 = 0:1)); logw <- numeric(); hm <- numeric(); pm <- list()
  for (i in seq_len(nrow(allocations))) {
    z <- allocations[i, ]; n1 <- sum(z); successes <- matrix(0, 2, 4)
    for (h in 0:1) if (any(z == h)) successes[h + 1, ] <- colSums(D[z == h, 2:5, drop = FALSE])
    for (hcase in if (prefix == "reference") NA_integer_ else 0:1) {
      S <- successes; N <- matrix(rep(c(3 - n1, n1), 4), 2, 4)
      pishape <- c(2 + 3 - n1, 2 + n1)
      if (!is.na(hcase)) {
        pishape[hcase + 1] <- pishape[hcase + 1] + 1
        js <- 1L; ys <- path$u0
        if (!path$stop && prefix %in% c("choice", "response")) {
          if (!omit_choice) { js <- c(js, 4L); ys <- c(ys, path$V) }
          if (prefix == "response") { js <- c(js, path$J); ys <- c(ys, path$u1) }
        }
        for (k in seq_along(js)) { S[hcase + 1, js[k]] <- S[hcase + 1, js[k]] + ys[k]; N[hcase + 1, js[k]] <- N[hcase + 1, js[k]] + 1 }
      }
      a <- shape + S; b <- shape + N - S
      lw <- sum(log(ifelse(D[, 1] == 1, anchor[z + 1], 1 - anchor[z + 1]))) +
        lbeta(pishape[2], pishape[1]) - lbeta(2, 2) + sum(lbeta(a, b) - lbeta(shape, shape))
      logw <- c(logw, lw); hm <- c(hm, hcase); pm[[length(pm) + 1]] <- c(pi = pishape[2] / sum(pishape), as.vector(t(a / (a + b))))
    }
  }
  w <- exp(logw - max(logw)); evidence <- sum(w) * exp(max(logw)); w <- w / sum(w)
  list(probability_H1 = if (prefix == "reference") NA_real_ else sum(w * hm),
    means = drop(w %*% do.call(rbind, pm)), weights = w, evidence_without_coin = evidence)
}

m09_adaptive_summary <- function(shape = 1, anchor = c(.1, .9)) {
  ref <- m09_adaptive(prefix = "reference", shape = shape, anchor = anchor); paths <- m09_paths(); rows <- list()
  for (i in seq_along(paths)) {
    f <- m09_adaptive(paths[[i]], shape = shape, anchor = anchor)
    mass <- f$evidence_without_coin / ref$evidence_without_coin * paths[[i]]$coin
    rows[[i]] <- tibble::tibble(path = i, first = paths[[i]]$u0, item = if (paths[[i]]$stop) "stop" else c("0", "A", "B")[paths[[i]]$J],
      second = paths[[i]]$u1, total = paths[[i]]$total, mass = mass, probability_H1 = f$probability_H1)
  }
  law <- dplyr::bind_rows(rows); score <- law |> dplyr::group_by(total) |> dplyr::summarise(joint_H1 = sum(mass * probability_H1), mass = sum(mass), .groups = "drop") |> dplyr::mutate(probability_H1 = joint_H1 / mass)
  fullrisk <- sum(law$mass * law$probability_H1 * (1 - law$probability_H1)); scorerisk <- sum(score$mass * score$probability_H1 * (1 - score$probability_H1))
  list(paths = law, scores = score, risks = tibble::tibble(full_path_risk = fullrisk, score_risk = scorerisk, loss = scorerisk - fullrisk))
}

# A known-null mixture ratio. Endpoint support is an explicit branch.
m09_ratio <- function(t, s, p0, a = 1, b = 1) {
  if (t < 0 || s < 0 || s > t || t != floor(t) || s != floor(s) || min(a, b) <= 0 || p0 < 0 || p0 > 1) stop("Invalid Bernoulli record.")
  if (p0 == 0) return(if (s > 0) Inf else exp(lbeta(a, b + t) - lbeta(a, b)))
  if (p0 == 1) return(if (s < t) Inf else exp(lbeta(a + t, b) - lbeta(a, b)))
  exp(lbeta(a + s, b + t - s) - lbeta(a, b) - s * log(p0) - (t - s) * log1p(-p0))
}

m09_crossing <- function(p = .5, denominator = .5, horizon = 100, alpha = .05, credible = FALSE) {
  if (p < 0 || p > 1 || horizon < 1 || horizon != floor(horizon)) stop("Invalid sequence.")
  alive <- 1; crossed <- 0; rows <- vector("list", horizon)
  for (t in seq_len(horizon)) {
    next_mass <- c(alive * (1 - p), 0) + c(0, alive * p); s <- 0:t
    if (credible) { v <- stats::pbeta(p, s + 1, t - s + 1); hit <- v < alpha / 2 | v > 1 - alpha / 2 }
    else hit <- vapply(s, function(k) m09_ratio(t, k, denominator) >= 1 / alpha, logical(1))
    first <- sum(next_mass[hit]); crossed <- crossed + first; next_mass[hit] <- 0; alive <- next_mass
    rows[[t]] <- tibble::tibble(time = t, first_crossing_mass = first, cumulative_crossing = crossed, survival = sum(alive))
  }
  dplyr::bind_rows(rows)
}

# A meaningful censored time is not a Gaussian missing score.
m09_censoring <- function() {
  time <- c(.3, .5, .6, .8, .9, .9, 1, 1, 1, 1); done <- c(rep(1, 6), rep(0, 4)); d <- sum(done); exposure <- sum(time)
  evidence <- exp(2 * log(1) + lgamma(2 + d) - lgamma(2) - (2 + d) * log(1 + exposure))
  fun <- function(lambda) d * log(lambda) - lambda * exposure - log(.05 * evidence)
  confidence_low <- stats::uniroot(fun, c(1e-10, d / exposure), tol = 1e-12)$root; confidence_high <- stats::uniroot(fun, c(d / exposure, 100), tol = 1e-12)$root
  prior_rows <- lapply(1:2, function(a) tibble::tibble(prior_shape = a, retained = "times and indicators", mean_rate = (a + d) / (1 + exposure),
    lower = stats::qgamma(.025, a + d, rate = 1 + exposure), upper = stats::qgamma(.975, a + d, rate = 1 + exposure)))
  for (a in 1:2) {
    density <- function(lambda) lambda^(a - 1) * exp(-5 * lambda) * (-expm1(-lambda))^6
    norm <- stats::integrate(density, 0, Inf, rel.tol = 1e-10)$value
    cdf <- function(z) stats::integrate(density, 0, z, rel.tol = 1e-10)$value / norm
    qu <- function(p) stats::uniroot(function(z) cdf(z) - p, c(0, 10), tol = 1e-10)$root
    prior_rows[[length(prior_rows) + 1]] <- tibble::tibble(prior_shape = a, retained = "indicators only", mean_rate = stats::integrate(function(z) z * density(z), 0, Inf, rel.tol = 1e-10)$value / norm, lower = qu(.025), upper = qu(.975))
  }
  list(records = tibble::tibble(time = time, completion = done), matched_priors = dplyr::bind_rows(prior_rows),
    full = tibble::tibble(events = d, exposure = exposure, posterior_mean = 8 / 9, posterior_variance = 8 / 81,
      lower = stats::qgamma(.025, 8, rate = 9), upper = stats::qgamma(.975, 8, rate = 9),
      confidence_lower = confidence_low, confidence_upper = confidence_high, new_completion_probability = 1 - .9^8,
      probability_fraction_above_half = stats::pgamma(log(2), 8, rate = 9, lower.tail = FALSE)))
}

# Independent observed-law prior plus an explicitly unlearned missing-group law.
m09_missing_flag <- function(a0 = 1, b0 = 1, lo = 0, hi = 1, linked = FALSE,
                             retrieved = 0, positive = 0, order = 96L) {
  if (min(a0, b0) <= 0 || lo < 0 || hi > 1 || lo > hi || retrieved < positive || positive < 0 || retrieved > 10) stop("Invalid missing-outcome assumptions.")
  if (linked && retrieved > 0) stop("This retrieval example uses the independent missing-group model.")
  if (retrieved > 0 && (lo != 0 || hi != 1)) stop("Retrieval conjugacy here requires the full [0,1] beta probability scale.")
  a <- a0 + positive; b <- b0 + retrieved - positive
  r <- m09_beta_rule(order, 17, 11); u <- m09_beta_rule(order, a, b); theta0 <- lo + (hi - lo) * u$node
  weight <- outer(r$weight, u$weight)
  cdf <- function(z) if (linked) stats::pbeta(z, 4, 13) else if (lo == 0 && hi == 0) stats::pbeta(z, 4, 24) else if (lo == 1 && hi == 1) stats::pbeta(z, 15, 13) else sum(weight * stats::pbeta(pmin(1, pmax(0,
    (z - outer(1 - r$node, theta0)) / matrix(r$node, order, order))), 4, 13))
  qu <- function(p) stats::uniroot(function(z) cdf(z) - p, c(0, 1), tol = 1e-10)$root
  er <- 17 / 28; er2 <- 17 * 18 / (28 * 29); ev <- 4 / 17; ev2 <- 4 * 5 / (17 * 18)
  u1 <- if (linked) ev else lo + (hi - lo) * a / (a + b)
  u2 <- if (linked) ev2 else lo^2 + 2 * lo * (hi - lo) * a / (a + b) + (hi - lo)^2 * a * (a + 1) / ((a + b) * (a + b + 1))
  mean <- if (linked) ev else er * ev + (1 - er) * u1
  second <- if (linked) ev2 else er2 * ev2 + (1 - 2 * er + er2) * u2 + 2 * (er - er2) * ev * u1
  remain <- 10 - retrieved
  tibble::tibble(missing_shape_a = a, missing_shape_b = b, missing_low = lo, missing_high = hi, linked = linked,
    population_mean = mean, variance = second - mean^2, lower = qu(.025), upper = qu(.975),
    probability_population_over_point3 = 1 - cdf(.3), new_missing_person_probability = u1,
    cohort_fraction_mean = (3 + positive + remain * u1) / 25,
    cohort_fraction_variance = (remain * u1 * (1 - u1) + remain * (remain - 1) * (u2 - u1^2)) / 25^2,
    entire_set_confidence_lower = if (3 == 0) 0 else stats::qbeta(.025, 3, 23),
    entire_set_confidence_upper = 1 - stats::qbeta(.025, 12, 14))
}

# Preserve order before choosing the actual stopped record.
m09_stopped_record <- function(sequence, threshold = 20) {
  if (!length(sequence) || any(!sequence %in% 0:1) || threshold <= 1) stop("Invalid stopped record.")
  ratios <- vapply(seq_along(sequence), function(t) m09_ratio(t, sum(sequence[seq_len(t)]), .5), numeric(1))
  hit <- which(ratios >= threshold)
  first <- if (length(hit)) hit[1] else NA_integer_
  T <- if (is.na(first)) length(sequence) else first
  successes <- sum(sequence[seq_len(T)])
  tibble::tibble(current_ratio = tail(ratios, 1), first_crossing = first, actual_stopped_length = T,
    stopped_beta_a = 1 + successes, stopped_beta_b = 1 + T - successes)
}

# Mean-only support-gap sensitivity: do not add response noise to this target.
m09_support_mean <- function(fit, radius = 0, order = 64L) {
  if (radius < 0) stop("Nonnegative external departure radius required.")
  case <- m09_case(fit); f <- c(1, -1); scale <- sqrt(fit$d / fit$a * drop(crossprod(f, fit$V %*% f)))
  u <- m09_beta_rule(order); departure <- radius * (2 * u$node - 1)
  cdf <- function(y) if (radius == 0) stats::pt((y - case$mean_location) / scale, 2 * fit$a) else sum(u$weight * stats::pt((y - case$mean_location - departure) / scale, 2 * fit$a))
  qu <- function(p) stats::uniroot(function(y) cdf(y) - p, c(-1000, 1000), tol = 1e-10)$root
  tibble::tibble(radius = radius, mean = case$mean_location, lower = qu(.025), upper = qu(.975),
    entire_mean_set_confidence_lower = case$confidence_lower - radius, entire_mean_set_confidence_upper = case$confidence_upper + radius)
}

m09_missing_set <- function(lo = 0, hi = 1) {
  if (lo < 0 || hi > 1 || lo > hi) stop("Require 0 <= lo <= hi <= 1.")
  cs <- m09_cp(3, 25, .025); cf <- m09_cp(12, 25, .025)
  if (lo == 0 && hi == 1) { L <- stats::qbeta(.025, 3, 23); U <- 1 - stats::qbeta(.025, 12, 14); method <- "two one-sided bounds" }
  else { L <- max(0, lo + (1 - lo) * cs[1] - lo * cf[2]); U <- min(1, hi + (1 - hi) * cs[2] - hi * cf[1]); method <- "two two-sided intervals, outer rectangle" }
  tibble::tibble(missing_low = lo, missing_high = hi, empirical_lower = .12 + .4 * lo, empirical_upper = .12 + .4 * hi,
    entire_set_confidence_lower = unname(L), entire_set_confidence_upper = unname(U), method = method)
}
