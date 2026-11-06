# Run from the candidate root: Rscript --vanilla supplement/inst/examples/m11-clinical-targets.R
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
source(file.path(supplement_root, "R/m11-clinical-targets.R"))
input <- file.path(supplement_root, "inst/examples/M11_INPUTS")
output <- file.path(supplement_root, "outputs/m11-clinical-targets")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
# 1. Read the supplied synthetic observations; no patient data or fitting shortcuts.
function_data <- readr::read_csv(file.path(input, "functional-observations.csv"), show_col_types = FALSE)
horizon_data <- readr::read_csv(file.path(input, "followup-observations.csv"), show_col_types = FALSE)
# 2. Keep population parameter posteriors, case prediction and loss targets distinct.
tables <- m11_tables(nodes = 64L, function_data = function_data, horizon_data = horizon_data)
# 3. Save tidy, explicitly named output columns for inspection and comparison.
for (name in names(tables)) readr::write_csv(tables[[name]], file.path(output, paste0(name, ".csv")))
writeLines(c("Synthetic teaching calculations; not clinical scoring.", "Beta-weighted quadrature uses 64 nodes; defining integrals are exact, floating-point evaluation is numerical.", "Counts, proper priors, outcomes and policy kernels come from the named M11 examples.", "Three-binomial posterior parameter mean is not the random-new-positive-person prediction.", "Time likelihood retains censoring; full-time confidence is a normalized comparison-density set, not a Poisson exposure pivot.", "Advanced joint parameter-risk intervals outside flag example remain manuscript definitions, not advertised implementations."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote", length(tables), "deterministic tables to", output, "\n")
