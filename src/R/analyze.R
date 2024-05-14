# Functions to analyze the appropriate weighting approach

summarizeWeight <- function(metrics) {
  #' Summarize Weight
  #'
  #' Generate a statistical summary of each weighting approach.
  #'
  #' @param metrics A tidy data frame containing graph metrics obtained from
  #' different weighting scenarios
  #' @return A tidy data frame containing the statistical summary of each
  #' approach

  res <- metrics %>%
    pivotMetrics() %>%
    dplyr::group_by(type, group, metric, method) %>%
    dplyr::summarize(
      "mean" = mean(value, na.rm = TRUE), "sd" = sd(value, na.rm = TRUE)
    ) %>%
    dplyr::ungroup()

  return(res)
}

describeWeight <- function(metrics) {
  #' Describe Weight
  #'
  #' Describe weighting method compared to the baseline approach. An ANOVA
  #' model is first fitted, followed by Tukey HSD test.
  #'
  #' @param metrics A tidy data frame containing graph metrics obtained from
  #' different weighting scenarios
  #' @return A tidy data frame of mean difference

  res <- metrics %>%
    pivotMetrics() %>%
    tidyr::nest(data = c(date, method, value)) %>%
    dplyr::mutate(
      "mean" = purrr::map(
        data, ~ aov(value ~ method, data = .x) %>% TukeyHSD() %>% broom::tidy()
      )
    ) %>%
    tidyr::unnest(mean) %>%
    subset(select = -c(data, term, null.value))

  return(res)
}

fitICC <- function(mtx, ...) {
  #' Fit Intraclass Correlation
  #'
  #' Fit an intraclass correlation model given an input matrix. All elements of
  #' the input matrix should be numeric.
  #'
  #' @param mtx A numeric input matrix
  #' @inheritDotParams psych::ICC
  #' @return A tidy data frame

  res <- psych::ICC(mtx) %>%
    extract2("results") %>%
    dplyr::mutate("type" = gsub(x = rownames(.), "_", " "))

  return(res)
}

fitCor <- function(mtx, ...) {
  #' Fit Correlation
  #'
  #' Calculate the correlation of a given matrix. The matrix should be derived
  #' from the graph metrics data frame.
  #'
  #' @param mtx A numeric input matrix
  #' @inheritDotParams stats::cor
  #' @return A tidy data frame

  multi <- ncol(mtx) > 2

  if (multi) {

    res <- cor(mtx, use = "complete.obs", ...) %>%
      {.[1, -1]} %>%
      as.list() %>%
      data.frame()

  } else {

    x   <- mtx[, 1]
    y   <- mtx[, 2]
    res <- cor.test(x, y, na.action = "omit.na", ...) %>%
      broom::tidy() %>%
      extract(c("conf.low", "conf.high"))

  }

  return(res)
}

mapMetricsFun <- function(metrics, FUN) {
  #' Map Functions to Metrics
  #'
  #' Map functions to calculate statistics on a data frame containing the
  #' graph metrics for all weighting approaches.
  #'
  #' @param metrics A tidy data frame containing graph metrics obtained from
  #' different weighting scenarios
  #' @param FUN A function to measure the statistics
  #' @return A tidy data frame of statistical results

  tbl <- pivotMetrics(metrics) %>%
    tidyr::pivot_wider(names_from = method, values_from = value)

  tbl_stat <- tbl %>%
    tidyr::nest(data = c(date, base:inv_log)) %>%
    dplyr::mutate(
      "mtx"    = purrr::map(data, ~ subset(.x, select = -date) %>% as.matrix()),
      "res"    = purrr::map(mtx,  ~ FUN(.x)),
      "res_12" = purrr::map(mtx,  ~ FUN(.x[, c(1, 2)])), # Base:resultant
      "res_13" = purrr::map(mtx,  ~ FUN(.x[, c(1, 3)])), # Base:product
      "res_14" = purrr::map(mtx,  ~ FUN(.x[, c(1, 4)])), # Base:quotient
      "res_15" = purrr::map(mtx,  ~ FUN(.x[, c(1, 5)])), # Base:log
      "res_16" = purrr::map(mtx,  ~ FUN(.x[, c(1, 6)])), # Base:inv_log
      "res_17" = purrr::map(mtx,  ~ FUN(.x[, c(1, 7)]))  # Base:density
    )

  res <- tbl_stat %>%
    tidyr::unnest(dplyr::starts_with("res"), names_sep = "_") %>%
    subset(select = -c(data, mtx))

  return(res)
}
