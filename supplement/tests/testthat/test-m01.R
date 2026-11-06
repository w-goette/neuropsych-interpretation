testthat::test_that("known-law examples reproduce the chapter numbers and scale direction", {
  results <- m01_example_results()
  testthat::expect_equal(results$normal$standardized_score, -1.5)
  testthat::expect_equal(results$normal$lower_tail, .0668072, tolerance = 5e-8)
  testthat::expect_equal(results$normal$two_sided_event, .1336144, tolerance = 5e-8)
  at_one <- results$reference[results$reference$score == 1, ]
  testthat::expect_equal(unlist(at_one[c("strict_lower", "inclusive_lower", "strict_upper", "inclusive_upper", "midpoint")]),
                         c(strict_lower=.1, inclusive_lower=.3, strict_upper=.7, inclusive_upper=.9, midpoint=.2))
  testthat::expect_equal(results$coarsening$category_probability, c(.3,.7))
  # Increasing relabeling preserves every tail; coarsening does not recover raw-score masses.
  transformed <- m01_reference_table(10 + 2 * (0:3), c(.1,.2,.4,.3))
  testthat::expect_equal(transformed$inclusive_lower, results$reference$inclusive_lower)
})

testthat::test_that("flagging uses the inclusive rule even at intended decimal equalities", {
  p <- c(.1,.2,.4,.3)
  curves <- m01_flagging_curve(0:3,p,c(0,.05,.2,.3,1))
  at <- function(rule,u) curves$flagged_fraction[curves$convention==rule & curves$level==u]
  testthat::expect_equal(at("Midpoint",.05),.1)
  testthat::expect_equal(at("Inclusive",.05),0)
  testthat::expect_equal(at("Midpoint",.2),.3)
  testthat::expect_equal(at("Inclusive",.2),.1)
  testthat::expect_equal(at("Inclusive",.3),.3)
  # Below/above every jump by much more than the machine-equality guard.
  ref <- m01_reference_table(0:3,p)
  levels <- sort(unique(c(0,1,pmax(0,ref$inclusive_lower-1e-8),ref$inclusive_lower)))
  full <- m01_flagging_curve(0:3,p,levels)
  inclusive <- full[full$convention=="Inclusive",]
  testthat::expect_true(all(inclusive$flagged_fraction <= inclusive$level+2e-15))
  testthat::expect_equal(full$flagged_fraction[full$level==1],rep(1,3))
  # Verify count-event sums independently on a fine grid, without simulation.
  grid <- seq(0,1,by=.001)
  full <- m01_flagging_curve(0:3,p,grid)
  ranks <- list(Inclusive=c(.1,.3,.7,1),Midpoint=c(.05,.2,.5,.85),Strict=c(0,.1,.3,.7))
  for(rule in names(ranks)) {
    expected <- vapply(grid,function(u) sum(p[ranks[[rule]]<=u]),numeric(1))
    testthat::expect_equal(full$flagged_fraction[full$convention==rule],expected,tolerance=1e-14)
  }
})

testthat::test_that("fixed-event intervals match roots, boundaries and no-data semantics", {
  row <- m01_frequency(100,8)
  testthat::expect_lt(max(abs(c(row$confidence_lower,row$confidence_upper)-c(.0351716,.1515576))),5e-8)
  testthat::expect_lt(max(abs(c(row$credible_lower,row$credible_upper)-c(.0415595,.1501162))),5e-8)
  testthat::expect_equal(row$posterior_mean,9/102)
  zero <- m01_frequency(100,0)
  all <- m01_frequency(100,100)
  testthat::expect_equal(zero$confidence_upper,1-.025^(1/100))
  testthat::expect_equal(all$confidence_lower,.025^(1/100))
  testthat::expect_gt(zero$credible_lower,0)
  none <- m01_frequency(0,0,a=2,b=3)
  testthat::expect_true(is.na(none$empirical_frequency))
  testthat::expect_equal(c(none$confidence_lower,none$confidence_upper),c(0,1))
  testthat::expect_equal(none$posterior_mean,2/5)
  # Compare beta quantiles to finite-sum inversion, for all counts in small designs.
  for(n in c(1,2,5,20)) for(k in 0:n) {
    row <- m01_frequency(n,k)
    if(k>0) testthat::expect_equal(row$confidence_lower,
      stats::uniroot(function(q)sum(stats::dbinom(k:n,n,q))-.025,c(0,1),tol=1e-12)$root,tolerance=1e-10)
    if(k<n) testthat::expect_equal(row$confidence_upper,
      stats::uniroot(function(q)sum(stats::dbinom(0:k,n,q))-.025,c(0,1),tol=1e-12)$root,tolerance=1e-10)
  }
})

testthat::test_that("invalid inputs fail rather than silently changing the experiment", {
  testthat::expect_error(m01_reference_table(c(0,0),c(.5,.5)),"distinct")
  testthat::expect_error(m01_reference_table(0:1,c(-.1,1.1)),"nonnegative")
  testthat::expect_error(m01_reference_table(0:1,c(.4,.4)),"summing")
  testthat::expect_error(m01_reference_table(c(0,Inf),c(.5,.5)),"finite")
  testthat::expect_error(m01_flagging_curve(0:1,c(.5,.5),NA_real_),"levels")
  testthat::expect_error(m01_frequency(10,11),"integers")
  testthat::expect_error(m01_frequency(2.5,1),"integers")
  testthat::expect_error(m01_frequency(5,2,a=0),"prior")
  testthat::expect_error(m01_frequency(5,2,level=1),"level")
  testthat::expect_error(m01_frequency(5,2,a=1e308,b=1e308),"range")
  testthat::expect_error(m01_reference_table(matrix(0:1,ncol=1),c(.5,.5)),"distinct")
})


