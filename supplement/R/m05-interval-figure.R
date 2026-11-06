# Two panels: fixed observed input -> intervals; repeated data at fixed tau -> coverage.
m05_interval_figure_data <- function() {
  intervals <- m05_scalar() |>
    dplyr::mutate(row = c(3,4,1,2),
      label = c("Confidence\nexpected score","Credible\nexpected score","Likelihood prediction\nnext score","Posterior predictive\nnext score"),
      method = c("Likelihood","Credible","Likelihood","Posterior predictive"),
      shape = c(0,16,0,16))
  coverage <- m05_coverage()
  curves <- coverage |>
    tidyr::pivot_longer(cols=c(confidence_and_likelihood_prediction,credible,posterior_predictive),names_to="procedure",values_to="coverage") |>
    dplyr::mutate(procedure=dplyr::recode(procedure,
      confidence_and_likelihood_prediction="Confidence + likelihood prediction",
      credible="Credible (expected score)",posterior_predictive="Posterior predictive (next score)"))
  marked <- curves |> dplyr::filter(tau %in% c(20,35,50),procedure!="Confidence + likelihood prediction")
  list(intervals=intervals,coverage=curves,prior=coverage |> dplyr::transmute(tau=tau,density=prior_density,scaled_shape=prior_density/max(prior_density)*.18),marked=marked)
}

plot_m05_intervals <- function(input=m05_interval_figure_data(),grayscale=FALSE,family=book_font_family()) {
  tokens <- book_tokens()
  colors <- c("Likelihood"=tokens[["brand_navy"]],"Credible"=tokens[["plot_blue"]],"Posterior predictive"=tokens[["plot_orange"]])
  if (grayscale) colors <- c("Likelihood"=tokens[["text_light"]],"Credible"=tokens[["text_light"]],"Posterior predictive"=tokens[["muted_light"]])
  color_curves <- c("Confidence + likelihood prediction"=unname(colors["Likelihood"]),
    "Credible (expected score)"=unname(colors["Credible"]),"Posterior predictive (next score)"=unname(colors["Posterior predictive"]))
  types <- c("Confidence + likelihood prediction"="solid","Credible (expected score)"="dashed","Posterior predictive (next score)"="dotted")
  common <- book_theme(base_size=14,base_family=family) + ggplot2::theme(
    plot.title.position="plot",plot.title=ggplot2::element_text(face="bold",size=14),
    plot.subtitle=ggplot2::element_text(size=11.5),plot.margin=ggplot2::margin(12,12,12,12),
    panel.grid.minor=ggplot2::element_blank(),axis.text=ggplot2::element_text(size=12),legend.position="none")
  a <- ggplot2::ggplot(input$intervals,ggplot2::aes(y=row)) +
    ggplot2::geom_vline(xintercept=35,linetype="longdash",color=tokens[["plot_slate"]],linewidth=.4) +
    ggplot2::geom_vline(xintercept=50,linetype="dotdash",color=tokens[["plot_slate"]],linewidth=.4) +
    ggplot2::geom_linerange(ggplot2::aes(xmin=lower,xmax=upper,color=method),orientation="y",linewidth=1) +
    ggplot2::geom_point(ggplot2::aes(x=center,color=method,shape=factor(shape)),size=3.1,stroke=.9) +
    ggplot2::geom_text(ggplot2::aes(x=lower,label=sprintf("%.1f",lower)),nudge_y=.23,size=4.2,family=family) +
    ggplot2::geom_text(ggplot2::aes(x=upper,label=sprintf("%.1f",upper)),nudge_y=.23,size=4.2,family=family) +
    ggplot2::scale_shape_manual(values=c("0"=0,"16"=16)) + ggplot2::scale_color_manual(values=colors) +
    ggplot2::scale_y_continuous(breaks=input$intervals$row,labels=input$intervals$label,limits=c(.55,4.55)) +
    ggplot2::scale_x_continuous(limits=c(10,66),breaks=seq(10,60,10)) +
    ggplot2::labs(title="A  Intervals after observing 35",subtitle="Dashed: score 35; dot-dash: prior mean 50",x="Score points",y=NULL) + common +
    ggplot2::theme(panel.grid.major.y=ggplot2::element_blank(),axis.text.y=ggplot2::element_text(size=12))
  b <- ggplot2::ggplot(input$coverage,ggplot2::aes(x=tau,y=coverage,color=procedure,linetype=procedure)) +
    ggplot2::geom_area(data=input$prior,ggplot2::aes(x=tau,y=scaled_shape),inherit.aes=FALSE,fill=tokens[["border_light"]]) +
    ggplot2::annotate("text",x=50,y=.07,label="Prior shape\n(scaled)",size=3.4,family=family,color=tokens[["muted_light"]]) +
    ggplot2::geom_line(linewidth=.85) +
    ggplot2::geom_point(data=input$marked,ggplot2::aes(shape=procedure),size=2.4) +
    ggplot2::scale_color_manual(values=color_curves) + ggplot2::scale_linetype_manual(values=types) +
    ggplot2::scale_shape_manual(values=c("Credible (expected score)"=16,"Posterior predictive (next score)"=18)) +
    ggplot2::scale_x_continuous(limits=c(0,100),breaks=seq(0,100,20),expand=ggplot2::expansion(mult=0)) +
    ggplot2::scale_y_continuous(limits=c(0,1),breaks=seq(0,1,.2),expand=ggplot2::expansion(mult=c(0,.02))) +
    ggplot2::labs(title="B  Repeat data at a fixed\nexpected score",x="Fixed expected score (points)",y="Sampling coverage",color=NULL,linetype=NULL,shape=NULL) + common +
    ggplot2::theme(legend.position="bottom",legend.text=ggplot2::element_text(size=12),legend.key.width=grid::unit(1.5,"lines")) +
    ggplot2::guides(color=ggplot2::guide_legend(ncol=1,order=1,override.aes=list(shape=c(NA,16,18))),linetype=ggplot2::guide_legend(ncol=1,order=1),shape="none")
  list(a,b)
}
