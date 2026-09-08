# Acknowledgments {-}

This book stands on the shoulders of the open R ecosystem. Special thanks to the maintainers of `bookdown`, the tidyverse, and the domain-specific packages that make computational game theory tractable in R: `GameTheory`, `CoopGame`, `gtree`, `EvolutionaryGames`, `igraph`, `Rcpp`, and many others.

I am grateful to the bookdown community for tooling that made this book possible, and to the broader R community for sustained generosity with code, documentation, and ideas.

Drafting and editorial assistance was provided by Claude (Anthropic). All technical content has been reviewed, verified, and curated by the author. Errors remain my own.

<!-- TODO: thank specific reviewers once they have read the manuscript. -->

## Inspiration {-}

The structural and pedagogical model for this book draws heavily on Mathias Harrer, Pim Cuijpers, Toshi A. Furukawa, and David D. Ebert's [*Doing Meta-Analysis with R: A Hands-On Guide*](https://bookdown.org/MathiasHarrer/Doing_Meta_Analysis_in_R/) — both the book and its open-source repository at <https://github.com/MathiasHarrer/Doing-Meta-Analysis-in-R>. Their thorough, transparent, and beautifully laid-out bookdown setup — sidebar grouping, semantic callout boxes, the citation block, the dark/light toggle, MathJax-rendered formulas, downloadable BibTeX/RIS citations — set a clear standard for what a reproducible R-based research book can look like. Where the present book mirrors their conventions, it does so deliberately and gratefully. Where it diverges (colors, typography, individual icons), the divergence is cosmetic; the underlying craft is theirs to credit.

## Use of LLM tools {-}

Portions of this book were prepared with assistance from large language model tooling for
narrowly defined, non-authorial tasks: copyediting, prose smoothing, Markdown/LaTeX formatting,
scaffolding of boilerplate files (CI configs, build scripts), code refactoring. The tools used were [Chat AI](https://kisski.gwdg.de/leistungen/2-02-llm-service/),
the LLM service of KISSKI (GWDG), and a self-hosted **Mistral Small (24B, Apache-2.0)** run locally via
[Ollama](https://ollama.com/) and the `ollamar` R package — local inference only, with no data sent to
third parties for the self-hosted model.

All scientific claims, methodological choices, analyses, interpretations, and conclusions are the
author's own. No LLM-generated text was incorporated without review and revision, and every reference
was verified against its DOI, arXiv ID, or ISBN.
