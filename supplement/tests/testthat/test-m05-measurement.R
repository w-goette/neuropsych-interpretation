testthat::test_that("finite-repeat covariance and endpoint designs are respected", {
  testthat::expect_equal(m05_replication()$average_error_variance,9)
  testthat::expect_equal(m05_replication(common=9)$average_error_variance,15.75)
  testthat::expect_equal(m05_replication(common=-12)$average_error_variance,0)
  testthat::expect_error(m05_replication(common=-12,repeats=5),"covariance")
  testthat::expect_error(m05_replication(stable=0,noise=0),"covariance")
  testthat::expect_equal(m05_replication(stable=9)$error_sd,3)
  testthat::expect_equal(m05_replication(stable=0)$single_reliability,0)
  testthat::expect_equal(m05_replication(noise=0)$average_reliability,1)
  moment <- m05_moment_counterexample()
  testthat::expect_equal(moment[1,2:7],moment[2,2:7])
  testthat::expect_equal(moment$posterior_positive_tau,c(.75,.25))
})

testthat::test_that("binomial confidence is conservative over fixed person probabilities", {
  intervals <- dplyr::bind_rows(lapply(0:8,function(s)m05_binary(s)))
  for (p in seq(0,1,length.out=51)) {
    contained <- intervals$confidence_lower <= p & intervals$confidence_upper >= p
    testthat::expect_gte(sum(stats::dbinom(0:8,8,p)*contained),.95-1e-12)
  }
  testthat::expect_equal(m05_binary(0)$confidence_lower,0)
  testthat::expect_equal(m05_binary(8)$confidence_upper,1)
  x <- m05_binary()
  testthat::expect_equal(stats::pbeta(x$credible_lower,4,8),.025,tolerance=1e-10)
  testthat::expect_equal(stats::pbinom(2,8,x$confidence_upper),.025,tolerance=1e-10)
  testthat::expect_error(m05_binary(a=0),"positive")
  testthat::expect_error(m05_binary(9),"binomial")
})

testthat::test_that("Gaussian conditional calculation works with deficient loadings", {
  result <- m05_gaussian(2,0,matrix(c(1,0),1),matrix(1),c(0,0),matrix(c(1,.8,.8,1),2))
  testthat::expect_equal(result$mean,c(1,.8))
  testthat::expect_equal(result$covariance,matrix(c(.5,.4,.4,.68),2))
  prior <- m05_gaussian(2,0,matrix(c(0,0),1),matrix(1),c(3,4),diag(2))
  testthat::expect_equal(prior$mean,c(3,4))
  testthat::expect_equal(prior$covariance,diag(2))
  testthat::expect_error(m05_gaussian(2,0,matrix(1),matrix(0),0,matrix(1)))
  testthat::expect_error(m05_gaussian(2,0,matrix(1),matrix(1),0,matrix(-1)))
  rows <- m05_scalar()
  testthat::expect_equal(rows$center,c(35,40.4,35,40.4))
  testthat::expect_gt(rows$variance[3],rows$variance[1])
  testthat::expect_gt(rows$variance[4],rows$variance[2])
  # Integrate fixed-tau coverage over the declared prior by a separate1D route.
  for (column in c("credible","posterior_predictive")) {
    value <- stats::integrate(function(t) m05_coverage(t)[[column]]*stats::dnorm(t,50,8),-Inf,Inf,rel.tol=1e-7)$value
    testthat::expect_equal(value,.95,tolerance=1e-7)
  }
  testthat::expect_lt(m05_coverage(20)$credible,.4)
  testthat::expect_error(m05_scalar(noise=0),"positive")
})

