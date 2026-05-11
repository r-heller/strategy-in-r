# Exercise Solutions {#sec-solutions}

> Solutions to end-of-chapter exercises.


This appendix provides brief solution sketches for selected exercises from Part I (Chapters 1--8). The goal is to offer enough guidance to check your reasoning without removing the learning opportunity. Full, runnable solutions are available in the book's online repository.

## Chapter 1: What is a Game? {-}

**Exercise 1 --- Identify the game.** *Choose a strategic interaction from everyday life and identify the four building blocks.*

::: {.callout-tip collapse="true" title="Solution"}
Many valid answers exist. One example: two roommates deciding whether to clean a shared kitchen.

- **Players**: Roommate A and Roommate B.
- **Actions**: Clean or Don't Clean (for each player).
- **Payoffs**: A clean kitchen benefits both, but cleaning is costly. If only one cleans, that person bears the full cost while both enjoy the result --- structurally a Prisoner's Dilemma.
- **Information**: Simultaneous --- neither observes the other's choice before deciding.

The key criterion is mutual dependence: each player's best action depends on what the other does.
:::

**Exercise 2 --- Payoff heatmap.** *Create a payoff matrix for the Battle of the Sexes.*

::: {.callout-tip collapse="true" title="Solution"}
The payoff matrices are:

$$
A = \begin{pmatrix} 3 & 0 \\ 0 & 2 \end{pmatrix}, \quad
B = \begin{pmatrix} 2 & 0 \\ 0 & 3 \end{pmatrix}
$$

Use `make_payoff_df()` with strategies `c("Opera", "Football")` for both players. The heatmap should show high payoffs on the diagonal (coordination) and zeros off the diagonal (miscoordination). Unlike the Prisoner's Dilemma, there is no dominant strategy --- both diagonal cells are Nash equilibria.
:::

## Chapter 2: Normal-Form Games {-}

**Exercise 1 --- Identifying dominance.** *Find strictly and weakly dominated strategies in the 3x3 game.*

::: {.callout-tip collapse="true" title="Solution"}
For Player 1, compare each row against every other row across all columns:

- Row 2 yields payoffs $(3, 2, 5)$. Row 1 yields $(2, 4, 1)$. Neither strictly dominates the other (Row 1 is better in column 2, Row 2 in columns 1 and 3).
- Row 3 yields $(1, 3, 2)$. Row 2 gives $3 > 1$, $2 < 3$, $5 > 2$ --- again, no strict dominance.

Check all pairwise comparisons systematically. For weak dominance, look for rows where one is at least as good in every column and strictly better in at least one. Apply the same logic to Player 2's columns using matrix $B$.
:::

**Exercise 2 --- IESDS practice.** *Apply IESDS to the 3x3 game from Exercise 1.*

::: {.callout-tip collapse="true" title="Solution"}
Apply IESDS step by step:

1. Check for strictly dominated strategies in the original game and eliminate them.
2. In the reduced game, check again for newly dominated strategies.
3. Repeat until no further elimination is possible.

The order of elimination does not matter for strict dominance (order independence). Document each step by showing the reduced matrix. If the game reduces to a single cell, it is dominance solvable.
:::

## Chapter 3: Nash Equilibrium {-}

**Exercise 1 --- Stag Hunt equilibria.** *Find all Nash equilibria of the Stag Hunt.*

::: {.callout-tip collapse="true" title="Solution"}
The two pure-strategy NE are (Stag, Stag) with payoffs $(4, 4)$ and (Hare, Hare) with payoffs $(3, 3)$. Verify by checking that no player can profitably deviate.

For the mixed NE, use the indifference principle. If Player 2 plays Stag with probability $q$:

$$
4q + 0(1-q) = 3q + 3(1-q) \implies 4q = 3 \implies q = 3/4
$$

By symmetry, $p = 3/4$ as well. The mixed NE is $(3/4, 3/4)$ with expected payoff $3$ for each player.

- **Payoff-dominant**: (Stag, Stag) yields $4 > 3$.
- **Risk-dominant**: (Hare, Hare), because Hare is the best response to the mixed NE probability and is safer against uncertainty about the opponent.
:::

**Exercise 3 --- Best-response plot for Chicken.** *Plot the best-response correspondences.*

::: {.callout-tip collapse="true" title="Solution"}
Set up the indifference conditions for each player using the Chicken payoffs. Player 1's expected payoff from Swerve equals their payoff from Straight at the indifference point. Solve for the critical mixing probability and plot both best-response functions on the unit square $[0, 1]^2$. The plot should reveal three intersection points: two at corners (the pure NE) and one in the interior (the mixed NE).
:::

