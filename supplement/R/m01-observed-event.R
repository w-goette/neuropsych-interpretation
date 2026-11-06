#' Tabulate strict, inclusive and midpoint reference comparisons
#'
#' A finite, supplied score law is the input, not an estimated norm table.
#' Rows are sorted by score. Probabilities are retained without renormalizing.
#' These are observed-score comparisons, not latent or diagnostic probabilities.
#' @param scores Distinct finite numeric score values.
#' @param probabilities Nonnegative finite masses, one per score, summing to one
#'   within 1e-12 (floating-point tolerance).
#' @return A tibble of score, probability, four strict/inclusive tails and midpoint.
#' @export
m01_reference_table <- function(scores, probabilities) {
  if (!is.numeric(scores) || !is.null(dim(scores)) || !length(scores) || any(!is.finite(scores)) ||
      anyDuplicated(scores)) {
    stop("scores must be distinct finite numeric values.", call. = FALSE)
  }
  if (!is.numeric(probabilities) || !is.null(dim(probabilities)) || length(probabilities) != length(scores) ||
      any(!is.finite(probabilities)) || any(probabilities < 0) ||
      abs(sum(probabilities) - 1) > 1e-12) {
    stop("probabilities must be nonnegative finite masses summing to one.", call. = FALSE)
  }
  tibble::tibble(score = scores, probability = probabilities) |>
    dplyr::arrange(.data$score) |>
    dplyr::mutate(
      inclusive_lower = cumsum(.data$probability),
      strict_lower = dplyr::lag(.data$inclusive_lower, default = 0),
      strict_upper = 1 - .data$inclusive_lower,
      inclusive_upper = 1 - .data$strict_lower,
      midpoint = .data$strict_lower + .data$probability / 2
    )
}

#' Calculate the population fraction flagged by each rank convention
#'
#' For each supplied level u, sum masses at scores whose rank is at most u.
#' Equality comparisons allow 8 machine epsilons to prevent cumulative-sum
#' roundoff from excluding an intended equality such as 0.1 + 0.2 = 0.3.
#' Levels closer than that tolerance to a jump are numerically indistinguishable
#' for this implementation; the mathematical rule remains rank <= u.
#' @param scores Distinct finite numeric scores.
#' @param probabilities Supplied masses as in m01_reference_table().
#' @param levels Finite numeric rule levels in [0,1], including any jump values.
#' @return A long tibble with convention, level and flagged_fraction (proportions).
#' @export
m01_flagging_curve <- function(scores, probabilities, levels) {
  reference <- m01_reference_table(scores, probabilities)
  if (!is.numeric(levels) || !is.null(dim(levels)) || !length(levels) || any(!is.finite(levels)) ||
      any(levels < 0 | levels > 1)) {
    stop("levels must be finite numbers in [0,1].", call. = FALSE)
  }
  columns <- c("inclusive_lower", "midpoint", "strict_lower")
  labels <- c("Inclusive", "Midpoint", "Strict")
  rows <- lapply(seq_along(columns), function(index) {
    ranks <- reference[[columns[[index]]]]
    tibble::tibble(
      convention = labels[[index]],
      level = sort(unique(levels)),
      flagged_fraction = vapply(sort(unique(levels)), function(level) {
        included <- ranks < level | dplyr::near(ranks, level, tol = 8 * .Machine$double.eps)
        sum(reference$probability[included])
      }, numeric(1))
    )
  })
  dplyr::bind_rows(rows)
}

