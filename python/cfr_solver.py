"""cfr_solver.py — Counterfactual Regret Minimization for two-player games.

Strategy in R — Python helper called via reticulate.
"""

import numpy as np


def cfr_iterate(payoff_matrix, iterations=10000):
    """Run vanilla CFR on a two-player zero-sum game."""
    n_actions = payoff_matrix.shape[0]
    regret_sum = np.zeros(n_actions)
    strategy_sum = np.zeros(n_actions)

    for _ in range(iterations):
        strategy = _regret_matching(regret_sum)
        strategy_sum += strategy
        opponent_strategy = strategy_sum / strategy_sum.sum() if strategy_sum.sum() > 0 else np.ones(n_actions) / n_actions
        action_utilities = payoff_matrix @ opponent_strategy
        regret_sum += action_utilities - np.dot(strategy, action_utilities)
        regret_sum = np.maximum(regret_sum, 0)

    avg_strategy = strategy_sum / strategy_sum.sum() if strategy_sum.sum() > 0 else np.ones(n_actions) / n_actions
    return avg_strategy


def _regret_matching(regret_sum):
    positive = np.maximum(regret_sum, 0)
    total = positive.sum()
    if total > 0:
        return positive / total
    return np.ones(len(regret_sum)) / len(regret_sum)
