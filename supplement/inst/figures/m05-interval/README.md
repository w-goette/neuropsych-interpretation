# Measurement and replication: figure data

The panels compare scalar intervals and repeated-data coverage under the supplied measurement model. CSVs describe interval centers and endpoints, coverage functions, prior-density weighting, and marked values. Sampling coverage, posterior probability, and prediction retain their distinct conditioning statements.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m05-interval-figure.R
```

The [chapter guide](../../examples/M05_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
