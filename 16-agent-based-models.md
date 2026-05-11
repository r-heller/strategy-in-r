# Agent-Based Models for Strategic Interaction {#sec-agent-based-models}

> Building agent-based models where heterogeneous agents play games, reproduce proportional to fitness, and evolve strategies over generations — illustrated with the Hawk-Dove game.


## Learning objectives {-}

- Contrast the agent-based modeling paradigm with analytical equilibrium analysis.
- Implement a population of agents with heterogeneous strategies that interact through pairwise games.
- Model evolutionary pressure via fitness-proportional reproduction and mutation.
- Simulate the Hawk-Dove game and interpret the emergent strategy frequencies in terms of the evolutionarily stable strategy.

## Motivation

Analytical game theory derives equilibria by assuming fully rational players with common knowledge. This is powerful but sometimes unrealistic. In biology, economics, and social science, we often observe populations of agents with limited information, heterogeneous strategies, and adaptive behavior. How do strategy frequencies evolve when agents interact locally, reproduce based on success, and occasionally mutate?

Agent-based models (ABMs) answer this question computationally. Instead of solving for equilibrium, we simulate it. Each agent carries a strategy, plays games against others, earns payoffs, and the population evolves over generations. ABMs can reveal dynamics that analytical models miss: path dependence, transient oscillations, the role of population size, and the effect of mutation rates. Maynard Smith's Hawk-Dove game — a cornerstone of evolutionary game theory — provides the ideal testbed because it has a known analytical equilibrium we can compare against [@osborne2004].

## Theory

### The Hawk-Dove game

Two animals contest a resource of value $v$. Each can play **Hawk** (escalate) or **Dove** (yield). The payoff matrix is:

| | Hawk | Dove |
|---|---|---|
| **Hawk** | $(v - c)/2$ | $v$ |
| **Dove** | $0$ | $v/2$ |

