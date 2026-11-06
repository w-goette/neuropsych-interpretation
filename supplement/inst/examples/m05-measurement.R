# Rebuild M05 from explicit synthetic inputs. Run from any working directory.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root,"renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library,.libPaths()))
source(file.path(supplement_root,"R/m05-measurement.R"))
output <- file.path(supplement_root,"outputs/m05-measurement")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
write_table <- function(value,name) readr::write_csv(value,file.path(output,paste0(name,".csv")))

# 1. Declare population spread, repeat noise and the finite-repeat covariance.
replication <- dplyr::bind_rows(m05_replication(),m05_replication(stable=9),
  m05_replication(common=9),m05_replication(common=-12))
write_table(replication,"replication")
# Equal one-score laws/reliabilities need not produce equal person posteriors.
write_table(m05_moment_counterexample(),"moment-counterexample")
write_table(m05_binary(),"binary")

# 2. Use a declared crossed/fixed-rater universe. Never interchange numerators.
write_table(dplyr::bind_rows(m05_gt(),m05_gt(J=8),m05_gt(K=4),m05_gt(fixed_raters=TRUE)),"gt-designs")
design <- m05_crossed_map()
write_table(tibble::tibble(effect=rownames(design$A),degrees_of_freedom=design$df,
  expected_mean_square=as.vector(design$A %*% c(64,9,4,16,9,4,36))),"gt-mean-squares")
write_table(m05_crossed_data(),"crossed-constructed-data")

# 3. Keep repeatability, intended-factor share and unidentified splits separate.
write_table(tibble::tibble(score=c("Single test","Two-test mean"),factor_variance=36,
  specificity_variance=c(28,14),transient_variance=c(36,18)) |>
  dplyr::mutate(observed_variance=factor_variance+specificity_variance+transient_variance,
    replication_reliability=(factor_variance+specificity_variance)/observed_variance,
    factor_share=factor_variance/observed_variance),"factor-shares")
write_table(tibble::tibble(g=c(4,8),s=c(5,1),a=c(1,3),e=c(3,1)) |>
  dplyr::mutate(variance=g+s+a+e,cross_occasion_covariance=g+s,
    current_target_variance=g+a,posterior_mean=current_target_variance*(-3)/variance,
    posterior_variance=current_target_variance*(1-current_target_variance/variance)),"state-equivalence")
write_table(m05_state_calibration(),"state-calibration")
write_table(tidyr::expand_grid(p=c(.25,.75),dependence=c(0,.1),pattern=c("11","00","10","01")) |>
  dplyr::mutate(probability=dplyr::case_when(pattern=="11"~p^2+dependence,
    pattern=="00"~(1-p)^2+dependence,TRUE~p*(1-p)-dependence),
    expected_sum=2*p,conditional_variance=2*p*(1-p)+2*dependence,
    replication_reliability=.25/(.25+conditional_variance)),"dependent-items")

# 4. Compute target intervals, then repeat the observation experiment at fixed tau.
write_table(m05_scalar(),"scalar-intervals")
write_table(m05_coverage(),"scalar-coverage")
write_table(dplyr::bind_rows(lapply(c(16,64,256),function(v){
  gain <- v/(v+36);tibble::tibble(prior_variance=v,posterior_mean=50+gain*(35-50),posterior_variance=gain*36)
})),"prior-sensitivity")
loading <- matrix(c(6,6),2,1); B <- loading %*% t(loading); specificity <- diag(28,2); transient <- diag(36,2)
posterior <- m05_gaussian(c(35,50),c(50,50),loading,specificity+transient,0,matrix(1))
stable <- B+specificity; observed <- stable+transient
mean_tau <- c(50,50)+as.vector(stable %*% solve(observed,c(-15,0)))
V_tau <- stable-stable %*% solve(observed,stable)
fresh_covariance <- loading %*% posterior$covariance %*% t(loading)+specificity+transient
same_covariance <- V_tau+transient
write_table(tibble::tibble(experiment=c("Same stable specificity","Fresh specificity"),
  mean1=c(mean_tau[1],50+6*posterior$mean),mean2=c(mean_tau[2],50+6*posterior$mean),
  variance1=c(same_covariance[1,1],fresh_covariance[1,1]),variance2=c(same_covariance[2,2],fresh_covariance[2,2]),
  covariance12=c(same_covariance[1,2],fresh_covariance[1,2]),factor_mean=posterior$mean,
  factor_variance=posterior$covariance[1,1]),"two-test-prediction")

