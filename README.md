
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dynprog - Domain-specific language for specifying dynamic programming computations

[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![lifecycle](http://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Last-changedate](https://img.shields.io/badge/last%20change-2018--03--17-orange.svg)](/commits/master)
[![packageversion](https://img.shields.io/badge/Package%20version-0.0.0.9000-orange.svg?style=flat-square)](commits/master)

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

The goal of dynprog is to …

## Installation

You can install the released version of `dynprog` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("dynprog")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mailund/dynprog")
```

## Example

``` r
library(dynprog)

x <- c("a", "b", "c")
y <- c("a", "b", "b", "c")
edit <- {
  E[1,j] <- j - 1
  E[i,1] <- i - 1
  E[i,j] <- min(
      E[i - 1,j] + 1,
      E[i,j - 1] + 1,
      E[i - 1,j - 1] + (x[i - 1] != y[j - 1])
 ) ? i > 1 && j > 1
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
