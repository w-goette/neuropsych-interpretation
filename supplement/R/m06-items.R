# Synthetic fixed-battery calculations for M06. Source this file; no package install.
# All normal distributions below use variances as inputs, SDs in dnorm/pnorm calls.
m06_items <- function(a, b) {
  if (!is.numeric(a) || !length(a) || any(!is.finite(a)) || any(a <= 0) ||
      !is.numeric(b) || length(a) != length(b) || any(!is.finite(b)))
    stop("Supply equally long finite slopes/difficulties and strictly positive slopes.")
  invisible(TRUE)
}
m06_patterns <- function(m) {
  if (length(m)!=1 || !is.finite(m) || m<1 || m>16 || m!=as.integer(m))
    stop("Enumeration requires an integer item count from 1 to 16.")
  vapply(rev(seq_len(m))-1L, function(k) (0:(2^m-1L) %/% 2^k) %% 2, numeric(2^m))
}
m06_kernel <- function(h, u, a=c(1,2), b=c(0,1)) {
  m06_items(a,b)
  if (length(u)!=length(a) || any(!u %in% c(0,1))) stop("Response must be a complete binary pattern.")
  vapply(h,function(z) exp(sum(ifelse(u==1,
    stats::plogis(a*(z-b),log.p=TRUE),stats::plogis(a*(z-b),lower.tail=FALSE,log.p=TRUE)))),numeric(1))
}
m06_law <- function(h=0,a=c(1,2),b=c(0,1),link=c("logistic","probit")) {
  m06_items(a,b);link<-match.arg(link)
  if(length(h)!=1 || !is.finite(h)) stop("Use one finite coordinate.")
  u<-m06_patterns(length(a));z<-a*(h-b)
  p<-if(link=="logistic") stats::plogis(z) else stats::pnorm(z)
  dp<-if(link=="logistic") a*p*(1-p) else a*stats::dnorm(z)
  if(any(p==0|p==1)) stop("Numerical saturation: use a less extreme coordinate or log-tail arithmetic.")
  prob<-apply(u,1,function(v) prod(ifelse(v==1,p,1-p)))
  score<-as.vector(sweep(u,2,p,"-") %*% (dp/(p*(1-p))))
  tibble::tibble(pattern=apply(u,1,paste0,collapse=""),total=rowSums(u),
    weighted=as.vector(u %*% a),probability=prob,derivative=prob*score,score=score)
}
m06_total <- function(h=0,a=c(1,2),b=c(0,1),link=c("logistic","probit")) {
  m06_items(a,b);link<-match.arg(link)
  if(length(h)!=1 || !is.finite(h)) stop("Use one finite coordinate.")
  p<-if(link=="logistic") stats::plogis(a*(h-b)) else stats::pnorm(a*(h-b))
  dp<-if(link=="logistic") a*p*(1-p) else a*stats::dnorm(a*(h-b))
  q<-1;dq<-0
  for(j in seq_along(a)) {
    old<-q;od<-dq
    q<-(1-p[j])*c(old,0)+p[j]*c(0,old)
    dq<-(1-p[j])*c(od,0)+p[j]*c(0,od)+dp[j]*(c(0,old)-c(old,0))
  }
  tibble::tibble(total=0:length(a),probability=q,derivative=dq)
}
m06_information <- function(h=seq(-5,6,.01),a=c(1,2),b=c(0,1),link="logistic") {
  dplyr::bind_rows(lapply(h,function(z) {
    law<-m06_law(z,a,b,link);q<-m06_total(z,a,b,link)
    mean<-sum(q$total*q$probability);v<-sum((q$total-mean)^2*q$probability)
    if(v<=0 || any(q$probability<=0)) stop("Numerical saturation in information calculation.")
    full<-sum(law$probability*law$score^2);total<-sum(q$derivative^2/q$probability)
    bound<-sum(q$total*q$derivative)^2/v
    tibble::tibble(h=z,pattern_information=full,total_information=total,moment_bound=bound,
      total_share=total/full,moment_share=bound/full)
  }))
}
m06_bracket_root <- function(fun) {
  width<-1
  while(sign(fun(-width))==sign(fun(width)) && width<2^20) width<-width*2
  stats::uniroot(fun,c(-width,width),tol=1e-10)$root
}
m06_confidence <- function(x=1,a=c(1,2),b=c(0,1),alpha=.05) {
  m06_items(a,b);m<-length(a)
  if(length(x)!=1 || !x %in% 0:m || length(alpha)!=1 || !is.finite(alpha) || alpha<=0 || alpha>=1)
    stop("Use an attainable integer total and an error rate in (0,1).")
  lo<-if(x==0) -Inf else m06_bracket_root(function(h) sum(m06_total(h,a,b)$probability[(x+1):(m+1)])-alpha/2)
  hi<-if(x==m) Inf else m06_bracket_root(function(h) sum(m06_total(h,a,b)$probability[1:(x+1)])-alpha/2)
  tibble::tibble(total=x,lower=lo,upper=hi,alpha=alpha)
}
m06_posterior <- function(u=c(1,0),a=c(1,2),b=c(0,1),prior_mean=0,prior_variance=1,total=NULL) {
  m06_items(a,b)
  if(length(prior_variance)!=1 || !is.finite(prior_variance) || prior_variance<=0 ||
      length(prior_mean)!=1 || !is.finite(prior_mean)) stop("Use a finite normal prior mean and positive variance.")
  if(!is.null(total) && (length(total)!=1 || !total %in% 0:length(a))) stop("Invalid total.")
  patterns<-m06_patterns(length(a));selected<-if(is.null(total)) NULL else which(rowSums(patterns)==total)
  likelihood<-if(is.null(total)) function(h) m06_kernel(h,u,a,b) else function(h)
    vapply(h,function(z) sum(vapply(selected,function(i) m06_kernel(z,patterns[i,],a,b),numeric(1))),numeric(1))
  raw<-function(h) likelihood(h)*stats::dnorm(h,prior_mean,sqrt(prior_variance))
  integral<-function(f,upper=Inf) stats::integrate(f,-Inf,upper,rel.tol=1e-10,abs.tol=1e-12,subdivisions=500)$value
  Z<-integral(raw);mean<-integral(function(h) h*raw(h))/Z
  variance<-integral(function(h) (h-mean)^2*raw(h))/Z
  cdf<-function(x) integral(raw,x)/Z
  limits<-prior_mean+c(-12,12)*sqrt(prior_variance)
  ci<-vapply(c(.025,.975),function(p) stats::uniroot(function(x) cdf(x)-p,limits,tol=1e-9)$root,numeric(1))
  map<-if(is.null(total)) stats::uniroot(function(h) sum(a*(u-stats::plogis(a*(h-b))))-(h-prior_mean)/prior_variance,limits,tol=1e-10)$root else NA_real_
  mle<-if(is.null(total)) {if(all(u==0)) -Inf else if(all(u==1)) Inf else m06_bracket_root(function(h) sum(a*(u-stats::plogis(a*(h-b)))))} else NA_real_
  summary<-tibble::tibble(observation=if(is.null(total)) paste0(u,collapse="") else paste0("total",total),prior_mean=prior_mean,prior_variance=prior_variance,
    normalizer=Z,mean=mean,variance=variance,lower=ci[1],upper=ci[2],MAP=map,MLE=mle)
  list(summary=summary,density=function(h) raw(h)/Z,cdf=cdf,
    tail_bound_outside_12_prior_SD=2*stats::pnorm(-12)/Z)
}
m06_prediction <- function(u=c(1,0),prior_variance=1) {
  post<-m06_posterior(u,prior_variance=prior_variance);patterns<-m06_patterns(2)
  prob<-vapply(1:4,function(i) stats::integrate(function(h) m06_kernel(h,patterns[i,])*post$density(h),-Inf,Inf,rel.tol=1e-10)$value,numeric(1))
  tibble::tibble(pattern=apply(patterns,1,paste0,collapse=""),total=rowSums(patterns),probability=prob)
}
m06_conditional_prediction <- function(alpha=.05) {
  if(!is.finite(alpha) || length(alpha)!=1 || alpha<=0 || alpha>=1) stop("Invalid error rate.")
  u<-m06_patterns(2);ta<-as.vector(u%*%c(1,2));constant<-exp(-as.vector(u%*%c(0,2)))
  pairs<-tidyr::expand_grid(first=1:4,future=1:4) |>
    dplyr::mutate(pooled=ta[first]+ta[future],difference=abs(ta[first]-ta[future]),weight=constant[first]*constant[future])
  pairs$inclusive_tail<-vapply(seq_len(nrow(pairs)),function(i) {
    ok<-pairs$pooled==pairs$pooled[i]
    sum(pairs$weight[ok & pairs$difference>=pairs$difference[i]])/sum(pairs$weight[ok])
  },numeric(1))
  pairs |> dplyr::mutate(included=inclusive_tail>=alpha,alpha=alpha)
}
m06_category <- function(h=0,cuts=c(-Inf,-1,1,Inf),sigma=1) {
  if(length(h)!=1 || !is.finite(h) || length(sigma)!=1 || !is.finite(sigma) || sigma<=0 ||
      length(cuts)<3 || cuts[1]!=-Inf || tail(cuts,1)!=Inf || any(diff(cuts)<=0)) stop("Invalid normal category experiment.")
  z<-(cuts-h)/sigma;q<-diff(stats::pnorm(z));dq<-(head(stats::dnorm(z),-1)-tail(stats::dnorm(z),-1))/sigma
  if(any(q<=0)) stop("Numerical saturation in bin probabilities.")
  tibble::tibble(category=0:(length(cuts)-2),probability=q,derivative=dq,information_term=dq^2/q)
}
m06_floor <- function() {
  raw<-function(h) stats::pnorm(-1-h)*stats::dnorm(h)
  int<-function(f,x=Inf) stats::integrate(f,-Inf,x,rel.tol=1e-10)$value
  Z<-int(raw);mean<-int(function(h) h*raw(h))/Z;v<-int(function(h) (h-mean)^2*raw(h))/Z
  q<-vapply(c(.025,.975),function(p) stats::uniroot(function(x) int(raw,x)/Z-p,c(-8,8),tol=1e-10)$root,numeric(1))
  tibble::tibble(mean=mean,variance=v,lower=q[1],upper=q[2],confidence_lower=-Inf,confidence_upper=-1+stats::qnorm(.975),imputed_cut_mean=-.5,imputed_cut_variance=.5)
}
# Golub-Welsch standard-normal quadrature: nodes, weights, sum(weights)=1.
m06_normal_quadrature <- function(order=32) {
  if(length(order)!=1 || !is.finite(order) || order<2 || order!=as.integer(order)) stop("Invalid quadrature order.")
  J<-matrix(0,order,order);J[cbind(1:(order-1),2:order)]<-sqrt(1:(order-1));J<-J+t(J)
  e<-eigen(J,symmetric=TRUE);list(nodes=e$values,weights=e$vectors[1,]^2)
}
m06_halton <- function(points=32768,shift=1) {
  if(length(points)!=1 || !is.finite(points) || points<16 || points!=as.integer(points) ||
      length(shift)!=1 || !is.finite(shift)) stop("Invalid shifted integration design.")
  primes<-c(2,3,5,7,11,13,17)
  vapply(seq_along(primes),function(j) {
    index<-seq_len(points)+128;value<-numeric(points);factor<-1/primes[j]
    while(any(index>0)) {value<-value+(index%%primes[j])*factor;index<-floor(index/primes[j]);factor<-factor/primes[j]}
    pmin(1-1e-12,pmax(1e-12,(value+(sqrt(primes[j])*shift)%%1)%%1))
  },numeric(points))
}
# Numerical evaluation of the explicitly stated noisy-anchor posterior, not a fit
# by substituting anchor averages as exact abilities. Deterministic shifted Halton
# plus normal quadrature; refinement differences are diagnostics, not error bounds.
m06_calibration <- function(points=32768,shift=1,prior_scale=1,order=32,grid_step=.025) {
  if(length(prior_scale)!=1 || !is.finite(prior_scale) || prior_scale<=0 ||
      !is.finite(grid_step) || grid_step<=0 || grid_step>.1) stop("Invalid prior scale or CDF grid step.")
  u<-m06_halton(points,shift);gh<-m06_normal_quadrature(order)
  t<-5.5/stats::qgamma(u[,1],5);s<-1.27/stats::qgamma(u[,2],5);mu<-sqrt(t/5)*stats::qnorm(u[,3]);v<-t-s/2
  keep<-v>0;t<-t[keep];s<-s[keep];mu<-mu[keep];v<-v[keep];u<-u[keep,,drop=FALSE]
  a1<-exp(.35*prior_scale*stats::qnorm(u[,4]));a2<-exp(log(1.5)+.35*prior_scale*stats::qnorm(u[,5]));b1<--.5+.75*prior_scale*stats::qnorm(u[,6]);b2<-.5+.75*prior_scale*stats::qnorm(u[,7])
  likelihood<-function(h,response) {
    first<-if(response[1]==1) stats::plogis(a1*(h-b1),log.p=TRUE) else stats::plogis(a1*(h-b1),lower.tail=FALSE,log.p=TRUE)
    second<-if(response[2]==1) stats::plogis(a2*(h-b2),log.p=TRUE) else stats::plogis(a2*(h-b2),lower.tail=FALSE,log.p=TRUE)
    exp(first+second)
  }
  M<-c(-1.5,-.5,.5,1.5);U<-rbind(c(0,0),c(1,0),c(1,0),c(1,1));cal<-rep(1,length(v))
  for(i in 1:4) {
    loc<-mu+(v/t)*(M[i]-mu);sd<-sqrt(v*s/(2*t));value<-numeric(length(v))
    for(k in seq_along(gh$nodes)) value<-value+gh$weights[k]*likelihood(loc+sd*gh$nodes[k],U[i,])
    cal<-cal*value
  }
  lc<-moment<-second<-numeric(length(v));future<-matrix(0,length(v),4);patterns<-m06_patterns(2)
  for(k in seq_along(gh$nodes)) {
    h<-mu+sqrt(v)*gh$nodes[k];w<-gh$weights[k]*likelihood(h,c(1,0))
    lc<-lc+w;moment<-moment+w*h;second<-second+w*h*h
    for(i in 1:4) future[,i]<-future[,i]+w*likelihood(h,patterns[i,])
  }
  weights<-cal*lc;den<-sum(weights);tw<-weights/den;cm<-moment/lc;cv<-pmax(0,second/lc-cm^2)
  mean<-sum(cal*moment)/den;within<-sum(tw*cv);between<-sum(tw*(cm-mean)^2)
  # Direct marginal density quadrature, independent of normal-posterior assumptions.
  grid<-seq(-8,8,by=grid_step)
  density<-vapply(grid,function(h) sum(cal*likelihood(rep(h,length(v)),c(1,0))*stats::dnorm(h,mu,sqrt(v)))/den,numeric(1))
  cumulative<-c(0,cumsum((head(density,-1)+tail(density,-1))*diff(grid)/2))
  ci<-stats::approx(cumulative,grid,xout=c(.025,.975),ties="ordered")$y
  summary<-tibble::tibble(points=points,shift=shift,prior_scale=prior_scale,quadrature_order=order,grid_step=grid_step,
    mean=mean,variance=within+between,within=within,between=between,lower=ci[1],upper=ci[2],density_mass_in_grid=tail(cumulative,1),
    calibration_only_mean=sum(cal*cm)/sum(cal),weight_ESS=den^2/sum(weights^2))
  values<-list(mu=mu,v=v,anchor_error=s,a1=a1,a2=a2,b1=b1,b2=b2)
  parameters<-dplyr::bind_rows(lapply(names(values),function(name) {z<-values[[name]];m<-sum(tw*z);tibble::tibble(parameter=name,mean=m,SD=sqrt(sum(tw*(z-m)^2)))}))
  list(summary=summary,parameters=parameters,future=tibble::tibble(pattern=apply(patterns,1,paste0,collapse=""),probability=as.vector(crossprod(cal,future))/den),density=tibble::tibble(h=grid,density=density))
}
