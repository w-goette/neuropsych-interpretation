# Rebuild M07's two figures as five responsive panels; deterministic, no seed.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE); script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R")); source(file.path(supplement_root, "R/m07-norms.R")); source(file.path(supplement_root, "R/m07-norms-figure.R"))
output <- file.path(supplement_root, "outputs/m07-norms-figure"); dir.create(output, recursive = TRUE, showWarnings = FALSE)
input <- m07_figure_data()
for (name in names(input)) readr::write_csv(input[[name]], file.path(output, paste0(name, ".csv")))
for (gray in c(FALSE, TRUE)) {
  plots <- plot_m07_norms(input, grayscale = gray)
  for (i in seq_along(plots)) ggplot2::ggsave(file.path(output, paste0("m07-norms-", i, if (gray) "-grayscale" else "", ".png")),
    plots[[i]], width = if (i <= 3) 3.8 else 4.6, height = 5.1, dpi = 300, device = ragg::agg_png, bg = "white")
}
for (group in c("references", "calibration")) {
  plots <- plot_m07_norms(input, family = "Helvetica"); indices <- if (group == "references") 1:3 else 4:5
  grDevices::postscript(file.path(output, paste0("m07-", group, ".eps")), width = (if (group == "references") 3.8 else 4.6) * length(indices), height = 5.1,
    family = "Helvetica", horizontal = FALSE, paper = "special", onefile = FALSE, bg = "white")
  grid::grid.newpage(); grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, length(indices))))
  for (j in seq_along(indices)) print(plots[[indices[j]]], vp = grid::viewport(layout.pos.row = 1, layout.pos.col = j))
  grid::popViewport(); invisible(grDevices::dev.off())
}
alts <- c(
  "Panel A. Reference density of observed score y for C0 peers, normal mean 50, SD 10. A solid curve and a vertical line at 35; shaded probability below 35 is 0.067.",
  "Panel B. Reference density for C1 peers, normal mean 40, SD 5. A dashed curve and the same vertical line at 35; shaded probability is 0.159. The performance stayed fixed while peers changed.",
  "Panel C. Dotted density for the equal-weight mixture of the two supplied groups; probability below 35 is 0.113. A long-dashed moment-matched normal has probability 0.143 at 35. Same mean and variance do not determine the percentile.",
  "Measurement panel A. Two parallel response lines against latent h from minus 3 to 3: group 0 observed score equals h; group 1 equals h+2. At h = 0 the scores differ by 2. Solid/dashed lines distinguish groups.",
  "Calibration panel B. Each group's true conditional percentile is converted to a normal quantile. Both reports equal h at every coordinate; a thin dashed line lies exactly on a thicker solid line. Exact coincidence is intentional, with no jitter or fabricated separation. This calibration coexists with different measurement relations in panel A.")
for (i in seq_along(alts)) writeLines(alts[i], file.path(output, paste0("panel-", i, "-alt.txt")))
writeLines(paste(alts, collapse = " "), file.path(output, "alt.txt"))
writeLines(c("Synthetic inputs/targets preserved from existing fig-m07-three-references and fig-m07-calibrated-not-invariant. Fixed score 35; original normal laws, mixture weights and Y=H+2C model. No empirical data or estimated parameters.",
  "Reference process: declared peers -> true CDF at the same observed 35 -> differing tail probabilities. Calibration process: observed group-offset relation -> correct conditional CDF and inverse-normal operation -> identical normalized reports. Two panels encode different quantities, not before/after measurements.",
  "Panel 5 overlap is exact algebra, not insufficient grid resolution. Do not jitter, separate or smooth. Evaluation grid: scores 5 to 85 by .05 and h=-3 to 3 by .02. Every density and value is retained as CSV and checked against the original formulas.",
  "The two scientific diagrams retain their chapter laws, values and stable figure IDs. R source uses shared book_theme/book_tokens, explicit identity lines/ribbons and redundant linetypes. ",
  "PNG: ragg, 300 dpi, reference panels 3.8 by 5.1 in; calibration panels 4.6 by 5.1 in, opaque white canvas, color/grayscale. EPS composite masters: Helvetica fallback; no identical font metrics promised.",
  "",
  paste("PNG font:", book_font_family(), ";ggplot2", packageVersion("ggplot2"), ";ragg", packageVersion("ragg"))), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Five M07 panels,data,grayscale counterparts and vector masters written\n")
