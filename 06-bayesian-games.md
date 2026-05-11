# Bayesian Games {#sec-bayesian-games}

> Games of incomplete information where players hold private types and form beliefs about opponents. Covers Bayesian Nash equilibrium, signaling games, and separating versus pooling equilibria with a worked job-market signaling example.


## Learning objectives {-}

- Explain how types and prior beliefs extend the normal-form model to incomplete information settings.
- Define Bayesian Nash equilibrium and compute it for small games with discrete types.
- Distinguish signaling games from other Bayesian games and identify separating, pooling, and semi-separating equilibria.
- Implement expected-payoff calculations under type uncertainty in R and produce publication-quality figures.

## Motivation

In every game we have studied so far --- from normal-form games (\@ref(sec-normal-form)) to extensive-form games (\@ref(sec-extensive-form)) --- players share complete knowledge of the payoff structure. In practice, this assumption is heroic. A firm entering a new market does not know its rival's cost structure. A job applicant knows her own ability, but the employer does not. A bidder in an auction knows his own valuation but must guess at others' valuations.

John Harsanyi's insight was that incomplete information can be modeled by introducing *types*: each player privately observes a type drawn from a commonly known distribution, and this type determines the player's payoffs. The resulting game is a **Bayesian game**, and the appropriate equilibrium concept is **Bayesian Nash equilibrium** (BNE). As @osborne2004 [Chapter 9] develops in detail, BNE asks each player to choose a strategy --- a complete plan mapping types to actions --- that is optimal in expectation over the other players' types.

Signaling games, a particularly important class of Bayesian games, arise when an informed player moves first and an uninformed player observes the action before responding. Spence's job-market signaling model is the classic example: a worker's education choice may reveal (or conceal) her productivity type to employers.

## Theory

### The Bayesian game model

A Bayesian game extends the standard normal form with three additional ingredients:

