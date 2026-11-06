# Heterogeneity and robustness: figure data

The panels compare Student-tail behavior and finite-reference plug-in probabilities. The square .1346 is a 100,000-repetition synthetic shrinkage simulation with seed 271004, separate from deterministic F-CDF curves. The .05 benchmark in each panel refers to its own experiment. CSVs contain curve coordinates, marked points, and benchmark definitions; label positions are display coordinates.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m10-cutoff-figure.R
```

The [chapter guide](../../examples/M10_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
