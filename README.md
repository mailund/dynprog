
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dynprog - Domain-specific language for specifying dynamic programming computations

[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![lifecycle](http://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Last-changedate](https://img.shields.io/badge/last%20change-2018--03--24-orange.svg)](/commits/master)
[![packageversion](https://img.shields.io/badge/Package%20version-0.1.0-orange.svg?style=flat-square)](commits/master)
[![Travis build
status](https://travis-ci.org/mailund/dynprog.svg?branch=master)](https://travis-ci.org/mailund/dynprog)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/mailund/dynprog?branch=master&svg=true)](https://ci.appveyor.com/project/mailund/dynprog)
[![Coverage
status](https://codecov.io/gh/mailund/dynprog/branch/master/graph/badge.svg)](https://codecov.io/github/mailund/dynprog?branch=master)
[![Coverage
status](http://coveralls.io/repos/github/mailund/dynprog/badge.svg?branch=master)](https://coveralls.io/github/mailund/dynprog?branch=master)
[![CRAN
status](http://www.r-pkg.org/badges/version/dynprog)](https://cran.r-project.org/package=dynprog)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/dynprog)](https://cran.r-project.org/package=dynprog)
[![minimal R
version](https://img.shields.io/badge/R-%E2%89%A53.1-blue.svg)](https://cran.r-project.org/)

The `dynprog` package implements a small domain-specific language for
specifying dynamic programming algorithms. It allows you to specify a
computation as a recursion and it will then use this recursion to fill
out a table and return it to you.

As a very simple example, you can specify a dynamic programming
computation of [Fibonnaci
numbers](https://en.wikipedia.org/wiki/Fibonacci_number) using

``` r
fibs <- {
    F[1] <- 1
    F[2] <- 1
    F[n] <- F[n - 1] + F[n - 2]
} %where% {
    n <- 1:10
}

fibs
#>  [1]  1  1  2  3  5  8 13 21 34 55
```

As shown in the example, the expression consists of two parts, the
first, before the `%where%` operator, describes a recursion and the
second, after the `%where%` operator, the range the variable `n` should
iterate over.

Formally, a `dynprog` expression is on the form

    DYNPROG_EXPR ::= RECURSIONS '%where%' RANGES
    RECURSIONS ::= '{' PATTERN_ASSIGNMENTS '}'
    RANGES ::= '{' RANGES_ASSIGNMENTS '}'

where `PATTERN_ASSIGNMENTS` describe the recursion and
`RANGES_ASSIGNMENTS` the variables to recurse over and the values those
variables should take.

Ranges are the simplest of the two.

    RANGES_ASSIGNMENTS ::= RANGES_ASSIGNMENT
                        |  RANGES_ASSIGNMENT ';' RANGES_ASSIGNMENTS
    RANGES_ASSIGNMENT ::= RANGE_INDEX '<-' RANGE_EXPRESSION

where `RANGE_INDEX` is just a variable and `RANGE_EXPRESSION` an
expression that should evaluate to a list or vector. You can specify
more than one variable if these are separated by `;` or newlines (the
grammar only says `;` but I am not too formal here). An example with two
range variables, of computing the [edit
distance](https://en.wikipedia.org/wiki/Edit_distance) between two
strings, is shown below.

The actual recursions are specified in `PATTERN_ASSIGNMENTS`:

    PATTERN_ASSIGNMENTS ::= PATTERN_ASSIGNMENT
                         |  PATTERN_ASSIGNMENT ';' PATTERN_ASSIGNMENTS

where

    PATTERN_ASSIGNMENT ::= PATTERN '<-' RECURSION
                        |  PATTERN '<-' RECURSION '?' CONDITION

    PATTERN ::= TABLE '[' INDICES ']'

Here, `TABLE` is just a variable and `INDICES` should be a
comma-separated lists of values/expressions or variables. When
recursions are evaluated, the range variables are tested against the
patterns. If a pattern contains a range variable as a variable, the
variable is free to take any value, but if it takes on a value, the
range variable must have that value.

To the right of the assignment in `PATTERN_ASSIGNMENTS` we have
`RECURSION`, which cna be any R expression and an optional `CONDITION`,
which should be an R expression that evaluates to a boolean value.

The semantics of the recursions are that the patterns are tested in the
order they are provided, and if both the patterns match the range
variables and the condition evaluates to `TRUE`, then the entry in the
table will get assigned the result of evaluating `RECURSION`.

For more information, see

> Mailund, T. (2018) [Domain-Specific Languages in
> R](https://amzn.to/2DRmFXb), Apress. ISBN 1484235878

## Installation

You can install the released version of `dynprog` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("dynprog")
```

and the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mailund/dynprog")
```

## Example

You can compute the
[edit-distance](https://en.wikipedia.org/wiki/Edit_distance) between two
strings like this:

``` r
x <- c("a", "b", "c")
y <- c("a", "b", "b", "c")
edit <- {
  E[1,j] <- j - 1
  E[i,1] <- i - 1
  E[i,j] <- min(
      E[i - 1,j] + 1,
      E[i,j - 1] + 1,
      E[i - 1,j - 1] + (x[i - 1] != y[j - 1])
 )
} %where% {
    i <- 1:(length(x) + 1)
    j <- 1:(length(y) + 1)
}

edit
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    0    1    2    3    4
#> [2,]    1    0    1    2    3
#> [3,]    2    1    0    1    2
#> [4,]    3    2    1    1    1
```
