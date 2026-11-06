# Norms invariance linking: figure data

Panels 1–3 compare reference populations at the same observed score 35. Panels 4–5 distinguish conditional calibration from measurement invariance using Y=H+2C. Coincident normalized reports follow exact algebra. CSVs provide reference densities, probabilities, response coordinates, and normalized-report coordinates.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m07-norms-figure.R
```

The [chapter guide](../../examples/M07_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