## Chapter 4: Mixed Strategies {-}

**Exercise 1 --- Asymmetric Matching Pennies.** *Compute the mixed NE when Player 1 receives 3 for (Heads, Heads).*

::: {.callout-tip collapse="true" title="Solution"}
Payoff matrices:

$$
A = \begin{pmatrix} 3 & -1 \\ -1 & 1 \end{pmatrix}, \quad
B = \begin{pmatrix} -1 & 1 \\ 1 & -1 \end{pmatrix}
$$

Player 2's indifference (making Player 1 indifferent is governed by $B$):

$$
-q + (1-q) = q - (1-q) \implies q^* = 1/2
$$

Player 1's indifference (making Player 2 indifferent is governed by $A$):

$$
3p - (1-p) = -p + (1-p) \implies 4p - 1 = -2p + 1 \implies p^* = 1/3
$$

The asymmetry in Player 1's payoff changes Player 1's mixing probability (not Player 2's). This is the "own-payoff effect" --- a player's equilibrium mixing probability is determined by the opponent's payoffs, not their own.
:::

**Exercise 4 --- Rock-Paper-Scissors.** *Argue that the unique mixed NE assigns 1/3 to each action.*

::: {.callout-tip collapse="true" title="Solution"}
By the symmetry of the game, if a NE assigns different probabilities to the three actions, then permuting the labels would yield another NE with different probabilities but identical structure --- contradicting uniqueness. Therefore the unique symmetric NE must assign equal probability $1/3$ to each action.

More formally: the indifference conditions for any pair of actions are identical by the cyclic symmetry of the payoff matrix, so the mixing probabilities must be equal. Since they sum to 1, each is $1/3$.
:::

## Chapter 5: Extensive-Form Games {-}

**Exercise 1 --- Ultimatum game.** *Find all NE and the SPE of the simplified ultimatum game.*

::: {.callout-tip collapse="true" title="Solution"}
The game tree has Player 1 choosing Fair or Greedy, then Player 2 choosing Accept or Reject.

**Backward induction**: In each of Player 2's subgames, accepting is strictly better than rejecting (5 > 0 and 2 > 0). So Player 2 accepts in both subgames. Anticipating this, Player 1 chooses Greedy (payoff 8 > 5). The SPE is (Greedy; Accept, Accept).

**Nash equilibria**: There are additional NE where Player 2 threatens to reject the Greedy offer. For example, (Fair; Accept, Reject) is a NE because Player 1's deviation to Greedy yields 0 given Player 2's strategy. However, this involves a non-credible threat --- Player 2 would not actually reject a payoff of 2 --- so backward induction eliminates it.
:::

**Exercise 3 --- Non-credible threats.** *What if the incumbent's Fight payoff is 2?*

::: {.callout-tip collapse="true" title="Solution"}
With Fight payoff of 2, the incumbent now weakly prefers fighting to accommodating (or strictly prefers it if Accommodate yields less than 2). In the subgame after entry, Fight is at least as good as Accommodate, so the threat to fight is credible.

The SPE changes: the entrant, anticipating a fight, may prefer to stay out. This illustrates a key insight --- whether a threat is credible depends on the payoffs in the subgame, not on the threat itself.
:::

## Chapter 6: Bayesian Games {-}

**Exercise 1 --- Modified signaling costs.** *Does the separating equilibrium survive if $c_L = 3$?*

::: {.callout-tip collapse="true" title="Solution"}
In the separating equilibrium, the High type chooses Education and the Low type does not. The Low type must not want to deviate to Education. The incentive compatibility condition for the Low type is:

$$
\text{Payoff(No Education)} \geq \text{Payoff(Education)} - c_L
$$

With $c_L = 3$, check whether the Low type's gain from being perceived as High (and receiving the High-type wage) exceeds the education cost. If the wage differential is, say, $8 - 2 = 6$ and $c_L = 3 < 6$, the Low type would profitably deviate to Education, breaking separation.

The minimum $c_L$ that sustains separation is the wage differential: the Low type must find education too costly to mimic the High type.
:::

**Exercise 2 --- Pooling equilibrium.** *Can both types pool on No Education?*

::: {.callout-tip collapse="true" title="Solution"}
In a pooling equilibrium on No Education, the employer observes no signal and pays the expected productivity: $E[\theta] = P(H) \cdot \theta_H + P(L) \cdot \theta_L$. Neither type deviates if the off-path belief about a worker who chooses Education is sufficiently pessimistic (e.g., the employer believes any educating worker is Low type with probability 1). Under such beliefs, education yields the Low-type wage minus the education cost, which is worse than the pooling wage for both types. These pessimistic off-path beliefs are permitted by Bayes' rule (which imposes no constraint off the equilibrium path).
:::

## Chapter 7: Repeated Games {-}

**Exercise 1 --- Critical discount factor.** *Compute $\delta^*$ for Grim Trigger with $T = 8, R = 5, P = 2, S = 0$.*

::: {.callout-tip collapse="true" title="Solution"}
Under Grim Trigger, cooperation yields $V_C = R / (1 - \delta) = 5 / (1 - \delta)$.

A one-shot deviation yields $T$ today and then $P$ forever: $V_D = T + \delta P / (1 - \delta) = 8 + 2\delta / (1 - \delta)$.

Cooperation is sustained when $V_C \geq V_D$:

$$
\frac{5}{1 - \delta} \geq 8 + \frac{2\delta}{1 - \delta}
$$

$$
5 \geq 8(1 - \delta) + 2\delta = 8 - 6\delta
$$

$$
6\delta \geq 3 \implies \delta^* = 1/2
$$

Verify in R by computing $V_C$ and $V_D$ at $\delta = 0.5$ and confirming they are equal.
:::

**Exercise 3 --- Folk theorem region.** *Plot the feasible and individually rational region.*

::: {.callout-tip collapse="true" title="Solution"}
The feasible payoff set is the convex hull of the four payoff profiles: $(4, 4)$, $(0, 6)$, $(6, 0)$, $(1, 1)$. The individually rational region requires each player's payoff to be at least their minmax value. In a 2x2 game, compute each player's minmax payoff by finding the worst the opponent can guarantee.

The Folk theorem region is the intersection: feasible payoffs that dominate both players' minmax values. Plot the convex hull as a polygon and shade the region above both minmax thresholds.
:::

## Chapter 8: Cooperative Game Theory {-}

**Exercise 1 --- Asymmetric savings.** *Compute the Shapley value for the modified water treatment game.*

::: {.callout-tip collapse="true" title="Solution"}
With $v(\{A\}) = v(\{B\}) = v(\{C\}) = 0$, $v(\{A,B\}) = 50$, $v(\{A,C\}) = 30$, $v(\{B,C\}) = 40$, $v(\{A,B,C\}) = 80$.

The Shapley value for player $i$ is:

$$
\phi_i = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|! \, (n - |S| - 1)!}{n!} \left[ v(S \cup \{i\}) - v(S) \right]
$$

