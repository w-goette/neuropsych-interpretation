# Design and validation: figure data

Two panels compare target variances after feasible additional observations. Inputs are independent standard-normal coordinates with initial covariance diag(1/2,1) and unit-error additions. Integer best splits are evaluated for k=0 through 8. Coincidence of the contrast paths at k=0,1,2 is exact. Panel axes have different variance ranges; CSVs give both target calculations.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m12-next-observation-figure.R
```

The [chapter guide](../../examples/M12_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
