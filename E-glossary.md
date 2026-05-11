# Glossary {#sec-glossary}

> Key terms and definitions used throughout this book.
Action
: A choice available to a player at a decision point. In a simultaneous game, the terms "action" and "strategy" are often used interchangeably.

Agent-based model
: A computational model in which autonomous agents interact according to specified rules, producing emergent macro-level behaviour. See \@ref(sec-agent-based-models).

Backward induction
: A solution method for extensive-form games of perfect information. Starting from terminal nodes and working backwards, each player's optimal action is determined at every decision node. The resulting strategy profile is a subgame perfect equilibrium. See \@ref(sec-extensive-form).

Battle of the Sexes
: A 2x2 coordination game with two pure-strategy Nash equilibria and one mixed equilibrium. The players prefer to coordinate but disagree on which outcome is better.

Bayesian game
: A game in which players have private information (types) drawn from a known prior distribution. Players maximise expected payoffs given their beliefs about opponents' types. See \@ref(sec-bayesian-games).

Bayesian Nash equilibrium (BNE)
: A strategy profile in a Bayesian game where each type of each player maximises expected payoff given the prior distribution over opponents' types and their strategies.

Best response
: A strategy $s_i^*$ that maximises player $i$'s payoff given the strategies of all other players. A Nash equilibrium is a profile where every player's strategy is a best response.

Characteristic function
: In cooperative game theory, a function $v: 2^N \to \mathbb{R}$ that assigns a worth to every coalition $S \subseteq N$. See \@ref(sec-cooperative-gt).

Chicken (Hawk-Dove)
: A 2x2 anti-coordination game modelling brinkmanship. Each player prefers the other to yield. It has two asymmetric pure-strategy NE and one mixed NE.

Common knowledge
: A fact is common knowledge if all players know it, all players know that all players know it, and so on ad infinitum. The structure of the game is typically assumed to be common knowledge.

Cooperative game theory
: The branch of game theory that studies what coalitions of players can achieve and how the joint gains should be allocated. Focuses on outcomes rather than strategies. See \@ref(sec-cooperative-gt).

Core
: The set of feasible payoff allocations in a cooperative game that no coalition can improve upon. An allocation is in the core if no subset of players can do better by breaking away.

Discount factor
: A parameter $\delta \in [0, 1)$ representing the weight a player places on future payoffs relative to current payoffs. Central to repeated game analysis. See \@ref(sec-repeated-games).

Dominant strategy
: A strategy that yields a payoff at least as high as any alternative regardless of opponents' actions (weak dominance) or strictly higher (strict dominance).

Evolutionary stable strategy (ESS)
: A strategy that, once prevalent in a population, cannot be invaded by any rare mutant strategy. Formally, a strategy $s^*$ is an ESS if it is a best response to itself and, against any alternative best response, does strictly better against the mutant than the mutant does against itself. See \@ref(sec-evolutionary-stable-strategies).

Extensive form
: A representation of a game as a tree, specifying the order of moves, information available at each decision point, and payoffs at terminal nodes. See \@ref(sec-extensive-form).

Feasible payoff set
: The convex hull of all achievable payoff vectors in a game. In repeated games, the folk theorem concerns the subset of feasible payoffs that are individually rational.

Folk theorem
: A family of results stating that in infinitely repeated games with sufficiently patient players ($\delta$ close to 1), any feasible and individually rational payoff vector can be sustained as a Nash equilibrium outcome. See \@ref(sec-repeated-games).

Game tree
: The tree representation of an extensive-form game, with nodes representing decision points and edges representing actions.

Grim Trigger
: A strategy in repeated games that cooperates until the opponent defects, then defects forever. The simplest strategy that can sustain cooperation via the threat of permanent punishment.

Imperfect information
: A game has imperfect information if at least one player does not observe all previous moves when making a decision. Represented by information sets in the game tree.

Incomplete information
: A game has incomplete information if players are uncertain about some aspect of the game, such as other players' payoffs or types. Modelled as a Bayesian game.

