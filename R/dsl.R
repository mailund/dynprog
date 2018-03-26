## Main language interface: with and where ####################################

#' Connects a recursion with sequences it should recurse over.
#'
#' This function parses a dynamic programming recursion expression and evaluates
#' it, returning the table that the recursions specify.
#'
#' @param recursion  Specification of the dynamic programming recursion.
#' @param ranges     Specification of the index-ranges the recursion should
#'                   compute values over.
#'
#' @return A filled out dynamic programming table.
#' @examples
#'
#' # Fibonnaci numbers
#' fib <- {
#'   F[n] <- 1 ? n <= 2
#'   F[n] <- F[n-1] + F[n-2]
#' } %where% {
#'   n <- 1:10
#' }
#' fib
#'
#' # Edit distance
#' x <- c("a", "b", "c")
#' y <- c("a", "b", "b", "c")
#' edit <- {
#'     E[1,j] <- j - 1
#'     E[i,1] <- i - 1
#'     E[i,j] <- min(
#'         E[i - 1,j] + 1,
#'         E[i,j - 1] + 1,
#'         E[i - 1,j - 1] + (x[i - 1] != y[j - 1])
#'     )
#' } %where% {
#'     i <- 1:(length(x) + 1)
#'     j <- 1:(length(y) + 1)
#' }
#' edit
#'
#' @export
`%where%` <- function(recursion, ranges) {
    eval_recursion(
        recursions = parse_recursion(rlang::enquo(recursion)),
        ranges = parse_ranges(rlang::enquo(ranges))
    )
}
