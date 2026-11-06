# Change: figure data

A supplied same-person normal law has means (50,52), covariance [[100,80],[80,100]], and observed case (35,36). Marginal change and conditional innovation answer different questions. Conditional rejection rates vary with the fixed first score even when their marginal average is .05. CSVs describe ellipses, comparison lines, conditional errors, readouts, and the fixed-baseline interval.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m08-change-figure.R
```

The [chapter guide](../../examples/M08_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
