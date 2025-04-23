# nolint start: object_name_linter

# exported in zzz.R
as_record_batch_reader.polars_data_frame <- function(
  x,
  ...,
  polars_compat_level = c("newest", "oldest")
) {
  as_polars_series(x) |>
    as_record_batch_reader.polars_series(..., polars_compat_level = polars_compat_level)
}

# exported in zzz.R
as_arrow_table.polars_data_frame <- function(
  x,
  ...,
  polars_compat_level = c("newest", "oldest")
) {
  try_fetch(
    {
      as_record_batch_reader.polars_data_frame(
        x,
        polars_compat_level = polars_compat_level
      )$read_table()
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
