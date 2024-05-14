# Functions to visualize the data

vizSimWeight <- function() {
  #' Visualize Simulated Weight
  #'
  #' Visualize simulated weight from the `simWeight` function.
  #'
  #' @return A GGPlot2 object
  require("ggplot2")

  tbl <- simWeight()

  plt <- ggplot(tbl, aes(x = ddd, y = weight)) +
    geom_vline(xintercept = 1, color = "grey60", linetype = 2) +
    annotate("text", x = 1, y = Inf, label = "DDD = 1", hjust = 1, vjust = 1) +
    geom_point(alpha = 0.4) +
    facet_wrap(~method, scales = "free_y", nrow = 1) +
    labs(
      x = "Simulated defined daily dose (DDD), set as a sequence from 0 to 5 with a step of 0.1",
      y = "Adjusted weight"
    ) +
    theme(
      axis.text.x  = element_blank(),
      axis.text.y  = element_blank(),
      axis.ticks.x = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank()
    )

  return(plt)
}

