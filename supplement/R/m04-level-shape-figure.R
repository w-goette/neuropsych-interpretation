# fig-m04-level-shape: same teaching law, observed projection and shifted populations.
m04_figure_data <- function() {
  R <- matrix(c(1,.6,.6,1),2);v <- c(1,1);observed <- c(-1.5,0);theta <- seq(0,2*pi,length.out=400)
  # Eigenvectors are ordered by ascending eigenvalue.
  U <- matrix(c(-1,1,1,1),2)/sqrt(2)
  outline <- U%*%diag(sqrt(c(.4,1.6)*stats::qchisq(.95,2)))%*%rbind(cos(theta),sin(theta))
  centers <- rbind(reference=c(0,0),global=c(-1,-1),focal=c(-1,0),opposing=c(-1,1))
  ellipses <- dplyr::bind_rows(lapply(1:4,function(i) tibble::tibble(population=rownames(centers)[i],angle=theta,score1=outline[1,]+centers[i,1],score2=outline[2,]+centers[i,2],center1=centers[i,1],center2=centers[i,2])))
  projection <- m04_geometry(observed,R)$coefficient*v
  steps <- tibble::tibble(operation=c('Level','Residual'),x=c(0,projection[1]),y=c(0,projection[2]),xend=c(projection[1],observed[1]),yend=c(projection[2],observed[2]))
  profiles <- tibble::tibble(profile=c('A','B'),score1=c(-1.5,-1.5),score2=c(0,-1.5),raw_score1=c(35,35),raw_score2=c(50,35))
  shifts <- dplyr::bind_rows(lapply(2:4,function(i) {g <- m04_geometry(centers[i,],R);tibble::tibble(population=rownames(centers)[i],delta1=centers[i,1],delta2=centers[i,2],level_squared=g$level^2,shape_noncentrality=g$shape)}))
  level_lines <- dplyr::bind_rows(lapply(1:2,function(i) tibble::tibble(profile=profiles$profile[i],score1=c(-4,4),score2=sum(c(profiles$score1[i],profiles$score2[i]))-c(-4,4))))
  list(ellipses=ellipses,steps=steps,profiles=profiles,shifts=shifts,level_lines=level_lines)
}
plot_m04_level_shape <- function(input,grayscale=FALSE,family=book_font_family()) {
  tokens <- book_tokens();palette <- book_palette(3)
  ink <- tokens[['text_light']];neutral <- tokens[['muted_light']]
  blue <- if(grayscale) ink else unname(palette[1]);accent <- if(grayscale) ink else unname(palette[2])
  fill <- .92*grDevices::col2rgb(tokens[['canvas_light']])+.08*grDevices::col2rgb(ink)
  fill <- grDevices::rgb(fill[1]/255,fill[2]/255,fill[3]/255)
  reference <- dplyr::filter(input$ellipses,population=='reference')
  theme <- book_theme(base_size=12,base_family=family)+ggplot2::theme(
    plot.title=ggplot2::element_text(size=13,face='bold'),plot.subtitle=ggplot2::element_text(size=11),
    plot.caption=ggplot2::element_text(size=10.5,hjust=0),axis.text=ggplot2::element_text(size=10.5),
    axis.title=ggplot2::element_text(size=11),legend.position='none',plot.margin=ggplot2::margin(8,10,8,8))
  base <- ggplot2::ggplot()+ggplot2::geom_polygon(data=reference,ggplot2::aes(score1,score2),fill=fill,colour=NA)+
    ggplot2::geom_path(data=reference,ggplot2::aes(score1,score2),colour=neutral,linetype='dotted',linewidth=.6)+
    ggplot2::geom_abline(intercept=0,slope=1,colour=neutral,linetype='longdash',linewidth=.55)+
    ggplot2::geom_hline(yintercept=0,colour=tokens[['border_light']],linewidth=.3)+
    ggplot2::geom_vline(xintercept=0,colour=tokens[['border_light']],linewidth=.3)+
    ggplot2::scale_x_continuous(breaks=c(-4,-2,0,2,4))+
    ggplot2::scale_y_continuous(breaks=c(-4,-2,0,2,4))+
    ggplot2::coord_fixed(xlim=c(-4,4),ylim=c(-4,4),expand=FALSE)+
    ggplot2::labs(x='Standardized score 1',y='Standardized score 2')+theme
  A <- base+
    ggplot2::geom_line(data=input$level_lines,ggplot2::aes(score1,score2,group=profile),colour=neutral,linetype='dashed',linewidth=.5)+
    ggplot2::geom_segment(data=input$steps[1,],ggplot2::aes(x=x,y=y,xend=xend,yend=yend),colour=blue,linewidth=.95,arrow=grid::arrow(length=grid::unit(.09,'inches'),type='closed'))+
    ggplot2::geom_segment(data=input$steps[2,],ggplot2::aes(x=x,y=y,xend=xend,yend=yend),colour=accent,linetype='dashed',linewidth=.85,arrow=grid::arrow(length=grid::unit(.09,'inches'),type='closed'))+
    ggplot2::geom_point(data=input$profiles,ggplot2::aes(score1,score2,shape=profile),colour=ink,size=2.5)+
    ggplot2::scale_shape_manual(values=c(A=16,B=0))+
    ggplot2::annotate('text',x=c(-2.3,-1.2,2.2),y=c(.7,-2.3,2.9),label=c('A','B','v = (1, 1)'),colour=ink,size=3.6,family=family)+
    ggplot2::labs(title='A. Split the observed profile',subtitle='Origin -> level -> residual -> A',
      caption='Solid arrow: fitted level; dashed: residual\nA: L = -0.84, Q_v = 2.81; B: -1.68, 0\nGray dashed lines: constant level\nGray ellipse: 95% of reference peers')
  plots <- list(A)
  for(i in 1:3) {
    row <- input$shifts[i,];shifted <- dplyr::filter(input$ellipses,population==row$population)
    title <- c('B. Global population shift','C. Focal population shift','D. Opposing population shift')[i]
    outcome <- c('Only level changes','Level and shape change','Only shape changes')[i]
    plots[[i+1]] <- base+
      ggplot2::geom_path(data=shifted,ggplot2::aes(score1,score2),colour=blue,linewidth=.85)+
      ggplot2::geom_segment(data=row,ggplot2::aes(x=0,y=0,xend=delta1,yend=delta2),colour=blue,linewidth=.9,arrow=grid::arrow(length=grid::unit(.09,'inches'),type='closed'))+
      ggplot2::geom_point(data=row,ggplot2::aes(x=delta1,y=delta2),colour=blue,shape=c(16,17,18)[i],size=2.5)+
      ggplot2::labs(title=title,subtitle=paste0('Mean moves to (',row$delta1,', ',row$delta2,')'),
        caption=sprintf('%s\nSquared level displacement: %.4g\nShape noncentrality: %.4g\nSolid outline: shifted 95%% region',outcome,row$level_squared,row$shape_noncentrality))
  }
  plots
}
