# Initial notation {#sec-notation}

```{=html}
<style>
.notation-page #quarto-content > *, .notation-page main.content { min-width: 0; }
.notation-scroll { max-width: 100%; min-width: 0; overflow-x: auto; }
.notation-scroll .math.display { overflow: visible; }
.notation-scroll mjx-container[display="true"] { max-width: none; width: max-content; min-width: 100%; overflow: visible; }
.notation-scroll:focus-visible, .notation-page .math.inline:focus-visible { outline: 3px solid var(--book-focus); outline-offset: 3px; }
.notation-page .math.inline { display: inline-block; max-width: 100%; overflow-x: auto; overflow-y: hidden; padding-block: .15em; vertical-align: middle; }
</style>

<script>
document.body.classList.add('notation-page');
(function () {
  function nameOverflow() {
    document.querySelectorAll('main .notation-scroll').forEach(function (element) {
      element.tabIndex = element.scrollWidth > element.clientWidth + 2 ? 0 : -1;
    });
    document.querySelectorAll('main .math.inline').forEach(function (element) {
      if (element.scrollWidth > element.clientWidth + 2) {
        element.tabIndex = 0;
        element.setAttribute('role', 'group');
        element.setAttribute('aria-label', 'Long mathematical expression; scroll horizontally');
      } else {
        element.removeAttribute('tabindex');
        element.removeAttribute('role');
        element.removeAttribute('aria-label');
      }
    });
  }
  function start() {
    let pending = false;
    function settle() {
      if (pending) return;
      pending = true;
      requestAnimationFrame(function () { requestAnimationFrame(function () { pending = false; nameOverflow(); }); });
    }
    const sizes = window.ResizeObserver ? new ResizeObserver(settle) : null;
    function observeMath() {
      if (sizes) document.querySelectorAll('main .math.inline, main .math.inline mjx-container, main .math.inline mjx-math').forEach(function (element) { sizes.observe(element); });
      settle();
    }
    function whenMathReady() {
      if (window.MathJax && MathJax.startup && MathJax.startup.promise) MathJax.startup.promise.then(observeMath);
      else setTimeout(whenMathReady, 150);
    }
    whenMathReady();
    if (document.fonts) {
      document.fonts.ready.then(observeMath);
      document.fonts.addEventListener('loadingdone', observeMath);
    }
    document.addEventListener('keydown', function (event) {
      const element = event.target;
      if (!(element instanceof HTMLElement) || !element.matches('.notation-scroll, .math.inline[role="group"]')) return;
      if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey || element.scrollWidth <= element.clientWidth + 2) return;
      const step = Math.max(48, parseFloat(getComputedStyle(element).fontSize) * 3);
      if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
        element.scrollLeft += event.key === 'ArrowRight' ? step : -step;
        event.preventDefault();
      } else if (event.key === 'Home' || event.key === 'End') {
        element.scrollLeft = event.key === 'Home' ? 0 : element.scrollWidth;
        event.preventDefault();
      }
    });
    window.addEventListener('resize', settle);
    window.addEventListener('scroll', settle, { passive: true });
    document.addEventListener('keydown', function (event) { if (event.key === 'Tab') nameOverflow(); }, true);
    const main = document.querySelector('main');
    if (main) new MutationObserver(settle).observe(main, { childList: true, subtree: true, attributes: true, attributeFilter: ['style', 'class'] });
    new MutationObserver(settle).observe(document.documentElement, { attributes: true, attributeFilter: ['style'] });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true });
  else start();
}());
</script>
```


Symbols identify different objects even when particular models relate them. Their meanings and assumptions are stated in the chapter that uses them.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 1; scroll horizontally"}

