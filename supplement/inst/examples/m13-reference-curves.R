# Reproduce selected M13 examples from any working directory.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
source(file.path(supplement_root, "R/m02-finite-reference.R"))
source(file.path(supplement_root, "R/m13-reference-curves.R"))
output <- file.path(supplement_root, "outputs/m13-reference-curves")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
# 1. Build the exact stipulated raw scores, separate count sample and priors.
# 2. Calculate each population/posterior/procedure target under its own experiment.
# 3. Save tidy tables; use M13_GUIDE.md to interpret every column and limitation.
tables <- m13_tables(nodes = 64L)
for (name in names(tables)) readr::write_csv(tables[[name]], file.path(output, paste0(name, ".csv")))
writeLines(c("Synthetic mathematical examples; no patient data or diagnostic rule.", "Normal reference:20 constructed scores, mean50/SD10, case35; raw proper prior50,5,3,200.", "Discrete branch:known support0:3, counts1,2,4,3, Dirichlet1,1,1,1; repeated-fitting truth.1,.2,.4,.3 is supplied separately.", "Sinh branch:external origin50/unit10, new transformed-scale prior0,1,2,1; uniform shapes[.5,2] or[.25,4].", "Reference and proper region/posterior targets are not interchangeable guarantees.", "Root/quadrature values are approximate numerical evaluations of exact definitions.", "Gamma probability tails omitted at most2e-12 for bounded integrands, plus quadrature/root errors.", "Shape mixtures use64-node Gauss-Legendre quadrature, not a claimed exact finite sum; refinement checked separately.", "General parameter confidence projection over all shapes is not implemented as a finite-grid envelope.", "Raw sinh predictive positive absolute moments do not exist; only probabilities/quantiles reported.", "Frozen selected-rule posterior content differs from achieved content across refitted tables."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote", length(tables), "M13 tables to", output, "\n")
