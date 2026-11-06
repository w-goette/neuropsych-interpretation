# Measurement and replication {#sec-measurement}

<style>
.m05-page #quarto-content > *, .m05-page main.content { min-width: 0; }
.m05-scroll { max-width: 100%; min-width: 0; overflow-x: auto; }
.m05-scroll .math.display { overflow: visible; }
.m05-scroll mjx-container[display="true"] { max-width: none; width: max-content; min-width: 100%; overflow: visible; }
.m05-scroll:focus-visible, .m05-page .math.inline:focus-visible { outline: 3px solid var(--book-focus); outline-offset: 3px; }
.m05-page .math.inline { display: inline-block; max-width: 100%; overflow-x: auto; overflow-y: hidden; padding-block: .15em; vertical-align: middle; }
.m05-figure-panels { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr)); gap: 1rem; }
.m05-figure-panels p { margin: 0; }
.m05-figure-panels img { width: 100%; height: auto; }
</style>

<script>
document.body.classList.add('m05-page');
(function () {
  function nameOverflow() {
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
    function settle() { requestAnimationFrame(function () { requestAnimationFrame(nameOverflow); }); }
    function whenMathReady() {
      if (window.MathJax && MathJax.startup && MathJax.startup.promise) MathJax.startup.promise.then(settle);
      else setTimeout(whenMathReady, 150);
    }
    whenMathReady();
    if (document.fonts) document.fonts.ready.then(settle);
    window.addEventListener('resize', settle);
    new MutationObserver(settle).observe(document.documentElement, { attributes: true, attributeFilter: ['style'] });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true });
  else start();
}());
</script>


## One score, several possible repeats {#sec-m05-question}

A person scores 35 on a test whose reference peers have mean 50 and SD 10. The earlier chapters asked how unusual that performance is among peers, alone and alongside other scores. A second question usually follows in a report or a research analysis: what would this person score if we measured them again? The answer depends on what "again" means.

- **The same form, a moment later.** Only momentary fluctuation in responding is redrawn. Whatever stays with the person on that form, such as how they respond to its particular items, is kept.
- **A parallel form on another day.** The particular items and the day's state are redrawn as well.
- **New tasks scored by new raters.** Differences between tasks, between raters, and in how this person responds to a particular task or rater are redrawn and averaged.
- **The same named raters, new tasks.** Rater leniency and this person's particular interaction with those raters now stay with the person.

Each choice defines a different expected score for the same person, and therefore a different error. Reliability coefficients, standard errors and intervals are statements about one declared choice, and a coefficient obtained under one kind of repeat does not transfer automatically to another.

Rarity among peers and expected performance under specified repeat conditions are different questions. The second needs a **replication universe**: the declared conditions over which repeats are imagined to vary. Repeating the same items immediately, giving new items tomorrow, and changing both examiner and form do not average over the same influences. None automatically isolates a cognitive construct.

This chapter starts on the **scored performance scale** $Y$. Any scoring or norm transformation is held fixed unless explicitly changed. The intended latent attribute is $H$; the expected replication score is $\tau_{\mathcal M}(i)$. Their relationship must be modelled. The person population determines between-person variation; $\mathcal M$ determines what is averaged within a person. A normative sample from different people alone does not identify the repeat-measurement law.

By the end of the chapter, a reader should be able to name the replication universe behind a reliability coefficient or standard error; tell population reliability apart from one person's precision; explain why a relative coefficient and an absolute coefficient differ, and what changes when raters are held fixed; recognize which splits of stable and transient variation a design cannot identify; compare a confidence interval, a credible interval and a prediction interval computed from the same score; and carry uncertainty about estimated measurement components into a person's interval.

## What each repeat averages over {#sec-m05-universes}

The repeats above become explicit models in the chapter, together with one that the opening list did not name. The table records, for each, what a repeat redraws and what stays in the person's expected score; the linked units state the exact assumptions.

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 1; scroll horizontally"}