1. **Type spaces.** Each player $i$ has a type $\theta_i \in \Theta_i$. A type encodes any private information that affects payoffs.
2. **Prior beliefs.** A common prior probability distribution $p(\theta_1, \ldots, \theta_n)$ governs the joint distribution of types. Players update beliefs using Bayes' rule after observing their own type.
3. **Type-contingent payoffs.** Player $i$'s payoff function $u_i(a_1, \ldots, a_n; \theta_i)$ may depend on $i$'s own type (and possibly on others' types).

A **strategy** in a Bayesian game is a function $s_i : \Theta_i \to A_i$ mapping each possible type to an action.

### Bayesian Nash equilibrium

::: {.rmdnote}
**Definition: Bayesian Nash Equilibrium**

A strategy profile $s^* = (s_1^*, \ldots, s_n^*)$ is a **Bayesian Nash equilibrium** if, for every player $i$ and every type $\theta_i \in \Theta_i$:

\begin{equation}
\mathbb{E}_{\theta_{-i}}\bigl[u_i(s_i^*(\theta_i),\, s_{-i}^*(\theta_{-i});\, \theta_i) \mid \theta_i\bigr] \geq \mathbb{E}_{\theta_{-i}}\bigl[u_i(a_i,\, s_{-i}^*(\theta_{-i});\, \theta_i) \mid \theta_i\bigr]
(\#eq:bne-def)
\end{equation}

for all $a_i \in A_i$.
:::

In words, each type of each player maximizes expected payoff given the prior distribution over others' types and others' equilibrium strategies. BNE is the natural extension of Nash equilibrium (\@ref(sec-nash-equilibrium)) to incomplete information.

### Signaling games

A **signaling game** is a two-player Bayesian game with sequential moves:

1. Nature draws the **sender's** type $\theta \in \Theta$ according to a prior $p(\theta)$.
2. The sender observes $\theta$ and chooses a **signal** (message) $m \in M$.
3. The **receiver** observes $m$ (but not $\theta$) and chooses an action $a \in A$.
4. Payoffs $u_S(m, a; \theta)$ and $u_R(m, a; \theta)$ are realized.

The equilibrium concept for signaling games is **perfect Bayesian equilibrium** (PBE), which requires that the receiver's beliefs about $\theta$ are derived from Bayes' rule whenever possible.

### Separating vs. pooling equilibria

- **Separating equilibrium:** Different types choose different signals, so the receiver can perfectly infer the sender's type from the observed message.
- **Pooling equilibrium:** All types choose the same signal, so the receiver learns nothing beyond the prior.
- **Semi-separating (partial pooling) equilibrium:** Some types pool while others separate, or types randomize between signals.

The existence and nature of these equilibria depend on the cost structure of signaling and the payoff differences across types.

## Implementation in R

We implement a two-type signaling game inspired by the Spence job-market model. A worker is either High-ability ($\theta_H$) or Low-ability ($\theta_L$), each with equal prior probability. The worker chooses whether to acquire education ($E$) or not ($N$). Education costs differ by type: it costs the High type $c_H = 1$ and the Low type $c_L = 4$. An employer then offers a wage equal to the expected productivity conditional on the observed education decision.


``` r
# Type parameters
types <- c("High", "Low")
prior <- c(High = 0.5, Low = 0.5)
productivity <- c(High = 6, Low = 2)
edu_cost <- c(High = 1, Low = 4)

# Wages under different employer beliefs
wage_if_high <- productivity["High"]
wage_if_low  <- productivity["Low"]
wage_pooled  <- sum(prior * productivity)

cat(sprintf("Productivity: High = %d, Low = %d\n",
            productivity["High"], productivity["Low"]))
```

```
#> Productivity: High = 6, Low = 2
```

``` r
cat(sprintf("Education cost: High = %d, Low = %d\n",
            edu_cost["High"], edu_cost["Low"]))
```

```
#> Education cost: High = 1, Low = 4
```

``` r
cat(sprintf("Pooling wage (prior expectation): %.1f\n", wage_pooled))
```

```
#> Pooling wage (prior expectation): 4.0
```

### Expected payoffs under each equilibrium type


``` r
# Separating equilibrium: High educates, Low does not
# Employer infers type perfectly from education choice
sep_payoffs <- tibble(
  type = rep(types, each = 2),
  action = rep(c("Educate", "No Education"), times = 2),
  payoff = c(
    wage_if_high - edu_cost["High"],  # High, Educate (separating)
    wage_if_low,                       # High, No Education (deviate)
    wage_if_high - edu_cost["Low"],    # Low, Educate (deviate)
    wage_if_low                        # Low, No Education (separating)
  ),
  equilibrium = c("Separating", "Deviation", "Deviation", "Separating")
)

# Pooling equilibrium: both types educate
# Employer pays pooling wage to educated, low wage to uneducated
pool_payoffs <- tibble(
  type = rep(types, each = 2),
  action = rep(c("Educate", "No Education"), times = 2),
  payoff = c(
    wage_pooled - edu_cost["High"],  # High, Educate (pooling)
    wage_if_low,                      # High, No Education (deviate)
    wage_pooled - edu_cost["Low"],   # Low, Educate (pooling)
    wage_if_low                       # Low, No Education (deviate)
  ),
  equilibrium = c("Pooling", "Deviation", "Pooling", "Deviation")
)

cat("Separating equilibrium payoffs:\n")
```

```
#> Separating equilibrium payoffs:
```

``` r
sep_payoffs |>
  select(type, action, payoff, equilibrium) |>
  print()
```

```
#> # A tibble: 4 × 4
#>   type  action       payoff equilibrium
#>   <chr> <chr>         <dbl> <chr>      
#> 1 High  Educate           5 Separating 
#> 2 High  No Education      2 Deviation  
#> 3 Low   Educate           2 Deviation  
#> 4 Low   No Education      2 Separating
```

``` r
cat("\nPooling equilibrium payoffs:\n")
```

```
#> 
#> Pooling equilibrium payoffs:
```

``` r
pool_payoffs |>
  select(type, action, payoff, equilibrium) |>
  print()
```

```
#> # A tibble: 4 × 4
#>   type  action       payoff equilibrium
#>   <chr> <chr>         <dbl> <chr>      
#> 1 High  Educate           3 Pooling    
#> 2 High  No Education      2 Deviation  
#> 3 Low   Educate           0 Pooling    
#> 4 Low   No Education      2 Deviation
```

### Checking incentive compatibility


``` r
# Separating equilibrium IC checks
high_sep <- wage_if_high - edu_cost["High"]  # 6 - 1 = 5
high_dev <- wage_if_low                       # 2
low_sep  <- wage_if_low                       # 2
low_dev  <- wage_if_high - edu_cost["Low"]    # 6 - 4 = 2

cat("Separating equilibrium IC checks:\n")
```

```
#> Separating equilibrium IC checks:
```

``` r
cat(sprintf("  High type: Educate (%.0f) vs No Education (%.0f) -> %s\n",
            high_sep, high_dev,
            ifelse(high_sep >= high_dev, "IC satisfied", "IC violated")))
```

```
#>   High type: Educate (5) vs No Education (2) -> IC satisfied
```

``` r
cat(sprintf("  Low type:  No Education (%.0f) vs Educate (%.0f) -> %s\n",
            low_sep, low_dev,
            ifelse(low_sep >= low_dev, "IC satisfied", "IC violated")))
```

```
#>   Low type:  No Education (2) vs Educate (2) -> IC satisfied
```

### Publication figure: expected payoffs by type and equilibrium


``` r
# Combine equilibrium payoffs for the chosen (non-deviation) actions
eq_summary <- tibble(
  type = rep(types, 2),
  equilibrium = rep(c("Separating", "Pooling"), each = 2),
  payoff = c(
    wage_if_high - edu_cost["High"],  # High, separating
    wage_if_low,                       # Low, separating
    wage_pooled - edu_cost["High"],   # High, pooling
    wage_pooled - edu_cost["Low"]     # Low, pooling
  ),
  action = c("Educate", "No Education", "Educate", "Educate")
)

p_bayesian <- ggplot(eq_summary,
                     aes(x = type, y = payoff, fill = equilibrium)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = payoff),
            position = position_dodge(width = 0.7),
            vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("Separating" = okabe_ito[1],
                               "Pooling" = okabe_ito[2]),
                    name = "Equilibrium type") +
  scale_y_continuous(name = "Expected payoff",
                     limits = c(-1, 6.5),
                     breaks = seq(-1, 6, 1)) +
  scale_x_discrete(name = "Worker type") +
  labs(title = "Payoff Comparison Across Equilibrium Types") +
  theme_publication()

p_bayesian
```

<div class="figure" style="text-align: center">
<img src="06-bayesian-games_files/figure-epub3/bayesian-payoffs-1.png" alt="Expected payoffs for each worker type under separating and pooling equilibria in the job-market signaling game. In the separating equilibrium the High type earns 5 (wage 6 minus education cost 1) while the Low type earns 2. In the pooling equilibrium the High type earns 3 (pooling wage 4 minus cost 1) and the Low type earns 0 (pooling wage 4 minus cost 4). Bars shaded by equilibrium type." width="80%" />
<p class="caption">(\#fig:bayesian-payoffs)Expected payoffs for each worker type under separating and pooling equilibria in the job-market signaling game. In the separating equilibrium the High type earns 5 (wage 6 minus education cost 1) while the Low type earns 2. In the pooling equilibrium the High type earns 3 (pooling wage 4 minus cost 1) and the Low type earns 0 (pooling wage 4 minus cost 4). Bars shaded by equilibrium type.</p>
</div>

``` r
save_pub_fig(p_bayesian, "bayesian-payoff-comparison")
```

## Worked example

We walk through the separating equilibrium step by step.

**Step 1: Set up the game.** Nature draws the worker's type: High ($\theta_H$, productivity 6) or Low ($\theta_L$, productivity 2), each with probability 0.5. Education costs 1 for the High type and 4 for the Low type.

**Step 2: Propose a separating strategy.** Suppose the High type educates and the Low type does not.

**Step 3: Derive employer beliefs.** Under this strategy, the employer observes $E$ and infers the worker is High with certainty, offering wage 6. Observing $N$, the employer infers the worker is Low with certainty, offering wage 2.

**Step 4: Check incentive compatibility.** The High type's payoff from educating is $6 - 1 = 5$, and from deviating to no education is $2$. Since $5 > 2$, the High type has no incentive to deviate. The Low type's payoff from not educating is $2$, and from deviating to education is $6 - 4 = 2$. Since $2 \geq 2$ (weak IC), the Low type has no strict incentive to deviate.

**Step 5: Verify the equilibrium.** Both types play optimally given employer beliefs, and beliefs are consistent with strategies via Bayes' rule. This constitutes a perfect Bayesian equilibrium.


``` r
# Payoff summary table
worked_example <- tibble(
  `Worker type` = c("High", "Low"),
  `Equilibrium action` = c("Educate", "No Education"),
  `Wage received` = c(6, 2),
  `Education cost` = c(1, 0),
  `Net payoff` = c(5, 2),
  `Deviation payoff` = c(2, 2),
  `IC satisfied?` = c("Yes (5 > 2)", "Yes (2 >= 2)")
)

worked_example |>
  gt() |>
  tab_header(
    title = "Separating Equilibrium in the Job-Market Signaling Game"
  ) |>
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
      <td colspan="7" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Separating Equilibrium in the Job-Market Signaling Game</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Worker-type">Worker type</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Equilibrium-action">Equilibrium action</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Wage-received">Wage received</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Education-cost">Education cost</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Net-payoff">Net payoff</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Deviation-payoff">Deviation payoff</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="IC-satisfied?">IC satisfied?</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Worker type" class="gt_row gt_center">High</td>
<td headers="Equilibrium action" class="gt_row gt_center">Educate</td>
<td headers="Wage received" class="gt_row gt_center">6</td>
<td headers="Education cost" class="gt_row gt_center">1</td>
<td headers="Net payoff" class="gt_row gt_center">5</td>
<td headers="Deviation payoff" class="gt_row gt_center">2</td>
<td headers="IC satisfied?" class="gt_row gt_center">Yes (5 &gt; 2)</td></tr>
    <tr><td headers="Worker type" class="gt_row gt_center">Low</td>
<td headers="Equilibrium action" class="gt_row gt_center">No Education</td>
<td headers="Wage received" class="gt_row gt_center">2</td>
<td headers="Education cost" class="gt_row gt_center">0</td>
<td headers="Net payoff" class="gt_row gt_center">2</td>
<td headers="Deviation payoff" class="gt_row gt_center">2</td>
<td headers="IC satisfied?" class="gt_row gt_center">Yes (2 &gt;= 2)</td></tr>
  </tbody>
  
</table>
</div>
```

Note that the separating equilibrium Pareto-dominates the pooling equilibrium for the High type (payoff 5 vs. 3) but is weakly better for the Low type as well (payoff 2 vs. 0). This is a distinctive feature of signaling models: the ability to separate benefits the high type at the cost of an investment (education) that is socially wasteful if it does not enhance actual productivity.

## Extensions

Bayesian games and signaling models underpin a vast literature in economics and political science:

- **Mechanism design** reverses the analysis: instead of solving a given game, the designer chooses the rules to achieve a desired outcome. Auctions (\@ref(sec-nash-equilibrium)) are a leading application.
- **Cheap talk** games are signaling games where the signal is costless. Equilibrium analysis then focuses on how much information can be credibly communicated.
- **Dynamic signaling** extends one-shot signaling to repeated interactions, connecting to the folk-theorem results of \@ref(sec-repeated-games).
- **Refinements** such as the Intuitive Criterion (Cho and Kreps, 1987) restrict off-path beliefs to eliminate implausible pooling equilibria.

For a thorough treatment of Bayesian games, see @osborne2004 [Chapter 9] and @shoham2009. The original formalization of types and Bayesian equilibrium traces to Harsanyi's foundational work, building on the strategic framework of @von-neumann1944.

## Exercises {-}

1. **Modified signaling costs.** Suppose the Low type's education cost falls to $c_L = 3$. Does the separating equilibrium from the worked example survive? If not, what is the minimum cost $c_L$ that sustains separation? Verify your answer in R.

2. **Pooling equilibrium check.** In the worked example, verify that a pooling equilibrium where *both* types choose No Education can be sustained. What off-path beliefs about a worker who deviates to Education would support this equilibrium?

3. **Three types.** Extend the signaling game to three types: High (productivity 8, cost 1), Medium (productivity 5, cost 3), and Low (productivity 2, cost 6), with equal priors. Find conditions under which a fully separating equilibrium exists.

4. **BNE in a Cournot game.** Two firms compete in quantities. Firm 1's marginal cost is commonly known to be $c_1 = 2$. Firm 2's marginal cost is $c_2 = 1$ (with probability 0.5) or $c_2 = 3$ (with probability 0.5), known only to Firm 2. Inverse demand is $P = 10 - Q$. Compute the Bayesian Nash equilibrium quantities. *(Hint: Firm 2 has two types, each choosing a quantity; Firm 1 chooses a single quantity that is optimal in expectation.)*

5. **Visualization.** Create a figure showing how the High type's payoff advantage in the separating equilibrium changes as the cost ratio $c_L / c_H$ varies from 1 to 8. At what ratio does the separating equilibrium first become sustainable?

Solutions appear in \@ref(sec-solutions).
