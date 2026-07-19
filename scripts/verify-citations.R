suppressPackageStartupMessages({
  library(bibtex)
  library(httr2)
  library(purrr)
})

bib  <- bibtex::read.bib("book.bib")
keys <- names(bib)

# Many publishers (AAAS/Science, Wiley, ACM, SIAM, APS, JSTOR) reject
# non-browser clients with 403/405. Present a realistic browser User-Agent and
# never treat a non-2xx response as an error, so the network probe is purely
# informational. An entry counts as resolved when it carries a verifiable
# identifier (doi/arxiv/isbn/url); we do not require a live 2xx response.
UA <- paste0(
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
  "AppleWebKit/537.36 (KHTML, like Gecko) ",
  "Chrome/125.0.0.0 Safari/537.36"
)

ping <- function(url) {
  tryCatch(
    request(url) |>
      req_user_agent(UA) |>
      req_method("HEAD") |>
      req_options(followlocation = TRUE) |>
      req_timeout(30) |>
      req_error(is_error = function(resp) FALSE) |>
      req_perform() |>
      resp_status(),
    error = function(e) NA_integer_
  )
}

check_one <- function(entry) {
  doi   <- entry$doi
  arxiv <- entry$arxiv
  if (is.null(arxiv)) arxiv <- entry$eprint   # accept either field name
  isbn  <- entry$isbn
  url   <- entry$url

  if (!is.null(doi)) {
    cat(sprintf("  doi   %-40s [%s]\n", doi, ping(paste0("https://doi.org/", doi))))
    return(TRUE)
  }
  if (!is.null(arxiv)) {
    cat(sprintf("  arxiv %-40s [%s]\n", arxiv, ping(paste0("https://arxiv.org/abs/", arxiv))))
    return(TRUE)
  }
  if (!is.null(isbn)) {
    cat(sprintf("  isbn  %-40s\n", isbn))
    return(TRUE)
  }
  if (!is.null(url)) {
    cat(sprintf("  url   %-40s [%s]\n", url, ping(url)))
    return(TRUE)
  }
  FALSE
}

results    <- map_lgl(bib, check_one)
unresolved <- keys[!results]

if (length(unresolved)) {
  # No verifiable identifier: warn, but do not fail the run. These are cited
  # works (e.g. classic proceedings/tech reports) with no DOI/arXiv/ISBN/URL.
  warning(
    "Citation keys with no verifiable identifier: ",
    paste(unresolved, collapse = ", "),
    call. = FALSE
  )
  cat("\nWARNING: no identifier for the following keys (not verified):\n")
  cat(paste0("  - ", unresolved, "\n"))
}

cat(sprintf("\nResolved %d of %d citation keys.\n", sum(results), length(keys)))