| Symbol | Initial meaning |
|---|---|
| $i,j,t$ | Person, item or score index as stated locally, and occasion |
| $n,p$ | Number of reference persons and number of score coordinates |
| $U$ | Item, trial, time, or rating observations |
| $A$ | Administration conditions and testing history |
| $Y$ | Raw or scored performance before the specified norm transformation |
| $C$ | Measured background and contextual covariates |
| $\mathcal D_{\mathrm{ref}}$ | Reference or calibration data |
| $Z$ | Reported or normed score profile |
| $H$ | Intended latent ability or state |
| $\mathcal M$ | Declared universe of replications |
| $\tau_{\mathcal M}(i)$ | Expected score for person $i$ under those replications |
| $E_{\mathcal M,i}$ | Residual relative to that expected score |
| $S(Y)$ or $S(Z)$ | A summary statistic; the input scale is stated |
| $D$ | A specified diagnostic, pathological, or prognostic target |
| $a,L$ | An action and its loss function |
| $\mu,\Sigma$ | A population mean vector and covariance matrix |
| $\bar Y,\widehat\Sigma$ | Estimated reference quantities under a specified sampling design |

:::::

Population parameters, estimates, latent attributes, observed performances, and hypothetical replications must be distinguished in each result. A covariance matrix is assumed positive definite only when that condition is stated.

The measurement-error symbol above is a residual definition. Independence, Gaussianity, constant variance, and stability over time are additional assumptions.

