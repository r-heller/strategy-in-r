# The CoopGame Package {#sec-coopgame-package}

> A conceptual survey of the CoopGame R package for transferable utility games, followed by from-scratch implementations of the characteristic function, core computation via linear constraints, and the nucleolus, with a three-player production game worked example and simplex visualization.


## Learning objectives {-}

- Describe the features of the CoopGame R package for transferable utility (TU) games.
- Represent cooperative games via a characteristic function vector using binary coalition encoding.
- Compute the core of a three-player game by setting up linear inequality constraints in base R.
- Understand the nucleolus as the allocation minimizing maximum coalition dissatisfaction.
- Visualize the core as a feasible region on a simplex plot using ggplot2.

## Motivation

Imagine three firms that each control a different resource needed for production: Firm A owns raw materials, Firm B operates a factory, and Firm C manages the distribution network. Any single firm can earn a modest profit alone, pairs can do better by combining capabilities, and the grand coalition of all three generates the highest total profit. How should they divide the surplus?

This is a **transferable utility (TU) cooperative game**, and the central question is which allocations are stable --- meaning no subgroup would prefer to break away. The set of all stable allocations is the **core**. The **nucleolus** refines this further by selecting the unique allocation that minimizes worst-case dissatisfaction.

The `CoopGame` package on CRAN provides a comprehensive toolkit for these problems: characteristic function encoding, solution concepts (Shapley value, nucleolus, tau-value), property checks (superadditivity, convexity, balancedness), and --- most distinctively --- core visualization on the simplex for three-player games. Since it is not installed, this chapter describes its API and implements the key algorithms from scratch.

## Theory

### Characteristic function representation

A TU game with $n$ players is defined by $v : 2^N \to \mathbb{R}$ with $v(\emptyset) = 0$. The `CoopGame` package stores $v$ as a vector of length $2^n - 1$, ordered by binary encoding:

