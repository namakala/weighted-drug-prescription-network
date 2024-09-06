# Functions to prepare for a graph object

regularize <- function(x, type = "rescale") {
  #' Min-Max Regularization
  #'
  #' Perform a regularization to a given set of numbers
  #'
  #' @param x A numeric vector
  #' @param type The type of regularization, support either `clean`, `minmax`,
  #' or `rescale`
  #' @return A regularized numeric vector

  if (length(x) == 1) {
    return(x)
  }

  clean_x <- ifelse(x == Inf, 0.11, x)
  minval  <- min(clean_x, na.rm = TRUE)
  maxval  <- max(clean_x, na.rm = TRUE)

  res <- dplyr::case_when(
    type == "clean"   ~ clean_x,
    type == "minmax"  ~ {clean_x - minval} / {maxval - minval},
    type == "rescale" ~ clean_x / maxval
  )

  return(res)
}

weightEntry <- function(n, dose = NULL, method = "density") {
  #' Weigh Entry
  #'
  #' Assign weight to the drug-prescription entry.
  #'
  #' @param n The number of claim for the entry in an `atc_tbl`
  #' @param dose The dose of the entry in an `atc_tbl`
  #' @param method The weighting method, support either `resultant`, `product`,
  #' `quotient`, `log`, `inv_log`, and `density`
  #' @return An array of weighted entry

  # Return only `n` for the baseline weight
  if (is.null(dose) | is.null(method) | method %in% c("none", "base")) {
    return(n)
  }

  # Modify DDD = 0.1 to prevent Inf
  mod_dose <- ifelse(dose == 0.1, 0.11, dose)

  # Transform the weight as diff of log base 10
  trans <- abs(n - abs(log(mod_dose, base = 10))) %>% regularize()

  # Set special rules for inverted log weights to prevent Inf
  inv_log <- {abs(n - trans) + n} %>% regularize(type = "clean")

  # Set weighing methods
  res <- dplyr::case_when(
    method == "resultant" ~ (n + dose) / 2,
    method == "product"   ~ n * dose,
    method == "quotient"  ~ n / dose,
    method == "log"       ~ trans,
    method == "inv_log"   ~ inv_log,
    method == "density"   ~ {n + dnorm(dose, mean = n, sd = n / 3)} %>% regularize()
  )

  return(res)
}

pairByRow <- function(atc_tbl, ..., method = "density", type = "additive") {
  #' Make Pairwise Row Combination
  #'
  #' Create a pairwise combination for each row of the input data frame.
  #' Pairwise combination is created by indexing each row number. Indexed row
  #' entries are then paired to generate a `from` and `to` field combinations.
  #' This combination is intended for generating a graph object (see
  #' `igraph::graph.data.frame`).
  #'
  #' @param atc_tbl A data frame containing split ATC
  #' @param method Method to weight to pass on to the `weightEntry` function
  #' @param type Type of weighing, support either `additive` or
  #' `multiplicative`
  #' @inheritDotParams base::aggregate
  #' @return A data frame for generating graph object, containing number of
  #' edges and its weight

  # Set weight
  atc_tbl %<>%
    inset2(
      "weight",
      value = ifelse(.$dose != 0, weightEntry(.$n, .$dose, method = method), .$n)
    )

  # Get the combination index
  if (nrow(atc_tbl) > 1) {
    id   <- RcppAlgos::comboGeneral(nrow(atc_tbl), 2, nThreads = 2)
    from <- id[, 1]
    to   <- id[, 2]
  } else {
    from <- to <- 1
  }

  tbl_from <- atc_tbl[from, ] %>% set_names(paste(names(.), "from", sep = "_"))
  tbl_to   <- atc_tbl[to, ]   %>% set_names(paste(names(.), "to",   sep = "_"))

  # Combine the column based on the index
  if (type == "additive") {
    dyad_weight <- {tbl_from$weight_from + tbl_to$weight_to} / 2
  } else if (type == "multiplicative") {
    dyad_weight <- tbl_from$weight_from * tbl_to$weight_to
  }

  tbl_pair <- cbind(tbl_from, tbl_to) %>% inset2("weight", value = dyad_weight)

  # Aggregate the metrics
  tbl_agg <- aggregate(weight ~ group_from + group_to, data = tbl_pair, ...) %>%
    set_names(c("from", "to", "weight"))
  
  return(tbl_agg)
}

