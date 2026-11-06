# M03 figure: joint law -> observed peer slice -> conditional lower tail.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
source(file.path(supplement_root, "R/m04-level-shape.R"))
output <- file.path(supplement_root,"outputs/m04-level-shape")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
# 1. Each list element is one explicitly named experiment or output family.
results <- m04_example_results()
# 2. Save full precision, not the manuscript's rounded display values.
for (name in names(results)) readr::write_csv(results[[name]], file.path(output,paste0(name,".csv")))
# 3. Record how these synthetic results were produced.
writeLines(c("Synthetic M04 experiments; no patient data, fitted clinical rule or diagnostic cutoff.",
  "Known law R=(1,.6;.6,1); raw profiles (35,50),(35,35), raw means50 andSD10.",
  "Global/focal/opposing shifts (-1,-1),(-1,0),(-1,1); fixed alpha=.05, separate n=20 norm experiment.",
  "Known-zero-contrast-mean paired model N=12, uncentered scatter (12,9;9,12); proper IW teaching priors.",
  "Two-dimensional training effect1.25,5 per group; a separate realized training sample for the NIW posterior.",
  "Deterministic quadrature/root inversion; declared tolerances in code and M04_GUIDE. General unknown-mean replication pushforward/global extrema remain unevaluated.",
  "Functions are sourced directly; no project package installation is required."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output,"session-info.txt"))
cat("Wrote",length(results),"M04 CSV tables to",output,"\n")
