# Output Parquet functions: sink_parquet, write_parquet

#' Evaluate the query in streaming mode and write to a Parquet file
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This allows streaming results that are larger than RAM to be written to disk.
#'
#' - `<lazyframe>$lazy_sink_*()` don't write directly to the output file(s) until
#'   [`$collect()`][lazyframe__collect()] is called.
#'   This is useful if you want to save a query to review or run later.
#' - `<lazyframe>$sink_*()` write directly to the output file(s) (they are shortcuts for
#'   `<lazyframe>$lazy_sink_*()$collect()`).
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__collect
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
#'   Only used if method is one of `"gzip"`, `"brotli"`, or `"zstd"`. Higher
#'   compression means smaller files on disk:
#'
#'   - `"gzip"`: min-level: 0, max-level: 9, default: 6.
#'   - `"brotli"`: min-level: 0, max-level: 11, default: 1.
#'   - `"zstd"`: min-level: 1, max-level: 22, default: 3.
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
#' @param sync_on_close Sync to disk when before closing a file. Must be one of:
#' * `"none"`: does not sync;
#' * `"data"`: syncs the file contents;
#' * `"all"`: syncs the file contents and metadata.
#' @param mkdir Recursively create all the directories in the path.
#'
#' @return
#' - `<lazyframe>$sink_*()` returns `NULL` invisibly.
#' - `<lazyframe>$lazy_sink_*()` returns a new [LazyFrame].
#'
#' @examples
#' # Sink table 'mtcars' from mem to parquet
#' tmpf <- tempfile()
#' as_polars_lf(mtcars)$sink_parquet(tmpf)
#'
#' # Create a query that can be run in streaming end-to-end
#' tmpf2 <- tempfile()
#' lf <- pl$scan_parquet(tmpf)$select(pl$col("cyl") * 2)$lazy_sink_parquet(tmpf2)
#' lf$explain() |>
#'   cat()
#'
#' # Execute the query and write to disk
#' lf$collect()
#'
#' # Load parquet directly into a DataFrame / memory
#' pl$read_parquet(tmpf2)
lazyframe__sink_parquet <- function(
  path,
  ...,
  compression = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd"),
  compression_level = NULL,
  statistics = TRUE,
  row_group_size = NULL,
  data_page_size = NULL,
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE,
  engine = c("auto", "in-memory", "streaming"),
  optimizations = pl$QueryOptFlags(),
  type_coercion = deprecated(),
  predicate_pushdown = deprecated(),
  projection_pushdown = deprecated(),
  simplify_expression = deprecated(),
  slice_pushdown = deprecated(),
  collapse_joins = deprecated(),
  no_optimization = deprecated()
) {
  wrap({
    check_dots_empty0(...)

    self$lazy_sink_parquet(
      path = path,
      compression = compression,
      compression_level = compression_level,
      statistics = statistics,
      row_group_size = row_group_size,
      data_page_size = data_page_size,
      maintain_order = maintain_order,
      storage_options = storage_options,
      retries = retries,
      sync_on_close = sync_on_close,
      mkdir = mkdir
    )$collect(
      engine = engine,
      optimizations = optimizations,
      type_coercion = type_coercion,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      collapse_joins = collapse_joins,
      no_optimization = no_optimization
    )
  })
  invisible(NULL)
}

#' @rdname lazyframe__sink_parquet
lazyframe__lazy_sink_parquet <- function(
  path,
  ...,
  compression = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd"),
  compression_level = NULL,
  statistics = TRUE,
  row_group_size = NULL,
  data_page_size = NULL,
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)

    target <- arg_to_sink_target(path)
    compression <- arg_match0(
      compression,
      values = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd")
    )
    sync_on_close <- arg_match0(
      sync_on_close %||% "none",
      values = c("none", "data", "all")
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

    self$`_ldf`$sink_parquet(
      target = target,
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
  })
}

#' Write to Parquet file
#'
#' @inheritParams lazyframe__sink_parquet
#' @param file File path to which the result should be written. This should be
#' a path to a directory if writing a partitioned dataset.
#' @param partition_by `r lifecycle::badge("experimental")`
#' A character vector indicating column(s) to partition by.
#' A partitioned dataset will be written if this is specified.
#' @param partition_chunk_size_bytes `r lifecycle::badge("experimental")`
#' Approximate size to split DataFrames within
#' a single partition when writing. Note this is calculated using the size of
#' the DataFrame in memory (the size of the output file may differ depending
#' on the file format / compression).
#'
#' @return `NULL` invisibly.
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
  retries = 2,
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)

    target <- file

    if (!is.null(partition_by)) {
      if (!is_string(file)) {
        abort(c(
          "Invalid `file` argument in the case when `partition_by` is specified.",
          x = sprintf("Expected single string, got: %s", obj_type_friendly(file))
        ))
      }

      target <- pl$PartitionByKey(file, by = partition_by)
      mkdir <- TRUE
    }

    self$lazy()$sink_parquet(
      path = target,
      compression = compression,
      compression_level = compression_level,
      statistics = statistics,
      row_group_size = row_group_size,
      data_page_size = data_page_size,
      storage_options = storage_options,
      retries = retries,
      mkdir = mkdir,
      optimizations = DEFAULT_EAGER_OPT_FLAGS,
      engine = "in-memory"
    )
  })
  invisible(NULL)
}
