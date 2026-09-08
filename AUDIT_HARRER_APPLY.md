# AUDIT_HARRER_APPLY.md

Pre-flight audit for the `feat/strict-harrer-layout` branch. Status as of
the initial check.

| § | Item | Status | Action |
|---|---|---|---|
| §2 | `style/style.css` carries the full token + callout + sidebar system | ✅ | verified — leave |
| §2 | `style/header.html` references local FA, no CDN | ✅ | leave |
| §2 | `style/after-body.html` has toggle + per-chapter PDF + footer | ✅ | leave |
| §3 | `style/font-awesome.min.css` + `style/webfonts/*.woff2` | ✅ | already vendored — leave |
| §4 | `part-*.Rmd` group files + `(APPENDIX)` directive in `_bookdown.yml` | ❌ | create 7 part files + rewrite `rmd_files:` |
| §5 | `index.Rmd` strict Harrer landing (right-floated `<img>`, `---` separators, `<br></br>`, `boxempty` citation) | ⚠️ | rewrite body — current uses `knitr::include_graphics` and includes a redundant `## License {-}` section |
| §6 | `citation.bib` + `citation.ris` at repo root | ✅ | leave |
| §6 | `citation-files/` copy hook in `_common.R` | ⚠️ | verify, add if missing |
| §7 | `scripts/render-chapter-pdfs.R` exists | ✅ | verify it filters `part-*.Rmd` |
