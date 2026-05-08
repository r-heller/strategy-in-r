# save_pub_fig.R — save figures as PDF + PNG @ 300dpi
# Strategy in R

save_pub_fig <- function(plot, slug, width = 6, height = 4, dpi = 300) {
  dir <- here::here("images")
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(file.path(dir, paste0(slug, ".pdf")),
                  plot, width = width, height = height, device = "pdf")
  ggplot2::ggsave(file.path(dir, paste0(slug, ".png")),
                  plot, width = width, height = height, dpi = dpi, device = "png")
  invisible(plot)
}
