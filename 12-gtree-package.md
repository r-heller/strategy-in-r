# The gtree Package {#sec-gtree-package}

> Extensive-form games and backward induction with the gtree package's domain-specific language --- plus a from-scratch pure-R implementation for solving game trees when external solvers are unavailable.


## Learning objectives {-}

- Describe the gtree package's domain-specific language (DSL) for specifying extensive-form games as nested stage structures.
- Explain how gtree interfaces with Gambit command-line solvers to compute Nash equilibria of sequential games.
- Build a pure-R game tree representation using nested lists and solve it via backward induction.
- Apply backward induction to the ultimatum game and identify the subgame-perfect equilibrium.
- Visualize a game tree with the equilibrium path highlighted.

## Motivation

Many strategic interactions unfold sequentially: a firm enters a market and the incumbent decides whether to fight or accommodate; a legislature passes a bill and the executive signs or vetoes it; a buyer makes an offer and the seller accepts or rejects. These situations are naturally modeled as *extensive-form games* --- tree structures where nodes represent decisions and edges represent actions.

In \@ref(sec-extensive-form) we introduced game trees and backward induction by hand. That approach works for textbook examples, but as games grow in size (more rounds, more players, more actions per node), manual tree construction becomes error-prone. The **gtree** package, developed by Sebastian Kranz, addresses this gap by providing a compact domain-specific language (DSL) for defining extensive-form games. It constructs the game tree internally and, when the Gambit solver suite is installed, calls industrial-strength algorithms to find equilibria.

However, gtree depends on external binaries (Gambit) and is not always available in every R environment. This chapter therefore pursues a dual strategy: we describe gtree's design and DSL so that readers can evaluate it for their own work, and we implement a complete game tree engine from scratch in pure R. The engine represents trees as nested lists, solves them by backward induction, and produces publication-quality visualizations of the equilibrium path --- all without any dependencies beyond base R and the tidyverse.

## Theory

### The gtree DSL {#sec-gtree-dsl}

The gtree package models an extensive-form game as a sequence of **stages**. Each stage specifies:

- **Who moves**: a named player or "nature" (for chance nodes).
- **What actions are available**: possibly conditional on variables set in earlier stages.
- **What payoffs result**: formulas that reference earlier actions.

A typical gtree specification looks like this (pseudocode, since gtree is not installed):

```
game <- new_game(
  players = c("Proposer", "Responder"),
  stages = list(
    stage("offer",
      player = "Proposer",
      actions = list(action("split", c("Fair", "Unfair")))
    ),
    stage("response",
      player = "Responder",
      actions = list(action("answer", c("Accept", "Reject")))
    )
  ),
  payoffs = list(
    payoff("Proposer",   ~ case_when(
      answer == "Reject" ~ 0,
      split == "Fair"    ~ 5,
      TRUE               ~ 8)),
    payoff("Responder",  ~ case_when(
      answer == "Reject" ~ 0,
      split == "Fair"    ~ 5,
      TRUE               ~ 2))
  )
)
```

The key design insight is that `condition` clauses allow stages to be contingent on prior choices, so the analyst describes the game linearly even though the underlying tree branches. The package internally expands this specification into a full game tree with correctly linked information sets.

### Gambit integration

Once a game is defined, gtree can export it to Gambit's `.efg` (extensive-form game) format and invoke Gambit's command-line solvers:

- `gambit-enumpure` enumerates all pure-strategy Nash equilibria.
- `gambit-enummixed` enumerates all mixed-strategy equilibria for two-player games.
- `gambit-lcp` uses the Lemke--Howson algorithm for bimatrix games (see \@ref(sec-custom-solvers)).
- `gambit-logit` computes quantal response equilibria.

This makes gtree a convenient R front-end for industrial-strength solvers without requiring the analyst to learn Gambit's file format or command-line interface.

### Backward induction for perfect-information games {#sec-backward-induction-theory}

For games of **perfect information** --- where every information set is a singleton --- backward induction provides an exact solution. The algorithm works from the terminal nodes back to the root: at each decision node, the moving player selects the action that maximizes their own payoff, given that all subsequent players will do the same.

::: {.rmdnote}
**Definition: Subgame-Perfect Equilibrium (SPE)**

A strategy profile is a **subgame-perfect equilibrium** if it constitutes a Nash equilibrium in every subgame of the original game. For finite games of perfect information, backward induction yields the unique SPE (when payoffs at terminal nodes are distinct).
:::

