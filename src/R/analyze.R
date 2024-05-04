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

getWeightICC <- function(metrics) {
  #' Get Weight ICC
  #'
  #' Calculate the intraclass correlation for all weighting approaches.
  #'
  #' @param metrics A tidy data frame containing graph metrics obtained from
  #' different weighting scenarios
  #' @return A tidy data frame of ICC measures

  tbl <- pivotMetrics(metrics) %>%
    tidyr::pivot_wider(names_from = method, values_from = value)

  tbl_icc <- tbl %>%
    tidyr::nest(data = c(date, base:inv_log)) %>%
    dplyr::mutate(
      "mtx" = purrr::map(data, ~ subset(.x, select = -date) %>% as.matrix()),
      "res" = purrr::map(
        mtx,
        function(x) {
          psych::ICC(x) %>%
            extract2("results") %>%
            dplyr::mutate("type" = rownames(.))
        }
      )
    )

  res <- tbl_icc %>%
    tidyr::unnest(res, names_sep = "_") %>%
    subset(select = -c(data, mtx))

  return(res)
}
