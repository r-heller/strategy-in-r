<p align="center"><a href="https://r-heller.github.io/strategy-in-r/"><img src="images/cover.png" alt="Strategy in R cover" width="280"></a></p>

# Strategy in R

*Game Theory, Simulation, and Machine Intelligence*

A free, open-source book by **Raban Heller**.

## Read it online

📖 **<https://r-heller.github.io/strategy-in-r/>**

## Download

- 📄 [Whole book (PDF)](https://r-heller.github.io/strategy-in-r/strategy-in-r.pdf)
- 📚 [EPUB](https://r-heller.github.io/strategy-in-r/strategy-in-r.epub)
- 📑 Per-chapter PDFs: every chapter has a download button at the top of its page.

## What this book covers

*Strategy in R* brings game theory and computation together in one place. It builds the foundations of strategic interaction from scratch (normal- and extensive-form games, Nash equilibrium, mixed strategies, Bayesian games, repeated games, cooperative game theory), then turns to the R toolkit and to simulation methods (Monte Carlo, agent-based models, Axelrod's tournament, replicator dynamics, network games). The second half covers reinforcement learning and modern AI through a game-theoretic lens — multi-agent RL, self-play, counterfactual regret minimisation, GANs as minimax games, and LLM agents — and closes with applications (auctions, mechanism design, matching, bargaining, empirical case studies) and a section on ethics and the future of strategic AI.

The book is for graduate students, researchers, and practitioners with working R fluency who want to apply it to strategic interaction. It is not a pure-mathematics textbook, not a general machine-learning textbook, and not a software-engineering manual.

## Table of contents

- Part I — Foundations of Game Theory
- Part II — The R Toolkit
- Part III — Simulation
- Part IV — AI and Machine Learning
- Part V — Applications
- Part VI — Ethics and the Future
- Appendices — R refresher, linear algebra, probability, exercise solutions, glossary

## How to cite

Heller, R. (2026). *Strategy in R: Game Theory, Simulation, and Machine Intelligence* (Version v0.1.0). <https://r-heller.github.io/strategy-in-r/>.

```bibtex
@book{heller2026strategy,
  author    = {Heller, Raban},
  title     = {Strategy in R: Game Theory, Simulation, and Machine Intelligence},
  year      = {2026},
  publisher = {Self-published via GitHub Pages},
  url       = {https://r-heller.github.io/strategy-in-r/},
  note      = {Version v0.1.0}
}
```

## Reproducibility

Built with [bookdown](https://bookdown.org/), R, and `renv`. To rebuild locally:

```bash
git clone https://github.com/r-heller/strategy-in-r.git
cd strategy-in-r
R -e 'renv::restore()'
R -e 'bookdown::render_book("index.Rmd", output_format = "all")'
```

A handful of chapters use Python via `reticulate`; see `python/requirements.txt`.

## License

Content: [CC BY 4.0](LICENSE-CONTENT) · Source code: [MIT](LICENSE).

## Contributing

Issues and PRs welcome. Please see [CONTRIBUTING.md](CONTRIBUTING.md).
