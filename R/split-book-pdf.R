#!/usr/bin/env Rscript
# Split the full book PDF into individual chapter PDFs.
# Usage: Rscript R/split-book-pdf.R [book.pdf]

library(pdftools)
library(qpdf)

args <- commandArgs(trailingOnly = TRUE)
book_pdf <- if (length(args) >= 1) args[1] else "_book/Strategy-in-R.pdf"

if (!file.exists(book_pdf)) {
  stop("Book PDF not found: ", book_pdf)
}

out_dir <- file.path(dirname(book_pdf), "downloads")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

file.copy(book_pdf, file.path(out_dir, "Strategy-in-R.pdf"), overwrite = TRUE)
cat("Copied full book PDF to downloads/\n")

toc <- pdf_toc(book_pdf)
n_pages <- pdf_length(book_pdf)
txt <- pdf_text(book_pdf)

flatten_toc <- function(node, depth = 0, parent = "") {
  rows <- list()
  if (!is.null(node$title) && nzchar(node$title)) {
    rows <- list(data.frame(
      title = node$title,
      depth = depth,
      parent = parent,
      stringsAsFactors = FALSE
    ))
  }
  nm <- if (!is.null(node$title)) node$title else parent
  for (child in node$children) {
    rows <- c(rows, flatten_toc(child, depth + 1, nm))
  }
  rows
}

toc_flat <- do.call(rbind, flatten_toc(toc))
cat("Found", nrow(toc_flat), "TOC entries\n")

chapters <- toc_flat[toc_flat$depth == 2, , drop = FALSE]
cat("Found", nrow(chapters), "depth-2 entries\n")

chapters <- chapters[!duplicated(chapters$title), , drop = FALSE]
cat("After dedup:", nrow(chapters), "unique chapter titles\n")

find_page <- function(title, start_from = 1) {
  title_clean <- trimws(title)
  for (pg in seq(start_from, min(start_from + 50, length(txt)))) {
    if (grepl(title_clean, txt[pg], fixed = TRUE)) return(pg)
  }
  for (pg in seq(start_from, length(txt))) {
    if (grepl(title_clean, txt[pg], fixed = TRUE)) return(pg)
  }
  short <- substr(title_clean, 1, min(30, nchar(title_clean)))
  for (pg in seq(start_from, length(txt))) {
    if (grepl(short, txt[pg], fixed = TRUE)) return(pg)
  }
  NA_integer_
}

pages <- integer(nrow(chapters))
last_page <- 1
for (i in seq_len(nrow(chapters))) {
  pg <- find_page(chapters$title[i], last_page)
  if (!is.na(pg)) {
    pages[i] <- pg
    last_page <- pg + 1
  }
}

chapters$page <- pages
chapters <- chapters[!is.na(chapters$page) & chapters$page > 0, , drop = FALSE]
chapters <- chapters[!duplicated(chapters$page), , drop = FALSE]

cat("\nChapter page mapping:\n")
for (i in seq_len(nrow(chapters))) {
  cat(sprintf("  p%3d: %s\n", chapters$page[i], chapters$title[i]))
}

slug <- function(title) {
  s <- tolower(title)
  s <- gsub("[^a-z0-9]+", "-", s)
  s <- gsub("^-+|-+$", "", s)
  s <- substr(s, 1, 60)
  s
}

cat("\nSplitting chapters:\n")
for (i in seq_len(nrow(chapters))) {
  start <- chapters$page[i]
  end <- if (i < nrow(chapters)) chapters$page[i + 1] - 1 else n_pages
  if (end < start) end <- start

  name <- slug(chapters$title[i])
  out_file <- file.path(out_dir, paste0(name, ".pdf"))

  tryCatch({
    pdf_subset(book_pdf, pages = start:end, output = out_file)
    cat(sprintf("  %-50s -> %s (%d pages)\n",
                chapters$title[i], basename(out_file), end - start + 1))
  }, error = function(e) {
    cat(sprintf("  SKIP: %s — %s\n", chapters$title[i], e$message))
  })
}

cat("\nDone. Chapter PDFs written to:", out_dir, "\n")
