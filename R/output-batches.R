#' Evaluate the query and call a user-defined function for every ready batch
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' This allows streaming results that are larger than RAM in certain cases.
#'
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
#'
#' # Each batch is a Polars DataFrame
#' lf$sink_batches(\(df) print(df), chunk_size = 10)
#'
#' # We can stop reading the batches by returning `TRUE`:
#' lf$sort("cyl")$sink_batches(
#'   \(df) {
#'     print(df)
#'
#'     # We want to stop if this condition is respected:
#'     max(df[["cyl"]])$to_r_vector() > 4
#'   },
#'   chunk_size = 10
#' )
#'
#' # One usecase for this function is to export larger-than-RAM data to file
#' # formats for which polars doesn't provide a writer out of the box.
#' # The example below writes a LazyFrame by batches to a CSV file for the
#' # sake of the example, but one could replace `write.csv()` by
#' # `haven::write_dta()`, `saveRDS()`, or other functions.
#' #
#' # Note that if `chunk_size` is missing, then Polars tries to compute it
#' # automatically. However, depending on the characteristics of the data (for
#' # instance very long string elements), this can lead to out-of-memory errors.
#' # It is therefore recommended to set `chunk_size` manually.
#'
#' withr::with_tempdir({
#'   file_idx <- 1
#'
#'   lf$sink_batches(
#'     \(df) {
#'       dest <- paste0("file_", file_idx, ".csv")
#'       cat(sprintf("Writing %s rows to %s\n", nrow(df), dest))
#'       write.csv(as.data.frame(df), dest)
#'       file_idx <<- file_idx + 1
#'     }
#'   )
#'
#'   cat("\nFiles in the directory:\n")
#'   cat(list.files("."))
#'   cat("\n\n")
#'
#'   pl$read_csv(".")
#' })
#'
#' # The number of rows in each chunk can be adjusted with `chunk_size`.
#' withr::with_tempdir({
#'   file_idx <- 1
#'
#'   lf$sink_batches(
#'     \(df) {
#'       dest <- paste0("file_", file_idx, ".csv")
#'       cat(sprintf("Writing %s rows to %s\n", nrow(df), dest))
#'       write.csv(as.data.frame(df), dest)
#'       file_idx <<- file_idx + 1
#'     }
#'   )
#'
#'   cat("\nFiles in the directory:\n")
#'   cat(list.files("."))
#' })
#'
#' # To avoid manually creating paths and incrementing `file_idx` in the
#' # anonymous function, we can use function factories:
#' withr::with_tempdir({
#'   writer_factory <- function(dir) {
#'     i <- 0
#'     function(df) {
#'       i <<- i + 1
#'       dest <- file.path(dir, sprintf("%03d.csv", i))
#'       cat(sprintf("Writing %s rows to %s\n", nrow(df), dest))
#'       as.data.frame(df) |>
#'         write.csv(dest, row.names = FALSE)
#'     }
#'   }
#'
#'   writer <- writer_factory(".")
#'
#'   lf$sink_batches(writer, chunk_size = 10)
#'
#'   cat("\nFiles in the directory:\n")
#'   cat(list.files("."))
#' })
lazyframe__sink_batches <- function(
  lambda,
  ...,
  chunk_size = NULL,
  maintain_order = TRUE,
  engine = c("auto", "in-memory", "streaming"),
  optimizations = pl$QueryOptFlags()
) {
  wrap({
    check_dots_empty0(...)

    self$lazy_sink_batches(
      lambda,
      chunk_size = chunk_size,
      maintain_order = maintain_order
    )$collect(engine = engine, optimizations = optimizations)
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
