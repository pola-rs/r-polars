# Output (ND)JSON functions: sink_ndjson, write_json, write_ndjson

#' Evaluate the query in streaming mode and write to a NDJSON file
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This allows streaming results that are larger than RAM to be written to disk.
#'
#' @inherit lazyframe__sink_parquet return
#' @inheritParams rlang::args_dots_empty
#' @param path A character. File path to which the file should be written.
#' @inheritParams lazyframe__sink_parquet
#' @inheritParams lazyframe__collect
#' @inheritParams pl__scan_parquet
#' @param compression `r lifecycle::badge("experimental")` What compression
#' format to use. Must be one of `uncompressed` (default), `gzip`, or `zstd`.
#' @param compression_level `r lifecycle::badge("experimental")` The compression
#' level to use, typically 0-9 or `NULL` to let the engine choose.
#' @param check_extension `r lifecycle::badge("experimental")` Whether to check
#' if the filename matches the compression settings. Will raise an error if
#' compression is set to `"uncompressed"` and the filename ends in one of
#' `".gz"`, `".zst"`, `".zstd"`, or if `compression != "uncompressed"` and the
#' file uses a mismatched extension. Only applies if file is a path.
#'
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_lf(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col(c("drat", "mpg")))$sink_ndjson(destination)
#' jsonlite::stream_in(file(destination))
lazyframe__sink_ndjson <- function(
  path,
  ...,
  compression = c("uncompressed", "gzip", "zstd"),
  compression_level = NULL,
  check_extension = TRUE,
  maintain_order = TRUE,
  storage_options = NULL,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE,
  engine = c("auto", "in-memory", "streaming"),
  optimizations = pl$QueryOptFlags()
) {
  wrap({
    check_dots_empty0(...)

    self$lazy_sink_ndjson(
      path = path,
      compression = compression,
      compression_level = compression_level,
      check_extension = check_extension,
      maintain_order = maintain_order,
      storage_options = storage_options,
      sync_on_close = sync_on_close,
      mkdir = mkdir
    )$collect(
      engine = engine,
      optimizations = optimizations
    )
  })

  invisible(NULL)
}

#' @rdname lazyframe__sink_ndjson
lazyframe__lazy_sink_ndjson <- function(
  path,
  ...,
  compression = c("uncompressed", "gzip", "zstd"),
  compression_level = NULL,
  check_extension = TRUE,
  maintain_order = TRUE,
  storage_options = NULL,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)
    check_character(storage_options, allow_null = TRUE)
    compression <- arg_match0(compression, values = c("uncompressed", "gzip", "zstd"))

    target <- arg_to_sink_target(path)
    sync_on_close <- arg_match0(
      sync_on_close %||% "none",
      values = c("none", "data", "all")
    )

    self$`_ldf`$sink_ndjson(
      target = target,
      compression = compression,
      compression_level = compression_level,
      check_extension = check_extension,
      maintain_order = maintain_order,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
      storage_options = storage_options
    )
  })
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
#' dat$select(pl$col(c("drat", "mpg")))$write_json(destination)
#' jsonlite::fromJSON(destination)
dataframe__write_json <- function(file) {
  wrap({
    self$`_df`$write_json(file)
  })
  invisible(NULL)
}

#' Serialize to newline delimited JSON representation
#'
#' @inheritParams dataframe__write_json
#' @inheritParams lazyframe__sink_ndjson
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_df(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col(c("drat", "mpg")))$write_ndjson(destination)
#' jsonlite::stream_in(file(destination))
dataframe__write_ndjson <- function(
  file,
  ...,
  compression = c("uncompressed", "gzip", "zstd"),
  compression_level = NULL,
  check_extension = TRUE
) {
  wrap({
    check_dots_empty0(...)
    self$lazy()$sink_ndjson(
      file,
      compression = compression,
      compression_level = compression_level,
      check_extension = check_extension,
      optimizations = DEFAULT_EAGER_OPT_FLAGS,
      engine = "in-memory"
    )
  })
  invisible(NULL)
}