For a 3-player game, enumerate all $3! = 6$ orderings and compute each player's marginal contribution in each ordering. Average across orderings.

For example, in ordering $(A, B, C)$: $A$ contributes $v(\{A\}) - v(\emptyset) = 0$, $B$ contributes $v(\{A,B\}) - v(\{A\}) = 50$, $C$ contributes $v(\{A,B,C\}) - v(\{A,B\}) = 30$.

Repeat for all six orderings and average. Municipality A benefits from large coalitions with B; Municipality B is the most valuable partner overall.
:::

**Exercise 4 --- Glove game.** *Write the characteristic function, compute the Shapley value, and find the core.*

::: {.callout-tip collapse="true" title="Solution"}
Characteristic function: $v(S) = \min(\text{left gloves in } S, \text{right gloves in } S)$. So $v(\{1\}) = v(\{2\}) = v(\{3\}) = 0$, $v(\{1,2\}) = 0$ (two left, no right), $v(\{1,3\}) = v(\{2,3\}) = 1$, $v(\{1,2,3\}) = 1$.

Shapley value: enumerate all $3! = 6$ orderings. Player 3 (the sole right-glove holder) is pivotal in 4 out of 6 orderings, yielding $\phi_3 = 4/6 = 2/3$. By symmetry, $\phi_1 = \phi_2 = 1/6$.

Core: the core requires $x_1 + x_3 \geq 1$, $x_2 + x_3 \geq 1$, $x_1 + x_2 \geq 0$, $x_1 + x_2 + x_3 = 1$, and $x_i \geq 0$. From the first two constraints and efficiency: $x_3 \geq 1 - x_1$ and $x_3 \geq 1 - x_2$. Since $x_1 + x_2 = 1 - x_3$, both constraints give $x_3 = 1$ and $x_1 = x_2 = 0$. The core is the single point $(0, 0, 1)$. The Shapley value $(1/6, 1/6, 2/3)$ does not lie in the core.
:::

