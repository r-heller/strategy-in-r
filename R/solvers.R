# solvers.R — Nash equilibrium solvers
# Strategy in R

solve_2x2_pure_nash <- function(A, B) {
  equilibria <- list()
  nr <- nrow(A)
  nc <- ncol(A)
  for (i in seq_len(nr)) {
    for (j in seq_len(nc)) {
      row_best <- A[i, j] == max(A[, j])
      col_best <- B[i, j] == max(B[i, ])
      if (row_best && col_best) {
        equilibria <- c(equilibria, list(c(i, j)))
      }
    }
  }
  equilibria
}

solve_2x2_mixed_nash <- function(A, B) {
  a <- A[1, 1] - A[2, 1] - A[1, 2] + A[2, 2]
  b <- B[1, 1] - B[1, 2] - B[2, 1] + B[2, 2]
  if (abs(a) < 1e-10 || abs(b) < 1e-10) return(NULL)
  q <- (A[2, 2] - A[2, 1]) / a
  p <- (B[2, 2] - B[1, 2]) / b
  if (p >= 0 && p <= 1 && q >= 0 && q <= 1) {
    return(list(p = p, q = q))
  }
  NULL
}

support_enumeration <- function(A, B) {
  pure <- solve_2x2_pure_nash(A, B)
  mixed <- solve_2x2_mixed_nash(A, B)
  list(pure = pure, mixed = mixed)
}
