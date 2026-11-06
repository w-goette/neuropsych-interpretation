# Correlated battery: figure data

Three panels show a joint normal score law and two conditional slices. Means are 50 and 50, SDs are 10, and correlation is .6. Profiles A=(35,50) and B=(35,35) share the first score but have different conditional comparisons. CSVs describe ellipses, densities, omitted plotted masses, slice intervals, and profile coordinates. Tail readouts integrate the full laws.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m03-conditional-figure.R
```

The [chapter guide](../../examples/M03_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
