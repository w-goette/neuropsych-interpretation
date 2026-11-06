# Finite reference: figure data

Two normal-reference fitting rules induce different sampling laws for achieved content. `density-data.csv` gives a 500-point grid per rule including .05; `rule-summary.csv` gives cutoffs, full-law means, exceedance probabilities, and masses outside the plotted range. The shaded finite window is not the entire tail.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m02-cutoff-figure.R
```

The [chapter guide](../../examples/M02_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
