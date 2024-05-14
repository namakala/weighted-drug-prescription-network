# Functions to simulate the weighting approaches

getMethodLabel <- function(method) {
  #' Get Method Names
  #'
  #' Get the name of weighting methods.
  #'
  #' @param method A character object or vector denoting the weighting methods
  #' @return Method names of the character input

  n_method <- length(method)
  
  if (n_method > 1) {
    res <- sapply(method, \(x) getMethodLabel(x), USE.NAMES = FALSE)
  } else {
    res <- dplyr::case_when(
      method == "resultant" ~ "Resultant",
      method == "product"   ~ "Product",
      method == "quotient"  ~ "Quotient",
      method == "log"       ~ "Absolute log",
      method == "inv_log"   ~ "Inverted absolute log",
      method == "density"   ~ "Density"
    )
  }

  return(res)
}

simWeight <- function() {
  #' Simulate Weight
  #'
  #' Simulate weighting approach with a given scenario.
  #'
  #' @return A tidy data frame containing simulation results

  set.seed(1810)

  ddd <- seq(0, 5, 1e-2)

  methods <- c(
    "resultant", "product", "quotient", "log", "inv_log", "density"
  )

  tbls <- lapply(methods, function(method) {
    weight <- weightEntry(n = 1, dose = ddd, method = method)

    tbl <- data.frame(
      "ddd" = ddd, "weight" = weight, "method" = getMethodLabel(method)
    )

    return(tbl)
  })

  tbl <- do.call(rbind, tbls) %>%
    tibble::tibble() %>%
    dplyr::mutate(method = factor(method, getMethodLabel(methods)))

  return(tbl)
}

