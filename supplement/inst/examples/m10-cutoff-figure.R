# Two separate, responsive panels; the same original inferential experiments.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R")); source(file.path(supplement_root, "R/m10-robustness.R")); source(file.path(supplement_root, "R/m10-cutoff-figure.R"))
output <- file.path(supplement_root, "outputs/m10-cutoff-figure"); dir.create(output, recursive = TRUE, showWarnings = FALSE)
data <- m10_figure_data()
for (name in names(data)) readr::write_csv(data[[name]], file.path(output, paste0(name, ".csv")))
font <- book_font_family()
for (gray in c(FALSE, TRUE)) {
  plots <- plot_m10_cutoff(data, gray = gray, family = font)
  for (i in seq_along(plots)) {
    name <- paste0("m10-one-cutoff-", i, if (gray) "-grayscale" else "")
    ggplot2::ggsave(file.path(output, paste0(name, ".png")), plots[[i]], width = 4.8, height = 4.7, units = "in", dpi = 200, device = ragg::agg_png, bg = "white")
  }
}
vector <- plot_m10_cutoff(data, family = "Helvetica")
for (i in seq_along(vector)) {
  grDevices::postscript(file.path(output, paste0("m10-one-cutoff-", i, ".eps")), width = 4.8, height = 4.7, horizontal = FALSE, onefile = FALSE, paper = "special", family = "Helvetica")
  print(vector[[i]]); grDevices::dev.off()
}
writeLines(c(paste("PNG font:", font), "PNG device: ragg::agg_png; 4.8 x 4.7 inches, 200 dpi", "EPS font/device: Helvetica/base postscript; matching geometry, host glyph metrics may differ", "Deterministic analytic curves; square .1346 is the manuscript's 100000-repetition synthetic shrinkage simulation (seed271004), repeated-experiment simulation, separate from the analytic curves.", "", "One benchmark probability .05 in each panel has a different experiment; exact coincidence is intentional, never jittered."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote five plotting tables, four PNGs and two EPS masters to", output, "\n")
