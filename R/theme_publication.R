# theme_publication.R — ggplot2 publication theme + Okabe-Ito palette
# Strategy in R

theme_publication <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = "bottom"
    )
}

okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#000000")

scale_colour_okabe_ito <- function(...) {
  ggplot2::scale_colour_manual(values = okabe_ito, ...)
}

scale_fill_okabe_ito <- function(...) {
  ggplot2::scale_fill_manual(values = okabe_ito, ...)
}
