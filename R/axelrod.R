# axelrod.R — iterated Prisoner's Dilemma tournament harness
# Strategy in R

play_round <- function(action1, action2, R = 3, S = 0, T = 5, P = 1) {
  payoffs <- matrix(c(R, S, T, P), nrow = 2, byrow = TRUE,
                    dimnames = list(c("C", "D"), c("C", "D")))
  c(payoffs[action1, action2], payoffs[action2, action1])
}

run_match <- function(strategy1, strategy2, rounds = 200) {
  history1 <- character(0)
  history2 <- character(0)
  scores <- c(0, 0)
  for (r in seq_len(rounds)) {
    a1 <- strategy1(history1, history2)
    a2 <- strategy2(history2, history1)
    payoff <- play_round(a1, a2)
    scores <- scores + payoff
    history1 <- c(history1, a1)
    history2 <- c(history2, a2)
  }
  scores
}

# Example strategies
strategy_always_cooperate <- function(own, opp) "C"
strategy_always_defect    <- function(own, opp) "D"
strategy_tit_for_tat      <- function(own, opp) {
  if (length(opp) == 0) "C" else opp[length(opp)]
}
