
## Parsing ranges #############################################################

#' Parser for the ranges part of a specification.
#'
#' Parses the ranges, the bit after `%where%`, and return a list of index
#' variables an the values they should iterate over. The ranges are returned as
#' a list with the range variables as its names and the range values as the
#' list components.
#'
#' @param ranges The quosure wrapping the input to the specification.
#' @return A parsed specification for ranges.
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

#' Parser for the recursion part of a specification.
#'
#' Parse the recursion part of an expressions, i.e. the bits before `%where%`.
#'
#' The parser return a list with the following components:
#' - **recursion_env:**  The environment in which expressions should be
#'     evaluated.
#' - **partterns:** A list of patterns, one per recursion case.
#' - **conditions:** A list of conditions, one per recursion case.
#' - **recursions:** A list of expressions, one per recursion case.
#'
#'
#' @param recursion The quosure wrapping the recursion of the specification.
#' @return A parsed specification for recursions.
parse_recursion <- function(recursion) {
    # We needed `recursion` to be a quasure so we know the environment in which
    # to evaluate the expressions, but to actually parse it, it is easier
    # to use the underlying expression.
    recursion_expr <- rlang::get_expr(recursion)
    recursion_env <- rlang::get_env(recursion)

    # FIXME: better input validation
    stopifnot(recursion_expr[[1]] == "{")
    recursion_cases <- recursion_expr[-1]

    n <- length(recursion_cases)
    patterns <- vector("list", length = n)
    conditions <- vector("list", length = n)
    recursions <- vector("list", length = n)

    for (i in seq_along(recursion_cases)) {
        case <- recursion_cases[[i]]

        condition <- TRUE
        stopifnot(rlang::is_call(case)) # FIXME: better error handling
        if (case[[1]] == "?") {
            # NB: The order matters here!
            condition <- case[[3]]
            case <- case[[2]]
        }

        stopifnot(case[[1]] == "<-") # FIXME: better error handling
        pattern <- case[[2]]
        recursion <- case[[3]]

        patterns[[i]] <- pattern
        recursions[[i]] <- recursion
        conditions[[i]] <- condition
    }

    list(
        recursion_env = recursion_env,
        patterns = patterns,
        conditions = conditions,
        recursions = recursions
    )
}
