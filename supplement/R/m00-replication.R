# Finite laws for one fixed synthetic person's declared replications.
# These functions evaluate supplied probabilities; they estimate no model.

#' The two supplied teaching laws used in M00
#' @return A tibble: universe label, possible score, and probability.
m00_replication_law <- function() {
  tibble::tibble(
    universe = rep(c("Universe 1", "Universe 2"), each = 3L),
    score = c(32, 35, 38, 35, 38, 41),
    probability = rep(1 / 3, 6L)
  )
}

#' Evaluate expected performance and residuals under complete finite laws
#' @param law A data frame with character universe and numeric score/probability.
#'   Each universe supplies a complete probability law; weights are not normalized.
#' @param observed One finite observed score admitted with positive probability
#'   under every supplied universe.
#' @return A list: law (including weighted contributions and residuals), summary.
m00_evaluate_replication <- function(law, observed = 35) {
  required <- c("universe", "score", "probability")
  if (!is.data.frame(law) || !all(required %in% names(law)) || nrow(law) == 0L) {
    stop("law must be a nonempty data frame with universe, score and probability.", call. = FALSE)
  }
  if (!is.character(law$universe) || anyNA(law$universe) ||
      any(!nzchar(trimws(law$universe)))) {
    stop("universe labels must be nonempty character strings.", call. = FALSE)
  }
  if (!is.numeric(law$score) || !is.numeric(law$probability) ||
      any(!is.finite(law$score)) || any(!is.finite(law$probability)) ||
      any(law$probability < 0)) {
    stop("scores and probabilities must be finite, and probabilities nonnegative.", call. = FALSE)
  }
  if (!is.numeric(observed) || length(observed) != 1L || !is.finite(observed)) {
    stop("observed must be one finite numeric score.", call. = FALSE)
  }
  if (anyDuplicated(law[, c("universe", "score")])) {
    stop("combine duplicate support scores within each universe first.", call. = FALSE)
  }
  groups <- split(law, law$universe)
  if (any(vapply(groups, function(x) abs(sum(x$probability) - 1) > 1e-12, logical(1)))) {
    stop("probabilities must sum to one within each universe.", call. = FALSE)
  }
  if (any(vapply(groups, function(x) !any(x$score == observed & x$probability > 0), logical(1)))) {
    stop("observed score must have positive probability in every supplied universe.", call. = FALSE)
  }
  # A probability-weighted sum is an expectation over possible repeats, not
  # an average over observed reference persons or an estimated latent ability.
  summary <- dplyr::summarise(
    dplyr::group_by(law, .data$universe),
    expected_score = sum(.data$score * .data$probability),
    .groups = "drop"
  )
  if (any(!is.finite(summary$expected_score))) stop("numeric expectation overflow.", call. = FALSE)
  detail <- dplyr::mutate(
    dplyr::left_join(tibble::as_tibble(law), summary, by = "universe"),
    contribution = .data$score * .data$probability,
    residual = .data$score - .data$expected_score
  )
  centered <- dplyr::summarise(
    dplyr::group_by(detail, .data$universe),
    mean_residual = sum(.data$probability * .data$residual), .groups = "drop"
  )
  summary <- dplyr::mutate(
    dplyr::left_join(summary, centered, by = "universe"),
    observed_score = observed,
    observed_residual = observed - .data$expected_score
  )
  list(law = detail, summary = summary)
}
