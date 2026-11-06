# Level and shape: figure data

Panel A separates fitted level from residual shape for two observed profiles. Panels B–D show global, focal, and opposing population mean shifts under the same correlation .6. Ellipses enclose 95% of each population and are not power curves. The perpendicular geometry is specific to the equal-row-sum covariance example. CSVs describe ellipses, projection steps, profiles, shifts, and constant-level lines.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m04-level-shape-figure.R
```

The [chapter guide](../../examples/M04_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
