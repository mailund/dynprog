context("test-dsl.R")

test_that("we can evaluate `fact`", {
    ## Factorial example ###############################

    # nolint start
    fact <- {
        fact[n] <- n * fact[n - 1] ? n > 1
        fact[n] <- 1               ? n <= 1
    } %where% {
        n <- 1:8
    }
    # nolint end

    expect_equal(as.vector(fact), c(1, 2, 6, 24, 120, 720, 5040, 40320))
})


test_that("we can evaluate `edit`", {

    ## Edit distance example ###############################
    x <- strsplit("abd", "")[[1]]
    y <- strsplit("abbd", "")[[1]]
    # nolint start
    edit <- {
        edit[1, j] <- j - 1
        edit[i, 1] <- i - 1
        edit[i, j] <- min(
            edit[i - 1, j] + 1,
            edit[i, j - 1] + 1,
            edit[i - 1, j - 1] + (x[i - 1] != y[j - 1])
        ) ? i > 1 && j > 1
    } %where% {
        i <- 1:(length(x) + 1)
        j <- 1:(length(y) + 1)
    }
    # nolint end

    expected <- matrix(c(
        0, 1, 2, 3, 4,
        1, 0, 1, 2, 3,
        2, 1, 0, 1, 2,
        3, 2, 1, 1, 1
    ), nrow = length(x) + 1, ncol = length(y) + 1, byrow = TRUE)
    dim(expected) <- c(i = length(x) + 1, j = length(y) + 1)

    expect_equal(edit, expected)
})
