# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "crew")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)

# Source user-defined functions
funs <- list.files("src/R", pattern = "*.R", full.name = TRUE) %>%
  lapply(source)

# Set option for targets
tar_option_set(
  packages   = pkgs,
  error      = "continue",
  memory     = "transient",
  controller = crew_controller_local(worker = 4),
  storage    = "worker",
  retrieval  = "worker",
  garbage_collection = TRUE
)

seed <- 1810

# Set parameters for branching
method <- c("base", "resultant", "product", "quotient", "log", "inv_log", "density")
type   <- c("additive", "multiplicative")

# Set the analysis pipeline
list(

  # List and read the file paths
  tar_target(fpath, lsData(pattern = "*csv")),
  tar_target(tbls, readData(fpath), pattern = fpath, iteration = "list"),
  
  # Visualize the simulated weigting approahces
  tar_target(plt_sim, vizSimWeight()),

  # Generate graph objects
  tar_map(
    unlist = FALSE,
    values = tidyr::expand_grid(method, type),
    tar_target(graph, mkGraph(tbls, method = method, type = type), pattern = map(tbls), iteration = "list"),
    tar_target(raw_metrics, getMetrics(graph), pattern = map(graph), iteration = "list"),
    tar_target(list_metrics, set_names(raw_metrics, names(fpath))),
    tar_target(metrics, combineMetrics(list_metrics) %>% inset(c("method", "type"), value = list(method, type)))
  ),

  # Combine graph metrics from all scenarios
  tar_target(
    metrics,
    bindMetrics(
      list(
        metrics_base_additive,
        metrics_resultant_additive,
        metrics_product_additive,
        metrics_quotient_additive,
        metrics_log_additive,
        metrics_inv_log_additive,
        metrics_density_additive,
        metrics_base_multiplicative,
        metrics_resultant_multiplicative,
        metrics_product_multiplicative,
        metrics_quotient_multiplicative,
        metrics_log_multiplicative,
        metrics_inv_log_multiplicative,
        metrics_density_multiplicative
      )
    )
  ),

  # Summarize the metrics and fit intraclass correlation models
  tar_target(metrics_summary, summarizeWeight(metrics)),
  tar_target(metrics_desc, describeWeight(metrics)),
  tar_target(metrics_cor, mapMetricsFun(metrics, fitCor)),
  tar_target(metrics_icc, mapMetricsFun(metrics, fitICC)),

  # Generate documentation
  tar_quarto(article, "docs/article.qmd"),
  tar_quarto(readme, "README.qmd", priority = 0)

)