## Additional selected solutions {-}

Below are brief hints for a few more exercises that students frequently ask about.

**Chapter 2, Exercise 4 --- From story to matrix.** *Two firms choose Invest or Stay.*

::: {.callout-tip collapse="true" title="Solution"}
The payoff matrix is:

$$
A = B = \begin{pmatrix} 5 & 1 \\ 4 & 3 \end{pmatrix}
$$

where rows/columns are (Invest, Stay). Check for dominance: against Invest, Stay yields 4 > 1 (in the role of the other firm); against Stay, Stay yields 3 > 1. Stay strictly dominates Invest for both players, so (Stay, Stay) with payoffs $(3, 3)$ is the unique NE. This is a Prisoner's Dilemma: mutual investment would yield $(5, 5)$ but the dominant strategy leads to a Pareto-inferior outcome.
:::

**Chapter 4, Exercise 2 --- Inspection game.** *Find the mixed NE of the Worker-Employer game.*

::: {.callout-tip collapse="true" title="Solution"}
Payoff matrices (Worker is row player, Employer is column player):

$$
A = \begin{pmatrix} 2 & 1 \\ 3 & 0 \end{pmatrix}, \quad
B = \begin{pmatrix} 3 & 2 \\ 0 & 1 \end{pmatrix}
$$

where rows are (Work, Shirk) and columns are (Trust, Monitor).

No pure-strategy NE exists (verify by checking best responses). For the mixed NE, let the Worker play Work with probability $p$ and the Employer play Trust with probability $q$.

Employer's indifference (using $A$): $2q + 1(1-q) = 3q + 0(1-q)$, so $q + 1 = 3q$, giving $q^* = 1/2$.

Worker's indifference (using $B$): $3p + 0(1-p) = 2p + 1(1-p)$, so $3p = p + 1$, giving $p^* = 1/2$.

Increasing the penalty for caught shirking (lowering $A_{2,2}$ below 0) does *not* change $p^*$ in equilibrium --- it changes the employer's mixing probability $q^*$ instead. This is another instance of the "own-payoff" paradox from the indifference principle.
:::

**Chapter 5, Exercise 4 --- SPE vs. NE counting.** *Count equilibria in the ultimatum game.*

::: {.callout-tip collapse="true" title="Solution"}
The normal form has 2 strategies for Player 1 (Fair, Greedy) and 4 strategies for Player 2 (Accept/Accept, Accept/Reject, Reject/Accept, Reject/Reject --- one decision for each of Player 1's possible offers).

Pure-strategy NE: find all cells where both players play a best response. There are three NE:

1. (Greedy; Accept, Accept) --- payoffs (8, 2).
2. (Fair; Accept, Reject) --- payoffs (5, 5).
3. (Fair; Reject, Reject) --- payoffs (5, 5).

Only NE 1 is subgame perfect, because in NE 2 and 3 Player 2's plan to reject the Greedy offer is not sequentially rational (2 > 0). Thus SPE $\subset$ NE strictly.
:::

**Chapter 7, Exercise 2 --- Tit-for-Tat critical discount factor.** *Derive $\delta^*$ for TFT.*

::: {.callout-tip collapse="true" title="Solution"}
Under TFT with $T = 5, R = 3, P = 1, S = 0$: cooperation yields $V_C = 3 / (1 - \delta)$.

A deviation yields $T = 5$ today. TFT retaliates next period (defects once), so the deviator gets $S = 0$ in period 2. Then TFT returns to cooperation (it copies the opponent's last action), so from period 3 onward the deviator gets $R = 3$ again --- but only if the deviator also returns to cooperation. The one-shot deviation payoff stream is:

$$
V_D = 5 + 0 \cdot \delta + 3 \cdot \frac{\delta^2}{1 - \delta}
$$

Setting $V_C \geq V_D$:

$$
\frac{3}{1 - \delta} \geq 5 + \frac{3\delta^2}{1 - \delta}
$$

$$
3 \geq 5(1 - \delta) + 3\delta^2 = 5 - 5\delta + 3\delta^2
$$

$$
3\delta^2 - 5\delta + 2 \leq 0
$$

Solving: $\delta = \frac{5 \pm \sqrt{25 - 24}}{6} = \frac{5 \pm 1}{6}$, so $\delta \in [2/3, 1]$. The critical discount factor is $\delta^* = 2/3$, which is higher than the Grim Trigger threshold ($1/2$ for these payoffs), reflecting TFT's milder punishment.
:::
