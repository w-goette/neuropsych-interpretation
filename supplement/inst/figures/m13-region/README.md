# Reference curves: figure data

Two boundary candidates from one coupled mean/SD region map into scorewise CDF envelopes. The normal-reference example has n=20, mean=50, and SD=10. Circle/dashed and triangle/dot-dash denote the same candidates in both panels. Their CDFs coincide at 50. Shading represents the admissible region or full band, not a uniform density. The band also uses boundary candidates beyond the two traced curves. Six CSVs record the region, polygon, traced parameters, analytic envelopes, curves, and anchors. A finite score window illustrates the all-score result; it is not its proof.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m13-region-figure.R
```

The [chapter guide](../../examples/M13_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
