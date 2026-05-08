# plotly_helpers.R — interactive plot utilities
# Strategy in R

make_plotly_payoff_matrix <- function(mat, title = "Payoff Matrix") {
  plotly::plot_ly(
    z = mat,
    type = "heatmap",
    colorscale = list(c(0, "#56B4E9"), c(1, "#E69F00"))
  ) |>
    plotly::layout(title = title)
}
