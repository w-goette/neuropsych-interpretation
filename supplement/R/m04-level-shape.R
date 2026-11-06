# M04 synthetic experiments. Inputs are declared observed-score populations,
# paired summaries, priors or training summaries, never patient norms.
m04_check_matrix <- function(x, p) {
  if (!is.matrix(x) || !all(dim(x) == c(p,p)) || any(!is.finite(x)) ||
      !isTRUE(all.equal(x,t(x), tolerance=1e-12))) stop("Supply a finite symmetric covariance matrix.", call.=FALSE)
  if (min(eigen(x,symmetric=TRUE,only.values=TRUE)$values)<=0) stop("Covariance must be positive definite.",call.=FALSE)
  invisible(x)
}
m04_check_vector <- function(x,p) {
  if (!is.numeric(x)||length(x)!=p||any(!is.finite(x))) stop("Supply a matching finite numeric vector.",call.=FALSE)
  invisible(x)
}
m04_geometry <- function(x, covariance, direction=rep(1,length(x))) {
  p <- length(x); m04_check_matrix(covariance,p);m04_check_vector(x,p);m04_check_vector(direction,p)
  if(p<2||all(direction==0)) stop("Use at least two coordinates and a nonzero fixed direction.",call.=FALSE)
  precision_direction <- solve(covariance,direction)
  information <- sum(direction*precision_direction)
  coefficient <- sum(precision_direction*x)/information
  level <- sqrt(information)*coefficient
  residual <- x-direction*coefficient
  shape <- as.numeric(crossprod(residual,solve(covariance,residual)))
  tibble::tibble(coefficient=coefficient,level=level,shape=shape,
    total=as.numeric(crossprod(x,solve(covariance,x))),level_lower_tail=stats::pnorm(level),
    shape_upper_tail=stats::pchisq(shape,p-1,lower.tail=FALSE),
    radial_upper_tail=stats::pchisq(level^2+shape,p,lower.tail=FALSE))
}
m04_quadratic_moments <- function(mean,covariance,A) {
  p <- length(mean);m04_check_vector(mean,p);m04_check_matrix(covariance,p)
  if(!is.matrix(A)||!all(dim(A)==c(p,p))||any(!is.finite(A))||!isTRUE(all.equal(A,t(A)))) stop("A must be finite symmetric with matching dimensions.",call.=FALSE)
  expectation <- sum(diag(A%*%covariance))+as.numeric(crossprod(mean,A%*%mean))
  variance <- 2*sum(diag(A%*%covariance%*%A%*%covariance))+4*as.numeric(crossprod(mean,A%*%covariance%*%A%*%mean))
  tibble::tibble(expectation=expectation,variance=variance)
}
m04_quadratic_correlation <- function(mean1,mean2,R1,R2,K,A) {
  p <- length(mean1);m04_check_vector(mean2,p);m04_check_matrix(rbind(cbind(R1,K),cbind(t(K),R2)),2*p)
  v1 <- m04_quadratic_moments(mean1,R1,A)$variance;v2 <- m04_quadratic_moments(mean2,R2,A)$variance
  if(v1<=0||v2<=0) stop("Both quadratic variances must be positive.",call.=FALSE)
  cross <- 2*sum(diag(A%*%K%*%A%*%t(K)))+4*as.numeric(crossprod(mean1,A%*%K%*%A%*%mean2))
  cross/sqrt(v1*v2)
}
m04_sd_correlation <- function(rho) {
  if(!is.numeric(rho)||any(!is.finite(rho))||any(abs(rho)>1)) stop("Correlation must lie in [-1,1].",call.=FALSE)
  (2/pi)*(sqrt(pmax(0,1-rho^2))+rho*asin(rho)-1)/(1-2/pi)
}
m04_shape_confidence <- function(q,df=1,alpha=.05) {
  if(length(q)!=1||!is.finite(q)||q<0||length(df)!=1||!is.finite(df)||df<1||alpha<=0||alpha>=1) stop("Use nonnegative q, df>=1 and 0<alpha<1.",call.=FALSE)
  central <- stats::pchisq(q,df)
  if(central<alpha/2) return(tibble::tibble(lower=NA_real_,upper=NA_real_,empty=TRUE))
  root <- function(probability) {
    endpoint <- 1
    while(stats::pchisq(q,df,ncp=endpoint)>probability) endpoint <- 2*endpoint
    stats::uniroot(function(lambda) stats::pchisq(q,df,ncp=lambda)-probability,c(0,endpoint),tol=1e-11)$root
  }
  tibble::tibble(lower=if(central<=1-alpha/2) 0 else root(1-alpha/2),upper=root(alpha/2),empty=FALSE)
}
# Exact angular kernel; integration variable t is a nuisance scale angle.
m04_correlation_kernel <- function(r,a,c) {
  vapply(r,function(value) (1-value^2)^((a-3)/2)*stats::integrate(
    function(t) sin(2*t)^(a-1)/(1-c*value*sin(2*t))^a,0,pi/2,
    rel.tol=1e-9,abs.tol=1e-11,subdivisions=300)$value,numeric(1))
}
m04_correlation_cdf <- function(x,a,c) {
  if(length(a)!=1||!is.finite(a)||a<=1||length(c)!=1||!is.finite(c)||abs(c)>=1||length(x)!=1||!is.finite(x)||abs(x)>1) stop("Use a>1, |c|<1 and x in [-1,1].",call.=FALSE)
  # r=sin(t) removes the integrable endpoint singularity for 1<a<3.
  density_angle <- function(t) m04_correlation_kernel(sin(t),a,c)*cos(t)
  total <- stats::integrate(density_angle,-pi/2,pi/2,rel.tol=1e-8,abs.tol=1e-10,subdivisions=400)$value
  if(x==-1) return(0);if(x==1) return(1)
  stats::integrate(density_angle,-pi/2,asin(x),rel.tol=1e-8,abs.tol=1e-10,subdivisions=400)$value/total
}
m04_paired_summary <- function(N=12,scatter=matrix(c(12,9,9,12),2),nu0=4,prior_scale=diag(2,2),intervals=TRUE) {
  if(length(N)!=1||N<2||N!=as.integer(N)||!is.finite(N)||nu0<=1) stop("Use integer N>=2 and nu0>1; zero contrast means must be known.",call.=FALSE)
  m04_check_matrix(scatter,2);m04_check_matrix(prior_scale,2)
  raw_correlation <- scatter[1,2]/sqrt(scatter[1,1]*scatter[2,2]);nu <- nu0+N;scale <- prior_scale+scatter
  c <- scale[1,2]/sqrt(scale[1,1]*scale[2,2])
  z <- stats::integrate(function(r) m04_correlation_kernel(r,nu,c),-1,1,rel.tol=1e-9)$value
  moment <- function(fun) stats::integrate(function(r) fun(r)*m04_correlation_kernel(r,nu,c)/z,-1,1,rel.tol=1e-8)$value
  result <- tibble::tibble(contrast_correlation=raw_correlation,plugin_square_correlation=raw_correlation^2,
    plugin_sd_correlation=m04_sd_correlation(raw_correlation),posterior_square_mean=moment(function(r) r^2),
    posterior_sd_mean=moment(m04_sd_correlation),nu_posterior=nu,scale_correlation=c)
  if(intervals) {
    lower <- stats::uniroot(function(rho) m04_correlation_cdf(raw_correlation,N,rho)-.975,c(-.99,.99),tol=1e-9)$root
    upper <- stats::uniroot(function(rho) m04_correlation_cdf(raw_correlation,N,rho)-.025,c(-.99,.99),tol=1e-9)$root
    quantile <- function(p) stats::uniroot(function(q) m04_correlation_cdf(sqrt(q),nu,c)-m04_correlation_cdf(-sqrt(q),nu,c)-p,c(1e-10,1-1e-10),tol=1e-9)$root
    q <- vapply(c(.025,.5,.975),quantile,numeric(1))
    result <- dplyr::mutate(result,rho_confidence_lower=lower,rho_confidence_upper=upper,
      square_confidence_lower=if(lower<=0&&upper>=0) 0 else min(lower^2,upper^2),square_confidence_upper=max(lower^2,upper^2),
      square_credible_lower=q[1],square_posterior_median=q[2],square_credible_upper=q[3],
      sd_credible_lower=m04_sd_correlation(sqrt(q[1])),sd_credible_upper=m04_sd_correlation(sqrt(q[3])))
  }
  result
}
m04_power <- function(delta,covariance=matrix(c(1,.6,.6,1),2),n=Inf,alpha=.05) {
  p <- length(delta);m04_check_vector(delta,p);m04_check_matrix(covariance,p)
  if(p!=2||alpha<=0||alpha>=1||length(n)!=1||((is.infinite(n)&&n<0)||(!is.infinite(n)&&(!is.finite(n)||n<=2||n!=as.integer(n))))) stop("This worked helper uses p=2, n>2 (or Inf) and 0<alpha<1.",call.=FALSE)
  g <- m04_geometry(delta,covariance);radius <- g$total;shape <- g$shape
  if(is.infinite(n)) return(tibble::tibble(flat_level=stats::pnorm(stats::qnorm(alpha)-g$level),shape=stats::pchisq(stats::qchisq(1-alpha,1),1,ncp=shape,lower.tail=FALSE),full_radius=stats::pchisq(stats::qchisq(1-alpha,2),2,ncp=radius,lower.tail=FALSE),optimal_discriminant=stats::pnorm(sqrt(radius)-stats::qnorm(1-alpha))))
  h <- 1+1/n
  tibble::tibble(flat_level=stats::pt(stats::qt(alpha,n-1),n-1,ncp=g$level/sqrt(h)),
    shape=stats::pf(stats::qf(1-alpha,1,n-1),1,n-1,ncp=shape/h,lower.tail=FALSE),
    full_radius=stats::pf(stats::qf(1-alpha,2,n-2),2,n-2,ncp=radius/h,lower.tail=FALSE),optimal_discriminant=NA_real_)
}
m04_training_average <- function(dstar=1.25,n0=5,n1=5) {
  if(length(dstar)!=1||!is.finite(dstar)||dstar<=0||any(!is.finite(c(n0,n1)))||any(c(n0,n1)<2)||any(c(n0,n1)!=as.integer(c(n0,n1)))) stop("Use positive dstar and integer group sizes >=2 for this two-dimensional helper.",call.=FALSE)
  c <- 1/n0+1/n1;m <- n0+n1-2
  if(dstar/sqrt(c)>8) stop("Angular teaching quadrature requires dstar/sqrt(c)<=8; use a stabilized algorithm for more extreme effects.",call.=FALSE)
  angle_density <- function(t) {b <- dstar*cos(t)/sqrt(c);exp(-dstar^2/(2*c))/(2*pi)*(1+b*sqrt(2*pi)*exp(b^2/2)*stats::pnorm(b))}
  psi_density <- function(u) exp(lgamma((m+1)/2)-.5*log(pi)-lgamma(m/2))*cos(u)^(m-1)
  known <- stats::integrate(function(t) stats::pnorm(dstar*cos(t)/sqrt(2))*angle_density(t),0,2*pi,rel.tol=1e-10)$value
  unknown <- stats::integrate(function(t) vapply(t,function(angle) stats::integrate(function(u) stats::pnorm(dstar*cos(angle+u)/sqrt(2))*psi_density(u),-pi/2,pi/2,rel.tol=1e-10)$value,numeric(1))*angle_density(t),0,2*pi,rel.tol=1e-9)$value
  tibble::tibble(oracle_auc=stats::pnorm(dstar/sqrt(2)),known_covariance_training_average=known,
    estimated_covariance_training_average=unknown,reversed_known_direction_probability=stats::pnorm(-dstar/sqrt(c)),
    angle_density_integral=stats::integrate(angle_density,0,2*pi)$value,scatter_angle_density_integral=stats::integrate(psi_density,-pi/2,pi/2)$value)
}
m04_training_posterior <- function() {
  # Separate realized sample, exactly as stated in sec-m04-trained-posterior.
  n <- 5;kappa <- .5+n;nu <- 4+2*n;p <- 2;m <- 2*n-2
  mean0 <- c(0,0);mean1 <- n*c(1.25,0)/kappa
  scale <- diag(2)+m*diag(2)+(.5*n/kappa)*tcrossprod(c(1.25,0));w <- c(1.25,0)
  a <- sum(w*(mean1-mean0));cc <- 2/kappa;q <- as.numeric(crossprod(w,scale%*%w));df <- nu-p+1
  cdf <- function(u) stats::integrate(function(s) stats::pnorm((stats::qnorm(u)-a*sqrt(s/(2*q)))/sqrt(cc/2))*stats::dchisq(s,df),0,Inf,rel.tol=1e-9,abs.tol=1e-11)$value
  quantiles <- vapply(c(.025,.5,.975),function(prob) stats::uniroot(function(u) cdf(u)-prob,c(1e-8,1-1e-8),tol=1e-10)$root,numeric(1))
  log_density <- function(x,center,sc) {d <- x-center;lgamma((df+p)/2)-lgamma(df/2)-p/2*log(df*pi)-.5*as.numeric(determinant(sc,logarithm=TRUE)$modulus)-(df+p)/2*log1p(as.numeric(crossprod(d,solve(sc,d)))/df)}
  sc <- (1+1/kappa)*scale/df;x <- c(1.25,0);logodds <- log(.2/.8)+log_density(x,mean1,sc)-log_density(x,mean0,sc)
  tibble::tibble(nu_posterior=nu,mean1_first=mean1[1],scale_first=scale[1,1],scale_second=scale[2,2],
    auc_posterior_mean=stats::pt(a/sqrt((2+cc)*q/df),df),auc_credible_lower=quantiles[1],auc_posterior_median=quantiles[2],auc_credible_upper=quantiles[3],
    class1_probability=stats::plogis(logodds),external_prevalence=.2)
}
m04_example_results <- function() {
  R <- matrix(c(1,.6,.6,1),2);raw <- rbind(A=c(35,50),B=c(35,35));alternatives <- rbind(global=c(-1,-1),focal=c(-1,0),opposing=c(-1,1))
  profiles <- dplyr::bind_rows(lapply(1:2,function(i) dplyr::bind_cols(tibble::tibble(profile=rownames(raw)[i],score1=raw[i,1],score2=raw[i,2]),m04_geometry((raw[i,]-50)/10,R))))
  shifts <- dplyr::bind_rows(lapply(1:3,function(i) {g <- m04_geometry(alternatives[i,],R);tibble::tibble(shift=rownames(alternatives)[i],delta1=alternatives[i,1],delta2=alternatives[i,2],level_squared=g$level^2,shape_noncentrality=g$shape,total_noncentrality=g$total,flat_retained_fraction=g$level^2/g$total)}))
  powers <- dplyr::bind_rows(lapply(c(Inf,20),function(n) dplyr::bind_rows(lapply(1:3,function(i) dplyr::bind_cols(tibble::tibble(experiment=if(is.infinite(n)) 'known law' else 'finite norms n=20',shift=rownames(alternatives)[i]),m04_power(alternatives[i,],R,n))))))
  ci <- m04_shape_confidence(profiles$shape[1]);b <- .5;q <- profiles$shape[1];L <- profiles$level[1]
  displacement <- tibble::tibble(level_posterior_mean=b*L,level_posterior_sd=sqrt(b),level_confidence_lower=L-stats::qnorm(.975),level_confidence_upper=L+stats::qnorm(.975),shape_confidence_lower=ci$lower,shape_confidence_upper=ci$upper,shape_posterior_mean=b+b^2*q,shape_credible_lower=b*stats::qchisq(.025,1,ncp=b*q),shape_credible_upper=b*stats::qchisq(.975,1,ncp=b*q))
  A <- diag(2)-matrix(.5,2,2)
  dispersion <- dplyr::bind_cols(tibble::tibble(origin='standardized known-law center'),m04_quadratic_moments(c(0,0),R,A))
  dispersion <- dplyr::mutate(dispersion,observed_A=stats::var((raw[1,]-50)/10),observed_B=stats::var((raw[2,]-50)/10),nonflat_covariance=as.numeric(2*t(c(.5,.5))%*%diag(c(2,1))%*%A%*%c(1,0)))
  p <- c(4,16,64,128);battery <- tibble::tibble(number_scores=p,squared_spread_correlation=(.09*p)^2/((.09*p+.55)^2+(p-2)*.55^2),single_score_retest=.45,within_domain_correlation=.45,between_domain_correlation=.27)
  floors <- dplyr::bind_rows(lapply(1:2,function(i) {t <- if(i==1)c(0,5,10) else c(0,2,14/3,10);a <- if(i==1)c(0,0) else c(4,0);b <- if(i==1)c(1,2) else c(3,1);dplyr::bind_rows(lapply(t,function(tt) {x <- pmax(-10,a-b*tt);tibble::tibble(trajectory=i,time=tt,score1=x[1],score2=x[2],within_profile_variance=stats::var(x))}))}))
  cov <- tibble::tibble(profile=c('A','B'),raw_mean=rowMeans(raw),raw_sd=apply(raw,1,stats::sd));cov <- dplyr::mutate(cov,raw_cov=raw_sd/raw_mean,standardized_mean=(raw_mean-50)/10,standardized_cov=NA_real_)
  variance <- as.numeric(crossprod(c(1,-1),R%*%c(1,-1)));sc2 <- (1+1/21)*(1.6+19*variance)/24
  finite <- tibble::tibble(experiment=c('known law','comparison prior / sampling','proper prior'),df=c(Inf,19,24),squared_scale=c(variance,1.05*variance,sc2),two_sided_tail=c(2*stats::pnorm(-1.5/sqrt(variance)),2*stats::pt(-1.5/sqrt(1.05*variance),19),2*stats::pt(-1.5/sqrt(sc2),24)))
  paired <- m04_paired_summary()
  sensitivity <- dplyr::bind_rows(lapply(list(c(4,2),c(12,10),c(4,1),c(12,9)),function(par) {z <- m04_paired_summary(nu0=par[1],prior_scale=diag(par[2],2),intervals=FALSE);tibble::tibble(nu0=par[1],prior_scale_diagonal=par[2],prior_mean_variance=par[2]/(par[1]-3),posterior_square_mean=z$posterior_square_mean)}))
  list(profiles=profiles,shifts=shifts,displacement=displacement,dispersion=dispersion,battery_length=battery,floors=floors,coefficient_of_variation=cov,finite_comparison=finite,power=powers,paired=paired,prior_sensitivity=sensitivity,training_average=m04_training_average(),training_posterior=m04_training_posterior())
}
