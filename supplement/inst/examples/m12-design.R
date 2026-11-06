# Run from the candidate root: Rscript --vanilla supplement/inst/examples/m12-design.R
argument <- grep("^--file=",commandArgs(FALSE),value=TRUE)
script <- sub("^--file=","",argument[[1]])
if(!file.exists(script)) script <- gsub("~+~"," ",script,fixed=TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script,mustWork=TRUE))))
source(file.path(supplement_root,"R/m12-design.R"))
output <- file.path(supplement_root,"outputs/m12-design")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
# 1. Declare the synthetic experiments before comparing their designs.
# 2. Enumerate feasible allocations and integrate the stated finite priors.
# 3. Keep confidence bounds, posterior risks and case predictions in named columns.
tables <- m12_tables()
for(name in names(tables)) readr::write_csv(tables[[name]],file.path(output,paste0(name,".csv")))
writeLines(c("Synthetic teaching inputs; not patient scoring or recommendations.","Deterministic finite sums and scalar adaptive integration; no Monte Carlo in this entry point.","Independent experiments remain separate tables; units/columns in M12_COLUMNS.csv and M12_GUIDE.md.","GT finite-grid prior is exactly the stated 3^7 support; global polyhedral confidence optimization remains the manuscript/Python diagnostic, not this R implementation.","Anchor and paired intervals use numerical integration/root finding of their exact defining laws.","Full adaptive and posterior-pipeline resampling experiments are not implemented by this selected R entry point.","Continuous noisy-item calibration, global AUC threshold optimization and drift posterior quantiles remain advanced manuscript definitions."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote",length(tables),"deterministic M12 tables to",output,"\n")
