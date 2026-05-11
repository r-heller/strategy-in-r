# How to use this book {-}

## Reading paths {-}

- **Linear** — front-to-back; expects no prior game-theory background.
- **Theorist** — Part I → Part V (applications) → Part VI (ethics); skim Parts II–IV for tools.
- **R programmer** — Part II (toolkit) → Part III (simulation) → dip into Part IV (AI/ML); refer to Part I as a reference.
- **AI researcher** — Part IV → Part VI; treat Part I as a glossary.

## Chapter conventions {-}

- Each chapter opens with a concrete question, not a definition.
- Code is shown in full; outputs follow immediately; interpretation is a separate paragraph.
- Cross-references use bookdown's `\@ref()` syntax: `Chapter \@ref(sec-nash-equilibrium)`, `Figure \@ref(fig:axelrod-ranking)`, `Table \@ref(tab:auction-types)`.
- Exercises live at the end of each chapter; solutions are in Appendix D.

## Companion code and data {-}

- All R scripts live under `R/`; example datasets under `data/`; Python helpers under `python/`.
- Every chapter is rebuildable in isolation: `bookdown::preview_chapter("12-gtree-package.Rmd")`.

## Downloads {-}

- A whole-book PDF and EPUB are linked from the navbar.
- Each chapter page has a per-chapter PDF download in the top-right.

## How to cite {-}

See the *Impressum* for the suggested citation, and `citation.bib` in the repository for a BibTeX entry.
