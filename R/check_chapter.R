# check_chapter.R — CI helper for chapter validation
# Strategy in R

check_chapter <- function(qmd_path) {
  if (!file.exists(qmd_path)) stop("File not found: ", qmd_path)
  lines <- readLines(qmd_path)
  content <- paste(lines, collapse = "\n")

  has_frontmatter <- grepl("^---", lines[1])
  has_fig <- grepl("save_pub_fig|fig-cap", content)
  has_exercises <- grepl("## Exercises", content)
  char_count <- nchar(gsub("```.*?```", "", content, perl = TRUE))

  list(
    file = qmd_path,
    has_frontmatter = has_frontmatter,
    has_figure = has_fig,
    has_exercises = has_exercises,
    prose_chars = char_count
  )
}
