context("test-parser.R")

test_that("we can parse ranges expressions", {
    ranges <- rlang::quo({
        i <- 1:5
    })
    expect_equal(parse_ranges(ranges), list(i = 1:5))

    ranges <- rlang::quo({
        i <- 1:5
        j <- 1:9
    })
    expect_equal(parse_ranges(ranges), list(i = 1:5, j = 1:9))
})

test_that("we can parse recursion expressions", {
    n <- fact <- NULL # to avoid lint complains
    recursions <- rlang::quo({
        fact[n] <- n * fact[n - 1]  ?  n >= 1
        fact[n] <- 1                ?  n < 1
    })

    parsed <- parse_recursion(recursions)
    expect_equal(length(parsed), 4)
    expect_equal(length(parsed$patterns), 2)
    expect_equal(length(parsed$conditions), 2)
    expect_equal(length(parsed$recursions), 2)

    expect_equal(parsed$recursion_env, rlang::get_env(recursions))

    expect_equal(parsed$patterns[[1]], rlang::expr(fact[n]))
    expect_equal(parsed$patterns[[2]], rlang::expr(fact[n]))

    expect_equal(parsed$conditions[[1]], rlang::expr(n >= 1))
    expect_equal(parsed$conditions[[2]], rlang::expr(n < 1))

    expect_equal(parsed$recursions[[1]], rlang::expr(n * fact[n - 1]))
    expect_equal(parsed$recursions[[2]], rlang::expr(1))

    # Try a different order of cases and one without a guard
    recursions <- rlang::quo({
        fact[n] <- 1 ?  n < 1
        fact[n] <- n * fact[n - 1]
    })

    parsed <- parse_recursion(recursions)
    expect_equal(length(parsed), 4)
    expect_equal(length(parsed$patterns), 2)
    expect_equal(length(parsed$conditions), 2)
    expect_equal(length(parsed$recursions), 2)

    expect_equal(parsed$recursion_env, rlang::get_env(recursions))

    expect_equal(parsed$patterns[[1]], rlang::expr(fact[n]))
    expect_equal(parsed$patterns[[2]], rlang::expr(fact[n]))

    expect_equal(parsed$conditions[[1]], rlang::expr(n < 1))
    expect_equal(parsed$conditions[[2]], rlang::expr(TRUE))

    expect_equal(parsed$recursions[[1]], rlang::expr(1))
    expect_equal(parsed$recursions[[2]], rlang::expr(n * fact[n - 1]))
})


test_that("we can run a top-level parser", {
    skip("Not ready for this yet")
})
