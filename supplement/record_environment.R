# Capture actual installed versions, including transitive dependencies.
# This records the environment; it does not install or change any packages.
script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_file <- sub("^--file=", "", script_argument[[1]])
if (!file.exists(script_file)) script_file <- gsub("~+~", " ", script_file, fixed = TRUE)
script_path <- normalizePath(script_file, mustWork = TRUE)
supplement_root <- dirname(script_path)
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
required <- c("dplyr", "ggplot2", "readr", "tibble", "testthat")
optional <- c("systemfonts", "ragg")
required <- unique(c(required, optional[vapply(optional, requireNamespace, logical(1), quietly = TRUE)]))
installed <- installed.packages()
dependencies <- tools::package_dependencies(required, db = installed, recursive = TRUE)
packages <- sort(unique(c(required, unlist(dependencies))))
versions <- tibble::tibble(
  package = packages,
  version = installed[packages, "Version"],
  built = installed[packages, "Built"]
)
readr::write_csv(versions, file.path(supplement_root, "environment-versions.csv"))
writeLines(capture.output(sessionInfo()), file.path(supplement_root, "session-info.txt"))
message("Recorded installed versions. See REPRODUCIBILITY.md for the tested lockfile and restore procedure.")
