
get_table_name <- function(patterns) {
    p <- patterns[[1]]
    stopifnot(p[[1]] == "[")
    p[[2]]
}

make_pattern_match <- function(pattern, range_vars) {
    matches <- vector("list", length = length(range_vars))
    stopifnot(pattern[[1]] == "[")
    for (i in seq_along(matches)) {
        matches[[i]] <- rlang::call2("==", pattern[[i + 2]], range_vars[[i]])
    }
    rlang::expr(all(!!! matches))
}

make_pattern_tests <- function(patterns, range_vars) {
    tests <- vector("list", length = length(patterns))
    for (i in seq_along(tests)) {
        tests[[i]] <- make_pattern_match(patterns[[i]], range_vars)
    }
    tests
}

make_recursion_case <- function(test_expr, value_expr, continue) {
    if (rlang::is_null(continue)) {
        rlang::call2("if", test_expr, value_expr)
    } else {
        rlang::call2("if", test_expr, value_expr, continue)
    }
}

update_expr <- function(conditions, recursions) {
    continue <- NULL
    for (i in rev(seq_along(conditions))) {
        continue <- make_recursion_case(
            conditions[[i]], recursions[[i]], continue
        )
    }
    continue
}

eval_recursion <- function(tbl_name, update_expr, ranges, eval_env) {
    loop <- rlang::expr({
        combs <- do.call(expand.grid, ranges)
        rlang::UQ(tbl_name) <- vector("numeric", length = nrow(combs))
        dim(rlang::UQ(tbl_name)) <- Map(length, ranges)
        for (row in seq_along(!! tbl_name)) {
            rlang::UQ(tbl_name)[row] <- with(combs[row, , drop = FALSE], {
                rlang::UQ(update_expr)
            })
        }
        rlang::UQ(tbl_name)
    })
    eval(loop, envir = rlang::env_clone(environment(), eval_env))
}

eval_dynprog <- function(dynprog) {
    conditions <- make_pattern_tests(
        dynprog$recursion$patterns,
        Map(as.symbol, names(dynprog$ranges))
    )
    for (i in seq_along(conditions)) {
        conditions[[i]] <- rlang::call2(
            "&&", dynprog$recursion$conditions[[i]], conditions[[i]]
        )
    }
    eval_recursion(
        get_table_name(dynprog$recursions$patterns),
        update_expr(conditions, dynprog$recursions$recursions),
        dynprog$ranges,
        dynprog$recursions$recursion_env
    )
}
