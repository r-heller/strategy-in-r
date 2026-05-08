# _common.R — loaded at the top of every chapter
# Strategy in R

suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(glue)
  library(gt)
  library(scales)
})

knitr::opts_chunk$set(
  dev = c("png", "pdf"),
  dpi = 300,
  fig.align = "center",
  fig.width = 6,
  fig.height = 4,
  out.width = "80%",
  comment = "#>"
)

set.seed(42)

source(here::here("R", "theme_publication.R"))
source(here::here("R", "save_pub_fig.R"))
