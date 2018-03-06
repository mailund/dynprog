## Main language interface: with and where ####################################

#' Connects a recursion with sequences it should recurse over.
#'
#' FIXME: more
#'
#' @param recursion  Specification of the dynamic programming recursion.
#' @param ranges     Specification of the index-ranges the recursion should
#'                   compute values over.
#'
#' @export
`%where%` <- function(recursion, ranges) {
    eval_recursion(
        recursions = parse_recursion(rlang::enquo(recursion)),
        ranges = parse_ranges(rlang::enquo(ranges))
    )

}
