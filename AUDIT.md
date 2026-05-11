# Audit — Strategy in R (Quarto → bookdown migration)

Performed 2026-05-11 on branch `migrate/bookdown-v2`.

## Inventory before migration

- Toolchain: Quarto book (`_quarto.yml`), output dir `_book/`, deployed pre-rendered to GitHub Pages.
- 47 chapter `.qmd` files (41 numbered chapters + 5 appendices + `00-introduction`) — fully written, ~15.5k lines total.
- Chapters lived in part subdirectories (`part-1-foundations/` … `part-6-ethics/`, `appendices/`).
- 5 GitHub Actions workflows (render-html, render-pdf, deploy-pages, citation-check, figure-check).
- `references.bib`: 66 entries with verified DOI/arXiv/ISBN.
- `R/`: helpers (`_common.R`, `theme_publication.R`, `save_pub_fig.R`, `axelrod.R`, `replicator.R`, `rl_agents.R`, `solvers.R`, `plotly_helpers.R`, `check_chapter.R`, `split-book-pdf.R`).
- `style/`: `header.html` (Inter + JetBrains Mono fonts), `per-chapter-pdf-button.html`.
- `apa.csl` bundled for offline citation rendering.

## Quarto syntax converted by `scripts/migrate_quarto_to_bookdown.py` (one-shot, removed)

| Quarto                              | bookdown                                |
|-------------------------------------|-----------------------------------------|
| ```` ```{r}\n#\| label: foo\n#\| fig-cap: "Bar"\n ```` | ```` ```{r foo, fig.cap="Bar"} ```` |
| `@sec-foo`                          | `\@ref(sec-foo)`                        |
| `@fig-foo`                          | `\@ref(fig:foo)` (label prefix stripped)|
| `@tbl-foo`                          | `\@ref(tab:foo)`                        |
| `@eq-foo`                           | `\@ref(eq:foo)`                         |
| `$$\n…\n$$ {#eq-foo}`               | `\begin{equation}\n…\n(\#eq:foo)\n\end{equation}` |
| `::: {.callout-note}\n## Title\nbody\n:::` | `::: {.rmdnote}\n**Title**\n\nbody\n:::` |
| `{.unnumbered}`                     | `{-}`                                   |

- 69 `fig-`/`tbl-` chunk labels were renamed (prefix stripped) and all corresponding `@fig-`/`@tbl-` cross-refs updated.
- Per-chapter Quarto YAML headers (`title`, `short-title`, `abstract`, `keywords`, `date-modified`, `other-links`, `author`) were stripped; abstracts were preserved as a blockquote epigraph under the H1 to avoid content loss.

## Required structural elements (per CLAUDE.md §B1.2)

- [x] `index.Rmd` — bookdown YAML + Preface
- [x] `impressum.Rmd`
- [x] `how-to-use.Rmd`
- [x] `notation.Rmd`
- [x] `acknowledgments.Rmd`
- [x] `about-the-author.Rmd`
- [x] 41 numbered chapter `.Rmd` files (with `# (PART)` dividers at 01/09/15/23/31/37)
- [x] 5 appendix `.Rmd` files (with `# (APPENDIX)` divider on `A-r-refresher.Rmd`)
- [x] `95-colophon.Rmd` (sessioninfo + commit SHA)
- [x] `99-references.Rmd` (`<div id="refs"></div>`)
- [x] `_common.R` per §A3 (preserves the existing `tidyverse`/`here`/`gt` package loads + `theme_publication`/`save_pub_fig` sources)
- [x] `style/style.css` per §A6 (Hugo Coder palette, with `.exercise`/`.definition`/`.theorem` preserved)
- [x] `style/header.html` (already present; keeps Inter + JetBrains Mono fonts)
- [x] `style/preamble.tex` per §B2.1 (preserves theorem environments and game-theory notation macros)
- [x] `style/per-chapter-pdf-button.html` (already present; safe `textContent` form)
- [x] `apa.csl` (kept; better than swapping CSLs mid-project)
- [x] `book.bib` (renamed from `references.bib` — 66 entries unchanged)
- [x] `CITATION.cff`, `citation.bib`
- [x] `LICENSE` (MIT, code) + `LICENSE-CONTENT` (CC BY 4.0, content)
- [x] `_bookdown.yml`, `_output.yml` (replaces `_quarto.yml`)
- [x] `.github/workflows/render-book.yml` (replaces 4 obsolete Quarto workflows)
- [x] `.github/workflows/citation-check.yml` (rewritten for `book.bib`)
- [x] `scripts/render-chapter-pdfs.R`, `scripts/verify-citations.R`, `scripts/toc-to-readme.R`
- [x] `README.md` rewritten badge-free
- [x] Pre-rendered `_book/` directory removed; CI now renders fresh output to `docs/`

## Caveats and follow-ups

- Local rendering not possible on this Windows host (no R installed). Verification deferred to GitHub Actions on push.
- The `_output.yml` `bookdown::pdf_book` stanza uses the existing `style/preamble.tex` — but the Quarto preamble assumed `scrbook` document class. The bookdown PDF uses the default `book` class. Watch for spacing or layout differences in the rendered PDF and tune the preamble if needed.
- `bookdown::bs4_book` does NOT generate per-chapter PDFs natively — `scripts/render-chapter-pdfs.R` does that and the after-body `style/per-chapter-pdf-button.html` injects the link.
- The migration script is one-shot and has been removed. If anything needs to be re-converted, re-run the script from git history (`git show migrate/bookdown-v2:scripts/migrate_quarto_to_bookdown.py`).
- The Quarto cite `[-@key]` (suppress author) syntax is pandoc-citeproc, which bookdown also uses — so those references should still render correctly under the APA CSL.
- `R/check_chapter.R` and `R/split-book-pdf.R` were Quarto-oriented helper scripts; review them on a follow-up pass to either delete or port to bookdown idioms.
