get_table_name <- function(patterns) {
    p <- patterns[[1]]
    stopifnot(p[[1]] == "[")
    p[[2]]
}

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
make_condition_checks <- function(
    ranges,
    patterns,
    conditions,
    recursions
) {
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

make_recursion_case <- function(
    test_expr,
    value_expr,
    continue
) {
    if (rlang::is_null(continue)) {
        rlang::call2("if", test_expr, value_expr)
    } else {
        rlang::call2("if", test_expr, value_expr, continue)
    }
}

make_update_expr <- function(
    ranges,
    patterns,
    conditions,
    recursions
) {
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
    dim(tbl) <- Map(length, ranges)
    eval_env[[tbl_name_string]] <- tbl

    for (row in seq_along(tbl)) {
        val <- eval(
            rlang::expr(rlang::UQ(update_expr)),
            combs[row, , drop = FALSE],
            eval_env
        )
        eval(rlang::expr(
            rlang::UQ(tbl_name)[rlang::UQ(row)]
            <- rlang::UQ(val)
        ), eval_env)
    }

    eval_env[[tbl_name_string]]
}