testthat::test_that("all crossed contrasts agree with the dense covariance experiment", {
  data <- m05_crossed_data();design <- m05_crossed_map()
  eq <- function(x) outer(x,x,`==`)*1
  person <- eq(data$person);task <- eq(data$task);rater <- eq(data$rater)
  theta <- c(64,9,4,16,9,4,36)
  V <- theta[1]*person+theta[2]*task+theta[3]*rater+theta[4]*person*task+
    theta[5]*person*rater+theta[6]*task*rater+theta[7]*diag(160)
  H <- function(d) matrix(1/d,d,d);C <- function(d) diag(d)-H(d)
  effect <- c("PTR","PT","PR","TR","P","T","R")
  projections <- lapply(effect,function(e)kronecker(kronecker(if(grepl("P",e))C(20)else H(20),
    if(grepl("T",e))C(4)else H(4)),if(grepl("R",e))C(2)else H(2)))
  lambda <- as.vector(design$A%*%theta)
  for (i in seq_along(effect)) {
    A <- projections[[i]]
    testthat::expect_equal(sum(diag(A)),design$df[i],tolerance=1e-10)
    testthat::expect_equal(sum(diag(A%*%V))/design$df[i],lambda[i],tolerance=1e-10)
    testthat::expect_equal(A%*%V%*%A,lambda[i]*A,tolerance=1e-9)
    ms <- as.numeric(crossprod(data$score,A%*%data$score))/design$df[i]
    testthat::expect_equal(ms,c(36,68,72,116,616,508,472)[i],tolerance=1e-9)
    for (j in seq_len(i-1)) testthat::expect_equal(projections[[j]]%*%V%*%A,matrix(0,160,160),tolerance=1e-9)
  }
  testthat::expect_equal(mean(data$score),50,tolerance=1e-12)
  testthat::expect_equal(mean(data$score[data$person==1]),35.909222874518,tolerance=1e-10)
  # Integrate mu in the dense covariance and compare log-likelihood ratios to spectral law.
  dense <- function(th) {
    V <- th[1]*person+th[2]*task+th[3]*rater+th[4]*person*task+
      th[5]*person*rater+th[6]*task*rater+th[7]*diag(160)+400*matrix(1,160,160)
    z <- data$score-50;U <- chol(V)
    -sum(log(diag(U)))-as.numeric(crossprod(z,solve(V,z)))/2
  }
  spectral <- function(th) {
    la <- as.vector(design$A%*%th);v0 <- sum(th*design$v0_weights)
    sum(-design$df/2*log(la)-design$df*c(36,68,72,116,616,508,472)/(2*la))-.5*log(400+v0)
  }
  other <- theta*c(.7,1.2,.4,2,.8,1.4,1.1)
  testthat::expect_equal(dense(other)-dense(theta),spectral(other)-spectral(theta),tolerance=1e-9)
  testthat::expect_error(m05_crossed_map(K=1),"at least two")
})

testthat::test_that("universe switches and confidence boxes retain their experiments", {
  random <- m05_gt();fixed <- m05_gt(fixed_raters=TRUE)
  testthat::expect_equal(random$person_variance,64)
  testthat::expect_equal(fixed$person_variance,68.5)
  testthat::expect_equal(random$relative_error,13)
  testthat::expect_equal(random$absolute_error,17.75)
  testthat::expect_equal(fixed$relative_error,8.5)
  testthat::expect_equal(fixed$absolute_error,11.25)
  testthat::expect_error(m05_gt(rep(0,7)),"Undefined")
  box <- m05_crossed_box()
  testthat::expect_true(all(c(64,9,4,16,9,4,36)>=box$component$lower))
  testthat::expect_true(all(c(64,9,4,16,9,4,36)<=box$component$upper))
  testthat::expect_false(box$empty)
  testthat::expect_equal(m05_box_design(box,sharpen_original=TRUE)$relative_upper,.9759299,tolerance=5e-7)
  testthat::expect_true(m05_oneway(B=.001,W=36)$empty)
  testthat::expect_true(is.na(m05_oneway(B=.001,W=36)$eta_lower))
  testthat::expect_error(m05_oneway(m=1),"design")
  testthat::expect_error(m05_oneway(n=20.5),"design")
})

testthat::test_that("state bounds and actual mixture CDFs obey independent benchmarks", {
  state <- m05_state_calibration()
  testthat::expect_equal(state$share_confidence_upper,.920584,tolerance=5e-7)
  testthat::expect_equal(state$uniform_split_mean,.333430,tolerance=5e-7)
  testthat::expect_equal(state$beta82_split_mean/state$uniform_split_mean,1.6,tolerance=1e-10)
  one <- m05_mixture(40.4,23.04,1)
  testthat::expect_equal(c(one$lower,one$upper),40.4+stats::qnorm(c(.025,.975))*4.8,tolerance=1e-7)
  two <- m05_mixture(c(-1,1),c(1,1),c(.5,.5))
  testthat::expect_equal(two$mean,0)
  testthat::expect_equal(two$variance,2)
  testthat::expect_equal(two$lower,-two$upper,tolerance=1e-7)
  u <- m05_halton(512)
  testthat::expect_true(all(u>0 & u<1))
  testthat::expect_lt(max(abs(colMeans(u)-.5)),.006)
  small <- m05_crossed_posterior(512,person=FALSE)
  testthat::expect_true(all(small$coefficients$relative_mean>0 & small$coefficients$relative_mean<1))
  testthat::expect_true(all(small$coefficients$absolute_mean<=small$coefficients$relative_mean))
  testthat::expect_gt(small$coefficients$relative_mean[2],small$coefficients$relative_mean[1])
  testthat::expect_error(m05_crossed_posterior(512,shape=2),"finite-second")
})
