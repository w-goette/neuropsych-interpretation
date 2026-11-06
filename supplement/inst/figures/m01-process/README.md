# One performance: figure data

A four-score probability law separates percentile-rank conventions from the fraction of peers selected by a fixed cutoff. The tables give category masses, assigned ranks, category-level decisions, and total selected probability.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m01-process-figure.R
```

The [chapter guide](../../examples/M01_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
