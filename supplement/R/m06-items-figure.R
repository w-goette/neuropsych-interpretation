# Two existing M06 teaching figures, exported as three responsive panels.
m06_figure_data <- function() {
  info<-m06_information()
  p10<-m06_posterior(c(1,0));p01<-m06_posterior(c(0,1));total<-m06_posterior(total=1)
  h<-seq(-4,4.5,.01)
  density<-tibble::tibble(h=h,Prior=stats::dnorm(h),`Pattern 10`=p10$density(h),
    `Pattern 01`=p01$density(h),`Total only`=total$density(h)) |>
    tidyr::pivot_longer(-h,names_to="observation",values_to="density")
  means<-tibble::tibble(observation=c("Pattern 10","Pattern 01","Total only"),
    h=c(p10$summary$mean,p01$summary$mean,total$summary$mean))
  mle<-tibble::tibble(observation=c("Pattern 10","Pattern 01"),h=c(p10$summary$MLE,p01$summary$MLE))
  list(information=info,density=density,means=means,mle=mle)
}
plot_m06_items <- function(input=m06_figure_data(),grayscale=FALSE,family=book_font_family()) {
  tokens<-book_tokens()
  types<-c("Full pattern"="solid","Total score"="dashed","Moment bound"="dotted")
  colors<-c("Full pattern"=tokens[["brand_navy"]],"Total score"=tokens[["plot_blue"]],"Moment bound"=tokens[["plot_orange"]])
  if(grayscale) colors[]<-tokens[["text_light"]]
  common<-book_theme(base_size=14,base_family=family)+ggplot2::theme(
    plot.title=ggplot2::element_text(size=14,face="bold"),plot.subtitle=ggplot2::element_text(size=11),
    axis.text=ggplot2::element_text(size=12),legend.text=ggplot2::element_text(size=12),
    legend.key.width=grid::unit(1.7,"lines"),plot.margin=ggplot2::margin(12,12,12,12),legend.position="bottom")
  info<-input$information |>
    dplyr::transmute(h,`Full pattern`=pattern_information,`Total score`=total_information,`Moment bound`=moment_bound) |>
    tidyr::pivot_longer(-h,names_to="quantity",values_to="information")
  marked<-info |> dplyr::filter(abs(h)<1e-10)
  a<-ggplot2::ggplot(info,ggplot2::aes(h,information,color=quantity,linetype=quantity))+
    ggplot2::geom_line(linewidth=.85)+ggplot2::geom_point(data=marked,ggplot2::aes(shape=quantity),size=2.8,fill="white",stroke=.9)+
    ggplot2::scale_color_manual(values=colors,breaks=names(types))+ggplot2::scale_linetype_manual(values=types,breaks=names(types))+
    ggplot2::scale_shape_manual(values=c("Full pattern"=21,"Total score"=22,"Moment bound"=24))+
    ggplot2::labs(title="A  Information at each coordinate",subtitle="Known slopes 1, 2; difficulties 0, 1",x="Latent coordinate h",y="Information\n(per coordinate squared)",color=NULL,linetype=NULL,shape=NULL)+
    ggplot2::scale_x_continuous(breaks=c(-4,-2,0,2,4,6))+
    common+ggplot2::guides(color=ggplot2::guide_legend(ncol=1,override.aes=list(shape=c(21,22,24),fill="white")),linetype=ggplot2::guide_legend(ncol=1),shape="none")
  share<-input$information |>
    dplyr::transmute(h,`Full pattern`=1,`Total score`=total_share,`Moment bound`=moment_share) |>
    tidyr::pivot_longer(-h,names_to="quantity",values_to="share")
  b<-ggplot2::ggplot(share,ggplot2::aes(h,share,color=quantity,linetype=quantity))+
    ggplot2::geom_line(linewidth=.85)+ggplot2::scale_color_manual(values=colors,breaks=names(types))+ggplot2::scale_linetype_manual(values=types,breaks=names(types))+
    ggplot2::scale_y_continuous(limits=c(.85,1.005),breaks=c(.85,.90,.95,1))+
    ggplot2::scale_x_continuous(breaks=c(-4,-2,0,2,4,6))+
    ggplot2::labs(title="B  Share retained
by the report",subtitle="Each quantity divided by
full-pattern information",x="Latent coordinate h",y="Fraction retained",color=NULL,linetype=NULL)+
    common+ggplot2::guides(color=ggplot2::guide_legend(ncol=1),linetype=ggplot2::guide_legend(ncol=1))
  postcolors<-c("Prior"=tokens[["muted_light"]],"Pattern 10"=tokens[["brand_navy"]],"Pattern 01"=tokens[["plot_blue"]],"Total only"=tokens[["plot_orange"]])
  if(grayscale) postcolors[]<-tokens[["text_light"]]
  posttypes<-c("Prior"="longdash","Pattern 10"="solid","Pattern 01"="dashed","Total only"="dotted")
  c<-ggplot2::ggplot(input$density,ggplot2::aes(h,density,color=observation,linetype=observation))+
    ggplot2::geom_line(linewidth=.9)+
    ggplot2::geom_segment(data=input$means,ggplot2::aes(x=h,xend=h,y=0,yend=.045,color=observation),inherit.aes=FALSE,linewidth=.8,show.legend=FALSE)+
    ggplot2::geom_point(data=input$mle,ggplot2::aes(x=h,y=.65,color=observation),inherit.aes=FALSE,shape=17,size=3,show.legend=FALSE)+
    ggplot2::scale_color_manual(values=postcolors)+ggplot2::scale_linetype_manual(values=posttypes)+
    ggplot2::scale_y_continuous(limits=c(0,.70),breaks=seq(0,.6,.2))+
    ggplot2::labs(title="Same total, different evidence",subtitle="Normal prior: mean 0, variance 1;
item parameters known",x="Latent coordinate h",y="Density per coordinate unit",color=NULL,linetype=NULL)+
    common+ggplot2::guides(color=ggplot2::guide_legend(ncol=2),linetype=ggplot2::guide_legend(ncol=2))
  list(a,b,c)
}
