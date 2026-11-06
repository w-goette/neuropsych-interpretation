# Draw the two M05 teaching panels from the supplied model.
argument <- grep("^--file=",commandArgs(FALSE),value=TRUE)
script <- sub("^--file=","",argument[[1]])
if(!file.exists(script)) script <- gsub("~+~"," ",script,fixed=TRUE)
supplement_root <- dirname(dirname(dirname(normalizePath(script,mustWork=TRUE))))
project_library <- file.path(supplement_root,"renv/library")
if(dir.exists(project_library)) .libPaths(c(project_library,.libPaths()))
options(neuropsychmethods.tokens=file.path(supplement_root,"inst/style/design-tokens.csv"))
source(file.path(supplement_root,"R/book-style.R"))
source(file.path(supplement_root,"R/m05-measurement.R"))
source(file.path(supplement_root,"R/m05-interval-figure.R"))
output <- file.path(supplement_root,"outputs/m05-interval-figure")
dir.create(output,recursive=TRUE,showWarnings=FALSE)
# Step1: compute and retain data before plotting. No automatic model fit.
input <- m05_interval_figure_data()
for(name in names(input)) readr::write_csv(input[[name]],file.path(output,paste0(name,".csv")))
# Step2: the same data, independently readable color and grayscale panels.
for(gray in c(FALSE,TRUE)) {
  plots <- plot_m05_intervals(input,grayscale=gray)
  for(i in seq_along(plots)) ggplot2::ggsave(file.path(output,paste0("m05-interval-",i,if(gray)"-grayscale"else"",".png")),
    plots[[i]],width=4.6,height=5.4,dpi=300,device=ragg::agg_png,bg="white")
}
# Step3: retain a vector master. Font metrics differ from the PNG device.
grDevices::postscript(file.path(output,"m05-interval.eps"),width=9.2,height=5.4,family="Helvetica",horizontal=FALSE,paper="special",onefile=FALSE,bg="white")
grid::grid.newpage();grid::pushViewport(grid::viewport(layout=grid::grid.layout(1,2)))
plots <- plot_m05_intervals(input,family="Helvetica")
for(i in seq_along(plots)) print(plots[[i]],vp=grid::viewport(layout.pos.row=1,layout.pos.col=i))
grid::popViewport();invisible(grDevices::dev.off())
alts <- c(
 "Panel A. Four 95% interval bars on a score axis from 10 to 66 after an observed score of 35, with prior mean 50, stable variance 64 and noise variance 36. From top: credible interval for the expected score, 31.0 to 49.8; confidence interval for the expected score, 23.2 to 46.8; posterior predictive interval for the next score, 25.3 to 55.5; likelihood prediction interval, 18.4 to 51.6. Filled centers denote posterior mean 40.4; open squares denote observed score 35. A dashed vertical line marks 35 and a dot-dash line marks prior mean 50. These intervals follow one observed input; they are not sampling coverage curves.",
 "Panel B. Sampling coverage from 0 to 1 versus the fixed true expected score from 0 to 100. Confidence and likelihood prediction coincide exactly at 0.95 on one solid line. The dashed credible curve peaks near 0.99 at 50 and is about 0.36 at 20; the dotted posterior predictive curve peaks near 0.97 and is about 0.72 at 20. Markers show 20, 35 and 50. The gray prior shape is scaled for illustration, not another coverage probability. Coverage repeats the first performance and also the future performance for prediction; it does not condition on the observed score of 35.")
for(i in seq_along(alts)) writeLines(alts[i],file.path(output,paste0("panel-",i,"-alt.txt")))
writeLines(paste(alts,collapse=" "),file.path(output,"alt.txt"))
writeLines("Four nominal 95% procedures under the supplied synthetic scalar model Y given tau is normal with mean tau and variance 36; the proper population prior for tau is normal with mean 50 and variance 64. A fixes observed y = 35 and compares targets,centers and widths; B fixes each true tau and repeats data to evaluate procedure coverage. Confidence covers tau; likelihood prediction covers the next score; both have 0.95 fixed-tau coverage and therefore share one solid line. Credible and posterior predictive coverage vary with tau and average to 0.95 over the stated prior. The gray prior shape is rescaled solely to show its population weighting. No clinical calibration,change criterion or disease probability is implied.",file.path(output,"caption.txt"))
writeLines(c("",
 "R calculates the stipulated scalar law, centers, endpoints, coverage functions and marked expectations. No simulation or seed. Two panels stack on narrow HTML instead of shrinking one composite. Exact.95 line coincidence intentionally retained;no jitter/smoothing/fake separation.",
 "intervals:procedure,target,center,variance,lower,upper,level,row,label,method,shape. coverage:tau points,procedure,coverage fraction. prior:density per score point,scaled_shape max.18 for a weighting illustration. marked:six nonconstant-curve points at20,35,50.",
 "Plain ggplot2 identity linerange/point/line/area/text. ",
 "Shared design tokens/book_theme,opaque white canvas,shape/linetype and direct-label redundancy,grayscale counterparts. Panel PNG4.6x5.4in300dpi ragg;EPS composite9.2x5.4inHelvetica. Figure text not affected by browser text scaling; native full-size images and textual table/caption provide alternatives.",
 paste("Resolved PNG font:",book_font_family(),";ggplot2",packageVersion("ggplot2"),";ragg",packageVersion("ragg"))),file.path(output,"PROVENANCE.txt"))
writeLines(capture.output(sessionInfo()),file.path(output,"session-info.txt"))
cat("Wrote two M05 panels,data,grayscale and vector master to",output,"\n")
