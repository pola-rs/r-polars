# Output Parquet functions: sink_parquet, write_parquet

#' Evaluate the query in streaming mode and write to a Parquet file
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This allows streaming results that are larger than RAM to be written to disk.
#'
#' @inheritParams rlang::args_dots_empty
#' @param path A character. File path to which the file should be written.
#' @param compression The compression method. Must be one of:
#' * `"lz4"`: fast compression/decompression.
#' * `"uncompressed"`
#' * `"snappy"`: this guarantees that the parquet file will be compatible with
#'   older parquet readers.
#' * `"gzip"`
#' * `"lzo"`
#' * `"brotli"`
#' * `"zstd"`: good compression performance.
#' @param compression_level `NULL` or integer. The level of compression to use.
#'  Only used if method is one of `"gzip"`, `"brotli"`, or `"zstd"`. Higher
#' compression means smaller files on disk:
#'  * `"gzip"`: min-level: 0, max-level: 10.
#'  * `"brotli"`: min-level: 0, max-level: 11.
#'  * `"zstd"`: min-level: 1, max-level: 22.
#' @param statistics Whether statistics should be written to the Parquet
#' headers. Possible values:
#' * `TRUE`: enable default set of statistics (default). Some statistics may be
#'   disabled.
#' * `FALSE`: disable all statistics
#' * `"full"`: calculate and write all available statistics
#' * A list created via [parquet_statistics()] to specify which statistics to
#'   include.
#' @param row_group_size Size of the row groups in number of rows. If `NULL`
#' (default), the chunks of the DataFrame are used. Writing in smaller chunks
#' may reduce memory pressure and improve writing speeds.
#' @param data_page_size Size of the data page in bytes. If `NULL` (default), it
#' is set to 1024^2 bytes.
#' @param maintain_order Maintain the order in which data is processed. Setting
#' this to `FALSE` will be slightly faster.
#' @inheritParams lazyframe__collect
#' @inheritParams pl__scan_parquet
#'
#' @return Invisibly returns the input LazyFrame
#'
#' @examples
#' # sink table 'mtcars' from mem to parquet
#' tmpf <- tempfile()
#' as_polars_lf(mtcars)$sink_parquet(tmpf)
#'
#' # stream a query end-to-end
#' tmpf2 <- tempfile()
#' pl$scan_parquet(tmpf)$select(pl$col("cyl") * 2)$sink_parquet(tmpf2)
#'
#' # load parquet directly into a DataFrame / memory
#' pl$scan_parquet(tmpf2)$collect()
lazyframe__sink_parquet <- function(
  path,
  ...,
  compression = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd"),
  compression_level = NULL,
  statistics = TRUE,
  row_group_size = NULL,
  data_page_size = NULL,
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
    compression <- arg_match0(
      compression,
      values = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd")
    )
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
    if (is_bool(statistics)) {
      statistics <- parquet_statistics(
        min = statistics,
        max = statistics,
        distinct_count = FALSE,
        null_count = statistics
      )
    } else if (identical(statistics, "full")) {
      statistics <- parquet_statistics(
        min = TRUE,
        max = TRUE,
        distinct_count = TRUE,
        null_count = TRUE
      )
    }
    if (!inherits(statistics, "polars_parquet_statistics")) {
      abort("`statistics` must be TRUE, FALSE, 'full', or a call to `parquet_statistics()`.")
    }

    lf <- lf$sink_parquet(
      path = path,
      compression = compression,
      compression_level = compression_level,
      stat_min = statistics[["min"]],
      stat_max = statistics[["max"]],
      stat_null_count = statistics[["null_count"]],
      stat_distinct_count = statistics[["distinct_count"]],
      row_group_size = row_group_size,
      data_page_size = data_page_size,
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

#' Write to Parquet file
#'
#' @inheritParams lazyframe__sink_parquet
#' @param file File path to which the result should be written. This should be
#' a path to a directory if writing a partitioned dataset.
#' @param partition_by A character vector indicating column(s) to partition by.
#' A partitioned dataset will be written if this is specified.
#' @param partition_chunk_size_bytes Approximate size to split DataFrames within
#' a single partition when writing. Note this is calculated using the size of
#' the DataFrame in memory (the size of the output file may differ depending
#' on the file format / compression).
#'
#' @return The input DataFrame is returned.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' dat = as_polars_df(mtcars)
#'
#' # write data to a single parquet file
#' destination = withr::local_tempfile(fileext = ".parquet")
#' dat$write_parquet(destination)
#'
#' # write data to folder with a hive-partitioned structure
#' dest_folder = withr::local_tempdir()
#' dat$write_parquet(dest_folder, partition_by = c("gear", "cyl"))
#' list.files(dest_folder, recursive = TRUE)
dataframe__write_parquet <- function(
  file,
  ...,
  compression = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd"),
  compression_level = NULL,
  statistics = TRUE,
  row_group_size = NULL,
  data_page_size = NULL,
  partition_by = NULL,
  partition_chunk_size_bytes = 4294967296,
  storage_options = NULL,
  retries = 2
) {
  wrap({
    compression <- compression %||% "uncompressed"
    check_dots_empty0(...)
    check_character(partition_by, allow_null = TRUE)
    compression <- arg_match0(
      compression,
      values = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd")
    )
    if (is_bool(statistics)) {
      statistics <- parquet_statistics(
        min = statistics,
        max = statistics,
        distinct_count = FALSE,
        null_count = statistics
      )
    } else if (identical(statistics, "full")) {
      statistics <- parquet_statistics(
        min = TRUE,
        max = TRUE,
        distinct_count = TRUE,
        null_count = TRUE
      )
    }
    if (!inherits(statistics, "polars_parquet_statistics")) {
      abort("`statistics` must be TRUE, FALSE, 'full', or a call to `parquet_statistics()`.")
    }
    self$`_df`$write_parquet(
      path = file,
      compression = compression,
      compression_level = compression_level,
      stat_min = statistics[["min"]],
      stat_max = statistics[["max"]],
      stat_null_count = statistics[["null_count"]],
      stat_distinct_count = statistics[["distinct_count"]],
      row_group_size = row_group_size,
      data_page_size = data_page_size,
      partition_by = partition_by,
      partition_chunk_size_bytes = partition_chunk_size_bytes,
      storage_options = storage_options,
      retries = retries
    )
    invisible(self)
  })
}