mkMatrix <- function(atc_tbl, ..., method = "density", type = "additive") {
  #' Make Matrix
  #'
  #' Create an adjacency matrix from a split ATC data frame
  #'
  #' @param atc_tbl A data frame containing split ATC entries
  #' @param ... Parameter passed on to `pairByRow`
  #' @param method Method to weight to pass on to the `weightEntry` function
  #' @param type Type of weighing, support either `additive` or
  #' `multiplicative`
  #' @return A sparse adjacency matrix

  # Generate parameters to create an empty matrix
  label <- genLabel()
  size  <- length(label)

  # Set the group as factor
  atc_tbl %<>%
    inset2("group",  value = factor(.$group, levels = label))

  # Get a list of user IDs
  uids <- unique(atc_tbl$id) %>% set_names(., .)

  # Iterate the row entry of ATC data frame
  mtxs <- lapply(uids, function(uid) {
    sub_tbl <- atc_tbl %>% subset(.$id == uid)
    groups  <- sub_tbl$group
    agg_tbl <- pairByRow(sub_tbl, ..., method = method, type = type)

    # Generate an empty matrix as a placeholder, set locators for rows and cols
    mtx <- Matrix::Matrix(
      0, nrow = size, ncol = size,
      dimnames = label %>% list(., .),
      sparse = TRUE
    )

    loc <- with(agg_tbl, list("row" = from, "col" = to))

    # Fill in the matrix
    mtx[loc$row, loc$col] <- agg_tbl$weight

    return(mtx)
  })
   
  mtx <- Reduce(\(x, y) x + y, mtxs)

  return(mtx)
}

mkGraph <- function(atc_tbl, method = "density", type = "additive") {
  #' Generate Graph Object
  #'
  #' Create a graph object from a pairwise combination data frame
  #'
  #' @param atc_tbl A data frame containing split ATC entries
  #' @param method Method to weight to pass on to the `weightEntry` function
  #' @param type Type of weighing, support either `additive` or
  #' `multiplicative`
  #' @return Medication graph from pairwises of ATC

  # Discard entries which become the turning point with `method = "log"`
  tbl <- atc_tbl %>% subset(.$dose >= 0.1 & .$dose < 10)

  # Generate the graph
  graph <- tryCatch(
    {
      mtx <- mkMatrix(tbl, sum, method = method, type = type)
      igraph::graph_from_adjacency_matrix(
        mtx, weighted = TRUE, mode = "directed"
      ) %>%
        igraph::as.undirected(mode = "collapse")
    },
    error = \(e) NULL
  )

  return(graph)
}

getMetrics <- function(graph) {
  #' Calculate Graph Metrics
  #'
  #' Calculate graph metrics from a given medication graphs
  #' @param graph Medication graph from pairwises of ATC
  #' @return A data frame containing node names and its metrics

  is_graph <- igraph::is_igraph(graph)

  if (is_graph) {
    degree   <- igraph::degree(graph)
    strength <- igraph::strength(graph)
    pagerank <- igraph::page_rank(graph) %>% extract2("vector")
    eigen    <- igraph::eigen_centrality(graph) %>%
      extract2("vector") %>%
      divide_by(sum(.))

    metrics <- data.frame(eigen, pagerank, degree, strength) %>%
      tibble::add_column("group" = rownames(.), .before = 1)

    return(metrics)
  }

  return(graph)
}

combineMetrics <- function(list_metrics) {
  #' Aggregate Metrics
  #'
  #' Combine a list of metrics into one data frame. This function assumes that
  #' the list is grouped by date.
  #'
  #' @param list_metrics List of graph metrics
  #' @return A combined data frame of graph metrics
  is_null <- sapply(list_metrics, is.null)
  list_metrics %<>% extract(!is_null)

  tbl <- do.call(rbind, list_metrics) %>%
    tibble::add_column(
      "date" = gsub(x = rownames(.), "^.*_|\\..*", "") %>% as.Date(),
      .after = 1
    ) %>%
    tibble::tibble()

  return(tbl)
}
