# (PART) Part I — Foundations of Game Theory {-}

# What is a Game? {#sec-what-is-a-game}

> Players, actions, payoffs, and information — the four building blocks that turn any strategic situation into a formal game. This chapter introduces the modeling stance of game theory, walks through canonical examples such as the Prisoner's Dilemma, coordination, and zero-sum games, and implements a reusable payoff-matrix visualization in R.


## Learning objectives {-}

After completing this chapter you will be able to:

- Identify the four core ingredients of a game: players, actions, payoffs, and information.
- Explain why a situation qualifies as a "strategic interaction" rather than a simple decision problem.
- Represent a simultaneous-move game as a payoff matrix and interpret its entries.
- Construct and visualize payoff matrices for classic 2x2 games in R.
- Distinguish between zero-sum, coordination, and social-dilemma games by inspecting their payoff structure.

## Motivation

Imagine two coffee shops that open on the same street. Each owner must set a price without knowing the competitor's choice. The profit of each shop depends not only on its own price but also on the price set by the other. This mutual dependence is the hallmark of a *strategic interaction*: the outcome for any one participant is shaped by the choices of all participants together.

Situations like this arise everywhere --- in economics, politics, biology, computer science, and everyday life. Firms compete on pricing and advertising; countries negotiate treaties; bacteria evolve resistance; autonomous vehicles coordinate at intersections. What unites these disparate settings is a common logical structure that can be captured by a single word: *game*.

Game theory provides a precise mathematical language for reasoning about strategic interactions. It was launched by @von-neumann1944, who demonstrated that parlour games, market competition, and military tactics all share the same formal skeleton. A few years later, @nash1950 showed that every finite game possesses at least one equilibrium --- a combination of strategies from which no player wants to deviate unilaterally. These two contributions created a discipline that now spans the social sciences, biology, and artificial intelligence.

This chapter lays the foundation for everything that follows. Before we can solve games, simulate tournaments, or train learning agents, we need a clear vocabulary for describing what a game *is*.

## Theory

### The four building blocks

Following @osborne2004, a game in *strategic form* is defined by four elements:

1. **Players.** A finite set $N = \{1, 2, \ldots, n\}$ of decision-makers. Each player is assumed to be rational --- they have well-defined preferences and act to maximize their own payoff.

2. **Actions (strategies).** For each player $i$, a set $A_i$ of available choices. In a simultaneous-move game every player chooses an action without observing what the others do. The set of all action profiles is $A = A_1 \times A_2 \times \cdots \times A_n$.

3. **Payoffs.** A function $u_i : A \to \mathbb{R}$ that assigns a numerical reward to player $i$ for every possible combination of actions. Payoffs encode preferences: player $i$ prefers action profile $a$ to profile $a'$ if and only if $u_i(a) > u_i(a')$.

4. **Information.** What each player knows when choosing an action. In a simultaneous game, players choose without observing others' moves; in a sequential game, later movers may observe earlier choices. We explore sequential information structures in \@ref(sec-extensive-form).

A compact way to represent a two-player simultaneous game is the *payoff matrix* (also called the *normal form*). Each row corresponds to an action of Player 1, each column to an action of Player 2, and each cell contains a pair $(u_1, u_2)$ of payoffs. We study this representation in depth in \@ref(sec-normal-form).

### What makes a situation a "game"?

Not every decision problem is a game. A hiker choosing a trail based on weather forecasts faces uncertainty, but the weather does not "respond" to the hiker's choice. A game requires at least two purposeful agents whose payoffs are mutually dependent. This *interdependence* is the key criterion: if the best action for one player depends on the action chosen by another, the situation is strategic and thus a game [@shoham2009].

### Three canonical examples

**The Prisoner's Dilemma.** Two suspects are interrogated separately. Each can *Cooperate* (stay silent) or *Defect* (betray the other). Mutual cooperation yields a moderate reward for both, mutual defection yields a poor outcome for both, and unilateral defection gives the defector a high payoff at the cooperator's expense. The tragedy is that each player has a dominant incentive to defect, even though mutual cooperation would leave both better off. This game is central to the study of cooperation and is revisited in \@ref(sec-repeated-games) and \@ref(sec-axelrod-tournament). The payoff structure is:

|               | Cooperate    | Defect       |
|:--------------|:-------------|:-------------|
| **Cooperate** | (3, 3)       | (0, 5)       |
| **Defect**    | (5, 0)       | (1, 1)       |

