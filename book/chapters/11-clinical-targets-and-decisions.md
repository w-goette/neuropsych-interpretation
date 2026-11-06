# Clinical targets and decisions {#sec-clinical-targets}

```{=html}
<style>
.m11-page #quarto-content > *, .m11-page main.content { min-width: 0; }
.m11-scroll { max-width: 100%; min-width: 0; overflow-x: auto; }
.m11-scroll .math.display { overflow: visible; }
.m11-scroll mjx-container[display="true"] { max-width: none; width: max-content; min-width: 100%; overflow: visible; }
.m11-scroll:focus-visible, .m11-page .math.inline:focus-visible { outline: 3px solid var(--book-focus); outline-offset: 3px; }
.m11-page .math.inline { display: inline-block; max-width: 100%; overflow-x: auto; overflow-y: hidden; padding-block: .15em; vertical-align: middle; }
.m11-figure-panels { display: grid; gap: .6rem; }
.m11-figure-panels p { margin: 0; }
.m11-figure-panels img { width: 100%; height: auto; }
</style>

<script>
document.body.classList.add('m11-page');
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
      if (!(element instanceof HTMLElement) || !element.matches('.m11-scroll, .math.inline[role="group"]')) return;
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

## One positive flag, several questions {#sec-m11-question}

Start with one record. In a synthetic validation study, a screening rule fixed in advance on a cognitive battery is positive for 16 of 20 people whose target condition was verified and for 4 of 40 verified people without it. A separate representative sample from the intended referral population contains 10 people with the target among 100. A new person from that referral population is assessed, and the rule is positive.

Before reading on, predict the chance that this person has the target condition. The flag is positive for 80% of people with the target and for only 10% of people without it. A tempting answer is .8, the flag's sensitivity.

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 1; scroll horizontally"}

| Question about the flagged person | Answer from this synthetic record | What the answer needed | Developed in |
|---|---|---|---|
| How unusual is a positive flag among people without the target? | About 1 in 10 (4 of 40) | Verified target-negative people assessed under the same protocol | [Rarity](#sec-m11-rarity) |
| What is the probability that this person has the target? | $51/116\approx.44$ | Both class-specific flag rates, the referral-population prevalence, and priors for all three | [A new positive case](#sec-m11-case-update) |
| How precisely is the population positive-result risk known? | Posterior mean .45 with central .95 credible interval [.22, .72]; a .95 confidence interval built from simultaneous binomial intervals, [.08, .92] | A proper prior, or a repeated-sampling construction, for the same three samples | [Confidence](#sec-m11-risk-confidence), [posterior](#sec-m11-risk-posterior) |
| Which action has the lower expected loss? | The alternative action if a missed target costs four times a false alarm; the baseline action if the costs are reversed; under the first costs, an ideal referral costing .2 beats both | Declared actions and consequences | [From the flag to an action](#sec-m11-flag-to-action) |
| Would the same probability hold in another clinic? | Not determined by these data | A transport model and information from the other population | [Transport](#sec-m11-transport) |
| Does the record reflect the person's ability or the testing process? | Not addressed by these counts | An operational response-process criterion and its own observations | [Response validity](#sec-m11-validity) |

: One positive flag and six questions. The counts, priors and costs are synthetic teaching inputs, and the probabilities refer to a new person drawn from the stated referral population. {#tbl-m11-one-flag}

:::::

The answer to the prediction is .44, not .8. A count of people shows why, using the observed proportions. Among 1,000 referrals, about 100 have the target, and the flag is positive for 80 of them. Among the 900 without the target, it is positive for 90. About 80 of the 170 positive flags therefore belong to people with the target, a proportion of .47. Stating a Bayesian problem as counts of people in this way is a well-studied aid to reasoning about it [@gigerenzer1995improve]. The predictive value .44 is slightly lower because it uses the posterior distribution of all three inputs, under uniform priors, rather than the three observed proportions. Sensitivity answers a different question: how often the flag is positive among people already known to have the target. Panel A of @fig-m11-flag-to-action shows how strongly the same flag's meaning depends on the population in which it is used.

::: {#fig-m11-flag-to-action}

::: {.m11-figure-panels}

<p><a href="figures/m11-flag-to-action-1.png" aria-label="Open full-size M11 panel 1"><img src="figures/m11-flag-to-action-1.png" alt="Panel A. Prevalence from0 to0.6 against target probability after a positive flag from0 to1. Sensitivity0.8 and false-positive probability0.1 are held at observed proportions. A solid increasing concave curve passes through8/17, about0.47, at prevalence0.1, marked by an open circle. Dashed sensitivity line0.8 is a different conditional probability. The point represents80 target-positive among170 positive flags per1,000 referrals; it is not the integrated new-case prediction." width="1100" height="980" loading="lazy"></a></p>

<p><a href="figures/m11-flag-to-action-2.png" aria-label="Open full-size M11 panel 2"><img src="figures/m11-flag-to-action-2.png" alt="Panel B. Target probability q from0 to1 against expected loss from0 to4 teaching units. Solid baseline loss4q, dashed alternative loss1-q and dotted ideal referral loss0.2 differ in line style and labels. At case probability51/116, about0.44, open circles mark losses about1.76,0.56 and0.20. Vertical threshold0.2 separates the two error-loss choices. Shading from0.05 to0.8 marks where ideal referral is cheapest. The new-case probability integrates uncertain sensitivity, false-positive rate and prevalence; it is not read from panel A." width="1100" height="1160" loading="lazy"></a></p>

:::

The flagged record of @tbl-m11-one-flag. **A.** Probability that a person with a positive flag has the target, $\pi s/\{\pi s+(1-\pi)f\}$ (@eq-m11-risk-parameter), with the flag's observed sensitivity $s=.8$ and false-positive probability $f=.1$ held fixed and the referral-population prevalence $\pi$ varied. The circle marks the observed prevalence .1, where the value is $8/17\approx.47$; the dashed line is the sensitivity. **B.** Conditional expected loss of three actions against the target probability $q$, for the teaching costs $c_{\mathrm{FP}}=1$, $c_{\mathrm{FN}}=4$ and an ideal referral costing .2 (@eq-m11-action-threshold, @eq-m11-referral). The vertical line marks the new flagged person's predictive probability $51/116\approx.44$ (@eq-m11-case-predictive), which integrates over uncertain $s$, $f$ and $\pi$ and so is not read from panel A. All inputs are synthetic; all values are exact calculations.

:::

The other rows of the table outline the chapter. Rarity among people without the target is one input, not the answer. A target probability needs competing target-specific laws and a population composition. Its uncertainty depends on which experiment is repeated or which prior is stated. An action needs consequences, and the same probability can support different actions when the consequences differ. Two questions are not answered by this record at all: whether its probability transfers to another population, and whether the record supports its intended interpretation. Each needs its own observations.

The same structure holds for richer records. Suppose a person obtains several low scores. The joint reference probability is small, yet the same pattern may be common under more than one clinical condition, under disrupted testing conditions, or in people with no specified condition. A rare observation prompts an explanation; it does not select one. Conversely, an ordinary test profile does not rule out an outcome that the battery measures poorly.

This chapter moves from a reference comparison to an **external target** and then to an action. The target might be pathology at assessment, loss of an independently measured everyday function, or a specified event within two years. Each requires its own observations and population. An assessment of response validity is another target, not a correction automatically supplied by a covariance model. An action additionally requires consequences, alternatives and preferences.

The examples are synthetic mathematical experiments. Their parameters, populations, losses and priors are teaching choices. They are not clinical cutoffs, empirical prevalence estimates or recommendations for any patient. Earlier chapters establish [reference profiles](03-correlated-battery.md#sec-correlated-battery), [measurement and replication](05-measurement-and-replication.md#sec-measurement), [selected records](09-administration-and-missingness.md#sec-administration) and [distributional alternatives](10-heterogeneity-and-robustness.md#sec-robustness). Here we supply the additional target relationships, rather than interpreting a normative tail as if those relationships were already known.

## How the chapter is organized {#sec-m11-roadmap}

The chapter follows a record from a reference comparison to an action. Each unit adds one kind of information and says what that information cannot supply on its own.

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 2; scroll horizontally"}

| Unit | Question | What it adds | What it cannot establish alone |
|---|---|---|---|
| [Target and experiment](#sec-m11-contract) | Which target, population and observations? | Known class laws, prevalence and Bayes' rule; why rarity is insufficient | Uncertainty about the laws |
| [Operating characteristics](#sec-m11-evidence) | How well does a flag or summary separate the classes? | Sensitivity, false-positive probability, AUC, likelihood ordering | Calibration, prevalence or utility |
| [Finite evidence](#sec-m11-finite) | How uncertain are the inputs? | Exact confidence images, proper posteriors, the new-case prediction | Accurate verification and representative sampling |
| [Function and prognosis](#sec-m11-prognosis) | What function or future event is predicted? | Regression prediction, horizons, censoring, competing events | A latent capacity or a causal effect |
| [Response validity](#sec-m11-validity) | Does the record support its intended interpretation? | Joint target and response-process states | Motive or intention |
| [Transport](#sec-m11-transport) | Does evidence transfer to this referral population? | Prevalence shift, spectrum and selection models | The transport assumption itself |
| [Validation](#sec-m11-validation) | Are reported risks supported by an independent target? | Calibration, proper scores, imperfect and missing labels | Clinical benefit |
| [Decisions](#sec-m11-decisions) | Which action has the preferable consequences? | Loss thresholds, population risk, net benefit | The causal benefit of an action |
| [Information](#sec-m11-information) | Is another observation worth its burden? | Value of information and finite stopping policies | That a feasible test attains the bound |

:::::

Known laws provide analytic benchmarks. Finite-data examples then estimate the quantities those benchmarks need. Exact identities, finite sums, named distributions, exact integral definitions, numerical quadrature and simulation have different roles. Confidence concerns a repeated-sampling experiment; a credible distribution concerns the stated prior and likelihood. Clinical validity and action consequences require evidence beyond either calculation.

For a first reading, follow the [target and rarity argument](#sec-m11-contract), [operating characteristics](#sec-m11-evidence), and [finite evidence](#sec-m11-finite), including its confidence, posterior and [new-case calculations](#sec-m11-case-update). Then use the [loss thresholds](#sec-m11-thresholds) to finish the [flagged-person example](#sec-m11-flag-to-action). Before applying its answer, read the [response-validity](#sec-m11-validity), [transport](#sec-m11-transport) and [validation](#sec-m11-validation) boundaries: verification must be independent of the flag, and [prognostic association alone does not establish an intervention's benefit](#sec-m11-net-benefit).

For further development, choose [function and prognosis](#sec-m11-prognosis), [fitted response states](#sec-m11-fitted-validity), [estimated transport](#sec-m11-fitted-transport), [proper scores](#sec-m11-calibration), [risk evaluation](#sec-m11-risk-evaluation), or [information and stopping](#sec-m11-information). Each argument needs its own stated design and assumptions. Returning readers can start with the [question-based lookup guide](#sec-m11-guide).

## Synthetic examples and reused symbols {#sec-m11-examples}

Every numerical example is a synthetic teaching input with stipulated parameters, chosen so that each result can be checked. None is an instrument's norms, an estimate from patients, an empirical prevalence or a clinical cutoff. Most examples are built for a single calculation. Separate examples are separate experiments, even when two of them use similar numbers; they are not estimates from one dataset.

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 3; scroll horizontally"}

| Example | Inputs | What it shows | Where |
|---|---|---|---|
| Three rarity models | $r_0=.01$, $\pi=.1$; $r_1=.01$, $.5$ or $0$ | Identical normative rarity, target probabilities .1, .85 and 0 | [Rarity](#sec-m11-rarity) |
| Gaussian score and tail event | $Z\mid D=0\sim N(0,1)$, $Z\mid D=1\sim N(-1,1)$, $z=-2$, $\pi=.1$ | The likelihood ratio at a score differs from that of the tail event | [Rarity](#sec-m11-rarity) |
| Two measures of different reliability | only $H_2$ shifts; error variances .01 and 1 | A highly reliable measure with no target signal has AUC .5 | [Measurement bridge](#sec-m11-measurement-bridge) |
| Validation flag record | 16 of 20, 4 of 40, 10 of 100; uniform priors | Risk posterior and confidence image; new-case prediction; actions | @tbl-m11-one-flag; [new case](#sec-m11-case-update), [action](#sec-m11-flag-to-action) |
| Functional regression | six people, one predictor, $x_0=(1,1)^T$ | Mean versus new-outcome intervals; a proper prior | [Function](#sec-m11-function) |
| Two-year follow-up | twelve people; events at .5, 1 and 1.5 years, nine censored at 2 | Horizon risk with censoring, Bayesian and confidence | [Horizon](#sec-m11-horizon) |
| Known joint states | four $(D,V)$ states with weights $(.72,.08,.12,.08)$ | Target and alternative-process probabilities coexist | [Joint states](#sec-m11-joint-validity) |
| Fitted response-state record | composition $(36,4,6,4)$ and a $4\times4$ count matrix | Learned composition and dependent indicators | [Fitted states](#sec-m11-fitted-validity) |
| Two-stratum spectrum | flag rates .4/.9 and .05/.2; stratum weights $(.8,.2)$ then $(.2,.8)$ | Sensitivity rises while positive predictive value falls | [Spectrum](#sec-m11-spectrum) |
| Fitted transport record | flags $(8,18)$ of 20 and $(2,8)$ of 40 per stratum; 8 of 10; 10 of 100 | Transported risk with seven uncertain inputs | [Fitted transport](#sec-m11-fitted-transport) |
| Missing verification | 30 verified positive, 50 verified negative, 20 unverified; 7 of 10 retrieved | Identified set, confidence enclosure, sensitivity posterior | [Missing verification](#sec-m11-missing-target) |
| Two-point parameter posterior | $q_\theta=.1$ with probability .8, $.9$ with probability .2 | Expected loss versus probability of optimality | [Unknown parameters](#sec-m11-decision-uncertainty) |
| 100-person evaluation | 16 true positives, 8 false positives, 4 false negatives, 72 true negatives | Rule risk and net benefit, empirical and posterior | [Risk evaluation](#sec-m11-risk-evaluation), [net benefit](#sec-m11-net-benefit) |
| Noisy next test | $q=.3$, sensitivity .8, false-positive probability .1, costs (1, 4) | Value of one test and of a two-step stopping policy | [Noisy test](#sec-m11-information-example), [sequential policy](#sec-m11-sequential-decision) |
| Uncertain sensitivity | Beta(1,1) sensitivity, two positive results | Integrated versus plug-in accuracy | [Uncertain test](#sec-m11-uncertain-information) |

:::::

Shared symbols retain their earlier meanings. Locally reused letters are defined where they enter an argument; the list below and the [notation appendix](../appendices/notation.md#sec-notation-targets) provide a reference when moving between units.

- $f$: the false-positive probability of a flag; $f_d(x)$, the target-specific record law.
- $s$, $t$: sensitivity and a decision threshold; $s(X)$, a summary of the record; in the transport unit, the source and target sites; $t$ also counts repeated results in the information unit, and $t_\nu$ is a Student law.
- $h$: a value of the latent attribute $H$; the prognostic horizon; $h_0$, the leverage of a prediction point.
- $B$: a score event; $B_{a,b}$, the beta CDF; $\mathrm B(a,b)$, the beta function.
- $K$: the number of mutually exclusive target states; the prior precision matrices $K_0,K_n$ of the function model.
- $M$: a proposed motive; the integrated state masses $M_1,M_0$.
- $R$: a common covariance matrix in the Gaussian bridge; an inclusion or verification indicator; the population risks $R(\delta)$, $R_0$, $R_Y$, $R_B$ and $R_{\log}$.
- $W$: additional validity-related observations. $C$, $c$: the context being conditioned on; subscripted $c$ denotes costs, and $C_L$ and $C_{k,e}$ are cost totals.
- $a,b$: shapes of beta and gamma priors; $a_0,a_1$ denote actions and $a_d(x)$ selection probabilities.
- $A$: a validity-indicator failure, not the administration conditions of the book-wide notation.
- $v$: the response-state value; a variance in the function model.
- $r$: the event probabilities $r_d$; a reported risk $r(X)$; the fraction with known outcomes; the transported flag probabilities $r_{dc}$.
- $d$: the target value; an event count; the Gaussian separation $d^2$.
- $L$: a loss; the event-time likelihoods $L(\lambda)$ and $L(\lambda,\rho)$. $E$: always an expectation.
- $\rho$: a competing hazard. $\alpha$: an error level. $\eta$: an interval error level; an unsupported stratum mass $\eta_d$.
- $T$: a ranked score; an event time. $J$: a cell of a finite partition; event indicators $J_i$; an imperfect reference label. $V$: the response state; the value functions $V_k$.

## Name the target and the observation experiment {#sec-m11-contract}

Let $D\in\{0,1\}$ indicate a specifically defined target at the stated time. The complement $D=0$ means absence of **that target**, not universal health. For several mutually exclusive states write $D\in\{0,\ldots,K\}$. Different disorders may coexist, so a mutually exclusive partition must sometimes use combinations rather than competing disease names. A continuous functional outcome is denoted $F$ later; the letter $H$ retains its meaning as a latent measurement attribute.

Let $X$ denote the retained assessment evidence beyond any context $C$ currently being conditioned on: available responses or reported profile $Z$, additional history and the administration/observation path. When context itself is part of the evidence rather than held fixed, the joint record is $(X,C)$. Its exact contents are stated in each model; a mixture over $C$ below describes the marginal law of $X$. A score with estimated norms is a function of the raw observations and calibration data, not an error-free latent variable. Independent training data are $\mathcal D$; a learned rule may be treated as fixed **conditional on those data** when evaluating new, independent people. Reusing evaluation outcomes in fitting changes the experiment.

Initially fix a context $C=c$ and the intended referral population, and supply the following known laws on a common dominating measure:

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 1; scroll horizontally"}

$$
\begin{aligned}
\pi&=P(D=1\mid c),\\
f_d(x)&=p(x\mid D=d,c),\\
m(x)&=\pi f_1(x)+(1-\pi)f_0(x).
\end{aligned}
$$ {#eq-m11-target-law}

:::::

These are observed-record densities or masses under the same protocol. They average over whatever latent abilities, stable specificities, occasion states and administration noise the target population contains. They do not describe repeated measurements of a fixed person unless that is the defined experiment. For $m(x)>0$ and $0<\pi<1$, define the likelihood ratio $\Lambda(x)=f_1(x)/f_0(x)$ with the usual infinite value when $f_0=0<f_1$. Then

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 2; scroll horizontally"}

$$
q(x)=P(D=1\mid x,c)=\frac{\pi f_1(x)}{m(x)},\qquad
\frac{q(x)}{1-q(x)}=\frac{\pi}{1-\pi}\Lambda(x).
$$ {#eq-m11-target-bayes}

:::::

The first identity follows by dividing the joint density $\pi f_1(x)$ by the marginal density. It covers infinite likelihood ratios through its density form. For multiple states the posterior weights are $\pi_d f_d(x)/\sum_k\pi_k f_k(x)$. States of zero prior probability remain excluded unless the model changes; observations with zero total model probability signal a model/support problem, not a normalized posterior.

This use of Bayes' rule is a probability identity in a joint population law. A frequentist can use it to define the unknown conditional population risk $q_\theta(x)$. A Bayesian additionally places a prior on unknown population parameters, and integrates their posterior. With known inputs, a point-mass prior gives exactly the displayed joint law; no inferential interval for $\pi,f_0,f_1$ has thereby been derived. [Finite target data](#sec-m11-finite) address those unknowns. The distinction between normative base rates and competing target likelihoods is also central to Gavett's treatment of abnormal-score counts [@gavett2015bayes].

### A rarity probability is insufficient {#sec-m11-rarity}

For a prespecified event $B$^[With two subscripts, $B_{a,b}$ is a beta CDF, and with two arguments, $\mathrm B(a,b)$ is the beta function. The unadorned $B$ is a score event.] on the recorded score scale, let $r_d=P(X\in B\mid D=d,c)$. Reference rarity gives $r_0$ only if the reference is truly the target-negative population under this protocol. A screened peer population can be a different comparator. If the event itself is all that is retained,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 3; scroll horizontally"}

$$
P(D=1\mid B,c)=\frac{\pi r_1}{\pi r_1+(1-\pi)r_0}.
$$ {#eq-m11-event-bayes}

:::::

Knowing $r_0=.01$ and $\pi=.1$ leaves very different possibilities: $r_1=.01$ gives $.1$; $r_1=.5$ gives $50/59\approx.847458$; $r_1=0$ gives zero. All three models agree on normative rarity. A related but different experiment observes only unlabelled marginal score data with law $P_X$. For any measurable $q(x)\in[0,1]$, define $P(D=1,X\in A)=\int_Aq(x)\,dP_X(x)$ and the complementary joint mass using $1-q(x)$. Every such construction has the same observed $P_X$, while target prevalence is $E_{P_X}q(X)$. If prevalence is independently fixed, admissible functions must have that mean, but many distinct risk functions can remain. Unlabelled marginal data alone therefore do not identify diagnostic risk; a known target-negative law supplies different information, as in the preceding event example.

A tail event and the observed score also carry different likelihoods. For $Z\mid D=0\sim N(0,1)$ and $Z\mid D=1\sim N(-1,1)$, $\Lambda(z)=\exp(-z-1/2)$. At $z=-2$ it is $\exp(1.5)\approx4.48$. If only $B=\{Z\le-2\}$ is retained, its likelihood ratio is $\Phi(-1)/\Phi(-2)\approx6.97$. The event averages over more extreme scores; it is not the likelihood ratio at the boundary. With $\pi=.1$ the corresponding probabilities are approximately $.33$ and $.44$. A p-value or reference percentile is neither likelihood ratio.

## Operating characteristics and the information in a summary {#sec-m11-evidence}

This unit asks how well a flag or a ranked summary separates the two target classes before any prevalence or loss enters. Its main result says that ordering records by the likelihood ratio gives the highest sensitivity at every attainable false-positive probability, and that a summary preserves the full posterior only when it preserves the likelihood ratio. A Gaussian special case then shows when a weighted composite attains that bound, and a measurement example shows why reliability does not imply relevance to the target.

A fixed diagnostic flag $\delta(X)\in\{0,1\}$ has sensitivity $s=P_1(\delta=1)$ and false-positive probability $f=P_0(\delta=1)$^[Without a subscript, $f$ is a false-positive probability; $f_d(x)$ is the record law of target state $d$.]; specificity is $1-f$. Its positive predictive value is $\pi s/\{\pi s+(1-\pi)f\}$. For a negative result the target probability is $\pi(1-s)/\{\pi(1-s)+(1-\pi)(1-f)\}$. These are repeated-person population quantities. Sensitivity does not give the probability of the target in a positive person, and false-positive probability is not the proportion of positive reports that are false.

For a ranked score $T$, oriented toward $D=1$, define

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 4; scroll horizontally"}

$$
\operatorname{AUC}(T)=P(T_1>T_0)+\tfrac12P(T_1=T_0),
$$ {#eq-m11-auc}

:::::

where the two records are independent class-specific draws. Ties count one half; AUC is a discrimination summary, not calibration, prevalence or utility. It equals the area under the ROC curve and is the quantity estimated by the Wilcoxon rank statistic [@hanley1982meaning].

::: {#prp-m11-likelihood-ordering}
## Likelihood ordering and compression

For known class laws with $P_1\ll P_0$, a rule that flags the largest $\Lambda$ values, randomizing on an equality set when needed, maximizes sensitivity at every attainable false-positive probability. If $S=s(X)$ is a measurable summary, its likelihood ratio satisfies

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 5; scroll horizontally"}

$$
\Lambda_S(S)=E_0\{\Lambda(X)\mid S\}.
$$ {#eq-m11-summary-lr}

:::::

Thus every summary-based rule can be implemented using the full record, and the full likelihood ordering has at least its ROC envelope and AUC. Equality of the full and summary **posterior probabilities** at every relevant prior $0<\pi<1$ holds precisely when $\Lambda(X)$ is a function of $S$, up to null sets. Equality for one decision threshold is weaker.
:::

::: {.proof}
For a threshold rule $\delta^*$ with cutoff $k\ge0$, $(\delta^*-\delta)(\Lambda-k)\ge0$ pointwise. Integrating under $P_0$ gives $E_1\delta^*-E_1\delta\ge k(E_0\delta^*-E_0\delta)$, which proves the matched-size comparison. Singular $P_1$ mass can first be flagged at zero false-positive cost; the absolutely continuous remainder has the same argument. For any measurable set $A$ of summaries, $P_1(S\in A)=E_0[\mathbf1_{S\in A}\Lambda]$, which identifies its Radon–Nikodym derivative as the displayed conditional expectation. The optimal ROC dominates the ROC of any ranked summary at each false-positive level, including linear segments supplied by tie randomization; integrating over that level gives the AUC inequality. Finally the map from $\Lambda$ to $q$ in @eq-m11-target-bayes is strictly increasing for an interior prior. Consequently knowing $S$ preserves the full posterior exactly if and only if it preserves $\Lambda$. A single loss threshold can instead fall on the same side of all the likelihood ratios within each summary cell.
:::

The matched-size comparison is the likelihood-ratio construction of Neyman and Pearson [@neyman1933efficient, sec. III(a)]. Randomization here establishes a population envelope and the tie convention. It is not a proposal to randomize clinical diagnoses. Oracle dominance compares known laws; it does not guarantee that a full fitted model beats a learned summary at a finite sample size. Estimated norms, feature selection, regularization, model search and threshold fitting must all be included when evaluating the procedure.

### A Gaussian bridge, with its limits {#sec-m11-gaussian}

Supply $Z\mid D=d\sim N_p(\mu_d,R)$ with common $R\succ0$.^[Here $R$ is the common within-class covariance matrix of the scores, as in the robustness chapter. In the selection and missing-verification units, $R$ is an inclusion or verification indicator, as in the administration chapter, and the decision units write population risks $R(\delta)$, $R_0$ and $R_Y$.] Put $\Delta=\mu_1-\mu_0$ and $d^2=\Delta^TR^{-1}\Delta$. Expanding the two quadratic log densities gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 6; scroll horizontally"}

$$
\log\Lambda(z)=\Delta^TR^{-1}\!\left(z-\frac{\mu_1+\mu_0}{2}\right).
$$ {#eq-m11-gaussian-lr}

:::::

If $d>0$, $T=\Delta^TR^{-1}Z$ has class mean difference $d^2$ and within-class variance $d^2$. The independent difference $T_1-T_0$ is normal with mean $d^2$ and variance $2d^2$, hence the oracle AUC is $\Phi(d/\sqrt2)$. At $d=0$ the classes coincide and AUC is one half. For a fixed nonzero $w$, the oriented composite has AUC

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 7; scroll horizontally"}

$$
\Phi\!\left(\frac{w^T\Delta}{\sqrt{2w^TRw}}\right),\qquad
(w^T\Delta)^2\le(w^TRw)d^2.
$$ {#eq-m11-linear-auc}

:::::

The inequality is Cauchy–Schwarz applied to $R^{1/2}w$ and $R^{-1/2}\Delta$. With orientation chosen to make the numerator nonnegative, equality occurs for $w$ proportional to $R^{-1}\Delta$, the direction of Fisher's linear discriminant [@fisher1936multiple]. An arithmetic mean has this property only if that direction is proportional to $\mathbf1$. Extra dispersion is redundant **given the optimal likelihood score**, not given every level score. For example, with $R=I_2$ and $\Delta=(-1,0)^T$, the mean discards part of the first coordinate's signal. Conditioning on the mean still leaves target-related contrast information. The optimality claim is specific to the target-related direction and the common-covariance model.

If covariances differ, the log likelihood ratio contains

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 8; scroll horizontally"}

$$
\tfrac12z^T(R_0^{-1}-R_1^{-1})z
+(R_1^{-1}\mu_1-R_0^{-1}\mu_0)^Tz
$$ {#eq-m11-unequal-quadratic}

:::::

and the normalizing determinant and mean constants. It is generally a full quadratic, not a universal dispersion index. Non-Gaussian target laws can need still different evidence. The target laws concern the actual observed scale: Gaussian copula coordinates do not make a nonlinear raw-score composite Gaussian.

### Measurement precision is not target relevance {#sec-m11-measurement-bridge}

Suppose a justified shared response kernel $k(x\mid h,c)$ applies in both target states, and $g_d(h\mid c)$ describes their latent distributions. Then

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 9; scroll horizontally"}

$$
f_d(x\mid c)=\int k(x\mid h,c)g_d(h\mid c)\,dh.
$$ {#eq-m11-measurement-target}

:::::

Under absolute continuity, dividing the two integrals gives $\Lambda_X(x)=E_0\{g_1(H)/g_0(H)\mid X=x\}$. The likelihood-ordering result now applies to the latent experiment followed by its shared noisy kernel. If target state also changes the response kernel at fixed $h$, this Markov argument fails; one must enlarge the state or model the direct effect.

CTT expected scores, GT universe scores, factor/SEM attributes and IRT coordinates can supply a definition of $H$ only under their stated replication or measurement assumptions. A stable test-specific component can be reliable yet irrelevant to the chosen external target. For a concrete CTT example take independent normal latent coordinates with unit within-class variances; let only $H_2$ shift by one between classes. Observe $X_1=H_1+e_1$ and $X_2=H_2+e_2$, with $\operatorname{Var}(e_1)=.01$ and $\operatorname{Var}(e_2)=1$; both errors are independent of the traits and each other. The replication reliabilities are $1/1.01$ and $1/2$ within class. Yet $X_1$ has AUC $.5$ while $X_2$ has AUC $\Phi(.5)\approx.691462$. SEM/IRT measurement precision likewise does not supply the missing target relationship. More precise observations can improve evidence under a valid shared model; reliability alone cannot identify diagnosis, function, response validity or an action.

## Finite data for diagnostic evidence {#sec-m11-finite}

The benchmarks above treated the class laws and prevalence as known. Here they are estimated from three samples, and the opening record of @tbl-m11-one-flag is worked out. Two targets must be kept apart. The unknown population positive-result risk receives a confidence interval and a posterior distribution. The target probability of one new flagged person is a single predictive number, and it is the number a Bayesian decision uses.

Suppose an independently fixed flag is applied to $n_1$ verified target-positive people and $n_0$ verified target-negative people. Save positive-flag counts $k_1,k_0$. A third, independent representative sample of $n_\pi$ people from the deployment population supplies the target count $k_\pi$. Verification is assumed accurate, complete and defined without using this flag. Sampling within each target class must represent the intended class-specific spectrum. These are strong design assumptions; a balanced case-control study alone cannot estimate deployment prevalence.

Let $s=P(B\mid D=1)$, $f=P(B\mid D=0)$ and $\pi=P(D=1)$ for that population/protocol. Conditional on the sample sizes,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 10; scroll horizontally"}

$$
\begin{aligned}
k_1&\sim\operatorname{Bin}(n_1,s),\\
k_0&\sim\operatorname{Bin}(n_0,f),\\
k_\pi&\sim\operatorname{Bin}(n_\pi,\pi),
\end{aligned}
\qquad\text{independently}.
$$ {#eq-m11-finite-likelihood}

:::::

The target is the **population positive-result risk**

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 11; scroll horizontally"}

$$
Q(s,f,\pi)=\frac{\pi s}{\pi s+(1-\pi)f}.
$$ {#eq-m11-risk-parameter}

:::::

It is defined when the flag has positive population probability. Unknown prevalence, sensitivity and false-positive rate all contribute uncertainty. Crawford, Garthwaite and Betkowska develop interval inference for post-test probabilities in this setting [@crawford2009diagnostic]. The following constructions specify their own proper priors and frequentist guarantee and derive their outputs directly; they do not treat confidence and credible intervals as interchangeable.

### A finite confidence statement for the risk parameter {#sec-m11-risk-confidence}

For $k\sim\operatorname{Bin}(n,\theta)$ let $[l,u]$ be the equal-tail Clopper–Pearson interval [@clopper1934binomial] with error at most $\eta$:

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 12; scroll horizontally"}

$$
\begin{aligned}
l&=B^{-1}_{k,n-k+1}(\eta/2) &&(k>0),\\
u&=B^{-1}_{k+1,n-k}(1-\eta/2)&&(k<n),
\end{aligned}
$$ {#eq-m11-binomial-confidence}

:::::

with $l=0$ at $k=0$ and $u=1$ at $k=n$. Here $B_{a,b}$ is the Beta$(a,b)$ CDF; with no observations use $[0,1]$. This is exact in the sense of finite coverage at least $1-\eta$, generally conservative. To verify it, for fixed $\theta$ invert the inclusive binomial upper/lower tail tests. Each rejected tail has probability at most $\eta/2$, including attainable discrete endpoints. The beta quantiles follow by integrating the beta density, or differentiating the finite binomial tail and matching its endpoint value.

Apply this with $\eta=\alpha/3$ to all three independent experiments; independence is not needed for the union bound. With probability at least $1-\alpha$, the rectangular confidence set contains $(s,f,\pi)$. The function $Q$ is increasing in $s,\pi$ and decreasing in $f$ in the interior: differentiating the ratio gives derivative signs $+,+,-$. Consequently its confidence image is

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 13; scroll horizontally"}

$$
\left[Q(l_s,u_f,l_\pi),\ Q(u_s,l_f,u_\pi)\right].
$$ {#eq-m11-risk-confidence-image}

:::::

If a zero-probability flag occurs at a corner, use the infimum/supremum over the part with positive denominator, rather than divide zero by zero. A region permitting arbitrarily small positive numerator and denominator can give the whole $[0,1]$. This is confidence for an unknown **population probability**, not confidence that the observed person's fixed binary state lies in a probability interval. If selection of the flag used these same observations, the three-binomial experiment no longer justifies this interval without additional analysis.

### Proper Bayesian inference for the same parameter {#sec-m11-risk-posterior}

Independently set $s\sim\operatorname{Beta}(a_s,b_s)$, $f\sim\operatorname{Beta}(a_f,b_f)$ and $\pi\sim\operatorname{Beta}(a_\pi,b_\pi)$ with every shape strictly positive. These priors are specified on the three **probabilities**, not on their logits or on the likelihood ratio. The beta density is $\theta^{a-1}(1-\theta)^{b-1}/\mathrm B(a,b)$, whose integral is one by the definition of the beta integral. Multiplication by @eq-m11-finite-likelihood adds successes and failures to the shapes, leaving independent beta posteriors. All shapes stay positive even at zero/all successes; the likelihood is bounded and positive in the prior interior, so the normalizing constant is finite and nonzero.

The posterior of $Q$ is the image of the joint posterior, rather than the value obtained by inserting three point estimates. If $p_{\mathcal D}$ denotes that joint density, its CDF is

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 14; scroll horizontally"}

$$
\begin{aligned}
u_t(s,f)&=\frac{tf}{(1-t)s+tf},\quad0<t<1,\\
P(Q\le t\mid\mathcal D)&=\int_0^1\!\int_0^1 B_{a'_\pi,b'_\pi}\{u_t(s,f)\}\\
&\quad\cdot p(s\mid\mathcal D)p(f\mid\mathcal D)\,ds\,df.
\end{aligned}
$$ {#eq-m11-risk-cdf}

:::::

Indeed $Q\le t$ is equivalent to $\pi\le tf/\{(1-t)s+tf\}$ for interior probabilities. This exact two-dimensional integral retains all nuisance uncertainty. Credible endpoints invert it; quadrature is a numerical evaluation, not a new sampling guarantee. A prior on $s/f$ would induce a different dependence/shape and must not be substituted silently. Substantial prior sensitivity is possible with few false positives or uncertain prevalence.

### A population risk distribution and a new positive case {#sec-m11-case-update}

There are two different Bayesian operations. First, treating the input event as a fixed reporting condition, the distribution just derived describes the unknown population parameter $Q$ given **training data only**. Its mean is $E(Q\mid\mathcal D)$. Second, draw a new person independently from the deployment population conditional on the same unknown parameters, and then observe that person's positive flag. That event itself has likelihood

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 15; scroll horizontally"}

$$
w_B(\theta)=\pi s+(1-\pi)f,\qquad
p(\theta\mid\mathcal D,B)=
\frac{w_B(\theta)p(\theta\mid\mathcal D)}{E(w_B\mid\mathcal D)}.
$$ {#eq-m11-case-tilt}

:::::

The new person's posterior target probability is therefore

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 16; scroll horizontally"}

$$
\begin{aligned}
P(D_*=1\mid B,\mathcal D)
&=\frac{E(\pi s\mid\mathcal D)}{E\{\pi s+(1-\pi)f\mid\mathcal D\}}\\
&=E(Q\mid B,\mathcal D).
\end{aligned}
$$ {#eq-m11-case-predictive}

:::::

This is a ratio of integrated **joint predictive masses**, not generally $E(Q\mid\mathcal D)$. The case-updated parameter posterior is tilted by how likely a positive record is under each parameter value. Integrating $Q$ against the unupdated parameter posterior answers the first operation, not this random-new-person experiment. If cases are recruited conditional on positivity, the recruitment-conditioned prior and likelihood must instead be specified consistently. One cannot selectively drop the denominator and retain an unselected prior. If $\theta$ is known the two operations coincide; in large informative samples they can be close.

For a concrete record take $k_1=16,n_1=20$, $k_0=4,n_0=40$, and $k_\pi=10,n_\pi=100$. With independent uniform probability priors the posteriors are Beta$(17,5)$, Beta$(5,37)$ and Beta$(11,91)$. The maximum-likelihood plug-in risk is $8/17\approx.470588$. The parameter posterior mean is approximately $.453299$, SD $.130327$, with central $.95$ interval $[.221929,.723930]$; $P(Q>.5\mid\mathcal D)\approx.348790$. The new-positive-person probability in @eq-m11-case-predictive is instead $51/116\approx.439655$. This last number is a state probability, not the probability $.348790$ of a parameter exceeding a threshold.

The simultaneous $.95$ confidence image from the same data is approximately $[.075947,.920083]$. Its greater width reflects the stated conservative construction, not a universal ordering of Bayesian and frequentist intervals. The integral values were evaluated with beta-weighted product quadrature; doubling 48 to 96 nodes per dimension changed the reported mean by less than $10^{-12}$ and the interval endpoints by less than $10^{-9}$. This is a convergence diagnostic; the analytic integral supplies the definition. All these outputs remain conditional on the assumed population, fixed flag and valid verification.

Which of $.439655$, $.453299$ and $.348790$ answers the new flagged person's target question? The first is the predictive state probability after observing that person's positive flag. The second averages the population risk over the training-data posterior; the third is that posterior's probability that the risk parameter exceeds $.5$. Their conditioning and targets differ; none is an interval for the person's fixed binary state.

### Retain patterns and competing targets {#sec-m11-finite-cells}

A binary flag can discard useful distinctions. For a prespecified finite partition $J\in\{1,\ldots,r\}$ of the observed record, let $p_{dj}=P(J=j\mid D=d)$ and collect class-specific multinomial counts $N_{dj}$. A case-control design supplies their likelihood $\prod_{d,j}p_{dj}^{N_{dj}}$ but still needs separate population information for $\pi$. For mutually exclusive multiple targets use class weights $\pi_d$. Proper Dirichlet priors on each row and on the population weights yield posterior shapes equal to prior shapes plus the respective counts. This follows from the simplex density proportional to $\prod_j p_j^{a_j-1}$; normalization can be obtained by transforming independent positive gamma variables into their sum and proportions, whose Jacobian is the sum to power $r-1$.

Every $p_{dj}$ and weight remains inside the nuisance integral:

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 17; scroll horizontally"}

$$
\begin{aligned}
q_d(j)&=\frac{\pi_d p_{dj}}{\sum_k\pi_k p_{kj}},\\
P(D_*=d\mid J_*=j,\mathcal D)&=\frac{E(\pi_d p_{dj}\mid\mathcal D)}{\sum_k E(\pi_k p_{kj}\mid\mathcal D)}.
\end{aligned}
$$ {#eq-m11-cell-predictive}

:::::

Proper positive shapes ensure an interior posterior and positive predictive denominators, including empty observed cells. They do not validate an unobserved population cell or make a sparse high-dimensional partition precise. A frequentist counterpart forms simultaneous binomial confidence intervals for every row-cell probability and population weight, assigns total error $\alpha$ across the finite list, intersects with each simplex, and takes the image of $q_d(j)$. True parameters lie in that intersection with probability at least $1-\alpha$; optimizing the ratios over it gives a conservative exact enclosure. Dependence between cell counts does not invalidate the union bound. There is no claim that this often wide construction is computationally efficient or sharp.

Adding an outcome-bearing measurement, a representative prevalence sample or stronger verification contributes likelihood information. Replacing missing evidence by a narrow prior contributes an assumption. Both may change a numerical answer, but they have different evidential meanings.

## Function and prognosis are external outcomes {#sec-m11-prognosis}

A diagnosis at assessment, an independently assessed functional limitation and an event during follow-up are different targets. Define the outcome instrument, informant, observation setting, time origin and horizon. A score can predict a measured daily-function rating without identifying a latent capacity free of rater/context effects. A baseline cross-sectional association does not supply a personal trajectory. Future care, survival, practice, treatment and ascertainment can change the population being predicted.

### An estimated model for functional performance {#sec-m11-function}

Let $F_i$ be a continuous external functional outcome in declared units, measured separately from the index cognitive score. For fixed recorded predictors $x_i\in\mathbb R^k$ (including an intercept), assume independent people with

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 18; scroll horizontally"}

$$
F_i=x_i^T\beta+\varepsilon_i,\qquad
\varepsilon_i\sim N(0,\sigma^2),\quad\sigma^2>0.
$$ {#eq-m11-function-model}

:::::

This is a conditional observed-outcome model, not a claim that function or cognition is intrinsically Gaussian. Suppose the $n\times k$ design matrix $X_F$ has rank $k$, $n>k$, and the prediction point $x_0$ was fixed independently of these outcomes. The targets are the population conditional mean $\mu_F(x_0)=x_0^T\beta$ and a new person's actual outcome $F_*$ at that predictor. They differ by new outcome variation. Treating a noisy cognitive predictor as fixed describes prediction from its **observed value**; a latent-ability slope or error-free effect requires a measurement model and additional data.

Put $\widehat\beta=(X_F^TX_F)^{-1}X_F^TF$, $s_F^2=\|F-X_F\widehat\beta\|^2/(n-k)$ and $h_0=x_0^T(X_F^TX_F)^{-1}x_0$. Conditional on $X_F,x_0$,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 19; scroll horizontally"}

$$
\begin{aligned}
\frac{x_0^T\widehat\beta-\mu_F(x_0)}{s_F\sqrt{h_0}}&\sim t_{n-k},\\
\frac{F_*-x_0^T\widehat\beta}{s_F\sqrt{1+h_0}}&\sim t_{n-k}.
\end{aligned}
$$ {#eq-m11-function-pivots}

:::::

The first assumes $h_0>0$; if $x_0=0$ the mean is identically zero under this parameterization. To derive the pivots, project the Gaussian residual vector onto the column space of $X_F$ and its orthogonal complement. Orthogonal coordinates of an isotropic Gaussian are independent, so the coefficient error is normal with covariance $\sigma^2(X_F^TX_F)^{-1}$, independently of residual sum of squares divided by $\sigma^2$, a sum of $n-k$ independent squared standard normals. A new independent residual adds variance $\sigma^2$ in the second numerator. Dividing each normal by the square root of the independent chi-square divided by its degrees of freedom gives the t law. Thus the two t intervals have exact conditional coverage in this model. Extrapolation enlarges $h_0$, but the formula cannot certify that the regression relationship remains valid there.

For the Bayesian analysis use the **same conditional likelihood** and a proper prior

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 20; scroll horizontally"}

$$
\begin{aligned}
\beta\mid\sigma^2&\sim N_k(m_0,\sigma^2K_0^{-1}),\\
\sigma^2&\sim\operatorname{IG}(a_0,b_0),
\end{aligned}
\quad K_0\succ0,\ a_0,b_0>0,
$$ {#eq-m11-function-prior}

:::::

where the inverse-gamma density is $b_0^{a_0}v^{-a_0-1}e^{-b_0/v}/\Gamma(a_0)$ with respect to $dv$. Define

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 21; scroll horizontally"}

$$
\begin{aligned}
K_n&=K_0+X_F^TX_F,&m_n&=K_n^{-1}(K_0m_0+X_F^TF),\\
a_n&=a_0+n/2,&
 b_n&=b_0+\tfrac12(F^TF+m_0^TK_0m_0-m_n^TK_nm_n).
\end{aligned}
$$ {#eq-m11-function-update}

:::::

Completing the square in the likelihood/prior gives $\beta\mid v,F\sim N(m_n,vK_n^{-1})$ and $v\mid F\sim\operatorname{IG}(a_n,b_n)$. The extra term in $b_n$ is one half of the minimum of $\|F-X_Fb\|^2+(b-m_0)^TK_0(b-m_0)$ over $b$, hence nonnegative; $b_n>0$ and $K_n\succ0$ prove propriety even for a rank-deficient design under this proper prior. That does not mean the likelihood identifies every coefficient.

Integrating $v$ in a normal density is elementary: substitute $u=1/v$ and use its gamma integral. It yields

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 22; scroll horizontally"}

$$
\begin{aligned}
\mu_F(x_0)\mid\mathcal D&\sim t_{2a_n}\left(x_0^Tm_n,\frac{b_n}{a_n}x_0^TK_n^{-1}x_0\right),\\
F_*\mid x_0,\mathcal D&\sim t_{2a_n}\left(x_0^Tm_n,\frac{b_n}{a_n}(1+x_0^TK_n^{-1}x_0)\right).
\end{aligned}
$$ {#eq-m11-function-posterior}

:::::

The second argument is **scale squared**, not variance. The mean target is degenerate if $x_0=0$; the predictive target still has outcome noise. A functional threshold $c_F$ has population risk $P(F_*<c_F\mid x_0,\beta,v)=\Phi\{(c_F-x_0^T\beta)/\sqrt v\}$. Its parameter posterior is the image of $(\beta,v)$; its posterior predictive event probability is the second t CDF at $c_F$. Here $x_0$ is a conditioned-on predictor, with no model for how often predictors occur, so observing it does not provide the random-case reweighting of @eq-m11-case-tilt.

As an explicitly different, improper reference-prior choice, $p(\beta,v)\propto1/v$ with respect to $d\beta\,dv$ gives the same t endpoints as the pivots when $X_F$ has full rank, $n>k$ and positive residual sum of squares. Integrating $\beta$ leaves $v^{-(n-k)/2-1}e^{-\mathrm{RSS}/(2v)}$, proving propriety under these conditions. The posterior coefficient covariance conditional on $v$ is $v(X_F^TX_F)^{-1}$; gamma integration yields t degrees of freedom $n-k$ and scale factors $s_F^2h_0$ and $s_F^2(1+h_0)$. This derives the precise agreement, rather than extending it to arbitrary priors or non-Gaussian data.

For a worked dataset set $x_i=(1,z_i)^T$, $z=(-2,-1,0,1,2,3)$, $F=(7,7,9,13,14,16)$ and $x_0=(1,1)^T$. Then $\widehat\beta=(10,2)^T$, RSS$=4$, $s_F^2=1$, $h_0=19/105$. The conditional mean interval is $[10.818942,13.181058]$ and the new-outcome interval is $[8.982792,15.017208]$, both at $.95$. With $m_0=(10,0)^T$, $K_0=I_2$, $a_0=b_0=2$, the proper posterior instead has $a_n=5$, $b_n\approx5.893130$, $m_n\approx(10.045802,1.893130)^T$. The corresponding intervals are $[10.970421,12.907442]$ and $[9.333279,14.544583]$; the predictive probability of function below ten is approximately $.064153$. These differences reflect an explicit prior, not different observed data. A bounded/ordinal function rating needs its own likelihood rather than automatic use of these t laws.

### Define a prognostic horizon before counting events {#sec-m11-horizon}

Let $T$ be time from a defined baseline to a defined outcome, $h>0$ the forecast horizon^[Here $h$ is a time horizon. In the measurement-bridge and response-validity units, $h$ is a value of the latent attribute $H$, as in the book-wide notation, and $h_0$ is the leverage of a prediction point.] and $D_h=\mathbf1(T\le h)$. With complete follow-up at that horizon, the binomial/cell experiments above apply directly within prespecified predictor strata. They estimate event probability **by $h$**, not an instantaneous hazard or lifetime probability. Multiple horizons reuse the same people and need their joint law for simultaneous statements.

One tractable time model assumes iid $T_i\sim\operatorname{Exp}(\lambda)$, $\lambda>0$, with administrative censoring at fixed $h$. Save $U_i=\min(T_i,h)$ and $J_i=\mathbf1(T_i\le h)$ for all scheduled people. Relative to a measure with a continuous event-time part and a censoring atom, the full likelihood is^[$L(\lambda)$ is a likelihood here, as in the administration chapter's event-time model. Elsewhere in this chapter $L(a,d)$ is a loss, as in the book-wide notation.]

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 23; scroll horizontally"}

$$
L(\lambda)=\lambda^d e^{-\lambda \mathcal E},\qquad
d=\sum_iJ_i,\ \mathcal E=\sum_iU_i,
\qquad q_h=1-e^{-\lambda h}.
$$ {#eq-m11-event-time-likelihood}

:::::

Each event contributes $\lambda e^{-\lambda U_i}$ and each censored person $e^{-\lambda h}$. With independent random censoring the same event-time likelihood follows after dropping factors free of $\lambda$, if conditional independence and distinct nuisance parameters actually hold. If follow-up depends on unrecorded impending events, that cancellation is not justified. Nor is the random exposure $\mathcal E$ a fixed Poisson observation window merely because the likelihood has the same algebraic form.

A proper Gamma$(a,b)$ prior in **shape/rate** form, density $b^a\lambda^{a-1}e^{-b\lambda}/\Gamma(a)$, gives Gamma$(a+d,b+\mathcal E)$ posterior. Its induced $q_h$ law retains rate uncertainty, and

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 24; scroll horizontally"}

$$
E(q_h\mid\mathcal D)=1-\left(\frac{b+\mathcal E}{b+\mathcal E+h}\right)^{a+d}.
$$ {#eq-m11-horizon-prediction}

:::::

Integrating $e^{-h\lambda}$ against the gamma density proves the expression. Gamma quantiles transform monotonically to credible intervals for $q_h$. A future event indicator also has this predictive probability; repeated future indicators share rate uncertainty and are not independent after integrating $\lambda$.

For finite frequentist inference one option retains only $d\sim\operatorname{Bin}(n,q_h)$ under the fixed common deadline, and uses the exact interval already derived. To use the full observed times without an unproved Poisson pivot, fix a proper comparison Gamma$(a,b)$ before observing the record. Its normalized prior predictive density has parameter-dependent part

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 25; scroll horizontally"}

$$
m(d,\mathcal E)=\frac{b^a\Gamma(a+d)}{\Gamma(a)(b+\mathcal E)^{a+d}}.
$$ {#eq-m11-time-comparison}

:::::

The set $\{\lambda:L(\lambda)\ge\alpha m(d,\mathcal E)\}$ has coverage at least $1-\alpha$ under the full experiment: the expectation of the density ratio $m(\mathcal R)/L_\lambda(\mathcal R)$ is one because both are normalized record laws; Markov's inequality bounds its exceeding $1/\alpha$. The same expected-likelihood-ratio and Markov argument underlies universal inference, where the comparison density is fitted on an independent split instead of fixed in advance [@wasserman2020universal]. This comparison prior defines a confidence construction, not a Bayesian posterior interpretation. For $d>0,\mathcal E>0$, the log likelihood $d\log\lambda-\lambda \mathcal E$ is strictly concave and vanishes toward minus infinity at both limits, so its superlevel set is an interval; the mixture density cannot exceed the maximum likelihood. For $d=0$ use a one-sided interval closure starting at zero. Project the set through $1-e^{-h\lambda}$ for risk confidence. This is an exact coverage bound, typically conservative.

For twelve people with $h=2$ years, supply event times $.5,1,1.5$ and nine observations censored at two. Thus $d=3,\mathcal E=21$ person-years, $\widehat\lambda=1/7$ per year and $\widehat q_2\approx.248523$. A Gamma$(2,2)$ prior (rate in years) gives Gamma$(5,23)$, with posterior mean rate $5/23$ and predictive event probability $.340918$. Inserting $5/23$ into $1-e^{-2\lambda}$ gives a different number; the correct prediction integrates the exponential. Using Gamma$(2,2)$ also as the prespecified comparison density, the full-record $.95$ confidence interval for the rate is approximately $[.009706,.598523]$ per year, mapping to $[.019225,.697915]$ for two-year risk. The independent count and full-time confidence constructions use the same twelve-person experiment but retain different data.

### Competing outcomes and unobserved follow-up {#sec-m11-competing}

Suppose a competing event prevents observing the target event thereafter. Under a constant target hazard $\lambda$ and competing hazard $\rho$,^[$\rho$ is a hazard rate in this unit only. Elsewhere in the book it denotes a correlation.] the survival probability before either is $e^{-(\lambda+\rho)t}$; integrating the target-event density gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 26; scroll horizontally"}

$$
P(T_{\mathrm{first}}\le h,\mathrm{cause}=1)
=\frac{\lambda}{\lambda+\rho}\{1-e^{-(\lambda+\rho)h}\}.
$$ {#eq-m11-competing-risk}

:::::

This is a cumulative incidence, not $1-e^{-\lambda h}$. The latter corresponds to a model without the competitor, or a particular hypothetical elimination model needing justification. First-event causes and times identify $L(\lambda,\rho)=\lambda^{d_1}\rho^{d_2}e^{-(\lambda+\rho)\mathcal E}$ under these constant hazards. Independent Gamma priors update both rates. With common updated rate $b'$, shapes $a'_1,a'_2$, transform to $\lambda_+=\lambda+\rho$ and $\omega=\lambda/\lambda_+$. The Jacobian $\lambda_+$ gives independent Gamma$(a'_1+a'_2,b')$ and Beta$(a'_1,a'_2)$ variables. Thus the posterior predictive cumulative incidence is

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 27; scroll horizontally"}

$$
\frac{a'_1}{a'_1+a'_2}
\left\{1-\left(\frac{b'}{b'+h}\right)^{a'_1+a'_2}\right\}.
$$ {#eq-m11-competing-predictive}

:::::

Unequal prior rates require the joint integral, not this factorization. The full-record normalized-mixture confidence construction also works for the two rates, followed by projecting its region to cumulative incidence. Shape assumptions, censoring independence and time origin remain necessary; the algebra does not validate them. Putter, Fiocco and Geskus review the estimation of cumulative incidence functions and multi-state extensions [@putter2007tutorial].

Without independent ascertainment, horizon outcomes may be unknown rather than negative. If a fraction $r$ have known outcomes and their event fraction is $u$, let $\theta_0$ be the unobserved group's event fraction. The full population risk is $ru+(1-r)\theta_0$ and lies sharply in $[ru,ru+1-r]$ when $\theta_0\in[0,1]$. Every $\theta_0$ gives the same observed law, proving nonidentification; appropriate retrieval or externally justified censoring/selection restrictions can narrow it. The [target-validation development](#sec-m11-validation) supplies finite uncertainty and a proper sensitivity posterior for this experiment. This is an identification limit, not permission to treat losses to follow-up as harmless censoring.

## Response validity needs its own evidence {#sec-m11-validity}

A covariance model can be mathematically correct for a population while a particular assessment does not support its intended ability interpretation. Response validity concerns the relationship between the recorded behavior and the interpretation proposed for it. Performance validity, self-reported symptom validity, construct measurement and statistical calibration are related questions with different observations. The AACN consensus statement addresses the distinct assessment of response validity [@sweet2021validity]. The models here illustrate the inference problem; they do not prescribe an operational validity cutoff or infer intent.

Let $V\in\{0,1\}$ denote a **specified operational response-process state**, where $V=1$ means the assessment meets a declared interpretation criterion and $V=0$ means an alternative process. The criterion and its adjudication must be defined for a real study; the symbol is not an independently observed ground truth merely because it is named. Let $D$ remain the external clinical target, $Z$ the cognitive record and $W$ additional validity-related observations. Disease and $V=0$ can coexist. Neither is the other's complement.

### Joint states and dependent observations {#sec-m11-joint-validity}

Supply state weights $\pi_{dv}=P(D=d,V=v\mid c)$ and joint record laws $f_{dv}(z,w\mid c)$. Then

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 28; scroll horizontally"}

$$
P(D=d,V=v\mid z,w,c)
=\frac{\pi_{dv}f_{dv}(z,w\mid c)}{\sum_{a,b}\pi_{ab}f_{ab}(z,w\mid c)}.
$$ {#eq-m11-joint-validity}

:::::

Summing over $v$ gives the target posterior; summing over $d$ gives the response-state posterior. Setting $v=1$ and renormalizing instead answers the different analytical question **conditional on that state being known**; it is not automatically justified by passing or failing an indicator. To infer a latent ability $H$ use the fuller model

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 29; scroll horizontally"}

$$
p(h,d,v\mid z,w,c)\ \propto
k(z,w\mid h,d,v,c)\,g(h\mid d,v,c)\,\pi_{dv}.
$$ {#eq-m11-validity-measurement}

:::::

Normalizing and marginalizing retain both response-state and ability uncertainty. Averaging the usual valid-process ability estimate with weights from an unrelated validity test is generally not this posterior. If the alternative process has no supported ability likelihood, a sensitivity model or restricted interpretation is more defensible than an invented corrected ability score.

Two validity indicators must also be combined through their **joint** law. Marginal false-positive probabilities of $.1$ each permit a joint failure probability between zero and $.1$, not necessarily $.01$. The bounds follow from nonnegative four-cell probabilities: $\max(0,a+b-1)\le P(A\cap B)\le\min(a,b)$. Perfectly redundant indicators with identical failures attain $.1$. Replacing that joint probability by $.01$ exaggerates evidence by a factor of ten on this side of the likelihood ratio. Conditional independence must hold within every relevant state and after accounting for context; unconditional independence is a different assumption. Overlapping items, common tasks and a shared response process can create dependence. Neuropsychological applications have chained likelihood ratios across several validity indicators, checking independence through the indicators' intercorrelations in the study samples [@larrabee2008aggregation]; the multiplication itself requires conditional independence within each state. Nonsignificant intercorrelations alone do not establish that joint conditional independence.

For a transparent known-law example order states as $(D,V)=(0,1),(1,1),(0,0),(1,0)$ and set weights $(.72,.08,.12,.08)$. Let $B$ be a low cognitive event and $A$ a validity-indicator failure^[$A$ is an event in the response-validity units, not the administration conditions of the book-wide notation.]. Supply

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 4; scroll horizontally"}

| State | $P(B\mid d,v)$ | $P(A\mid d,v)$ |
|---|---:|---:|
| $(0,1)$ | .05 | .05 |
| $(1,1)$ | .70 | .10 |
| $(0,0)$ | .60 | .80 |
| $(1,0)$ | .80 | .90 |

:::::

Assume $A$ and $B$ conditionally independent **only in this synthetic example**. For a person with both events the unnormalized state masses are $(.0018,.0056,.0576,.0576)$, summing to $.1226$. Consequently $P(D=1\mid A,B)=316/613\approx.515498$, and $P(V=0\mid A,B)=576/613\approx.939641$. If one wrongly conditions on $V=1$ as known, the target probability becomes $28/37\approx.756757$. A high alternative-process probability can coexist with substantial target probability; it does not establish motive or negate disease.

### Learn the response-state model rather than treating it as supplied {#sec-m11-fitted-validity}

Consider an idealized validation experiment with an external, accurate adjudication of the **operational** $(D,V)$ states. An independent representative sample supplies counts $m_{dv}$ for the four state weights. Independently recruited representative within-state samples supply four-cell counts for $(B,A)$. The observed likelihood is a product of one multinomial for state composition and one multinomial for each conditional record row. Use independent Dirichlet$(1,1,1,1)$ priors on all five simplexes. The finite-cell derivation above proves propriety and adds counts to each vector. It neither estimates an unlabelled state without data nor assumes conditional independence between $A,B$.

For a completely specified record, take composition counts $(36,4,6,4)$. In the state order above, the conditional counts in order $(B=1,A=1),(1,0),(0,1),(0,0)$ are

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 30; scroll horizontally"}

$$
\begin{pmatrix}
0&1&1&18\\
2&12&0&6\\
10&2&6&2\\
14&2&4&0
\end{pmatrix}.
$$ {#eq-m11-validity-counts}

:::::

The posterior composition shapes are $(37,5,7,5)$ and the first conditional cell means are $(1,3,11,15)/24$. For a new randomly drawn person with $B=A=1$, integrated state masses are proportional to $(37,15,77,75)$, giving target probability $90/204\approx.441176$ and alternative-response probability $152/204\approx.745098$. These are predictive ratios of expected joint masses. The parameter functions $q_{dv}=\pi_{dv}p_{dv,11}/\sum\pi p_{11}$ themselves have a nondegenerate posterior obtained by integrating all five independent Dirichlet distributions; their credible intervals and dependence are retained by joint integration or joint posterior draws. Empty observed cells are not assigned zero risk merely because their count is zero. Applying the simultaneous simplex-confidence construction to these same counts gives a frequentist enclosure for each $q_{dv}$; the coverage is over the whole declared validation experiment. A positive predictive value does not require an artificial test of one person's binary label.

This fitted example estimates both state composition and dependent indicator laws. Its external labels are a design assumption: imperfect adjudication requires its own error model, and state-selective recruitment changes the likelihood. The known-law example and finite record are separate synthetic experiments, not two estimates from the same clinical data.

### What unlabelled indicators cannot identify {#sec-m11-validity-identification}

Even a well-fitted mixture can leave its response-process interpretation unidentified. If the only observed event has probability $.2$, the model $P(B)=\nu r_0+(1-\nu)r_1$ is compatible with $(\nu,r_0,r_1)=(.2,1,0)$ and with $(0,r_0,.2)$ for arbitrary $r_0$. These are identical **whole observed Bernoulli laws** but incompatible response-state prevalences and case assignments. A proper prior can produce a posterior, yet with no additional identifying observations it selects among observationally equivalent explanations. Label switching is an additional issue when mixture components have no externally anchored meaning [@stephens2000dealing].

If the conditional finite record matrix $G$, whose columns are known state-specific distributions, is externally calibrated, an unlabelled population instead satisfies $p_{\mathrm{record}}=G\pi$. Full column rank identifies the weights: $G\pi=G\widetilde\pi$ then implies $\pi=\widetilde\pi$. If the columns are linearly dependent, choose a nonzero null vector $b$. Since columns sum to one, $\mathbf1^Tb=0$; at an interior weight vector, small positive and negative perturbations $\pi\pm\epsilon b$ stay on the simplex and give the same record law. This proves a local nonidentification even with known kernels. More indicators help only if their joint distributions add distinguishing information and their calibration/meaning is defensible.

Finally let $M$ represent a proposed motive^[$M$ denotes a motive only in this paragraph. The information unit writes integrated state masses $M_1,M_0$.]. If $k(z,w\mid h,d,v,M)$ is identical for all $M$ after conditioning on $(h,d,v)$, the observed likelihood has no additional factor distinguishing motives. For fixed $(h,d,v)$, any change in the conditional motive proportions leaves the entire record law unchanged. Posterior motive differences then reflect imported prior/context assumptions, not a mathematical implication of a failed indicator. Even an identified operational response state does not by itself identify intention, deception or a particular cause. Independent history, process observations, replication under appropriate conditions and externally validated response-process measures can supply evidence; a dispersion statistic or a low-score count alone cannot supply it by definition.

## Joint evidence, spectrum and transport {#sec-m11-transport}

History, biomarkers, cognitive scores, functional ratings and response-process observations can complement one another, but only relative to a target and a joint observation law. If $X,W$ are both observed and the relevant conditional densities exist, the chain rule gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 31; scroll horizontally"}

$$
\Lambda(X,W)=\Lambda_X(X)
\frac{f_1(W\mid X)}{f_0(W\mid X)}.
$$ {#eq-m11-joint-evidence}

:::::

The second factor measures evidence **beyond what $X$ already supplied**. Replacing it by the marginal ratio $f_1(W)/f_0(W)$ requires conditional independence of $X,W$ within both target states. A duplicated score $W=X$ supplies no additional observation, although multiplying its marginal ratio would square the evidence. A demographic characteristic already used in the pretest probability must likewise enter a compatible conditional score law; it must not be counted again as an independent likelihood ratio.

### Changing prevalence is a specific transport model {#sec-m11-prior-shift}

Let $s,t$ denote source and target sites^[As subscripts in this unit, $s$ and $t$ name sites. Elsewhere $s$ is a sensitivity and $t$ a decision threshold or, in the information unit, a number of results.]. Suppose the observed-record laws are identical within each target state, $f_{d,t}(x)=f_{d,s}(x)$, while $\pi_t$ may differ from $\pi_s$. With both prevalences interior,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 32; scroll horizontally"}

$$
\operatorname{logit}q_t(x)=\operatorname{logit}q_s(x)
+\operatorname{logit}\pi_t-\operatorname{logit}\pi_s.
$$ {#eq-m11-prior-shift}

:::::

Subtract the two log posterior-odds identities to prove it. The same likelihood ratio can be reused because the **entire** class-conditional record law is assumed transported. This is a prior/prevalence-shift model, not a consequence of applying the same score transformation at two sites. It does not require identical sampling proportions in the original case-control study; it requires the correct population prevalences in the risk calculation. Adjusting a classifier's posterior probabilities to new class prior probabilities, including the case in which the new prior probabilities must themselves be estimated, is treated by Saerens, Latinne and Decaestecker [@saerens2002adjusting].

A different model is covariate shift: $P_t(D\mid X)=P_s(D\mid X)$ while the distribution of $X$ changes. Then conditional risks already transport, and adding a prevalence-odds correction would generally spoil them. Average event rates and average losses still change because the predictor distribution changes. These two assumptions should not be combined casually; the data/design must support the one being used.

### Spectrum changes the likelihood itself {#sec-m11-spectrum}

Let $C$ distinguish severity, comorbidity, language, referral route or another relevant stratum. Even if $f_d(x\mid c)$ transports within supported strata,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 33; scroll horizontally"}

$$
f_{d,t}(x)=\int f_d(x\mid c)\,g_{d,t}(c)\,dc
$$ {#eq-m11-spectrum-mixture}

:::::

depends on the target's class-specific spectrum $g_{d,t}$. Thus sensitivity, specificity and marginal likelihood ratios can change along with prevalence. The dependence of sensitivity and specificity on the spectrum of the people studied was emphasized early in diagnostic research [@ransohoff1978problems]. Conditional risk for a person with measured $C=c$ instead uses $\pi_t(c)$ and $f_d(x\mid c)$; do not average over a stratum already known for that person. If $C$ is measured with error, the observed-stratum law and latent-stratum law are different experiments.

For a two-stratum example let the positive-flag probabilities among target-positive people be $.4,.9$, and among target-negative people $.05,.2$. At the source, each class has stratum weights $(.8,.2)$, giving sensitivity $.5$ and false-positive probability $.08$. At the target, weights $(.2,.8)$ give $.8$ and $.17$. With prevalence $.1$ at both sites, positive-result risk changes from $25/61\approx.409836$ to $80/233\approx.343348$. Sensitivity improved but the positive predictive value fell because the negative-class spectrum also changed. Updating prior odds alone would miss this. The probabilities are stipulated, not estimated clinical transport effects.

### Selection and the record being interpreted {#sec-m11-selection}

Let $R=1$ indicate inclusion, referral, complete testing or target verification. For a supplied selection probability $a_d(x)=P(R=1\mid X=x,D=d)$ and positive class-specific inclusion probability $\bar a_d=E_d a_d(X)$,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 34; scroll horizontally"}

$$
f_{d,R}(x)=\frac{a_d(x)f_d(x)}{\bar a_d},\qquad
\Lambda_R(x)=\Lambda(x)\frac{a_1(x)}{a_0(x)}\frac{\bar a_0}{\bar a_1}.
$$ {#eq-m11-selected-likelihood}

:::::

Multiplying the joint law by its selection factor and normalizing proves both expressions on selected support. If selection depends only on $X$, the $a(x)$ factors cancel in the conditional state posterior **given the full $X$**, but class likelihoods and prevalence both change. The selected prior odds are $(\pi/(1-\pi))(\bar a_1/\bar a_0)$, which cancel the normalization ratio above and recover the original $q(x)$. Keeping only one of these changes is inconsistent. If selection depends on target status beyond the recorded $X$, the cancellation fails. If the record is reduced to a summary, unrecorded selection-relevant information can also prevent cancellation at that summary.

An administration path belongs in $X$ when it is informative. Fixed-subset reference norms are not automatically selected-subset norms, even when missingness depends only on recorded earlier scores. Conditional likelihood factors can cancel without preserving a selected score distribution; this is the distinction developed in [administration and missingness](09-administration-and-missingness.md#sec-administration). For a clinical target the class-specific protocol law is needed on **both** sides of the likelihood ratio. Cases with poor follow-up or unverified targets need an observation/verification model, not automatic exclusion.

### Estimate transported evidence and its uncertainty {#sec-m11-fitted-transport}

A finite two-stratum design can separate the assumptions. Obtain independent, representative class-by-stratum validation samples with positive-flag counts $k_{dc}$ of $n_{dc}$. Obtain separate target-site, class-labelled samples whose stratum counts estimate $g_{d,t}$, and an independent representative target-site sample estimating prevalence. Assume the conditional flag probabilities $r_{dc}$ transport but leave the target spectra and prevalence unknown. The likelihood contains **all** these binomial/multinomial factors. Conditional selection probabilities known from design can instead be incorporated explicitly; unknown informative selection is not learned by merely naming it.

For two strata define $w_d=P_t(C=1\mid D=d)$, so

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 35; scroll horizontally"}

$$
s_t=(1-w_1)r_{10}+w_1r_{11},\qquad
f_t=(1-w_0)r_{00}+w_0r_{01}.
$$ {#eq-m11-fitted-standardization}

:::::

Independent proper beta priors on the four probabilities, two weights and prevalence update by their own successes/failures. Their joint image supplies the parameter posterior of transported positive-result risk $Q(s_t,f_t,\pi_t)$. For a new random positive person integrate joint masses $E(\pi_t s_t)$ and $E\{(1-\pi_t)f_t\}$ before normalizing. A sensitivity/specificity point estimate paired with an uncertain prevalence alone would omit four response probabilities and both mixture weights.

For an explicit finite record use positive counts $(8,18)$ from twenty target-positive people per stratum, and $(2,8)$ from forty target-negative people per stratum. Two independent target-site class-specific samples each contain eight stratum-1 people of ten; the separate prevalence sample contains ten targets of one hundred. Put independent uniform priors on all seven probabilities. The four response posteriors are Beta$(9,13)$, Beta$(19,3)$, Beta$(3,39)$ and Beta$(9,33)$; both weight posteriors are Beta$(9,3)$ and prevalence is Beta$(11,91)$. Independence gives $E(s_t)=3/4$ and $E(f_t)=5/28$. Integrated predictive target risk for a new positive person is $33/98\approx.336735$. It is not a claim that those two conditional means are known; the full parameter-risk posterior retains all seven uncertain coordinates.

For frequentist inference assign total error $\alpha$ across exact binomial intervals for these seven coordinates. Image the joint rectangle through @eq-m11-fitted-standardization and $Q$. This covers the same unknown transported risk with probability at least $1-\alpha$. For positive denominators the extrema can be found among its $2^7$ vertices: holding all but one coordinate fixed makes the numerator and denominator affine in that coordinate, so their ratio is monotone or constant; moving to an endpoint cannot worsen an extremum. Repeat one coordinate at a time. Zero-denominator corners require limiting infima/suprema as before. This finite optimization is a particular computable construction, not a generic assurance that estimated transport is precise. For the supplied finite record, allocating $.05/7$ error to each coordinate gives the $.95$ confidence enclosure $[.026116,.918108]$ for the transported positive-result risk. All $128$ vertices were evaluated; a separate global numerical optimization agreed within $2\times10^{-10}$. This numerical comparison checks the example, while the coordinatewise argument establishes the enclosure. The seven independent binomial likelihoods, rather than the known-spectrum example, define its repeated-sampling guarantee.

If a target class has an unsupported stratum of mass $\eta_d$, even a perfectly known supported-stratum flag probability $r_{d,\mathrm{obs}}$ only gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 36; scroll horizontally"}

$$
r_{d,t}\in[(1-\eta_d)r_{d,\mathrm{obs}},
\ (1-\eta_d)r_{d,\mathrm{obs}}+\eta_d].
$$ {#eq-m11-unsupported-spectrum}

:::::

The bounds are sharp by setting the unsupported probability to zero or one. Unknown $\eta_d$ adds further uncertainty. With no restriction on an unsupported person's conditional target relationship, conditional risk may range over $[0,1]$. A proper prior expresses an extrapolation assumption; it does not verify transport. Representative target observations, common adjudication, compatible administration, support overlap and measurement-comparability evidence would strengthen the inference. Equal percentile distributions or a high source AUC alone do not provide them.

## What counts as target validation? {#sec-m11-validation}

A model can reproduce the labels used to construct it without predicting an independent target. If $D^*=\mathbf1(Z\in B)$ is defined by the very score rule under evaluation, using $\mathbf1(Z\in B)$ to predict $D^*$ gives sensitivity and specificity one by identity when both classes have positive probability. If only one class occurs, agreement is still perfect but one of those conditional operating characteristics is undefined. It establishes agreement with that definition, not an independently observed pathology, daily function or future outcome. A new sample of people does not remove this criterion overlap. The requirement that the reference diagnosis be established independently of the test under evaluation is a long-standing principle of diagnostic research [@ransohoff1978problems]. A consensus syndrome can legitimately include cognitive findings, but agreement with that syndrome and independent target validation must be reported as different evidence.

Independent evaluation also concerns the **procedure**. Freeze norm transformations, feature selection, imputation, response-validity exclusions, tuning, weights, risk calibration, thresholds and stopping before evaluating reserved target-labelled people. Fitting any of these on the evaluation outcomes can make apparent accuracy optimistic. The repeated experiment for a deployable learned procedure includes its training pipeline; evaluating a single frozen model on independent people instead estimates its conditional performance given that training. [Design and validation](12-design-and-validation.md#sec-design) develops broader design choices; the guarantees below concern explicitly fixed predictions and independent evaluation records.

### Calibration, discrimination and proper scores {#sec-m11-calibration}

For a supplied risk report $r(X)\in[0,1]$, population calibration means $E(D\mid r(X))=r(X)$ almost surely in the deployment population. This is weaker than $r(X)=P(D=1\mid X)$. The two conditions correspond to what Van Calster and colleagues call moderate and strong calibration [@vancalster2016calibration]. The constant report $r=\pi$ is calibrated but has AUC $.5$; a strictly increasing, nonidentity distortion of the true nonconstant risk preserves its AUC while generally losing calibration. For an explicit ranking-preserving distortion, $r=q^2$ on interior risks is one-to-one, so $E(D\mid r)=\sqrt r$, which differs from $r$. Calibration can also fail within a subgroup even when it holds after pooling: equal-sized groups with true risks $.1$ and $.9$ both given report $.5$ are calibrated in aggregate, yet neither group is calibrated.

Let $q(X)=P(D=1\mid X)$ and evaluate a new independent person under the target joint law. The expected Brier loss decomposes as

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 37; scroll horizontally"}

$$
E\{(D-r(X))^2\}
=E\{q(X)(1-q(X))\}+E\{(q(X)-r(X))^2\}.
$$ {#eq-m11-brier}

:::::

Condition on $X$, write $D-r=(D-q)+(q-r)$ and use $E(D-q\mid X)=0$ to prove it. The second term is nonnegative and is zero only when $r=q$ almost surely. It depends on more than an aggregate calibration plot. For logarithmic loss,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 38; scroll horizontally"}

$$
\begin{aligned}
\ell_{\log}(D,r)&=-D\log r-(1-D)\log(1-r),\\
E\{\ell_{\log}(D,r(X))\mid X\}&=\operatorname{Ent}\{q(X)\}\\
&\quad+\operatorname{KL}\{\operatorname{Bern}(q(X))\Vert
\operatorname{Bern}(r(X))\}.
\end{aligned}
$$ {#eq-m11-log-score}

:::::

where $\operatorname{Ent}(q)=-q\log q-(1-q)\log(1-q)$. Nonnegativity of the divergence follows from $-\log t\ge1-t$ after summing with the true outcome probabilities; equality requires the same Bernoulli law. Use $0\log0=0$ and infinite loss for assigning zero probability to a possible outcome. These are proper scoring rules, with the loss orientation opposite to reward conventions in the general scoring-rule literature [@gneiting2007proper]. Average Brier/log loss evaluates probability prediction, not a patient's utilities.

For a summary $S=s(X)$ define $q_S=E(D\mid S)=E(q(X)\mid S)$. The best population Brier risks satisfy

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 39; scroll horizontally"}

$$
R_B(S)-R_B(X)=E\{(q(X)-q_S)^2\}=E\{\operatorname{Var}(q(X)\mid S)\}.
$$ {#eq-m11-target-compression}

:::::

Apply @eq-m11-brier with $r=q_S$ to establish this identity. Similarly, conditional expectation in @eq-m11-log-score gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 40; scroll horizontally"}

$$
R_{\log}(S)-R_{\log}(X)
=E\!\left[\operatorname{KL}\{\operatorname{Bern}(q(X))\Vert
\operatorname{Bern}(q_S)\}\right].
$$ {#eq-m11-log-compression}

:::::

This is conditional mutual information about $D$ for a deterministic reduction, when finite. Adding another observation $W$ replaces $X$ by $(X,W)$ and gives the same squared-risk difference with $q(X,W)-q(X)$. Thus incremental prediction is target-specific. It does not identify the mechanism producing a profile, and a tiny probability-score gain need not change any preferred action. These identities compare true conditional laws; estimation error can reverse the ordering of **fitted** models on new data.

For finite calibration evidence, fix a partition and constant predicted values $r_b$ from training, independently of evaluation outcomes. In an iid target evaluation sample, conditional on the bin memberships and bin sample sizes $n_b$, event counts $k_b$ are independent binomials with probabilities $q_b=P(D=1\mid\mathrm{bin}=b)$. Conditioning here retains membership, not each person's exact within-bin predictor values. The exact binomial intervals give finite confidence for each $q_b$, with total error allocated across bins if simultaneous coverage is desired. A zero-sized bin gives $[0,1]$. Independent proper beta priors yield Beta$(a_b+k_b,b_b+n_b-k_b)$ posteriors and explicit credible comparisons with $r_b$. Neither coarse-bin calibration nor a posterior predictive check proves calibration at every exact continuous predictor or subgroup. If predictions vary within a bin, uncertainty in its average report must also be accounted for before calling a bin-event interval an exact interval for calibration error.

### Imperfect reference outcomes change the estimand {#sec-m11-imperfect-target}

Suppose the true target $D$ is not observed, but a reference label $J$ is. Supply reference sensitivity $\mathrm{Se}_J=P(J=1\mid D=1)$ and specificity $\mathrm{Sp}_J=P(J=0\mid D=0)$ and assume $J\perp X\mid D$. This **nondifferential error** assumption matters: adjudication influenced by index scores can violate it. Then

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 41; scroll horizontally"}

$$
P(J=1\mid X=x)=(1-\mathrm{Sp}_J)+(\mathrm{Se}_J+\mathrm{Sp}_J-1)q(x).
$$ {#eq-m11-imperfect-target}

:::::

Conditioning on $D$ proves the equation. Solving it for the target probability is the classical correction of an apparent prevalence for the sensitivity and specificity of an imperfect test [@rogan1978estimating]. If $\mathrm{Se}_J,\mathrm{Sp}_J$ are known and $\mathrm{Se}_J+\mathrm{Sp}_J>1$, the observed-label risk $q_J(x)$ identifies $q(x)=\{q_J(x)+\mathrm{Sp}_J-1\}/(\mathrm{Se}_J+\mathrm{Sp}_J-1)$, subject to compatibility $q_J\in[1-\mathrm{Sp}_J,\mathrm{Se}_J]$. At $\mathrm{Se}_J+\mathrm{Sp}_J=1$ the reference label is uninformative about the target; unknown reference accuracy adds nonidentification. For example an observed Bernoulli label probability $.2$ is compatible with perfect labels and target prevalence $.2$, or with $\mathrm{Se}_J=.8,\mathrm{Sp}_J=.9$ and target prevalence $1/7$. Those models have the same whole observed label law. Additional informative predictors cannot automatically identify unknown differential reference errors.

Finite reference-error inference needs its own validation data. In one fixed prediction stratum, let $k_J$ of $n_J$ people have positive observed labels, and obtain independent accurate-target samples that estimate $\mathrm{Se}_J,\mathrm{Sp}_J$ by binomial reference-label counts. Parameterize the model by $(q,\mathrm{Se}_J,\mathrm{Sp}_J)$ with proper independent beta priors; its likelihood includes

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 42; scroll horizontally"}

$$
\begin{aligned}
&\{(1-\mathrm{Sp}_J)+(\mathrm{Se}_J+\mathrm{Sp}_J-1)q\}^{k_J}\\
&\quad\cdot\{\mathrm{Sp}_J-(\mathrm{Se}_J+\mathrm{Sp}_J-1)q\}^{n_J-k_J}\\
&\quad\cdot L_{\mathrm{Se}}(\mathrm{Se}_J)\,L_{\mathrm{Sp}}(\mathrm{Sp}_J).
\end{aligned}
$$ {#eq-m11-reference-error-likelihood}

:::::

This is a bounded positive likelihood in the interior, so the proper posterior exists; it generally does **not** factor into independent beta posteriors. Normalize the three-dimensional integral and marginalize $\mathrm{Se}_J,\mathrm{Sp}_J$ for target risk. If imposing $\mathrm{Se}_J+\mathrm{Sp}_J>1$, explicitly truncate and normalize the prior on that region. A frequentist counterpart combines simultaneous exact intervals for $q_J,\mathrm{Se}_J,\mathrm{Sp}_J$, intersects with compatibility and any declared orientation restriction, and takes the inverse-map image for $q$. Near uninformative reference accuracy this can encompass $[0,1]$. Precise agreement with a noisy reference label alone is not precise truth inference.

### Missing verification: bounds and a fitted sensitivity model {#sec-m11-missing-target}

Let $R$ indicate whether the target is initially verified in a scheduled representative cohort. Save all three counts $(n_s,n_f,n_m)$ for verified positive, verified negative and unverified people. The population observed-category probabilities are $(\pi_s,\pi_f,\pi_m)$, summing to one. No outcome-independent verification assumption is made. If $\theta_0=P(D=1\mid R=0)$, then

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 43; scroll horizontally"}

$$
\pi=P(D=1)=\pi_s+\pi_m \theta_0,\qquad
\pi\in[\pi_s,1-\pi_f].
$$ {#eq-m11-verification-bounds}

:::::

Every $\theta_0\in[0,1]$ gives exactly the same observed three-category law, and both endpoints are attained. Dropping the unverified people instead estimates $P(D=1\mid R=1)$, generally a different target. Omitting unverified cases can bias estimates of diagnostic accuracy, and adjusting for it requires assumptions about how cases were selected for verification [@begg1983assessment]. The interval $[\pi_s,1-\pi_f]$ is a sharp identification region of the kind studied in partial identification [@manski2003partial]. The same derivation applies within a prespecified prediction bin, provided its denominator includes all scheduled members.

For finite uncertainty, lower one-sided binomial bounds $l_s,l_f$ for $\pi_s,\pi_f$, each with error at most $\alpha/2$, imply

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 44; scroll horizontally"}

$$
[\pi_s,1-\pi_f]\ \subseteq\ [l_s,1-l_f]
$$ {#eq-m11-verification-confidence}

:::::

with probability at least $1-\alpha$ over repeated scheduled cohorts. The two counts need not be independent: their individual marginal binomial bounds and a union bound suffice. This is a confidence enclosure for the **entire identified set**, not the plug-in set and not a posterior interval under a chosen missing-group assumption.

For a proper sensitivity posterior, independently set $(\pi_s,\pi_f,\pi_m)\sim\operatorname{Dir}(a_s,a_f,a_m)$ and $\theta_0\sim\operatorname{Beta}(a_\theta,b_\theta)$, with all shapes positive. The observed counts update only the Dirichlet shapes. Marginalize its full joint law and $\theta_0$ through $\pi=\pi_s+\pi_m\theta_0$; conditional on the simplex, its CDF is the beta CDF at $(t-\pi_s)/\pi_m$, truncated to $[0,1]$. This exact simplex integral gives credible probabilities while retaining observed-category uncertainty and the unlearned missing-group assumption. In particular,

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 45; scroll horizontally"}

$$
E(\pi\mid\mathcal D)=
\frac{a_s+n_s}{a_++n}
+\frac{a_m+n_m}{a_++n}\frac{a_\theta}{a_\theta+b_\theta},\quad
a_+=a_s+a_f+a_m.
$$ {#eq-m11-verification-mean}

:::::

For counts $(30,50,20)$, the empirical identified set is $[.3,.5]$ while the $.95$ entire-set confidence enclosure is approximately $[.212406,.601679]$. Under uniform Dirichlet/Beta priors the posterior mean risk is $41.5/103\approx.402913$. Replacing only the missing-group prior by Beta$(1,9)$ gives $33.1/103\approx.321359$, without changing the observed likelihood. Neither prior is learned from initial unverified outcomes.

Now independently retrieve ten of the twenty initially unverified records uniformly, with valid same-target ascertainment, and observe seven targets. Conditional on their initial statuses and selected identities, the new likelihood is $\theta_0^7(1-\theta_0)^3$. The baseline $\theta_0$ posterior becomes Beta$(8,4)$, while the initial-status Dirichlet remains Dir$(31,51,21)$. The population risk mean becomes $45/103\approx.436893$. The initial verified denominator is not rewritten by retrieval; the added labels inform the previously missing outcome split. A new person known initially unverified instead has predictive target probability $2/3$ in this independent-prior model, whereas an unselected new person has probability $45/103$. A fixed cohort's completed event fraction is another target because its thirty verified targets are already known. This distinction connects target validation to the [missing-outcome analysis](09-administration-and-missingness.md#sec-m09-fitted-mnar).

Reference labels, verification, transport and learning design are part of the evidence. Mathematical calibration conditional on invented labels cannot replace their substantive validation.

## Choose actions under explicit consequences {#sec-m11-decisions}

A probability becomes a decision only after specifying available actions and consequences. The same evidence can reasonably lead to different actions when the consequences differ. Here $a_0$ means a baseline action and $a_1$ an alternative directed at the target; neither symbol necessarily means treatment or a diagnostic label. A referral, accommodation, monitoring plan or additional assessment has its own costs and possible benefits.

Let $L(a,d)$ be loss in declared common units. For a known conditional target probability $q=q(x)$, choose an action minimizing

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 46; scroll horizontally"}

$$
\bar L(a\mid x)=\sum_dL(a,d)P(D=d\mid x).
$$ {#eq-m11-conditional-loss}

:::::

This is pointwise conditional expected loss, not a statement that the action with the highest disease probability is always appropriate. A finite action set has a minimizer; ties can be resolved by a prespecified preference. With multiple clinical/response states, sum over the **joint** state probabilities if consequences depend on both. For continuous functional outcomes replace the sum by the appropriate posterior/predictive integral and ensure the expected loss exists.

### Binary thresholds and referral {#sec-m11-thresholds}

Use the transparent teaching loss table

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 5; scroll horizontally"}

| Action | $D=0$ | $D=1$ |
|---|---:|---:|
| $a_0$ | 0 | $c_{\mathrm{FN}}$ |
| $a_1$ | $c_{\mathrm{FP}}$ | 0 |

:::::

with strictly positive costs. Conditional losses are $c_{\mathrm{FN}}q$ and $c_{\mathrm{FP}}(1-q)$, respectively. Therefore

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 47; scroll horizontally"}

$$
\begin{aligned}
a_1\text{ is preferred}&\iff q>t,
& t&=\frac{c_{\mathrm{FP}}}{c_{\mathrm{FP}}+c_{\mathrm{FN}}},\\
&\iff\Lambda(x)>
\frac{(1-\pi)c_{\mathrm{FP}}}{\pi c_{\mathrm{FN}}},
&&0<\pi<1.
\end{aligned}
$$ {#eq-m11-action-threshold}

:::::

At equality losses tie. Threshold probabilities of this kind, including a testing threshold for gathering more information before acting, were developed for clinical decisions by Pauker and Kassirer [@pauker1980threshold]. The likelihood form follows by substituting posterior odds. Cost subscripts identify the actual error rather than an ambiguous transition notation. More generally define $\Delta L_0=L(a_1,0)-L(a_0,0)>0$ and $\Delta L_1=L(a_0,1)-L(a_1,1)>0$. The threshold is $\Delta L_0/(\Delta L_0+\Delta L_1)$. If these signs do not hold, an action can dominate or the preferred direction can reverse; one should compare losses directly rather than force this formula.

An ideal referral action $a_R$ with loss $c_R$ in both states represents paying for a definitive next-stage resolution with no residual error costs. It is preferable precisely when

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 48; scroll horizontally"}

$$
c_R<\min\{c_{\mathrm{FN}}q,c_{\mathrm{FP}}(1-q)\},
\quad\text{or}\quad
\frac{c_R}{c_{\mathrm{FN}}}<q<1-\frac{c_R}{c_{\mathrm{FP}}}.
$$ {#eq-m11-referral}

:::::

For nonnegative $c_R$, this nonempty strict region exists only when $c_R<c_{\mathrm{FP}}c_{\mathrm{FN}}/(c_{\mathrm{FP}}+c_{\mathrm{FN}})$. Actual referral has delay, imperfect measurements and downstream decisions; its expected loss must include those consequences. The [information calculation](#sec-m11-information) replaces this idealization with a specified noisy next observation.

### From the flagged record to an action {#sec-m11-flag-to-action}

We can now finish the opening problem. Each step below uses one stated input, and changing any one of them can change the conclusion.

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 6; scroll horizontally"}

| Step | Quantity | Value for the synthetic record | What it rests on |
|---|---|---|---|
| Observations | Flags in verified target-positive and target-negative people; targets in a representative referral sample | 16 of 20; 4 of 40; 10 of 100 | Accurate verification, representative sampling and a flag fixed in advance ([finite evidence](#sec-m11-finite)) |
| Target | The target state of one new referral-population member with a positive flag | | The referral population and target definition ([contract](#sec-m11-contract)) |
| Probability | New-positive-person probability, @eq-m11-case-predictive | $51/116\approx.44$ | Independent uniform priors on $s$, $f$ and $\pi$ |
| Losses | False-positive and false-negative costs; an ideal referral cost if one is available | $(1,4)$ or $(4,1)$; $c_R=.2$ | Declared teaching consequences |
| Action | Lowest conditional expected loss, @eq-m11-action-threshold and @eq-m11-referral | $a_1$ under $(1,4)$; $a_0$ under $(4,1)$; referral under $(1,4)$ when $c_R=.2$ | The probability and the losses together |

: The flagged record from observations to an action. Each row supplies what the next row needs. {#tbl-m11-flag-to-action}

:::::

For the earlier new-positive-person probability $51/116$, costs $c_{\mathrm{FP}}=1,c_{\mathrm{FN}}=4$ give $t=.2$ and prefer $a_1$. Costs $4,1$ instead give $t=.8$ and prefer $a_0$. If the first cost pair also permits ideal referral at $c_R=.2$, its region is $.05<q<.8$, so referral is best at this probability. None of these teaching losses supplies a clinical recommendation.

At this probability the expected losses under the first cost pair are $4(.44)=1.76$ for $a_0$, $1-.44=.56$ for $a_1$ and $.20$ for referral, as panel B of @fig-m11-flag-to-action shows. The probability entering the comparison is the new-person predictive probability. It is not the posterior mean of the population risk (.45) or the posterior probability that the population risk exceeds one half (.35); the [next subsection](#sec-m11-decision-uncertainty) explains why a decision uses the integrated probability. Under the first cost pair the choice of $a_1$ over $a_0$ is not fragile in this example. Every value in the central credible interval $[.22,.72]$ for the population risk lies above the threshold .2. If the simultaneous confidence image $[.076,.920]$ is instead used as the uncertainty set for the population risk, the robust criterion of the next subsection compares worst-case losses $4(.920)=3.68$ for $a_0$ and $1-.076=.924$ for $a_1$, and also chooses $a_1$; when ideal referral at .2 is available, its constant loss makes it the robust choice. Under the reversed costs the worst cases are .920 for $a_0$ and $4(.924)\approx3.70$ for $a_1$, and the robust choice is $a_0$.

A model-based summary of the calculation reads as follows. Under the synthetic validation counts, uniform priors and the stated teaching costs, a member of the referral population with a positive flag has a predictive target probability of about .44; when a missed target is assigned four times the loss of a false alarm, the alternative action has lower expected loss than the baseline, and an ideal referral costing .2 would have lower expected loss than either. The summary describes the model. It is not a recommendation for managing any patient, and every input in @tbl-m11-flag-to-action would need empirical support before it could inform one.

### Unknown parameters and the cost of a wrong probability {#sec-m11-decision-uncertainty}

When target-law parameters are unknown, the Bayesian decision uses the integrated conditional predictive state probabilities for the **actual** case experiment, as in @eq-m11-case-predictive. It minimizes posterior expected loss, not the proportion of parameter draws in which an action would be best. For example suppose the conditional parameter posterior assigns probability $.8$ to $q_\theta=.1$ and $.2$ to $q_\theta=.9$. Its predictive mean is $.26$. At costs $(c_{\mathrm{FP}},c_{\mathrm{FN}})=(1,4)$, losses are $.74$ for $a_1$ and $1.04$ for $a_0$, so $a_1$ is preferred even though only $.2$ of the parameter posterior makes it optimal under known parameters. That probability-of-optimality summary answers another question.

For frequentist evaluation hold the true population law fixed and repeat new independent people; conditional on the training data, an estimated rule is one fixed function. With sensitivity $s$ and false-positive probability $f$, its population risk is

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 49; scroll horizontally"}

$$
R(\delta)=\pi c_{\mathrm{FN}}(1-s)+(1-\pi)c_{\mathrm{FP}}f.
$$ {#eq-m11-population-risk}

:::::

A risk-minimizing true-posterior rule is an oracle benchmark. It is not an exact-size hypothesis test, and using estimated parameters does not inherit the oracle's risk. A confidence set for population parameters can supply a range of risks; a robust action can minimize maximum conditional loss over a scientifically justified risk interval, at the expense of a different decision criterion. For $q\in[l,u]$, the worst losses are $c_{\mathrm{FN}}u$ for $a_0$ and $c_{\mathrm{FP}}(1-l)$ for $a_1$. This formula follows by maximizing their affine losses at opposite interval endpoints; the interval must actually represent the intended uncertainty set, not an arbitrary tail area.

Let $C_L=c_{\mathrm{FP}}+c_{\mathrm{FN}}$, $\delta_q=\mathbf1(q>t)$ and $\delta_r=\mathbf1(r>t)$ for a reported risk $r$. Directly subtracting the two conditional losses gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 50; scroll horizontally"}

$$
\begin{aligned}
R(\delta_r)-R(\delta_q)
&=C_L E\{|q(X)-t|\mathbf1(\delta_r\ne\delta_q)\}\\
&\le C_L E|q(X)-r(X)|\\
&\le C_L\sqrt{E\{(q(X)-r(X))^2\}}.
\end{aligned}
$$ {#eq-m11-regret}

:::::

On a disagreement, $t$ lies between $q$ and $r$, establishing the first inequality; Cauchy–Schwarz gives the second. Ties have zero conditional regret when $q=t$. Thus the Brier excess-risk term controls an upper bound on action regret for these losses. It does not assert that every Brier improvement changes an action or that a fixed calibration metric uniquely determines clinical utility.

### Finite evaluation of risk and proper-score loss {#sec-m11-risk-evaluation}

For a rule frozen independently of an iid deployment evaluation sample, save all $n$ target labels and losses $U_i=L(\delta(X_i),D_i)$. If $0\le U_i\le u_{\max}$, the empirical mean $\widehat R$ satisfies

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 51; scroll horizontally"}

$$
P(|\widehat R-R|\ge\epsilon)\le2e^{-2n\epsilon^2/u_{\max}^2}.
$$ {#eq-m11-risk-bound}

:::::

Here $u_{\max}>0$ is a supplied bound, not the sample maximum. A short proof clarifies the guarantee. For a bounded centered loss, let $g(t)$ be its log moment-generating function. Its second derivative is a variance under exponential tilting, at most $u_{\max}^2/4$ because any variable on $[0,u_{\max}]$ has variance no larger than that value. With $g(0)=g'(0)=0$, integration yields $g(t)\le t^2u_{\max}^2/8$. Independence, Chernoff's inequality and minimization over $t$ give each one-sided exponent; sum the two tails. This is Hoeffding's inequality [@hoeffding1963probability], a distribution-free bound for a fixed procedure, not conditional coverage for each patient profile.

For $n_\delta$ candidate rules all fixed using independent training data, a union bound gives simultaneous error at most $\alpha$ with $\epsilon=u_{\max}\sqrt{\log(2n_\delta/\alpha)/(2n)}$. Selecting the smallest empirical risk from these candidates then has true risk at most $2\epsilon$ above the smallest candidate risk, by applying both inequalities and the empirical minimization. A new refit or an unrestricted search using evaluation outcomes is another procedure and is not covered by this finite candidate argument.

Brier losses are bounded by one, so the same proof evaluates their population mean. Log losses are bounded if predictions are clipped in advance to $[\varepsilon,1-\varepsilon]$, with bound $-\log\varepsilon$; the resulting target is the clipped procedure's log loss. Unclipped log loss requires additional tail assumptions rather than this bound.

For a proper Bayesian counterpart on the same finite-record experiment, partition the complete target-labelled evaluation record into categories $j$ with probabilities $p_j$ and fixed rule losses $\ell_j$. A proper Dirichlet prior updates by all category counts. For $a'_j=a_j+n_j$ and $a'_+=\sum a'_j$, population risk has the exact posterior image $R=\sum_jp_j\ell_j$ with

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 52; scroll horizontally"}

$$
\begin{aligned}
E(R\mid\mathcal D)&=\bar\ell=\frac{\sum_j a'_j\ell_j}{a'_+},\\
\operatorname{Var}(R\mid\mathcal D)&=
\frac{\sum_j a'_j(\ell_j-\bar\ell)^2}{a'_+(a'_++1)}.
\end{aligned}
$$ {#eq-m11-risk-dirichlet}

:::::

These follow by integrating monomials in the Dirichlet density: $E p_j=a'_j/a'_+$, $E p_jp_k=a'_j(a'_k+\mathbf1_{j=k})/\{a'_+(a'_++1)\}$. The same posterior joint draws evaluate differences between rules, preserving their dependence on the same people. A category-specific loss must be constant for this finite representation; a varying continuous report needs its actual likelihood or a refined partition, not arbitrary category averaging. Credible risk intervals do not inherit the frequentist bound's coverage.

As a complete evaluation record take 100 new people: sixteen true positives, eight false positives, four false negatives and seventy-two true negatives. At costs $(1,4)$ the empirical rule risk is $.24$; always taking $a_0$ or always taking $a_1$ gives $.8$ in these data. A uniform Dirichlet prior on these four probabilities gives posterior shapes $(17,9,5,73)$ and mean rule risk $29/104\approx.278846$. All four unknown cell probabilities, not just the observed error fraction, enter the posterior. The distribution-free bound with $u_{\max}=4$ is deliberately cautious at this sample size; a narrow interval would need more structure or more data.

### Net benefit is a specified loss comparison {#sec-m11-net-benefit}

For the binary loss table, let $\kappa=c_{\mathrm{FP}}/c_{\mathrm{FN}}=t/(1-t)$. Define population net benefit relative to $a_0$ for all as

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 53; scroll horizontally"}

$$
\operatorname{NB}_t(\delta)=\pi s-\kappa(1-\pi)f
=\frac{R(a_0\text{ for all})-R(\delta)}{c_{\mathrm{FN}}}.
$$ {#eq-m11-net-benefit}

:::::

Expand @eq-m11-population-risk to prove the identity. This is the decision-curve principle of expressing consequences through a threshold-probability tradeoff [@vickers2006decision]; the formula here is derived for the displayed loss table. Plotting it across plausible thresholds compares consequences at different **declared** preferences, not a prevalence-free measure of accuracy.

In an iid target sample its empirical estimate is $\mathrm{TP}/n-\kappa\mathrm{FP}/n$. For the 100-person example, $t=.2$ gives $\kappa=.25$ and net benefit $.14$; the reduction in empirical loss is $4(.14)=.56$. The posterior mean is $(17-.25\cdot9)/104\approx.141827$, with a full Dirichlet image for uncertainty. Empirical net benefit is the mean of bounded contributions in $[-\kappa,1]$, so shifting by $\kappa$ permits @eq-m11-risk-bound with range $1+\kappa$. Simultaneous comparisons across a fixed finite list of thresholds/rules require the corresponding multiplicity allocation; an unrestricted chosen curve maximum is not covered by a single-point interval. In a case-control evaluation sample, raw positive/negative fractions do not represent target prevalence; reweight class-specific operating characteristics by the deployment prevalence and include its uncertainty.

Costs of collecting the predictor, delay, burdens and downstream errors must be added if they differ between strategies. A prognostic association under observed care does not identify how outcomes would change under an action. For an intervention, loss may need potential outcomes [@rubin1974estimating] $F(a)$ or $D_h(a)$, treatment effects and adverse effects. Two causal models can agree on every observed $(X,D)$ distribution yet assign different unobserved outcomes under an untried action. For an explicit witness, suppose observed care always uses $a_0$ and the adverse outcome $D_h(a_0)\mid X$ has any supplied risk $q(X)$. One model sets $D_h(a_1)=D_h(a_0)$; another sets $D_h(a_1)=0$. Both give exactly the same observed $(X,a_0,D_h(a_0))$ law, yet only the second predicts prevention by $a_1$ when $q(X)>0$. Observed risk alone therefore cannot identify causal benefit; randomized or otherwise justified causal evidence is additional information. The loss table can faithfully represent a decision only when its state-specific consequences are substantively supported.

Does the observed prognosis or net benefit establish that $a_1$ prevents the outcome? No. The two models above agree under observed care $a_0$, but one gives no benefit from $a_1$ and the other prevents the outcome. Choosing an intervention needs evidence about those consequences as well as the predicted risk.

## What is another observation worth? {#sec-m11-information}

Additional testing is useful when it can improve a decision enough to justify its costs, burdens and delays. A high-information measurement need not be valuable when it cannot change the preferred action. Conversely, a modest observation near a consequential threshold can be valuable. The calculation must use the intended target, feasible actions and actual joint measurement model.

### Expected value of sample and perfect information {#sec-m11-evsi}

Condition on the current complete record and calibration data, denoted $\mathcal I$. Let $\omega$ be the loss-relevant unknown state, including target status and any uncertain nuisance/measurement parameters. A justified posterior or known population conditional law $p(\omega\mid\mathcal I)$ and proposed observation kernel $k(y\mid\omega,\mathcal I)$ define

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 54; scroll horizontally"}

$$
\begin{aligned}
m(y\mid\mathcal I)&=\int k(y\mid\omega,\mathcal I)p(\omega\mid\mathcal I)\,d\omega,\\
p(\omega\mid y,\mathcal I)&=
\frac{k(y\mid\omega,\mathcal I)p(\omega\mid\mathcal I)}{m(y\mid\mathcal I)}.
\end{aligned}
$$ {#eq-m11-next-observation}

:::::

Sums replace integrals for discrete variables; normalize only on positive predictive support. Assume a finite feasible action set, finite expected losses, unchanged loss-relevant state during observation, and the ability to ignore the observation and retain any current action. Let

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 55; scroll horizontally"}

$$
\begin{aligned}
R_0&=\min_a E\{L(a,\omega)\mid\mathcal I\},\\
R_Y&=E_{Y\mid\mathcal I}\left[\min_aE\{L(a,\omega)\mid Y,\mathcal I\}\right],\\
\operatorname{EVSI}(Y)&=R_0-R_Y,\\
\operatorname{EVPI}&=R_0-E\{\min_aL(a,\omega)\mid\mathcal I\}.
\end{aligned}
$$ {#eq-m11-information-values}

:::::

Then $0\le\operatorname{EVSI}\le\operatorname{EVPI}$. For the lower bound, after every possible $Y$ one may keep the current optimal action; averaging its conditional loss gives $R_0$ by the tower property. For the upper bound, $\min_a E(L\mid Y)\ge E(\min_a L\mid Y)$ because each action's loss dominates the pointwise minimum. Average again and subtract from $R_0$. Perfect information here reveals the **whole loss-relevant state**; perfect disease status alone may be less valuable if unknown state-specific consequences also matter.

A constant observation, an observation conditionally independent of every loss-relevant state, or an observation that leaves the same action optimal almost surely has zero EVSI. Positive gross EVSI is not positive net value. If measurement cost $c(Y,\omega)$ is separable from the terminal action, subtract its conditional expected cost. If it affects outcomes, available actions or losses, include those effects in the experiment rather than invoke the free-information inequality unchanged. Under the simple zero-correct-loss binary table, EVPI about $D$ alone is the current minimum error loss, because perfect $D$ allows zero terminal loss. Ades, Lu and Claxton develop Monte Carlo calculations of the expected value of sample information for medical decision models with several uncertain parameters [@ades2004expected].

### A complete noisy-test example {#sec-m11-information-example}

Suppose current target probability is $q=.3$, costs are $(c_{\mathrm{FP}},c_{\mathrm{FN}})=(1,4)$, and the proposed binary observation has known sensitivity $.8$ and false-positive probability $.1$ conditional on the current record. It is an additional observation, not a reused score. Current optimal loss is $.7$ from $a_1$. The new positive probability is $.3(.8)+.7(.1)=.31$. Posterior target probabilities after positive and negative results are $24/31\approx.774194$ and $2/23\approx.086957$.

The optimal terminal actions are $a_1$ after a positive and $a_0$ after a negative. Average terminal loss is $.7(.1)+4(.3)(.2)=.31$, so EVSI is $.39$, bounded by EVPI $.7$. At an observation cost of $.1$, net value is $.29$. This is exact finite enumeration of the four target/result cells. Sensitivity, false-positive rate and the prior are teaching inputs; their adequacy and costs require empirical support before use.

### Calibrating an uncertain next test {#sec-m11-uncertain-information}

A learned observation kernel must stay inside the predictive integral. Suppose independent calibration data produce proper Beta$(a_s,b_s)$ and Beta$(a_f,b_f)$ distributions for sensitivity and false-positive probability. Use a prior/posterior prevalence distribution for the new person's one target draw, independently of those calibration quantities in this example. Conditional on $D,s,f$, successive indicators for **this same person** are assumed iid Bernoulli$(s)$ if $D=1$ and Bernoulli$(f)$ if $D=0$. This restrictive replication kernel excludes additional stable personal test propensity, fatigue, learning or response-state changes; those require added states or nonidentical kernels.

For an ordered sequence of $t$ outcomes with $k$ positives, integrated state masses before normalization are

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 56; scroll horizontally"}

$$
\begin{aligned}
M_1(k,t)&=E(\pi\mid\mathcal D)
\frac{\mathrm B(a_s+k,b_s+t-k)}{\mathrm B(a_s,b_s)},\\
M_0(k,t)&=E(1-\pi\mid\mathcal D)
\frac{\mathrm B(a_f+k,b_f+t-k)}{\mathrm B(a_f,b_f)}.
\end{aligned}
$$ {#eq-m11-sequence-integrals}

:::::

For one ordered path there is no binomial coefficient. If only the count at an independently fixed length is observed, both masses acquire the common $\binom tk$; it cancels from state odds but is needed for the count probability. The posterior state probability is $M_1/(M_1+M_0)$. Within the $D=1$ component, $s$ updates to Beta$(a_s+k,b_s+t-k)$; within $D=0$, $f$ updates instead. The full posterior is a mixture of these branches, retaining induced dependence between state and parameters. Future predictive outcome probabilities integrate that mixture. Replacing it with independent marginal posteriors or retaining the initial sensitivity mean after every observation loses that dependence.

For a small exact illustration use $q=.3$, uncertain sensitivity Beta$(1,1)$ and known false-positive probability $.1$. Two consecutive positives give target mass $.3E(s^2)=.1$ and nontarget mass $.7(.1)^2=.007$, so target probability is $100/107\approx.934579$. Treating sensitivity's mean $.5$ as known instead gives $75/82\approx.914634$. The integrated signal law depends on the second beta moment; uncertainty creates predictive dependence between repeated results. Observing more appropriately sampled calibration cases would update the sensitivity likelihood, whereas choosing a narrower prior would introduce another assumption. EVSI calculations use the complete current branch mixture, not just a posterior mean accuracy.

### A finite sequential policy {#sec-m11-sequential-decision}

Let $\mathcal I_t$ include every observed result, selected test, cost-relevant condition and updated parameter distribution. With at most $k$ further measurements, define terminal optimal risk $r(\mathcal I_t)=\min_aE(L\mid\mathcal I_t)$. For a finite menu of available next experiments $e$ with separable expected costs $c_e(\mathcal I_t)$, backward induction gives

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 equation 57; scroll horizontally"}

$$
\begin{aligned}
V_0(\mathcal I_t)&=r(\mathcal I_t),\\
C_{k,e}(\mathcal I_t)&=c_e(\mathcal I_t)\\
&\quad+E\{V_{k-1}(\mathcal I_t,e,Y)\mid\mathcal I_t,e\},\\
V_k(\mathcal I_t)&=\min\{r(\mathcal I_t),
\ \min_e C_{k,e}(\mathcal I_t)\}.
\end{aligned}
$$ {#eq-m11-sequential-value}

:::::

Here $C_{k,e}$ is the expected total cost of choosing experiment $e$ now and following the optimal remaining policy. The recursion follows by separating the first decision: stop now or pay for one experiment and then use the already optimal remaining policy. Induction over the finite horizon proves global optimality **within this specified model, action/experiment menu and horizon**. It is not a universal best battery. A myopic one-step EVSI need not capture options opened by later measurements. Unknown kernels or state evolution require the full posterior/history state; the scalar disease probability alone need not summarize it.

Continue the known-kernel $.3/.8/.1$ example with at most two measurements, conditionally independent given $D$, each costing $.1$. One further measurement gives total expected loss $.41$. With two available, stop and take $a_1$ after a first positive: even a subsequent negative leaves posterior probability above $.2$, so another measurement cannot change the terminal action. After a first negative, a second measurement can change it and is worth its cost. The optimal policy therefore tests once and tests again only after a negative. It has expected number of measurements $1+.69=1.69$, terminal sensitivity $.96$ and false-positive probability $.19$. Terminal expected loss is $4(.3)(.04)+.7(.19)=.181$; measurement cost is $.169$, for total $.35$. Always taking two measurements has the same terminal decisions but cost $.2$, giving $.381$. These results enumerate the full path tree and show how stopping changes resource use and operating characteristics.

For a frequentist interpretation of this same known-law policy, hold sensitivity, false-positive rate and population target proportion fixed, then repeat the **complete policy** on new people. Path probabilities and terminal action/cost losses give the sensitivity, false-positive probability, expected test count and total risk above. At fixed target state, repeat all stochastic test outcomes and stopping; the prior proportion is used only to combine state-specific risks. When the policy was learned from finite data, evaluation must include that learning or condition explicitly on its frozen result. Independent policy-level validation with bounded total loss can use @eq-m11-risk-bound; fixed-length test calibration is not automatically stopping-policy calibration.

For Bayesian updating, known policy factors determined only by saved history cancel from the joint path likelihood, but the response likelihoods and their parameter uncertainty remain. Conditioning recruitment on a particular stopping path is a different experiment with its own selection normalizer and prior, just as in [administration](09-administration-and-missingness.md#sec-administration). A posterior probability crossing a decision threshold is not an alpha-level sequential test; neither the loss calculation nor the cancellation proof supplies an anytime confidence guarantee.

A useful additional observation might be an item, retest, informant report, independent target verification, norm/measurement calibration sample or external outcome. The state, kernel, target population and affected losses determine which. Value for one current person, value for future referrals and value for a fixed cohort are different design objectives. A mathematical upper bound on information is not evidence that a particular feasible test can attain it.

## Choose the target before choosing the calculation {#sec-m11-guide}

The table collects reader questions with the sections that answer them.

::::: {.m11-scroll role="group" tabindex="0" aria-label="M11 table 7; scroll horizontally"}

| Clinical or interpretive question | Development and output |
|---|---|
| Is a rare pattern evidence for this target? | [Target likelihoods](#sec-m11-evidence) compare explicit populations; a reference tail alone is insufficient. |
| How uncertain is a positive-result risk? | [Finite evidence](#sec-m11-finite) estimates both class laws and prevalence, separating a parameter distribution from a new-case prediction. |
| What function or future event is predicted? | [Function and prognosis](#sec-m11-prognosis) specify outcome units, prediction versus mean, horizon, censoring and competitors. |
| Does this record support its intended interpretation? | [Response validity](#sec-m11-validity) uses separate operational states and evidence without equating them to motive. |
| Can evidence be reused in this referral population? | [Transport](#sec-m11-transport) distinguishes prevalence, spectrum, selection and unsupported strata. |
| Are reported risks supported by an independent target? | [Validation](#sec-m11-validation) separates calibration, discrimination, criterion overlap and missing/imperfect labels. |
| Which action has the preferable consequences? | [Loss-based decisions](#sec-m11-decisions) compare conditional and population risks under stated costs. |
| Is another observation worth its burden? | [Information and stopping](#sec-m11-information) compare complete noisy-measurement policies under a finite horizon. |

:::::

## What the assessment can support {#sec-m11-conclusion}

A reference profile answers how unusual an observation is among declared peers. A clinical target probability additionally needs competing target-specific record laws and an appropriate population composition. A response-state or latent-ability interpretation needs its own measurement/process assumptions. A decision needs consequences and feasible alternatives. Keeping these steps explicit allows their evidence to accumulate without treating one successful calculation as proof of all the others.

For the flagged person of @tbl-m11-one-flag, each answer now has its own basis. The flag's rarity among people without the target, about 1 in 10, was one input. The target probability .44 combined that input with sensitivity and prevalence from separate samples and with stated priors. The two intervals described different experiments for the population risk, a posterior distribution and a repeated-sampling guarantee. The action followed only after the costs were declared, and it reversed when the costs did. Whether the same numbers apply in another clinic, and whether the record reflects the person's ability, remained open because the record did not contain the observations those questions need.

Report the target and time horizon, the retained observations and scale, the referral population, the administration/verification design, and what was learned from which data. When a probability is supplied, distinguish an estimated population risk, a new-person predictive state probability and uncertainty about a risk parameter. When an interval is supplied, identify its confidence, credible, prediction or partial-identification target. A wide interval or a sharp nonidentification bound can be informative: it states precisely what additional verification, calibration, repeated observations or population support would change the inference.

For an action, state the loss comparison and include measurement burden, delay and downstream uncertainty. Compare complete fitted or sequential procedures in the intended population. Oracle likelihood ordering and free-information bounds explain what a justified model permits; they do not establish a deployable model's accuracy or a treatment's causal benefit. Shared response kernels, external labels, transport restrictions, priors and losses remain assessable assumptions rather than consequences of the algebra.

The next [design and validation chapter](12-design-and-validation.md#sec-design) takes these target-specific objectives into choices about tests, replications, reference samples and validation budgets. The present chapter supplies the objective and its uncertainty; an attractive information bound alone does not establish that a feasible clinical design attains it.
