# M03 figure: joint law -> observed peer slice -> conditional lower tail.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R"))
source(file.path(supplement_root, "R/m03-correlated-battery.R"))
source(file.path(supplement_root, "R/m03-conditional-figure.R"))
output <- file.path(supplement_root, "outputs/m03-conditional")
dir.create(output, recursive = TRUE, showWarnings = FALSE)
# 1. Save the mathematical objects before choosing their visual appearance.
input <- m03_figure_data()
for (name in names(input)) readr::write_csv(input[[name]], file.path(output, paste0(name, ".csv")))
# 2. Export independently readable panels, with a grayscale counterpart.
for (gray in c(FALSE, TRUE)) {
  panels <- plot_m03_conditional(input, grayscale = gray)
  suffix <- if (gray) "-grayscale" else ""
  for (i in seq_along(panels)) ggplot2::ggsave(file.path(output, paste0("m03-conditional-", i, suffix, ".png")),
    panels[[i]], width = 3.4, height = 4.3, dpi = 300, device = ragg::agg_png, bg = "white")
}
# 3. Base EPS provides a vector master without adding a graphics dependency.
grDevices::postscript(file.path(output, "m03-conditional.eps"), width = 10.2, height = 4.3,
  family = "Helvetica", horizontal = FALSE, paper = "special", onefile = FALSE, bg = "white")
grid::grid.newpage()
grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, 3)))
plots <- plot_m03_conditional(input, family = "Helvetica")
for (i in seq_along(plots)) print(plots[[i]], vp = grid::viewport(layout.pos.row = 1, layout.pos.col = i))
grid::popViewport()
invisible(grDevices::dev.off())
alts <- c(
  "Joint distribution of two synthetic observed test scores: score 2 horizontal, score 1 vertical, both axes 20 to 80. Correlation 0.6 tilts 50% and 95% ellipses upward. Bars at score 2=50 and 35 have score 1 means 50 and 41, each +/-16. Circle A=(35,50) and open square B=(35,35) share score 1=35.",
  "Score 1 reference densities for all peers (dashed) and peers with score 2=50 (solid), on common axes with the next panel. The conditional mean is 50, SD8. Dotted cutoff at the observed 35; shaded conditional lower tail is 3.04% of this slice versus 6.68% of all peers.",
  "Same score 1 density axes, now conditioning on score 2=35. The solid conditional curve moves to mean 41 while its SD stays 8; dashed all-peer curve is unchanged. At the observed 35, the conditional lower tail is 22.66%, versus the unchanged marginal 6.68%."
)
for (i in seq_along(alts)) writeLines(alts[[i]], file.path(output, paste0("panel-", i, "-alt.txt")))
writeLines(paste(alts, collapse = " "), file.path(output, "alt.txt"))
writeLines("Conditional comparisons under the supplied synthetic observed-score law. Panel1 preserves the joint ellipse/slice construction; panels2 and3 separately show the distribution for score1 among peers with score2=50 and35. Dashed curves show the unchanged marginal law N(50,100); solid conditional laws are N(50,64) and N(41,64). Shading is to the left of the observed35 in each conditional law. Conditional lower tails are3.04% and22.66%; marginal lower tail6.68%. Tail readouts integrate the full laws, while density curves cover8 to85; omitted masses are saved. These distributions compare different people, not personal retest or latent scores.", file.path(output, "caption.txt"))
writeLines(c(
 "Figure ID fig-m03-conditional-slices; same source law, profiles, axes orientation and50%/95% regions as eq-m03-example-law.",
 "",
 "Density grid: 900 positions plus the exact score 35. Ellipses: 400 angles, fixed lower Cholesky and chi-square radii. No simulation or smoothing.",
 "Process: supplied law and two observed profiles -> fixed score2 slices -> conditional center/spread -> lower-tail score1 proportions. No cutoff rule or fitting experiment added.",
 "Two conditional comparisons each show the all-peer dashed curve and the corresponding blue conditional curve. Line types, titles, shapes, and grayscale distinguish the comparisons.",
 "Density y axis probability per score unit; score axes in observed units. Lower-tail readouts use full distributions; omitted plotted masses in summaries.csv.",
 "Plain ggplot2 geom_path/geom_line/geom_ribbon, identity statistics/position; no automatic fit. Shared tokens/theme, opaque white canvas.",
 "PNG each3.4x4.3in,300dpi,ragg. EPS vector composite10.2x4.3in,Helvetica fallback; font metrics need not equal raster.",
 paste("Resolved PNG font:", book_font_family(), "; ggplot2", packageVersion("ggplot2"), "; ragg", packageVersion("ragg")),
 "",
 "Plot dictionaries: ellipses level=central probability,angle=radians,score2/score1=units; densities conditional_density/marginal_density=probability per unit; summaries conditional_sd=SD,conditional/marginal_tail=fractions,omitted_*_mass=fractions outside plotted range; slices low/high=conditional mean+/-2SD; profiles explicitly ordered(score1,score2) in labels."
), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
cat("Wrote three M03 panels, grayscale versions and vector master to", output, "\n")