The time complexity of backward induction is $O(n)$ where $n$ is the number of nodes in the tree, since each node is visited exactly once. For a tree with branching factor $b$ and depth $d$, the total number of nodes is:

\begin{equation}
n = \frac{b^{d+1} - 1}{b - 1}
(\#eq:tree-nodes)
\end{equation}

This exponential growth in tree size is the fundamental computational challenge --- but backward induction remains efficient because it processes each node exactly once.

### The ultimatum game

The **ultimatum game** is a canonical example in behavioral economics. A Proposer has a sum of money (say, 10 units) and offers a split to a Responder. The Responder either Accepts (both receive their shares) or Rejects (both receive nothing). Despite the intuition that any positive offer should be accepted, experimental evidence consistently shows that offers below 20--30% are frequently rejected.

The game-theoretic prediction under backward induction is stark: the Responder should accept any positive offer (since something is better than nothing), and therefore the Proposer should offer the minimum possible amount. This divergence between theory and behavior makes the ultimatum game a rich pedagogical example.

## Implementation in R {#sec-gtree-implementation}

### A flexible game tree representation

We represent game trees as nested lists. Each node is either a *decision node* (with a player and children) or a *terminal node* (with payoffs for all players).


``` r
# A terminal node stores final payoffs for all players
make_terminal <- function(payoffs) {
  list(type = "terminal", payoffs = payoffs)
}

# A decision node stores who moves and a named list of children
make_decision <- function(player, children) {
  list(type = "decision", player = player, children = children)
}

# Backward induction: recursively solve from leaves to root
solve_by_backward_induction <- function(node) {
  if (node$type == "terminal") {
    return(list(payoffs = node$payoffs, path = list()))
  }

  # Recursively solve all children
  solutions <- lapply(node$children, solve_by_backward_induction)

  # Current player picks child maximizing their own payoff

  player <- node$player
  child_payoffs <- sapply(solutions, function(s) s$payoffs[player])
  best_idx <- which.max(child_payoffs)
  best_action <- names(node$children)[best_idx]
  best_solution <- solutions[[best_idx]]

  list(
    payoffs = best_solution$payoffs,
    path = c(
      list(list(player = player, action = best_action)),
      best_solution$path
    )
  )
}
```

### Building the ultimatum game tree


``` r
# Ultimatum game: Proposer offers Fair (5,5) or Unfair (8,2)
# Responder Accepts or Rejects each offer

ultimatum_game <- make_decision(1, list(
  "Fair (5,5)" = make_decision(2, list(
    "Accept" = make_terminal(c(5, 5)),
    "Reject" = make_terminal(c(0, 0))
  )),
  "Unfair (8,2)" = make_decision(2, list(
    "Accept" = make_terminal(c(8, 2)),
    "Reject" = make_terminal(c(0, 0))
  ))
))

result <- solve_by_backward_induction(ultimatum_game)
cat("Subgame-perfect equilibrium payoffs:", result$payoffs, "\n\n")
```

```
#> Subgame-perfect equilibrium payoffs: 8 2
```

``` r
cat("SPE path:\n")
```

```
#> SPE path:
```

``` r
for (step in result$path) {
  player_label <- c("Proposer", "Responder")[step$player]
  cat(glue("  {player_label} chooses: {step$action}"), "\n")
}
```

```
#>   Proposer chooses: Unfair (8,2) 
#>   Responder chooses: Accept
```

As predicted by the theory, backward induction selects the Unfair offer (since 8 > 5 for the Proposer) and the Responder Accepts (since 2 > 0). The SPE payoffs are (8, 2).

### Visualizing the game tree {#sec-game-tree-viz}

To build a publication-quality game tree figure, we first flatten the tree into a data frame of nodes and edges, then use `ggplot2` to render it with the equilibrium path highlighted.


``` r
# Flatten tree into node and edge data frames for plotting
flatten_tree <- function(node, node_id = 1, depth = 0, x_center = 0,
                         x_spread = 2, eq_path = NULL) {
  nodes <- tibble()
  edges <- tibble()

  if (node$type == "terminal") {
    payoff_label <- paste0("(", paste(node$payoffs, collapse = ", "), ")")
    nodes <- tibble(
      id = node_id, depth = depth, x = x_center,
      label = payoff_label, node_type = "terminal", player = NA_integer_
    )
    return(list(nodes = nodes, edges = edges, next_id = node_id + 1))
  }

  # Decision node
  player_labels <- c("Proposer", "Responder")
  nodes <- tibble(
    id = node_id, depth = depth, x = x_center,
    label = player_labels[node$player], node_type = "decision",
    player = node$player
  )

  n_children <- length(node$children)
  child_positions <- seq(-x_spread / 2, x_spread / 2, length.out = n_children)
  next_id <- node_id + 1

  for (i in seq_along(node$children)) {
    action_name <- names(node$children)[i]
    child_node <- node$children[[i]]

    # Check if this edge is on the equilibrium path
    on_eq_path <- FALSE
    if (!is.null(eq_path) && length(eq_path) > 0) {
      step <- eq_path[[1]]
      if (step$player == node$player && step$action == action_name) {
        on_eq_path <- TRUE
      }
    }

    child_result <- flatten_tree(
      child_node, next_id, depth + 1,
      x_center + child_positions[i], x_spread / 2,
      eq_path = if (on_eq_path && length(eq_path) > 1) eq_path[-1] else
                if (on_eq_path) list() else NULL
    )

    new_edge <- tibble(
      from_id = node_id, to_id = next_id,
      from_x = x_center, from_y = -depth,
      to_x = x_center + child_positions[i], to_y = -(depth + 1),
      action = action_name, on_eq_path = on_eq_path
    )

    edges <- bind_rows(edges, new_edge, child_result$edges)
    nodes <- bind_rows(nodes, child_result$nodes)
    next_id <- child_result$next_id
  }

  list(nodes = nodes, edges = edges, next_id = next_id)
}
```


``` r
tree_data <- flatten_tree(
  ultimatum_game, eq_path = result$path, x_spread = 4
)

nodes_df <- tree_data$nodes |>
  mutate(y = -depth)

edges_df <- tree_data$edges

p_tree <- ggplot() +
  # Draw edges (non-equilibrium first, then equilibrium on top)
  geom_segment(
    data = edges_df |> filter(!on_eq_path),
    aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    colour = "grey60", linewidth = 0.7
  ) +
  geom_segment(
    data = edges_df |> filter(on_eq_path),
    aes(x = from_x, y = from_y, xend = to_x, yend = to_y),
    colour = okabe_ito[1], linewidth = 1.5
  ) +
  # Action labels on edges
  geom_label(
    data = edges_df,
    aes(x = (from_x + to_x) / 2, y = (from_y + to_y) / 2, label = action),
    size = 2.8, label.size = 0, fill = "white", alpha = 0.85
  ) +
  # Decision nodes
  geom_point(
    data = nodes_df |> filter(node_type == "decision"),
    aes(x = x, y = y, colour = factor(player)),
    size = 8
  ) +
  # Decision node labels
  geom_text(
    data = nodes_df |> filter(node_type == "decision"),
    aes(x = x, y = y, label = label),
    size = 2.5, colour = "white", fontface = "bold"
  ) +
  # Terminal node labels (payoffs)
  geom_label(
    data = nodes_df |> filter(node_type == "terminal"),
    aes(x = x, y = y, label = label),
    size = 3, fill = "grey95", label.padding = unit(0.2, "lines")
  ) +
  scale_colour_manual(
    values = c("1" = okabe_ito[1], "2" = okabe_ito[2]),
    labels = c("Proposer", "Responder"),
    name = "Player"
  ) +
  coord_cartesian(
    xlim = c(-3, 3),
    ylim = c(-2.5, 0.3)
  ) +
  labs(title = "Ultimatum Game: Subgame-Perfect Equilibrium Path") +
  theme_publication() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

p_tree
```

<div class="figure" style="text-align: center">
<img src="12-gtree-package_files/figure-epub3/ultimatum-tree-1.png" alt="Game tree for the ultimatum game. The Proposer (orange node) chooses between a Fair and Unfair split; the Responder (blue nodes) then Accepts or Rejects. The bold orange path marks the subgame-perfect equilibrium: Proposer offers Unfair (8, 2) and Responder Accepts." width="80%" />
<p class="caption">(\#fig:ultimatum-tree)Game tree for the ultimatum game. The Proposer (orange node) chooses between a Fair and Unfair split; the Responder (blue nodes) then Accepts or Rejects. The bold orange path marks the subgame-perfect equilibrium: Proposer offers Unfair (8, 2) and Responder Accepts.</p>
</div>

``` r
save_pub_fig(p_tree, "ultimatum-game-tree", width = 8, height = 5.5)
```

The figure makes the structure of the SPE transparent. At each of the Responder's decision nodes, Accepting yields a positive payoff while Rejecting yields zero --- so the Responder always Accepts. Knowing this, the Proposer selects the split that maximizes their own share, choosing the Unfair offer.

## Worked example {#sec-ultimatum-worked-example}

Let us extend the ultimatum game to allow three possible offers and solve it step by step.

**Setup.** The Proposer has 10 units and can offer three splits:

| Offer     | Proposer receives | Responder receives |
|-----------|------------------:|-------------------:|
| Generous  | 4                 | 6                  |
| Fair      | 5                 | 5                  |
| Greedy    | 9                 | 1                  |

The Responder observes the offer and chooses Accept or Reject. If Rejected, both receive 0.


``` r
# Three-offer ultimatum game
ultimatum_3 <- make_decision(1, list(
  "Generous (4,6)" = make_decision(2, list(
    "Accept" = make_terminal(c(4, 6)),
    "Reject" = make_terminal(c(0, 0))
  )),
  "Fair (5,5)" = make_decision(2, list(
    "Accept" = make_terminal(c(5, 5)),
    "Reject" = make_terminal(c(0, 0))
  )),
  "Greedy (9,1)" = make_decision(2, list(
    "Accept" = make_terminal(c(9, 1)),
    "Reject" = make_terminal(c(0, 0))
  ))
))

result_3 <- solve_by_backward_induction(ultimatum_3)
cat("SPE payoffs:", result_3$payoffs, "\n\n")
```

```
#> SPE payoffs: 9 1
```

``` r
cat("SPE path:\n")
```

```
#> SPE path:
```

``` r
for (step in result_3$path) {
  player_label <- c("Proposer", "Responder")[step$player]
  cat(glue("  {player_label} chooses: {step$action}"), "\n")
}
```

```
#>   Proposer chooses: Greedy (9,1) 
#>   Responder chooses: Accept
```

**Step-by-step reasoning:**

1. **Responder's subgames.** At each of the three decision nodes, the Responder compares Accept vs. Reject. Since Accepting always yields a positive payoff (6, 5, or 1) while Rejecting yields 0, the Responder Accepts every offer.

2. **Proposer's choice.** Knowing the Responder will Accept any offer, the Proposer compares their own payoffs: 4 (Generous), 5 (Fair), or 9 (Greedy). The Proposer selects the Greedy offer.

3. **SPE outcome.** The Proposer offers (9, 1) and the Responder Accepts, yielding equilibrium payoffs $(9, 1)$.

This result highlights the starkness of the game-theoretic prediction: rational, self-interested players reach an extreme outcome. The large experimental literature on ultimatum games shows that this prediction fails descriptively --- Responders frequently reject low offers and Proposers often offer 40--50% --- which motivates models incorporating fairness preferences, spite, and social norms.

### Scaling analysis

How does backward induction perform as the game tree grows? We generate random trees of varying depth and branching factor and record solution times.


``` r
# Generate random perfect-information game trees
generate_random_tree <- function(depth, branching, n_players = 2) {
  if (depth == 0) {
    return(make_terminal(runif(n_players, -5, 5)))
  }
  player <- ((depth - 1) %% n_players) + 1
  children <- setNames(
    lapply(seq_len(branching), function(i) {
      generate_random_tree(depth - 1, branching, n_players)
    }),
    paste0("A", seq_len(branching))
  )
  make_decision(player, children)
}

configs <- expand.grid(depth = 2:8, branching = c(2, 3)) |>
  as_tibble() |>
  mutate(n_terminals = branching^depth, time_ms = NA_real_)

for (i in seq_len(nrow(configs))) {
  tree <- generate_random_tree(configs$depth[i], configs$branching[i])
  elapsed <- system.time(solve_by_backward_induction(tree))["elapsed"]
  configs$time_ms[i] <- elapsed * 1000
}

configs |>
  mutate(branching = factor(branching)) |>
  select(depth, branching, n_terminals, time_ms) |>
  gt() |>
  tab_header(title = "Backward Induction: Solution Time by Tree Size") |>
  fmt_number(columns = time_ms, decimals = 2) |>
  fmt_number(columns = n_terminals, use_seps = TRUE, decimals = 0) |>
  cols_label(
    depth = "Depth", branching = "Branching",
    n_terminals = "Terminal Nodes", time_ms = "Time (ms)"
  )
```

```{=html}
<div id="xpgxtiazzl" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xpgxtiazzl table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#xpgxtiazzl thead, #xpgxtiazzl tbody, #xpgxtiazzl tfoot, #xpgxtiazzl tr, #xpgxtiazzl td, #xpgxtiazzl th {
  border-style: none;
}

#xpgxtiazzl p {
  margin: 0;
  padding: 0;
}

#xpgxtiazzl .gt_table {
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

#xpgxtiazzl .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#xpgxtiazzl .gt_title {
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

#xpgxtiazzl .gt_subtitle {
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

#xpgxtiazzl .gt_heading {
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

#xpgxtiazzl .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xpgxtiazzl .gt_col_headings {
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

#xpgxtiazzl .gt_col_heading {
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

#xpgxtiazzl .gt_column_spanner_outer {
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

#xpgxtiazzl .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#xpgxtiazzl .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#xpgxtiazzl .gt_column_spanner {
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

#xpgxtiazzl .gt_spanner_row {
  border-bottom-style: hidden;
}

#xpgxtiazzl .gt_group_heading {
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

#xpgxtiazzl .gt_empty_group_heading {
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

#xpgxtiazzl .gt_from_md > :first-child {
  margin-top: 0;
}

#xpgxtiazzl .gt_from_md > :last-child {
  margin-bottom: 0;
}

#xpgxtiazzl .gt_row {
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

#xpgxtiazzl .gt_stub {
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

#xpgxtiazzl .gt_stub_row_group {
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

#xpgxtiazzl .gt_row_group_first td {
  border-top-width: 2px;
}

#xpgxtiazzl .gt_row_group_first th {
  border-top-width: 2px;
}

#xpgxtiazzl .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xpgxtiazzl .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#xpgxtiazzl .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#xpgxtiazzl .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xpgxtiazzl .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xpgxtiazzl .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#xpgxtiazzl .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#xpgxtiazzl .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#xpgxtiazzl .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xpgxtiazzl .gt_footnotes {
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

#xpgxtiazzl .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xpgxtiazzl .gt_sourcenotes {
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

#xpgxtiazzl .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xpgxtiazzl .gt_left {
  text-align: left;
}

#xpgxtiazzl .gt_center {
  text-align: center;
}

#xpgxtiazzl .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#xpgxtiazzl .gt_font_normal {
  font-weight: normal;
}

#xpgxtiazzl .gt_font_bold {
  font-weight: bold;
}

#xpgxtiazzl .gt_font_italic {
  font-style: italic;
}

#xpgxtiazzl .gt_super {
  font-size: 65%;
}

#xpgxtiazzl .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#xpgxtiazzl .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#xpgxtiazzl .gt_indent_1 {
  text-indent: 5px;
}

#xpgxtiazzl .gt_indent_2 {
  text-indent: 10px;
}

#xpgxtiazzl .gt_indent_3 {
  text-indent: 15px;
}

#xpgxtiazzl .gt_indent_4 {
  text-indent: 20px;
}

#xpgxtiazzl .gt_indent_5 {
  text-indent: 25px;
}

#xpgxtiazzl .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#xpgxtiazzl div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="4" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Backward Induction: Solution Time by Tree Size</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="depth">Depth</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="branching">Branching</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_terminals">Terminal Nodes</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="time_ms">Time (ms)</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="depth" class="gt_row gt_right">2</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">4</td>
<td headers="time_ms" class="gt_row gt_right">1.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">3</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">8</td>
<td headers="time_ms" class="gt_row gt_right">0.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">4</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">16</td>
<td headers="time_ms" class="gt_row gt_right">0.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">5</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">32</td>
<td headers="time_ms" class="gt_row gt_right">0.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">6</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">64</td>
<td headers="time_ms" class="gt_row gt_right">1.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">7</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">128</td>
<td headers="time_ms" class="gt_row gt_right">3.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">8</td>
<td headers="branching" class="gt_row gt_center">2</td>
<td headers="n_terminals" class="gt_row gt_right">256</td>
<td headers="time_ms" class="gt_row gt_right">5.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">2</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">9</td>
<td headers="time_ms" class="gt_row gt_right">0.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">3</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">27</td>
<td headers="time_ms" class="gt_row gt_right">0.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">4</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">81</td>
<td headers="time_ms" class="gt_row gt_right">1.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">5</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">243</td>
<td headers="time_ms" class="gt_row gt_right">2.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">6</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">729</td>
<td headers="time_ms" class="gt_row gt_right">7.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">7</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">2,187</td>
<td headers="time_ms" class="gt_row gt_right">22.00</td></tr>
    <tr><td headers="depth" class="gt_row gt_right">8</td>
<td headers="branching" class="gt_row gt_center">3</td>
<td headers="n_terminals" class="gt_row gt_right">6,561</td>
<td headers="time_ms" class="gt_row gt_right">67.00</td></tr>
  </tbody>
  
</table>
</div>
```


``` r
p_scaling <- configs |>
  mutate(branching = factor(branching,
    labels = c("Binary (b=2)", "Ternary (b=3)")
  )) |>
  ggplot(aes(x = n_terminals, y = time_ms,
             colour = branching, shape = branching)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  scale_colour_manual(values = okabe_ito[c(1, 2)]) +
  scale_x_log10(name = "Number of terminal nodes",
                labels = label_comma()) +
  scale_y_log10(name = "Solution time (ms)") +
  labs(
    title = "Backward Induction Scales Linearly with Tree Size",
    colour = "Tree type", shape = "Tree type"
  ) +
  theme_publication()

p_scaling
```

<div class="figure" style="text-align: center">
<img src="12-gtree-package_files/figure-epub3/gtree-scaling-1.png" alt="Backward induction solution time as a function of the number of terminal nodes. Both binary and ternary trees show approximately linear growth, confirming the O(n) complexity of the algorithm." width="80%" />
<p class="caption">(\#fig:gtree-scaling)Backward induction solution time as a function of the number of terminal nodes. Both binary and ternary trees show approximately linear growth, confirming the O(n) complexity of the algorithm.</p>
</div>

``` r
save_pub_fig(p_scaling, "gtree-scaling-analysis", width = 7, height = 4.5)
```

The log-log plot confirms the expected linear relationship between tree size and computation time. Binary trees with depth 8 have $2^8 = 256$ terminal nodes and solve in well under a millisecond. Even ternary trees at depth 8 ($3^8 = 6{,}561$ terminals) remain fast. The real computational challenge arises with imperfect information, where backward induction no longer applies and one must resort to solvers like Gambit.

## Extensions

The game tree engine and backward induction solver developed here connect to several other topics in this book:

- **Extensive-form games** (\@ref(sec-extensive-form)) provides the theoretical foundation for the tree representation used here. The present chapter adds the computational machinery to solve those trees at scale.
- **Custom solvers** (\@ref(sec-custom-solvers)) implements support enumeration and other algorithms for normal-form games. For extensive-form games with imperfect information, converting to normal form and applying these solvers is a standard approach.
- **nashpy via reticulate** (\@ref(sec-nashpy-reticulate)) offers another route for computing mixed-strategy equilibria after normal-form conversion.
- **Bargaining** (\@ref(sec-bargaining)) extends the ultimatum game to multi-round alternating offers, where the discount factor determines the equilibrium split. The Rubinstein model in that chapter can be solved directly with the backward induction engine developed here.

For the foundational theory of extensive-form games and backward induction, see @von-neumann1944 and @osborne2004 (Chapters 5--7). The existence of subgame-perfect equilibria in finite games of perfect information is guaranteed by Zermelo's theorem, which predates @nash1950 but complements the Nash equilibrium framework. For comprehensive coverage of the Gambit solvers, see the Gambit documentation and @shoham2009 (Chapter 4). The gtree package vignettes provide tutorials for games with simultaneous moves within stages, nature nodes, and parameterized game families.

## Exercises {-}

1. **Centipede game.** Encode a six-round centipede game where two players alternate. At each node, the current player can Stop (receiving $2k$ while the other receives $0$, where $k$ is the round number) or Continue. If both Continue for all six rounds, each receives 7. Solve by backward induction. Does the SPE match experimental evidence on centipede games?

2. **Discount factor sensitivity.** Modify the ultimatum game so that rejection leads to a second round (with both players' payoffs discounted by $\delta$) where the Responder becomes the Proposer. Solve for $\delta \in \{0.5, 0.7, 0.9, 0.99\}$ and plot the Proposer's equilibrium payoff as a function of $\delta$. How does patience affect the first mover's advantage?

3. **Visualizing larger trees.** Extend the `flatten_tree()` function to handle a three-round bargaining game (alternating Proposers, two actions per round, acceptance or rejection at each stage). Generate the game tree visualization with the equilibrium path highlighted. What modifications to the layout algorithm are needed to prevent node overlap at deeper levels?

Solutions appear in \@ref(sec-solutions).
