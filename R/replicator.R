# replicator.R — replicator dynamics via deSolve
# Strategy in R

replicator_ode <- function(t, state, parms) {
  x <- state
  A <- parms$payoff_matrix
  fitness <- as.vector(A %*% x)
  avg_fitness <- sum(x * fitness)
  dx <- x * (fitness - avg_fitness)
  list(dx)
}

run_replicator <- function(payoff_matrix, x0, times = seq(0, 50, by = 0.1)) {
  parms <- list(payoff_matrix = payoff_matrix)
  out <- deSolve::ode(y = x0, times = times, func = replicator_ode, parms = parms)
  as.data.frame(out)
}
