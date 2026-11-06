testthat::test_that("M12 precision agrees with direct Gaussian conditioning and protects domains", {
  K <- matrix(c(1,.5,.5,1),2);x <- c(0,1);nextK <- m12_update(K,x)
  testthat::expect_equal(nextK,solve(solve(K)+tcrossprod(x)),tolerance=1e-13)
  testthat::expect_equal(K[1,1]-nextK[1,1],1/8,tolerance=1e-14)
  testthat::expect_equal(m12_update(diag(c(.5,1)),x)[1,1],.5)
  testthat::expect_error(m12_update(diag(c(1,0)),x));testthat::expect_error(m12_update(K,x,0));testthat::expect_error(m12_update(K,1))
  testthat::expect_error(m12_paths(-1));testthat::expect_error(m12_coordinate_allocation(coefficient=c(0,0)))
  allocation <- m12_coordinate_allocation();testthat::expect_equal(allocation$effort,c(4,8));testthat::expect_equal(sum(allocation$variance_term),.75)
  data <- m12_paths();testthat::expect_equal(nrow(data),27L)
  for(k in 0:8) {
    path <- data[data$added==k,]; direct <- m12_update(diag(c(.5,1)),c(1,0))
    testthat::expect_equal(path$contrast_variance[1],1+1/(2+k),tolerance=1e-14)
    testthat::expect_equal(path$contrast_variance[3],min(1/(2+0:k)+1/(1+k-0:k)),tolerance=1e-14)
  }
})
testthat::test_that("M12 unknown-component and pilot allocations keep different estimators distinct", {
  g <- m12_gt();testthat::expect_equal(nrow(g$designs),39L);testthat::expect_equal(sum(g$normalizer_weights),1,tolerance=1e-13)
  d <- g$designs;best <- d[which.min(d$posterior_mse),];testthat::expect_equal(c(best$tasks,best$raters),c(6L,3L));testthat::expect_equal(best$supplied_mse,10.7222222222,tolerance=1e-9);testthat::expect_equal(best$posterior_mse,11.5238,tolerance=5e-5);testthat::expect_equal(best$probability_grid_optimal,.9072,tolerance=5e-5)
  tilted <- m12_gt(c(.6,.3,.1))$designs;testthat::expect_equal(min(tilted$posterior_mse),9.2960,tolerance=5e-5)
  testthat::expect_error(m12_gt(c(1,0,1)));testthat::expect_error(m12_gt(budget=1))
  p <- m12_pilot();testthat::expect_equal(nrow(p),1081L)
  testthat::expect_equal(as.numeric(p[which.min(p$unshrunk_posterior_mse),c("n1","n2")]),c(44,14))
  testthat::expect_equal(as.numeric(p[which.min(p$posterior_mean_bayes_mse),c("n1","n2")]),c(56,11))
})
testthat::test_that("M12 item mixtures integrate unknown calibration before choosing action", {
  a <- m12_item_design();testthat::expect_lt(max(abs(a$risk$posterior_error-c(.309524,.192641,.179089,.119377,.167749,.144382))),5e-7)
  testthat::expect_lt(max(abs(m12_item_design(2)$risk$posterior_error-c(.318182,.219697,.196667,.142867,.195076,.165088))),5e-7)
  testthat::expect_error(m12_item_design(0))
  # Independent scalar beta integral for three repeats of A in state0.
  aa <- a$pattern[a$pattern$allocation=="Three A",]
  for(k in 0:3) {
    direct <- stats::integrate(function(q)stats::dbinom(k,3,q)*stats::dbeta(q,3,19),0,1,rel.tol=1e-11)$value
    testthat::expect_equal(aa$predictive0[aa$xA==k],direct,tolerance=1e-11)
  }
  testthat::expect_equal(aa$action,c(0L,0L,1L,1L))
  testthat::expect_gt(abs(aa$predictive0[aa$xA==3]-(3/22)^3),.001)
  for(key in unique(a$pattern$allocation)) {
    p <- a$pattern[a$pattern$allocation==key,];testthat::expect_equal(sum(p$predictive0),1,tolerance=1e-13);testthat::expect_equal(sum(p$predictive1),1,tolerance=1e-13)
  }
  i <- m12_information();testthat::expect_equal(as.numeric(i[1,2:4]),c(.596034,.617478,.669974),tolerance=5e-7)
  eq <- m12_information(slope=c(1,1));testthat::expect_equal(eq$moment_bound,eq$full_information,tolerance=1e-13);testthat::expect_equal(eq$total_information,eq$full_information,tolerance=1e-13)
  testthat::expect_error(m12_information(slope=c(-1,2)));testthat::expect_error(m12_information(h=1000))
})
testthat::test_that("M12 different criteria and correlated boundary derivatives survive", {
  d <- m12_operating();testthat::expect_lt(max(abs(d$auc-c(.670672,.691462,.520666))),5e-7);testthat::expect_lt(max(abs(d$binary_error-c(.1,.1,.098664))),5e-7)
  testthat::expect_equal(m12_separation(c(2,0))$gradient,c(1/9,.16),tolerance=1e-13)
  q <- m12_separation(c(1.875,.125))$separation;testthat::expect_equal(q,.669642857142857,tolerance=1e-13)
  # Supplied covariance inverse is an independent route when both coordinates observed.
  direct <- as.numeric(c(1,0)%*%solve(matrix(c(1,.6,.6,1),2)+diag(1/c(1.875,.125)),c(1,0)))
  testthat::expect_equal(q,direct,tolerance=1e-14)
  testthat::expect_error(m12_separation(c(-1,1)));testthat::expect_error(m12_separation(c(1,1),covariance=matrix(1,2,2)))
})
testthat::test_that("M12 finite coverage, paired and learning experiments retain their targets", {
  for(n in c(1,5,12)) for(p in seq(0,1,.1)) {
    ci <- vapply(0:n,m12_cp,numeric(2),n=n);included <- ci[1,]<=p & p<=ci[2,]
    testthat::expect_gte(sum(stats::dbinom(0:n,n,p)[included]),.95-1e-13)
  }
  testthat::expect_error(m12_cp(21,20));testthat::expect_equal(unname(m12_cp(0,5)[1]),0);testthat::expect_equal(unname(m12_cp(5,5)[2]),1)
  paired <- m12_paired();testthat::expect_equal(paired$pvalue,.04138946533203125,tolerance=1e-12);testthat::expect_equal(paired$credible_lower,-.18432430491,tolerance=1e-8);testthat::expect_equal(paired$credible_upper,-.01143985783,tolerance=1e-8)
  testthat::expect_equal(m12_paired_success(100),.544445427935232,tolerance=1e-12);testthat::expect_equal(m12_paired_success(200,TRUE),.715013,tolerance=5e-7);testthat::expect_equal(m12_paired_success(400,TRUE),.852540,tolerance=5e-7)
  testthat::expect_error(m12_paired_success(0))
  m <- m12_majority();testthat::expect_equal(m$posterior_mean,m$quadrature_mean,tolerance=1e-12);testthat::expect_equal(m$fixed_q_learning_risk,.339523464,tolerance=1e-12);testthat::expect_equal(m$credible_lower,.188989,tolerance=5e-7)
})
testthat::test_that("M12 regression, anchors, transport and verification preserve units", {
  r <- m12_regression();fit <- stats::lm(y~x,data=r$observations)
  testthat::expect_equal(unname(stats::coef(fit)),c(r$summary$intercept,r$summary$slope),tolerance=1e-10)
  pred <- stats::predict(fit,newdata=data.frame(x=0),interval="prediction")
  testthat::expect_equal(unname((pred[1,3]-pred[1,2])/2),r$summary$prediction_halfwidth,tolerance=1e-10)
  a <- m12_anchor();testthat::expect_equal(a$summary$credible_lower,36.4591681238,tolerance=1e-7);testthat::expect_equal(a$summary$credible_upper,41.5655232344,tolerance=1e-7)
  best <- a$allocation[which.min(a$allocation$posterior_expected_mse),];testthat::expect_equal(c(best$calibrators,best$repeats),c(14L,13L));testthat::expect_equal(best$posterior_expected_mse,.626713,tolerance=5e-7)
  t <- m12_transport();testthat::expect_equal(t$posterior_mean,.188642003158132,tolerance=1e-13);testthat::expect_equal(t$posterior_variance,.00346158334389109,tolerance=1e-13)
  v <- m12_verification();testthat::expect_equal(v$posterior_mean,c((15+31/2)/103,(15+31/10)/103),tolerance=1e-14)
  testthat::expect_gt(v$posterior_variance[1],v$posterior_variance[2]);testthat::expect_equal(v$identified_upper-v$identified_lower,c(.3,.3),tolerance=1e-14)
})
