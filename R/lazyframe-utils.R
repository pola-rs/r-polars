make_profile_plot <- function(data, truncate_nodes) {
  check_installed("ggplot2")
  timings <- as.data.frame(data[[2]])
  timings$node <- factor(timings$node, levels = unique(timings$node))
  total_timing <- max(timings$end)
  if (total_timing > 10000000) {
    unit <- "s"
    total_timing <- paste0(total_timing / 1000000, "s")
    timings$start <- timings$start / 1000000
    timings$end <- timings$end / 1000000
  } else if (total_timing > 10000) {
    unit <- "ms"
    total_timing <- paste0(total_timing / 1000, "ms")
    timings$start <- timings$start / 1000
    timings$end <- timings$end / 1000
  } else {
    unit <- "\U00B5s"
    total_timing <- paste0(total_timing, "\U00B5s")
  }

  # for some reason, there's an error if I use rlang::.data directly in aes()
  .data <- rlang::.data

  plot <- ggplot2::ggplot(
    timings,
    ggplot2::aes(
      x = .data[["start"]],
      xend = .data[["end"]],
      y = .data[["node"]],
      yend = .data[["node"]]
    )
  ) +
    ggplot2::geom_segment(linewidth = 6) +
    ggplot2::xlab(
      paste0("Node duration in ", unit, ". Total duration: ", total_timing)
    ) +
    ggplot2::ylab(NULL) +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size = 12)
    )

  if (truncate_nodes > 0) {
    plot <- plot +
      ggplot2::scale_y_discrete(
        labels = rev(paste0(strtrim(timings$node, truncate_nodes), "...")),
        limits = rev
      )
  } else {
    plot <- plot +
      ggplot2::scale_y_discrete(
        limits = rev
      )
  }

  # do not show the plot if we're running testthat
  if (!identical(Sys.getenv("TESTTHAT"), "true")) {
    print(plot)
  }
  plot
}

#' @rdname lazyframe__sink_parquet
#' @param min Include stats on the minimum values in the column.
#' @param max Include stats on the maximum values in the column.
#' @param distinct_count Include stats on the number of distinct values in the
#' column.
#' @param null_count Include stats on the number of null values in the column.
#'
#' @export
parquet_statistics <- function(
  ...,
  min = TRUE,
  max = TRUE,
  distinct_count = TRUE,
  null_count = TRUE
) {
  check_dots_empty0(...)
  check_bool(min)
  check_bool(max)
  check_bool(distinct_count)
  check_bool(null_count)

  structure(
    list(
      min = min,
      max = max,
      distinct_count = distinct_count,
      null_count = null_count
    ),
    class = c("polars_parquet_statistics", "list")
  )
}

set_sink_optimizations <- function(
  self,
  type_coercion = TRUE,
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  collapse_joins = TRUE,
  no_optimization = FALSE,
  `_check_order` = TRUE
) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown <- FALSE
    projection_pushdown <- FALSE
    slice_pushdown <- FALSE
    `_check_order` <- FALSE
  }

  self$`_ldf`$optimization_toggle(
    type_coercion = type_coercion,
    `_type_check` = `_type_check`,
    predicate_pushdown = predicate_pushdown,
    projection_pushdown = projection_pushdown,
    simplify_expression = simplify_expression,
    slice_pushdown = slice_pushdown,
    comm_subplan_elim = FALSE,
    comm_subexpr_elim = FALSE,
    cluster_with_columns = FALSE,
    collapse_joins = collapse_joins,
    streaming = TRUE,
    `_eager` = FALSE,
    `_check_order` = `_check_order`
  )
}

#' Transforms raw percentiles into our preferred format, adding the 50th
#' percentile.
#' Raises an error if the percentile sequence is invalid (e.g. outside the
#' range [0, 1]).
#' @noRd
parse_percentiles <- function(percentiles, inject_median = FALSE) {
  if (!all(percentiles >= 0 & percentiles <= 1)) {
    abort("`percentiles` must all be in the range [0, 1].")
  }
  sub_50_percentiles <- percentiles[percentiles < 50] |>
    sort()
  at_or_above_50_percentiles <- percentiles[percentiles >= 50] |>
    sort()
  if (
    isTRUE(inject_median) &&
      (length(at_or_above_50_percentiles) == 0 || at_or_above_50_percentiles[1] != 0.5)
  ) {
    at_or_above_50_percentiles <- c(0.5, at_or_above_50_percentiles)
  }

  c(sub_50_percentiles, at_or_above_50_percentiles)
}
