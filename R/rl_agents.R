# rl_agents.R — tabular Q-learning and SARSA for matrix games
# Strategy in R

q_learning_agent <- function(n_actions, alpha = 0.1, gamma = 0.95, epsilon = 0.1) {
  Q <- matrix(0, nrow = 1, ncol = n_actions)
  list(
    choose = function() {
      if (runif(1) < epsilon) {
        sample(n_actions, 1)
      } else {
        which.max(Q[1, ])
      }
    },
    update = function(action, reward) {
      Q[1, action] <<- Q[1, action] + alpha * (reward - Q[1, action])
    },
    get_Q = function() Q
  )
}
