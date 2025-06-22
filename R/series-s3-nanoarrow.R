# TODO: infer_nanoarrow_schema.polars_series

# nolint start: object_name_linter

# exported in zzz.R
#' Create a nanoarrow_array_stream from a Polars object
#'
#' @param x A polars object
#' @param ... Ignored.
#' @param schema `r lifecycle::badge("experimental")`
#' An optional [nanoarrow schema object][nanoarrow::as_nanoarrow_schema].
#' If specified, interpret the nanoarrow schema as a corresponding polars dtype
#' and then convert the original object using `<Series>$cast()`.
#' Note that the schema of the returned object cannot be fully controlled
#' because Polars does not support all Arrow types.
#' @param polars_compat_level `r lifecycle::badge("experimental")`
#' Determines the compatibility level when exporting Polars' internal data structures.
#' When specifying a new compatibility level, Polars exports its internal data structures
#' that might not be interpretable by other Arrow implementations.
#' The level can be specified as the name (e.g., `"newest"`) or as a scalar integer
#' (Currently, `0` or `1` is supported).
#' - `"newest"` (default): Use the highest level, currently same as `1`
#'   (Low compatibility).
#' - `"oldest"`: Same as `0` (High compatibility).
#' @return A [nanoarrow array stream][nanoarrow::as_nanoarrow_array_stream]
#' @seealso
#' - [`as_polars_series(<nanoarrow_array_stream>)`][as_polars_series]:
#'   Import an array stream as a [Series] via the Arrow C stream interface.
#' @examplesIf requireNamespace("nanoarrow", quietly = TRUE)
#' # Zero-copy round trip via nanoarrow
#' as_polars_series(letters[1:3], name = "letters") |>
#'   nanoarrow::as_nanoarrow_array_stream() |>
#'   as_polars_series()
#'
#' # Specify the schema
#' as_polars_series(1:3, name = "numbers") |>
#'   nanoarrow::as_nanoarrow_array_stream(schema = nanoarrow::na_uint8()) |>
#'   as_polars_series()
#'
#' # DataFrame support
#' pl$DataFrame(a = 1:3, b = letters[1:3]) |>
#'   nanoarrow::as_nanoarrow_array_stream() |>
#'   as_polars_df()
#'
#' # Compatibility level
#' as_polars_series(letters[1:3]) |>
#'   nanoarrow::as_nanoarrow_array_stream(polars_compat_level = 1) |>
#'   nanoarrow::infer_nanoarrow_schema() |>
#'   format()
#'
#' as_polars_series(letters[1:3]) |>
#'   nanoarrow::as_nanoarrow_array_stream(polars_compat_level = "oldest") |>
#'   nanoarrow::infer_nanoarrow_schema() |>
#'   format()
#' @rdname s3-as_nanoarrow_array_stream
as_nanoarrow_array_stream.polars_series <- function(
  x,
  ...,
  schema = NULL,
  polars_compat_level = c("newest", "oldest")
) {
  try_fetch(
    {
      polars_compat_level <- arg_match_compat_level(polars_compat_level)

      pl_r_series <- if (!is.null(schema)) {
        # Sinse polars does not support all Arrow types,
        # we cannot fully control the output schema
        # TODO: needs warnings? needs fallback to the default method (use `arrow` to cast)?
        target_dtype <- nanoarrow::basic_array_stream(list(), schema) |>
          infer_polars_dtype()
        x$`_s`$cast(target_dtype$`_dt`, strict = TRUE)
      } else {
        x$`_s`
      }

      stream <- nanoarrow::nanoarrow_allocate_array_stream()
      pl_r_series$to_arrow_c_stream(stream, polars_compat_level = polars_compat_level)
      stream
    },
    error = function(cnd) {
      abort(
        "Evaluation failed.",
        parent = cnd
      )
    }
  )
}

# nolint end
