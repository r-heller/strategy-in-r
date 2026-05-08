# rl_agents.R — tabular Q-learning and SARSA agents
# Strategy in R

#' Create a Q-learning agent for matrix games (stateless setting)
#'
#' @param n_actions Number of available actions
#' @param alpha Learning rate
#' @param gamma Discount factor (unused in stateless games, kept for API consistency)
#' @param epsilon Exploration rate for epsilon-greedy
#' @return A list with choose(), update(), and get_Q() methods
q_learning_agent <- function(n_actions, alpha = 0.1, gamma = 0.95, epsilon = 0.1) {
  Q <- matrix(0, nrow = 1, ncol = n_actions)
  list(
    choose = function() {
      if (runif(1) < epsilon) {
        sample(n_actions, 1)
      } else {
        ties <- which(Q[1, ] == max(Q[1, ]))
        sample(ties, 1)
      }
    },
    update = function(action, reward) {
      Q[1, action] <<- Q[1, action] + alpha * (reward - Q[1, action])
    },
    get_Q = function() Q
  )
}

#' Create a Q-learning agent for tabular MDPs (with states)
#'
#' @param n_states Number of states
#' @param n_actions Number of available actions
#' @param alpha Learning rate
#' @param gamma Discount factor
#' @param epsilon Exploration rate for epsilon-greedy
#' @return A list with choose(), update(), and get_Q() methods
q_learning_tabular <- function(n_states, n_actions, alpha = 0.1,
                                gamma = 0.95, epsilon = 0.1) {
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  list(
    choose = function(state) {
      if (runif(1) < epsilon) {
        sample(n_actions, 1)
      } else {
        ties <- which(Q[state, ] == max(Q[state, ]))
        sample(ties, 1)
      }
    },
    update = function(state, action, reward, next_state) {
      best_next <- max(Q[next_state, ])
      Q[state, action] <<- Q[state, action] +
        alpha * (reward + gamma * best_next - Q[state, action])
    },
    get_Q = function() Q,
    get_V = function() apply(Q, 1, max)
  )
}

#' Create a SARSA agent for tabular MDPs
#'
#' @param n_states Number of states
#' @param n_actions Number of available actions
#' @param alpha Learning rate
#' @param gamma Discount factor
#' @param epsilon Exploration rate for epsilon-greedy
#' @return A list with choose(), update(), and get_Q() methods
sarsa_agent <- function(n_states, n_actions, alpha = 0.1,
                         gamma = 0.95, epsilon = 0.1) {
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  list(
    choose = function(state) {
      if (runif(1) < epsilon) {
        sample(n_actions, 1)
      } else {
        ties <- which(Q[state, ] == max(Q[state, ]))
        sample(ties, 1)
      }
    },
    update = function(state, action, reward, next_state, next_action) {
      Q[state, action] <<- Q[state, action] +
        alpha * (reward + gamma * Q[next_state, next_action] - Q[state, action])
    },
    get_Q = function() Q,
    get_V = function() apply(Q, 1, max)
  )
}
