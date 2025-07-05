# Output (ND)JSON functions: sink_ndjson, write_json, write_ndjson
# (there is only sink_ndjson() in Python Polars but there is sink_json() in
# Rust Polars).

#' Evaluate the query in streaming mode and write to a NDJSON file
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This allows streaming results that are larger than RAM to be written to disk.
#'
#' @inheritParams rlang::args_dots_empty
#' @param path A character. File path to which the file should be written.
#' @inheritParams lazyframe__sink_parquet
#' @inheritParams lazyframe__collect
#' @inheritParams pl__scan_parquet
#'
#' @return Invisibly returns the input LazyFrame
#'
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_lf(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col("drat", "mpg"))$sink_ndjson(destination)
#' jsonlite::stream_in(file(destination))
lazyframe__sink_ndjson <- function(
  path,
  ...,
  maintain_order = TRUE,
  type_coercion = TRUE,
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  collapse_joins = TRUE,
  no_optimization = FALSE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)

    target <- arg_to_sink_target(path)
    sync_on_close <- arg_match0(
      sync_on_close %||% "none",
      values = c("none", "data", "all")
    )

    lf <- set_sink_optimizations(
      self,
      type_coercion = type_coercion,
      `_type_check` = `_type_check`,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      collapse_joins = collapse_joins,
      no_optimization = no_optimization
    )

    lf <- lf$sink_json(
      target = target,
      maintain_order = maintain_order,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
      storage_options = storage_options,
      retries = retries
    )

    # TODO: support `engine`, `lazy` arguments
    wrap(lf)$collect()
  })
  invisible(self)
}

#' Serialize to JSON representation
#'
#' @param file File path to which the result will be written.
#'
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_df(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col("drat", "mpg"))$write_json(destination)
#' jsonlite::fromJSON(destination)
dataframe__write_json <- function(file) {
  wrap({
    self$`_df`$write_json(file)
    invisible(self)
  })
}

#' Serialize to newline delimited JSON representation
#'
#' @inheritParams dataframe__write_json
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_df(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col("drat", "mpg"))$write_ndjson(destination)
#' jsonlite::stream_in(file(destination))
dataframe__write_ndjson <- function(file) {
  wrap({
    # TODO: Update like https://github.com/pola-rs/polars/pull/22582
    self$lazy()$sink_ndjson(file)
    invisible(self)
  })
}
