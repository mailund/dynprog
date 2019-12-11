#' Extract the table name from a pattern.
#'
#' We generally assume that patterns are on the form `table[exprs]`
#' where `table` is the name of the dynamic programming table. This
#' function extract that name.
#'
#' @param patterns The patterns used in the recursion.
#' @return The table part of the pattern.
get_table_name <- function(patterns) {
    p <- patterns[[1]]
    stopifnot(p[[1]] == "[")
    p[[2]]
}

#' Translate a pattern into a predicate that checks the pattern.
#'
#' Takes a pattern from the DSL and make a comparison of the
#' pattern specification against range variables.
#'
#' @param pattern An expression on the form `table[index-list]`
#' @param range_vars A list of the variables used in the ranges.
#' @return An expression that tests `pattern` against `range_vars`.
make_pattern_match <- function(pattern, range_vars) {
    matches <- vector("list", length = length(range_vars))
    stopifnot(pattern[[1]] == "[")
    for (i in seq_along(matches)) {
        matches[[i]] <- rlang::call2(
            "==",
            pattern[[i + 2]],
            range_vars[[i]]
        )
    }
    rlang::expr(all(!!! matches))
}

#' Make pattern tests for all patterns.
#'
#' This function calls [make_pattern_match()] for each pattern in `patterns`
#' and return a list of all the pattern test expressions.
#'
#' @param patterns A list of the patterns used in a recursion.
#' @param range_vars The variables used in the ranges.
#' @return A list of pattern check expressions.
make_pattern_tests <- function(patterns, range_vars) {
    tests <- vector("list", length = length(patterns))
    for (i in seq_along(tests)) {
        tests[[i]] <- make_pattern_match(
            patterns[[i]],
            range_vars
        )
    }
    tests
}

#' Translate condition expressions into calls that test them.
#'
#' Takes the full dynprog expression and construct a list of condition
#' tests for each component of the recursion.
#'
#' @param ranges The ranges specifications
#' @param patterns The patterns specifications
#' @param conditions The conditions specifications
#' @param recursions The recursions specification
#' @return A list of calls, one per recursion, for testing conditions.
make_condition_checks <- function(ranges,
                                  patterns,
                                  conditions,
                                  recursions) {
    test_conditions <- make_pattern_tests(
        patterns,
        Map(as.symbol, names(ranges))
    )
    for (i in seq_along(conditions)) {
        test_conditions[[i]] <- rlang::call2(
            "&&", test_conditions[[i]], conditions[[i]]
        )
    }
    test_conditions
}

#' Construct a test for a case in the recursion
#'
#' This function creates an `if`-statement for testing if a case can be
#' applied.
#'
#' @param test_expr The expression that must be true for the case to be applied
#' @param value_expr The value to compute if the test is true
#' @param continue The next case to check if this one isn't true
#' @return An `if`-statement for checking and potentially evaluating one case.
make_recursion_case <- function(test_expr,
                                value_expr,
                                continue) {
    if (rlang::is_null(continue)) {
        rlang::call2("if", test_expr, value_expr)
    } else {
        rlang::call2("if", test_expr, value_expr, continue)
    }
}

#' String together the case `if`-statements of a recursion.
#'
#' @param ranges The ranges specification
#' @param patterns The patterns specification
#' @param conditions The conditions specifications
#' @param recursions The recursions specification
#' @return A series of `if`-`else`-statements for evaluating a recursion.
make_update_expr <- function(ranges,
                             patterns,
                             conditions,
                             recursions) {
    conditions <- make_condition_checks(
        ranges,
        patterns,
        conditions,
        recursions
    )
    continue <- NULL
    for (i in rev(seq_along(conditions))) {
        continue <- make_recursion_case(
            conditions[[i]], recursions[[i]], continue
        )
    }
    continue
}

#' Evaluate an entire dynprog recursion.
#'
#' This function takes the `ranges` and `recursions` of a specification and
#' evaluate the dynprog expression, returning a filled out dynamic programming
#' table.
#'
#' @param ranges The ranges specification
#' @param recursions The recursions specification
#' @return The filled out dynamic programming table
eval_recursion <- function(ranges, recursions) {
    tbl_name <- get_table_name(recursions$patterns)
    tbl_name_string <- as.character(tbl_name)
    update_expr <- make_update_expr(
        ranges,
        recursions$patterns,
        recursions$conditions,
        recursions$recursions
    )
    eval_env <- rlang::child_env(recursions$recursion_env)

    combs <- do.call(expand.grid, ranges)
    tbl <- vector("numeric", length = nrow(combs))
    dim(tbl) <- unlist(Map(length, ranges))
    eval_env[[tbl_name_string]] <- tbl

    for (row in seq_along(tbl)) {
        val <- eval(
            rlang::expr(rlang::UQ(update_expr)),
            combs[row, , drop = FALSE], # nolint
            eval_env
        )
        eval(rlang::expr(
            rlang::UQ(tbl_name)[rlang::UQ(row)]
            <- rlang::UQ(val)
        ), eval_env)
    }

    eval_env[[tbl_name_string]]
}
