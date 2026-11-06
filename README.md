# Neuropsychological Test Interpretation

An applied mathematical framework for interpreting neuropsychological test performance: reference comparisons, measurement, repeated testing, and clinical decisions.

**[Read the online book](https://w-goette.github.io/neuropsych-interpretation/)**

The book is intended for clinicians, researchers, and students who want to understand what test scores can establish, which assumptions their interpretations require, and how different statistical questions call for different methods. Fourteen chapters connect practical interpretation questions with mathematical derivations, worked examples, and reproducible R calculations.

## What the book covers

- **Reference comparisons:** percentiles, finite reference samples, reference curves, correlated batteries, profile differences, and patterns of low scores.
- **Measurement:** expected performance, replication, reliability, item responses, measurement invariance, and linking score scales.
- **Repeated and incomplete observations:** retest change, historical baselines, administration rules, missingness, and adaptive testing.
- **Clinical inference and study design:** heterogeneity, robust comparisons, outcome probabilities, decision losses, and validation of complete procedures.

Frequentist and Bayesian approaches are developed around stated observation designs and targets. Classical test theory, generalizability theory, factor analysis, structural equation models, and item response theory are connected through explicit assumptions and mathematical bridges.

The worked examples use synthetic teaching inputs. The book distinguishes unusual performance, measurement precision, personal change, diagnosis, and action; its accompanying code is educational rather than a patient-scoring system.

## Explore the examples

The [R companion](supplement/README.md) links each chapter to its numerical examples, figure scripts, data dictionaries, and beginner guides. Functions, teaching data, captions, and figure descriptions are included in this repository.

To reproduce an example, install R and restore the recorded environment from the repository root:

```sh
Rscript --vanilla supplement/restore.R
Rscript --vanilla supplement/inst/examples/m01-observed-event.R
```

Generated results appear under `supplement/outputs/`. Run the companion tests with:

```sh
Rscript --vanilla supplement/run_checks.R
```

[Reproduction details](supplement/REPRODUCIBILITY.md) explain the locked package versions, numerical tolerances, and computational limits. The recorded R version is 4.6.1; the project functions are sourced directly without installing this repository as an R package.

## Build the book locally

With Python 3 and Quarto installed, run:

```sh
python3 scripts/check_sources.py --require-complete-book
quarto render book --to html
```

The HTML book is written to `book/_book/`. Use `quarto preview book --to html` for a local preview. The recorded Quarto version is 1.10.18.

Chapter sources, references, and the notation appendix are under [book/](book/). Figure data and R source are under [supplement/](supplement/).

## License

Original text, figures, teaching data, and R code are licensed under [CC BY-NC 4.0](LICENSE). See [COPYRIGHT.md](COPYRIGHT.md) for the scope and [THIRD_PARTY.md](THIRD_PARTY.md) for third-party dependencies.
