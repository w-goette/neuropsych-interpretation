# Interpretation: figure data

Two finite repeat laws for one synthetic person have expected scores 35 and 38 despite the same observed score 35. Each of three repeat values has probability 1/3. Rows distinguish possible repeats, expectation, and observation; they do not represent elapsed time.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m00-replication-figure.R
```

The [chapter guide](../../examples/M00_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
