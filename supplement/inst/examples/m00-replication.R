# From the source repository root:
# Rscript --vanilla supplement/inst/examples/m00-replication.R
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
source(file.path(supplement_root, "R/m00-replication.R"))
output <- file.path(supplement_root, "outputs/m00-replication")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
# First inspect the supplied possible scores and their probabilities.
law <- m00_replication_law()
# Hold the person and observed score fixed; evaluate each declared repeat law.
result <- m00_evaluate_replication(law, observed = 35)
readr::write_csv(result$law, file.path(output, "law.csv"))
readr::write_csv(result$summary, file.path(output, "summary.csv"))
print(result$summary)
writeLines(c(
  "M00 synthetic complete finite replication laws for one fixed person.",
  "Observed score = 35 in both universes. Each possible repeat has probability 1/3.",
  "Universe 1: 32,35,38; expected score35; observed residual0.",
  "Universe 2: 35,38,41; expected score38; observed residual-3.",
  "Inputs stipulated, not estimated. No reference percentile, sample size, prior or clinical outcome.",
  "Deterministic finite sums; no simulation or seed. Floating-point error checked at 1e-12."
), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
