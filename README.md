# Strategy in R

**Game Theory, Simulation, and Machine Intelligence — A Quarto Book**

*Strategy in R* is an open-source book covering game theory, computational simulation, AI/ML for strategic interaction, and ethics — implemented end-to-end in R.

**Read online:** [r-heller.github.io/strategy-in-r](https://r-heller.github.io/strategy-in-r/)

## Build

Requirements: [Quarto](https://quarto.org/) ≥ 1.4, R ≥ 4.3, `renv`.

```bash
git clone https://github.com/r-heller/strategy-in-r.git
cd strategy-in-r
```

In R:

```r
renv::restore()
```

Render:

```bash
quarto render            # HTML + PDF + EPUB
quarto render --to html  # HTML only
quarto render --to pdf   # PDF only (requires TinyTeX)
```

## Structure

| Part | Topic |
|------|-------|
| I | Foundations of Game Theory |
| II | The R Toolkit |
| III | Simulation |
| IV | AI and Machine Learning |
| V | Applications |
| VI | Ethics and the Future |

## License

- **Code:** [MIT](LICENSE)
- **Content:** [CC-BY-SA 4.0](LICENSE-CONTENT)

## Citation

```bibtex
@book{heller2026strategy,
  author    = {Heller, Raban},
  title     = {Strategy in R: Game Theory, Simulation, and Machine Intelligence},
  year      = {2026},
  url       = {https://r-heller.github.io/strategy-in-r/},
  note      = {Quarto book, DOI forthcoming via Zenodo}
}
```

## Author

Raban Heller ([ORCID: 0000-0001-8006-9742](https://orcid.org/0000-0001-8006-9742))
