# M03 figure: joint law -> observed peer slice -> conditional lower tail.
argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- sub("^--file=", "", argument[[1]])
if (!file.exists(script)) script <- gsub("~+~", " ", script, fixed = TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script, mustWork = TRUE))))
project_library <- file.path(supplement_root, "renv/library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens=file.path(supplement_root,"inst/style/design-tokens.csv"))
source(file.path(supplement_root,"R/book-style.R"))
source(file.path(supplement_root,"R/m04-level-shape.R"))
source(file.path(supplement_root,"R/m04-level-shape-figure.R"))
output <- file.path(supplement_root,"outputs/m04-level-shape-figure")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
# Step 1: keep scientific data before applying a visual encoding.
input <- m04_figure_data()
for(name in names(input)) readr::write_csv(input[[name]],file.path(output,paste0(name,".csv")))
# Step 2: independently readable panels, with redundant grayscale encodings.
for(gray in c(FALSE,TRUE)) {
  plots <- plot_m04_level_shape(input,grayscale=gray)
  for(i in seq_along(plots)) ggplot2::ggsave(file.path(output,paste0("m04-level-shape-",i,if(gray) "-grayscale" else "",".png")),plots[[i]],width=3.6,height=4.6,dpi=300,device=ragg::agg_png,bg="white")
}
# Step 3: retain a vector master, using the documented portable font fallback.
grDevices::postscript(file.path(output,"m04-level-shape.eps"),width=7.2,height=9.2,family="Helvetica",horizontal=FALSE,paper="special",onefile=FALSE,bg="white")
grid::grid.newpage();grid::pushViewport(grid::viewport(layout=grid::grid.layout(2,2)))
plots <- plot_m04_level_shape(input,family="Helvetica")
for(i in seq_along(plots)) print(plots[[i]],vp=grid::viewport(layout.pos.row=ceiling(i/2),layout.pos.col=(i-1)%%2+1))
grid::popViewport();invisible(grDevices::dev.off())
alts <- c(
"Panel A. Standardized score 1 is horizontal and score 2 vertical, both from -4 to 4. A is (-1.5, 0). A solid level arrow runs from (0, 0) to (-0.75, -0.75); a dashed residual arrow ends at A. Its L is about -0.84 and Q_v about 2.81. Open-square B is (-1.5, -1.5), with L about -1.68 and Q_v zero. The gray ellipse contains 95% of reference peers; gray downward-sloping lines hold level constant in this equal-row-sum example.",
"Panel B. The same axes and covariance show a global population mean shift to (-1, -1), along the declared diagonal. Compare the solid shifted 95% ellipse with the gray reference ellipse. Squared level displacement is 1.25 and shape noncentrality zero: only level changes.",
"Panel C. The same axes and covariance show a focal population mean shift to (-1, 0). Squared level displacement is 0.3125 and shape noncentrality 1.25: both change. The solid outline is a shifted population 95% region, not a power or rejection probability.",
"Panel D. The same axes and covariance show an opposing population mean shift to (-1, 1), across the declared diagonal. Squared level displacement is zero and shape noncentrality 5: only shape changes. This is a known-law population comparison, not an observed diagnosis.")
for(i in seq_along(alts)) writeLines(alts[i],file.path(output,paste0("panel-",i,"-alt.txt")))
writeLines(paste(alts,collapse=" "),file.path(output,"alt.txt"))
writeLines("Level and residual shape under the supplied synthetic two-score reference, correlation.6. Panel A tracks origin to fitted level to residual endpoint for observed A, while B lies on the flat direction. Panels B-D separately translate global,focal and opposing population means with the same covariance. All outlines enclose95% of their stated populations; they are not power curves. The perpendicular geometry and constant-level slopes are special to equal row sums. Means, profile values, projection endpoints and noncentralities follow the chapter formulas; shared axes show the complete ellipses.",file.path(output,"caption.txt"))
writeLines(c("ID fig-m04-level-shape. No simulation,jitter,smoothing or new experiment.",
 "",
 "Ellipses use 400 angles and ascending eigenbasis columns (-1,1)/sqrt2 and (1,1)/sqrt2, with eigenvalues .4 and 1.6.",
 "Panel A shows level and shape; panels B–D show separate mean shifts. Common axes run from -4 to 4.",
 "Plain ggplot2 path,polygon,segment,point,text; identity data operations, no automatic statistical fit or extension. ",
 "All panels opaque white; shared tokens/theme, direct titles/shapes/linetypes; grayscale counterparts. PNG3.6x4.6in300dpi,ragg;EPS7.2x9.2in2x2,Helvetica fallback. Raster and vector font metrics may differ.",
 paste("Resolved PNG font:",book_font_family(),";ggplot2",packageVersion("ggplot2"),";ragg",packageVersion("ragg")),
 "ellipses: population,angle radians,score1/2 standardized units,center1/2 fixed mean. steps: level/residual operation and arrow coordinates. profiles: standardized/raw coordinates. shifts: mean displacements and two noncentralities. level_lines: constant x1+x2 for the two observed profiles only."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote four M04 panels,grayscale,data and vector master to",output,"\n")
