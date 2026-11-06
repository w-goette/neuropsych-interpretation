testthat::test_that("same profiles answer different declared questions", {
  x <- m03_example_results()
  testthat::expect_identical(names(x), c("linear", "quadratic", "conditional_count", "vector_prediction", "family_values", "conditional_prediction", "metric", "count_probabilities", "family_levels", "fitted_count_predictive", "content_outer"))
  testthat::expect_equal(nrow(x$linear), 8L)
  testthat::expect_equal(x$linear$lower_tail[x$linear$comparison=="marginal"], rep(stats::pnorm(-1.5),2))
  testthat::expect_lt(max(abs(x$linear$lower_tail[x$linear$comparison=="average"] - c(.2008678,.0467663))), 5e-8)
  testthat::expect_lt(max(abs(x$linear$two_sided_tail[x$linear$comparison=="discrepancy"] - c(.0935325,1))), 5e-8)
  testthat::expect_lt(max(abs(x$linear$lower_tail[x$linear$comparison=="conditional"] - c(.0303964,.2266274))), 5e-8)
  testthat::expect_equal(x$quadratic$distance, c(3.515625,2.8125))
  testthat::expect_equal(x$quadratic$conditioning_distance + x$quadratic$residual_distance, x$quadratic$distance)
  testthat::expect_lt(max(abs(x$quadratic$upper_tail - c(.1724216,.2450605))),5e-8)
  testthat::expect_lt(max(abs(x$vector_prediction$predictive_tail - c(.2320582,.3051451))),5e-8)
  testthat::expect_lt(max(abs(x$vector_prediction$proper_radial_tail - c(.1688098,.2360619))),5e-8)
  testthat::expect_equal(x$vector_prediction$denominator_df,c(18,18))
  testthat::expect_lt(max(abs(x$conditional_count$target_crossing_probability-c(.1056498,.4502618))),5e-8)
  testthat::expect_equal(x$conditional_count$known_conditioning_count,c(0L,1L))
  testthat::expect_equal(x$conditional_count$observed_full_count,c(1L,2L))
  testthat::expect_lt(max(abs(x$conditional_prediction$lower_tail-c(.045897,.254022))),5e-7)
  testthat::expect_lt(max(abs(x$conditional_prediction$radial_two_sided-c(.091794,.508045))),5e-7)
  testthat::expect_lt(max(abs(x$conditional_prediction$proper_lower_tail-c(.030954,.231931))),5e-7)
  testthat::expect_gt(x$conditional_prediction$leverage_multiplier[2],x$conditional_prediction$leverage_multiplier[1])
  testthat::expect_lt(max(abs(x$fitted_count_predictive$at_least_one-c(.269318,.236510))),5e-7)
  testthat::expect_lt(max(abs(x$fitted_count_predictive$both-c(.085440,.070167))),5e-7)
  testthat::expect_true(all(x$fitted_count_predictive$quadrature_error<1e-9))
  testthat::expect_true(all(x$content_outer$confidence_lower>=0 & x$content_outer$confidence_upper<=1))
  testthat::expect_lte(.008209,x$content_outer$confidence_lower[1])
  testthat::expect_lte(x$content_outer$confidence_upper[2],.665465)
  testthat::expect_lt(max(abs(x$metric$weighted_upper_tail-c(.299443,.113967))),5e-7)
  testthat::expect_gt(x$metric$diagonal_distance[2],x$metric$diagonal_distance[1])
  testthat::expect_lt(x$metric$original_distance[2],x$metric$original_distance[1])
})

