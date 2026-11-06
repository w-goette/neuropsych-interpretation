# Check the recorded packages and the library used by standalone examples.
check_companion_environment <- function(project) {
  project <- normalizePath(project, mustWork = TRUE)
  project_library <- file.path(project, "renv", "library")
  if (!dir.exists(project_library)) {
    stop("The companion library is missing. Run Rscript --vanilla supplement/restore.R.", call. = FALSE)
  }
  .libPaths(c(project_library, .libPaths()))
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is unavailable. Run Rscript --vanilla supplement/restore.R.", call. = FALSE)
  }
  lock <- jsonlite::fromJSON(file.path(project, "renv.lock"), simplifyVector = FALSE)
  records <- lock$Packages
  installed <- utils::installed.packages()
  base_packages <- rownames(installed)[!is.na(installed[, "Priority"])]
  dependency_names <- function(fields) {
    values <- unlist(fields, use.names = FALSE)
    if (!length(values)) return(character())
    entries <- trimws(unlist(strsplit(values, ",", fixed = TRUE)))
    sub("[[:space:](].*$", "", entries)
  }
  description <- read.dcf(file.path(project, "DESCRIPTION"))
  fields <- intersect(c("Depends", "Imports", "Suggests", "LinkingTo"), colnames(description))
  declared <- dependency_names(description[1, fields])
  used <- character()
  walk <- function(expr) {
    if (is.call(expr)) {
      name <- if (is.symbol(expr[[1]])) as.character(expr[[1]]) else ""
      if (name %in% c("::", ":::")) used <<- c(used, as.character(expr[[2]]))
      if (name %in% c("library", "require", "requireNamespace") && length(expr) > 1L &&
          is.character(expr[[2]])) used <<- c(used, expr[[2]])
      children <- as.list(expr)
      for (i in seq_along(children)) {
        if (!identical(children[[i]], quote(expr = ))) walk(children[[i]])
      }
    } else if (is.expression(expr) || is.pairlist(expr)) {
      for (i in seq_along(expr)) {
        if (!identical(expr[[i]], quote(expr = ))) walk(expr[[i]])
      }
    }
  }
  files <- c(list.files(file.path(project, "R"), pattern = "[.]R$", full.names = TRUE),
             list.files(file.path(project, "inst", "examples"), pattern = "[.]R$", full.names = TRUE),
             list.files(file.path(project, "tests"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
             file.path(project, c("restore.R", "run_checks.R", "check_environment.R", "record_environment.R")))
  for (file in files) walk(parse(file))
  used <- setdiff(unique(used), c("R", base_packages))
  undeclared <- setdiff(used, c(declared, "renv"))
  unlocked <- setdiff(union(used, declared), c("R", base_packages, names(records)))
  for (package in names(records)) {
    dependencies <- dependency_names(records[[package]][c("Depends", "Imports", "LinkingTo")])
    unlocked <- union(unlocked, setdiff(dependencies, c("R", base_packages, names(records))))
  }
  if (length(undeclared) || length(unlocked)) {
    stop(paste0("Dependency metadata is incomplete. Undeclared: ", paste(undeclared, collapse = ", "),
                "; absent from renv.lock: ", paste(unlocked, collapse = ", ")), call. = FALSE)
  }
  examples <- list.files(file.path(project, "inst", "examples"), pattern = "[.]R$", full.names = TRUE)
  missing_setup <- examples[!vapply(examples, function(file) {
    any(grepl(".libPaths(", readLines(file, warn = FALSE), fixed = TRUE))
  }, logical(1))]
  if (length(missing_setup)) {
    stop("Examples missing companion-library setup: ", paste(basename(missing_setup), collapse = ", "), call. = FALSE)
  }
  problems <- character()
  for (package in names(records)) {
    path <- file.path(project_library, package, "DESCRIPTION")
    if (!file.exists(path)) {
      problems <- c(problems, paste(package, "is missing from", project_library))
      next
    }
    version <- read.dcf(path, fields = "Version")[[1]]
    if (utils::compareVersion(version, records[[package]]$Version) != 0L) {
      problems <- c(problems, paste(package, "has version", version, "but requires", records[[package]]$Version))
    }
    error <- tryCatch({ loadNamespace(package); NULL }, error = function(e) conditionMessage(e))
    if (!is.null(error)) problems <- c(problems, paste(package, "cannot load:", error))
  }
  if (length(problems)) {
    stop(paste(c("Companion environment is incomplete; run supplement/restore.R:", problems), collapse = "\n"), call. = FALSE)
  }
  cat("Verified", length(records), "locked packages and", length(examples), "standalone example library setups.\n")
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  script <- sub("^--file=", "", argument[[1]])
  if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
  check_companion_environment(dirname(normalizePath(script, mustWork = TRUE)))
}
