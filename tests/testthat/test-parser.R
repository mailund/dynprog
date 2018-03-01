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

test_that("we can run a top-level parser", {
    tbl_name <- rlang::expr(1)
    recursion <- rlang::expr(2)
    ranges <- rlang::expr(3)
    mock_obj <- list(
      tbl_name = tbl_name,
      recursion = recursion,
      ranges = ranges
    )

    expect_true({
        parse(mock_obj)
        TRUE
    })
})
