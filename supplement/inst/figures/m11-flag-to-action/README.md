# Clinical targets and decisions: figure data

Panel A uses sensitivity .8, false-positive rate .1, and varying prevalence; prevalence .1 gives positive-result target probability 8/17. Panel B uses the separate integrated new-case probability 51/116 and compares losses 4q, 1-q, and .2. Referral is preferred for .05<q<.8. Panel B does not derive its probability from panel A. CSVs provide prevalence curves, losses, case points, and readouts.

Reproduce from the repository root:

```sh
Rscript --vanilla supplement/inst/examples/m11-flag-figure.R
```

The [chapter guide](../../examples/M11_GUIDE.md) explains the model, quantities, and computational limits. This folder supplies plotting data, caption, alternative text, and device information. The script writes generated files under `supplement/outputs/`.

Color and grayscale PNGs use redundant labels, shapes, or line types. Vector files use the recorded graphics device and font fallback; font metrics can differ from PNGs. The HTML chapter stacks panels on narrow screens and links to full-resolution images. Inputs are synthetic teaching examples.
