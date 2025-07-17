#' Evaluate the query in streaming mode and write to an Arrow IPC file
#'
#' @inherit lazyframe__sink_parquet description params return
#' @inheritParams rlang::args_dots_empty
#' @param compression Determines the compression algorithm.
#' Must be one of:
#' - `"uncompressed"` or `NULL`: Write an uncompressed Arrow file.
#' - `"lz4"`: Fast compression/decompression.
#' - `"zstd"` (default): Good compression performance.
#' @param compat_level Determines the compatibility level when exporting
#' Polars' internal data structures. When specifying a new compatibility level,
#' Polars exports its internal data structures that might not be interpretable by
#' other Arrow implementations. The level can be specified as the name
#' (e.g., `"newest"`) or as a scalar integer (Currently, `0` or `1` is supported).
#' - `"newest"` (default): Use the highest level, currently same as `1`
#'   (Low compatibility).
#' - `"oldest"`: Same as `0` (High compatibility).
#' @examples
#' tmpf <- tempfile(fileext = ".arrow")
#' as_polars_lf(mtcars)$sink_ipc(tmpf)
#' pl$scan_ipc(tmpf)$collect()
lazyframe__sink_ipc <- function(
  path,
  ...,
  compression = c("zstd", "lz4", "uncompressed"),
  compat_level = c("newest", "oldest"),
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
    compression <- arg_match0(
      compression %||% "uncompressed",
      values = c("zstd", "lz4", "uncompressed")
    )
    compat_level <- arg_match_compat_level(compat_level)
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

    lf <- lf$sink_ipc(
      target = target,
      compression = compression,
      compat_level = compat_level,
      maintain_order = maintain_order,
      sync_on_close = sync_on_close,
      mkdir = mkdir,
      storage_options = storage_options,
      retries = retries
    )

    # TODO: support `engine`, `lazy` arguments
    wrap(lf)$collect()
  })
  invisible(NULL)
}

#' Write to Arrow IPC file.
#'
#' @inherit lazyframe__sink_parquet description params return
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__sink_ipc
#' @inherit write_csv return
#' @examples
#' tmpf <- tempfile()
#' as_polars_df(mtcars)$write_ipc(tmpf)
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

    # TODO: Update like https://github.com/pola-rs/polars/pull/22582
    self$lazy()$sink_ipc(
      path = path,
      compression = compression,
      compat_level = compat_level,
      storage_options = storage_options,
      retries = retries
    )
  })
  invisible(NULL)
}