#' Compare confidence and posterior summaries for a fixed event
#'
#' Reference persons are independent with a common event probability. The event
#' and sample size are fixed independently of the evaluation observations. The
#' Bayesian calculation uses a proper Beta(a,b) prior for that same probability.
#' No patient ability, retest or disease model is supplied.
#' @param n Nonnegative integer number of reference persons.
#' @param k Integer event count between zero and n.
#' @param a,b Strictly positive finite beta prior shapes; defaults 1,1 are a
#'   teaching choice, not an automatically suitable clinical prior.
#' @param level Interval probability/nominal coverage, strictly between 0 and 1.
#' @return One tibble row: inputs, empirical frequency, confidence/credible
#'   limits, posterior mean and new-reference-person predictive probability.
#'   At n=0 empirical frequency is NA and [0,1] records no sampling information;
#'   it is not an application of the n>=1 confidence theorem. Posterior = prior.
#' @export
m01_frequency <- function(n, k, a = 1, b = 1, level = .95) {
  scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  if (!scalar(n) || n < 0 || n != floor(n) ||
      !scalar(k) || k < 0 || k > n || k != floor(k)) {
    stop("n and k must be integers with 0 <= k <= n.", call. = FALSE)
  }
  if (!scalar(a) || !scalar(b) || a <= 0 || b <= 0) {
    stop("a and b must be strictly positive finite prior shapes.", call. = FALSE)
  }
  if (!scalar(level) || level <= 0 || level >= 1) {
    stop("level must be strictly between zero and one.", call. = FALSE)
  }
  alpha <- 1 - level
  posterior_a <- a + k
  posterior_b <- b + n - k
  if (!is.finite(posterior_a + posterior_b)) {
    stop("updated prior/count total exceeds finite numerical range.", call. = FALSE)
  }
  tibble::tibble(
    n = n, k = k, prior_a = a, prior_b = b, level = level,
    empirical_frequency = if (n == 0) NA_real_ else k / n,
    confidence_lower = if (k == 0) 0 else stats::qbeta(alpha / 2, k, n - k + 1),
    confidence_upper = if (k == n) 1 else stats::qbeta(1 - alpha / 2, k + 1, n - k),
    posterior_a = posterior_a, posterior_b = posterior_b,
    posterior_mean = posterior_a / (posterior_a + posterior_b),
    credible_lower = stats::qbeta(alpha / 2, posterior_a, posterior_b),
    credible_upper = stats::qbeta(1 - alpha / 2, posterior_a, posterior_b),
    predictive_reference_event = posterior_a / (posterior_a + posterior_b)
  )
}

#' Reproduce the chapter M01 synthetic observed-event examples
#'
#' All inputs are stipulated; the normal, four-score and 8/100 examples are
#' separate experiments. No random numbers or empirical clinical data are used.
#' @return A named list of tibbles for normal tails, tied-score comparisons,
#'   coarsening, flagging rules and fixed-event inference/boundaries.
#' @export
m01_example_results <- function() {
  reference <- m01_reference_table(0:3, c(.1, .2, .4, .3))
  normal <- tibble::tibble(
    case_score = 35, known_mean = 50, known_sd = 10,
    standardized_score = (35 - 50) / 10,
    lower_tail = stats::pnorm((35 - 50) / 10),
    upper_tail = stats::pnorm((35 - 50) / 10, lower.tail = FALSE),
    two_sided_event = 2 * stats::pnorm((35 - 50) / 10)
  )
  # Grouping 0/1 and 2/3 retains category masses but loses within-category detail.
  coarsening <- reference |>
    dplyr::mutate(category = ifelse(.data$score <= 1, "Lower: 0 or 1", "Upper: 2 or 3")) |>
    dplyr::group_by(.data$category) |>
    dplyr::summarise(category_probability = sum(.data$probability), .groups = "drop")
  # Include every possible rank jump, the display limits and the two teaching levels.
  levels <- sort(unique(c(0, 1, .05, .20, reference$strict_lower,
                          reference$inclusive_lower, reference$midpoint)))
  list(
    normal = normal,
    reference = reference,
    coarsening = coarsening,
    flagging = m01_flagging_curve(reference$score, reference$probability, levels),
    frequency = dplyr::bind_rows(
      m01_frequency(100, 8), m01_frequency(100, 0),
      m01_frequency(100, 100), m01_frequency(0, 0)
    )
  )
}
