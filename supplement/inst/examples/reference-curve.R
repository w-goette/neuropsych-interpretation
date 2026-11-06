# Run from the repository root with:
# Rscript supplement/inst/examples/reference-curve.R
# This example uses no random numbers and no patient/test data.

# Find the supplement from this script's location, rather than an absolute
# author-specific path. The --file argument is supplied by Rscript.
script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- sub("^--file=", "", script_argument[[1]])
if (!file.exists(script_file)) script_file <- gsub("~+~", " ", script_file, fixed = TRUE)
script_path <- normalizePath(script_file, mustWork = TRUE)
supplement_root <- dirname(dirname(dirname(script_path)))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst", "style", "design-tokens.csv"))
source(file.path(supplement_root, "R", "book-style.R"))
source(file.path(supplement_root, "R", "reference-curve.R"))

# A supplied mean of zero and standard deviation of one define a standardized
# normal teaching reference. These are modeling inputs, not estimated norms.
curve <- normal_reference_curve(seq(-3, 3, length.out = 301), mean = 0, sd = 1)
output_directory <- file.path(supplement_root, "outputs", "reference-curve")
save_reference_figure(curve, output_directory)

# Retain the inputs and interpretation with the outputs. A publication caption
# and alt text have different purposes: one explains the scientific content;
# the other gives a nonvisual description of the displayed information.
writeLines(c(
  "Figure ID: fig-supp-reference-curve",
  "Status: framework demonstration; not integrated into a manuscript chapter",
  "Inputs: synthetic N(0, 1), 301 equally spaced scores from -3 to 3",
  "Algorithm: exact normal CDF evaluated numerically with stats::pnorm",
  "Seed: not applicable; deterministic calculation",
  paste("Resolved PNG/plot font:", book_font_family()),
  paste("PNG device:", if (requireNamespace("ragg", quietly = TRUE)) "ragg::agg_png" else "grDevices::png"),
  "Secondary PDF uses the portable Helvetica base-PDF font; no Cairo dependency is assumed.",
  "Design tokens: supplement/inst/style/design-tokens.csv",
  "Source: supplement/inst/examples/reference-curve.R",
  "Caption: Lower-tail fraction under a supplied standard normal reference. The fraction is 0.5 at the mean; it describes reference rarity, not a clinical target.",
  "Accessibility: one dark blue curve on white; information does not depend on color; axis units and alt text supplied"
), file.path(output_directory, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output_directory, "session-info.txt"))
message("Example outputs: ", output_directory)
