#' Evaluate the query and call a user-defined function for every ready batch
#'
#' `r lifecycle::badge("experimental")`
#' This allows streaming results that are larger than RAM in certain cases.
#' Note that this method is much slower than native sinks.
#' Only use it if you cannot implement your logic otherwise.
#'
#' `<lazyframe>$sink_batches()` is a shortcut for `<lazyframe>$lazy_sink_batches()$collect()`.
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__collect
#' @inheritParams lazyframe__sink_parquet
#' @param lambda A function that will receive a [DataFrame] as the first argument and
#'   called for side effects (e.g., writing to a file).
#'   If the function returns `TRUE` and using the streaming engine,
#'   this signals that no more results are needed, allowing for early stopping.
#' @param chunk_size A positive integer or `NULL` (default).
#'   The number of rows that are buffered before the callback is called.
#' @return
#' - `<lazyframe>$sink_batches()` returns `NULL` invisibly.
#' - `<lazyframe>$lazy_sink_batches()` returns a new [LazyFrame].
#' @examples
#' lf <- as_polars_lf(mtcars)
#' lf$sink_batches(\(df) print(df), chunk_size = 10)
#'
#' # Early stopping by returning TRUE from the function
#' lf$sort("cyl")$sink_batches(
#'   \(df) {
#'     print(df)
#'     if (max(df[["cyl"]])$to_r_vector() > 4) TRUE else FALSE
#'   },
#'   chunk_size = 10
#' )
lazyframe__sink_batches <- function(
  lambda,
  ...,
  chunk_size = NULL,
  maintain_order = TRUE,
  engine = c("auto", "in-memory", "streaming")
) {
  wrap({
    self$lazy_sink_batches(
      lambda,
      ...,
      chunk_size = chunk_size,
      maintain_order = maintain_order
    )$collect(
      engine = engine
    )
    # TODO: support `optimizations` argument
  })
  invisible()
}

#' @rdname lazyframe__sink_batches
lazyframe__lazy_sink_batches <- function(
  lambda,
  ...,
  chunk_size = NULL,
  maintain_order = TRUE
) {
  wrap({
    check_dots_empty0(...)
    lambda <- as_function(lambda)

    self$`_ldf`$sink_batches(
      lambda = function(df) {
        lambda(wrap(.savvy_wrap_PlRDataFrame(df))) |>
          isTRUE()
      },
      chunk_size = chunk_size,
      maintain_order = maintain_order
    )
  })
}
