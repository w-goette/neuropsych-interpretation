# Run from the project root: Rscript supplement/inst/examples/m03-correlated-battery.R
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R/m03-correlated-battery.R"))
output <- file.path(supplement_root, "outputs/m03-correlated-battery")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
# 1. Supply the chapter's fixed synthetic inputs. No patient data are read.
input <- m03_inputs()
# 2. Evaluate each declared comparison. Known and hypothetical fitted norms
# have the same printed summaries but represent different experiments.
results <- m03_example_results()
# 3. Keep full precision in CSVs; round only when displaying a result.
for (name in names(results)) readr::write_csv(results[[name]], file.path(output, paste0(name, ".csv")))
writeLines(c(
  "M03 synthetic example: means50/50,SD10/10,rho.6; profiles A=(35,50),B=(35,35).",
  "Known population law is supplied. Separately stipulate n20 sample summaries numerically equal to that law; case excluded from fitting.",
  "Count cutoffs40/40, inclusive coordinate/count rules; named lower-tail family alpha.05.",
  "Proper joint prior: mean(50,50),kappa1,nu5,Psi2*fixed example covariance, chosen before hypothetical norms.",
  "Conditional-regression example uses coding(1,(c-50)/10),B0=(50,6),V0=I,nu0=4,Psi0=128; a separate conditional prior.",
  "Exact Gaussian/Student/F/chi-square expressions evaluated numerically; orthants/Student count/weighted tails use deterministic adaptive quadrature.",
  "quadrature_error is the integrator's estimated absolute error, not a rigorous error certificate or model uncertainty.",
  "Content_outer is the elementary conservative enclosure; optimized extrema and posterior content quantiles are NOT computed.",
  "Predictive count probabilities are posterior means of achieved content, not credible intervals or impairment probabilities.",
  "No random sampling or seed; no disease, causal or retest inference. See M03_GUIDE.md for output meanings and limitations."
), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote", length(results), "M03 CSV tables to", output, "\n")
