argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
for (file in c("book-style.R", "m02-finite-reference.R", "m13-reference-curves.R", "m13-region-figure.R")) source(file.path(supplement_root, "R", file))
output <- file.path(supplement_root, "outputs/m13-region-figure")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
data <- m13_figure_data()
for (name in names(data)) readr::write_csv(data[[name]], file.path(output, paste0(name, ".csv")))
font <- book_font_family()
for (gray in c(FALSE, TRUE)) {
  plots <- plot_m13_region(data, gray, font)
  for (i in seq_along(plots)) ggplot2::ggsave(file.path(output, paste0("m13-region-", i, if (gray) "-grayscale" else "", ".png")), plots[[i]], width = 5.5, height = 6.1, units = "in", dpi = 200, device = ragg::agg_png, bg = "white")
}
plots <- plot_m13_region(data, family = "Helvetica")
for (i in seq_along(plots)) {
  grDevices::postscript(file.path(output, paste0("m13-region-", i, ".eps")), width = 5.5, height = 6.1, horizontal = FALSE, onefile = FALSE, paper = "special", family = "Helvetica")
  print(plots[[i]]); grDevices::dev.off()
}
writeLines(c(paste("PNG font:", font), "PNG device:ragg::agg_png; white canvas;5.5x6.1 inches,200dpi. EPS:base postscript/Helvetica fallback, opaque colors.", "Figure fig-m13-region-to-band. Synthetic normal reference: n=20, mean=50, SD=10; fixed component probabilities sqrt(.95).", "Panel1 couples candidate means/SDs. Panel2 carries two positive-boundary candidates into their normal CDFs and the full analytic envelopes.", "The two candidate curves coincide at50 exactly. Different curves attain the lower envelope on opposite sides; no jitter or altered illustration inputs.", "Blue shading is the full joint-region band, including negative-boundary extrema not individually traced. Finite20..80 score window illustrates, not proves, all-real-score coverage.", "Shared ggplot2 style; shapes, line types, and labels supplement color."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote six plotting tables, four PNGs and two EPS masters to", output, "\n")

# Retained caption/alt text are part of the source figure, copied with outputs.
for (name in c("caption.txt", "alt.txt", "panel-1-alt.txt", "panel-2-alt.txt")) file.copy(file.path(supplement_root, "inst/figures/m13-region", name), file.path(output, name), overwrite = TRUE)