# 5. Calibration is a separate experiment; no plug-in reliability shortcut.
write_table(m05_oneway(),"oneway-confidence")
write_table(dplyr::bind_rows(m05_oneway_posterior(501),m05_oneway_posterior(1001)),"oneway-posterior")
box <- m05_crossed_box()
write_table(box$component,"crossed-component-box")
write_table(dplyr::bind_rows(m05_box_design(box,sharpen_original=TRUE),m05_box_design(box,J=8),
  m05_box_design(box,K=4)),"crossed-design-confidence")
delta <- 1-sqrt(.95); person_box <- m05_crossed_box(alpha=delta)
upper_error <- m05_gt(person_box$component$upper)$absolute_error
half <- stats::qnorm(1-delta/2)*sqrt(upper_error)
write_table(tibble::tibble(observed_average=35,upper_absolute_error_variance=upper_error,
  lower=35-half,upper=35+half),"new-person-confidence")

# 6. Numerical posterior integration: compare coarse/fine quadrature, not a normal fit.
coarse <- lapply(c(3,8),function(a)m05_crossed_posterior(2^17,shape=a,person=FALSE))
fine <- lapply(c(3,8),function(a)m05_crossed_posterior(2^19,shape=a,person=TRUE))
write_table(dplyr::bind_rows(lapply(fine,`[[`,"coefficients")),"crossed-posterior")
write_table(dplyr::bind_rows(lapply(fine,`[[`,"ordering")),"design-ordering")
write_table(dplyr::bind_rows(lapply(fine,`[[`,"person")),"person-mixtures")
convergence <- dplyr::bind_rows(lapply(seq_along(fine),function(i){
  coarse_row <- coarse[[i]]$coefficients[1,];fine_row <- fine[[i]]$coefficients[1,]
  tibble::tibble(shape=c(3,8)[i],coarse_points=2^17,fine_points=2^19,
    relative_mean_change=fine_row$relative_mean-coarse_row$relative_mean,
    absolute_mean_change=fine_row$absolute_mean-coarse_row$absolute_mean,
    relative_ordering_change=fine[[i]]$ordering$relative_probability-coarse[[i]]$ordering$relative_probability,
    absolute_ordering_change=fine[[i]]$ordering$absolute_probability-coarse[[i]]$ordering$absolute_probability)
}))
write_table(convergence,"integration-convergence")
writeLines(c("All inputs synthetic and explicit; no patients or instrument norms.",
 "M05 supplies priors before constructing calibration data; prior means are not estimates learned from these outcomes.",
 "All scores are points and variances points squared. Population shares/probabilities are fractions, not percentages.",
 "Exact formulas/quantiles: replication,binary,GT,factor/state-equivalence,Gaussian,confidence tables.",
 "State posterior uses one-dimensional adaptive quadrature with rel.tol1e-10 and uniroot tol1e-10.",
 "One-way posterior log grids501/1001 per axis on a in[.001,2000],e in[5,200],with log-scale Jacobian. Truncation/discretization are numerical approximations, not exact equal-tail reproduction.",
 "Crossed posterior: deterministic shifted Halton7D,skip128,shift1,131072 coarse/524288 fine points for each IG shape3/8 with component means(64,9,4,16,9,4,36). Uniform inverse-gamma factors transform independent-prior integration coordinates; normalized likelihood weights integrate the posterior.",
 "Effective weight count diagnoses quadrature weight concentration; not independent posterior sample size,Monte Carlo standard error or rigorous error bound. Coarse/fine differences are empirical sensitivity diagnostics.",
 "Person mixtures use the actual weighted normal CDF and root finding(tol1e-7); observed new-case density reweights components. Fresh facet prediction adds conditional absolute error. Calibrated/new person are different observation designs.",
 "Data columns/dictionaries and mapping are in inst/examples/M05_GUIDE.md. The tables can be checked against the stated formulas and declared numerical tolerances.",
 "No random simulation/seed needed; no statistical or clinical validation implied."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote",length(list.files(output,pattern="[.]csv$")),"M05 tables to",output,"\n")
