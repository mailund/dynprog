
## Parsing ranges #############################################################

#' Parser for the ranges part of a specification.
#'
#' FIXME: more
#'
#' @param ranges The quosure wrapping the input to the specification.
#' @return A parsed specification for ranges.
#' @export
parse_ranges <- function(ranges) {
    # We needed `ranges` to be a quasure so we know the environment in which
    # to evaluate the expressions, but to actually parse it, it is easier
    # to use the underlying expression.
    ranges_expr <- rlang::get_expr(ranges)
    ranges_env <- rlang::get_env(ranges)

    # FIXME: better input validation
    stopifnot(ranges_expr[[1]] == "{")
    ranges_definitions <- ranges_expr[-1]

    # We want to evaluate all the expressions, in the quosure environment,
    # and put them in a list under the name we gave them.
    n <- length(ranges_definitions)
    result <- vector("list", length = n)
    indices <- vector("character", length = n)

    for (i in seq_along(ranges_definitions)) {
        assignment <- ranges_definitions[[i]]

        # FIXME: better input validation
        stopifnot(assignment[[1]] == "<-")
        range_var <- as.character(assignment[[2]])
        range_value <- eval(assignment[[3]], ranges_env)

        indices[[i]] <- range_var
        result[[i]] <- range_value
    }

    names(result) <- indices
    result
}

## Parsing recursion ##########################################################

## Main language interface: with and where ####################################

#' Function for parsing an entire dynprog expression.
#'
#' This is the top-level parser. It will be invoked by \code{\link{\%where\%}}
#' once an entire expression has been parsed by the R parser. It is then
#' responsible for doing the DSL parsing before we evaluate the expression.
#'
#' @param spec The dynamic programming specification.
#' @return     An object containing the parsed specification.
parse <- function(spec) {
    spec
}

#' Defines a table and connects it with a recursive formula.
#'
#' FIXME: more
#'
#' @param tbl_name  A name we can use for a table. This name is used
#'                  in the `recursion` specification.
#' @param recursion Specification of a recursion that uses `tbl_name`.
#'
#' @return An object representing the recursion-expression.
#'         This object is used to create the dynamic programming algorithm
#'         when the \code{\%with\%} expression is combined with a \code{\%where\%}
#'         expression that specifies the indices the algorithm should iterate over.
#'
#' @seealso \%where\%
#'
#' @export
`%with%` <- function(tbl_name, recursion) {
    tbl_name <- rlang::enexpr(tbl_name)
    recursion <- rlang::enquo(recursion)
    # FIXME: check validity of input
    list(tbl_name = tbl_name, recursion = recursion)
}

#' Connects a recursion with sequences it should recurse over.
#'
#' FIXME: more
#'
#' A \code{\%where\%} call is the last function call in a dynamic programming
#' specification, so this is also where we trigger the actual evaluation of the
#' expression.
#'
#' @param recursion  Specification of the dynamic programming recursion.
#'                   This will be the result of a call to \code{\%with\%}.
#' @param ranges     Specification of the index-ranges the recursion should
#'                   compute values over.
#'
#' @seealso \%with\%
#'
#' @export
`%where%` <- function(recursion, ranges) {
    # FIXME: check validity of input
    recursion$ranges <- rlang::enquo(ranges)
    recursion
}
