suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(glue)
  library(gt)
  library(scales)
})

knitr::opts_chunk$set(
  echo       = TRUE,
  message    = FALSE,
  warning    = FALSE,
  cache      = TRUE,
  cache.lazy = FALSE,
  dev        = c("png", "pdf"),
  dpi        = 300,
  fig.align  = "center",
  fig.width  = 7,
  fig.height = 4.5,
  fig.retina = 2,
  out.width  = "90%",
  comment    = "#>"
)

options(
  scipen = 999,
  digits = 3,
  knitr.kable.NA = "—"
)

set.seed(42)

source(here::here("R", "theme_publication.R"))
source(here::here("R", "save_pub_fig.R"))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::theme_set(
    ggplot2::theme_minimal(base_family = "Inter", base_size = 12) +
      ggplot2::theme(
        plot.title.position   = "plot",
        plot.caption.position = "plot",
        plot.caption          = ggplot2::element_text(hjust = 0, color = "#666"),
        panel.grid.minor      = ggplot2::element_blank()
      )
  )
}