testthat::test_that("independent integrals, exact reductions and inclusive counts agree", {
  for(rho in c(0,.2,.6,.9)) for(z in c(-2,-1,0,1)) {
    cdf <- m03_bvn(z,z,rho)$probability
    factor <- m03_bvn(z,z,rho,"factor")$probability
    testthat::expect_lt(abs(cdf-factor),1e-9)
  }
  for(z in c(-2,-1,0,1)) {
    testthat::expect_lt(abs(m03_bvn(z,z,0)$probability-stats::pnorm(z)^2),1e-10)
  }
  for(rho in c(-.5,0,.6)) {
    S <- matrix(c(100,100*rho,100*rho,100),2)
    counts <- m03_count2(c(40,40),c(50,50),S)
    testthat::expect_equal(sum(counts$mass),1,tolerance=1e-12)
    testthat::expect_true(all(counts$mass>=0))
    testthat::expect_equal(sum(counts$count*counts$mass),2*stats::pnorm(-1))
    testthat::expect_equal(counts$inclusive_tail[1],1)
    testthat::expect_equal(counts$inclusive_tail[3],counts$mass[3])
    level <- m03_family_level(.05,rho)
    testthat::expect_gt(level,.025)
    testthat::expect_lt(level,.05)
    testthat::expect_lt(abs(m03_family2(level,rho)-.05),1e-10)
    testthat::expect_lte(m03_family2(.025,rho),.05)
  }
  testthat::expect_equal(m03_family2(0),0)
  testthat::expect_equal(m03_family2(1),1)
  testthat::expect_lt(abs(m03_family_level(.05,0)-(1-sqrt(.95))),1e-10)
  # Conditional Student integral is checked against Gaussian scale mixing, an
  # independent representation, rather than an identical duplicate formula.
  for(df in c(18,24)) {
    z <- if(df==18) -1/sqrt(133/120) else -1/sqrt(11/12)
    original <- m03_student_count2(z,df)$both
    mixture <- stats::integrate(function(s) vapply(s,function(v) stats::dchisq(v,df)*m03_bvn(z*sqrt(v/df),z*sqrt(v/df),.6)$probability,numeric(1)),0,Inf,rel.tol=1e-8,subdivisions=500)$value
    testthat::expect_lt(abs(original-mixture),1e-8)
  }
})

testthat::test_that("units, rank domains and posterior scale remain explicit", {
  x <- m03_inputs();y<-x$profiles[1,];S<-x$covariance
  original<-m03_vector_predict(y,x$mean,S,20)
  D<-diag(c(2,.5));offset<-c(100,-30)
  transformed<-m03_vector_predict(as.numeric(offset+D%*%y),as.numeric(offset+D%*%x$mean),D%*%S%*%D,20)
  testthat::expect_equal(transformed,original)
  lower<-m03_linear(y,c(.5,.5),x$mean,S)
  transformed_linear<-m03_linear(as.numeric(D%*%y),as.numeric(solve(D,c(.5,.5))),as.numeric(D%*%x$mean),D%*%S%*%D)
  testthat::expect_equal(transformed_linear,lower)
  posterior<-m03_niw(x$mean,S,20,c(50,50),1,5,2*S)
  testthat::expect_equal(posterior$scale,11/12*S)
  testthat::expect_equal(posterior$df,24)
  testthat::expect_equal(posterior$df/(posterior$df-2)*posterior$scale,S)
  finite_boundary<-m03_vector_predict(y,x$mean,S,3)
  testthat::expect_equal(finite_boundary$denominator_df,1)
  testthat::expect_true(is.finite(finite_boundary$predictive_tail))
  singular<-matrix(1,2,2)
  proper_singular<-m03_niw(c(0,0),singular,2,c(0,0),1,4,diag(2))
  testthat::expect_true(min(eigen(proper_singular$scale,symmetric=TRUE)$values)>0)
  testthat::expect_error(m03_vector_predict(y,x$mean,S,2),'n > p')
  testthat::expect_error(m03_vector_predict(y,x$mean,singular,20),'positivity')
  testthat::expect_error(m03_linear(y,c(0,0),x$mean,S),'nonzero')
  testthat::expect_error(m03_conditional(y,x$mean,S,1,1),'partition')
  testthat::expect_error(m03_bvn(-1,-1,-.5,'factor'),'rho >= 0')
  testthat::expect_error(m03_bvn(-1,-1,1),'-1 < rho < 1')
  testthat::expect_error(m03_family_level(0),'alpha')
  testthat::expect_error(m03_family2(1.1),'t in')
  testthat::expect_error(m03_student_count2(-1,0),'Invalid')
  testthat::expect_error(m03_content_outer(2,2),'n > p')
  testthat::expect_error(m03_content_outer(20,2,k=3),'integer')
  testthat::expect_error(m03_niw(x$mean,S,20,x$mean,0,5,S),'Invalid')
  testthat::expect_error(m03_weighted_tail(-1),'nonnegative')
  testthat::expect_equal(m03_weighted_tail(0)$probability,1)
  testthat::expect_lt(abs(m03_weighted_tail(stats::qchisq(.95,2))$probability-.063675),5e-7)
})
