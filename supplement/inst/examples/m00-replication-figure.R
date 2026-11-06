# Run from the source root with Rscript --vanilla supplement/inst/examples/m00-replication-figure.R
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
for (file in c("book-style.R", "m00-replication.R", "m00-replication-figure.R")) {
  source(file.path(supplement_root, "R", file))
}
output <- file.path(supplement_root, "outputs/m00-replication-figure")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
result <- m00_evaluate_replication(m00_replication_law())
data <- m00_replication_figure_data(result)
for (name in c("law", "summary")) readr::write_csv(result[[name]], file.path(output, paste0(name, ".csv")))
readr::write_csv(data, file.path(output, "geometry.csv"))
font <- book_font_family()
for (gray in c(FALSE, TRUE)) {
  plots <- plot_m00_replication(data, gray, font)
  for (i in seq_along(plots)) ggplot2::ggsave(
    file.path(output, paste0("m00-replication-", i, if (gray) "-grayscale" else "", ".png")),
    plots[[i]], width = 5.5, height = 3.8, units = "in", dpi = 200,
    device = ragg::agg_png, bg = "white")
}
vector <- plot_m00_replication(data, family = "Helvetica")
for (i in seq_along(vector)) {
  grDevices::postscript(file.path(output, paste0("m00-replication-", i, ".eps")),
    width = 5.5, height = 3.8, horizontal = FALSE, onefile = FALSE,
    paper = "special", family = "Helvetica")
  print(vector[[i]]); grDevices::dev.off()
}
writeLines(c(
  "Two stipulated finite repeat laws for a fixed synthetic person. No sample or fitted model.",
  "Universe1: 32,35,38. Universe2: 35,38,41. Each probability 1/3. Observed 35 fixed.",
  "Rows distinguish objects, not time or frequency. No jitter: expected and observed coincide in Universe1.",
  paste("PNG font:", font), "PNG: ragg::agg_png, 5.5x3.8in, 200dpi, opaque white; grayscale counterparts.",
  "EPS: base postscript, Helvetica fallback, same coordinates; font metrics/timestamp can differ.",
  "Common score axes30..43; values/markers from geometry.csv and law/summary.csv.",
  "No RNG, seed, new package/extension, clinical interpretation or causal arrow."
), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
writeLines("The same observed score under two declared replication universes. Each of the three possible scores has probability 1/3. Expected performance is 35 in Universe 1 and 38 in Universe 2; the observed score stays 35, so its residual is 0 or -3. Rows separate kinds of quantity, not occasions. These supplied laws are synthetic and identify no latent ability or diagnosis.", file.path(output, "caption.txt"))
writeLines(c(
  "Universe 1, a supplied three-value repeat law. Possible scores 32, 35, 38, each probability 1/3, are circles on the first row. Their expected score 35 is a diamond on the second row. Observed 35 is a triangle on the third row. Its residual is 0; separate rows show equal values without jitter.",
  "Universe 2 on the same score axis. Possible scores 35, 38, 41, each probability 1/3. The expected score is 38, while the observed score stays 35. The observed residual is -3. Rows and marker shapes distinguish possible repeats, their average and the single observation."
), file.path(output, "alt.txt"))
cat("Wrote three CSVs, four color/grayscale PNGs and two EPS masters to", output, "\n")