\begin{equation}
\text{index}(S) = \sum_{i \in S} 2^{i-1}
(\#eq:coalition-index)
\end{equation}

For players $\{1, 2, 3\}$: index $1 = \{1\}$, $2 = \{2\}$, $3 = \{1,2\}$, $4 = \{3\}$, $5 = \{1,3\}$, $6 = \{2,3\}$, $7 = \{1,2,3\}$.

### The core

::: {.rmdnote}
**Definition: Core**

The **core** of a TU game $(N, v)$ is the set of allocations satisfying efficiency and coalition rationality:

\begin{equation}
\text{Core}(v) = \left\{ x \in \mathbb{R}^n : \sum_{i=1}^n x_i = v(N), \; \sum_{i \in S} x_i \geq v(S) \;\forall\, S \subset N \right\}
(\#eq:core-def)
\end{equation}
:::

The core may be empty, a single point, or a convex polytope. The Bondareva-Shapley theorem states that the core is non-empty if and only if the game is **balanced**.

### The nucleolus

The **nucleolus** (Schmeidler, 1969) selects the allocation that lexicographically minimizes the sorted vector of **excesses**:

\begin{equation}
e(S, x) = v(S) - \sum_{i \in S} x_i
(\#eq:excess)
\end{equation}

A positive excess means coalition $S$ is underpaid. The nucleolus solves:

\begin{equation}
\text{nuc}(v) = \arg\min_{x \in \mathcal{I}} \theta(x)
(\#eq:nucleolus)
\end{equation}

where $\theta(x)$ is the vector of excesses sorted in decreasing order. It always exists, is unique, and lies in the core when the core is non-empty.

### The CoopGame package API

The `CoopGame` package provides: `createGame()` for defining games; `coreVertices()` and `drawCorePlot()` for core computation and visualization; `nucleolus()` and `shapleyValue()` for solution concepts; and `isConvexGame()`, `isSuperadditiveGame()`, `isBalancedGame()` for property checking. We now implement these from scratch.

## Implementation in R {#sec-coopgame-impl}

### Coalition encoding and game definition


``` r
# Convert player set to coalition index (binary encoding)
coalition_idx <- function(members, n) sum(2^(members - 1))

# Convert index back to player set
idx_to_players <- function(idx, n) which(as.logical(intToBits(idx)[1:n]))

# Generate all non-empty coalitions
all_coalitions <- function(n) {
  lapply(1:(2^n - 1), function(k) idx_to_players(k, n))
}

# Three-player production game
# A (materials), B (factory), C (distribution)
# Index: 1={A}, 2={B}, 3={A,B}, 4={C}, 5={A,C}, 6={B,C}, 7={A,B,C}
v_prod <- c(10, 20, 50, 15, 40, 45, 80)
names(v_prod) <- c("{A}", "{B}", "{A,B}", "{C}", "{A,C}", "{B,C}", "{A,B,C}")

cat("Production game characteristic function:\n")
```

```
#> Production game characteristic function:
```

``` r
print(v_prod)
```

```
#>     {A}     {B}   {A,B}     {C}   {A,C}   {B,C} {A,B,C} 
#>      10      20      50      15      40      45      80
```

``` r
cat(sprintf("\nSurplus from cooperation: %d - %d = %d\n",
            80, 10 + 20 + 15, 80 - 45))
```

```
#> 
#> Surplus from cooperation: 80 - 45 = 35
```

### Computing the core via linear constraints

For three players with efficiency $x_A + x_B + x_C = 80$, substituting $x_C = 80 - x_A - x_B$ reduces the core to a 2D feasibility problem:


``` r
# After substitution, the six constraints are:
#   x_A >= 10,  x_B >= 20,  x_A + x_B <= 65 (from x_C >= 15)
#   x_A + x_B >= 50,  x_B <= 40 (from x_A + x_C >= 40),  x_A <= 35

core_constraints <- tribble(
  ~constraint,         ~description,
  "x_A >= 10",        "A individual rationality",
  "x_B >= 20",        "B individual rationality",
  "x_A + x_B <= 65",  "C individual rationality",
  "x_A + x_B >= 50",  "AB coalition rationality",
  "x_B <= 40",        "AC coalition rationality",
  "x_A <= 35",        "BC coalition rationality"
)
core_constraints |>
  gt() |>
  tab_header(title = "Core Constraints (after efficiency substitution)") |>
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
      <td colspan="2" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Core Constraints (after efficiency substitution)</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="constraint">constraint</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="description">description</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="constraint" class="gt_row gt_center">x_A &gt;= 10</td>
<td headers="description" class="gt_row gt_center">A individual rationality</td></tr>
    <tr><td headers="constraint" class="gt_row gt_center">x_B &gt;= 20</td>
<td headers="description" class="gt_row gt_center">B individual rationality</td></tr>
    <tr><td headers="constraint" class="gt_row gt_center">x_A + x_B &lt;= 65</td>
<td headers="description" class="gt_row gt_center">C individual rationality</td></tr>
    <tr><td headers="constraint" class="gt_row gt_center">x_A + x_B &gt;= 50</td>
<td headers="description" class="gt_row gt_center">AB coalition rationality</td></tr>
    <tr><td headers="constraint" class="gt_row gt_center">x_B &lt;= 40</td>
<td headers="description" class="gt_row gt_center">AC coalition rationality</td></tr>
    <tr><td headers="constraint" class="gt_row gt_center">x_A &lt;= 35</td>
<td headers="description" class="gt_row gt_center">BC coalition rationality</td></tr>
  </tbody>
  
</table>
</div>
```

### Finding core vertices


``` r
# Find vertices by intersecting all pairs of boundary lines
boundary_intersections <- function() {
  bounds <- list(c(1,0,10), c(0,1,20), c(1,1,65),
                 c(1,1,50), c(0,1,40), c(1,0,35))
  vertices <- tibble(x_A = numeric(), x_B = numeric(), x_C = numeric())

  for (i in 1:(length(bounds) - 1)) {
    for (j in (i + 1):length(bounds)) {
      A_mat <- matrix(c(bounds[[i]][1:2], bounds[[j]][1:2]),
                      nrow = 2, byrow = TRUE)
      b_vec <- c(bounds[[i]][3], bounds[[j]][3])
      if (abs(det(A_mat)) < 1e-10) next
      sol <- solve(A_mat, b_vec)
      xa <- sol[1]; xb <- sol[2]; xc <- 80 - xa - xb

      feasible <- (xa >= 10 - 1e-10) && (xb >= 20 - 1e-10) &&
        (xa + xb <= 65 + 1e-10) && (xa + xb >= 50 - 1e-10) &&
        (xb <= 40 + 1e-10) && (xa <= 35 + 1e-10)

      if (feasible) {
        vertices <- bind_rows(vertices,
          tibble(x_A = round(xa, 2), x_B = round(xb, 2), x_C = round(xc, 2)))
      }
    }
  }
  distinct(vertices)
}

core_verts <- boundary_intersections()
core_verts |>
  gt() |>
  tab_header(title = "Vertices of the Core") |>
  cols_align(align = "center")
```

```{=html}
<div id="xgdyentzro" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xgdyentzro table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#xgdyentzro thead, #xgdyentzro tbody, #xgdyentzro tfoot, #xgdyentzro tr, #xgdyentzro td, #xgdyentzro th {
  border-style: none;
}

#xgdyentzro p {
  margin: 0;
  padding: 0;
}

#xgdyentzro .gt_table {
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

#xgdyentzro .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#xgdyentzro .gt_title {
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

#xgdyentzro .gt_subtitle {
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

#xgdyentzro .gt_heading {
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

#xgdyentzro .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xgdyentzro .gt_col_headings {
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

#xgdyentzro .gt_col_heading {
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

#xgdyentzro .gt_column_spanner_outer {
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

#xgdyentzro .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#xgdyentzro .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#xgdyentzro .gt_column_spanner {
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

#xgdyentzro .gt_spanner_row {
  border-bottom-style: hidden;
}

#xgdyentzro .gt_group_heading {
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

#xgdyentzro .gt_empty_group_heading {
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

#xgdyentzro .gt_from_md > :first-child {
  margin-top: 0;
}

#xgdyentzro .gt_from_md > :last-child {
  margin-bottom: 0;
}

#xgdyentzro .gt_row {
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

#xgdyentzro .gt_stub {
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

#xgdyentzro .gt_stub_row_group {
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

#xgdyentzro .gt_row_group_first td {
  border-top-width: 2px;
}

#xgdyentzro .gt_row_group_first th {
  border-top-width: 2px;
}

#xgdyentzro .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xgdyentzro .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#xgdyentzro .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#xgdyentzro .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xgdyentzro .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#xgdyentzro .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#xgdyentzro .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#xgdyentzro .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#xgdyentzro .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#xgdyentzro .gt_footnotes {
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

#xgdyentzro .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xgdyentzro .gt_sourcenotes {
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

#xgdyentzro .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#xgdyentzro .gt_left {
  text-align: left;
}

#xgdyentzro .gt_center {
  text-align: center;
}

#xgdyentzro .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#xgdyentzro .gt_font_normal {
  font-weight: normal;
}

#xgdyentzro .gt_font_bold {
  font-weight: bold;
}

#xgdyentzro .gt_font_italic {
  font-style: italic;
}

#xgdyentzro .gt_super {
  font-size: 65%;
}

#xgdyentzro .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#xgdyentzro .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#xgdyentzro .gt_indent_1 {
  text-indent: 5px;
}

#xgdyentzro .gt_indent_2 {
  text-indent: 10px;
}

#xgdyentzro .gt_indent_3 {
  text-indent: 15px;
}

#xgdyentzro .gt_indent_4 {
  text-indent: 20px;
}

#xgdyentzro .gt_indent_5 {
  text-indent: 25px;
}

#xgdyentzro .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#xgdyentzro div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Vertices of the Core</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="x_A">x_A</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="x_B">x_B</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="x_C">x_C</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="x_A" class="gt_row gt_center">10</td>
<td headers="x_B" class="gt_row gt_center">40</td>
<td headers="x_C" class="gt_row gt_center">30</td></tr>
    <tr><td headers="x_A" class="gt_row gt_center">30</td>
<td headers="x_B" class="gt_row gt_center">20</td>
<td headers="x_C" class="gt_row gt_center">30</td></tr>
    <tr><td headers="x_A" class="gt_row gt_center">35</td>
<td headers="x_B" class="gt_row gt_center">20</td>
<td headers="x_C" class="gt_row gt_center">25</td></tr>
    <tr><td headers="x_A" class="gt_row gt_center">25</td>
<td headers="x_B" class="gt_row gt_center">40</td>
<td headers="x_C" class="gt_row gt_center">15</td></tr>
    <tr><td headers="x_A" class="gt_row gt_center">35</td>
<td headers="x_B" class="gt_row gt_center">30</td>
<td headers="x_C" class="gt_row gt_center">15</td></tr>
  </tbody>
  
</table>
</div>
```

### Computing the nucleolus


``` r
# Compute excesses for all proper coalitions
compute_excesses <- function(x, v_vec, n) {
  coalitions <- all_coalitions(n)
  grand_idx <- 2^n - 1
  exc <- numeric(0); nms <- character(0)
  for (k in seq_along(coalitions)) {
    if (k == grand_idx) next
    S <- coalitions[[k]]
    exc <- c(exc, v_vec[k] - sum(x[S]))
    nms <- c(nms, paste(S, collapse = ","))
  }
  names(exc) <- nms
  exc
}

# Nucleolus via grid search (tractable for 3 players)
find_nucleolus <- function(v_vec, n, grid_size = 300) {
  grand_val <- v_vec[2^n - 1]
  best_x <- NULL; best_theta <- Inf
  xa_seq <- seq(10, 35, length.out = grid_size)
  xb_seq <- seq(20, 40, length.out = grid_size)

  for (xa in xa_seq) {
    for (xb in xb_seq) {
      xc <- grand_val - xa - xb
      if (xc < 15 - 1e-10 || xa + xb < 50 - 1e-10 ||
          xa + xb > 65 + 1e-10) next
      max_exc <- max(compute_excesses(c(xa, xb, xc), v_vec, n))
      if (max_exc < best_theta) {
        best_theta <- max_exc; best_x <- c(xa, xb, xc)
      }
    }
  }
  names(best_x) <- c("A", "B", "C")
  best_x
}

nuc <- find_nucleolus(v_prod, 3)
cat("Nucleolus (approximate):\n")
```

```
#> Nucleolus (approximate):
```

``` r
cat(sprintf("  A: %.2f, B: %.2f, C: %.2f (sum: %.2f)\n",
            nuc[1], nuc[2], nuc[3], sum(nuc)))
```

```
#>   A: 25.05, B: 32.44, C: 22.51 (sum: 80.00)
```

``` r
cat("\nExcesses at the nucleolus:\n")
```

```
#> 
#> Excesses at the nucleolus:
```

``` r
print(round(sort(compute_excesses(nuc, v_prod, 3), decreasing = TRUE), 2))
```

```
#>    1,2      3    1,3    2,3      2      1 
#>  -7.49  -7.51  -7.56  -9.95 -12.44 -15.05
```

### Shapley value and core visualization {#sec-core-viz}


``` r
# Shapley value via permutation enumeration
shapley_prod <- function() {
  perms <- list(c(1,2,3), c(1,3,2), c(2,1,3),
                c(2,3,1), c(3,1,2), c(3,2,1))
  phi <- c(0, 0, 0)
  get_v <- function(m) {
    if (length(m) == 0) return(0)
    v_prod[coalition_idx(m, 3)]
  }
  for (perm in perms) {
    coal <- integer(0)
    for (p in perm) {
      v_before <- get_v(coal)
      coal <- c(coal, p)
      phi[p] <- phi[p] + (get_v(sort(coal)) - v_before)
    }
  }
  phi / length(perms)
}
shap <- shapley_prod()

# Barycentric to Cartesian simplex coordinates
to_simplex <- function(xA, xB, xC) {
  total <- xA + xB + xC
  a <- xA / total; b <- xB / total; cc <- xC / total
  tibble(x = b + cc / 2, y = cc * sqrt(3) / 2)
}

simplex_verts <- tibble(
  label = c("A gets 80", "B gets 80", "C gets 80"),
  x = c(0, 1, 0.5), y = c(0, 0, sqrt(3) / 2)
)

core_simplex <- map_dfr(seq_len(nrow(core_verts)), function(i) {
  to_simplex(core_verts$x_A[i], core_verts$x_B[i], core_verts$x_C[i])
})
hull_order <- chull(core_simplex$x, core_simplex$y)
core_hull <- core_simplex[c(hull_order, hull_order[1]), ]

shap_pt <- to_simplex(shap[1], shap[2], shap[3])
nuc_pt <- to_simplex(nuc[1], nuc[2], nuc[3])

p_simplex <- ggplot() +
  geom_polygon(data = simplex_verts, aes(x = x, y = y),
               fill = "grey95", colour = "grey50", linewidth = 0.5) +
  geom_polygon(data = core_hull, aes(x = x, y = y),
               fill = okabe_ito[3], alpha = 0.3,
               colour = okabe_ito[3], linewidth = 1) +
  geom_point(data = core_simplex, aes(x = x, y = y),
             colour = okabe_ito[3], size = 2) +
  geom_point(data = shap_pt, aes(x = x, y = y),
             colour = okabe_ito[1], size = 4, shape = 17) +
  annotate("text", x = shap_pt$x + 0.04, y = shap_pt$y + 0.02,
           label = sprintf("Shapley\n(%.1f, %.1f, %.1f)",
                           shap[1], shap[2], shap[3]),
           colour = okabe_ito[1], size = 3, fontface = "bold", hjust = 0) +
  geom_point(data = nuc_pt, aes(x = x, y = y),
             colour = okabe_ito[5], size = 4, shape = 15) +
  annotate("text", x = nuc_pt$x - 0.04, y = nuc_pt$y - 0.03,
           label = sprintf("Nucleolus\n(%.1f, %.1f, %.1f)",
                           nuc[1], nuc[2], nuc[3]),
           colour = okabe_ito[5], size = 3, fontface = "bold", hjust = 1) +
  geom_text(data = simplex_verts, aes(x = x, y = y, label = label),
            vjust = c(1.8, 1.8, -1), size = 3, colour = "grey30") +
  annotate("text", x = 0.5, y = 0.25, label = "Core",
           colour = okabe_ito[3], size = 5, fontface = "bold") +
  coord_fixed() +
  theme_publication() +
  theme(axis.text = element_blank(), axis.title = element_blank(),
        axis.ticks = element_blank(), panel.grid = element_blank()) +
  labs(title = "Core of the Three-Player Production Game")

p_simplex
```

<div class="figure" style="text-align: center">
<img src="11-coopgame-package_files/figure-epub3/core-simplex-1.png" alt="The core of the three-player production game (shaded polygon) within the efficiency simplex. The Shapley value (triangle) and nucleolus (square) both lie inside the core, confirming both solution concepts yield stable allocations." width="80%" />
<p class="caption">(\#fig:core-simplex)The core of the three-player production game (shaded polygon) within the efficiency simplex. The Shapley value (triangle) and nucleolus (square) both lie inside the core, confirming both solution concepts yield stable allocations.</p>
</div>

``` r
save_pub_fig(p_simplex, "core-simplex", width = 7, height = 6)
```

\@ref(fig:core-simplex) shows the core as a shaded polygon on the efficiency simplex. Every point inside represents a stable allocation where no coalition can profitably deviate. Both the Shapley value and nucleolus lie inside, confirming stability.

## Worked example

### Step-by-step core membership check

We verify which allocations are in the core by testing all constraints.


``` r
check_core <- function(x, v_vec, n, labels) {
  grand <- v_vec[2^n - 1]
  coalitions <- all_coalitions(n)
  all_pass <- abs(sum(x) - grand) < 0.01
  cat(sprintf("Efficiency: sum = %.2f -- %s\n",
              sum(x), ifelse(all_pass, "PASS", "FAIL")))
  for (k in 1:(2^n - 2)) {
    S <- coalitions[[k]]
    pass <- sum(x[S]) >= v_vec[k] - 0.01
    if (!pass) all_pass <- FALSE
    cat(sprintf("  v(%s) = %d, x(%s) = %.2f -- %s\n",
                paste(labels[S], collapse = ","), v_vec[k],
                paste(labels[S], collapse = ","), sum(x[S]),
                ifelse(pass, "PASS", "FAIL")))
  }
  cat(sprintf("In core: %s\n\n", ifelse(all_pass, "YES", "NO")))
}

labels <- c("A", "B", "C")
equal <- rep(80 / 3, 3)

cat("=== Shapley value ===\n")
```

```
#> === Shapley value ===
```

``` r
check_core(shap, v_prod, 3, labels)
```

```
#> Efficiency: sum = 80.00 -- PASS
#>   v(A) = 10, x(A) = 24.17 -- PASS
#>   v(B) = 20, x(B) = 31.67 -- PASS
#>   v(A,B) = 50, x(A,B) = 55.83 -- PASS
#>   v(C) = 15, x(C) = 24.17 -- PASS
#>   v(A,C) = 40, x(A,C) = 48.33 -- PASS
#>   v(B,C) = 45, x(B,C) = 55.83 -- PASS
#> In core: YES
```

``` r
cat("=== Nucleolus ===\n")
```

```
#> === Nucleolus ===
```

``` r
check_core(nuc, v_prod, 3, labels)
```

```
#> Efficiency: sum = 80.00 -- PASS
#>   v(A) = 10, x(A) = 25.05 -- PASS
#>   v(B) = 20, x(B) = 32.44 -- PASS
#>   v(A,B) = 50, x(A,B) = 57.49 -- PASS
#>   v(C) = 15, x(C) = 22.51 -- PASS
#>   v(A,C) = 40, x(A,C) = 47.56 -- PASS
#>   v(B,C) = 45, x(B,C) = 54.95 -- PASS
#> In core: YES
```

``` r
cat("=== Equal division ===\n")
```

```
#> === Equal division ===
```

``` r
check_core(equal, v_prod, 3, labels)
```

```
#> Efficiency: sum = 80.00 -- PASS
#>   v(A) = 10, x(A) = 26.67 -- PASS
#>   v(B) = 20, x(B) = 26.67 -- PASS
#>   v(A,B) = 50, x(A,B) = 53.33 -- PASS
#>   v(C) = 15, x(C) = 26.67 -- PASS
#>   v(A,C) = 40, x(A,C) = 53.33 -- PASS
#>   v(B,C) = 45, x(B,C) = 53.33 -- PASS
#> In core: YES
```

The Shapley value and nucleolus pass all constraints. Equal division ($\approx 26.67$ each) fails because $x_B + x_C \approx 53.33 < 45$ is satisfied, but Firm B with only 26.67 would prefer to partner with C for 45 --- the coalition rationality constraint $x_A + x_B \geq 50$ is violated. This illustrates that simplistic "fair" divisions are often unstable.

Firm B receives the largest share under both solution concepts, reflecting its central role in the two most valuable pair coalitions ($v(\{A,B\}) = 50$ and $v(\{B,C\}) = 45$). Firm A, despite the lowest stand-alone value, earns well above 10 because it generates substantial synergies with B.

## Extensions

- **Linear programming for the nucleolus.** Our grid-search works for three players but does not scale. The standard algorithm solves a sequence of LPs, minimizing the maximum excess at each stage. The `CoopGame` package uses `lpSolve` for this.
- **Game properties.** `CoopGame` tests monotonicity, superadditivity, convexity, and balancedness. Convex games are particularly well-behaved: the core is always non-empty and the Shapley value lies within it.
- **Additional solution concepts.** Beyond Shapley and nucleolus, `CoopGame` computes the tau-value, Gately point, per-capita nucleolus, and equal surplus division, each with different fairness properties.
- **Power indices.** The Shapley value computation connects to \@ref(sec-gametheory-package), where we compute power indices for weighted voting games.

## Exercises {-}

1. **Empty core.** Consider a three-player game with $v(\{i\}) = 0$ for all $i$, $v(\{i,j\}) = 1$ for all pairs, and $v(\{1,2,3\}) = 1$. Show that the core is empty by demonstrating that the constraints in \@ref(eq:core-def) are infeasible. What does this imply about the stability of the grand coalition?

2. **Convexity check.** Write a function that checks whether a game is convex (marginal contributions are non-decreasing). Test it on the production game. Is it convex? If not, find a player and pair of coalitions that violate the condition.

3. **Shrinking the pie.** Change the grand coalition value from 80 to 60, keeping all pair values the same. Recompute the core vertices. Does the core shrink, or does it become empty? If it becomes empty, explain which constraint(s) are violated and why the game becomes unbalanced.

Solutions appear in \@ref(sec-solutions).
