# Run: Rscript supplement/inst/examples/m01-process-figure.R
# This example assumes known probabilities. There is no reference sample or RNG.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- sub("^--file=", "", argument[[1]])
if (!file.exists(script_path)) script_path <- gsub("~+~", " ", script_path, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script_path, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens = file.path(supplement_root, "inst/style/design-tokens.csv"))
source(file.path(supplement_root, "R/book-style.R"))
source(file.path(supplement_root, "R/m01-process-figure.R"))
output <- file.path(supplement_root, "outputs/m01-process-figure")
dir.create(output, recursive = TRUE, showWarnings = FALSE)

# 1. Compute the ranks for every score, apply the cutoff, then sum selected mass.
# A rank is a label for a category, not the number of people in that category.
data <- m01_process_data()
readr::write_csv(data$law, file.path(output, "known-law.csv"))
readr::write_csv(data$decisions, file.path(output, "all-score-decisions.csv"))
readr::write_csv(data$summary, file.path(output, "rule-results.csv"))

# 2. Draw each stage independently so HTML can stack them on narrow screens.
# No extension is needed. Opaque white canvases work in both HTML reading modes.
save_panels <- function(panels, suffix = "") {
  for (i in seq_along(panels)) {
    ggplot2::ggsave(file.path(output, paste0("m01-process-", i, suffix, ".png")),
      panels[[i]], width = 3.2, height = 6.3, dpi = 300,
      device = ragg::agg_png, bg = "white")
  }
}
panels <- plot_m01_process(data)
save_panels(panels)
save_panels(plot_m01_process(data, grayscale = TRUE), "-grayscale")

# 3. Export a composite PNG and a vector master.
# PDF uses its supported Helvetica fallback; PNG uses the shared resolved font.
draw_row <- function(panels) {
  grid::grid.newpage()
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, 3)))
  for (i in seq_along(panels)) {
    print(panels[[i]], vp = grid::viewport(layout.pos.row = 1, layout.pos.col = i))
  }
  grid::popViewport()
}
ragg::agg_png(file.path(output, "m01-process.png"), width = 9.6, height = 6.3,
              units = "in", res = 300, background = "white")
draw_row(panels)
invisible(grDevices::dev.off())
grDevices::pdf(file.path(output, "m01-process.pdf"), width = 9.6, height = 6.3,
               family = "Helvetica", useDingbats = FALSE)
draw_row(plot_m01_process(data, family = "Helvetica"))
invisible(grDevices::dev.off())

alts <- c(
  "Stage 1. A known synthetic population has scores 0, 1, 2, 3 with probabilities 10%, 20%, 40%, 30%. The highlighted score-0 category contains 10 of every 100 people.",
  "Stage 2. The same score-0 category receives inclusive rank 10%, midpoint rank 5%, or strict rank 0%. A dashed line marks the fixed 5% cutoff. These are assigned ranks, not fractions of people flagged.",
  "Stage 3. Flag if rank is at most 5%. Inclusive: 10% exceeds 5%, so exclude all 10 people and flag 0% of the population. Midpoint: 5% is at most 5%; strict: 0% is at most 5%; both include all 10 people and flag 10% of the population. Full bars represent 100% of people. No other score category passes."
)
for (i in seq_along(alts)) writeLines(alts[[i]], file.path(output, paste0("panel-", i, "-alt.txt")))
writeLines(paste(alts, collapse = " "), file.path(output, "alt.txt"))
writeLines("One population, three rank conventions, one cutoff. Assigned ranks in stage 2 differ from population fractions flagged in stage 3. Midpoint ranking does not split a tied group: all people in the category receive the same rank and decision. Synthetic known-law example; no empirical-CDF estimation or population shift.", file.path(output, "caption.txt"))
writeLines(c(
  "Figure ID: fig-m01-rank-flagging; target: sec-m01-flagging, M01.",
  "Source: existing synthetic four-score table and 5% counterexample in M01.",
  "Design: known score law, rank assignment, fixed cutoff, selected population mass.",
  "Deterministic; no seed, sample or fitted distribution. Rank units: percent; mass units: population fraction.",
  "Conventions: inclusive P(Y<=y), strict P(Y<y), midpoint strict + half tie mass. Cutoff includes equality.",
  "All four scores evaluated under every convention; selected mass summed, never equated to assigned rank.",
  "Bars: panel 1 heights proportional to mass; panel 3 full strip = 100% of population.",
  "PNG panels: 3.2 x 6.3 in, 300 dpi, ragg; composite: 9.6 x 6.3 in.",
  paste("PNG font:", book_font_family(), "; PDF font: Helvetica."),
  "ragg is required for this entry point and already declared in Suggests.",
  "CSV dictionary: score = observed score; people = specified count per 100; mass = probability; *_percent = percentage ranks; selected = rank<=5; selected_mass = mass if selected, else 0; flagged_fraction = sum selected_mass.",
  "Tests: tests/testthat/test-m01-process-figure.R checks all-category ranks and selected masses; fraction comparison tolerance 1e-14."
), file.path(output, "PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()), file.path(output, "session-info.txt"))
