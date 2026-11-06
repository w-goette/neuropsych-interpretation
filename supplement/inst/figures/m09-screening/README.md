# Administration and missingness: figure data

Three panels follow the full observation law through a stopping rule into the retained record. Independent standard-normal scores are retained together only when both are negative, with probability 1/4. The selected quadrant, scatter boundaries, and radius circle define different events. CSVs provide laws, boxes, arrows, bands, circle coordinates, hatches, and probability readouts.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m09-screening-figure.R
```

The [chapter guide](../../examples/M09_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