| Imagined repeat | Redrawn and averaged | Retained in the expected score | Developed in |
|---|---|---|---|
| Independent draws from one declared kernel | Whatever the declared kernel redraws | Whatever it holds fixed for the person | [Expected performance](#sec-m05-ctt) |
| New tasks and new raters | Task and rater effects, every interaction, cell residual | The person effect | [Facets and decisions](#sec-m05-gt) |
| The same named raters, new tasks | Task effects, task interactions, cell residual | The person effect, the raters' offset and the person–rater interaction | [Fixed raters](#sec-m05-fixed-raters) |
| The same task–rater cell again | The transient part of the cell residual | Every effect of that person, task and rater, including any persistent three-way interaction | [Unreplicated designs](#sec-m05-gt-unreplicated) |
| The same tests on another occasion | Transient noise, and the occasion state in the state model | Common factors and stable specificity (in the state model, the stable trait and stable specificity) | [Factors and states](#sec-m05-factor) |

::::

Two further targets are defined by content rather than by a repeat. A factor-based target excludes stable test specificity that every repeat of the same test retains; a current-state target includes an occasion state that another occasion would redraw. Error is measured relative to whichever target is declared, so these targets have their own error variances.

## How the chapter is organized {#sec-m05-roadmap}

The units move from definitions that need no distributional assumption to explicit likelihoods, priors and estimated components. Each unit states its own observations, target and guarantee; a reader who needs one result can go directly to it.

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 2; scroll horizontally"}

| Unit | Question | Experiment |
|---|---|---|
| [Expected performance](#sec-m05-ctt) | What is a person's expected score, and what do reliability, repeat correlations and averaging summarize? | A declared replication kernel; moment identities, then a binary likelihood |
| [Facets and decisions](#sec-m05-gt) | How do tasks and raters enter error for ranking people versus comparing with a fixed threshold? | Balanced crossed task-by-rater design with supplied variance components |
| [Factors, specificity and states](#sec-m05-factor) | Does repeatability measure the intended factor, and which splits can data identify? | Factor, state and item-response models |
| [Gaussian latent inference](#sec-m05-gaussian) | What can be said about a latent target, or the next score, after one performance? | Known measurement parameters; confidence, posterior and prediction |
| [Estimating components](#sec-m05-components) | How uncertain are fitted components, and how does that uncertainty reach a person's interval? | One-way and crossed calibration; confidence bounds and proper posteriors |

::::

The [lookup guide](#sec-m05-guide) near the end collects the questions, targets and designs in one table, and the [closing section](#sec-m05-boundaries) states what the chapter establishes.

**For a first reading,** follow [expected performance](#sec-m05-ctt) and [parallel repeats](#sec-m05-parallel), then compare [repeatability with common-factor share](#prp-m05-factor-reliability). The [scalar calculation](#sec-m05-shrinkage) returns to the score of 35; [prediction and the four-interval comparison](#sec-m05-gaussian-prediction) distinguish an expected score from the next performance. This Gaussian tour uses supplied measurement parameters. The correlated-repeat, state-calibration and rank-deficient branches can be revisited afterward, with their own conditions. Use the [symbol table](#sec-m05-running) for lookup rather than memorizing it first.

**For calibration and study design,** follow the [crossed experiment](#sec-m05-gt) through its [contrast law](#sec-m05-gt-sampling), then use the [one-way benchmark](#sec-m05-oneway) to see exact component inference in a simpler design. Return to [crossed confidence bounds](#sec-m05-crossed-confidence), the [component posterior](#sec-m05-component-bayes) and [person-target mixtures](#sec-m05-fitted-person-example). The one-way result does not supply the crossed analysis; the latter retains shared facets and parameter uncertainty.

**For consultation,** choose a repeat in the [universe table](#sec-m05-universes), then use the [lookup guide](#sec-m05-guide) to find the target and its full conditions. A reading route does not replace the sampling design, likelihood or prior required by that result.

The R companion's M05 guide reproduces the synthetic examples step by step and explains the target, units and numerical limits of its 23 output tables. It distinguishes exact formulas from the quadrature and prior-importance calculations used to evaluate posterior integrals.

## The running examples and reused symbols {#sec-m05-running}

Every numerical example in this chapter is a synthetic teaching input, chosen so that results can be checked by hand. None is an instrument norm, a fitted value from patients or a clinical cutoff. Three settings recur.

- **A single-score population** (expected-performance and Gaussian units). Stable expected-score variance 64 and independent repeat-noise variance 36 around mean 50, so observed scores have SD 10 and single-score reliability .64. The score $y=35$ is the running observation.
- **A crossed task-by-rater design** (facet and component units). Seven supplied variance components, $(64,9,4,16,9,4,36)$ for person, task, rater, the three two-way interactions and the cell residual, with four tasks and two raters; then 20 persons, whose mean squares later reappear as constructed calibration data.
- **A two-test factor population** (factor and Gaussian units). One common factor with loading 6 on each test, stable specificity variance 28 and transient variance 36, so each test again has SD 10. The two tests correlate .36. This population is not the two-test reference law of the [correlated-battery chapter](03-correlated-battery.md#sec-correlated-battery), whose correlation is .6, although the profile $(35,50)$ reappears as an observation.

Self-contained examples treat binary replication ($m=8$ responses with $s=2$ successes), trait and state splits, local item dependence and a one-way calibration study ($n=20$ persons with $m=3$ replications each).

The chapter covers many experiments with a limited alphabet, so several letters carry different meanings in different units. Each is defined where it is used; the likeliest confusions are:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 3; scroll horizontally"}

| Symbol | Meanings, by unit |
|---|---|
| $\Phi$ | The standard normal CDF $\Phi(\cdot)$ only, as elsewhere in the book. The absolute GT coefficient, written $\Phi$ in many GT texts, is $\rho_{\mathrm{abs}}$ here |
| $G$ | The stable intended trait $G_i$, with variance $g$, in the state model (the same convention as the [change chapter](08-change.md#sec-change)); gamma variables $G_u,G_r$ in the state posterior evaluation. The relative GT coefficient, written $G$ or $E\rho^2$ in many GT texts, is $\rho_{\mathrm{rel}}$ here |
| $\rho$ | Reliability-type variance ratios: replication reliability $\rho_{\mathcal M}$, reliability $\rho_m$ of an average of $m$ repeats, composite reliability $\rho_w$; the relative and absolute GT coefficients $\rho_{\mathrm{rel}}(J,K)$, $\rho_{\mathrm{abs}}(J,K)$ and their fixed-rater versions $\rho_{\mathrm{rel}}^{(K)}$, $\rho_{\mathrm{abs}}^{(K)}$; the one-way single-score reliability $\rho=\eta/(1+\eta)$ |
| $H$ | The latent attribute $H$ (a vector in the factor and Gaussian units); the averaging matrix $H_d=\mathbf1_d\mathbf1_d^T/d$ in the mean-square proofs; the current-state target $H_{it}$ |
| $R$ | The replication $R$ drawn from the kernel; rater effects $R_k$; the residual covariance matrix $R$ in the Gaussian unit; interval endpoints $R_\pm$ in the state calibration |
| $P$ | Person effects $P_i$; the projector $P$ onto identified coordinates; probability $P(\cdot)$ |
| $E$, $e$ | Expectation $E(\cdot)$ and the residual $E_{\mathcal M}$; the cell residual $e_{ijk}$ with variance $v_e$; the noise variance $e$ in the state model and the within-person variance $e$ in the one-way calibration |
| $a$, $b$ | Affine recoding constants; beta prior parameters; the state variance $a$ and the split index $a\in[0,1]$; nested-rater variances $a,b$; the one-way person variance $a$; inverse-gamma shapes and scales $a_A,b_A$; a person's variance bound $b_i$ and covariance vector $b_i$; bias or variance terms $b_h,b_\tau,b_\theta$ |
| $c$ | Common error covariance $c$; common-factor share $c_w$; coefficient vector $c$ for identified targets; interval half-widths $c,c_B$; prior centers $c_A$ |
| $d$, $D$ | Local item dependence $d$; degrees of freedom $d_A$; level counts $d$ in $H_d,C_d$. Occasion differences $D_i$ and $Q_D$; the covariance sum $D$ in the coefficient-alpha bridge; the inverse mean-square map $D=\mathsf A^{-1}$ |
| $M$, $m$ | The universe $\mathcal M$; occasion means $M_i$; the information matrix $M=\Lambda^TR^{-1}\Lambda$; numbers of replications $m$; posterior means $m_H,m_\tau,m_i,m_\mu,m_*$; the item mean function $m(h)$ |
| $Q$, $q$ | The sum of squared loadings $Q$; an orthonormal basis $Q$; sums of squares $Q_M,Q_D$; the latent dimension $q$; split proportions $q,q_g,q_a$ |
| $r$, $t$, $u$ | The replication index $r$; the shrinkage ratio $r=v/(v+\sigma^2)$; the transient total $r=a+e$ and stable total $t=g+s$ in the state units; a persistent cell variance $u$, the mean total $u=t+r/2$ and uniform variables $U_r$ |
| $S$, $s$ | Stable specificity $S_i$ with covariance $\Psi_S$; the binary success count $S$ with value $s$; the specificity variance $s$ in the state model; the sample variance $S_M^2$ |

::::

## Expected performance and classical test theory {#sec-m05-ctt}

We start with the least committal model: a person, a declared way of producing repeats, and the average over those repeats. Nothing yet says that repeats are normally distributed, that error is the same size for everyone, or that the average is a cognitive ability. Classical test theory (CTT) needs only this structure.

Let $I$ be a randomly sampled person from a declared population. For that person a replication $R$ is drawn according to a specified kernel $P_{\mathcal M}(dr\mid I)$, producing $Y=Y(I,R)$. The kernel includes the intended administration conditions, form, occasion, scoring and observation protocol. Assume $E(Y^2)<\infty$ and define

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 1; scroll horizontally"}

$$
\tau=\tau_{\mathcal M}(I)=E(Y\mid I),\qquad
E_{\mathcal M}=Y-\tau.
$$ {#eq-m05-ctt-definition}

::::

The capital $E_{\mathcal M}$ denotes a residual, while $E(\cdot)$ denotes expectation. For a fixed person $i$, the target $\tau_{\mathcal M}(i)$ is a fixed number in that experiment. In the population experiment $\tau$ is random because $I$ is random. Person identity can include stable features that are irrelevant to the intended construct; an operational expectation is not thereby a pure ability measure.

::: {#prp-m05-ctt-moments}
## Orthogonal residual and population reliability

Under the finite-second-moment experiment above,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 2; scroll horizontally"}

$$
\begin{aligned}
E(E_{\mathcal M}\mid I)&=0,\quad\operatorname{Cov}(\tau,E_{\mathcal M})=0,\\
\operatorname{Var}(Y)&=\operatorname{Var}(\tau)+E\{\operatorname{Var}(Y\mid I)\}.
\end{aligned}
$$ {#eq-m05-ctt-moments}

::::

When $\operatorname{Var}(Y)>0$, define the replication reliability

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 3; scroll horizontally"}

$$
\rho_{\mathcal M}
=\frac{\operatorname{Var}(\tau)}{\operatorname{Var}(Y)}\in[0,1].
$$ {#eq-m05-reliability}

::::

The population mean squared error of the single score as an estimate of its replication expectation is
$E\{(Y-\tau)^2\}=E\{\operatorname{Var}(Y\mid I)\}$.
:::

::: {.proof}
Subtracting the conditional expectation gives the conditional-zero-mean property. Iterated expectation gives $E(E_{\mathcal M})=0$ and
$E\{(\tau-E\tau)E_{\mathcal M}\}=E[(\tau-E\tau)E(E_{\mathcal M}\mid I)]=0$.
Expand the variance of $\tau+E_{\mathcal M}$. Finally,
$E(E_{\mathcal M}^2)=E\{E(E_{\mathcal M}^2\mid I)\}=E\{\operatorname{Var}(Y\mid I)\}$.
Both variance terms are nonnegative. If the denominator is zero, the ratio is undefined rather than evidence of perfect measurement.
:::

In words, every observed score splits into an expected score and a residual that is uncorrelated with it, so observed variance is stable variance plus average error variance. Reliability is the stable share. These identities use no Gaussian law, independent-error premise or constant conditional variance. Indeed, take equally frequent people with $\tau=0$ or $2$, and let the residual be equally likely to be $\pm\sqrt{1+\tau^2}$ within each person. Then $\operatorname{Var}(\tau)=1$, the mean conditional error variance is $3$, and $\rho_{\mathcal M}=1/4$. The residual distribution depends on $\tau$, although their covariance is zero. Conditional error SDs are $1$ and $\sqrt5$; the single population summary does not give either person's precision.

### What a repeat-score correlation requires {#sec-m05-parallel}

The definition of reliability uses an expected score that is never observed. A study can reach it only through repeats, so we need conditions under which the correlation between two observed repeats equals $\rho_{\mathcal M}$, and a rule for what averaging several repeats buys.

::: {#prp-m05-parallel}
## Parallel replications and their average

Suppose $Y_r=\tau+E_r$, $r=1,\ldots,m$, have the same person target, $E(E_r\mid I)=0$, the same average error variance $v_e=E\{\operatorname{Var}(E_r\mid I)\}$, and conditionally uncorrelated errors across distinct replications. Set $v_\tau=\operatorname{Var}(\tau)$. If the relevant variances are positive,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 4; scroll horizontally"}

$$
\operatorname{Cov}(Y_r,Y_s)=v_\tau\quad(r\ne s),\qquad
\operatorname{Corr}(Y_r,Y_s)=\rho_{\mathcal M},
$$ {#eq-m05-parallel-correlation}

::::

and the reliability of the average $\bar Y_m$ for the same target is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 5; scroll horizontally"}

$$
\rho_m=\frac{v_\tau}{v_\tau+v_e/m}
=\frac{m\rho_{\mathcal M}}{1+(m-1)\rho_{\mathcal M}}.
$$ {#eq-m05-aggregation}

::::
:::

::: {.proof}
Each error is orthogonal to $\tau$. The cross-error covariance is the expectation of its conditional covariance, because the conditional means vanish; it is zero by assumption. Expanding the covariance gives the first result. Expanding the variance of the mean error gives $v_e/m$. Dividing $v_\tau$ by the resulting total variance and substituting $v_e/v_\tau=(1-\rho_{\mathcal M})/\rho_{\mathcal M}$ proves the last expression for $v_\tau>0$. For $v_\tau=0$, $v_e>0$, both sides are zero; for $v_e=0$, $v_\tau>0$, both sides are one.
:::

The second expression in @eq-m05-aggregation is known as the Spearman–Brown formula; Brown gave it for the reliability of $n$ amalgamated tests [@brown1910some, p. 299]. Conditional independence is sufficient for the cross-error condition; equality of marginal error variances alone is insufficient. With a common pairwise error covariance $c$, the average error variance is instead $v_e/m+(m-1)c/m$ and the two-score correlation is $(v_\tau+c)/(v_\tau+v_e)$. For all finite $m$ in a valid common-covariance sequence, positive $c$ leaves an error floor. Practice, recall and shared examiner influences can also change the target or error means, invalidating the parallel model itself. A retest correlation is a reliability coefficient only under the matching target/design assumptions.

**Synthetic population example.** Let a stable expected score have mean $50$, variance $64$, and independent repeat noise variance $36$. Single-score reliability is $.64$; averaging four genuinely parallel observations gives $64/(64+9)\approx .8767$ and error SD $3$. Holding the noise variance at $36$ but changing the person population's stable variance to $9$ gives reliability $.20$, although single-person noise SD remains $6$. Reliability depends on population spread; precision and population ranking are different summaries. For the running score of 35, the single-score error SD is 6 points in both populations; reliability .64 or .20 describes how well single scores order people in the respective population.

### Correlated repeats have a design constraint {#sec-m05-correlated-repeats}

Repeat errors become correlated when an influence is shared across the repeats in a schedule, such as the same examiner at every session. The previous paragraph's formulas then need one more check: not every common covariance is possible. A common covariance cannot be chosen independently of the number of repeats. Suppose the unconditional residual covariance matrix has diagonal $v_e\ge0$ and off-diagonal $c$. It equals $(v_e-c)I_m+c\mathbf1_m\mathbf1_m^T$. Its eigenvalues are $v_e-c$ on the $m-1$ contrast directions and $v_e+(m-1)c$ on the common direction. For $m\ge2$ it is positive semidefinite exactly when

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 6; scroll horizontally"}

$$
-\frac{v_e}{m-1}\le c\le v_e.
$$ {#eq-m05-common-error-domain}

::::

Conversely any matrix in this range can be realized by a possibly degenerate centered Gaussian residual vector, independently of the person expectation. Thus these are real design possibilities, not merely an algebraic warning. A fixed negative $c$ can be possible for a specified finite collection of repeats but cannot extend to arbitrarily many with the same diagonal. A common-covariance sequence valid for every finite $m$ requires $0\le c\le v_e$. One realization in that range is $E_r=U+\epsilon_r$, with independent centered $U,\epsilon_r$, variances $c,v_e-c$. Whether $U$ is redrawn for the intended replication or retained as a person feature changes the operational target; this construction by itself does not settle that choice.

For the supplied $v_\tau=64,v_e=36$, take $c=9$. A pair's observed correlation is $.73$, exceeding the single-score reliability $.64$ for the originally declared target. Four-score averaging has error variance $36/4+3(9)/4=15.75$, reliability $64/79.75\approx .8025$, and error SD about $3.9686$, rather than $3$ under independent repeats. Its limiting error variance is $9$ and limiting reliability $64/73\approx .8767$. Conversely a four-repeat residual matrix with $c=-12$ has zero error in its average, even though each residual has variance $36$; the sum of errors is then zero almost surely. That finite design cannot be extended to five repeats with the same covariance. Correlation, precision and the law of an actual replication schedule must be considered together. In particular, a retest correlation above the declared reliability can signal shared error rather than better measurement.

### Conditional precision and inference without a Gaussian premise {#sec-m05-conditional-precision}

Reliability and the average error variance are population summaries. An interpretation of one person's score needs that person's precision, and, for any probability statement about the expected score, a likelihood. This section shows what moments alone can and cannot supply.

Write $v(i)=\operatorname{Var}(Y\mid I=i)$. With conditionally independent, identically distributed replications, $\bar Y_m$ has expectation $\tau(i)$ and variance $v(i)/m$ at that person. The population average $v_e=E\{v(I)\}$ is not a bound on every $v(i)$. If a valid supplied upper bound $v(i)\le b_i$ is available for the particular person and $0<\alpha<1$, then

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 7; scroll horizontally"}

$$
P_i\!\left\{|\bar Y_m-\tau(i)|\le
\sqrt{b_i/(m\alpha)}\right\}\ge1-\alpha.
$$ {#eq-m05-conditional-moment-interval}

::::

Indeed, on the event that the squared error exceeds $b_i/(m\alpha)$, its nonnegative expectation is at least that threshold times the event probability. Using $E_i(\bar Y_m-\tau(i))^2=v(i)/m$ gives the bound. Zero $b_i$ means the target is observed exactly. Substituting only the population $v_e$ instead gives at least $1-\alpha$ coverage averaged over people, by the same argument, with no fixed-person guarantee. Unknown bounds or dependent repeats need their own treatment; an estimated coefficient cannot simply be substituted into this inequality.

The missing likelihood in a moment-only posterior assertion can also be exhibited exactly. Let a scored response take only $Y=-2$ or $2$. For any person expectation $\tau\in[-2,2]$, use the replication kernel
$P(Y=2\mid\tau)=(\tau+2)/4$. Compare two possible populations: A has $P(\tau=-1)=P(\tau=1)=1/2$; B has probabilities $1/8,3/4,1/8$ at $\tau=-2,0,2$. In both populations $E(Y\mid\tau)=\tau$, $E\tau=0$, $\operatorname{Var}(\tau)=1$, $P(Y=2)=1/2$, $\operatorname{Var}(Y)=4$, mean residual variance $3$ and reliability $1/4$. They therefore have the same entire one-score observed distribution and the same reliability. After $Y=2$, however,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 8; scroll horizontally"}

$$
P_A(\tau>0\mid Y=2)=3/4,\qquad
P_B(\tau>0\mid Y=2)=1/4.
$$ {#eq-m05-moment-posterior-counterexample}

::::

These follow by multiplying each stated population mass by its response probability and dividing by $1/2$. The two proper population distributions encode different person-level assumptions that a one-score likelihood and reliability cannot distinguish. Thus no universal posterior tail about the operational expectation is determined by those summaries. More repeated outcomes under a specified stable kernel can add information; a coefficient alone cannot.

### A bounded-score replication likelihood with both kinds of interval {#sec-m05-binary-replication}

A non-Gaussian example makes the additional assumptions concrete. Hold the administration and scoring protocol fixed, and observe $m\ge1$ independent binary replications from one person,
$Y_r\mid\vartheta\sim\operatorname{Bernoulli}(\vartheta)$, $0\le\vartheta\le1$. The target is that person's expected scored response $\tau=\vartheta$, in binary-score units; $S=\sum_rY_r$ is the observation retained by this likelihood. Conditional variance is $\vartheta(1-\vartheta)$, which changes with the person. These are independent draws from the same declared replication kernel, not an assumption that any set of different clinical items is exchangeable.

For fixed $\vartheta$, write $p_\vartheta(s)=\binom ms\vartheta^s(1-\vartheta)^{m-s}$ with the usual point-mass interpretation at zero and one. A confidence set for the same target is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 9; scroll horizontally"}

$$
\mathcal C_m(s)=\left\{\vartheta\in[0,1]:
\sum_{u=0}^{s}p_\vartheta(u)\ge\alpha/2,\quad
\sum_{u=s}^{m}p_\vartheta(u)\ge\alpha/2\right\}.
$$ {#eq-m05-binary-confidence}

::::

It has coverage at least $1-\alpha$ for every fixed $\vartheta$, including the endpoints. To prove this, under the true parameter the event that a lower cumulative probability is less than $\alpha/2$ is an initial segment of possible counts, of total probability at most $\alpha/2$. The upper-tail failure is a final segment with the same bound; their union has probability at most $\alpha$. Coupling each Bernoulli as $\mathbf1\{U_r\le\vartheta\}$ using independent uniforms proves that counts increase with $\vartheta$. It follows that the candidate set is an interval. For $0<s<m$, its lower endpoint solves $P_\vartheta(S\ge s)=\alpha/2$ and upper endpoint solves $P_\vartheta(S\le s)=\alpha/2$. The lower endpoint is zero when $s=0$; the upper is one when $s=m$. The procedure is generally conservative because its tails are discrete. It is the interval of @clopper1934binomial, developed for a single binomial count in [One observed performance](01-one-performance.md#sec-m01-confidence).

For a Bayesian analysis of these identical observations and target, declare a proper population/teaching prior $\vartheta\sim\operatorname{Beta}(a,b)$, $a,b>0$, with density $\vartheta^{a-1}(1-\vartheta)^{b-1}/B(a,b)$. The likelihood kernel is $\vartheta^s(1-\vartheta)^{m-s}$, giving

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 10; scroll horizontally"}

$$
\begin{aligned}
\vartheta\mid s&\sim\operatorname{Beta}(a+s,b+m-s),\\
P(Y_{m+1}=1\mid s)&=\frac{a+s}{a+b+m}.
\end{aligned}
$$ {#eq-m05-binary-posterior}

::::

Its finite positive beta normalizer proves propriety at all counts, including all-zero or all-one outcomes; no improper limiting prior is needed. The prediction integrates a new Bernoulli response over this posterior. A credible interval is a beta probability statement conditional on $s$ and the prior, not a uniform fixed-$\vartheta$ confidence guarantee.

For synthetic $m=8,s=2$ and $\alpha=.05$, the confidence interval is approximately $[.031854,.650856]$. The predetermined prior $\operatorname{Beta}(2,2)$ gives posterior $\operatorname{Beta}(4,8)$, mean and new-response probability $1/3$, and central $95\%$ credible interval approximately $[.109263,.609743]$. Under the stated beta population the single-response reliability is $1/(a+b+1)$: beta integration gives $\operatorname{Var}(\vartheta)=ab/[(a+b)^2(a+b+1)]$, whereas the marginal response variance is $ab/(a+b)^2$. At $a=b=2$ this is $.20$; the average of eight parallel responses has reliability $8/(8+4)=2/3$. These population ratios do not give a particular person's posterior by themselves; here the full kernel and prior, as well as the observed count, supplied it.

Read side by side, both intervals concern the same expected response of this person. The credible interval is narrower and its center is pulled toward .5: the posterior parameters $a+s=4$ and $b+m-s=8$ add the prior's 2 and 2 to the observed 2 successes and 6 failures, so the posterior mean is $1/3$ rather than the observed proportion $.25$. The confidence interval uses no prior and keeps its coverage for every fixed $\vartheta$; the credible interval's probability is conditional on the observed count and that prior.

### Scale, inference and what is still missing {#sec-m05-ctt-boundaries}

For a fixed affine recoding $Y^*=a+bY$, $b\ne0$, the new target is $a+b\tau$ and residual is $bE_{\mathcal M}$. Both variance components multiply by $b^2$, preserving reliability and changing error SD by $|b|$. For nonlinear $g$, the target is $E\{g(Y)\mid I\}$, generally different from $g(\tau)$. For example, equally likely scores $0$ and $2$ have mean $1$, but their cubed scores have mean $4$, while the cube of the mean is $1$. The strictly increasing map $y^3$ preserves score order and does not preserve this expectation. Coarsening can remove further information. A reliability coefficient on one scale cannot simply be attached to a different nonlinear normed scale.

The CTT identities are properties of a joint probability experiment, not by themselves a likelihood for a person. The moment interval requires a valid conditional bound; the binary intervals require the explicit independent Bernoulli kernel and, for the posterior, a proper prior. Sampling $I$ from the population induces a distribution for $\tau$, but its first two moments alone do not determine $p(\tau\mid y)$, as the two-population construction demonstrates. The Gaussian and estimated-component sections below supply other explicit likelihoods and priors; they do not follow from the residual definition alone.

Conditional independence of repeated errors, sampling of replications and stability of the target need design evidence. Useful additional data include repeat administrations matched to the desired universe, alternate forms and examiners, and checks for systematic occasion effects. High repeatability by itself establishes neither construct validity nor response validity.

## Facets and decisions: a balanced GT experiment {#sec-m05-gt}

The CTT kernel was deliberately abstract. For many neuropsychological measures the sources that vary across repeats can be named: which task or item set was given, who scored it, and how this person responded to that task or scorer. An expected score over new tasks and new raters differs from an expected score using one fixed form and examiner. Generalizability theory (GT) makes such facets explicit. Its treatment of observations classified by two independent facets, with variance components used to design a measurement procedure for a particular decision, is developed in @gleser1965generalizability. Consider $n\ge2$ randomly sampled persons, $J\ge2$ tasks and $K\ge2$ raters, independently sampled from their respective populations. Every person is scored on every task by every rater, once per cell, using a common metric. This is a balanced, fully crossed design; it is not a model for raters assigned selectively to particular people.

Use the local random-effects model

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 11; scroll horizontally"}

$$
Y_{ijk}=\mu+P_i+T_j+R_k+(PT)_{ij}+(PR)_{ik}+(TR)_{jk}+e_{ijk}.
$$ {#eq-m05-gt-model}

::::

All entries within each array are independent and identically distributed, centered and of finite variance; the seven arrays are mutually independent. Write their variances as $v_P,v_T,v_R,v_{PT},v_{PR},v_{TR},v_e$, allowing zero except where a denominator later requires positivity. The cell term $e$ combines any person–task–rater interaction and residual noise: one observation per cell cannot separate those sources. Person identity fixes the person effect; expectation over independently drawn tasks/raters and their interactions gives $\tau_i=\mu+P_i$. Persistent task or rater effects are averaged out only because they belong to this declared universe.

::: {#prp-m05-gt-dependability}
## Relative and absolute error for an average

For $\bar Y_i=(JK)^{-1}\sum_{jk}Y_{ijk}$, define

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 12; scroll horizontally"}

$$
\begin{aligned}
\Delta&=\bar T+\bar R+\overline{TR},\\
\delta_i&=\overline{PT}_i+\overline{PR}_i+\bar e_i,\\
v_{\mathrm{rel}}&=v_{PT}/J+v_{PR}/K+v_e/(JK),\\
v_{\mathrm{abs}}&=v_{\mathrm{rel}}+v_T/J+v_R/K+v_{TR}/(JK).
\end{aligned}
$$ {#eq-m05-gt-errors}

::::

Then $\bar Y_i=\tau_i+\Delta+\delta_i$ and, over the random design, absolute mean squared error is $v_{\mathrm{abs}}$. For distinct persons using the **same sampled tasks and raters**, the error in their observed difference has variance $2v_{\mathrm{rel}}$. The corresponding population coefficients are

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 13; scroll horizontally"}

$$
\rho_{\mathrm{rel}}(J,K)=\frac{v_P}{v_P+v_{\mathrm{rel}}},\qquad
\rho_{\mathrm{abs}}(J,K)=\frac{v_P}{v_P+v_{\mathrm{abs}}}.
$$ {#eq-m05-gt-coefficients}

::::

They are defined when their denominators are positive. With $v_P>0$, $0<\rho_{\mathrm{abs}}(J,K)\le \rho_{\mathrm{rel}}(J,K)\le1$.
:::

::: {.proof}
Averaging $J$ independent entries of $(PT)_{ij}$ gives variance $v_{PT}/J$, averaging $K$ entries of $(PR)_{ik}$ gives $v_{PR}/K$, and averaging $JK$ cell entries gives $v_e/(JK)$. The common design offset $\Delta$ has variance $v_T/J+v_R/K+v_{TR}/(JK)$. All these sums and $P_i$ are uncorrelated by the array assumptions, so their variances add. In $\bar Y_i-\bar Y_l$, $\Delta$ cancels exactly, leaving error $\delta_i-\delta_l$; the two person-specific errors are independent and equally variable. The signal difference $P_i-P_l$ has variance $2v_P$, establishing the relative signal/total-variance ratio. The absolute ratio uses the total variance of a single person's mean across independently sampled designs. Nonnegative added terms give the ordering.
:::

We write the two coefficients as $\rho_{\mathrm{rel}}$ and $\rho_{\mathrm{abs}}$ because they are reliability-type variance ratios for relative and absolute decisions. GT texts commonly write them as $G$ (or $E\rho^2$) and $\Phi$; this book reserves $\Phi$ for the standard normal CDF and uses $G$ for a stable trait. The relative coefficient is the ratio of universe-score variance to expected observed-score variance that @gleser1965generalizability call a coefficient of generalizability [p. 399].

A common harsh rater shifts everyone's mean and can leave rankings unaffected while changing whether a score lies below an externally fixed threshold. Thus $\rho_{\mathrm{rel}}$ summarizes relative differentiation; $\rho_{\mathrm{abs}}$ includes absolute-location error. Neither is a sensitivity/specificity coefficient for a clinical cutoff. The marginal covariance of two different persons' means is $\operatorname{Var}(\Delta)$ in this shared-facet design. It must not be mistaken for a stable person signal or silently omitted from a likelihood.

**Synthetic decision study.** Supply the variances

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 14; scroll horizontally"}

$$
(v_P,v_T,v_R,v_{PT},v_{PR},v_{TR},v_e)=(64,9,4,16,9,4,36)
$$ {#eq-m05-gt-example-components}

::::

in squared score units. With $J=4,K=2$, $v_{\mathrm{rel}}=13$ and $v_{\mathrm{abs}}=17.75$, giving $\rho_{\mathrm{rel}}\approx .8312$, $\rho_{\mathrm{abs}}\approx .7829$, and absolute error SD $\sqrt{17.75}\approx4.2131$. Increasing tasks to eight while retaining two raters gives $v_{\mathrm{rel}}=8.75$ and $v_{\mathrm{abs}}=12.125$. Increasing raters to four while retaining four tasks instead gives $8.5$ and $12$. These are exact variance predictions under supplied components, not recommendations about feasible clinical testing or estimated-component guarantees. More tasks alone cannot remove $v_{PR}/K+v_R/K$ at fixed $K$. As @gleser1965generalizability observe, reliability as a function of test length, the idea behind the Spearman–Brown formula, does not carry over to a multifacet instrument: accuracy depends on how many conditions are sampled on each facet [p. 416].

Read in the opening's terms: if the four-task, two-rater average is used only to order people tested with the same tasks and raters, its error SD is $\sqrt{13}\approx3.61$ points. If it is compared with a fixed external threshold, the shared task and rater offsets also count, and the error SD is about 4.21 points. In this supplied example, doubling raters reduces both error variances slightly more than doubling tasks, because the person–rater and rater variances are divided only by $K=2$.

### What the crossed design identifies {#sec-m05-gt-identification}

The decision study supplied the seven variances. A calibration study must learn them from data, and the first question is whether the crossed design contains enough distinct contrasts to do so.

The matrices in the proof make averaging and comparison explicit. For one factor, $H_d$ replaces its entries by their average, retaining the constant part; $C_d$ subtracts that average, retaining contrasts between levels. A tensor product combines one such choice for each of persons, tasks and raters. A person contrast, for example, can average over tasks and raters. These operations isolate the sources contributing to each mean square. The later Gaussian model supplies independent chi-square laws for these sums of squares.

::: {#prp-m05-gt-meansquares}
## Expected mean squares in the crossed design

Let $MS_A$ be the ordinary balanced analysis-of-variance mean square for effect $A$, with a grand mean and all main and two-way effects included. The residual is the three-way contrast space. The model implies:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 4; scroll horizontally"}

| Effect | Degrees of freedom | Expected mean square |
|---|---|---|
| $e$ | $(n-1)(J-1)(K-1)$ | $v_e$ |
| $PT$ | $(n-1)(J-1)$ | $v_e+Kv_{PT}$ |
| $PR$ | $(n-1)(K-1)$ | $v_e+Jv_{PR}$ |
| $TR$ | $(J-1)(K-1)$ | $v_e+nv_{TR}$ |
| $P$ | $n-1$ | $v_e+Kv_{PT}+Jv_{PR}+JKv_P$ |
| $T$ | $J-1$ | $v_e+Kv_{PT}+nv_{TR}+nKv_T$ |
| $R$ | $K-1$ | $v_e+Jv_{PR}+nv_{TR}+nJv_R$ |

::::

These moment equations identify the seven variance parameters within this model. They do not separate components hidden inside $e$.
:::

::: {.proof}
For a factor with $d$ levels define $H_d=\mathbf1_d\mathbf1_d^T/d$ and $C_d=I_d-H_d$. Stack the cells in person, task, rater order. The sum of squares for effect $P$ is $y^T A_P y$, where $A_P=C_n\otimes H_J\otimes H_K$; for $PT$ use $C_n\otimes C_J\otimes H_K$; for the residual use $C_n\otimes C_J\otimes C_K$. The remaining four matrices follow by assigning $C$ to the factors in the effect and $H$ to the others. Each is an orthogonal projection of the rank displayed in the table, annihilating the grand mean.

For any such $A$, $E(y^TAy)=\operatorname{tr}(AV)$, where $V=\operatorname{Cov}(y)$. For example, the person component is $v_PI_n\otimes(\mathbf1_J\mathbf1_J^T)\otimes(\mathbf1_K\mathbf1_K^T)$, the $PT$ component is $v_{PT}I_n\otimes I_J\otimes(\mathbf1_K\mathbf1_K^T)$, and the cell component is $v_eI_{nJK}$. Use $C_d\mathbf1_d=0$, $H_d\mathbf1_d=\mathbf1_d$, and $\operatorname{tr}(C_d)=d-1$ to compute the traces divided by the ranks. A component survives only when its constant directions are not annihilated; the remaining constant directions supply the multipliers $n,J,K$. This gives all seven entries. The first four rows solve successively for $v_e,v_{PT},v_{PR},v_{TR}$; each main-effect row then solves for its remaining variance because its multiplier is positive.
:::

For example, $\widehat v_{PT}=(MS_{PT}-MS_e)/K$ and
$\widehat v_P=(MS_P-MS_{PT}-MS_{PR}+MS_e)/(JK)$ are unbiased moment estimates. They can be negative in a finite sample. Truncating them at zero changes their sampling properties; inserting either version into $\rho_{\mathrm{rel}}$ or $\rho_{\mathrm{abs}}$ does not create a confidence interval. Gaussian array assumptions additionally give independent projected sums of squares with scaled chi-square distributions, since the covariance acts as the displayed expected mean square on each orthogonal contrast space. Gaussianity is needed for that distributional statement, not for the mean-square expectations.

### The full Gaussian contrast experiment {#sec-m05-gt-sampling}

The mean-square table becomes a sampling experiment only after a distribution is supplied. Assume now that all seven arrays are Gaussian, while retaining their independence and the crossed design. For each effect $A$ in the table, let $d_A$ be its degrees of freedom, $\lambda_A=E(MS_A)$ its displayed mean square, and $SS_A=d_A MS_A$. Let $\bar Y$ be the grand mean, $N=nJK$, and

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 15; scroll horizontally"}

$$
\begin{aligned}
v_0&=\frac{v_P}{n}+\frac{v_T}{J}+\frac{v_R}{K}
 +\frac{v_{PT}}{nJ}+\frac{v_{PR}}{nK}
 +\frac{v_{TR}}{JK}+\frac{v_e}{nJK},\\
\bar Y&\sim N(\mu,v_0),\qquad
SS_A\ \overset d=\ \lambda_A\,\chi^2_{d_A}.
\end{aligned}
$$ {#eq-m05-gt-full-sampling}

::::

All seven sums of squares and the grand mean are mutually independent. If a particular $\lambda_A=0$, its sum of squares is identically zero; division by it is unavailable. Taking $v_e>0$ makes every $\lambda_A$ and $v_0$ positive, the regular case used later for estimated-component inference.

To prove the entire law, expand each factor's identity as $H_d+C_d$. Their eight tensor products are mutually orthogonal projections summing to $I_N$: seven contrast spaces and the grand-mean space. Every covariance component is a tensor product of identities and constant matrices, with $\mathbf1_d\mathbf1_d^T=dH_d$. Thus it acts as a scalar on each of the eight spaces. On contrast space $A$ that scalar is exactly $\lambda_A$ in the mean-square table. On the normalized constant vector it is $Nv_0$. In an orthonormal basis adapted to these spaces the Gaussian coordinates are independent, with mean zero in the contrast spaces and mean $\sqrt N\mu$ in the constant coordinate. Squaring the $d_A$ contrast coordinates gives the stated independent chi-squares; dividing the constant coordinate by $\sqrt N$ gives the grand mean. This argument proves independence as well as marginal laws; uncorrelated non-Gaussian effects do not supply it.

For example, with $n=20,J=4,K=2$ and the supplied seven variance components, the mean squares in table order $(e,PT,PR,TR,P,T,R)$ are
$(36,68,72,116,616,508,472)$, with degrees of freedom $(57,57,19,3,19,3,1)$. Their degrees sum to $159=N-1$. The grand mean has variance $v_0=8.6$. The expected mean square for a rater effect is based on only one contrast degree of freedom even though 160 cells were observed. Adding people cannot turn two raters into a large rater sample. These are model expectations, not fitted uncertainty estimates; the [component-inference section](#sec-m05-components) will use observed mean squares and the full sampling experiment. The same numbers reappear as [constructed observations with unknown components](#sec-m05-crossed-confidence).

### Changing the universe changes the target {#sec-m05-gt-universe}

If the same named raters are held fixed for all future replications, their main effects become a fixed offset, and each person's average $PR$ interaction with those raters becomes part of that person's new task-averaged target. The original $v_P$ numerator is no longer the complete stable variation for that universe. If every person receives independently sampled tasks/raters, their design offsets no longer cancel in person differences; the shared-facet relative error formula does not apply. If only one task or rater is observed, some contrast spaces disappear and the displayed component identification fails. More cells or constraints are needed. The [table of repeats](#sec-m05-universes) near the start of the chapter summarizes these choices.

Frequentist $\rho_{\mathrm{rel}}$ and $\rho_{\mathrm{abs}}$ here are population variance ratios under repeated sampling of persons/facets; their algebra alone supplies no fitted-procedure coverage. A Bayesian analysis of the **same** experiment uses the crossed covariance likelihood and a proper prior on these variances, then pushes the posterior through these same ratios. The estimated-component section provides the full crossed sampling likelihood, simultaneous component and design-coefficient confidence bounds, and evaluated proper posterior distributions. A simpler one-way replication experiment supplies an exact variance-ratio benchmark alongside its own proper posterior. Neither method can identify an additional unreplicated source inside $e$ merely by assigning it a new name.

### Fixed raters: a different expectation and numerator {#sec-m05-fixed-raters}

The change of universe can be written explicitly. Retain the same named $K$ raters across future replications, but draw entirely new tasks. In the stated random-array model, regard their realized main effects as fixed, and retain each person's $PR$ terms with those raters. The new operational expectation is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 16; scroll horizontally"}

$$
\tau_i^{(K)}=\mu+\bar R+P_i+\overline{PR}_i.
$$ {#eq-m05-fixed-rater-target}

::::

Across new people, conditional on the rater main effects, the person-varying part has variance $v_P+v_{PR}/K$. This is the universe-score variance that @gleser1965generalizability give for generalizing over one facet while the conditions of the other are fixed but not yet specified [p. 400, eq. 4]. For each new set of $J$ tasks, shared error is $\bar T+\overline{TR}$ and person-specific error is $\overline{PT}_i+\bar e_i$. Independence and averaging give

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 17; scroll horizontally"}

$$
\begin{aligned}
v_{\mathrm{rel}}^{(K)}&=v_{PT}/J+v_e/(JK),\\
v_{\mathrm{abs}}^{(K)}&=v_{\mathrm{rel}}^{(K)}+v_T/J+v_{TR}/(JK),\\
\rho_{\mathrm{rel}}^{(K)}&=\frac{v_P+v_{PR}/K}{v_P+v_{PR}/K+v_{\mathrm{rel}}^{(K)}},\\
\rho_{\mathrm{abs}}^{(K)}&=\frac{v_P+v_{PR}/K}{v_P+v_{PR}/K+v_{\mathrm{abs}}^{(K)}}.
\end{aligned}
$$ {#eq-m05-fixed-rater-coefficients}

::::

The constant rater offset is part of this new target; accuracy relative to an externally defined rater-free target would be a different question and could include bias from that offset. The formulas also rely on the original homogeneous independent $PR$ and $TR$ arrays across the named raters. Conditioning on named raters in a model with rater-specific interaction variances would require those conditional variances instead.

In the teaching example at $J=4,K=2$, the new person variance is $68.5$, relative error $8.5$ and absolute error $11.25$. Thus $\rho_{\mathrm{rel}}^{(K)}\approx .8896$ and $\rho_{\mathrm{abs}}^{(K)}\approx .8589$, compared with $.8312$ and $.7829$ when new raters belong to the original replication universe. These higher coefficients do not demonstrate an improved instrument: part of the old error is now retained in the new target. The two targets answer different repeat questions.

### Designs that cannot distinguish the proposed sources {#sec-m05-gt-unreplicated}

A design can also leave two named sources permanently entangled. Two common cases are a single observation per cell and raters nested within persons.

One observation in a cell cannot tell whether its residual is a persistent person–task–rater interaction or transient noise. To exhibit the full observational equivalence, replace $e_{ijk}$ by $U_{ijk}+\epsilon_{ijk}$, with independent Gaussian arrays of variances $u$ and $v_e-u$, where $0\le u\le v_e$. All other arrays are unchanged. For every $u$ the entire once-per-cell crossed vector has the identical mean and covariance, hence the identical Gaussian likelihood. A repeated observation of the same cell retaining $U_{ijk}$ but redrawing $\epsilon$ has an additional cross-repeat covariance $u$ for that cell. Its expected score retains $U_{ijk}$; a fresh-cell expectation does not. No number of new once-only cells identifies this split under the stated model. Actual repeated cells or justified external restrictions are needed. @shrout1979intraclass make the same point for rater studies: without repeated ratings by each judge on each target, the judge-by-target interaction and error cannot be estimated separately [p. 422].

If $v_e>0$ is itself unknown, write $q=u/v_e$ and give it an independent proper prior $q\sim\operatorname{Beta}(a_q,b_q)$, $a_q,b_q>0$. The once-per-cell likelihood is constant in $q$. With any prior for the other parameters having a finite positive posterior normalizer, it follows that $\pi(q\mid y)=\pi(q)$ after integrating those parameters. For an explicit family guaranteeing this condition at every finite $y$, use the proper normal prior for $\mu$ and independent inverse-gamma component priors $v_A\sim\operatorname{IG}(a_A,b_A)$, $a_A>2,b_A>0$, defined in the [component section](#sec-m05-component-bayes), independently of $q$. The covariance satisfies $V\succeq v_eI_N$, so the likelihood is bounded above by $(2\pi v_e)^{-N/2}$. Its prior expectation is finite because

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 18; scroll horizontally"}

$$
E(v_e^{-N/2})=b_e^{-N/2}
\frac{\Gamma(a_e+N/2)}{\Gamma(a_e)}<\infty.
$$ {#eq-m05-gt-split-normalizer}

::::

The bound follows directly by substituting $x=b_e/v_e$ in the inverse-gamma integral. The likelihood is everywhere positive on this prior support, so its normalizer is positive as well. Normalizing then cancels the entire $q$-independent likelihood/prior integral, leaving the stated beta prior unchanged. A proper posterior does not make the split data-identified. Inference about newly sampled tasks/raters still uses the combined $v_e$; inference about repeated identical cells needs the split.

A different assignment of raters can remove other distinctions. For example, suppose each person has their own $K$ raters, used across that person's tasks. Let $R_{ik}^{\mathrm{nested}}$ and $U_{ik}^{\mathrm{nested}}$ be independent centered Gaussian rater and person–rater arrays, with variances $a$ and $b$. Both enter every relevant cell with exactly the same indicator for $(i,k)$. Their sum has variance $a+b$, so replacing $(a,b)$ by $(a+t,b-t)$ for any allowed nonnegative pair leaves the full nested-data likelihood unchanged. Other fixed, person, task and cell terms do not resolve this equivalence. A prediction for a future design in which named raters are shared across people would allocate these sources differently; it is not identified from the nested data merely by importing the earlier crossed mean-square table. Crossing some common raters across people, or supplying substantive constraints, adds the missing information. In the simpler rating design without tasks, where each target has its own judges, @shrout1979intraclass note that judge effects, the judge-by-target interaction and random error are all inseparable [p. 421].

If only one task or rater level is observed in the original design, the corresponding $C_d$ is zero and the affected sums of squares disappear. The invertible seven-equation argument no longer applies. Nonnegative component constraints can bound some combinations, but they do not supply the missing contrast observations. In any design, the person population, sampled facets, retained effects and decision target must travel with a coefficient or a proposed design change.

## Factors, stable specificity and states {#sec-m05-factor}

GT names the sources of variation across repeats; it does not say which stable source is the attribute of interest. CTT defines an expectation without deciding its substantive composition. A factor or structural equation model (SEM) adds relationships between observations and declared latent variables. Consider $p$ scored tests across replications $r$:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 19; scroll horizontally"}

$$
Y_{ir}=\nu+\Lambda H_i+S_i+\varepsilon_{ir}.
$$ {#eq-m05-factor-model}

::::

Here $H_i\in\mathbb R^q$ is the intended stable factor vector, $\Lambda$ is a $p\times q$ loading matrix, $S_i$ is a stable test-specific vector, and $\varepsilon_{ir}$ is transient measurement variation. Assume $H_i,S_i,\varepsilon_{ir}$ mutually independent, finite second moments, $E(H_i)=h_0$, $E(S_i)=E(\varepsilon_{ir})=0$, and covariances $\Omega,\Psi_S,\Theta$. Errors are independent across replications and independent of all stable terms. These are model assumptions, stronger than the CTT residual definition. Diagonal $\Psi_S$ describes mutually uncorrelated stable specificities; a non-diagonal matrix admits shared stable residual influences.

For the universe that retains $H_i,S_i$ and redraws $\varepsilon_{ir}$, the expectation is $\tau_i=\nu+\Lambda H_i+S_i$. The factor-based target $\kappa_i=\nu+\Lambda H_i$ excludes $S_i$. A stable motor, language or response-style influence might belong to $S$ in one intended interpretation and to a construct factor in another. That scientific classification needs external measurement justification.

::: {#prp-m05-factor-reliability}
## Replication reliability and common-factor share

Set $B=\Lambda\Omega\Lambda^T$. The model gives

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 20; scroll horizontally"}

$$
\Sigma_Y=B+\Psi_S+\Theta,\qquad
\operatorname{Cov}(Y_{ir},Y_{is})=B+\Psi_S\quad(r\ne s).
$$ {#eq-m05-factor-covariance}

::::

For any fixed weight vector $w$ with $w^T\Sigma_Yw>0$, the replication reliability and common-factor variance share of $w^TY$ are respectively

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 21; scroll horizontally"}

$$
\rho_w=\frac{w^T(B+\Psi_S)w}{w^T\Sigma_Yw},\qquad
c_w=\frac{w^TBw}{w^T\Sigma_Yw},\qquad c_w\le\rho_w.
$$ {#eq-m05-factor-shares}

::::

For a coordinate $j$ with $(\Sigma_Y)_{jj}>0$, $c_j=B_{jj}/(\Sigma_Y)_{jj}$ is its common-factor communality as a proportion of total variance. A constant coordinate has zero observed variance, and this ratio is undefined. Stable specificity contributes to reliability and is excluded from communality.
:::

::: {.proof}
Expand the covariance of each sum. Independence removes all cross terms. Across replications, the stable terms are retained and the transient terms have zero cross covariance. The conditional expectation of $w^TY$ given the person is $w^T(\nu+\Lambda H_i+S_i)$, so the CTT variance ratio gives $\rho_w$. Excluding $S$ gives the stated common-factor share. Since $\Psi_S$ is positive semidefinite, $w^T\Psi_Sw\ge0$ and the ordering follows. These are variance statements, not distributional normality claims.
:::

**Synthetic two-test example.** Let $H\sim N(0,1)$, $\Lambda=(6,6)^T$, $\nu=(50,50)^T$, $\Psi_S=28I_2$ and $\Theta=36I_2$, with all components independent as specified. Each test has variance $100$, communality $.36$ and replication reliability $.64$. For their mean, factor variance is $36$, stable-specific variance $14$ and transient variance $18$. Thus reliability is $50/68\approx .7353$, while the common-factor share is $36/68\approx .5294$. Changing stable-specific variance changes repeatability without demonstrating better construct measurement. A retest study of these two tests would report reliability .64 for each; only a model that separates the common factor from stable specificity reveals that the common-factor share is .36.

### A coefficient bridge under stated restrictions {#sec-m05-alpha}

The coefficient studied in @cronbach1951alpha is a covariance summary sometimes used in place of a repeat design. Its interpretation needs restrictions; the specific factor-model bridge below is derived from the stated assumptions. For $p\ge2$ tests with covariance $\Sigma$, define the algebraic coefficient

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 22; scroll horizontally"}

$$
\alpha=\frac p{p-1}\left(1-\frac{\operatorname{tr}\Sigma}{\mathbf1^T\Sigma\mathbf1}\right),
\qquad \mathbf1^T\Sigma\mathbf1>0.
$$ {#eq-m05-alpha}

::::

::: {#prp-m05-alpha-bridge}
## Equal-loading and unequal-loading special cases

Suppose $Y_j=\nu_j+\lambda_j H+\varepsilon_j$, $\operatorname{Var}(H)=v_H>0$, with no stable specificity and mutually independent centered transient errors of variances $\theta_j\ge0$, independent of $H$. Write $L=\sum_j\lambda_j$, $Q=\sum_j\lambda_j^2$ and $D=L^2v_H+\sum_j\theta_j>0$. Reliability of the sum is $\rho=L^2v_H/D$, and

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 23; scroll horizontally"}

$$
\alpha=\frac p{p-1}\frac{(L^2-Q)v_H}{D},\qquad
\rho-\alpha=\frac{(pQ-L^2)v_H}{(p-1)D}\ge0.
$$ {#eq-m05-alpha-gap}

::::

Equality holds exactly when all loadings are equal. Equal error variances are not needed for that equality. Adding equal error variances and equal intercepts gives the parallel-score moment special case; the stated model also assumes the required replication structure.
:::

::: {.proof}
The covariance is $v_H\lambda\lambda^T+\operatorname{diag}(\theta_1,\ldots,\theta_p)$. Therefore its trace is $Qv_H+\sum\theta_j$ and its sum of entries is $D$. Substitute in the definition of $\alpha$ and subtract from $\rho$. Cauchy–Schwarz gives $L^2\le pQ$, with equality precisely for a loading vector proportional to $\mathbf1$.
:::

@novick1967coefficient derived $\alpha$ in general as a lower bound on the reliability of a composite with uncorrelated errors, and showed that equality holds exactly when the components are essentially $\tau$-equivalent, that is, when their true scores differ only by constants [Theorems 2.1 and 3.1, p. 6]. In the one-factor model above the true scores are $\nu_j+\lambda_jH$, so essential $\tau$-equivalence means equal loadings; the proposition proves this case directly. This is a conditional bridge, not a general claim that $\alpha$ identifies an instrument's reliability. Correlated errors, stable specificity, multiple factors and different universes require the relevant covariance decomposition. In the preceding two-test example, $\alpha=2(1-200/272)\approx .5294$ equals the common-factor share under its equal-loading/diagonal-residual structure, while repeatability is $.7353$. A negative $\alpha$ can result when oppositely signed loadings cancel; it is not a negative variance component. Reverse scoring and the intended composite must be specified before interpretation. The distinction matters in practice. In a reanalysis of the WAIS-IV standardization covariances with a general factor and four group factors, alpha coefficients of the four factor index scores were at least .90, while the shares of index-score variance attributed to their intended group factors (omega hierarchical) were only .10 to .41 [@watkins2017reliability, p. 1113]. A high reliability coefficient and a small share for the intended factor can describe the same score, as in the two-test example.

### What a single occasion cannot separate {#sec-m05-identification}

The two-test example supplied the split between stable specificity and transient error. A study with one occasion per person cannot recover it, whatever the sample size.

::: {#prp-m05-identification}
## Observational equivalence of stable and transient residuals

Even if $\nu,\Lambda,\Omega$ are known, a single jointly Gaussian occasion with residual covariance $\Psi\succ0$ cannot identify its split into stable specificity and transient error. For an explicit counterexample family within the earlier moment model, also choose $H\sim N_q(h_0,\Omega)$. For every $a\in[0,1]$, choose $S\sim N_p(0,a\Psi)$ and $\varepsilon\sim N_p(0,(1-a)\Psi)$, mutually independent and independent of $H$. All models give exactly the same observed distribution
$N_p(\nu+\Lambda h_0,B+\Psi)$, but different replication reliability whenever $w^T\Psi w>0$. Here zero covariance matrices denote degenerate Gaussian endpoints.
:::

::: {.proof}
The sum of independent Gaussian vectors has the summed mean and covariance, here independent of $a$. The replication covariance is $B+a\Psi$, so the reliability numerator varies with $a$ while its observed denominator is fixed. Thus the whole single-occasion likelihood, not just one estimated correlation, is identical across the alternatives. No amount of additional single-occasion sampling can distinguish them without further restrictions or data.
:::

Omega coefficients, computed from a single administration, respect this limit by combining specific-factor variance and random error into one uniqueness term [@watkins2017reliability, p. 1115].

With independent transient replications, cross-replication covariance identifies $B+\Psi_S$ in the population, while within-occasion covariance identifies $B+\Psi_S+\Theta$. Subtracting identifies $\Theta$ under these assumptions. Identifying the remaining factor/specific split needs restrictions on $\Lambda,\Omega,\Psi_S$ and enough informative tests. Factor coordinates themselves admit invertible recodings: $H^*=AH$, $\Lambda^*=\Lambda A^{-1}$ and $\Omega^*=A\Omega A^T$ preserve the observed law. Declaring a factor scale/sign or loading constraints is part of identification; a labelled coordinate is not a uniquely established cognitive mechanism.

For a centered linear SEM, let $H-h_0=B_H(H-h_0)+\zeta$, where $B_H$ is $q\times q$, $E(\zeta)=0$ and $I-B_H$ is invertible. Then $H-h_0=(I-B_H)^{-1}\zeta$ and
$\Omega=(I-B_H)^{-1}\operatorname{Cov}(\zeta)(I-B_H)^{-T}$ by covariance transformation. This supplies a mathematical bridge to the measurement covariance above. Its arrows have a causal interpretation only with additional design and identifying assumptions; the covariance identity alone supplies none.

For an explicit causal ambiguity, let $0<|r|<1$ and consider two structural constructions using independent standard normal disturbances. One sets $H_1=Z_1$, $H_2=rH_1+\sqrt{1-r^2}Z_2$; the other sets $H_2=Z_2$, $H_1=rH_2+\sqrt{1-r^2}Z_1$. Both give the identical centered bivariate normal law with unit variances and correlation $r$. If an intervention is defined by replacing the equation for $H_1$ by the constant $h$, the first construction gives $E(H_2)=rh$ and the second gives $E(H_2)=0$. The covariance cannot choose between these intervention models. An arrow interpretation therefore needs more than fitting the same measurement covariance.

### Stable traits, current states and another identification limit {#sec-m05-state}

Repeated occasions separate transient noise from what persists between them. Some variation, however, is neither permanent nor momentary: a person can be more or less alert on a given day. A state component describes such variation, and it raises a second identification question. Decomposing repeated measurements of the same people into a trait that does not change, a state that changes and random error, estimated by structural equation modeling, was proposed for multiwave clinical data by @kenny1995trait. Their state follows a first-order autoregression, which with stationarity and four or more waves lets the three sources be estimated [p. 53]; they advise dropping the error variances when the autoregressive coefficient is near zero [p. 54]. The model here takes states to be independent across occasions, which is that boundary case, and shows exactly what such data can and cannot identify. For one test, consider $Y_{it}=\nu+G_i+S_i+A_{it}+\varepsilon_{it}$, with mutually independent centered Gaussian components: stable intended trait $G$, stable specificity $S$, occasion state $A$ and measurement noise $\varepsilon$. Assume states and noise independent across occasions and constant variances $g,s,a,e$. Then the within-occasion variance is $g+s+a+e$, and the cross-occasion covariance is $g+s$. The component choices $(4,5,1,3)$ and $(8,1,3,1)$ produce the same entire Gaussian repeated-score law: diagonal $13$ and every off-diagonal $9$. They disagree about both the stable intended trait and the current state. Even arbitrarily many occasions do not resolve those splits for this single-test model. Within-occasion replication or a justified multi-indicator design could help separate state from noise; factor restrictions or external indicators could help separate trait from stable specificity. Correlated states, practice or changing loadings require a new model and can invalidate the cross-occasion subtraction.

For a current-state target $H_{it}=G_i+A_{it}$, variation in $A$ belongs to the target at occasion $t$; for the long-run target $G_i$ it is an averaged fluctuation. Error is defined relative to the target. A small stable-trait error variance and a small current-state error variance need not describe the same measurement quality. Detailed change models belong to [Change](08-change.md#sec-change).

### What is identified about a trait or state share? {#sec-m05-state-identified-set}

Suppose the population repeated-score law in this Gaussian model is known exactly, with diagonal variance $V$ and common off-diagonal covariance $C$, where $0<C<V$. Put $t=C=g+s$ and $r=V-C=a+e$. Every choice

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 24; scroll horizontally"}

$$
g\in[0,t],\quad s=t-g,\qquad
a\in[0,r],\quad e=r-a
$$ {#eq-m05-state-equivalence-set}

::::

has that same entire repeated-score law. These ranges are sharp: independent Gaussian components realize every listed choice. Thus the stable intended-trait variance share $g/V$ can be anywhere in $[0,C/V]$. The current-state target $H_t=G+A_t$ has variance share $(g+a)/V$ anywhere in $[0,1]$. Both are signal/total-variance shares for their specified single-occasion targets, not the same retest reliability. More occasions estimate the two totals better under the model, but cannot distinguish their internal splits.

The two earlier component choices also give different proper posteriors at the same score even when their parameters are supplied. At a single centered observation $y=Y_t-\nu$, target $H_t$ and residual $S+\varepsilon_t$ are independent normals with variances $g+a$ and $s+e$. Completing their normal square gives posterior mean $(g+a)y/V$ and variance $(g+a)\{1-(g+a)/V\}$. At $y=-3$, the choices $(4,5,1,3)$ and $(8,1,3,1)$ therefore give means $-15/13\approx-1.153846$ and $-33/13\approx-2.538462$, with variances $40/13\approx3.076923$ and $22/13\approx1.692308$. The difference comes from distinct measurement/target assumptions, although the observed repeated-score law is identical. These are population-model posteriors, not distributions of an already observed score.

### Finite calibration can learn totals while leaving splits unidentified {#sec-m05-state-calibration}

Now actually estimate the totals from $n\ge2$ independent people measured on two occasions under this same stable model. Both $\nu$ and the totals $t\ge0,r>0$ are unknown. Define $M_i=(Y_{i1}+Y_{i2})/2$ and $D_i=(Y_{i1}-Y_{i2})/\sqrt2$. Gaussian transformation gives mutually independent arrays

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 25; scroll horizontally"}

$$
M_i\sim N(\nu,u),\quad u=t+r/2,\qquad
D_i\sim N(0,r).
$$ {#eq-m05-state-calibration-law}

::::

The zero mean of $D_i$ is a restriction of this no-systematic-change experiment, not a fitted mean silently set to zero. Use $S_M^2$ with denominator $n-1$, $Q_M=(n-1)S_M^2$, and the **uncentered** $Q_D=\sum_iD_i^2$. Orthogonal normal mean/contrast coordinates give independent pivots $Q_M/u\sim\chi^2_{n-1}$ and $Q_D/r\sim\chi^2_n$.

For a desired error rate $0<\gamma<1$, put $\epsilon=1-\sqrt{1-\gamma}$. Form the usual central chi-square variance intervals

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 26; scroll horizontally"}

$$
\begin{aligned}
[U_-,U_+]&=\left[\frac{Q_M}{\chi^2_{n-1,1-\epsilon/2}},
\frac{Q_M}{\chi^2_{n-1,\epsilon/2}}\right],\\
[R_-,R_+]&=\left[\frac{Q_D}{\chi^2_{n,1-\epsilon/2}},
\frac{Q_D}{\chi^2_{n,\epsilon/2}}\right].
\end{aligned}
$$ {#eq-m05-state-total-confidence}

::::

Their rectangle has simultaneous coverage exactly $(1-\epsilon)^2=1-\gamma$ for $(u,r)$. Intersect it with $u\ge r/2$ and $r>0$; this preserves coverage at every allowed true parameter. Its union of the sharp trait-share identified sets has outer endpoints

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 27; scroll horizontally"}

$$
\left[0,\frac{U_+-R_-/2}{U_++R_-/2}\right]
$$ {#eq-m05-state-share-confidence}

::::

when the region is nonempty, and is reported empty otherwise. On the joint coverage event this interval contains the **entire true identified set**, hence any true $g/(t+r)$. To prove the upper endpoint, the largest possible share is obtained by taking $g=t$, and $(u-r/2)/(u+r/2)$ increases in positive $u$ and decreases in positive $r$. The extreme pair $(U_+,R_-)$ is feasible whenever the region is nonempty. This is an outer confidence statement about partially identified targets; it does not turn the unobserved split into an estimate. The corresponding current-state-share identified set remains $[0,1]$ even with exact totals.

A proper Bayesian analysis uses the same $M,D$ likelihood and targets. Put a prior proportional to the product of $u\sim\operatorname{IG}(a_u,b_u)$ and $r\sim\operatorname{IG}(a_r,b_r)$ densities, **restricted to $u>r/2$**, with positive shapes/scales, and let $\nu\mid u\sim N(\nu_0,u/\kappa_0)$, $\kappa_0>0$. Here inverse-gamma density is $b^a v^{-a-1}e^{-b/v}/\Gamma(a)$ on $v>0$. The joint restricted prior has a finite positive normalizer: its unrestricted product integrates to one and assigns positive probability to this open region. Define independent split proportions $q_g=g/t$ and $q_a=a/r$, each with declared proper beta priors independent of $(u,r,\nu)$.

Completing the normal mean square and using the known-zero difference likelihood gives

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 28; scroll horizontally"}

$$
\begin{aligned}
\kappa_n&=\kappa_0+n,&
\nu_n&=(\kappa_0\nu_0+n\bar M)/\kappa_n,\\
a_u^*&=a_u+n/2,&
b_u^*&=b_u+Q_M/2+
\frac{\kappa_0n}{2\kappa_n}(\bar M-\nu_0)^2,\\
a_r^*&=a_r+n/2,& b_r^*&=b_r+Q_D/2.
\end{aligned}
$$ {#eq-m05-state-total-posterior}

::::

The posterior for $(u,r)$ is the product of these updated inverse-gamma densities restricted to $u>r/2$, and $\nu\mid u,r,y\sim N(\nu_n,u/\kappa_n)$. Its unrestricted product is proper with positive probability of the same open constraint, proving posterior propriety for every finite dataset. These continuous priors put no mass on exactly zero stable total or exactly zero split components; point-null analysis would need declared boundary masses. The split priors remain exactly unchanged, since the likelihood and constraint contain neither $q_g$ nor $q_a$. The resulting posteriors for $g/(t+r)=q_g(u-r/2)/(u+r/2)$ and $(g+a)/(t+r)$ integrate uncertain totals **and** these prior-dependent splits. A covariance fit alone supplies neither posterior.

For synthetic summaries $n=20$, $\bar M=0$, $S_M^2=11$ and $Q_D=80$, at $\gamma=.05$ the intervals are approximately $u\in[5.911811,26.348143]$, $r\in[2.178998,9.330876]$. The outer trait-share confidence interval is $[0,.920584]$. Take the predetermined restricted prior with $a_u=a_r=3$, $b_u=22,b_r=8$, $\nu_0=0,\kappa_0=1$, and uniform beta split priors. The numbers $11$ and $4$ are the means of the **unrestricted** inverse-gamma factors; truncation changes the joint prior moments. The posterior factors are $\operatorname{IG}(13,126.5)$ and $\operatorname{IG}(13,48)$, subject to the same constraint.

To evaluate the posterior exactly up to one-dimensional quadrature, let $X=r/(2u)$. In the unrestricted posterior product it has law $(48/253)F_{26,26}$: writing $u=126.5/G_u$, $r=48/G_r$ gives independent gamma variables of shape 13 and rate 1, whose ratio is that F law. Restrict to $0<X<1$, an event of probability approximately $.9999668605$. For $h(x)=(1-x)/(1+x)$, the trait share is $q_gh(X)$. For $0<z<1$, its CDF is the integral of the beta CDF at $\min\{1,z/h(x)\}$ against this restricted density. The CDF is zero for $z\le0$ and one for $z\ge1$; the endpoint $x=1$ has probability zero. With the uniform split prior its posterior mean is approximately $.333430$, median $.322976$ and central $95\%$ credible interval $[.016057,.718127]$. Changing only the prior for $q_g$ to $\operatorname{Beta}(8,2)$ raises the posterior mean to approximately $.533488$.

The data and posterior totals are unchanged; the likelihood cannot arbitrate between the split priors. The confidence and credible statements have different guarantees for the same trait-share target, and neither supplies construct validity. In this synthetic example, 20 people on two occasions narrow the totals considerably, but the share of variance due to the intended stable trait remains anywhere from 0 to about .92 under the confidence statement, and its posterior summary moves with the split prior.

### The item-kernel bridge {#sec-m05-item-bridge}

An item-response model, including IRT, can supply the kernel left unspecified by CTT. For a finite response vector $U$ with probabilities $p(u\mid h)$, $\sum_u p(u\mid h)=1$, and a fixed score $Y=s(U)$, define

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 29; scroll horizontally"}

$$
 m(h)=\sum_u s(u)p(u\mid h),\qquad
 v(h)=\sum_u\{s(u)-m(h)\}^2p(u\mid h).
$$ {#eq-m05-item-moments}

::::

If the declared person-level model says that $h$ contains every stable influence on the repeat kernel, then $\tau_{\mathcal M}(i)=m(h_i)$ and the residual has conditional mean zero and variance $v(h_i)$. Under a specified population distribution for $H$, total variance gives
$\operatorname{Var}(Y)=\operatorname{Var}\{m(H)\}+E\{v(H)\}$. For locally independent binary items with success probabilities $p_j(h)$ and sum scoring, $m(h)=\sum_jp_j(h)$ and $v(h)=\sum_jp_j(h)\{1-p_j(h)\}$; the second equality follows by adding conditional variances and explicitly requires conditional independence. These equations prove the bridge from an item kernel to CTT; they do not identify a factor scale, establish local independence empirically or equate a moment ratio with Fisher information. [Items and scoring](06-items-and-scoring.md#sec-items-and-scoring) owns the full likelihood, coarsening and information developments.

For a finite dependent-item example, let the population have equally likely $H=-1,1$, with the two item margins $p(H)=.25,.75$, respectively. Given $H$, specify the four response probabilities by

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 30; scroll horizontally"}

$$
\begin{aligned}
P(11\mid H)&=p^2+d,\\
P(00\mid H)&=(1-p)^2+d,\\
P(10\mid H)&=P(01\mid H)=p(1-p)-d,\quad d=.1.
\end{aligned}
$$ {#eq-m05-dependent-item-example}

::::

All four probabilities are positive and sum to one at both stated values of $p$; both margins remain $p$, but conditional covariance is $d$. For $Y=U_1+U_2$, the person expectation is $.5$ or $1.5$, and its conditional variance is $2p(1-p)+2d=.575$. The between-person expected-score variance is $.25$, so the replication reliability under fresh conditional response draws is $.25/.825=10/33\approx .303030$. Setting $d=0$ at the same margins gives conditional variance $.375$ and reliability $.40$. Local dependence therefore changes precision even when the item success curves and expected sum score agree. Using the conditional-independent variance formula in the dependent model would answer a different experiment. The finite joint kernel, rather than a coefficient or a marginal item curve alone, supplies the bridge.

The factor/SEM and item-kernel bridges are measurement assumptions and moment identities, with no confidence/credible interval implied by the identities themselves. Gaussian latent inference below compares likelihood confidence procedures and a proper population-prior posterior on declared targets. Unknown component inference later treats the same variance functions under repeated calibration sampling and a proper parameter prior. Neither approach removes the observational equivalences here: a posterior split can be determined by its prior when the likelihood cannot distinguish it.

## Gaussian inference for a declared latent target {#sec-m05-gaussian}

A latent posterior needs more than a covariance decomposition. Let $p,q\ge1$ be integer score and latent dimensions. In this unit $\Phi$ is the standard normal CDF and $z_u=\Phi^{-1}(u)$; $\chi^2_{d,u}$ is a central chi-square quantile. Fix a population and measurement scale and supply known $\nu,\Lambda,R,h_0,\Omega$, where $R\succ0$ and $\Omega\succ0$. For one $p$-coordinate performance use

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 31; scroll horizontally"}

$$
Y\mid H=h\sim N_p(\nu+\Lambda h,R),\qquad
H\sim N_q(h_0,\Omega).
$$ {#eq-m05-gaussian-experiment}

::::

The second distribution is a **proper population prior for the individual target**; the first is the observation likelihood. They are explicit modelling choices, not a consequence of a low normed score. For the factor model above, taking $R=\Psi_S+\Theta$ integrates over the population distribution of stable specificity as well as transient noise. Conditional on the complete fixed person $(h,s)$, however, only the transient part is redrawn. We will keep those experiments distinct.

The unit examines one Gaussian model from five angles: a proper posterior for the latent target; a confidence region for the same target treated as fixed; what remains possible when the loadings are rank deficient; a scalar calculation with its risk, coverage and prior sensitivity; and prediction of another performance, with or without the person's stable specificity. The scalar calculation returns to the running score of 35.

::: {#prp-m05-gaussian-posterior}
## Proper posterior and squared-error prediction

For any $p\times q$ matrix $\Lambda$, including one of deficient rank, define

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 32; scroll horizontally"}

$$
\begin{aligned}
V_H&=(\Omega^{-1}+\Lambda^TR^{-1}\Lambda)^{-1},\\
m_H(y)&=V_H\{\Omega^{-1}h_0+\Lambda^TR^{-1}(y-\nu)\}.
\end{aligned}
$$ {#eq-m05-latent-posterior}

::::

Then $H\mid Y=y\sim N_q(m_H(y),V_H)$ is proper. Equivalently, for $\Sigma=\Lambda\Omega\Lambda^T+R$,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 33; scroll horizontally"}

$$
\begin{aligned}
m_H(y)&=h_0+\Omega\Lambda^T\Sigma^{-1}(y-\nu-\Lambda h_0),\\
V_H&=\Omega-\Omega\Lambda^T\Sigma^{-1}\Lambda\Omega.
\end{aligned}
$$ {#eq-m05-latent-gain}

::::

For $0<\alpha<1$, the ellipsoid
$\{h:(h-m_H)^TV_H^{-1}(h-m_H)\le\chi^2_{q,1-\alpha}\}$ has conditional posterior probability $1-\alpha$. The posterior mean minimizes posterior expected squared Euclidean error; its population-integrated mean squared error is $\operatorname{tr}(V_H)$.
:::

::: {.proof}
Multiplying likelihood and prior gives an exponent whose terms in $h$ are
$-\tfrac12 h^T(\Omega^{-1}+\Lambda^TR^{-1}\Lambda)h+h^T\{\Omega^{-1}h_0+\Lambda^TR^{-1}(y-\nu)\}$.
The precision is positive definite because $\Omega^{-1}$ is positive definite and the added term is positive semidefinite. Complete the square to obtain a normalized Gaussian density with finite integral and the stated mean/covariance. Multiplying the proposed gain expression by the precision verifies the alternative mean; multiplying the proposed covariance by the precision verifies it is the inverse. Posterior standardization gives $q$ independent standard normal coordinates, whose squared sum has the stated chi-square distribution. Finally,
$E(\|H-a\|^2\mid y)=\operatorname{tr}(V_H)+\|a-m_H(y)\|^2$.
The minimum is achieved at $m_H$; integrating over $Y$ leaves the same constant trace under the joint prior/likelihood model.
:::

A proper prior can yield a proper posterior along unidentified likelihood directions. That fact does not make those directions data-identified. For $\Lambda=0$, the posterior is exactly the prior. Changing the population prior or the stable-specific covariance can change the inference even at the same observed score. Unknown measurement parameters require additional calibration data and the later mixture calculation.

### The same likelihood with a fixed target {#sec-m05-confidence}

::: {#prp-m05-gaussian-confidence}
## Likelihood confidence region for a fixed latent coordinate

In the observation family $Y\mid h\sim N_p(\nu+\Lambda h,R)$, suppose $\Lambda$ has full column rank $q\le p$. Treat $h$ as fixed and $R,\Lambda,\nu$ as known, and let the experiment redraw the entire kernel residual. Put

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 34; scroll horizontally"}

$$
M=\Lambda^TR^{-1}\Lambda,\qquad
\widehat h=M^{-1}\Lambda^TR^{-1}(Y-\nu).
$$ {#eq-m05-gls-target}

::::

Then $\widehat h\mid h\sim N_q(h,M^{-1})$ and

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 35; scroll horizontally"}

$$
\mathcal C(Y)=\{h:(\widehat h-h)^TM(\widehat h-h)
\le\chi^2_{q,1-\alpha}\}
$$ {#eq-m05-confidence-region}

::::

has coverage $P_h\{h\in\mathcal C(Y)\}=1-\alpha$ for every fixed $h$. No population prior is used.
:::

::: {.proof}
Full column rank makes $M$ positive definite. Apply the displayed linear map to the normal observation: its mean is $h$ and its covariance is
$M^{-1}\Lambda^TR^{-1}RR^{-1}\Lambda M^{-1}=M^{-1}$.
Whitening therefore gives $q$ independent standard normals, and the ellipsoid inclusion is exactly the chi-square event.
:::

This compares confidence and posterior inference for the same $H$ and the same observation kernel. Their centers and shapes generally differ. With $R=\Psi_S+\Theta$, frequentist coverage averages over a new draw of $S$ among people at the fixed $h$, as well as transient noise. It is not a guarantee across retests of one person with their fixed $s$. In that retest experiment, $\widehat h$ has mean $h+M^{-1}\Lambda^TR^{-1}s$ and covariance obtained using $\Theta$ instead of $R$, so the confidence proof no longer applies. If the likelihood is rank deficient, a proper prior still works, but this finite full-coordinate confidence ellipsoid cannot be constructed without additional restrictions.

### Identified coordinates and unbounded confidence directions {#sec-m05-rank-confidence}

A deficient loading matrix does not make all likelihood inference impossible. Put $A=R^{-1/2}\Lambda$, let $k=\operatorname{rank}(A)$, and let $Q$ have orthonormal columns spanning its column space. For $k\ge1$, define $P=QQ^T$ and the identified observation mean coordinate $\eta=Q^TAh$. Then

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 36; scroll horizontally"}

$$
Q^TR^{-1/2}(Y-\nu)\mid h\sim N_k(\eta,I_k).
$$ {#eq-m05-identified-coordinate-law}

::::

Thus

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 37; scroll horizontally"}

$$
\mathcal C_k(Y)=\left\{h:
\|Q^TR^{-1/2}(Y-\nu-\Lambda h)\|^2
\le\chi^2_{k,1-\alpha}\right\}
$$ {#eq-m05-rank-confidence-cylinder}

::::

has exactly $1-\alpha$ coverage for every fixed $h$ under the stated full-residual likelihood. The proof is direct: at the true $h$ the displayed vector consists of $k$ independent standard normal coordinates. If $k<q$, the confidence set is unbounded along every vector in $\ker\Lambda$; adding such a vector leaves both the set's defining expression and the full data likelihood unchanged. At $k=0$ there is no identified coordinate, and the whole latent space is an uninformative coverage-one set.

A linear target $b^Th$ is identified exactly when $b$ annihilates this kernel, equivalently $b\in\operatorname{range}(\Lambda^T)$. In that case write $b^Th=c^T\eta$ for a fixed $c$; the estimator $c^TQ^TR^{-1/2}(Y-\nu)$ has variance $\|c\|^2$, giving the usual normal interval when $c\ne0$. If $b$ does not annihilate the kernel, choose $n_0\in\ker\Lambda$ with $b^Tn_0\ne0$. All parameters $h+t n_0$ have the identical observation law while $b^T(h+t n_0)$ spans the real line. No almost-surely finite interval under that law can have coverage bounded below by $1-\alpha>0$ for every such parameter: its inclusion probability tends to zero as $|t|\to\infty$, by bounded convergence. A proper prior can supply finite posterior intervals here, but their finiteness is not likelihood identification.

Nor must an unidentified coordinate retain its **marginal** prior when the prior connects it to identified coordinates. For $p=1,q=2$, $\Lambda=(1,0)$, $R=1$, $\nu=0$, $h_0=0$, an independent $N_2(0,I_2)$ prior leaves $H_2\mid y\sim N(0,1)$. Replacing only the prior covariance by $\Omega=\left(\begin{smallmatrix}1&.8\\.8&1\end{smallmatrix}\right)$ instead gives $H_2\mid y\sim N(.4y,.68)$ from the same gain formula. At $y=2$ its posterior mean is $.8$. The likelihood still contains no $h_2$; the assumed population association supplies this update. Report which prior relationship contributes to an individual inference.

### A scalar calculation, risk and prior sensitivity {#sec-m05-shrinkage}

Take a deliberately simpler CTT model with no stable-specific term: $Y\mid\tau\sim N(\tau,36)$ and proper prior $\tau\sim N(50,64)$. Units are score points; this supplied population is the earlier single-score example. A score $y=35$ gives

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 38; scroll horizontally"}

$$
\tau\mid y\sim N(40.4,23.04),\qquad
40.4=50+.64(35-50).
$$ {#eq-m05-scalar-posterior}

::::

The central $95\%$ credible interval is approximately $[30.9922,49.8078]$. The likelihood confidence interval for fixed $\tau$, repeating independent noise, is $y\pm1.959964(6)$, or $[23.2402,46.7598]$. These intervals concern the same latent expectation under different inferential constructions; neither is an interval for an already observed score.

The two intervals correspond to two conventions in neuropsychological practice. Traditional limits are centered on the obtained score and use the standard error of measurement, $s_X\sqrt{1-r_{XX}}$; the limits reported for WAIS-IV index scores are instead centered on an estimated true score, obtained by regressing the obtained score toward the normative mean, and use a standard error of estimation [@crawford2012waisiv, pp. 193-194]. In the form $s_X\sqrt{r_{XX}(1-r_{XX})}$ described by @crawford2009percentiles [p. 200], and with $s_X=10$ and $r_{XX}=.64$, these give the confidence interval and the credible interval above: half-widths $1.959964\times6$ and $1.959964\times4.8$ around 35 and 40.4.

The model shows what the regressed center assumes. It is a posterior mean under a population prior, so it suits a person drawn from the normative population. Both papers question regressing a score from a clinical population toward the normative mean, since in all likelihood the score is then regressed toward the wrong mean [@crawford2009percentiles, p. 202; @crawford2012waisiv, pp. 193-194]; the fixed-person coverage below quantifies the cost.

For a general scalar prior $N(m_0,v)$ and error variance $\sigma^2$, let $r=v/(v+\sigma^2)\in(0,1)$. The posterior mean is $m(Y)=m_0+r(Y-m_0)$ and its variance is $V=r\sigma^2$. At a fixed target $h$, the mean squared error of this estimator is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 39; scroll horizontally"}

$$
\operatorname{MSE}_h\{m(Y)\}
=(1-r)^2(h-m_0)^2+r^2\sigma^2.
$$ {#eq-m05-fixed-risk}

::::

This follows by writing $m(Y)-h=(1-r)(m_0-h)+r\varepsilon$, whose second term has mean zero and variance $r^2\sigma^2$. For $m_0=50,v=64,\sigma^2=36$, risk at $h=35$ is $43.9056$, exceeding the unshrunk score's risk $36$. Averaged over the stated prior, the risk is $23.04$. Shrinkage improves integrated squared error for that population/prior; it is not a uniform fixed-person improvement.

Similarly, write $b_h=(1-r)(m_0-h)$ and $c=z_{1-\alpha/2}\sqrt V$. The sampling coverage of the central credible interval at fixed $h$ is exactly

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 40; scroll horizontally"}

$$
\Phi\!\left(\frac{c-b_h}{r\sigma}\right)
-\Phi\!\left(\frac{-c-b_h}{r\sigma}\right).
$$ {#eq-m05-credible-coverage}

::::

The formula is obtained by integrating $N(b_h,r^2\sigma^2)$ between $-c$ and $c$. At $h=50,35,20$, the nominal $.95$ posterior intervals have sampling coverage approximately $.9857,.8516,.3585$, respectively. Coverage tends to zero as $|h-m_0|\to\infty$ for a fixed finite prior variance. Its average over the prior is $.95$ by iterated posterior probability. Posterior credibility, population-average coverage and fixed-person coverage answer different questions.

As an explicit proper-prior sensitivity check at $y=35$, changing only the prior variance from $64$ to $16$ gives posterior mean $45.3846$ and variance $11.0769$; using variance $256$ gives mean $36.8493$ and variance $31.5616$. These are alternate teaching populations/priors, not estimates from the same data. A more representative calibration sample and sensitivity analysis are preferable to silently treating an imported reliability coefficient as an individual prior.

### Predicting another performance from the same person {#sec-m05-retest}

For the scalar model above, a new same-person performance redraws only independent noise. Integrating $Y_2\mid\tau\sim N(\tau,36)$ over the posterior gives
$Y_2\mid y\sim N(40.4,59.04)$: variance $23.04+36$. The central predictive interval is approximately $[25.3401,55.4599]$, wider than the latent interval because future noise is added. Joint normality or direct integration establishes the normal law; adding variances alone would not establish it in a non-Gaussian model.

### A frequentist prediction region for the same repeat kernel {#sec-m05-gaussian-prediction}

Before comparing prediction with latent uncertainty, specify what the future performance redraws. In this paragraph fix $h$ and observe independent $Y_1,Y_2\mid h\sim N_p(\nu+\Lambda h,R)$, with all measurement parameters supplied. The **entire residual $R$ is redrawn**. In the earlier factor model with $R=\Psi_S+\Theta$, that would include fresh specificity, rather than a retest retaining the same $S$.

Using the projector $P$ onto $\operatorname{col}(R^{-1/2}\Lambda)$, take $P=0$ at rank zero and define

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 41; scroll horizontally"}

$$
\begin{aligned}
\widehat y_2&=\nu+R^{1/2}P R^{-1/2}(Y_1-\nu),\\
W_F&=R^{1/2}(I_p+P)R^{1/2}.
\end{aligned}
$$ {#eq-m05-likelihood-predictor}

::::

The prediction region $\{z:(z-\widehat y_2)^TW_F^{-1}(z-\widehat y_2)\le\chi^2_{p,1-\alpha}\}$ has coverage $1-\alpha$ for $Y_2$ at every fixed $h$, averaged over both independent performances. Indeed, projection preserves the whitened true mean in its column space, so the prediction error is a zero-mean Gaussian with covariance $W_F$ from its two independent errors. This matrix is positive definite even if $\Lambda$ is deficient. When $\Lambda$ has full column rank, $\widehat y_2=\nu+\Lambda\widehat h$ and $W_F=R+\Lambda M^{-1}\Lambda^T$. When $\Lambda=I_p$, it reduces to $\widehat y_2=Y_1$, $W_F=2R$. Fixed-$h$ repeated-pair coverage is not constant conditional on a particular realized $Y_1$.

For the **same likelihood and future response**, the proper Gaussian prior gives posterior prediction

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 42; scroll horizontally"}

$$
Y_2\mid Y_1=y\sim N_p(\nu+\Lambda m_H(y),
R+\Lambda V_H\Lambda^T).
$$ {#eq-m05-latent-kernel-prediction}

::::

This follows by integrating the linear normal mean over its already normalized posterior and adding independent new residual noise. Its central ellipsoid has the stated conditional posterior predictive probability; averaging that probability over the prior/likelihood experiment gives $1-\alpha$ joint prediction coverage. It need not have that coverage for every fixed latent target. Both procedures predict the same future scored vector, but use different constructions and guarantees.

For a retest retaining all stable person terms, use $Y_r\mid\tau\sim N_p(\tau,\Theta)$ with fixed $\tau=\nu+\Lambda h+s$ instead. The likelihood prediction region is now centered at $Y_1$ with covariance $2\Theta$. The proper population-prior retest distribution in the result below uses $m_\tau$ and $V_\tau+\Theta$. Replacing $R$ by $\Theta$ is justified here by a new fixed-$\tau$ likelihood, not by deleting specificity from the previous fixed-$h$ kernel.

In the scalar teaching model at $y=35$, fixed-$\tau$ $95\%$ likelihood prediction is approximately $[18.3692,51.6308]$, compared with the posterior predictive interval $[25.3401,55.4599]$. To examine the latter's frequentist behavior, write $r=v/(v+\sigma^2)$, posterior prediction variance $W_B=\sigma^2(1+r)$, and prediction center $m(Y_1)=m_0+r(Y_1-m_0)$. At fixed $\tau$, the prediction error has mean $(1-r)(\tau-m_0)$ and variance $W_*=\sigma^2(1+r^2)$, since it contains independent $\varepsilon_2-r\varepsilon_1$. Put $b_\tau=(1-r)(\tau-m_0)$ and $c_B=z_{1-\alpha/2}\sqrt{W_B}$. Its interval coverage is therefore

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 43; scroll horizontally"}

$$
\Phi\!\left(\frac{c_B-b_\tau}{\sqrt{W_*}}\right)
-\Phi\!\left(\frac{-c_B-b_\tau}{\sqrt{W_*}}\right).
$$ {#eq-m05-fixed-person-predictive-coverage}

::::

For $m_0=50,v=64,\sigma^2=36$ and nominal $.95$, this is approximately $.965492,.910418,.724937$ at $\tau=50,35,20$. It tends to zero for targets far from the fixed prior center; its average over the declared prior is $.95$ by iterated predictive probability. These are mathematical comparisons of replication predictions, not clinical change criteria or evidence about practice effects.

The scalar teaching model has now produced four nominal $95\%$ intervals from the same score. They answer different questions: the latent intervals cover $\tau$, while prediction intervals cover $Y_2$. Sampling coverage at fixed $\tau$ repeats $Y_1$ and, for prediction, $Y_2$ as well.

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 5; scroll horizontally"}

| Interval | Target | What repeats, or what is conditioned on | After $y=35$ | Sampling coverage at fixed $\tau$ |
|---|---|---|---|---|
| Likelihood confidence | Latent expectation $\tau$ | New noise at fixed $\tau$ | $[23.24,46.76]$ | $.95$ at every $\tau$ |
| Credible | Latent expectation $\tau$ | The observed score and the prior $N(50,64)$ | $[30.99,49.81]$ | $.9857,.8516,.3585$ at $\tau=50,35,20$; $.95$ averaged over the prior |
| Likelihood prediction | Next score $Y_2$ | New noise in both scores at fixed $\tau$ | $[18.37,51.63]$ | $.95$ at every $\tau$ |
| Posterior predictive | Next score $Y_2$ | The observed score and the prior | $[25.34,55.46]$ | $.9655,.9104,.7249$ at $\tau=50,35,20$; $.95$ averaged over the prior |

::::

None of the four is a mistaken version of another. A statement about this person's expected score that must hold whatever that score is calls for the confidence construction. When the population prior is a defensible description of the people to whom the person is compared, the credible interval summarizes the latent target given the score, but its retest coverage falls for people far from the prior center. Prediction intervals are wider than the corresponding latent intervals because the next score adds its own noise. @fig-m05-interval-coverage draws both comparisons. Panel A fixes the observed score $y=35$. Panel B varies the true expectation $\tau$ and averages over the relevant repeated data; it does not condition on that observed score.

::: {#fig-m05-interval-coverage .m05-content-figure fig-alt="Panel A. Four 95% interval bars on a score axis from 10 to 66 after an observed score of 35, with prior mean 50, stable variance 64 and noise variance 36. From top: credible interval for the expected score, 31.0 to 49.8; confidence interval for the expected score, 23.2 to 46.8; posterior predictive interval for the next score, 25.3 to 55.5; likelihood prediction interval, 18.4 to 51.6. Filled centers denote posterior mean 40.4; open squares denote observed score 35. A dashed vertical line marks 35 and a dot-dash line marks prior mean 50. These intervals follow one observed input; they are not sampling coverage curves. Panel B. Sampling coverage from 0 to 1 versus the fixed true expected score from 0 to 100. Confidence and likelihood prediction coincide exactly at 0.95 on one solid line. The dashed credible curve peaks near 0.99 at 50 and is about 0.36 at 20; the dotted posterior predictive curve peaks near 0.97 and is about 0.72 at 20. Markers show 20, 35 and 50. The gray prior shape is scaled for illustration, not another coverage probability. Coverage repeats the first performance and also the future performance for prediction; it does not condition on the observed score of 35."}

<div class="m05-figure-panels">
<div><a href="figures/m05-interval-1.png" aria-label="Open full-size measurement interval panel 1"><img src="figures/m05-interval-1.png" alt="Panel A. Four 95% interval bars on a score axis from 10 to 66 after an observed score of 35, with prior mean 50, stable variance 64 and noise variance 36. From top: credible interval for the expected score, 31.0 to 49.8; confidence interval for the expected score, 23.2 to 46.8; posterior predictive interval for the next score, 25.3 to 55.5; likelihood prediction interval, 18.4 to 51.6. Filled centers denote posterior mean 40.4; open squares denote observed score 35. A dashed vertical line marks 35 and a dot-dash line marks prior mean 50. These intervals follow one observed input; they are not sampling coverage curves." /></a></div>
<div><a href="figures/m05-interval-2.png" aria-label="Open full-size measurement interval panel 2"><img src="figures/m05-interval-2.png" alt="Panel B. Sampling coverage from 0 to 1 versus the fixed true expected score from 0 to 100. Confidence and likelihood prediction coincide exactly at 0.95 on one solid line. The dashed credible curve peaks near 0.99 at 50 and is about 0.36 at 20; the dotted posterior predictive curve peaks near 0.97 and is about 0.72 at 20. Markers show 20, 35 and 50. The gray prior shape is scaled for illustration, not another coverage probability. Coverage repeats the first performance and also the future performance for prediction; it does not condition on the observed score of 35." /></a></div>
</div>

Four nominal $95\%$ procedures under the supplied synthetic scalar model $Y\mid\tau\sim N(\tau,36)$ and proper population prior $\tau\sim N(50,64)$. **A.** After observing 35, the confidence and likelihood prediction intervals are centered at 35 (open squares); the credible and posterior predictive intervals are centered at the posterior mean 40.4 (filled circles). The targets are the expected score and the next performance, respectively. **B.** At each fixed true expectation, sampling coverage repeats the first performance and, for prediction, the future performance as well. Confidence and likelihood prediction coincide at .95 on one solid line. Credible and posterior predictive coverage vary with the true expectation and average to .95 over the declared prior; its gray shape is rescaled only to show population weighting. These are model calculations, not clinical change criteria or disease probabilities. Each panel links to its full-resolution image.

:::

::: {#prp-m05-stable-retest}
## Stable-specific prediction versus fresh specificity

In the factor model assume mutually independent $H\sim N_q(h_0,\Omega)$, $S\sim N_p(0,\Psi_S)$ and $\varepsilon_r\sim N_p(0,\Theta)$, with independent errors across replications. Let $K_\tau=B+\Psi_S\succ0$, $\Theta\succ0$, $\mu=\nu+\Lambda h_0$ and $\Sigma=K_\tau+\Theta$. For the same-person target $\tau=\nu+\Lambda H+S$,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 44; scroll horizontally"}

$$
\begin{aligned}
m_\tau(y)&=\mu+K_\tau\Sigma^{-1}(y-\mu),\\
V_\tau&=K_\tau-K_\tau\Sigma^{-1}K_\tau.
\end{aligned}
$$ {#eq-m05-expected-score-posterior}

::::

Then $\tau\mid y\sim N_p(m_\tau,V_\tau)$ and an independent-noise retest has law $N_p(m_\tau,V_\tau+\Theta)$. A different experiment retaining $H$ but drawing a new independent $S^*$ and new noise instead has predictive law

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 45; scroll horizontally"}

$$
N_p\{\nu+\Lambda m_H,\ \Lambda V_H\Lambda^T+\Psi_S+\Theta\},
$$ {#eq-m05-fresh-specific-prediction}

::::

where $m_H,V_H$ use $R=\Psi_S+\Theta$ in the earlier posterior.
:::

::: {.proof}
The prior for $\tau$ is $N_p(\mu,K_\tau)$ and $Y\mid\tau\sim N_p(\tau,\Theta)$. Apply the posterior calculation with identity loading to obtain $m_\tau,V_\tau$. Independent future noise adds $\Theta$ to its conditional covariance. For the fresh-specificity experiment, $H\mid y$ is normal, and the independent fresh $S^*,\varepsilon^*$ are normal, so their sum has the stated mean and covariance. Existing $S$ generally has a nonzero posterior mean given $y$; replacing it by an independent zero-mean $S^*$ changes the experiment.
:::

At $y=(35,50)^T$ in the earlier two-test synthetic population, $E(H\mid y)=-.6618$ with variance $.4706$. The same-person retest mean is approximately $(41.2040,47.7665)^T$, with predictive covariance having diagonal $57.1103$ and off-diagonal $5.3603$. Fresh specificity gives equal mean coordinates $46.0294$, diagonal covariance $80.9412$ and off-diagonal $16.9412$. A score pattern partly attributed to stable specificity persists in a retest; it does not persist when that specificity is deliberately redrawn. Neither calculation is a personal change, diagnosis or response-validity probability.

## Estimating measurement components {#sec-m05-components}

The preceding Gaussian intervals used supplied variances and loadings. Real calibration studies estimate them. Replacing a population reliability by a sample coefficient does not preserve a normal interval's coverage or posterior variance. We first give an exact benchmark for a simpler repeat design, then simultaneous frequentist bounds and a full proper Bayesian analysis of the crossed GT experiment, including estimated-component person inference. These analyses address uncertainty in the measurement model, distinct from uncertainty about a particular person's target.

### Exact benchmark: balanced one-way replication {#sec-m05-oneway}

Let $n\ge2$ independent persons each have $m\ge2$ independent replications,

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 46; scroll horizontally"}

$$
Y_{ir}=\mu+P_i+\varepsilon_{ir},\quad
P_i\overset{\mathrm{iid}}\sim N(0,a),\quad
\varepsilon_{ir}\overset{\mathrm{iid}}\sim N(0,e),
$$ {#eq-m05-oneway-model}

::::

with all effects independent, unknown fixed $\mu\in\mathbb R$, $a\ge0$ and $e>0$. The target is the population ratio $\eta=a/e$, hence the single-score reliability $\rho=\eta/(1+\eta)$ or mean-score reliability $\rho_m=m\eta/(1+m\eta)$. This is a calibration experiment over persons and replications, not a confidence procedure for an individual person's $\tau_i$. In rater-reliability language, with persons as targets and replications as judges, $\rho$ is the one-way intraclass correlation of @shrout1979intraclass for their Case 1, target variance divided by the sum of target and within-target variances [p. 423]; they also give guidelines for choosing among six forms according to the rating design and the intended use of the result.

Define the between-person and within-person mean squares

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 47; scroll horizontally"}

$$
\begin{aligned}
B&=\frac m{n-1}\sum_i(\bar Y_i-\bar Y)^2,\\
W&=\frac1{n(m-1)}\sum_{i,r}(Y_{ir}-\bar Y_i)^2,\qquad F_{\mathrm{obs}}=B/W.
\end{aligned}
$$ {#eq-m05-oneway-ms}

::::

For observed $W>0$ (probability one under the model), write $f_l,f_u$ for the $\alpha/2$ and $1-\alpha/2$ quantiles of $F_{n-1,n(m-1)}$.

::: {#prp-m05-component-confidence}
## Exact confidence set for the variance ratio

The random set

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 48; scroll horizontally"}

$$
\mathcal E(Y)=\left\{\eta\ge0:
 f_l\le\frac{F_{\mathrm{obs}}}{1+m\eta}\le f_u\right\}
$$ {#eq-m05-ratio-set}

::::

has coverage $P_{\mu,a,e}\{a/e\in\mathcal E(Y)\}=1-\alpha$, including $a=0$. If $u=(F_{\mathrm{obs}}/f_l-1)/m\ge0$, the set is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 49; scroll horizontally"}

$$
\left[\max\left\{0,\frac{F_{\mathrm{obs}}/f_u-1}{m}\right\},\ u\right].
$$ {#eq-m05-ratio-endpoints}

::::

If $u<0$, it is empty. Mapping the set through $\eta/(1+\eta)$ or $m\eta/(1+m\eta)$ gives exact confidence sets for the respective reliabilities. Replacing an empty set by $\{0\}$ changes boundary coverage.
:::

::: {.proof}
Person means are independent $N(\mu,a+e/m)$, so $(n-1)B/(e+ma)\sim\chi^2_{n-1}$. Within each person, orthogonal centered contrasts remove $P_i$ and $\mu$ and have independent normal coordinates of variance $e$. Across persons these contrast vectors are independent, giving $n(m-1)W/e\sim\chi^2_{n(m-1)}$. The mean and centered coordinates are independent Gaussian projections, hence these two sums of squares are independent. Their scaled ratio gives
$F_{\mathrm{obs}}/(1+m\eta)\sim F_{n-1,n(m-1)}$.
Inverting its central probability event proves coverage for each parameter point, including $\eta=0$. Since all divisors are positive, rearranging the two inequalities gives the stated interval intersected with $[0,\infty)$, which is empty when its untruncated upper endpoint is negative. Both reliability maps are strictly increasing and one-to-one on this domain, so inclusion of the true transformed parameter is the same event.
:::

**Synthetic mean-square example.** Supply $n=20,m=3,B=144,W=36$. These are possible teaching summaries, not observed patient data. At $\alpha=.05$, $(f_l,f_u)\approx(.428647,2.086364)$, giving $\eta\in[.305737,2.777233]$. The corresponding single-score reliability interval is approximately $[.234149,.735256]$; the three-replication mean reliability interval is $[.478409,.892838]$. The moment estimates are $\widehat a=(B-W)/m=36$, $\widehat e=36$, and single-score plug-in reliability $.50$. Its uncertainty is substantial even though the point estimate has two decimal places. Sixty scores from 20 people leave single-score reliability anywhere from about .23 to .74 at this confidence level.

If $F_{\mathrm{obs}}<f_l$, the exact set is empty. Under $a=0$ this happens with probability $\alpha/2$; forcing the set to include zero would therefore increase its boundary coverage from $1-\alpha$ to $1-\alpha/2$. An empty set signals incompatibility with the central pivot event for every allowed parameter value, not evidence of a negative population variance. When $m=1$, $W$ and this ratio experiment do not exist. Nonnormal errors or informative repeat schedules do not inherit the exact $F$ law. Mapped through $\eta/(1+\eta)$, the interval of @eq-m05-ratio-endpoints is the confidence interval of @shrout1979intraclass for their Case 1 coefficient [p. 424, eqs. 4-6] whenever its lower endpoint is nonnegative; their interval is not truncated at zero and so can extend below it.

### Finite uncertainty in all seven crossed components {#sec-m05-crossed-confidence}

The one-way pivot is a benchmark, not a solution to the crossed experiment. Return to the fully crossed Gaussian model, with $n,J,K\ge2$, $v_e>0$ and the other six variances nonnegative. The [full contrast law](#sec-m05-gt-sampling) gives seven independent $d_A MS_A/\lambda_A\sim\chi^2_{d_A}$ pivots, where $\lambda_A=E(MS_A)$. The unknown grand mean is absent from these contrasts; no assumption that $\mu$ is known is needed.

For $0<\alpha<1$, put $\epsilon=1-(1-\alpha)^{1/7}$. Define for every contrast space

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 50; scroll horizontally"}

$$
L_A=\frac{d_A MS_A}{\chi^2_{d_A,1-\epsilon/2}},\qquad
U_A=\frac{d_A MS_A}{\chi^2_{d_A,\epsilon/2}}.
$$ {#eq-m05-crossed-lambda-intervals}

::::

Each interval covers its eigenvalue with probability $1-\epsilon$; independence gives simultaneous coverage exactly $1-\alpha$ for the seven eigenvalues. Intersecting the rectangle with the nonnegative-component model preserves the event that the true parameter is included. This gives a joint confidence region for **all** components, not separate point estimates that are subsequently treated as known.

A convenient conservative calculation avoids an unverified optimization. Write $\lambda=\mathsf A\theta$ for the invertible linear map in the mean-square table, using a fixed matching order for the seven effects and components, and put $D=\mathsf A^{-1}$. Let $D^+_{ij}=\max(D_{ij},0)$ and $D^-_{ij}=\min(D_{ij},0)$. All vectors in the eigenvalue rectangle have component coordinates between

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 51; scroll horizontally"}

$$
\underline v=\max\{0,D^+L+D^-U\},\qquad
\overline v=D^+U+D^-L,
$$ {#eq-m05-crossed-component-box}

::::

with maximum taken coordinatewise. If any upper bound is below its lower bound, report the box as empty. Otherwise this box contains the true component vector with probability at least $1-\alpha$. To prove it, each positive coefficient in a row of $D$ uses its lower eigenvalue endpoint to minimize that linear functional, while each negative coefficient uses its upper endpoint; the reverse choices maximize it. Intersect with nonnegativity. The result is an **outer box**; it can contain vectors that do not map back into the original rectangle. Its coverage can be conservative. Positive residual lower bound holds with probability one under this regular experiment.

For any proposed positive integer design sizes $(J',K')$, evaluate relative error at the component lower and upper bounds, calling the results $l_{\mathrm{rel}}$ and $u_{\mathrm{rel}}$, and similarly define $l_{\mathrm{abs}},u_{\mathrm{abs}}$. Monotonicity of the variance ratios gives confidence intervals

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 52; scroll horizontally"}

$$
\begin{aligned}
\rho_{\mathrm{rel}}(J',K')&\in
\left[\frac{\underline v_P}{\underline v_P+u_{\mathrm{rel}}},
\frac{\overline v_P}{\overline v_P+l_{\mathrm{rel}}}\right],\\
\rho_{\mathrm{abs}}(J',K')&\in
\left[\frac{\underline v_P}{\underline v_P+u_{\mathrm{abs}}},
\frac{\overline v_P}{\overline v_P+l_{\mathrm{abs}}}\right].
\end{aligned}
$$ {#eq-m05-crossed-coefficient-confidence}

::::

All denominators are positive because $\underline v_e>0$. These intervals cover simultaneously over **every** considered design whenever the true components are in the box. Thus selecting a design from the calibration data does not invalidate this particular simultaneous statement, provided the box and actual design-dependent bounds are retained. It does not establish an optimal choice under clinical burden or cost. Tighter images of the original constrained region require genuine global bounds, rather than an unchecked local numerical optimum.

For a synthetic calibration with $n=20,J=4,K=2$, take the observed mean squares in table order $(e,PT,PR,TR,P,T,R)$ to be $(36,68,72,116,616,508,472)$ and grand mean 50. They happen to equal the earlier supplied model expectations, but here they are **data summaries** and the components are unknown. Compare their earlier role as [supplied expectations](#sec-m05-gt-sampling). A deterministic 160-cell vector with these summaries can be constructed: for each factor use its normalized constant vector and a normalized centered linear contrast; in each effect's tensor-product space choose the resulting unit contrast $u_A$ and set
$y=50\mathbf1+\sum_A\sqrt{d_A MS_A}\,u_A$. The seven contrasts are orthogonal, so projecting this vector recovers exactly those sums of squares. No sampled patients or random simulation is involved.

At $95\%$, $\epsilon\approx .007300832$. The component lower bounds are zero except $\underline v_e\approx22.8593$; upper bounds in order $(P,T,R,PT,PR,TR,e)$ are approximately
$(222.420,656.829,281867.137,48.269,46.703,298.892,63.210)$. The very large rater bound reflects the single rater contrast degree of freedom and this conservative simultaneous construction, not 160 independent rater observations. The calculations use unrounded quantiles; the printed component entries are descriptive decimal approximations.

At the original design one can sharpen the displayed coefficient bound analytically. The mean-square equations give
$\rho_{\mathrm{rel}}(J,K)=1-(\lambda_{PT}+\lambda_{PR}-\lambda_e)/\lambda_P$. Nonnegative interactions imply $\lambda_e\le\min(\lambda_{PT},\lambda_{PR})$, so on the joint coverage event
$\rho_{\mathrm{rel}}(J,K)\le1-\max(L_{PT},L_{PR})/U_P\approx .975930$; also $\rho_{\mathrm{abs}}\le\rho_{\mathrm{rel}}$. Combining this with the box bounds gives the following conservative simultaneous intervals, with upper endpoints rounded outward:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 6; scroll horizontally"}

| Proposed design | Confidence interval for $\rho_{\mathrm{rel}}$ | Confidence interval for $\rho_{\mathrm{abs}}$ |
|---|---|---|
| $J'=4,K'=2$ | $[0,.976]$ | $[0,.976]$ |
| $J'=8,K'=2$ | $[0,.994]$ | $[0,.994]$ |
| $J'=4,K'=4$ | $[0,.994]$ | $[0,.994]$ |

::::

These are evaluated finite-sample bounds for the full crossed design, rather than a transplanted one-way interval. They are broad and need not be the narrowest valid bounds. More independent task/rater levels, a larger person sample, or justified restrictions can improve different parts of the problem. A proper prior provides a different inferential construction, developed next, not an automatic frequentist guarantee.

### A proper component posterior for the same experiments {#sec-m05-component-bayes}

For the crossed GT data, stack all $N=nJK$ cells into $y$. For each effect $A\in\{P,T,R,PT,PR,TR\}$ let $Z_A$ have one column per level of that effect and a $1$ in the column affecting each cell. Then the Gaussian random-effects version of the earlier model has **marginal calibration likelihood**

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 53; scroll horizontally"}

$$
p(y\mid\mu,\theta)
=(2\pi)^{-N/2}|V_\theta|^{-1/2}
 \exp\{-\tfrac12(y-\mu\mathbf1)^TV_\theta^{-1}(y-\mu\mathbf1)\},
$$ {#eq-m05-component-likelihood}

::::

where

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 54; scroll horizontally"}

$$
V_\theta=\sum_A v_A Z_AZ_A^T+v_eI_N,\qquad
\theta=(v_P,v_T,v_R,v_{PT},v_{PR},v_{TR},v_e).
$$ {#eq-m05-component-covariance}

::::

Effects have been integrated out, rather than estimated and then treated as observed. The same construction for the one-way experiment uses only $Z_P$ and $v_eI$.

Specify independent proper priors $\mu\sim N(m_0,s_0^2)$, $s_0^2>0$, and $v_A\sim\operatorname{IG}(a_A,b_A)$ for every variance including $v_e$, with $a_A>2,b_A>0$. Our inverse-gamma convention is the density

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 55; scroll horizontally"}

$$
\pi_A(v)=\frac{b_A^{a_A}}{\Gamma(a_A)}v^{-a_A-1}e^{-b_A/v},\qquad v>0,
$$ {#eq-m05-ig-density}

::::

relative to $dv$. Substituting $x=b_A/v$ into the moment integral gives $E(v^r)=b_A^r\Gamma(a_A-r)/\Gamma(a_A)$ for $r<a_A$. Its mean is therefore $b_A/(a_A-1)$; $b_A$ has squared-score units. The shape restriction ensures finite first and second prior moments, beyond what is needed for propriety. Hyperparameters must be fixed before using these calibration outcomes, or their estimation must be included. For a concrete teaching choice, use $a_A=3$, $b_A=2c_A$, where $c_A$ are the seven positive values in the GT example, and $m_0=50,s_0=20$. These values center prior means on the earlier supplied variances; they are not new empirical estimates. A scaled-score recoding requires recoding these hyperparameters as well.

::: {#prp-m05-component-posterior}
## Proper posterior and propagation to coefficients and person targets

For finite $y$ and the stated priors, the posterior

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 56; scroll horizontally"}

$$
\pi(\mu,\theta\mid y)
=\frac{p(y\mid\mu,\theta)\pi(\mu)\prod_A\pi_A(v_A)}
{\displaystyle\int p(y\mid u,t)\pi(u)\prod_A\pi_A(t_A)\,du\,dt}
$$ {#eq-m05-component-posterior}

::::

is proper. Posterior distributions for $\rho_{\mathrm{rel}}(J',K')$ and $\rho_{\mathrm{abs}}(J',K')$ use the earlier variance-ratio functions at the proposed new design sizes $J',K'$. For the one-way experiment the same posterior construction induces a distribution for $\eta=a/e$ and its reliability maps, using the same target as the confidence set, without asserting equal tails or coverage.

For a calibrated person $i$ in the crossed data, define $b_i=\operatorname{Cov}(P_i,y\mid\mu,\theta)=v_P z_i$, where $z_i$ indicates that person's cells. Conditional on $\mu,\theta,y$, the target $\tau_i=\mu+P_i$ has Gaussian mean and variance

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 57; scroll horizontally"}

$$
\begin{aligned}
m_i(\mu,\theta)&=\mu+b_i^TV_\theta^{-1}(y-\mu\mathbf1),\\
V_i(\theta)&=v_P-b_i^TV_\theta^{-1}b_i.
\end{aligned}
$$ {#eq-m05-component-person}

::::

Integrating these conditional Gaussian laws against $\pi(\mu,\theta\mid y)$ gives the full person-target posterior. Its variance is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 58; scroll horizontally"}

$$
\operatorname{Var}(\tau_i\mid y)
=E\{V_i(\theta)\mid y\}
 +\operatorname{Var}\{m_i(\mu,\theta)\mid y\}.
$$ {#eq-m05-total-uncertainty}

::::
:::

::: {.proof}
Every $Z_AZ_A^T$ is positive semidefinite and $v_e>0$, so $V_\theta\succeq v_eI_N$ and $|V_\theta|\ge v_e^N$. The nonnegative quadratic exponent therefore bounds the likelihood above by $(2\pi v_e)^{-N/2}$. All other priors integrate to one, and $E(v_e^{-N/2})$ under the inverse-gamma prior is finite: substituting $x=b_e/v_e$ gives $b_e^{-N/2}\Gamma(a_e+N/2)/\Gamma(a_e)$. The posterior denominator is finite, and it is positive because the integrand is positive on the prior support. This proves propriety without requiring a falsely claimed conjugate independent-component posterior.

Given $\mu,\theta$, the pair $(P_i,y)$ is jointly Gaussian with covariance blocks $v_P,b_i,V_\theta$. Completing the square, or applying the preceding Gaussian conditional calculation, gives the stated mean/variance. The full posterior is their mixture by iterated conditioning. To justify finite person-target second moments, condition on the six nonresidual random-effect arrays and the parameters, leaving the cell residuals Gaussian with covariance $v_eI_N$. Their conditional observation likelihood is bounded by $(2\pi v_e)^{-N/2}$. The prior second moment of $\mu+P_i$ is finite and independent of $v_e$ under these proper priors, so integrating that likelihood times $(\mu+P_i)^2$ is finite. The law of total variance therefore applies and gives the decomposition. Pushing the proper posterior through a measurable coefficient function defines its proper distribution.
:::

The extra between-parameter term is nonnegative, but the mixture variance need not exceed $V_i$ evaluated at an arbitrary point estimate: its first term is also averaged over different parameters. A mixture of normals need not itself be normal; its equal-tail intervals require its actual CDF or posterior integration. A posterior mean reliability is generally different from reliability calculated from posterior mean components, because the ratio is nonlinear.

For a completely **new** person without measurement data, calibration alone yields a calibration-informed population predictive target distribution; it does not estimate a person-specific deviation. For an observed new person's latent inference, the joint posterior must include that case's measurement likelihood as well as the independent calibration likelihood. Reference-only parameter learning and joint case/calibration learning are different conditioning conventions and must be declared.

For a calibrated person's new average over entirely fresh tasks and raters, retain $P_i$ but redraw all facet terms. Conditional on $\mu,\theta,\tau_i$, that average is normal with mean $\tau_i$ and variance $v_{\mathrm{abs}}(\theta;J',K')$. Its full predictive variance is
$E\{V_i(\theta)+v_{\mathrm{abs}}(\theta;J',K')\mid y\}+\operatorname{Var}\{m_i(\mu,\theta)\mid y\}$.
Reusing tasks or raters retains some effects and requires their joint posterior, so this fresh-facet formula cannot be reused unchanged.

The likelihood, posterior-integral and moment representations are exact under the stated Gaussian design and priors. The following worked examples evaluate these integrals and explicitly distinguish numerical approximation from the proved distributional statements. The positive inverse-gamma priors exclude exact zero components. A scientific point-null analysis needs an explicit point mass or another declared boundary treatment; a continuous prior cannot supply posterior mass at zero. If the design does not separate two components, their likelihood may depend only on their sum; a proper posterior then resolves their split through prior assumptions rather than new identification. The single-occasion stable/transient equivalence is one example. Sampling assumptions, facet independence and prior sensitivity require scrutiny in actual use.

### A proper posterior at the same one-way benchmark {#sec-m05-oneway-posterior-example}

The unknown-variance likelihood can be evaluated without substituting the moment estimates. For the one-way summaries $n=20,m=3,B=144,W=36$, additionally stipulate grand mean 50. Use independent proper priors $a\sim\operatorname{IG}(3,128)$, $e\sim\operatorname{IG}(3,72)$ and $\mu\sim N(50,400)$. Their prior variance means 64 and 36 come from the earlier supplied CTT teaching population; they are declared assumptions, not hyperparameters estimated by this calibration. Write $\varphi(x;b,v)$ for a univariate normal density with mean $b$ and variance $v$.

Integrating $\mu$, the one-way likelihood for $(a,e)$ is proportional to

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 59; scroll horizontally"}

$$
\begin{aligned}
&(e+ma)^{-(n-1)/2}
 \exp\!\left\{-\frac{(n-1)B}{2(e+ma)}\right\}\\
&\quad\times e^{-n(m-1)/2}
 \exp\!\left\{-\frac{n(m-1)W}{2e}\right\}
 \varphi\!\left(\bar Y;50,400+\frac{e+ma}{nm}\right).
\end{aligned}
$$ {#eq-m05-oneway-marginal-likelihood}

::::

Here $e^{-n(m-1)/2}$ is a power of the **variance parameter $e$**, not an exponential with the Euler constant. The expression follows from the independent between/within contrast laws and the grand mean's variance $(e+ma)/(nm)$. Multiplying by the two inverse-gamma densities gives a nonconjugate joint posterior; propriety follows from the earlier residual-variance likelihood bound and finite inverse-gamma negative moments. Integrate the ratio $a/(a+e)$ at each parameter pair to obtain the posterior for the same single-score reliability as the confidence set.

Deterministic two-dimensional quadrature gives posterior mean approximately $.526638$, median $.528446$ and central $95\%$ credible interval $[.324946,.718553]$, compared with the exact confidence interval $[.234149,.735256]$. Independent prior importance integration checks these values and the normalization; neither interval is an individual person's precision. This example uses uncertain variances and mean, not a known-reliability Gaussian shortcut.

### Evaluating the full crossed calibration posterior {#sec-m05-crossed-posterior-example}

Now use the actual crossed summaries above and the seven original component priors $\operatorname{IG}(3,2c_A)$, $c=(64,9,4,16,9,4,36)$, with $\mu\sim N(50,400)$. These teaching priors were specified in the model; the synthetic data were constructed afterward. Do not reinterpret their centers as estimates of a real instrument's prior from these same outcomes.

The Gaussian contrast decomposition gives an efficient exact likelihood after integrating the uncertain mean:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 60; scroll horizontally"}

$$
\begin{aligned}
L(\theta;y)&\propto
\varphi(\bar Y;m_0,s_0^2+v_0(\theta))\\
&\quad\times\prod_A\lambda_A(\theta)^{-d_A/2}
\exp\!\left\{-\frac{d_A MS_A}{2\lambda_A(\theta)}\right\}.
\end{aligned}
$$ {#eq-m05-crossed-spectral-likelihood}

::::

The product is over the seven contrast spaces; $v_0$ is the grand-mean variance derived earlier. The omitted factor is independent of $\theta$. This is the same full marginal likelihood as the dense $N$-coordinate covariance expression, not a fit to independent person averages that drops shared facets. The posterior components remain coupled through the seven linear eigenvalues and $v_0$; independent inverse-gamma priors do not make them independently conjugate posterior variances.

For completeness, conditional mean-parameter uncertainty is

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 61; scroll horizontally"}

$$
\begin{aligned}
s_\mu^2(\theta)&=(s_0^{-2}+v_0(\theta)^{-1})^{-1},\\
m_\mu(\theta)&=s_\mu^2(\theta)
\{m_0/s_0^2+\bar Y/v_0(\theta)\}.
\end{aligned}
$$ {#eq-m05-crossed-mean-posterior}

::::

At these data $m_\mu=50$ because the prior and observed grand means coincide, but $s_\mu^2$ is positive and varies across the component posterior. It is not legitimate to treat the population mean as supplied merely because its posterior center remains 50.

Numerically integrating this proper seven-component posterior gives:

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 7; scroll horizontally"}

| Component prior | Target | Posterior mean | Central $95\%$ interval |
|---|---|---:|---|
| $\operatorname{IG}(3,2c_A)$ | $\rho_{\mathrm{rel}}(4,2)$ | $.821$ | $[.683,.914]$ |
| $\operatorname{IG}(3,2c_A)$ | $\rho_{\mathrm{abs}}(4,2)$ | $.772$ | $[.616,.885]$ |
| $\operatorname{IG}(8,7c_A)$ | $\rho_{\mathrm{rel}}(4,2)$ | $.823$ | $[.724,.898]$ |
| $\operatorname{IG}(8,7c_A)$ | $\rho_{\mathrm{abs}}(4,2)$ | $.773$ | $[.662,.864]$ |

::::

The second prior has the same component means $c_A$ and less prior dispersion. Both are proper and assign probability zero to exact zero components; positive lower credible endpoints do not constitute point-null tests. For the first prior, inserting the **posterior mean components** instead would give about $.834$ and $.786$, rather than the posterior means $.821$ and $.772$. The nonlinear ratio must be integrated when it is the target.

Under the first prior, increasing tasks to eight gives posterior mean coefficients about $(\rho_{\mathrm{rel}},\rho_{\mathrm{abs}})=(.873,.832)$; increasing raters to four at four tasks gives about $(.876,.834)$. Yet the posterior probabilities that the latter design has the larger relative and absolute coefficients are only about $.556$ and $.517$. Indeed, direct subtraction of the two error formulas shows the relative ordering depends on $v_{PR}>v_{PT}/2$, and the absolute ordering on $v_{PR}+v_R>(v_{PT}+v_T)/2$. A small difference between plug-in design predictions is not a confident design ordering. The second prior changes these probabilities to about $.605$ and $.544$. Clinical time, burden, feasible raters and outcome utility remain additional decision information.

These are approximate evaluations of a proved posterior integral. Eight separately scrambled, power-of-two prior integrations used $2^{20}$ points each for the first prior and $2^{18}$ each for the second. For the first prior, the observed range across integrations was below $.000012$ for each original-design coefficient mean and $.0004$ for its reported coefficient quantile endpoints. The design-ordering probability ranges were about $.0006$ and $.0013$. A separate rejection sampler produced 100000 independent component-posterior draws: each contrast likelihood is maximized at its observed mean square, and the marginal grand-mean density is bounded using $s_0^2>0$, supplying a finite likelihood envelope. Accepting a prior draw with likelihood divided by that envelope gives density proportional to prior times likelihood, which proves the sampler's target. Its coefficient/person CDF checks agreed with the integration at their observed Monte Carlo error level. This is numerical posterior evaluation, not proof of a confidence theorem, evidence for Gaussianity, or simulated clinical validation.

### A calibrated person's mixture, and an independent new person {#sec-m05-fitted-person-example}

For person 1 in the constructed crossed dataset, the observed $4\times2$ average is approximately 35.9092. The target remains $\tau_1=\mu+P_1$, averaging over entirely new tasks and raters. Integrating the conditional normal law in the component result, including the uncertain $\mu$, gives posterior mean approximately 38.43, variance 15.46 and central $95\%$ interval $[30.74,46.20]$. After integrating $\mu$ at each component vector, the conditional person law is normal. Its average variance is about 14.755, and the variance of its conditional means is about .703. The full normal-mixture CDF supplies the quantiles; a normal fit using only the two printed moments is not substituted.

There is a useful local bridge to the relative coefficient. Split the person-cell indicator into its grand-mean and person-contrast projections. The covariance acts as $Nv_0$ and $\lambda_P$ on those spaces. Since $m_\mu=\bar Y=50$ in this example, the conditional target mean becomes $50+(JKv_P/\lambda_P)(\bar Y_1-50)$. The mean-square identities give $JKv_P/\lambda_P=\rho_{\mathrm{rel}}(4,2)$, so the full posterior mean is exactly $50+E(\rho_{\mathrm{rel}}(4,2)\mid y)(\bar Y_1-50)$ before decimal rounding. This gain follows from the balanced Gaussian shared-facet experiment and its prior, rather than from attaching an imported reliability to any observed score.

At the component moment estimates $(64,9,4,16,9,4,36)$, the analogous conditional posterior retaining uncertainty in $\mu$ has variance about 15.594. The full mixture variance 15.46 is slightly smaller, despite its positive between-component term: the within-component variance is averaged at different parameter values. Thus propagating parameter uncertainty is essential but does not imply a universal inequality relative to any arbitrary plug-in posterior variance.

Now exclude a **new** person and their entirely new task/rater levels from that calibration. Fix the case design sizes before observing the case. Observe their $J'\times K'$ average $x$, with fixed-person likelihood
$x\mid\tau,\theta\sim N(\tau,v_{\mathrm{abs}}(\theta;J',K'))$. Both a confidence construction and a proper posterior can target this same operational expectation. This average is a different observation experiment from the earlier single score with noise variance 36.

For a frequentist interval at level $1-\alpha$, choose $\delta=1-\sqrt{1-\alpha}$. Use the crossed component confidence box at error $\delta$, and let $U_{\mathrm{abs}}$ be the resulting upper absolute-error variance at the new design. Then

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 62; scroll horizontally"}

$$
\left[x-z_{1-\delta/2}\sqrt{U_{\mathrm{abs}}},
 x+z_{1-\delta/2}\sqrt{U_{\mathrm{abs}}}\right]
$$ {#eq-m05-new-person-component-confidence}

::::

covers every fixed $\tau$ with probability at least $1-\alpha$, repeating calibration and the independent new person's facet errors. To prove it, the true components are in the box with probability at least $1-\delta$. Independently, the standardized case error lies between the standard normal quantiles with probability $1-\delta$. On their joint event the bound on $v_{\mathrm{abs}}$ makes the displayed interval include $\tau$. The product of those probabilities is at least $1-\alpha$. Report an empty interval if the component box is empty. Reusing calibration tasks or raters in the case would change the independence experiment and require another argument.

For the Bayesian analysis, add a population prior $\tau\mid\mu,\theta\sim N(\mu,v_P)$ and include this case likelihood in the joint posterior. Integrating the calibration mean parameter first gives $\tau\mid\theta,y\sim N(m_\mu,A_\theta)$, where $A_\theta=v_P+s_\mu^2(\theta)$. The case updates the component posterior by the additional marginal density

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 63; scroll horizontally"}

$$
\begin{aligned}
\pi(\theta\mid y,x)&\propto\pi(\theta\mid y)\\
&\quad\times\varphi\{x;m_\mu(\theta),A_\theta+v_{\mathrm{abs}}(\theta;J',K')\}.
\end{aligned}
$$ {#eq-m05-new-person-component-update}

::::

At each such component vector, put $b_\theta=v_{\mathrm{abs}}(\theta;J',K')$. Completing the normal square gives

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 equation 64; scroll horizontally"}

$$
\begin{aligned}
m_*(\theta)&=m_\mu+
\frac{A_\theta}{A_\theta+b_\theta}(x-m_\mu),\\
V_*(\theta)&=\frac{A_\theta b_\theta}{A_\theta+b_\theta},\\
\tau\mid\theta,y,x&\sim N(m_*(\theta),V_*(\theta)).
\end{aligned}
$$ {#eq-m05-new-person-target-mixture}

::::

Integrate this normal law against the **case-updated** component posterior. Its finite positive normalizer is justified, rather than assumed: $b_\theta\ge v_e/(J'K')$ bounds the case density by a constant times $v_e^{-1/2}$; combine the earlier calibration bound with the inverse-gamma negative moment of order $(N+1)/2$. Positivity is immediate on prior support. The same bound times the finite prior second moment of $\mu+P_{\mathrm{new}}$, independent of $v_e$, establishes finite target second moments. Fresh-task/rater prediction adds $b_\theta$ at each conditional component value and uses the same updated mixing distribution. Prior finite component moments and the same bound justify its finite variance.

For a new $4\times2$ average $x=35$ and the first crossed prior, full inference gives target posterior mean about 37.95, variance 14.38 and central $95\%$ interval $[30.54,45.44]$. A future entirely fresh $4\times2$ average retaining this same person target has predictive variance about 31.49 and central interval $[27.00,49.06]$. These include uncertainty in the calibration components and population mean, the latent person deviation, the case's contribution to component learning and, for prediction, new facet error. They are not a new person's posterior obtained from calibration alone.

For comparison, the conservative fixed-person confidence construction above gives approximately $[-1641.68,1711.68]$ at $95\%$, because its simultaneous calibration bound on absolute-error variance is about 562046 with only two sampled raters. This extreme width concerns the stated Gaussian model and conservative procedure; it is not a lower bound on all attainable precision. More facet levels, a sharper justified confidence construction or an explicitly different model can improve it. The much narrower credible interval also uses the proper population/component priors; it does not acquire a uniform fixed-person guarantee by being narrower. None of these teaching calculations establishes an instrument's clinical precision or a disease probability.

## Lookup guide: choose the replication target before the coefficient {#sec-m05-guide}

The same observed score can enter several experiments. Choose the target before choosing a coefficient or interval. The table collects the chapter's questions with the target and design each result assumes; each entry links to the unit that states its conditions.

:::: {.m05-scroll role="group" tabindex="0" aria-label="M05 table 8; scroll horizontally"}

| Reader question and development | Target and design |
|---|---|
| What remains stable over the intended repeats? [CTT](#sec-m05-ctt) | Person expectation under a declared universe; population and conditional error moments |
| Can a bounded score support person inference? [Binary replication](#sec-m05-binary-replication) | The same expected binary response under repeated sampling and a proper beta prior |
| Can people be ranked using sampled tasks and raters? [Relative GT](#sec-m05-gt) | Stable person variance relative to difference error under shared facets |
| How precise is an absolute score against a fixed threshold? [Absolute GT](#sec-m05-gt) | Error including shared task/rater offsets, over newly sampled facets |
| Does repeatability measure the intended factor? [Factor bridge](#sec-m05-factor) | Common-factor versus all stable variance; explicit factor and specificity assumptions |
| Can the data distinguish trait, state and noise? [Identification](#sec-m05-identification) and [state calibration](#sec-m05-state-calibration) | Sharp compatible variance shares; finite calibration of identified totals and prior sensitivity of unobserved splits |
| What is the latent attribute after seeing a score? [Gaussian inference](#sec-m05-gaussian) and [rank](#sec-m05-rank-confidence) | Proper population-prior posterior and fixed-target likelihood confidence, including unidentified directions, with known measurement parameters |
| What could this person's next score be? [Prediction](#sec-m05-gaussian-prediction) and [stable retests](#prp-m05-stable-retest) | Confidence or posterior prediction with an explicit choice of retained stable terms and redrawn residuals |
| How uncertain are the fitted measurement components? [Component uncertainty](#sec-m05-components) | One-way and full crossed calibration; simultaneous confidence bounds and evaluated proper component posteriors |
| What does fitted calibration imply for a person? [Person inference](#sec-m05-fitted-person-example) | A calibrated person's posterior, or an independent new person's confidence/posterior/prediction with the case likelihood included |

::::

The chapter began with moment identities, then adds explicit sampling distributions where inference needs them. The binary repeat experiment does not require a Gaussian score model. The state model separates uncertainty in estimable totals from unidentified internal splits. The Gaussian latent unit supplies individual-target distributions with **known** measurement parameters; the final unit estimates components from calibration and propagates their uncertainty into coefficients, design comparisons and person targets. Exact algebra, named probability laws and exact posterior integrals are distinguished from numerical evaluations. The synthetic examples are checks and illustrations, not instrument norms or clinical cutoffs.

## What more measurement can establish {#sec-m05-boundaries}

Return to the score of 35. Under the running single-score population, the person's expected score on a repeat of the declared kind has posterior mean 40.4 and a $95\%$ credible interval from about 31.0 to 49.8; a fixed-target $95\%$ confidence interval runs from about 23.2 to 46.8; and a $95\%$ posterior predictive interval for the next score runs from about 25.3 to 55.5. Which of these belongs in an interpretation depends on the declared repeat, on whether a population prior is part of the claim, and on whether the target is an expected score or the next performance. When the measurement components are themselves estimated, their uncertainty enters every one of these intervals.

The chapter's models answer questions about replication expectations, variance ratios and declared latent attributes. They explain why a stable score can remain a poor measure of an intended factor, why a relative ranking can be dependable while an absolute threshold is sensitive to facets, and why a prior-based latent interval differs from a fixed-target confidence interval or future-performance interval. A repeated-score law may identify stable and changing totals while leaving the intended trait or state share only bounded; the finite calibration example shows why estimating those totals more precisely cannot resolve the internal split. Likewise, a proper latent posterior along a null loading direction depends on prior assumptions rather than likelihood identification.

Calibration uncertainty is part of the experiment when components are estimated. The crossed examples propagate it through population coefficients, alternative designs and individual targets. A person's observed case also contributes its likelihood to the joint posterior; calibration alone describes an unobserved new person's population target distribution. Confidence coverage, posterior credibility and future-performance probability retain their stated sampling or prior conditioning. Their numerical widths do not establish a universal ordering of methods or a clinically adequate precision.

Additional repeat, crossed-facet, multi-indicator and within-occasion data can resolve different ambiguities. They cannot replace construct definitions, representative populations or an explicit administration protocol. Observed repeatability does not establish a unique mechanism, an acquired decline, response validity, disease or a useful clinical action. Detailed item scoring belongs to [Items and scoring](06-items-and-scoring.md#sec-items-and-scoring); comparability to [Norms, invariance and linking](07-norms-invariance-linking.md#sec-norms); longitudinal targets to [Change](08-change.md#sec-change). Clinical outcomes/actions and validation of fitted design recommendations need their own data and methods in the later chapters.
