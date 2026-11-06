# Reproduce the synthetic examples in M01, from any working directory:
# Rscript supplement/inst/examples/m01-observed-event.R
# No random numbers are drawn. This does not analyze patient data.

# Rscript supplies its own file location. Find the surrounding supplement copy,
# so the example also works inside an isolated candidate without personal paths.
script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- sub("^--file=", "", script_argument[[1]])
# Rscript can encode spaces as ~+~ in --file for absolute paths.
if (!file.exists(script_file)) script_file <- gsub("~+~", " ", script_file, fixed = TRUE)
script_path <- normalizePath(script_file, mustWork = TRUE)
supplement_root <- dirname(dirname(dirname(script_path)))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R", "m01-observed-event.R"))

# A list keeps separate experiments separate. Each named table has explicit
# columns in the original score units or in proportions from zero to one.
results <- m01_example_results()
output_directory <- file.path(supplement_root, "outputs", "m01-observed-event")
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)
for (name in names(results)) {
  readr::write_csv(results[[name]], file.path(output_directory, paste0(name, ".csv")))
}
writeLines(capture.output(sessionInfo()), file.path(output_directory, "session-info.txt"))
writeLines(c(
  "Module: M01; synthetic supplied normal law, four-score law and separate fixed-event samples",
  "Inputs: normal mean=50, sd=10, score=35; scores=0:3, masses=.1,.2,.4,.3",
  "Frequency examples: n=100, k=8/0/100; n=0, k=0; proper Beta(1,1) prior; interval level=.95",
  "Methods: pnorm, cumulative/complement sums, category sums, mass sums over rank<=u, qbeta",
  "Seed: none; deterministic. No fitted reference model or empirical data.",
  "Floating-point: probabilities sum tolerance=1e-12; no mass normalization; rank equality tolerance=8 machine epsilons",
  "Intervals: exact distributional/beta-quantile expressions evaluated numerically, not normal approximations",
  "Confidence = repeated-sampling coverage for fixed design; credible = conditional posterior mass",
  "Prediction = event for one additional reference person, not retest of the patient",
  "Source: supplement/inst/examples/m01-observed-event.R and R/m01-observed-event.R",
  "Manuscript mapping and data dictionary: supplement/inst/examples/M01_GUIDE.md"
), file.path(output_directory, "PROVENANCE.txt"))
message("M01 example outputs: ", output_directory)
