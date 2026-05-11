# Render each chapter to its own PDF in docs/pdf-chapters/.
# Skips index, front matter, and back matter.

library(rmarkdown)
library(fs)

skip <- c(
  "index.Rmd", "impressum.Rmd", "how-to-use.Rmd", "notation.Rmd",
  "acknowledgments.Rmd", "about-the-author.Rmd",
  "95-colophon.Rmd", "99-references.Rmd"
)

chapters <- dir_ls(".", glob = "*.Rmd")
chapters <- chapters[!path_file(chapters) %in% skip]
# Skip the (PART) and (APPENDIX) marker files; they contain no content.
chapters <- chapters[!grepl("^part-.*\.Rmd$", path_file(chapters))]

out_dir <- "docs/pdf-chapters"
dir_create(out_dir)

for (ch in chapters) {
  out <- path_ext_set(path_file(ch), "pdf")
  message("Rendering ", ch, " -> ", out)
  tryCatch(
    rmarkdown::render(
      input         = ch,
      output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
      output_file   = out,
      output_dir    = out_dir,
      envir         = new.env(),
      quiet         = TRUE
    ),
    error = function(e) message("FAILED: ", ch, " — ", conditionMessage(e))
  )
}