**Coordination (Stag Hunt).** Two hunters can chase a *Stag* (which requires joint effort) or a *Hare* (which can be caught alone). If both hunt the stag, both feast; if one hunts alone, the stag escapes and that hunter gets nothing while the other catches a hare. The game has two pure-strategy equilibria and highlights the tension between efficiency and safety.

|             | Stag         | Hare         |
|:------------|:-------------|:-------------|
| **Stag**    | (4, 4)       | (0, 3)       |
| **Hare**    | (3, 0)       | (2, 2)       |

**Zero-sum (Matching Pennies).** Each player secretly shows *Heads* or *Tails*. If the coins match, Player 1 wins; otherwise Player 2 wins. Every gain for one player is an equal loss for the other, so $u_1(a) + u_2(a) = 0$ for every profile $a$. This is the class of games @von-neumann1944 first solved completely. We study mixed-strategy solutions in \@ref(sec-mixed-strategies).

|             | Heads        | Tails        |
|:------------|:-------------|:-------------|
| **Heads**   | (1, -1)      | (-1, 1)      |
| **Tails**   | (-1, 1)      | (1, -1)      |

## Implementation in R

We now build an R function to create and visualize any 2x2 payoff matrix. The function returns a tidy data frame suitable for plotting with `ggplot2`.


``` r
# Build a tidy data frame for a 2x2 payoff matrix
make_payoff_df <- function(game_name, row_actions, col_actions, payoffs) {
  # payoffs: list of four pairs c(u1, u2) in row-major order
  tibble(
    game       = game_name,
    row_action = rep(row_actions, each = length(col_actions)),
    col_action = rep(col_actions, times = length(row_actions)),
    payoff_1   = map_dbl(payoffs, 1),
    payoff_2   = map_dbl(payoffs, 2),
    label      = glue("({payoff_1}, {payoff_2})")
  )
}
```

Next we build data frames for our three canonical games and combine them into one tidy dataset.


``` r
pd <- make_payoff_df(
  "Prisoner's Dilemma",
  c("Cooperate", "Defect"), c("Cooperate", "Defect"),
  list(c(3, 3), c(0, 5), c(5, 0), c(1, 1))
)

stag <- make_payoff_df(
  "Stag Hunt",
  c("Stag", "Hare"), c("Stag", "Hare"),
  list(c(4, 4), c(0, 3), c(3, 0), c(2, 2))
)

mp <- make_payoff_df(
  "Matching Pennies",
  c("Heads", "Tails"), c("Heads", "Tails"),
  list(c(1, -1), c(-1, 1), c(-1, 1), c(1, -1))
)

games <- bind_rows(pd, stag, mp) |>
  mutate(
    game = factor(game, levels = c("Prisoner's Dilemma",
                                   "Stag Hunt",
                                   "Matching Pennies"))
  )
```

Now we produce a publication-quality heatmap of the three payoff matrices, using Player 1's payoff for the fill colour.


``` r
p_heatmap <- ggplot(games, aes(x = col_action, y = row_action,
                                fill = payoff_1)) +
  geom_tile(colour = "white", linewidth = 1.2) +
  geom_text(aes(label = label), size = 3.6, fontface = "bold") +
  facet_wrap(~ game, scales = "free") +
  scale_fill_gradient2(
    low = okabe_ito[6],   # vermillion for negative/low
    mid = "white",
    high = okabe_ito[3],  # bluish-green for positive/high
    midpoint = 1.5,
    name = "Player 1\npayoff"
  ) +
  scale_y_discrete(limits = rev) +
  labs(x = "Player 2", y = "Player 1") +
  theme_publication(base_size = 11) +
  theme(
    strip.text = element_text(face = "bold", size = 11),
    panel.grid = element_blank(),
    axis.ticks = element_blank()
  )

p_heatmap
```