A tail probability requires an explicit ordering or event. For a discrete score, strict, inclusive, midpoint, and randomized conventions must not be substituted without explanation. The [interpretation contract](../chapters/00-interpretation.md#sec-interpretation-contract) specifies what each result must make clear.

## Symbols for finite reference inference {#sec-notation-reference}

These symbols are defined formally in [Finite reference information](../chapters/02-finite-reference.md#sec-m02-running) and [Reference curves, tables, and transformations](../chapters/13-reference-curves.md#sec-m13-question). They are listed here because several look alike.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 2; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $G_\nu$; $q_{\nu,u}$ | Central Student $t$ CDF with $\nu$ degrees of freedom and its $u$ quantile |
| $t_\nu(m,c)$ | Location-scale Student law of $m+cT$; $c$ is a scale, not generally an SD |
| $H_\nu(t;\lambda)$; $k_\nu(r;\lambda)$ | Noncentral Student CDF, numerator $Z+\lambda$, and its quantile in the first argument |
| $c_{d,r}$ | Chi-square quantile with $d$ degrees of freedom |
| $\operatorname{IG}(a,b)$ | Inverse-gamma law with density proportional to $v^{-a-1}e^{-b/v}$ |
| $h_0$ | Leverage $x_0^T(X^TX)^{-1}x_0$ at a fixed predictor vector |
| $\zeta$; $\zeta_{u,\gamma,n}$ | Coefficient of a fitted cutoff $\bar Y+\zeta S$; its content-calibrated value |
| $\tau_-,\tau_+$ | SD limits of a joint mean/SD confidence or credible region |
| $\xi_{n,1-\alpha}$ | Calibrated radius of a uniform band around a fitted normal percentile curve |
| $\omega$ | Shape parameter of the sinh-normal score family |

:::::

## Symbols for level, shape and information {#sec-notation-level-shape}

These symbols are defined formally in [Level, shape, and information loss](../chapters/04-level-and-shape.md#sec-m04-running). They are listed here because several letters there have chapter-local meanings that differ from the book-wide table above.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 3; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $v$; $\ell$, $L$ | Declared direction; projection coefficient along $v$ and its standardized level coordinate |
| $Q_v$ | Residual shape relative to $v$, measured in the reference covariance metric |
| $C$ | Centering matrix $I-\mathbf 1\mathbf 1^T/p$ in that chapter, not the covariates of the table above |
| $s^2$, $s$ | Within-profile variance and SD of comparable scores, divisor $p-1$ |
| $A$ | Dispersion matrix $C/(p-1)$ in that chapter, not the administration conditions of the table above |
| $D$ | Two-score shape coordinate, occasion contrast or binary population indicator, as stated locally |
| $\rho_{s^2}$; $\rho_s(\rho)$ | Cross-occasion correlation of squared spread; of the SD, as a function of the contrast correlation |
| $c_\delta$ | Variance factor $1/n_0+1/n_1$ of a two-group mean difference |
| $\operatorname{AUC}$ | Area under the population ROC curve, as in the clinical-targets and design chapters |

:::::

## Symbols for measurement and replication {#sec-notation-measurement}

These symbols are defined formally in [Measurement and replication](../chapters/05-measurement-and-replication.md#sec-m05-running), which also lists its locally reused letters. The relative and absolute generalizability coefficients are written with $\rho$ so that $\Phi$ keeps its book-wide meaning as the standard normal CDF.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 4; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $\rho_{\mathcal M}$; $\rho_m$ | Replication reliability $\operatorname{Var}(\tau)/\operatorname{Var}(Y)$ under the declared universe; reliability of an average of $m$ parallel repeats |
| $v_P,v_T,v_R,v_{PT},v_{PR},v_{TR},v_e$ | Variance components of the crossed person-by-task-by-rater design |
| $v_{\mathrm{rel}}$, $v_{\mathrm{abs}}$ | Relative (shared facets cancel) and absolute error variances of a person's average |
| $\rho_{\mathrm{rel}}(J,K)$, $\rho_{\mathrm{abs}}(J,K)$ | Relative and absolute GT coefficients for $J$ tasks and $K$ raters, often written $G$ (or $E\rho^2$) and $\Phi$ in GT texts; superscript $(K)$ for named raters held fixed |
| $\lambda_A$, $d_A$, $MS_A$ | Expected mean square, degrees of freedom and observed mean square of effect $A$ |
| $\Lambda,\Omega,\Psi_S,\Theta$ | Loadings, factor covariance, stable-specificity covariance and transient covariance of the factor model |
| $G_i$, $S_i$, $A_{it}$ | Stable intended trait, stable specificity and occasion state in the trait-state model (also used in the change chapter); here $A$ is a state, not the administration conditions of the table above |

:::::

## Symbols for items and scoring {#sec-notation-items}

These symbols are defined formally in [Items and scoring](../chapters/06-items-and-scoring.md#sec-m06-running), which also lists its locally reused letters. The item slope $a_j$ is chapter notation, not the action $a$ of the table above.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 5; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $p_h(u)$; $X=s(U)$; $q_h(x)$ | Probability of response pattern $u$ at latent coordinate $h$; a fixed scoring map; the induced law of the reported score |
| $a_j$, $b_j$; $\operatorname{expit}$ | Item slope and difficulty; the logistic function $1/(1+e^{-z})$ |
| $\mathcal S_U$, $\mathcal S_X$ | Derivative scores $\partial_h\log p_h(u)$ and $\partial_h\log q_h(x)$ |
| $I_U(h)$, $I_X(h)$ | Exact Fisher information about $h$ in the full response pattern and in the reported score |
| $\tau(h)$, $V(h)$; $\tau'(h)^2/V(h)$ | Conditional mean and variance of the score; their moment-based lower bound on $I_X(h)$, not the score's exact information |
| $T_a=\sum_ja_jU_j$ | Slope-weighted total, sufficient for $h$ with known logistic items |
| $m(u)$, $Z_u$ | Prior-predictive probability of pattern $u$; under a normal prior it is the normalizer $Z_u$ of the person posterior, a symbol the change chapter uses the same way |
| $\mathcal D$ | Calibration data, as elsewhere in the book |

:::::

## Symbols for norms, invariance and linking {#sec-notation-norms}

These symbols are defined formally in [Norms, invariance, and linking](../chapters/07-norms-invariance-linking.md#sec-m07-examples), which also lists its locally reused letters. $C$ there is a measured covariate, often a group indicator, as in the table above.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 6; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $F(y\mid c)$; $G_c$ | Conditional reference CDF of the observed score; CDF of its standardized residual |
| $F_{\mathrm{pool}}$; $G_C$ | Pooled reference CDF; the covariate distribution that weights it |
| $U^*$ | Randomized rank of a discrete score |
| $S$; $w(o)$; $\eta$ | Inclusion indicator; inclusion probability given the observed variables; inclusion fraction $P(S=1)$ (selection unit only) |
| $\lambda_a,\gamma_a$; $\beta$ | Anchor loading and the anchor's direct group offset; latent group contrast |
| $c_\delta$ | $1/n_0+1/n_1$ for a two-group mean difference, as in the level-and-shape section above |
| $e_{AB}$ | Rank (equipercentile) map from form $A$ to form $B$; there $A,B$ label forms |
| $A,B$ | Intercept and slope of an affine latent link, in the order of the positive affine change $A+BY$ of the reference-curves chapter; not the administration conditions of the table above |
| $c$ | Chi-square quantile in the link bands, as $c_{d,r}$ above |
| $X_d$, $X_M$; $f_h$, $f_\xi$ | Design matrices with rows $(1,d_j)$ and $(1,M_r)$; vectors $(1,h)^T$ and $(1,\xi)^T$ |
| $g=v/t$ | Reliability ratio of a two-reading source average |

:::::

## Symbols for repeated testing and change {#sec-notation-change}

These symbols are defined formally in [Repeated testing and change](../chapters/08-change.md#sec-m08-examples), which also lists its locally reused letters. Where an earlier section above already named an object, the change chapter carries that name forward; footnotes there mark the few exceptions.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 7; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $Y_1,Y_2$; $D_Y$ | Observed performances at two occasions; their raw difference |
| $B$, $V$; $R$ | Conditional coefficients $\Sigma_{21}\Sigma_{11}^{-1}$ and conditional covariance of a known two-occasion law, as in the correlated-battery chapter; the conditional innovation $Y_2-m(Y_1)$ |
| $\delta$ | Fixed conditional mean offset of a case, in observed-score units |
| $v$ | Declared direction, as in the level-and-shape section above |
| $h_0$; $h$, $h_n$ | Leverage; leverage multipliers $1+h_0$ and $1+x_0^TV_nx_0$, as in the correlated-battery chapter |
| $\operatorname{IW}_p(\eta,\Psi)$; $t_p(f,m,\Lambda)$ | Inverse-Wishart law with scale $\Psi$; multivariate Student law with scale matrix $\Lambda$. The correlated-battery chapter writes the degrees as $\nu$ and $d$; in the change chapter $\nu=n-k$ is the residual degrees of freedom |
| $S$ | Residual sum-of-products matrix in the fitted-reference unit (its covariance estimate is $S/\nu$); stable specificity in the state unit |
| $g,s,a,e$; $K$ | Trait, specificity, state and noise variances as in the measurement section above; the stable total $K=g+s$, written $t$ in that chapter |
| $\rho$; $R_\rho$ | Serial correlation of the state; its correlation matrix $\rho^{\lvert t-u\rvert}$ |
| $\Delta_H$ | Latent change $h_2-h_1$ on an anchored metric |
| $K(u\mid h)$ | Two-occasion item-pattern probability, the $p_h(u)$ of the items section above |
| $t=v+s/2$, $g$ | Variance and gain of a two-reading anchor average, as in the items section |
| $\theta=(\theta_0,\theta_1)^T$; $\beta$ | Personal line (intercept, slope); reference age-norm coefficients |
| $z_j$; $D_z$, $D_u$ | Expected-score normative coordinate; its change and the change in percentile |
| $P$, $\Delta$, $q$ | Premorbid level, change from it, and proxy bias in the baseline unit |
| $Y_2(a)$; $A$ | Potential follow-up outcome under treatment $a$; the treatment indicator, part of the testing history $A$ of the table above |

:::::

## Symbols for administration and missingness {#sec-notation-administration}

These symbols are defined formally in [Administration and missingness](../chapters/09-administration-and-missingness.md#sec-m09-examples), which also lists its locally reused letters. Where an earlier section above already named an object, the administration chapter carries that name forward; footnotes there mark the letters kept with a second meaning.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 8; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $Y$; $O$, $o$; $(O,Y_O)$ | Score vector defined under a compatible full administration; random and fixed retained-coordinate patterns; the actual record |
| $g(o\mid y)$; $\bar g_o(y_o)$ | Observation mechanism; its average over the missing scores given the retained ones, the selection factor of a pattern |
| MCAR; MAR | Pattern independent of all scores; pattern depending only on the retained values |
| $X$; $R$; $\pi_{jr}$; $w_j$, $q_j$ | First-score category; administration indicator ($R=1$ full); joint score/pattern probabilities; population and continuation probabilities |
| $f_\theta$, $g_\psi$ | Response model and observation mechanism, with parameters $\theta$ and $\psi$ |
| $h_x$, $h$ | Leverage of a prediction vector, $f_x^TV_ff_x$ for the fitted line or $f^TV_nf$ under the posterior |
| $\mathcal H_t$; $q_t(j\mid\mathcal H_{t-1})$; $k_\theta$ | Recorded history; adaptive policy probability; response kernel |
| $M_t$; $\Lambda_t$; $Q(\,\cdot\,)$ | Beta-mixture likelihood ratio; likelihood-ratio process with estimated calibration; prior predictive probability of a record |
| $c_i$; $D_i$; $d$, $\mathcal E$ | Administrative time limit; completion indicator; completion count and total exposure |
| $\pi_s,\pi_f,\pi_m$; $\theta_0$ | Recorded flag, recorded nonflag and unrecorded probabilities; flag probability among the unrecorded |
| $\Delta$, $\eta$; $\Gamma$ | Declared departures of an unobserved response or mean; an external bound on them |
| $n_{\mathrm{MC}}$ | Number of independent Monte Carlo draws |

:::::

## Symbols for heterogeneity and robustness {#sec-notation-robustness}

These symbols are defined formally in [Heterogeneity and robustness](../chapters/10-heterogeneity-and-robustness.md#sec-m10-examples), which also lists its locally reused letters. Where an earlier section above already named an object, the robustness chapter carries that name forward; footnotes there mark the letters kept with a second meaning.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 9; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $Z$; $\mathcal D$; $P_\theta$, $q_A(\theta)$ | Observed profile; reference data; a stipulated observed-score law and the probability of a fixed score event $A$ under it |
| $X=Z-\mu_0=\delta+\varepsilon$; $Q=X^TBX$; $C_p$ | Deviation from an analysis origin; a quadratic form with fixed matrix $B$; the centering matrix $C$ of the level-and-shape section above |
| $\kappa_{ijkl}$, $M_{ijk}$ | Fourth cumulants and third moments of $\varepsilon$ |
| $T$; $\Omega$; $\nu$; $d(z)$ | Gamma precision of the Student branch; Student scale matrix (the $\Lambda$ of the change section above); degrees of freedom; Student Mahalanobis form |
| $\sigma_\mu$ | Prior scale of the Student location |
| $\pi_g$, $f_g$; $r_g(z)$; $K$ | Mixture weights and component densities; component responsibility; number of components |
| $W_i$; $r=p-1$; $\mathcal E_i$, $d=2r$ | Stable residual variance of a person; number of contrast directions; paired-contrast energy and its dimension |
| $\rho_{s^2}$ | Cross-occasion correlation of squared dispersion, as in the level-and-shape section above |
| $F_j$, $U_j$; $C(u)$, $c(u)$; $R_c$; $\lambda_L$ | Marginal CDFs and uniform coordinates; copula CDF and density; copula correlation parameter; lower tail-dependence coefficient |
| $S$; $S_\lambda=(1-\lambda)S+\lambda\tau I$; $T_0$ | Sample covariance; linear shrinkage toward $\tau I$; a fixed shrinkage target |
| $\operatorname{IW}_p(\nu_0,\Psi_0)$; $m_n,\kappa_n,\nu_n,\Psi_n$; $d_n$ | Inverse-Wishart prior, as in the change section above; normal/inverse-Wishart posterior parameters; predictive degrees of freedom |
| $\Delta_R$; $\eta$, $\epsilon$; $\mathrm{Eff}$ | Relative covariance perturbation; its operator-norm bound and the mean-shift bound; relative efficiency of a discriminant direction |
| $\varepsilon$, $H$, $h=H(A)$ | Contamination fraction, contaminating law and its event probability, in the contamination unit |
| $n_{\mathrm{MC}}$; $n_\theta$ | Number of independent Monte Carlo draws, as in the administration section above; number of posterior parameter draws |
| $s_{\mathrm{tr}}$; $m$, $k$; $c$; $V$ | Trained anomaly score; number of calibration persons and the calibration rank; calibrated cutoff; content of a realized region |

:::::

## Symbols for clinical targets and decisions {#sec-notation-targets}

These symbols are defined formally in [Clinical targets and decisions](../chapters/11-clinical-targets-and-decisions.md#sec-m11-examples), which also lists its locally reused letters. Where an earlier section above already named an object, the clinical-targets chapter carries that name forward; footnotes there mark the letters kept with a second meaning.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 10; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $D$; $\pi=P(D=1\mid c)$; $f_d(x)$, $m(x)$ | Target state, as in the table above; prevalence in the referral population; target-specific record law and its mixture |
| $X$; $W$; $C=c$ | Retained assessment record; additional validity-related observations; the context held fixed |
| $\Lambda(x)$; $q(x)$ | Likelihood ratio $f_1/f_0$; target probability $P(D=1\mid x,c)$ |
| $s$, $f$; $\operatorname{AUC}$ | Sensitivity and false-positive probability of a flag; area under the ROC curve, as in the level-and-shape section above |
| $Q(s,f,\pi)$; $k_1,k_0$; $k_\pi$ of $n_\pi$ | Population positive-result risk; positive-flag counts among verified target-positive and target-negative people; targets in the prevalence sample |
| $F$; $X_F$; $K_0,K_n$; $h_0$ | Functional outcome; design matrix of the function model; prior precision of its coefficients, as in the finite-reference section above; leverage |
| $h$; $q_h$; $d$, $\mathcal E$ | Forecast horizon; event probability by the horizon; event count and total exposure, as in the administration section above |
| $V$; $\pi_{dv}$ | Operational response-process state; joint weights of target and response states |
| $R$; $a_d(x)$, $\bar a_d$ | Inclusion or verification indicator, as in the administration section above; selection probability and its class average |
| $r(X)$; $\operatorname{Ent}(q)$ | Reported risk; Bernoulli entropy in the logarithmic score |
| $\mathrm{Se}_J,\mathrm{Sp}_J$ | Sensitivity and specificity of an imperfect reference label $J$ |
| $\pi_s,\pi_f,\pi_m$; $\theta_0$ | Verified-positive, verified-negative and unverified probabilities; target fraction among the unverified, as in the administration section above |
| $a_0,a_1$; $L(a,d)$; $\bar L(a\mid x)$ | Baseline and alternative actions and their loss, as in the table above; conditional expected loss |
| $c_{\mathrm{FP}},c_{\mathrm{FN}}$; $t$; $c_R$ | False-positive and false-negative costs; decision threshold on the target probability; cost of an ideal referral |
| $R(\delta)$; $u_{\max}$; $n_\delta$; $\operatorname{NB}_t$ | Population risk of a rule; a supplied loss bound; number of candidate rules; net benefit at threshold $t$ |
| $\operatorname{EVSI}$, $\operatorname{EVPI}$; $V_k$ | Expected values of sample and perfect information; optimal expected total loss with at most $k$ further measurements |

:::::

## Symbols for design and validation {#sec-notation-design}

These symbols are defined formally in [Design and validation](../chapters/12-design-and-validation.md#sec-m12-examples), which also lists its locally reused letters. Where an earlier section above already named an object, the design chapter carries that name forward; footnotes there mark the letters kept with a second meaning.

::::: {.notation-scroll role="group" tabindex="0" aria-label="Notation table 11; scroll horizontally"}

| Symbol | Meaning |
|---|---|
| $d$; $O_d\sim p_\theta^d$; $\psi(\theta)$; $C(d)$ | A design; the record it produces and its law; the declared target; the design's cost |
| $\mathcal A$; $f_{\mathcal A,T,d}$; $R_\theta(f\mid T,d)$, $\mathcal R_\theta(\mathcal A,d)$ | Complete learning algorithm; the rule it fits on development sample $T$; risk of that frozen fit and risk averaged over repeated development |
| $X_d$, $V_d$; $M=X_d^TV_d^{-1}X_d$; $s_d^2$ | Loading/design matrix and error covariance of a linear experiment; its precision matrix; sampling variance of the target estimate |
| $K_0$, $K_d$, $K_n$ | Prior and posterior covariance matrices; in this chapter's regression, covariance factors scaled by the error variance. Finite-reference regression instead uses the corresponding precision factors |
| $\mathcal I_d$; $\mathcal B(d)$ | Expected information gain; expected posterior loss plus cost |
| $v_P,\dots,v_e$; $\lambda_A$, $d_A$; $v_{\mathrm{rel}}$, $v_{\mathrm{abs}}$ | Decision-study variance components, expected mean squares, degrees of freedom and error variances, as in the measurement section above |
| $J$, $K$; $J_c$, $K_c$; $r_d$, $r^-_d$, $r^+_d$ | Numbers of future tasks and raters; numbers in the calibration study; the declared error of design $d$ and its bounds over a confidence region |
| $\mathcal S_U$, $\mathcal S_X$; $I_U(h)$, $I_X(h)$ | Derivative scores and Fisher information about a fixed person's coordinate, as in the items section above |
| $I_\delta$, $I_\delta(t)$ | Fisher information about a population shift $\delta$; for a single threshold item at $t$ |
| $d$; $t_*$; $c_{\mathrm{FP}},c_{\mathrm{FN}}$ | Class separation in latent SD units, as in the clinical-targets section above; Bayes threshold on the latent scale; error costs |
| $R$; $\Lambda=\operatorname{diag}(\lambda)$; $Q(\lambda)$; $t_j$ | Within-class latent covariance; precisions of added measurement; known-law class separation; gradient components, $\partial Q/\partial\lambda_j=t_j^2$ |
| $\kappa_j$; $B$; $\nu$ | Precision per cost; budget; Lagrange multiplier |
| $\tilde\delta=R^{-1/2}\delta$; $\lambda_+$ | Whitened shift; total precision of an aligned observation |
| $W_h$; $n_h$, $k_h$; $\bar s_h$ | Target stratum weights; stratum sample sizes and costs; posterior mean of a stratum variance |
| $K$; $K_\gamma$; $h_x$ | Binomial event count; number of observations below the $\gamma$ quantile; leverage, as in the administration section above |
| $D_i$, $W_t$; $b$, $h$; $v$, $e$; $\Gamma$ | Anchor differences and case repeats; channel offset and the case's expected score; their variances; a bound on offset drift, as in the administration section above |
| $m$; $E_i$, $r_T$; $n_{ab}$, $p_{ab}$, $M$, $\omega$ | Number of candidate procedures; error indicators and the frozen rule's error rate; paired error counts and probabilities, the discordant count and the share where only the first rule errs |
| $\operatorname{IW}_6(\nu_0,\Psi_0)$; $\nu_n,\Psi_n$, $\kappa_h$, $m_h$ | Inverse-Wishart prior and its posterior parameters, as in the change and robustness sections above |
| $r_h$, $W_h$, $R_t$; $\delta_h$ | Stratum error rates and target weights; transported error; logit drift |
| $\pi_s,\pi_f,\pi_m$; $\theta_0$; $e(X)$ | Verified-error, verified-correct and unverified probabilities; error rate among the unverified, as in the administration section above; verification probability |

:::::
