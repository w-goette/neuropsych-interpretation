# Items and scoring: figure data

The fixed two-item kernel uses slopes 1 and 2 and difficulties 0 and 1. The information panels compare full-pattern information, total-score information, and a moment bound in absolute units and as shares. A separate posterior panel combines pattern or total likelihood with a standard normal prior. The total-only posterior is a prior-predictively weighted mixture. CSVs give information, densities, means, and likelihood estimates.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m06-items-figure.R
```

The [chapter guide](../../examples/M06_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