: Hawk-Dove payoff matrix, where $v$ is the resource value and $c$ is the cost of fighting. {#tbl-hawk-dove}

When $c > v$ (fighting is costly relative to the resource), the game has no pure-strategy Nash equilibrium. The mixed-strategy Nash equilibrium has each player playing Hawk with probability:

\begin{equation}
p^* = \frac{v}{c}
(\#eq:hawk-dove-ne)
\end{equation}

This is also the evolutionarily stable strategy (ESS): a population at frequency $p^*$ cannot be invaded by either pure strategy [@osborne2004].

### Agent-based evolutionary dynamics

In the ABM framework, we model a finite population of $N$ agents. Each generation proceeds in three steps:

1. **Interaction.** Each agent plays the Hawk-Dove game against $k$ randomly chosen opponents. Its fitness is the average payoff across these interactions.

2. **Reproduction.** The next generation is formed by sampling $N$ agents from the current population with replacement, where the probability of being selected is proportional to fitness (shifted to be non-negative):

\begin{equation}
\Pr(\text{agent } i \text{ selected}) = \frac{f_i - f_{\min} + \epsilon}{\sum_{j=1}^{N} (f_j - f_{\min} + \epsilon)}
(\#eq:fitness-selection)
\end{equation}

where $f_i$ is agent $i$'s fitness, $f_{\min}$ is the minimum fitness in the population, and $\epsilon > 0$ is a small constant ensuring all agents have positive selection probability.

3. **Mutation.** Each offspring independently switches strategy with probability $\mu$ (the mutation rate).

::: {.rmdnote}
**Definition**

An **agent-based model** (ABM) is a computational model in which autonomous agents with individual attributes interact according to specified rules. Macro-level patterns emerge from these micro-level interactions without being explicitly programmed.
:::

### Connection to replicator dynamics

In the limit of large populations, weak selection, and low mutation, the ABM dynamics converge to the **replicator equation** (\@ref(sec-replicator-dynamics)):

\begin{equation}
\dot{x}_H = x_H \left[ \pi_H(\mathbf{x}) - \bar{\pi}(\mathbf{x}) \right]
(\#eq:replicator)
\end{equation}

where $x_H$ is the frequency of Hawks, $\pi_H$ is the expected payoff to a Hawk, and $\bar{\pi}$ is the population average payoff. The ABM allows us to see how finite population effects, stochastic drift, and mutation perturb these deterministic predictions.

## Implementation in R {#sec-abm-implementation}

### Core simulation functions


``` r
# Hawk-Dove payoff function
hawk_dove_payoff <- function(strategy1, strategy2, v = 2, c = 5) {
  if (strategy1 == "Hawk" && strategy2 == "Hawk") {
    return((v - c) / 2)
  } else if (strategy1 == "Hawk" && strategy2 == "Dove") {
    return(v)
  } else if (strategy1 == "Dove" && strategy2 == "Hawk") {
    return(0)
  } else {
    return(v / 2)
  }
}

# Compute fitness for all agents via random pairwise interactions
compute_fitness <- function(population, n_interactions, v, c) {
  n <- length(population)
  fitness <- numeric(n)
  for (i in seq_len(n)) {
    opponents <- sample(seq_len(n)[-i], min(n_interactions, n - 1))
    payoffs <- vapply(opponents, function(j) {
      hawk_dove_payoff(population[i], population[j], v, c)
    }, numeric(1))
    fitness[i] <- mean(payoffs)
  }
  fitness
}

# Fitness-proportional selection with shift
select_parents <- function(population, fitness, n) {
  shifted <- fitness - min(fitness) + 0.01
  probs <- shifted / sum(shifted)
  idx <- sample(seq_along(population), n, replace = TRUE, prob = probs)
  population[idx]
}

# Mutation
mutate_population <- function(population, mu) {
  strategies <- c("Hawk", "Dove")
  mutate_mask <- runif(length(population)) < mu
  population[mutate_mask] <- vapply(population[mutate_mask], function(s) {
    sample(setdiff(strategies, s), 1)
  }, character(1))
  population
}
```

### Running the ABM


``` r
run_hawk_dove_abm <- function(n_agents = 200, n_generations = 300,
                               initial_hawk_freq = 0.5,
                               n_interactions = 10,
                               mutation_rate = 0.01,
                               v = 2, c = 5, seed = 42) {
  set.seed(seed)

  # Initialize population
  n_hawks <- round(n_agents * initial_hawk_freq)
  population <- c(rep("Hawk", n_hawks), rep("Dove", n_agents - n_hawks))

  # Storage for tracking
  history <- tibble(
    generation = integer(),
    hawk_freq = double(),
    mean_fitness = double()
  )

  for (gen in seq_len(n_generations)) {
    hawk_freq <- mean(population == "Hawk")
    fitness <- compute_fitness(population, n_interactions, v, c)

    history <- bind_rows(history, tibble(
      generation = gen,
      hawk_freq = hawk_freq,
      mean_fitness = mean(fitness)
    ))

    # Selection and reproduction
    population <- select_parents(population, fitness, n_agents)

    # Mutation
    population <- mutate_population(population, mutation_rate)
  }

  history
}
```

### Strategy frequency evolution


``` r
v <- 2
c_val <- 5
ess_freq <- v / c_val

# Run three independent simulations with different initial conditions
runs <- list(
  list(init = 0.1, seed = 42, label = "Run 1 (10% Hawk)"),
  list(init = 0.5, seed = 123, label = "Run 2 (50% Hawk)"),
  list(init = 0.9, seed = 456, label = "Run 3 (90% Hawk)")
)

history_all <- map_dfr(runs, function(r) {
  run_hawk_dove_abm(
    n_agents = 200, n_generations = 300,
    initial_hawk_freq = r$init, n_interactions = 10,
    mutation_rate = 0.01, v = v, c = c_val, seed = r$seed
  ) |>
    mutate(run = r$label)
})

p_evolution <- ggplot(history_all, aes(x = generation, y = hawk_freq,
                                        colour = run)) +
  geom_line(linewidth = 0.6, alpha = 0.85) +
  geom_hline(yintercept = ess_freq, linetype = "dashed",
             colour = okabe_ito[8], linewidth = 0.6) +
  scale_colour_manual(values = okabe_ito[c(1, 2, 3)], name = "Simulation") +
  theme_publication() +
  labs(title = "Hawk-Dove ABM: Strategy Frequency Over Generations",
       x = "Generation",
       y = "Fraction playing Hawk",
       caption = glue("Dashed line = ESS frequency (v/c = {ess_freq})"))

p_evolution
```

<div class="figure" style="text-align: center">
<img src="16-agent-based-models_files/figure-epub3/abm-strategy-evolution-1.png" alt="Strategy frequency evolution in the Hawk-Dove agent-based model across three independent runs. The dashed horizontal line marks the analytical ESS frequency $p^* = v/c = 0.4$. Despite starting from different initial conditions, all runs converge to fluctuate around the predicted equilibrium." width="80%" />
<p class="caption">(\#fig:abm-strategy-evolution)Strategy frequency evolution in the Hawk-Dove agent-based model across three independent runs. The dashed horizontal line marks the analytical ESS frequency $p^* = v/c = 0.4$. Despite starting from different initial conditions, all runs converge to fluctuate around the predicted equilibrium.</p>
</div>

``` r
save_pub_fig(p_evolution, "abm-strategy-evolution", width = 7, height = 5)
```

### Population fitness over time


``` r
# Compute the analytical equilibrium fitness
# At ESS: pi_bar = p*[p*(v-c)/2 + (1-p*)v] + (1-p*)[p*0 + (1-p*)v/2]
p_star <- ess_freq
pi_bar_star <- p_star * (p_star * (v - c_val)/2 + (1 - p_star) * v) +
               (1 - p_star) * (p_star * 0 + (1 - p_star) * v/2)

p_fitness <- ggplot(history_all, aes(x = generation, y = mean_fitness,
                                      colour = run)) +
  geom_line(linewidth = 0.6, alpha = 0.85) +
  geom_hline(yintercept = pi_bar_star, linetype = "dashed",
             colour = okabe_ito[8], linewidth = 0.6) +
  scale_colour_manual(values = okabe_ito[c(1, 2, 3)], name = "Simulation") +
  theme_publication() +
  labs(title = "Hawk-Dove ABM: Average Population Fitness",
       x = "Generation",
       y = "Mean payoff per interaction",
       caption = glue("Dashed line = fitness at ESS ({round(pi_bar_star, 2)})"))

p_fitness
```

<div class="figure" style="text-align: center">
<img src="16-agent-based-models_files/figure-epub3/abm-fitness-1.png" alt="Average population fitness over generations in the Hawk-Dove ABM. Fitness is highest when the population is near the ESS. Early generations show rapid fitness changes as the population adjusts from its initial state; later generations fluctuate around the equilibrium fitness level." width="80%" />
<p class="caption">(\#fig:abm-fitness)Average population fitness over generations in the Hawk-Dove ABM. Fitness is highest when the population is near the ESS. Early generations show rapid fitness changes as the population adjusts from its initial state; later generations fluctuate around the equilibrium fitness level.</p>
</div>

``` r
save_pub_fig(p_fitness, "abm-fitness", width = 7, height = 5)
```

## Worked example

Let us trace through the first few generations of a small population to understand the mechanics.


``` r
set.seed(42)
n_agents <- 20
population <- c(rep("Hawk", 14), rep("Dove", 6))  # 70% Hawk

cat("Initial population (20 agents, 70% Hawk):\n")
```

```
#> Initial population (20 agents, 70% Hawk):
```

``` r
cat(glue("  Hawks: {sum(population == 'Hawk')}, ",
         "Doves: {sum(population == 'Dove')}"), "\n\n")
```

```
#>   Hawks: 14, Doves: 6
```

``` r
# Generation 1: compute fitness
fitness <- compute_fitness(population, n_interactions = 5, v = v, c = c_val)

fitness_by_type <- tibble(
  strategy = population,
  fitness = fitness
) |>
  group_by(strategy) |>
  summarise(mean_fitness = round(mean(fitness), 3),
            min_fitness = round(min(fitness), 3),
            max_fitness = round(max(fitness), 3),
            .groups = "drop")

cat("Generation 1 fitness summary:\n")
```

```
#> Generation 1 fitness summary:
```

``` r
print(fitness_by_type)
```

```
#> # A tibble: 2 × 4
#>   strategy mean_fitness min_fitness max_fitness
#>   <chr>           <dbl>       <dbl>       <dbl>
#> 1 Dove            0.267         0           0.6
#> 2 Hawk           -0.4          -1.5         1.3
```


``` r
# Selection: Hawks have lower average fitness when over-represented
cat("\nWith 70% Hawks (above ESS of 40%), Hawks fight each other often.\n")
```

```
#> 
#> With 70% Hawks (above ESS of 40%), Hawks fight each other often.
```

``` r
cat("Doves benefit from facing other Doves more than Hawks benefit from\n")
```

```
#> Doves benefit from facing other Doves more than Hawks benefit from
```

``` r
cat("fighting other Hawks (since (v-c)/2 < 0 when c > v).\n\n")
```

```
#> fighting other Hawks (since (v-c)/2 < 0 when c > v).
```

``` r
# Next generation
population_new <- select_parents(population, fitness, n_agents)
population_new <- mutate_population(population_new, mu = 0.01)

cat("After selection and mutation:\n")
```

```
#> After selection and mutation:
```

``` r
cat(glue("  Hawks: {sum(population_new == 'Hawk')}, ",
         "Doves: {sum(population_new == 'Dove')}"), "\n")
```

```
#>   Hawks: 14, Doves: 6
```

``` r
cat(glue("  Hawk frequency: {mean(population_new == 'Hawk')}"), "\n")
```

```
#>   Hawk frequency: 0.7
```

The population moves toward the ESS. Because Hawks are overrepresented (70% vs. the ESS of 40%), they frequently fight each other and incur the costly loss of $(v-c)/2 = -1.5$. Doves, meanwhile, avoid fighting costs entirely. Selection therefore favors Doves, pulling the population toward the equilibrium frequency.

### Sensitivity to parameters


``` r
# Effect of mutation rate on variance of equilibrium frequency
mutation_rates <- c(0.001, 0.01, 0.05, 0.1)

sensitivity_df <- map_dfr(mutation_rates, function(mu) {
  h <- run_hawk_dove_abm(n_agents = 200, n_generations = 300,
                          initial_hawk_freq = 0.5, n_interactions = 10,
                          mutation_rate = mu, v = v, c = c_val, seed = 42)
  # Use last 100 generations as "steady state"
  steady <- tail(h, 100)
  tibble(
    mutation_rate = mu,
    mean_hawk_freq = round(mean(steady$hawk_freq), 3),
    sd_hawk_freq = round(sd(steady$hawk_freq), 3)
  )
})

sensitivity_df |>
  gt() |>
  cols_label(mutation_rate = "Mutation rate",
             mean_hawk_freq = "Mean Hawk freq",
             sd_hawk_freq = "SD of Hawk freq") |>
  tab_header(title = "Effect of Mutation Rate on Equilibrium Behavior",
             subtitle = "Steady-state statistics from last 100 of 300 generations")
```

```{=html}
<div id="lxrzuzrubd" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#lxrzuzrubd table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#lxrzuzrubd thead, #lxrzuzrubd tbody, #lxrzuzrubd tfoot, #lxrzuzrubd tr, #lxrzuzrubd td, #lxrzuzrubd th {
  border-style: none;
}

#lxrzuzrubd p {
  margin: 0;
  padding: 0;
}

#lxrzuzrubd .gt_table {
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

#lxrzuzrubd .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#lxrzuzrubd .gt_title {
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

#lxrzuzrubd .gt_subtitle {
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

#lxrzuzrubd .gt_heading {
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

#lxrzuzrubd .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxrzuzrubd .gt_col_headings {
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

#lxrzuzrubd .gt_col_heading {
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

#lxrzuzrubd .gt_column_spanner_outer {
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

#lxrzuzrubd .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#lxrzuzrubd .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#lxrzuzrubd .gt_column_spanner {
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

#lxrzuzrubd .gt_spanner_row {
  border-bottom-style: hidden;
}

#lxrzuzrubd .gt_group_heading {
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

#lxrzuzrubd .gt_empty_group_heading {
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

#lxrzuzrubd .gt_from_md > :first-child {
  margin-top: 0;
}

#lxrzuzrubd .gt_from_md > :last-child {
  margin-bottom: 0;
}

#lxrzuzrubd .gt_row {
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

#lxrzuzrubd .gt_stub {
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

#lxrzuzrubd .gt_stub_row_group {
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

#lxrzuzrubd .gt_row_group_first td {
  border-top-width: 2px;
}

#lxrzuzrubd .gt_row_group_first th {
  border-top-width: 2px;
}

#lxrzuzrubd .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxrzuzrubd .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#lxrzuzrubd .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#lxrzuzrubd .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxrzuzrubd .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxrzuzrubd .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#lxrzuzrubd .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#lxrzuzrubd .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#lxrzuzrubd .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#lxrzuzrubd .gt_footnotes {
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

#lxrzuzrubd .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxrzuzrubd .gt_sourcenotes {
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

#lxrzuzrubd .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#lxrzuzrubd .gt_left {
  text-align: left;
}

#lxrzuzrubd .gt_center {
  text-align: center;
}

#lxrzuzrubd .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#lxrzuzrubd .gt_font_normal {
  font-weight: normal;
}

#lxrzuzrubd .gt_font_bold {
  font-weight: bold;
}

#lxrzuzrubd .gt_font_italic {
  font-style: italic;
}

#lxrzuzrubd .gt_super {
  font-size: 65%;
}

#lxrzuzrubd .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#lxrzuzrubd .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#lxrzuzrubd .gt_indent_1 {
  text-indent: 5px;
}

#lxrzuzrubd .gt_indent_2 {
  text-indent: 10px;
}

#lxrzuzrubd .gt_indent_3 {
  text-indent: 15px;
}

#lxrzuzrubd .gt_indent_4 {
  text-indent: 20px;
}

#lxrzuzrubd .gt_indent_5 {
  text-indent: 25px;
}

#lxrzuzrubd .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#lxrzuzrubd div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_title gt_font_normal" style>Effect of Mutation Rate on Equilibrium Behavior</td>
    </tr>
    <tr class="gt_heading">
      <td colspan="3" class="gt_heading gt_subtitle gt_font_normal gt_bottom_border" style>Steady-state statistics from last 100 of 300 generations</td>
    </tr>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="mutation_rate">Mutation rate</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="mean_hawk_freq">Mean Hawk freq</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="sd_hawk_freq">SD of Hawk freq</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="mutation_rate" class="gt_row gt_right">0.001</td>
<td headers="mean_hawk_freq" class="gt_row gt_right">0.417</td>
<td headers="sd_hawk_freq" class="gt_row gt_right">0.045</td></tr>
    <tr><td headers="mutation_rate" class="gt_row gt_right">0.010</td>
<td headers="mean_hawk_freq" class="gt_row gt_right">0.407</td>
<td headers="sd_hawk_freq" class="gt_row gt_right">0.052</td></tr>
    <tr><td headers="mutation_rate" class="gt_row gt_right">0.050</td>
<td headers="mean_hawk_freq" class="gt_row gt_right">0.419</td>
<td headers="sd_hawk_freq" class="gt_row gt_right">0.040</td></tr>
    <tr><td headers="mutation_rate" class="gt_row gt_right">0.100</td>
<td headers="mean_hawk_freq" class="gt_row gt_right">0.444</td>
<td headers="sd_hawk_freq" class="gt_row gt_right">0.041</td></tr>
  </tbody>
  
</table>
</div>
```

Higher mutation rates increase the variance around the ESS — agents are more frequently pushed away from the equilibrium — but the mean frequency remains close to $p^* = 0.4$ across all mutation rates. This robustness is a signature of the ESS: selection pressure always pushes back toward equilibrium, regardless of perturbations [@von-neumann1944].

## Extensions

- **Spatial structure.** When agents interact only with neighbors on a grid, spatial clusters can form and persist. Cooperation can be sustained in spatial Prisoner's Dilemma even without reciprocity (\@ref(sec-spatial-pd)).
- **Multiple strategies.** The ABM framework extends naturally to games with more than two pure strategies. With three or more strategies, the dynamics can exhibit limit cycles (as in Rock-Paper-Scissors) rather than convergence to a fixed point.
- **Evolutionary stability.** The analytical counterpart to ABM convergence is the concept of an evolutionarily stable strategy. See \@ref(sec-ess) for formal definitions and the relationship to Nash equilibrium.
- **Replicator dynamics.** The continuous-time limit of the ABM's selection step yields the replicator equation (\@ref(sec-replicator-dynamics)). Comparing the ABM to the replicator ODE reveals where finite-population effects matter.
- **Network structure.** When the interaction graph is not well-mixed but has network structure, cooperation dynamics change qualitatively (\@ref(sec-network-games)). For the foundational analysis, see @shoham2009.

## Exercises {-}

1. **Three strategies.** Add a third strategy, **Retaliator**, that plays Dove against Doves and Hawk against Hawks (it matches the opponent's type). This requires each agent to observe its opponent's strategy before acting. Run the ABM and report whether Retaliator can invade a Hawk-Dove population at the ESS.

2. **Population size effects.** Run the Hawk-Dove ABM with population sizes of 20, 100, 500, and 2000 agents for 300 generations each. Plot the standard deviation of the Hawk frequency (over the last 100 generations) against population size. What relationship do you observe, and why?

3. **Stag Hunt dynamics.** Replace the Hawk-Dove payoff matrix with the Stag Hunt: mutual cooperation (Stag, Stag) yields 4 each, mutual defection (Hare, Hare) yields 2 each, and miscoordination yields 0 for the Stag player and 2 for the Hare player. Run the ABM from initial cooperation frequencies of 0.3, 0.5, and 0.8. Does the population always converge to the same equilibrium? Explain in terms of the game's two Nash equilibria.

Solutions appear in \@ref(sec-solutions).