<div class="figure" style="text-align: center">
<img src="01-what-is-a-game_files/figure-epub3/payoff-heatmap-1.png" alt="Payoff matrices for three canonical 2x2 games. Cell colour encodes Player 1's payoff using a diverging Okabe-Ito-inspired palette; each cell displays both players' payoffs as an ordered pair." width="80%" />
<p class="caption">(\#fig:payoff-heatmap)Payoff matrices for three canonical 2x2 games. Cell colour encodes Player 1's payoff using a diverging Okabe-Ito-inspired palette; each cell displays both players' payoffs as an ordered pair.</p>
</div>



## Worked example

Let us walk through the Prisoner's Dilemma step by step to cement the vocabulary.

**Step 1 --- Identify the players.** There are two players: Suspect 1 and Suspect 2.

**Step 2 --- List the actions.** Each player can *Cooperate* (stay silent) or *Defect* (betray). So $A_1 = A_2 = \{\text{Cooperate}, \text{Defect}\}$.

**Step 3 --- Specify payoffs.** We read the matrix row by row:


``` r
pd |>
  select(
    `Player 1` = row_action,
    `Player 2` = col_action,
    `Payoff 1`  = payoff_1,
    `Payoff 2`  = payoff_2
  ) |>
  gt() |>
  tab_header(title = "Prisoner's Dilemma Payoffs") |>
  cols_align(align = "center")
```

```{=html}
<div id="qeayjdrzqo" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#qeayjdrzqo table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#qeayjdrzqo thead, #qeayjdrzqo tbody, #qeayjdrzqo tfoot, #qeayjdrzqo tr, #qeayjdrzqo td, #qeayjdrzqo th {
  border-style: none;
}

#qeayjdrzqo p {
  margin: 0;
  padding: 0;
}

#qeayjdrzqo .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#qeayjdrzqo .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#qeayjdrzqo .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#qeayjdrzqo .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#qeayjdrzqo .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#qeayjdrzqo .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qeayjdrzqo .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#qeayjdrzqo .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#qeayjdrzqo .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#qeayjdrzqo .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#qeayjdrzqo .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#qeayjdrzqo .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#qeayjdrzqo .gt_spanner_row {
  border-bottom-style: hidden;
}

#qeayjdrzqo .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#qeayjdrzqo .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#qeayjdrzqo .gt_from_md > :first-child {
  margin-top: 0;
}

#qeayjdrzqo .gt_from_md > :last-child {
  margin-bottom: 0;
}

#qeayjdrzqo .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#qeayjdrzqo .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#qeayjdrzqo .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#qeayjdrzqo .gt_row_group_first td {
  border-top-width: 2px;
}

#qeayjdrzqo .gt_row_group_first th {
  border-top-width: 2px;
}

#qeayjdrzqo .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qeayjdrzqo .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#qeayjdrzqo .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#qeayjdrzqo .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qeayjdrzqo .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#qeayjdrzqo .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#qeayjdrzqo .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#qeayjdrzqo .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#qeayjdrzqo .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#qeayjdrzqo .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#qeayjdrzqo .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qeayjdrzqo .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#qeayjdrzqo .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#qeayjdrzqo .gt_left {
  text-align: left;
}

#qeayjdrzqo .gt_center {
  text-align: center;
}

#qeayjdrzqo .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#qeayjdrzqo .gt_font_normal {
  font-weight: normal;
}

#qeayjdrzqo .gt_font_bold {
  font-weight: bold;
}

#qeayjdrzqo .gt_font_italic {
  font-style: italic;
}

#qeayjdrzqo .gt_super {
  font-size: 65%;
}

#qeayjdrzqo .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#qeayjdrzqo .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#qeayjdrzqo .gt_indent_1 {
  text-indent: 5px;
}

#qeayjdrzqo .gt_indent_2 {
  text-indent: 10px;
}

#qeayjdrzqo .gt_indent_3 {
  text-indent: 15px;
}

#qeayjdrzqo .gt_indent_4 {
  text-indent: 20px;
}

#qeayjdrzqo .gt_indent_5 {
  text-indent: 25px;
}

#qeayjdrzqo .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#qeayjdrzqo div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Prisoner's Dilemma Payoffs</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Player-1">Player 1</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Player-2">Player 2</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Payoff-1">Payoff 1</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Payoff-2">Payoff 2</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Player 1" class="gt_row gt_center">Cooperate</td>
<td headers="Player 2" class="gt_row gt_center">Cooperate</td>
<td headers="Payoff 1" class="gt_row gt_center">3</td>
<td headers="Payoff 2" class="gt_row gt_center">3</td></tr>
    <tr><td headers="Player 1" class="gt_row gt_center">Cooperate</td>
<td headers="Player 2" class="gt_row gt_center">Defect</td>
<td headers="Payoff 1" class="gt_row gt_center">0</td>
<td headers="Payoff 2" class="gt_row gt_center">5</td></tr>
    <tr><td headers="Player 1" class="gt_row gt_center">Defect</td>
<td headers="Player 2" class="gt_row gt_center">Cooperate</td>
<td headers="Payoff 1" class="gt_row gt_center">5</td>
<td headers="Payoff 2" class="gt_row gt_center">0</td></tr>
    <tr><td headers="Player 1" class="gt_row gt_center">Defect</td>
<td headers="Player 2" class="gt_row gt_center">Defect</td>
<td headers="Payoff 1" class="gt_row gt_center">1</td>
<td headers="Payoff 2" class="gt_row gt_center">1</td></tr>
  </tbody>
  
</table>
</div>
```

**Step 4 --- Check for dominance.** Regardless of what Player 2 does, Player 1 earns more by defecting (5 > 3 when Player 2 cooperates; 1 > 0 when Player 2 defects). Defect is a *dominant strategy* for Player 1. By symmetry, the same holds for Player 2.

**Step 5 --- Identify the outcome.** Both players defect, yielding payoffs (1, 1). This is the unique Nash equilibrium, yet both players would prefer mutual cooperation at (3, 3). The gap between individual rationality and collective welfare is what makes the Prisoner's Dilemma so compelling --- and why mechanisms for sustaining cooperation, from repeated interaction [@axelrod1981] to enforceable contracts, are among the central concerns of game theory.

## Extensions

The four-element definition introduced here is deliberately minimal. Real-world strategic situations often involve richer structure:

- **Sequential moves and information sets.** When players move in turn and can observe some or all prior actions, we use the *extensive form* --- a game tree that encodes timing and information. See \@ref(sec-extensive-form).
- **Mixed strategies.** Players may randomize over actions. @von-neumann1944 proved that every finite zero-sum game has a value in mixed strategies; @nash1950 extended the existence result to all finite games. We cover mixed strategies in \@ref(sec-mixed-strategies).
- **Incomplete information.** When players are uncertain about others' payoffs or types, we enter the realm of *Bayesian games*, treated in \@ref(sec-bayesian-games).
- **Repeated interaction.** Many strategic encounters happen repeatedly. Repetition can sustain cooperation even in Prisoner's Dilemma settings, a theme explored in \@ref(sec-repeated-games).
- **Multi-agent learning.** When agents learn from experience rather than computing equilibria analytically, game theory intersects with reinforcement learning [@sutton2018]. We develop this connection in \@ref(sec-q-learning) and \@ref(sec-multi-agent-rl).

The compact representation we built in R --- the `make_payoff_df()` function and heatmap visualization --- will be extended in \@ref(sec-normal-form) where we study dominance, best responses, and iterated elimination of dominated strategies.

## Exercises {-}

1. **Identifying game elements.** Consider an intersection where two autonomous vehicles arrive simultaneously. Each can *Go* or *Yield*. If both go, they crash (payoff -5 each). If both yield, they waste time (payoff 0 each). If one goes and the other yields, the goer saves time (payoff 3) and the yielder waits (payoff 1). Write down the four elements (players, actions, payoffs, information) and construct the 2x2 payoff matrix. What type of game is this (zero-sum, coordination, or social dilemma)?

2. **Payoff heatmap.** Using the `make_payoff_df()` function from this chapter, create a payoff matrix for the *Battle of the Sexes* game: two players choose between *Opera* and *Football*. Both prefer to coordinate, but Player 1 prefers Opera (payoffs 3, 2 when both choose Opera) and Player 2 prefers Football (payoffs 2, 3 when both choose Football). Miscoordination yields (0, 0). Plot the heatmap and describe the payoff structure.

3. **Zero-sum verification.** Prove algebraically that Matching Pennies is zero-sum by showing $u_1(a) + u_2(a) = 0$ for every action profile. Then modify the payoffs so that the game is *not* zero-sum but still competitive (Player 1 prefers matching and Player 2 prefers mismatching). Plot both versions side by side using `facet_wrap()`.

4. **From story to model.** Pick a real-world scenario (e.g., two countries deciding whether to impose tariffs, two students deciding how much effort to put into a group project, or two streaming services choosing content investment levels). Identify the players, actions, and a plausible payoff structure. Use `make_payoff_df()` to encode your game and produce the heatmap. Discuss whether the game resembles a Prisoner's Dilemma, coordination game, or something else.

5. **Reading the literature.** Read the first two pages of @nash1950. In your own words, state Nash's definition of an equilibrium point. How does it relate to the concept of a dominant-strategy outcome in the Prisoner's Dilemma?

Solutions appear in \@ref(sec-solutions).
