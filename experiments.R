edit <- fact <- n <- i <- j <- NULL # for lint


## Factorial example ###############################

fact <- {
  fact[n] <- n * fact[n - 1] ? n > 1
  fact[n] <- 1               ? n <= 1
} %where% {n <- 1:8}

eval_dynprog(fact)


## Edit distance example ###############################

x <- strsplit("abd", "")[[1]]
y <- strsplit("abbd", "")[[1]]
edit <- {
  edit[1,j] <- j - 1
  edit[i,1] <- i - 1
  edit[i,j] <- min(edit[i - 1,j] + 1,
                   edit[i,j - 1] + 1,
                   edit[i - 1,j - 1] + (x[i - 1] != y[j - 1])) ? i > 1 && j > 1
} %where% {
    i <- 1:(length(x) + 1)
    j <- 1:(length(y) + 1)
}

eval_dynprog(edit)
