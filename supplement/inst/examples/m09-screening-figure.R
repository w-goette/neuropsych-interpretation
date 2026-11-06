argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R"))
source(file.path(supplement_root, "R/m09-administration.R"))
source(file.path(supplement_root, "R/m09-screening-figure.R"))
output <- file.path(supplement_root, "outputs/m09-screening")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
data <- m09_figure_data()
for (name in names(data)) readr::write_csv(data[[name]], file.path(output, paste0(name, ".csv")))
font <- book_font_family(); plots <- plot_m09_screening(data, family = font); gray <- plot_m09_screening(data, gray = TRUE, family = font)
vector <- plot_m09_screening(data, family = "Helvetica")
width <- c(5.5, 5.5, 5.5); height <- c(6.6, 6.6, 3.5)
for (i in 1:3) {
  for (gray_variant in c(FALSE, TRUE)) {
    suffix <- if (gray_variant) "-gray" else ""
    ragg::agg_png(file.path(output, paste0("m09-screening-", i, suffix, ".png")), width = width[i], height = height[i], units = "in", res = 200, background = book_tokens()[["canvas_light"]])
    print((if (gray_variant) gray else plots)[[i]]); grDevices::dev.off()
  }
  grDevices::postscript(file.path(output, paste0("m09-screening-", i, ".eps")), width = width[i], height = height[i], horizontal = FALSE, onefile = FALSE, paper = "special", family = "Helvetica")
  print(vector[[i]]); grDevices::dev.off()
}
# One vector composite retains the complete logical panel sequence.
grDevices::postscript(file.path(output, "m09-screening-composite.eps"), width = 6.8, height = sum(height), horizontal = FALSE, onefile = FALSE, paper = "special", family = "Helvetica")
grid::grid.newpage(); grid::pushViewport(grid::viewport(layout = grid::grid.layout(3, 1, heights = grid::unit(height, "null"))))
for (i in 1:3) print(vector[[i]], vp = grid::viewport(layout.pos.row = i, layout.pos.col = 1), newpage = FALSE)
grDevices::dev.off()
record <- file.path(supplement_root, "inst/figures/m09-screening")
for (name in c("caption.txt", paste0("panel-", 1:3, "-alt.txt"))) file.copy(file.path(record, name), file.path(output, name), overwrite = TRUE)
writeLines(c(paste("Raster font:", font), "Raster device: ragg::agg_png,200dpi,opaque shared white canvas.", "Vector: base postscript EPS with Helvetica fallback; font metrics need not match PNG.", "No simulation or random seed: analytic score-plane boundaries and law values.", "", "Original stable figure ID: fig-m09-selected-history. Values and experiment preserved.", "Figure-specific data/alt/caption/source mappings are retained in inst/figures/m09-screening/."), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
message("M09 figure panels saved to ", output)
