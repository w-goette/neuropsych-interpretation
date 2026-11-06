# M02 two-rule content laws: same synthetic inputs, independently readable panels.
argument <- grep("^--file=",commandArgs(FALSE),value=TRUE)
script_path <- sub("^--file=","",argument[[1]])
if(!file.exists(script_path))script_path<-gsub("~+~"," ",script_path,fixed=TRUE)
supplement_root<-dirname(dirname(dirname(normalizePath(script_path,mustWork=TRUE))))
project_library<-file.path(supplement_root,"renv","library")
if(dir.exists(project_library)).libPaths(c(project_library,.libPaths()))
options(neuropsychmethods.tokens=file.path(supplement_root,"inst/style/design-tokens.csv"))
source(file.path(supplement_root,"R/book-style.R"))
source(file.path(supplement_root,"R/m02-finite-reference.R"))
source(file.path(supplement_root,"R/m02-cutoff-figure.R"))
output<-file.path(supplement_root,"outputs/m02-cutoff")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
# 1. Evaluate the exact-law density numerically, not by simulated norm samples.
input<-m02_figure_data()
readr::write_csv(input$data,file.path(output,"density-data.csv"))
readr::write_csv(input$summary,file.path(output,"rule-summary.csv"))
# 2. Each panel is sized for reading as a separate phone-width figure.
for(gray in c(FALSE,TRUE)) {
  panels<-plot_m02_cutoff(input,grayscale=gray)
  suffix<-if(gray)"-grayscale" else ""
  for(i in seq_along(panels))ggplot2::ggsave(file.path(output,paste0("m02-cutoff-",i,suffix,".png")),
    panels[[i]],width=3.4,height=4.1,dpi=300,device=ragg::agg_png,bg="white")
}
# 3. Keep a genuine vector composite using the portable base PostScript device.
# The base EPS device supplies a vector composite.
grDevices::postscript(file.path(output,"m02-cutoff.eps"),width=6.8,height=4.1,
  family="Helvetica",horizontal=FALSE,paper="special",onefile=FALSE,bg="white")
grid::grid.newpage();grid::pushViewport(grid::viewport(layout=grid::grid.layout(1,2)))
panels<-plot_m02_cutoff(input,family="Helvetica")
for(i in seq_along(panels))print(panels[[i]],vp=grid::viewport(layout.pos.row=1,layout.pos.col=i))
grid::popViewport();invisible(grDevices::dev.off())
alts<-c(
 "Content-calibrated rule fitted from 20 synthetic norms, cutoff 26.0. Density across norming studies against achieved population fraction 0 to 0.25; solid blue curve peaks near zero. Dotted line at 0.05; shade to its right. Mean flagged population 1.52%; 5.0% of norm studies exceed 5% content.",
 "Mean-calibrated rule from the same 20 synthetic norm summaries, cutoff 32.3. Same density axes 0 to 0.25 and 0 to 80; dashed orange curve is broader. Mean flagged population 5.00%; 39.2% of norm studies exceed 5% content. Mean control and upper-content control answer different questions.")
for(i in seq_along(alts))writeLines(alts[[i]],file.path(output,paste0("panel-",i,"-alt.txt")))
writeLines(paste(alts,collapse=" "),file.path(output,"alt.txt"))
writeLines("Sampling densities of achieved lower-tail content for two prespecified fitting rules with 20 independent normal-reference persons. Same coefficients and synthetic summaries as M02: cutoff 26.0 controls content at most 5% in 95% of norm studies; cutoff 32.3 controls mean flagging at 5%. Both panels use common axes; dotted line is population fraction 0.05 and shading shows the displayed density above it. Readouts use the entire law, while plotted curves cover 0.0005 to 0.25. Under the specified reference prior these are also posterior densities at the realized cutoffs; proper-prior laws differ.",file.path(output,"caption.txt"))
writeLines(c(
 "Figure ID fig-m02-cutoff-content; target sec-m02-cutoff-example.",
 "Same normal law, n20, u.05, gamma.95, synthetic mean50/sd10 and two calibrated coefficients. No new true population parameters or patient data.",
 "500 grid values per rule, already including the exact .05 boundary; continuous density from differentiating the stated chi-square mixture, evaluated by adaptive quadrature.",
 "Axes population fraction and density per unit population fraction. Full-law mean/tail readouts are not inferred from truncated shaded geometry. Omitted masses saved in rule-summary.csv.",
 "Shared axes 0..0.25 and0..80; blue solid / orange dashed plus separate titles survive grayscale. Same data, no jitter/smoothing.",
 "Deterministic; no RNG/seed. PNG each3.4x4.1in/300dpi, ragg; vector composite6.8x4.1in, base EPS with Helvetica fallback.",
 paste("Resolved font:",book_font_family(),"; ggplot2",packageVersion("ggplot2"),"; ragg",packageVersion("ragg")),
 "Base EPS supplies vector geometry. Opaque shaded fill uses the same white/series blend in all devices.",
 "Plain geom_line/geom_ribbon stat identity/position identity; no density estimation or automatic statistical summary.",
 "",
 "Data dictionary: rule prespecified fitting objective; population_fraction achieved population flagging fraction; density across norm samples per unit population fraction; coefficient dimensionless; cutoff score units; mean_fraction average population fraction; studies_above_05 fraction of norm samples exceeding.05; omitted_lower/upper_plot_mass refer only to finite displayed range."
),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote M02 cutoff figure to",output,"\n")
