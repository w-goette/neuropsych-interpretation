# Rebuild M06 information and posterior panels using declared synthetic inputs.
argument<-grep("^--file=",commandArgs(FALSE),value=TRUE)
script<-sub("^--file=","",argument[[1]])
if(!file.exists(script)) script<-gsub("~+~"," ",script,fixed=TRUE)
supplement_root<-dirname(dirname(dirname(normalizePath(script,mustWork=TRUE))))
project_library<-file.path(supplement_root,"renv/library")
if(dir.exists(project_library)) .libPaths(c(project_library,.libPaths()))
options(neuropsychmethods.tokens=file.path(supplement_root,"inst/style/design-tokens.csv"))
source(file.path(supplement_root,"R/book-style.R"));source(file.path(supplement_root,"R/m06-items.R"));source(file.path(supplement_root,"R/m06-items-figure.R"))
output<-file.path(supplement_root,"outputs/m06-items-figure");dir.create(output,recursive=TRUE,showWarnings=FALSE)
input<-m06_figure_data()
for(name in names(input)) readr::write_csv(input[[name]],file.path(output,paste0(name,".csv")))
for(gray in c(FALSE,TRUE)) {
  plots<-plot_m06_items(input,grayscale=gray)
  for(i in seq_along(plots)) ggplot2::ggsave(file.path(output,paste0("m06-items-",i,if(gray)"-grayscale"else"",".png")),plots[[i]],width=4.6,height=5.4,dpi=300,device=ragg::agg_png,bg="white")
}
# Vector masters use a recorded Helvetica fallback, not a promised identical font.
for(group in c("information","posterior")) {
  plots<-plot_m06_items(input,family="Helvetica");indices<-if(group=="information") 1:2 else 3
  grDevices::postscript(file.path(output,paste0("m06-",group,".eps")),width=if(group=="information")9.2 else 4.6,height=5.4,family="Helvetica",horizontal=FALSE,paper="special",onefile=FALSE,bg="white")
  grid::grid.newpage();grid::pushViewport(grid::viewport(layout=grid::grid.layout(1,length(indices))))
  for(j in seq_along(indices)) print(plots[[indices[j]]],vp=grid::viewport(layout.pos.row=1,layout.pos.col=j))
  grid::popViewport();invisible(grDevices::dev.off())
}
alts<-c(
 "Panel A. Three information curves against latent coordinate h from minus5 to6 for fixed two-item logistic responses. Solid full-pattern information is at least dashed total information,which is at least dotted moment bound. Markers at h=0 show approximately.670,.617,.596. All decrease toward zero in distant tails.",
 "Panel B. Shares of full-pattern information over the same coordinate range. Full pattern is1 throughout. Total retained share is about.922 at0,and about.89 at its minimum near2.7. Moment-bound share is about.890 at0. A share near1 in distant tails does not mean high absolute information;compare panel A.",
 "Posterior densities on latent coordinate h under a normal prior with mean0 and variance1. Solid pattern10 has mean.0667;dashed pattern01 has mean.6250;dotted total-only posterior is their prior-predictive mixture with mean.1567. The long-dashed prior is included. Short vertical marks at the baseline show posterior means;top triangles mark likelihood estimates.3336 and1.2301. All curves are numerical evaluations of the same known-item model,not a normal approximation to each posterior.")
for(i in seq_along(alts)) writeLines(alts[i],file.path(output,paste0("panel-",i,"-alt.txt")))
writeLines(paste(alts,collapse=" "),file.path(output,"alt.txt"))
writeLines(c("Synthetic item model: slopes 1 and 2; difficulties 0 and 1; standard normal prior for the posterior only. Deterministic calculations; no clinical cutoff.",
 "Information:fixed response kernel -> finite pattern probabilities -> scoring into totals -> exact local information and moment bound;panelB divides each by full-pattern information. Posterior:pattern likelihood -> normal-prior weighting -> pattern/total-only density mixture. Mean marks and MLE triangles have different meanings.",
 "Near-overlap is real numerical closeness;total-only posterior is dominated by more likely pattern10. Grid resolution is.01;no jitter,smoothing or artificial curve separation. Retain separate absolute/share panels and clear line types instead of changing illustration data.",
 "Inputs and calculations are defined in the supplied R source using finite sums and adaptive quadrature.",
 "PNG uses ragg,300dpi,opaque white canvas,shared book_theme/book_tokens and resolved font below. Information panels4.6x5.4in;posterior4.6x5.4in. Color and grayscale counterparts;EPS composite masters use Helvetica fallback. ",
 "",
 paste("Resolved PNG font:",book_font_family(),";ggplot2",packageVersion("ggplot2"),";ragg",packageVersion("ragg"))),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Three M06 panels,data,grayscale and EPS masters written to",output,"\n")
