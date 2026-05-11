# Generate a condensed table-of-contents block from _bookdown.yml.
# Writes scripts/_toc-block.md; paste into README.md as needed.

library(yaml)
library(fs)

cfg <- yaml::read_yaml("_bookdown.yml")
files <- cfg$rmd_files

extract_h1 <- function(f) {
  if (!file_exists(f)) return(NULL)
  lines <- readLines(f, n = 60, warn = FALSE)
  h1 <- grep("^# [^(]", lines, value = TRUE)[1]
  if (is.na(h1)) return(NULL)
  sub("\\s*\\{[^}]*\\}\\s*$", "", sub("^# ", "", h1))
}

skip <- c("index.Rmd", "99-references.Rmd")
out  <- character(0)
for (f in files) {
  if (f %in% skip) next
  title <- extract_h1(f)
  if (is.null(title)) next
  out <- c(out, paste0("- ", title))
}
writeLines(out, "scripts/_toc-block.md")
cat("Wrote scripts/_toc-block.md\n")