Individually rational payoff
: The minimum payoff a player can guarantee regardless of opponents' strategies (the minmax value). In repeated games, the folk theorem applies to payoffs above this threshold.

Information set
: In an extensive-form game, a collection of decision nodes among which a player cannot distinguish. The player must choose the same action at all nodes in the same information set.

Matching Pennies
: A 2x2 zero-sum game where one player wins if outcomes match and the other wins if they differ. It has a unique Nash equilibrium in mixed strategies.

Mechanism design
: The "inverse" of game theory: designing the rules of a game (mechanism) so that self-interested players produce a desired outcome in equilibrium. See \@ref(sec-mechanism-design).

Minmax value
: The lowest payoff that opponents can force on a player, or equivalently, the highest payoff a player can guarantee against the worst-case opponent behaviour.

Mixed strategy
: A probability distribution over a player's pure strategies. A player randomises among actions according to the specified probabilities. See \@ref(sec-mixed-strategies).

Monte Carlo method
: A computational technique that uses random sampling to estimate quantities or simulate systems. Used throughout Part III for game simulations. See \@ref(sec-monte-carlo).

Nash equilibrium (NE)
: A strategy profile in which no player can increase their payoff by unilaterally changing their strategy. Every finite game has at least one Nash equilibrium (possibly in mixed strategies). See \@ref(sec-nash-equilibrium).

Normal form (strategic form)
: A representation of a simultaneous game as a matrix of payoffs. Each row corresponds to a strategy of one player, each column to a strategy of the other. See \@ref(sec-normal-form).

Pareto optimal (Pareto efficient)
: An outcome is Pareto optimal if no alternative outcome makes at least one player strictly better off without making any player worse off. The Prisoner's Dilemma equilibrium is famously Pareto inefficient.

Payoff matrix
: The matrix encoding all players' payoffs for every combination of strategies in a normal-form game.

Perfect information
: A game has perfect information if every player, when making a decision, observes all previously taken actions. Chess is a canonical example.

Prisoner's Dilemma
: A 2x2 game where each player has a dominant strategy to defect, yet mutual cooperation yields a higher payoff for both. The unique NE is Pareto inefficient.

Pure strategy
: A deterministic plan of action that specifies exactly which action a player will take at every decision point.

Replicator dynamics
: A system of differential equations describing how the proportions of strategies in a population change over time based on their relative fitness. See \@ref(sec-replicator-dynamics).

Shapley value
: A unique allocation in cooperative game theory that distributes the total value among players according to their average marginal contribution across all possible orderings. See \@ref(sec-cooperative-gt).

Signaling game
: A dynamic Bayesian game where an informed player (sender) takes an observable action to convey information to an uninformed player (receiver). See \@ref(sec-bayesian-games).

Stag Hunt
: A 2x2 coordination game with two pure-strategy NE: one payoff-dominant (both hunt Stag) and one risk-dominant (both hunt Hare). It models the tension between cooperation and safety.

Strategy profile
: A specification of one strategy for every player in the game. An $n$-player game has a strategy profile $(s_1, s_2, \ldots, s_n)$.

Subgame
: A portion of an extensive-form game that starts at a singleton information set, contains all successors, and does not break any information set.

Subgame perfect equilibrium (SPE)
: A strategy profile that constitutes a Nash equilibrium in every subgame of the original game. Found by backward induction in games of perfect information. See \@ref(sec-extensive-form).

Support (of a mixed strategy)
: The set of pure strategies assigned positive probability in a mixed strategy. At a Nash equilibrium, every strategy in the support must yield the same expected payoff.

Tit-for-Tat (TFT)
: A strategy in repeated games that cooperates in the first round, then copies the opponent's previous action. Famously successful in Axelrod's tournaments. See \@ref(sec-axelrod-tournament).

Zero-sum game
: A game in which the sum of all players' payoffs is zero (or constant) for every outcome. One player's gain is exactly another's loss. Matching Pennies is a canonical example.
