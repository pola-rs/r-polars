# TODO: @2.0.0: Fix the default value of compression to "uncompressed"

#' Evaluate the query in streaming mode and write to Arrow IPC File Format
#'
#' @inherit lazyframe__sink_parquet description params return
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__collect
#' @param compression Determines the compression algorithm.
#' Must be one of:
#' - `"uncompressed"` or `NULL`: Write an uncompressed Arrow file.
#' - `"lz4"`: Fast compression/decompression.
#' - `"zstd"` (default): Good compression performance.
#' @param compat_level Determines the compatibility level when exporting
#'   Polars' internal data structures. When specifying a new compatibility level,
#'   Polars exports its internal data structures that might not be interpretable by
#'   other Arrow implementations. The level can be specified as the name
#'   (e.g., `"newest"`) or as a scalar integer
#'   (Currently, `r (pl$CompatLevel$oldest:pl$CompatLevel$newest) |> format_code()`
#'   are supported).
#'
#'   - `"newest"` `r lifecycle::badge("experimental")` (default):
#'     Use the highest level, currently same as
#'     `r pl$CompatLevel$newest |> format_code()` (Low compatibility).
#'   - `"oldest"`: Same as `0` (High compatibility).
#' @examples
#' tmpf <- tempfile(fileext = ".arrow")
#' as_polars_lf(mtcars)$sink_ipc(tmpf)
#'
#' pl$read_ipc(tmpf)
lazyframe__sink_ipc <- function(
  path,
  ...,
  compression = c("zstd", "lz4", "uncompressed"),
  compat_level = c("newest", "oldest"),
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE,
  engine = c("auto", "in-memory", "streaming"),
  optimizations = QueryOptFlags()
) {
  wrap({
    check_dots_empty0(...)

    # Allow override by option at the downstream function
    if (missing(compat_level)) {
      compat_level <- missing_arg()
    }

    self$lazy_sink_ipc(
      path = path,
      compression = compression,
      compat_level = compat_level,
      maintain_order = maintain_order,
      storage_options = storage_options,
      retries = retries,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
    )$collect(engine = engine, optimizations = optimizations)
  })

  invisible(NULL)
}

#' @rdname lazyframe__sink_ipc
lazyframe__lazy_sink_ipc <- function(
  path,
  ...,
  compression = c("zstd", "lz4", "uncompressed"),
  compat_level = c("newest", "oldest"),
  maintain_order = TRUE,
  storage_options = NULL,
  retries = 2,
  sync_on_close = c("none", "data", "all"),
  mkdir = FALSE
) {
  wrap({
    check_dots_empty0(...)

    compat_level <- use_option_if_missing(
      compat_level,
      missing(compat_level),
      "newest"
    )

    target <- arg_to_sink_target(path)
    compression <- arg_match0(
      compression %||% "uncompressed",
      values = c("zstd", "lz4", "uncompressed")
    )
    compat_level <- arg_match_compat_level(compat_level)
    sync_on_close <- arg_match0(
      sync_on_close %||% "none",
      values = c("none", "data", "all")
    )

    self$`_ldf`$sink_ipc(
      target = target,
      compression = compression,
      compat_level = compat_level,
      maintain_order = maintain_order,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
      storage_options = storage_options,
      retries = retries
    )
  })
}

#' Write to Arrow IPC File Format
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__sink_ipc
#' @inherit dataframe__write_parquet return
#' @examples
#' tmpf <- tempfile(fileext = ".arrow")
#' as_polars_df(mtcars)$write_ipc(tmpf)
#'
#' pl$read_ipc(tmpf)
dataframe__write_ipc <- function(
  path,
  ...,
  compression = c("zstd", "lz4", "uncompressed"),
  compat_level = c("newest", "oldest"),
  storage_options = NULL,
  retries = 2
) {
  wrap({
    check_dots_empty0(...)

    # Allow override by option at the downstream function
    if (missing(compat_level)) {
      compat_level <- missing_arg()
    }

    self$lazy()$sink_ipc(
      path = path,
      compression = compression,
      compat_level = compat_level,
      storage_options = storage_options,
      retries = retries,
      optimizations = DEFAULT_EAGER_OPT_FLAGS,
      engine = "in-memory"
    )
  })
  invisible(NULL)
}

#' Write to Arrow IPC Streaming Format
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__sink_ipc
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("nanoarrow", quiet = TRUE) && nanoarrow::nanoarrow_with_zstd()
#' tmpf <- tempfile(fileext = ".arrows")
#' as_polars_df(mtcars)$write_ipc_stream(tmpf)
#'
#' nanoarrow::read_nanoarrow(tmpf)
dataframe__write_ipc_stream <- function(
  path,
  ...,
  compression = c("zstd", "lz4", "uncompressed"),
  compat_level = c("newest", "oldest")
) {
  wrap({
    check_dots_empty0(...)

    # Handle missing values with use_option_if_missing (similar to lazy_sink_ipc)
    compat_level <- use_option_if_missing(
      compat_level,
      missing(compat_level),
      "newest"
    )

    compression <- arg_match0(
      compression %||% "uncompressed",
      values = c("zstd", "lz4", "uncompressed")
    )
    compat_level <- arg_match_compat_level(compat_level)

    self$`_df`$write_ipc_stream(
      path = path,
      compression = compression,
      compat_level = compat_level
    )
  })
  invisible(NULL)
}
