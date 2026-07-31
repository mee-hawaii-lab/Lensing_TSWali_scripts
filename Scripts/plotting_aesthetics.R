# Publication-ready ggplot2 theme for the He'eia storm disturbance manuscript.

library(ggplot2)


theme_wali <- function() {
  theme_light() +
    theme(
      panel.grid       = element_blank(),
      panel.background = element_blank(),
      panel.border     = element_rect(colour = "black", fill = NA, linewidth = 1),
      axis.title.x     = element_text(color = "black", size = 10, face = "bold"),
      axis.title.y     = element_text(color = "black", size = 10, face = "bold"),
      axis.text.x      = element_text(color = "black", size = 10, angle = 45,
                                      hjust = 1, vjust = 1),
      axis.text.y      = element_text(color = "black", size = 10),
      axis.ticks       = element_line(color = "black", linewidth = 0.5)
    )
}

date_cols <- c("#80CDC1","#01665E","#8C510A","#D8B365","#FBBB04") # Save colors


storm_shade <- function(x = 3, fill = "#dfdfdf") {
  annotate("rect",
           xmin = x - 0.5, xmax = x + 0.5,
           ymin = -Inf, ymax = Inf,
           fill = fill)
}
