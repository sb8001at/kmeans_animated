function(input, output, session) {
  
  ncluster_reactive <- reactive({return(input$ncluster)})
  npoint_reactive <- reactive({return(input$n_points)})
  center_means <- reactive({
    return(
      data.frame(
        x = runif(input$ncluster, -1, 1), 
        y = runif(input$ncluster, -1, 1),
        clus = 1:input$ncluster)
    )
  })
  
  data <- reactive({
    return(
      data.frame(x=runif(npoint_reactive(), -1, 1), y=runif(npoint_reactive(), -1, 1))
    )
  })

  
  observeEvent(input$initialize, {
    
    dist_d <- NULL
    for(k in 1:ncluster_reactive()){
      dist_d <- cbind(dist_d, (data()$x - center_means()[k, 1]) ^ 2 + (data()$y - center_means()[k, 2]) ^ 2)
    }
    
    # 最も近いクラスターを探す
    min_dist <- apply(dist_d, 1, min)
    
    clus <- numeric(npoint_reactive())
    
    for(k in 1:npoint_reactive()){
      clus[k] <- which((dist_d[k, ] |> unlist()) == min_dist[k])
    }
    
    # グラフ用データを準備
    data_temp <- data.frame(data(), clus, xcenter = center_means()[clus,]$x, ycenter = center_means()[clus,]$y)
    
    # plotlyでグラフ化
    output$kmeansplot <- renderPlotly({
      data_temp |> 
        plot_ly(
          x =~ x,
          y =~ y,
          color =~ factor(clus),
          colors = RColorBrewer::brewer.pal(factor(clus) |> nlevels(), "Paired"),
          size = 2,
          alpha = 0.8,
          hoverinfo = "text",
          type = 'scatter',
          mode = 'markers',
          showlegend = F
        ) |> 
        add_markers(
          x =~ xcenter,
          y =~ ycenter,
          color =~ factor(clus),
          size = 5,
          inherit = TRUE
        ) |> 
        add_segments(
          x =~ x,
          xend =~ xcenter,
          y =~ y,
          yend =~ ycenter,
          color =~ factor(clus),
          alpha = 0.05,
          size = 0.1,
          mode = 'lines',
          inherit = TRUE
        ), height = 800, width = 1200
    }) 
  })

  observeEvent(input$runculc, {
    
    # アウトプットを保存する変数
    data_for_gganimate <- NULL
    
    data_ <- data()
    center_init <- center_means()
    
    for(i in 1:30){
      
      dist_d <- NULL
      for(k in 1:ncluster_reactive()){
        if(i == 1){
          dist_d <- cbind(dist_d, (data_$x - center_init[k, 1]) ^ 2 + (data_$y - center_init[k, 2]) ^ 2)
        } else {
          dist_d <- cbind(dist_d, (data_$x - center_means2[k, 2] |> unlist()) ^ 2 + (data_$y - center_means2[k, 3] |> unlist()) ^ 2)
        }
      }

      # 最も近いクラスターを探す
      min_dist <- apply(dist_d, 1, min)
      
      clus <- numeric(npoint_reactive())
      
      for(k in 1:npoint_reactive()){
        clus[k] <- which((dist_d[k, ] |> unlist()) == min_dist[k])
      }
      
      # グラフ用データを準備
      if(i == 1){
        data_temp <- data.frame(data_, clus, xcenter = center_init[clus,]$x, ycenter = center_init[clus,]$y, timestate = 2*i-1)
      } else {
        data_temp <- data.frame(data_, clus, xcenter = center_means2[clus,]$x, ycenter = center_means2[clus,]$y, timestate = 2*i-1)
      }
 
      data_for_gganimate <- rbind(data_for_gganimate, data_temp)
      
      # 重心でクラスターの中心を更新する
      center_means2 <- data_temp |> group_by(factor(clus)) |> summarise(x = mean(x), y=mean(y))
      colnames(center_means2) <- c("clus", "x", "y")
      
      # グラフ用データを準備
      data_temp <- data.frame(data_, clus, xcenter = center_means2[clus,]$x, ycenter = center_means2[clus,]$y, timestate = 2*i)
      data_for_gganimate <- rbind(data_for_gganimate, data_temp)
    }
    
    # plotlyでグラフ化
    output$kmeansplot <- renderPlotly({
      data_for_gganimate |> 
        plot_ly(
          x =~ x,
          y =~ y,
          color =~ factor(clus),
          colors = RColorBrewer::brewer.pal(factor(clus) |> nlevels(), "Paired"),
          size = 2,
          alpha = 0.8,
          frame =~ timestate,
          hoverinfo = "text",
          type = 'scatter',
          mode = 'markers',
          showlegend = F
        ) |> 
        add_markers(
          x =~ xcenter,
          y =~ ycenter,
          color =~ factor(clus),
          size = 8,
          inherit = TRUE
        ) |> 
        add_segments(
          x =~ x,
          xend =~ xcenter,
          y =~ y,
          yend =~ ycenter,
          color =~ factor(clus),
          alpha = 0.05,
          size = 0.1,
          mode = 'lines',
          inherit = TRUE
        ) |> 
        animation_opts(
          frame = 500,
          transition = 0,
          easing = "linear",
          redraw = TRUE,
          mode = "immediate"
        )
    }) 
  })
}
