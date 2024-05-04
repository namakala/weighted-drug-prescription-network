# Functions to clean the data

getNeuroMeds <- function() {
  #' Get Nervous System Medications
  #'
  #' This function will take no parameter and generate a list of nervous system
  #' medication, as indicated by code `N0x` by the WHOCC ATC code.
  #'
  #' @return A vector of nervous system medications, including psychopharmaca
  res <- c(
    "Anesthetic",
    "Analgesics",
    "Antiepileptics",
    "Antiparkinson",
    "Antipsychotics",
    "Anxiolytics",
    "Hypnotics and sedatives",
    "Antidepressants",
    "Psychostimulants",
    "Psycholeptics + psychoanaleptics",
    "Antidementia",
    "Other nervous system drugs"
  )

  return(res)
}

genLabel <- function() {
  #' Generate Matrix Label
  #'
  #' Generate label for matrix dimension, the label is set to ATC group name by
  #' default
  #'
  #' @return A vector of character object
  label <- c(
    "Alimentary and metabolism",
    "Blood",
    "Cardiovascular",
    "Dermatologicals",
    "Genitourinary",
    "Systemic hormonal",
    "Systemic anti-infectives",
    "Antineoplastics",
    "Musculoskeletal",
    getNeuroMeds(),
    "Antiparasitics",
    "Respiratory",
    "Sensory",
    "Others"
  )

  return(label)
}

bindMetrics <- function(metrics) {
  #' Bind Metrics
  #'
  #' Row-bind metrics obtained from all weighting approaches.
  #'
  #' @param metrics A combined data frame of graph metrics
  #' @param A row-bound data frame containing metrics from all weighting
  #' approaches

  res <- do.call(rbind, metrics) %>%
    subset(.$eigen != 0 & .$degree != 0 & .$strength != 0)

  return(res)
}

pivotMetrics <- function(metrics) {
  #' Pivot Metrics
  #'
  #' Pivot the shape of metrics to a long data frame.
  #'
  #' @param metrics A tidy data frame containing graph metrics obtained from
  #' different weighting scenarios
  #' @return A tidy long data frame

  sub_tbl <- metrics %>%
    subset(select = -c(degree, pagerank)) %>%
    tidyr::pivot_longer(eigen:strength, names_to = "metric")

  return(sub_tbl)
}

