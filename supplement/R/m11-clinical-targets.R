# M11 synthetic target/decision experiments. Source-based functions, not clinical rules.
# Quantities describe the experiment named in each function; data are stipulated.
m11_cp <- function(k, n, error = .05) {
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
m11_beta_rule <- function(n = 64L, a = 1, b = 1) {
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


m11_risk <- function(s, f, prevalence) {
  if (any(!is.finite(c(s, f, prevalence))) || any(c(s, f, prevalence) < 0 | c(s, f, prevalence) > 1)) stop("Probabilities must be in [0,1].")
  denominator <- prevalence * s + (1 - prevalence) * f
  if (any(denominator <= 0)) stop("Positive flag probability required.")
  prevalence * s / denominator
}

# All three training experiments remain inside posterior integration.
m11_flag <- function(nodes = 64L) {
  ss <- m11_beta_rule(nodes, 17, 5); ff <- m11_beta_rule(nodes, 5, 37); pp <- m11_beta_rule(nodes, 11, 91)
  s <- rep(ss$node, times = nodes); f <- rep(ff$node, each = nodes)
  weight <- as.vector(outer(ss$weight, ff$weight)); mean_q <- second <- 0
  for (i in seq_len(nodes)) {
    q <- m11_risk(s, f, pp$node[i])
    mean_q <- mean_q + pp$weight[i] * sum(weight * q)
    second <- second + pp$weight[i] * sum(weight * q^2)
  }
  cdf <- function(t) {
    if (t <= 0) return(0)
    if (t >= 1) return(1)
    sum(weight * stats::pbeta(t * f / ((1 - t) * s + t * f), 11, 91))
  }
  lower <- stats::uniroot(function(t) cdf(t) - .025, c(.000001, .999999), tol = 1e-12)$root
  upper <- stats::uniroot(function(t) cdf(t) - .975, c(.000001, .999999), tol = 1e-12)$root
  bounds <- rbind(m11_cp(16, 20, .05 / 3), m11_cp(4, 40, .05 / 3), m11_cp(10, 100, .05 / 3))
  list(posterior = tibble::tibble(parameter = c("sensitivity", "false_positive", "prevalence"), positive_count = c(16, 4, 10), sample_size = c(20, 40, 100), shape_a = c(17, 5, 11), shape_b = c(5, 37, 91), confidence_lower = bounds[, 1], confidence_upper = bounds[, 2]),
    risk = tibble::tibble(nodes = nodes, plugin = 8 / 17, parameter_mean = mean_q, parameter_sd = sqrt(max(0, second - mean_q^2)), credible_lower = lower, credible_upper = upper, probability_Q_gt_half = 1 - cdf(.5), case_predictive = (11 / 102 * 17 / 22) / (11 / 102 * 17 / 22 + 91 / 102 * 5 / 42), confidence_lower = m11_risk(bounds[1, 1], bounds[2, 2], bounds[3, 1]), confidence_upper = m11_risk(bounds[1, 2], bounds[2, 1], bounds[3, 2])))
}

m11_function <- function(data = tibble::tibble(z = -2:3, function_rating = c(7, 7, 9, 13, 14, 16))) {
  X <- cbind(1, data$z); F <- data$function_rating; n <- nrow(X); k <- ncol(X); x0 <- c(1, 1)
  if (n <= k || qr(X)$rank < k || any(!is.finite(c(X, F)))) stop("Full rank, finite data, n>k required for these pivots.")
  bh <- solve(crossprod(X), crossprod(X, F)); rss <- sum((F - X %*% bh)^2); s2 <- rss / (n - k)
  if (s2 <= 0) stop("Positive residual variance required.")
  h0 <- drop(crossprod(x0, solve(crossprod(X), x0))); location <- sum(x0 * bh)
  K0 <- diag(k); m0 <- c(10, 0); Kn <- K0 + crossprod(X); mn <- solve(Kn, K0 %*% m0 + crossprod(X, F))
  an <- 2 + n / 2; bn <- 2 + .5 * (sum(F^2) + drop(crossprod(m0, K0 %*% m0)) - drop(crossprod(mn, Kn %*% mn)))
  q0 <- drop(crossprod(x0, solve(Kn, x0))); bayes_location <- sum(x0 * mn)
  interval <- function(center, scale, df) center + c(-1, 1) * stats::qt(.975, df) * scale
  rows <- lapply(c(FALSE, TRUE), function(prediction) {
    ci <- interval(location, sqrt(s2 * (as.numeric(prediction) + h0)), n - k)
    cr <- interval(bayes_location, sqrt(bn / an * (as.numeric(prediction) + q0)), 2 * an)
    tibble::tibble(target = if (prediction) "new_outcome" else "conditional_mean", frequentist_center = location, confidence_or_prediction_lower = ci[1], confidence_or_prediction_upper = ci[2], proper_posterior_center = bayes_location, credible_or_predictive_lower = cr[1], credible_or_predictive_upper = cr[2])
  })
  list(intervals = dplyr::bind_rows(rows), fit = tibble::tibble(intercept = bh[1], slope = bh[2], rss = rss, residual_variance = s2, leverage = h0, posterior_intercept = mn[1], posterior_slope = mn[2], posterior_shape = an, posterior_scale = bn, posterior_predictive_below_ten = stats::pt((10 - bayes_location) / sqrt(bn / an * (1 + q0)), 2 * an)))
}

m11_horizon <- function(data = tibble::tibble(observed_time_years = c(.5, 1, 1.5, rep(2, 9)), event = c(1, 1, 1, rep(0, 9)))) {
  d <- sum(data$event); exposure <- sum(data$observed_time_years); horizon <- 2; a <- 2; b <- 2
  if (d <= 0 || exposure <= 0 || any(!data$event %in% 0:1) || any(data$observed_time_years <= 0)) stop("This illustrated root construction requires events and positive exposure.")
  logm <- a * log(b) + lgamma(a + d) - lgamma(a) - (a + d) * log(b + exposure)
  g <- function(rate) d * log(rate) - rate * exposure - log(.05) - logm
  mle <- d / exposure
  lo <- stats::uniroot(g, c(1e-12, mle), tol = 1e-12)$root; hi <- stats::uniroot(g, c(mle, 10), tol = 1e-12)$root
  rate_credible <- stats::qgamma(c(.025, .975), shape = a + d, rate = b + exposure)
  count_interval <- m11_cp(d, nrow(data))
  tibble::tibble(events = d, scheduled = nrow(data), exposure_person_years = exposure, horizon_years = horizon, rate_mle = mle, risk_plugin = -expm1(-horizon * mle), posterior_shape = a + d, posterior_rate_years = b + exposure, risk_predictive = 1 - ((b + exposure) / (b + exposure + horizon))^(a + d), rate_confidence_lower = lo, rate_confidence_upper = hi, risk_confidence_lower = -expm1(-horizon * lo), risk_confidence_upper = -expm1(-horizon * hi), risk_credible_lower = -expm1(-horizon * rate_credible[1]), risk_credible_upper = -expm1(-horizon * rate_credible[2]), count_confidence_lower = count_interval[1], count_confidence_upper = count_interval[2])
}

m11_validity <- function() {
  D <- c(0, 1, 0, 1); V <- c(1, 1, 0, 0); pi <- c(.72, .08, .12, .08); B <- c(.05, .7, .6, .8); A <- c(.05, .1, .8, .9)
  mass <- pi * B * A; q <- mass / sum(mass)
  counts <- matrix(c(0, 1, 1, 18, 2, 12, 0, 6, 10, 2, 6, 2, 14, 2, 4, 0), 4, byrow = TRUE)
  shapes <- counts + 1; composition <- c(37, 5, 7, 5); first <- shapes[, 1] / rowSums(shapes); fitted <- composition / sum(composition) * first; fitted <- fitted / sum(fitted)
  list(known_states = tibble::tibble(target_D = D, response_V = V, state_probability = pi, flag_B_probability = B, failure_A_probability = A, joint_mass = mass, state_posterior = q), fitted_states = tibble::tibble(target_D = D, response_V = V, composition_shape = composition, first_cell_shape = shapes[, 1], row_shape_total = rowSums(shapes), state_predictive = fitted), state_readout = tibble::tibble(experiment = c("known_law", "fitted_five_simplexes"), target_probability = c(sum(q[D == 1]), sum(fitted[D == 1])), alternative_process_probability = c(sum(q[V == 0]), sum(fitted[V == 0]))), conditional_counts = tibble::tibble(target_D = rep(D, each = 4), response_V = rep(V, each = 4), cell = rep(c("B1_A1", "B1_A0", "B0_A1", "B0_A0"), 4), count = as.vector(t(counts))))
}

m11_transport <- function() {
  k <- c(8, 18, 2, 8, 8, 8, 10); n <- c(20, 20, 40, 40, 10, 10, 100)
  bounds <- t(vapply(seq_along(k), function(i) m11_cp(k[i], n[i], .05 / 7), numeric(2)))
  vertices <- expand.grid(lapply(seq_along(k), function(i) bounds[i, ])); names(vertices) <- c("r10", "r11", "r00", "r01", "w1", "w0", "prevalence")
  values <- with(vertices, m11_risk((1 - w1) * r10 + w1 * r11, (1 - w0) * r00 + w0 * r01, prevalence))
  vertices$risk <- values
  es <- (1 - 9 / 12) * 9 / 22 + 9 / 12 * 19 / 22; ef <- (1 - 9 / 12) * 3 / 42 + 9 / 12 * 9 / 42
  list(parameters = tibble::tibble(parameter = names(vertices)[1:7], positive_count = k, sample_size = n, shape_a = k + 1, shape_b = n - k + 1, confidence_lower = bounds[, 1], confidence_upper = bounds[, 2]), vertices = tibble::as_tibble(vertices), summary = tibble::tibble(mean_sensitivity = es, mean_false_positive = ef, new_positive_predictive = m11_risk(es, ef, 11 / 102), confidence_lower = min(values), confidence_upper = max(values)), spectrum = tibble::tibble(site = c("source", "target"), sensitivity = c(.5, .8), false_positive = c(.08, .17), prevalence = .1, positive_result_risk = m11_risk(c(.5, .8), c(.08, .17), .1)))
}

m11_validation <- function() {
  q <- c(.1, .9); r <- rep(.5, 2); weights <- c(.5, .5)
  calibration <- tibble::tibble(group = c("low", "high"), true_risk = q, reported_risk = r, distorted_report = q^2, best_brier = q * (1 - q), constant_brier = q * (1 - q) + (q - r)^2, best_log_loss = -q * log(q) - (1 - q) * log1p(-q), constant_log_loss = -q * log(r) - (1 - q) * log1p(-r), weight = weights)
  labels <- tibble::tibble(model = c("perfect_reference", "sensitivity_08_specificity_09"), label_probability = .2, reference_sensitivity = c(1, .8), reference_specificity = c(1, .9), target_probability = c(.2, 1 / 7))
  list(calibration = calibration, imperfect_reference = labels)
}

m11_missing <- function() {
  n <- c(30, 50, 20); shapes <- n + 1; total <- sum(shapes)
  lo_s <- stats::qbeta(.025, 30, 71); lo_f <- stats::qbeta(.025, 50, 51)
  tibble::tibble(model = c("uniform_missing_prior", "low_missing_prior", "uniform_after_random_retrieval"), missing_shape_a = c(1, 1, 8), missing_shape_b = c(1, 9, 4), verified_positive_shape = shapes[1], verified_negative_shape = shapes[2], unverified_shape = shapes[3], empirical_identified_lower = .3, empirical_identified_upper = .5, whole_set_confidence_lower = lo_s, whole_set_confidence_upper = 1 - lo_f, population_risk_mean = shapes[1] / total + shapes[3] / total * c(.5, .1, 2 / 3), known_missing_case_probability = c(.5, .1, 2 / 3))
}

m11_decisions <- function(flag = m11_flag()$risk) {
  q <- flag$case_predictive; l <- flag$confidence_lower; u <- flag$confidence_upper
  choices <- tibble::tibble(cost_false_positive = c(1, 4), cost_false_negative = c(4, 1), threshold = c(.2, .8), case_probability = q, loss_a0 = c(4, 1) * q, loss_a1 = c(1, 4) * (1 - q), robust_loss_a0 = c(4, 1) * u, robust_loss_a1 = c(1, 4) * (1 - l))
  shapes <- c(17, 9, 5, 73); losses <- c(0, 1, 4, 0); total <- sum(shapes); mean <- sum(shapes * losses) / total
  evaluation <- tibble::tibble(cell = c("true_positive", "false_positive", "false_negative", "true_negative"), count = c(16, 8, 4, 72), posterior_shape = shapes, loss = losses, net_benefit_contribution = c(1, -.25, 0, 0))
  list(actions = choices, evaluation_cells = evaluation, evaluation_summary = tibble::tibble(empirical_risk = .24, posterior_mean_risk = mean, posterior_variance_risk = sum(shapes * (losses - mean)^2) / (total * (total + 1)), empirical_net_benefit = .14, posterior_mean_net_benefit = (17 - .25 * 9) / total, hoeffding_95_half_width = 4 * sqrt(log(40) / 200)), optimality_counterexample = tibble::tibble(parameter_risk = c(.1, .9), posterior_weight = c(.8, .2), known_parameter_preferred_a1 = c(FALSE, TRUE)))
}

# Known-kernel posterior transition and full finite recursion, including test costs.
m11_next <- function(q, y, sensitivity = .8, false_positive = .1) {
  if (q < 0 || q > 1 || !y %in% 0:1 || min(sensitivity, false_positive) < 0 || max(sensitivity, false_positive) > 1) stop("Invalid state/kernel.")
  p1 <- if (y == 1) sensitivity else 1 - sensitivity; p0 <- if (y == 1) false_positive else 1 - false_positive
  mass <- q * p1 + (1 - q) * p0
  if (mass == 0) stop("Observed path has zero probability.")
  c(probability = mass, posterior = q * p1 / mass)
}
m11_policy_value <- function(q, remaining = 2L, cost = .1) {
  if (length(q) != 1L || !is.finite(q) || q < 0 || q > 1) stop("A finite scalar target probability in [0,1] is required.")
  if (length(remaining) != 1L || length(cost) != 1L || !all(is.finite(c(remaining, cost))) || remaining < 0 || remaining != floor(remaining) || cost < 0) stop("Finite nonnegative horizon/cost required.")
  stop_loss <- min(4 * q, 1 - q)
  if (remaining == 0) return(stop_loss)
  plus <- m11_next(q, 1); minus <- m11_next(q, 0)
  min(stop_loss, cost + plus[1] * m11_policy_value(plus[2], remaining - 1L, cost) + minus[1] * m11_policy_value(minus[2], remaining - 1L, cost))
}
m11_information <- function() {
  q <- .3; plus <- m11_next(q, 1); minus <- m11_next(q, 0)
  risks <- tibble::tibble(remaining_measurements = 0:2, optimal_total_loss = vapply(0:2, function(k) m11_policy_value(q, k), numeric(1)))
  branch <- tibble::tibble(first_result = c("positive", "negative"), probability = c(plus[1], minus[1]), updated_target_probability = c(plus[2], minus[2]), next_choice_in_two_step_policy = c("stop_a1", "test_again"))
  paths <- tibble::tibble(path = c("positive", "negative_positive", "negative_negative"), terminal_a1 = c(1, 1, 0), measurements = c(1, 2, 2), probability_given_target = c(.8, .2 * .8, .2^2), probability_given_nontarget = c(.1, .9 * .1, .9^2))
  list(policy_values = risks, branches = branch, terminal_paths = paths, value_summary = tibble::tibble(current_risk = .7, expected_terminal_one_test = .31, gross_evsi = .39, evpi = .7, test_cost = .1, net_value_one_test = .29, policy_sensitivity = .96, policy_false_positive = .19, expected_measurements = 1.69, policy_terminal_loss = .181, policy_total_loss = .35, always_two_total_loss = .381))
}

# Same person, one target draw, shared uncertain sensitivity; ordered path likelihoods.
m11_uncertain_test <- function(a = 1, b = 1, q = .3, f = .1, length = 2L) {
  if (min(a, b) <= 0 || q <= 0 || q >= 1 || f <= 0 || f >= 1 || length < 0 || length != floor(length)) stop("Proper beta, interior probabilities and nonnegative integer length required.")
  k <- 0:length; m1 <- q * exp(lbeta(a + k, b + length - k) - lbeta(a, b)); m0 <- (1 - q) * f^k * (1 - f)^(length - k)
  plug <- q * (a / (a + b))^k * (1 - a / (a + b))^(length - k)
  tibble::tibble(positives = k, ordered_length = length, target_joint_mass = m1, nontarget_joint_mass = m0, integrated_target_probability = m1 / (m1 + m0), plugin_target_probability = plug / (plug + m0), count_multiplicity = choose(length, k), count_predictive_probability = choose(length, k) * (m1 + m0))
}

m11_tables <- function(nodes = 64L, function_data = NULL, horizon_data = NULL) {
  flag <- m11_flag(nodes); fun <- if (is.null(function_data)) m11_function() else m11_function(function_data); time <- if (is.null(horizon_data)) m11_horizon() else m11_horizon(horizon_data)
  validity <- m11_validity(); transport <- m11_transport(); validation <- m11_validation(); decision <- m11_decisions(flag$risk); information <- m11_information()
  rarity <- tibble::tibble(target_event_probability = c(.01, .5, 0), nontarget_event_probability = .01, prevalence = .1, target_given_event = m11_risk(c(.01, .5, 0), .01, .1))
  tail <- tibble::tibble(record = c("exact_score_minus_two", "tail_at_most_minus_two"), likelihood_ratio = c(exp(1.5), stats::pnorm(-1) / stats::pnorm(-2)))
  tail$target_probability <- .1 * tail$likelihood_ratio / (.1 * tail$likelihood_ratio + .9)
  c(list(rarity = rarity, score_vs_tail = tail, operating_bridge = tibble::tibble(measure = c("X1", "X2"), replication_reliability = c(1 / 1.01, 1 / 2), class_mean_shift = c(0, 1), observed_within_class_variance = c(1.01, 2), auc = c(.5, stats::pnorm(.5))), flag_parameters = flag$posterior, flag_risk = flag$risk, function_fit = fun$fit, function_intervals = fun$intervals, horizon = time), validity, list(transport_parameters = transport$parameters, transport_vertices = transport$vertices, transported_risk = transport$summary, spectrum = transport$spectrum), validation, list(missing_verification = m11_missing()), decision, information, list(uncertain_repeated_test = m11_uncertain_test()))
}
