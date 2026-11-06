# Same covariance updates, two independently readable targets. No new experiment.
m12_figure_data <- function() {
  path <- m12_paths()
  list(h1 = path[path$strategy != "Best split",c("added","strategy","h1_variance")],
    contrast = path[,c("added","strategy","contrast_variance")],
    readout = tibble::tibble(target=c("H1","H1","H1-H2","H1-H2"),new_observation=c("H1","H2","H1","H2"),starting_variance=c(.5,.5,1.5,1.5),next_variance=c(1/3,.5,4/3,1),variance_gain=c(1/6,0,1/6,1/2)))
}
plot_m12_next_observation <- function(data=m12_figure_data(),gray=FALSE,family=book_font_family()) {
  levels <- c("Repeat H1","Measure H2","Best split");tokens <- book_tokens();ink <- tokens[["text_light"]];muted <- tokens[["muted_light"]]
  colors <- if(gray) c(grDevices::gray(.1),grDevices::gray(.4),grDevices::gray(.48)) else c(unname(book_palette(2)),unname(book_palette(3)[3]))
  names(colors) <- levels
  theme <- book_theme(17,family)+ggplot2::theme(plot.title=ggplot2::element_text(size=20,face="bold"),plot.subtitle=ggplot2::element_text(size=15),axis.title=ggplot2::element_text(size=18),axis.text=ggplot2::element_text(size=17),legend.position="bottom",legend.title=ggplot2::element_blank(),legend.text=ggplot2::element_text(size=17),plot.margin=ggplot2::margin(12,14,12,12))
  scales <- list(ggplot2::scale_colour_manual(values=colors,breaks=levels),ggplot2::scale_linetype_manual(values=c("Repeat H1"="solid","Measure H2"="dashed","Best split"="dotted"),breaks=levels),ggplot2::scale_shape_manual(values=c("Repeat H1"=16,"Measure H2"=22,"Best split"=17),breaks=levels),ggplot2::scale_x_continuous(breaks=0:8),ggplot2::guides(colour=ggplot2::guide_legend(ncol=1),linetype=ggplot2::guide_legend(ncol=1),shape=ggplot2::guide_legend(ncol=1)))
  a <- ggplot2::ggplot(data$h1,ggplot2::aes(added,h1_variance,colour=strategy,linetype=strategy,shape=strategy))+
    ggplot2::geom_line(linewidth=.9)+ggplot2::geom_point(size=2.7,fill="white",stroke=.8)+
    ggplot2::annotate("text",x=8,y=.55,label="Measure H2: no gain",hjust=1,size=5.5,family=family,colour=muted)+
    ggplot2::annotate("text",x=3,y=.39,label="Repeat H1:\n1/3 after one addition",hjust=0,size=5.5,family=family,colour=ink)+
    ggplot2::scale_y_continuous(breaks=seq(0,.6,.1),limits=c(0,.6))+ggplot2::coord_cartesian(xlim=c(-.1,8.1),expand=FALSE)+
    ggplot2::labs(title="A. Precision for H1",subtitle="Independent coordinates; H1 already measured once",x="Added observations, k",y="Posterior variance")+scales+theme
  b <- ggplot2::ggplot(data$contrast,ggplot2::aes(added,contrast_variance,colour=strategy,linetype=strategy,shape=strategy))+
    ggplot2::geom_hline(yintercept=1,linetype="longdash",colour=muted,linewidth=.55)+
    ggplot2::geom_line(linewidth=.9)+ggplot2::geom_point(size=2.7,fill="white",stroke=.8)+
    ggplot2::annotate("text",x=8,y=1.45,label="Unmeasured H2 variance: 1",hjust=1,size=5.5,family=family,colour=muted)+
    ggplot2::annotate("text",x=.2,y=.23,label="First-addition gain:\nH1: 1/6; H2: 1/2",hjust=0,size=5.5,family=family,colour=ink)+
    ggplot2::scale_y_continuous(breaks=c(0,.5,1,1.5),limits=c(0,1.6))+ggplot2::coord_cartesian(xlim=c(-.1,8.1),expand=FALSE)+
    ggplot2::labs(title="B. Precision for H1 minus H2",subtitle="Same observations; now both coordinates matter",x="Added observations, k",y="Posterior variance")+scales+theme
  list(h1=a,contrast=b)
}
