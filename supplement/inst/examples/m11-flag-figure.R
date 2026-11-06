# Reproduce fig-m11-flag-to-action as two independently readable R panels.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R")); source(file.path(supplement_root, "R/m11-clinical-targets.R")); source(file.path(supplement_root, "R/m11-flag-figure.R"))
output <- file.path(supplement_root, "outputs/m11-flag-figure"); dir.create(output, recursive = TRUE, showWarnings = FALSE)
data <- m11_figure_data()
for (name in names(data)) readr::write_csv(data[[name]], file.path(output, paste0(name, ".csv")))
font <- book_font_family()
for (gray in c(FALSE, TRUE)) {
  plots <- plot_m11_flag(data, gray, font)
  for (i in seq_along(plots)) ggplot2::ggsave(file.path(output, paste0("m11-flag-to-action-", i, if (gray) "-grayscale" else "", ".png")), plots[[i]], width = 5.5, height = if (i == 1) 4.9 else 5.8, units = "in", dpi = 200, device = ragg::agg_png, bg = "white")
}
vector <- plot_m11_flag(data, family = "Helvetica")
for (i in seq_along(vector)) {
  grDevices::postscript(file.path(output, paste0("m11-flag-to-action-", i, ".eps")), width = 5.5, height = if (i == 1) 4.9 else 5.8, horizontal = FALSE, onefile = FALSE, paper = "special", family = "Helvetica")
  print(vector[[i]]); grDevices::dev.off()
}
writeLines(c(paste("PNG font:", font), "PNG: ragg::agg_png, white canvas, 200dpi; panels 5.5x4.9 and 5.5x5.8 inches", "Vector EPS: base postscript/Helvetica fallback, same geometry, host metrics can vary.", "", "Panel B shows all three loss curves and the case loss 1.76 on a y-axis from 0 to 4.", "Deterministic synthetic example; panel-level alternative text accompanies the figure."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote four data tables, four color/grayscale PNGs and two EPS masters to", output, "\n")
