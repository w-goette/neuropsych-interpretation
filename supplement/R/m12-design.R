# Synthetic design calculations. Source this file; no project package installation.
# A value called variance is in squared target-score units, not an SD.
m12_positive <- function(x, name, zero = FALSE) {
  if (!is.numeric(x) || any(!is.finite(x)) || any(if (zero) x < 0 else x <= 0)) stop(name, " has invalid values.", call. = FALSE)
  invisible(x)
}
m12_cp <- function(k, n, error = .05) {
  if (length(k) != 1 || length(n) != 1 || n < 1 || k < 0 || k > n || k != floor(k) || n != floor(n) || error <= 0 || error >= 1) stop("Invalid binomial inputs.")
  c(lower = if (k == 0) 0 else stats::qbeta(error / 2, k, n - k + 1), upper = if (k == n) 1 else stats::qbeta(1 - error / 2, k + 1, n - k))
}
# The error on the new observation must be independent of the old record/state.
m12_update <- function(K, x, noise = 1) {
  if (!is.matrix(K) || nrow(K) != ncol(K) || length(x) != nrow(K) || any(!is.finite(K)) || any(!is.finite(x)) || !isTRUE(all.equal(K, t(K))) || min(eigen(K, symmetric = TRUE, only.values = TRUE)$values) <= 0) stop("K must be positive definite and match x.")
  m12_positive(noise, "Noise variance"); if (length(noise) != 1) stop("Scalar noise needed.")
  Kx <- as.vector(K %*% x)
  K - tcrossprod(Kx) / (noise + sum(x * Kx))
}
m12_paths <- function(max_additions = 8L) {
  if (length(max_additions) != 1 || max_additions < 0 || max_additions != floor(max_additions)) stop("Nonnegative integer needed.")
  dplyr::bind_rows(lapply(0:max_additions, function(k) {
    split <- 0:k; variance <- 1 / (2 + split) + 1 / (1 + k - split); best <- which.min(variance)
    tibble::tibble(added = k, strategy = c("Repeat H1", "Measure H2", "Best split"),
      h1_variance = c(1 / (2 + k), .5, 1 / (2 + split[best])),
      contrast_variance = c(1 / (2 + k) + 1, .5 + 1 / (1 + k), variance[best]),
      added_h1 = c(k, 0, split[best]), added_h2 = c(0, k, k - split[best]))
  }))
}
m12_coordinate_allocation <- function(coefficient = c(1, -1), noise_sd = c(1, 2), cost = c(1, 1), budget = 12) {
  if (length(coefficient) != length(noise_sd) || length(cost) != length(coefficient) || any(!is.finite(coefficient)) || all(coefficient == 0)) stop("Nonzero target with matched inputs needed.")
  m12_positive(c(noise_sd, cost, budget), "Positive allocation inputs")
  effort <- budget * abs(coefficient) * noise_sd / sqrt(cost) / sum(abs(coefficient) * noise_sd * sqrt(cost))
  tibble::tibble(coordinate = seq_along(effort), coefficient, noise_sd, cost, effort, variance_term = ifelse(effort == 0, 0, coefficient^2 * noise_sd^2 / effort))
}
m12_gt <- function(prior = c(1, 1, 1), budget = 40) {
  m12_positive(prior, "Grid probabilities"); if (length(prior) != 3 || budget < 6) stop("Three grid probabilities and feasible budget needed.")
  prior <- prior / sum(prior); base <- c(64, 9, 4, 16, 9, 4, 36)
  # Component order P,T,R,PT,PR,TR,e; contrast order e,PT,PR,TR,P,T,R.
  A <- rbind(c(0,0,0,0,0,0,1), c(0,0,0,2,0,0,1), c(0,0,0,0,4,0,1), c(0,0,0,0,0,20,1), c(8,0,0,2,4,0,1), c(0,40,0,2,0,20,1), c(0,0,80,0,4,20,1))
  df <- c(57,57,19,3,19,3,1); SS <- df * c(36,68,72,116,616,508,472)
  index <- as.matrix(expand.grid(rep(list(1:3), 7))); grid <- sweep(matrix(c(.5,1,2)[index], nrow(index), 7), 2, base, `*`)
  lambda <- grid %*% t(A); v0 <- as.vector(grid %*% c(1/20,1/4,1/2,1/80,1/40,1/8,1/160))
  log_weight <- rowSums(sweep(log(lambda), 2, -df/2, `*`) - sweep(1 / lambda, 2, SS/2, `*`)) + stats::dnorm(50, 50, sqrt(100 + v0), log = TRUE) + rowSums(matrix(log(prior)[index], nrow(index), 7))
  weight <- exp(log_weight - max(log_weight)); weight <- weight / sum(weight)
  designs <- expand.grid(tasks = 1:floor(budget), raters = 1:floor(budget)) |>
    dplyr::mutate(cost = 2 * tasks + 3 * raters + tasks * raters) |> dplyr::filter(cost <= budget)
  co <- with(designs, cbind(0, 1/tasks, 1/raters, 1/tasks, 1/raters, 1/(tasks*raters), 1/(tasks*raters)))
  errors <- grid %*% t(co); opt <- max.col(-errors, ties.method = "first")
  designs$supplied_mse <- as.vector(co %*% base); designs$posterior_mse <- colSums(errors * weight)
  designs$probability_grid_optimal <- vapply(seq_len(nrow(designs)), function(i) sum(weight[opt == i]), numeric(1))
  list(designs = tibble::as_tibble(designs), components = tibble::tibble(component = c("P","T","R","PT","PR","TR","e"), posterior_mean = colSums(grid * weight)), normalizer_weights = weight)
}
m12_item_design <- function(shape = 1) {
  m12_positive(shape, "Beta shape"); if (length(shape) != 1) stop("Scalar shape needed.")
  allocation <- tibble::tibble(allocation = c("None","A","Two A","Three A","B","A+B"), rA = c(0,1,2,3,0,1), rB = c(0,0,0,0,1,1))
  success <- matrix(c(2,3,14,18), 2, 2); pa <- shape + success; pb <- shape + 20 - success; pi <- (shape + 12) / (2 * shape + 40)
  probability <- function(x, r, h) prod(choose(r, x) * exp(lbeta(pa[,h] + x, pb[,h] + r - x) - lbeta(pa[,h], pb[,h])))
  pattern <- dplyr::bind_rows(lapply(seq_len(nrow(allocation)), function(i) {
    r <- as.numeric(allocation[i,c("rA","rB")]); x <- expand.grid(xA = 0:r[1], xB = 0:r[2]); p0 <- apply(x, 1, probability, r = r, h = 1); p1 <- apply(x, 1, probability, r = r, h = 2)
    tibble::tibble(allocation = allocation$allocation[i], xA = x$xA, xB = x$xB, predictive0 = p0, predictive1 = p1, joint0 = (1-pi)*p0, joint1 = pi*p1, action = as.integer(pi*p1 > (1-pi)*p0))
  }))
  risk <- pattern |> dplyr::group_by(allocation) |> dplyr::summarise(posterior_error = sum(pmin(joint0, joint1)), .groups = "drop")
  list(risk = dplyr::left_join(allocation, risk, by = "allocation") |> dplyr::mutate(beta_shape = shape, cost = rA + 2*rB), pattern = pattern)
}
m12_information <- function(h = 0, slope = c(1,2), difficulty = c(0,1)) {
  if (length(h)!=1 || !is.finite(h) || length(slope)!=length(difficulty) || any(!is.finite(difficulty))) stop("Matched item parameters needed.")
  m12_positive(slope, "Slopes"); if(length(slope)>12) stop("Finite teaching enumeration limited to twelve items.")
  p <- stats::plogis(slope*(h-difficulty)); if(any(p<=0 | p>=1)) stop("Numerical response boundary; choose a supported finite illustration range."); u <- as.matrix(expand.grid(rep(list(0:1),length(p)))); prob <- apply(u,1,function(z)prod(p^z*(1-p)^(1-z))); score <- as.vector(sweep(u,2,p,`-`) %*% slope); total <- rowSums(u)
  by_total <- tibble::tibble(total, prob, derivative=prob*score) |> dplyr::group_by(total) |> dplyr::summarise(prob=sum(prob),derivative=sum(derivative),.groups="drop")
  mean <- sum(by_total$total*by_total$prob); variance <- sum((by_total$total-mean)^2*by_total$prob); derivative <- sum(by_total$total*by_total$derivative)
  tibble::tibble(h, moment_bound=derivative^2/variance, total_information=sum(by_total$derivative^2/by_total$prob), full_information=sum(prob*score^2))
}
m12_operating <- function() {
  threshold <- c(0,.5,.5+log(9)); fp <- stats::pnorm(threshold,lower.tail=FALSE); tp <- stats::pnorm(threshold-1,lower.tail=FALSE)
  tibble::tibble(criterion=c("Local shift","Global binary AUC","Operating loss"), threshold, shift_information=stats::dnorm(threshold)^2/(fp*(1-fp)), auc=(1+tp-fp)/2, binary_error=pmin(.9*fp,.1*tp)+pmin(.9*(1-fp),.1*(1-tp)))
}
m12_separation <- function(precision, covariance=matrix(c(1,.6,.6,1),2), shift=c(1,0)) {
  m12_positive(precision,"Precision",zero=TRUE)
  if (!is.matrix(covariance) || length(shift)!=length(precision) || nrow(covariance)!=length(shift) || ncol(covariance)!=length(shift) || !isTRUE(all.equal(covariance,t(covariance))) || min(eigen(covariance,symmetric=TRUE,only.values=TRUE)$values)<=0 || any(!is.finite(shift))) stop("Valid covariance/shift dimensions needed.")
  residual <- as.vector(solve(diag(length(shift))+covariance%*%diag(precision,length(precision)),shift)); weight <- precision*residual
  list(separation=sum(shift*weight),gradient=residual^2,weight=weight)
}
m12_pilot <- function() {
  pairs <- expand.grid(n1=2:100,n2=2:25) |> dplyr::filter(n1+4*n2<=100)
  pairs$supplied_variance <- .8^2/pairs$n1+.2^2*9/pairs$n2
  pairs$unshrunk_posterior_mse <- .8^2*1.1/pairs$n1+.2^2*6.7/pairs$n2
  pairs$posterior_mean_bayes_mse <- .8^2*1.1/(9+pairs$n1)+.2^2*6.7/(9+pairs$n2)
  lower <- 7*c(1,9)/stats::qchisq(1-.025/2,7); upper <- 7*c(1,9)/stats::qchisq(.025/2,7)
  pairs$confidence_variance_lower <- .8^2*lower[1]/pairs$n1+.2^2*lower[2]/pairs$n2; pairs$confidence_variance_upper <- .8^2*upper[1]/pairs$n1+.2^2*upper[2]/pairs$n2
  tibble::as_tibble(pairs)
}
m12_regression <- function() {
  i <- 0:19; x <- (-1)^(i+1); y <- 50+2*x+sin(i); X <- cbind(1,x); b <- solve(crossprod(X),crossprod(X,y)); S2 <- sum((y-X%*%b)^2)/18; Kn <- solve(diag(.01,2)+crossprod(X)); mn <- Kn%*%(c(.5,0)+crossprod(X,y)); bn <- 2+.5*(sum(y^2)+25-as.numeric(t(mn)%*%solve(Kn,mn)))
  list(observations=tibble::tibble(index=i,x,y),summary=tibble::tibble(intercept=b[1],slope=b[2],residual_variance=S2,confidence_halfwidth=stats::qt(.975,18)*sqrt(S2/20),prediction_halfwidth=stats::qt(.975,18)*sqrt(S2*1.05),posterior_center=mn[1],credible_halfwidth=stats::qt(.975,24)*sqrt(bn/12*Kn[1,1]),predictive_halfwidth=stats::qt(.975,24)*sqrt(bn/12*(1+Kn[1,1]))))
}
m12_anchor <- function() {
  # NIG pairs are mean, kappa, shape, inverse-gamma scale; variance mean needs shape>1.
  update <- function(n,mean,s2,prior_mean) { k <- .1+n; a <- 2+n/2; b <- 2+.5*(n-1)*s2+.1*n/(2*k)*(mean-prior_mean)^2; c(mean=(.1*prior_mean+n*mean)/k,kappa=k,shape=a,scale=b) }
  D <- update(8,1,4,0); W <- update(4,40,9,40)
  cdf <- function(z) stats::integrate(function(t) stats::pt((z+t-W[1])/sqrt(W[4]/(W[3]*W[2])),2*W[3])*stats::dt((t-D[1])/sqrt(D[4]/(D[3]*D[2])),2*D[3])/sqrt(D[4]/(D[3]*D[2])),-Inf,Inf,rel.tol=1e-9)$value
  credible <- vapply(c(.025,.975),function(p) stats::uniroot(function(z)cdf(z)-p,c(20,60),tol=1e-9)$root,numeric(1));half <- stats::qt(1-.05/4,3)*sqrt(9/4)+stats::qt(1-.05/4,7)*sqrt(4/8)
  pair <- expand.grid(calibrators=1:40,repeats=1:20) |> dplyr::filter(calibrators+2*repeats<=40);pair$posterior_expected_mse <- D[4]/(D[3]-1)/pair$calibrators+W[4]/(W[3]-1)/pair$repeats
  list(summary=tibble::tibble(estimate=39,confidence_lower=39-half,confidence_upper=39+half,posterior_mean=W[1]-D[1],posterior_variance=W[4]/(W[3]-1)/W[2]+D[4]/(D[3]-1)/D[2],credible_lower=credible[1],credible_upper=credible[2],bounded_drift_lower=39-half-2,bounded_drift_upper=39+half+2),allocation=tibble::as_tibble(pair))
}
m12_paired <- function() {
  cdf <- function(z) stats::integrate(function(s) stats::pbeta(pmin(1,pmax(0,(1+z/s)/2)),6,16)*stats::dbeta(s,22,82),0,1,abs.tol=1e-10,subdivisions=400)$value
  ci <- vapply(c(.025,.975),function(p)stats::uniroot(function(z)cdf(z)-p,c(-.99,.99),tol=1e-9)$root,numeric(1))
  tibble::tibble(pvalue=2*stats::pbinom(5,20,.5),posterior_difference_mean=-10/104,probability_A_better=stats::pbeta(.5,6,16),credible_lower=ci[1],credible_upper=ci[2])
}
m12_paired_success <- function(n, assurance=FALSE) {
  if (length(n)!=1 || n<1 || n!=floor(n)) stop("Positive integer validation size needed.")
  bb <- function(k,n,a,b) exp(lchoose(n,k)+lbeta(a+k,b+n-k)-lbeta(a,b))
  sum(vapply(1:n,function(m) { k <- 0:m;pv <- pmin(1,2*pmin(stats::pbinom(k,m,.5),stats::pbinom(k-1,m,.5,lower.tail=FALSE)));reject <- pv<=.05+1e-14
    if(assurance) bb(m,n,22,82)*sum(bb(k,m,6,16)[reject & k<m/2]) else stats::dbinom(m,n,.2)*sum(stats::dbinom(k,m,.25)[reject]) },numeric(1)))
}
m12_majority <- function() {
  risk <- function(q) q+(1-2*q)*stats::pbinom(4,9,q,lower.tail=FALSE)
  mean <- sum(vapply(0:9,function(k) exp(lchoose(9,k)+lbeta(13+k+(k<=4),29+9-k+(k>4))-lbeta(13,29)),numeric(1)))
  direct <- stats::integrate(function(q)risk(q)*stats::dbeta(q,13,29),0,1,rel.tol=1e-12)$value
  cdf <- function(z) { q <- stats::uniroot(function(q)risk(q)-z,c(0,.5),tol=1e-13)$root;stats::pbeta(q,13,29)+stats::pbeta(1-q,13,29,lower.tail=FALSE) }
  ci <- vapply(c(.025,.975),function(p)stats::uniroot(function(z)cdf(z)-p,c(1e-8,.5-1e-8),tol=1e-9)$root,numeric(1)); qci <- m12_cp(12,40)
  tibble::tibble(fixed_q=.3,fixed_q_learning_risk=risk(.3),confidence_lower=risk(qci[1]),confidence_upper=risk(qci[2]),posterior_mean=mean,quadrature_mean=direct,credible_lower=ci[1],credible_upper=ci[2])
}
m12_transport <- function() {
  a <- c(4,6); b <- c(58,16); w <- c(21,31);meanr <- a/(a+b);er2 <- a*(a+1)/((a+b)*(a+b+1));ew <- w/sum(w);ew2 <- w*(w+1)/(sum(w)*(sum(w)+1));second <- sum(ew2*er2)+2*prod(w)/(sum(w)*(sum(w)+1))*prod(meanr);mean <- sum(ew*meanr)
  limits <- list(m12_cp(3,60,.05/3),m12_cp(5,20,.05/3),m12_cp(30,50,.05/3));corners <- expand.grid(limits);risk <- (1-corners[,3])*corners[,1]+corners[,3]*corners[,2]
  tibble::tibble(source_sample_error=.1,target_plugin_error=.17,posterior_mean=mean,posterior_variance=second-mean^2,confidence_lower=min(risk),confidence_upper=max(risk))
}
m12_verification <- function() {
  total <- 103;theta <- c(.5,.1);mean <- 15/total+31/total*theta;theta2 <- c(1/3,2/(10*11));second <- 15*16/(total*(total+1))+31*32/(total*(total+1))*theta2+2*15*31/(total*(total+1))*theta
  tibble::tibble(missing_prior=c("Beta(1,1)","Beta(1,9)"),identified_lower=.14,identified_upper=.44,whole_set_confidence_lower=stats::qbeta(.025,14,87),whole_set_confidence_upper=1-stats::qbeta(.025,56,45),posterior_mean=mean,posterior_variance=second-mean^2)
}
m12_tables <- function() {
  gt <- m12_gt(); tilted <- m12_gt(c(.6,.3,.1));item1 <- m12_item_design();item2 <- m12_item_design(2);anchor <- m12_anchor();reg <- m12_regression();pilot <- m12_pilot()
  allocation <- dplyr::bind_rows(lapply(c("supplied_variance","unshrunk_posterior_mse","posterior_mean_bayes_mse","confidence_variance_upper"),function(key)pilot[which.min(pilot[[key]]),] |> dplyr::mutate(criterion=key)))
  correlated <- dplyr::bind_rows(lapply(seq(0,2,length.out=101),function(l) {q <- m12_separation(c(l,2-l));tibble::tibble(precision1=l,precision2=2-l,separation=q$separation,gradient1=q$gradient[1],gradient2=q$gradient[2])}))
  list(precision_paths=m12_paths(),coordinate_allocation=m12_coordinate_allocation(),gt_designs=gt$designs,gt_components=gt$components,gt_tilted_designs=tilted$designs,item_designs=dplyr::bind_rows(item1$risk,item2$risk),item_patterns=item1$pattern,item_information=m12_information(),operating_criteria=m12_operating(),correlated_allocation=correlated,pilot_allocations=pilot,pilot_selected=allocation,regression_observations=reg$observations,regression_intervals=reg$summary,anchor_summary=anchor$summary,anchor_allocations=anchor$allocation,paired_comparison=m12_paired(),power_assurance=tibble::tibble(n=c(100,200,400),power=vapply(c(100,200,400),m12_paired_success,numeric(1)),assurance=vapply(c(100,200,400),m12_paired_success,numeric(1),assurance=TRUE)),majority_learning=m12_majority(),transport=m12_transport(),missing_verification=m12_verification(),random_verification=tibble::tibble(design=c("Supplied","Variance optimal"),verification1=c(.2,1/3),verification2=c(.8,2/3),population_error=.25,verified_only_error=c(.34,.3),ipw_variance=c(.4375,.3875)),precision_sizes=tibble::tibble(target=c("Zero events: upper1%","Absolute tail error0.02","Bounded loss error0.05"),n=c(ceiling(log(.05)/log(.99)),ceiling(log(40)/(2*.02^2)),ceiling(log(40)/(2*.05^2)))))
}
