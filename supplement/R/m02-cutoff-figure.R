# Keep data construction separate from appearance. No stochastic samples.
m02_figure_data <- function() {
  zeta <- m02_cutoffs()
  # Include exactly 0.05 as a shading boundary in the evaluation grid.
  grid <- sort(unique(c(seq(.0005,.25,length.out=500),.05)))
  data <- dplyr::bind_rows(lapply(names(zeta),function(rule) {
    coefficient <- zeta[[rule]]
    density <- m02_content_density(grid, coefficient)
    tibble::tibble(rule=rule,population_fraction=grid,density=density)
  }))
  summary <- tibble::tibble(rule=names(zeta),coefficient=as.numeric(zeta),cutoff=50+10*zeta,
    mean_fraction=stats::pt(zeta/sqrt(1+1/20),19),
    studies_above_05=vapply(zeta,function(z)1-m02_content_cdf(.05,z),numeric(1)),
    omitted_lower_plot_mass=vapply(zeta,function(z)m02_content_cdf(.0005,z),numeric(1)),
    omitted_upper_plot_mass=vapply(zeta,function(z)1-m02_content_cdf(.25,z),numeric(1)))
  list(data=data,summary=summary)
}
plot_m02_cutoff <- function(input,grayscale=FALSE,family=book_font_family()) {
  palette <- if(grayscale)c("#333333","#666666") else unname(book_palette(2))
  line_types <- c("solid","longdash")
  titles <- c("Content-calibrated rule","Mean-calibrated rule")
  common_top <- 80
  lapply(seq_len(nrow(input$summary)),function(i) {
    row <- input$summary[i,];data <- dplyr::filter(input$data,rule==row$rule)
    shaded <- dplyr::filter(data,population_fraction>=.05)
    blend <- as.numeric(.8 * grDevices::col2rgb(book_tokens()[["canvas_light"]]) + .2 * grDevices::col2rgb(palette[[i]])) / 255
    shade <- grDevices::rgb(blend[[1]], blend[[2]], blend[[3]])
    ggplot2::ggplot(data,ggplot2::aes(x=population_fraction,y=density))+
      ggplot2::geom_ribbon(data=shaded,ggplot2::aes(ymin=0,ymax=density),
        stat="identity",position="identity",fill=shade,alpha=1)+
      ggplot2::geom_line(colour=palette[[i]],linetype=line_types[[i]],linewidth=.85)+
      ggplot2::geom_vline(xintercept=.05,linetype="dotted",linewidth=.5,colour=unname(book_tokens()[["text_light"]]))+
      ggplot2::scale_x_continuous(limits=c(0,.25),breaks=seq(0,.25,.05),labels=sprintf("%.2f",seq(0,.25,.05)),expand=ggplot2::expansion(mult=c(.01,.02)))+
      ggplot2::scale_y_continuous(limits=c(0,common_top),breaks=seq(0,80,20),expand=ggplot2::expansion(mult=c(0,.01)))+
      ggplot2::labs(title=paste0(i,". ",titles[[i]]),subtitle=sprintf("Cutoff %.1f; norms n = 20",row$cutoff),
        x="Population fraction flagged",y="Density across norm studies",
        caption=sprintf("Mean flagged: %.2f%% of peers\nAbove 5%% content: %.1f%% of studies",100*row$mean_fraction,100*row$studies_above_05))+
      book_theme(base_size=11.5,base_family=family)+
      ggplot2::theme(plot.title=ggplot2::element_text(size=12,face="bold"),
        plot.subtitle=ggplot2::element_text(size=10.5),plot.caption=ggplot2::element_text(size=11,hjust=0),
        axis.text=ggplot2::element_text(size=10),axis.title=ggplot2::element_text(size=10.5),
        plot.margin=ggplot2::margin(8,9,8,8))
  })
}
