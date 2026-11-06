# Rebuild the chapter's synthetic experiments, from any working directory.
argument<-grep("^--file=",commandArgs(FALSE),value=TRUE)
script<-sub("^--file=","",argument[[1]])
if(!file.exists(script)) script<-gsub("~+~"," ",script,fixed=TRUE)
supplement_root<-dirname(dirname(dirname(normalizePath(script,mustWork=TRUE))))
project_library<-file.path(supplement_root,"renv/library")
if(dir.exists(project_library)) .libPaths(c(project_library,.libPaths()))
source(file.path(supplement_root,"R/m06-items.R"))
output<-file.path(supplement_root,"outputs/m06-items")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
write_table<-function(x,name) readr::write_csv(x,file.path(output,paste0(name,".csv")))
# 1. Observe the pattern, then group by what the scoring rule retains.
write_table(m06_law(),"pattern-law")
write_table(m06_total(),"total-law")
write_table(m06_information(0),"information-at-zero")
H<-c(-1,0,1);prior<-c(.05,.9,.05);probability<-.01+.98*sin(pi*H/2)^2
write_table(dplyr::bind_rows(lapply(0:1,function(y) {
  weights<-prior*if(y==1) probability else 1-probability
  tibble::tibble(response=y,predictive_mass=sum(weights),posterior_mean=sum(H*weights)/sum(weights),posterior_variance=sum(H^2*weights)/sum(weights))
})),"pointwise-variance")
# 2. Dependence and the binary/underlying-scale bridge are separate experiments.
u<-m06_patterns(2);pm<-c(.25,.75)
probs<-vapply(1:4,function(i) mean(vapply(pm,function(p) prod(ifelse(u[i,]==1,p,1-p)),numeric(1))),numeric(1))
derivative<-vapply(1:4,function(i) mean(vapply(pm,function(p) prod(ifelse(u[i,]==1,p,1-p))*sum(u[i,]-p),numeric(1))),numeric(1))
write_table(tibble::tibble(pattern=apply(u,1,paste0,collapse=""),probability=probs,derivative=derivative,information_term=derivative^2/probs),"dependent-kernel")
K<-stats::integrate(function(t) stats::pnorm(t)^2*stats::dnorm(t),-Inf,Inf)$value-.25
rho<-4*stats::integrate(function(p) (stats::pnorm(p/sqrt(2))-.5)^2*stats::dnorm(p),-Inf,Inf)$value
write_table(tibble::tibble(fresh_task_mean=stats::pnorm(1/sqrt(2)),link_at_task_mean=stats::pnorm(1),shared_covariance=K,shared_difference_variance_times_J=.5-2*K,separate_difference_variance_times_J=.5,scored_reliability=rho,underlying_reliability=1/3),"binary-facet")
write_table(m06_law(.4,c(.7,1.2,2),c(-1,.3,1),"probit"),"probit-pattern-law")
# 3. Exact weighted reports can compress; rounded weights define another map.
weighted<-m06_law(0,c(1,1,2),c(0,.5,1))
write_table(weighted,"weighted-report")
write_table(tibble::tibble(experiment=c("Unweighted equal-item X","One-to-one X squared"),exact_information=c(.5,.5),moment_bound=c(.5,4/9)),"recoding")
# 4. Keep person-coordinate confidence, credibility and future responses separate.
posts<-list()
for(v in c(1,4)) for(pattern in c("00","01","10","11","total1")) {
  args<-list(prior_variance=v)
  if(pattern=="total1") args$total<-1 else args$u<-as.numeric(strsplit(pattern,"")[[1]])
  posts[[paste(pattern,v)]]<-do.call(m06_posterior,args)$summary
}
posteriors<-dplyr::bind_rows(posts);write_table(posteriors,"person-posteriors")
confidence<-dplyr::bind_rows(lapply(0:2,m06_confidence));write_table(confidence,"confidence-by-total")
patterns<-m06_patterns(2);ci<-posteriors |> dplyr::filter(prior_variance==1,observation!="total1")
coverage<-dplyr::bind_rows(lapply(c(0,1,2,4),function(h) {
  law<-m06_law(h);q<-m06_total(h)
  tibble::tibble(h=h,credible_coverage=sum(law$probability*(ci$lower<=h & h<=ci$upper)),confidence_coverage=sum(q$probability*(confidence$lower<=h & h<=confidence$upper)))
}));write_table(coverage,"fixed-coordinate-coverage")
pred<-m06_prediction();write_table(pred,"future-patterns")
mean<-sum(pred$total*pred$probability);variance<-sum((pred$total-mean)^2*pred$probability)
p<-m06_posterior();average_noise<-stats::integrate(function(h) (stats::plogis(h)*(1-stats::plogis(h))+stats::plogis(2*(h-1))*(1-stats::plogis(2*(h-1))))*p$density(h),-Inf,Inf)$value
marg<-as.vector(crossprod(pred$probability,patterns));cov<-sum(pred$probability*patterns[,1]*patterns[,2])-prod(marg)
write_table(tibble::tibble(mean=mean,variance=variance,expected_conditional_variance=average_noise,variance_of_expected_score=variance-average_noise,item1_probability=marg[1],item2_probability=marg[2],item_covariance=cov,plug_in_mean=sum(stats::plogis(c(1,2)*(p$summary$mean-c(0,1))))),"future-summary")
write_table(m06_conditional_prediction(),"conditional-future-pairs")
# 5. Floors/categories use the actual observed bin, not a point at its boundary.
write_table(m06_information(c(-6,-3,0,3,6),c(4,4),c(-3,3)),"separated-peaks")
write_table(m06_category(),"categories-at-zero")
write_table(m06_floor(),"floor-inference")
# 6. Anchor confidence intervals and a finite witness, not an optimized search.
alphaA<-.01;epsilon<-alphaA/3;QM<-5;QZ<-.54;n<-4
write_table(tibble::tibble(parameter=c("mu","t","s"),lower=c(-stats::qt(1-epsilon/2,3)*sqrt(QM/3)/2,QM/stats::qchisq(1-epsilon/2,3),QZ/stats::qchisq(1-epsilon/2,4)),upper=c(stats::qt(1-epsilon/2,3)*sqrt(QM/3)/2,QM/stats::qchisq(epsilon/2,3),QZ/stats::qchisq(epsilon/2,4))),"anchor-confidence")
weights<-c(-3,-1,1,3);u4<-m06_patterns(4);totals<-rowSums(u4);ranked<-as.vector(u4%*%weights)
write_table(tibble::tibble(statistic=c("T1","T2","S1","S2"),observed=c(3,1,3,3),lower_tail=c(mean(totals<=3),mean(totals<=1),mean(ranked<=3),mean(ranked<=3)),upper_tail=c(mean(totals>=3),mean(totals>=1),mean(ranked>=3),mean(ranked>=3))),"fair-column-tails")
TV<-.01*(10/3+4*sqrt(5/24))/4
bound<-2+stats::qlogis(sqrt(1-.02/2))/.5
write_table(tibble::tibble(calibration_event_error_bound=TV,calibration_tail_lower_bound=3/16-TV,case_tail_lower_bound=.745,restricted_confidence_lower=-bound,restricted_confidence_upper=bound),"confidence-witness-bounds")
# Full known-common-slope uncertain-difficulty experiment, finite exact sums.
joint<-array(0,c(2,2,4));difficulty<-rbind(c(0,0),c(-1,2))
for(i in 1:2) for(j in 1:2) joint[i,j,]<-.25*m06_law(c(-1,1)[i],c(1,1),difficulty[j,])$probability
write_table(tibble::tibble(observation=c("10","01","total1"),probability_H1=c(sum(joint[2,,3])/sum(joint[,,3]),sum(joint[2,,2])/sum(joint[,,2]),sum(joint[2,,2:3])/sum(joint[,,2:3]))),"uncertain-sufficiency")
# 7. Unknown calibration parameters: two deterministic shifts under each prior.
# The shift/refinement range is a diagnostic, not a guaranteed numerical error.
fits<-list()
for(scale in c(1,2)) for(shift in 1:2) {
  cat("Integrating noisy anchors: prior scale",scale,"shift",shift,"\n")
  fit<-m06_calibration(32768,shift,scale,32)
  fits[[paste(scale,shift)]]<-fit$summary
  if(shift==1) {
    write_table(fit$parameters,paste0("calibrated-parameters-scale",scale))
    write_table(fit$future,paste0("calibrated-future-scale",scale))
    write_table(fit$density,paste0("calibrated-density-scale",scale))
  }
}
write_table(dplyr::bind_rows(fits),"calibrated-person-refinements")
writeLines(c("All inputs synthetic. Known-item laws enumerate or recurse exactly before numerical arithmetic; posterior integrals use adaptive quadrature.",
 "Noisy anchors use32768 deterministic shifted-Halton points in7 nuisance dimensions,normal quadrature order32 and marginal-density grid step.025 on[-8,8]. Two shifts per prior;diagnostics are not error bounds or proof. Inspect refinement output and chapter for conditioning.",
 "Actual fixed-case and calibration equations/priors in M06;case likelihood updates nuisance weights. No hidden exact calibration abilities. No model fit to patients or diagnostic recommendation.",
 "Tail omission,quadrature,finite-grid and shifted-integration error differ. Finite-grid density mass is retained for inspection. Wider log-slope normal SD changes slope arithmetic means as well as dispersion."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("M06 tables written to",output,"\n")
