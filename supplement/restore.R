# Run from supplement/: Rscript --vanilla restore.R
# Keeps the dependency library inside this source copy; no project package install.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
file <- sub("^--file=", "", argument[[1]])
if (!file.exists(file)) file <- gsub("~+~", " ", file, fixed = TRUE)
project <- dirname(normalizePath(file, mustWork = TRUE))
source(file.path(project, "check_environment.R"))
check_companion_files(project)
Sys.setenv(RENV_PATHS_ROOT = file.path(project, "renv", "state"),
           RENV_PATHS_CACHE = file.path(project, "renv", "cache"),
           RENV_PATHS_SOURCE = file.path(project, "renv", "source"),
           RENV_PATHS_BINARY = file.path(project, "renv", "binary"))
library <- file.path(project, "renv", "library")
dir.create(library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(library, .libPaths()))
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", lib = library, repos = "https://cloud.r-project.org")
}
# Reuse an already installed bootstrap in this local library when available.
if (!dir.exists(file.path(library, "renv"))) {
  stopifnot(file.copy(find.package("renv"), library, recursive = TRUE))
}
renv::restore(project = project, library = library,
              lockfile = file.path(project, "renv.lock"), prompt = FALSE)
source(file.path(project, "check_environment.R"))
check_companion_environment(project)
