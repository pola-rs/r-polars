# nolint start: object_name_linter

# exported in zzz.R
as_record_batch_reader.polars_series <- function(
  x,
  ...,
  polars_compat_level = c("newest", "oldest")
) {
  try_fetch(
    {
      polars_compat_level <- arg_match_compat_level(polars_compat_level)

      # This function is not exported from the arrow package
      # <https://github.com/apache/arrow/issues/39793>
      stream <- utils::getFromNamespace("allocate_arrow_array_stream", "arrow")()
      x$`_s`$to_arrow_c_stream(stream, polars_compat_level = polars_compat_level)
      arrow::RecordBatchReader$import_from_c(stream)
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
