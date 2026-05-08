"""nashpy_helpers.py — thin wrappers around nashpy for use via reticulate.

Strategy in R — Python helper.
"""

import nashpy as nash
import numpy as np


def find_nash_equilibria(A, B):
    """Find Nash equilibria for a two-player game with payoff matrices A and B."""
    game = nash.Game(np.array(A), np.array(B))
    equilibria = list(game.support_enumeration())
    return [(eq[0].tolist(), eq[1].tolist()) for eq in equilibria]


def find_mixed_nash(A, B):
    """Find mixed strategy Nash equilibria via support enumeration."""
    game = nash.Game(np.array(A), np.array(B))
    return list(game.support_enumeration())
