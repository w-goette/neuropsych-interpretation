# Reproduce the existing M12 precision figure as two responsive R/ggplot2 panels.
argument <- grep("^--file=",commandArgs(FALSE),value=TRUE);script <- sub("^--file=","",argument[[1]])
if(!file.exists(script)) script <- gsub("~+~"," ",script,fixed=TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script,mustWork=TRUE))))
project_library <- file.path(supplement_root, "renv", "library")
if (dir.exists(project_library)) .libPaths(c(project_library, .libPaths()))
options(neuropsychmethods.tokens=file.path(supplement_root,"inst/style/design-tokens.csv"))
source(file.path(supplement_root,"R/book-style.R"));source(file.path(supplement_root,"R/m12-design.R"));source(file.path(supplement_root,"R/m12-next-observation-figure.R"))
output <- file.path(supplement_root,"outputs/m12-next-observation-figure");dir.create(output,recursive=TRUE,showWarnings=FALSE)
data <- m12_figure_data()
for(name in names(data))readr::write_csv(data[[name]],file.path(output,paste0(name,".csv")))
font <- book_font_family()
for(gray in c(FALSE,TRUE)) {
  plots <- plot_m12_next_observation(data,gray,font)
  for(i in seq_along(plots))ggplot2::ggsave(file.path(output,paste0("m12-next-observation-",i,if(gray)"-grayscale" else "",".png")),plots[[i]],width=5.5,height=5.4,units="in",dpi=200,device=ragg::agg_png,bg="white")
}
plots <- plot_m12_next_observation(data,family="Helvetica")
for(i in seq_along(plots)) {
  grDevices::postscript(file.path(output,paste0("m12-next-observation-",i,".eps")),width=5.5,height=5.4,horizontal=FALSE,onefile=FALSE,paper="special",family="Helvetica");print(plots[[i]]);grDevices::dev.off()
}
grDevices::postscript(file.path(output,"m12-next-observation-composite.eps"),width=5.5,height=10.8,horizontal=FALSE,onefile=FALSE,paper="special",family="Helvetica")
grid::grid.newpage();grid::pushViewport(grid::viewport(layout=grid::grid.layout(2,1)))
for(i in 1:2) print(plots[[i]],vp=grid::viewport(layout.pos.row=i,layout.pos.col=1))
grDevices::dev.off()
writeLines(c(paste("PNG font:",font),"PNG: ragg::agg_png, white canvas,200dpi, separate5.5x5.4in panels.","Vector EPS panels and composite: base postscript with Helvetica fallback; metrics may differ from PNG.","","Same independent standard-normal coordinates, initial covariance diag(1/2,1), unit-error additions and exact integer best splits k0–8.","Overlap at k0,1,2 is exact; no jitter or altered data. Panel A y-range0–0.6 improves use of space; panel B0–1.6. Variance units unchanged.","No new experiment, clinical target, uncertainty band or simulation."),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Saved three data tables, four PNGs, two EPS panels and a composite master to",output,"\n")
