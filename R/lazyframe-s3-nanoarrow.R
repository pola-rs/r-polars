#' @param maintain_order `r lifecycle::badge("experimental")`
#'   Maintain the order in which data is processed. Setting this to `FALSE` will be slightly faster.
#' @param chunk_size `r lifecycle::badge("experimental")`
#'   A positive integer or `NULL` (default).
#'   The number of rows each chunk collected from the lazy computation before
#'   being sent to the Arrow C stream.
#'   If `NULL`, Polars tries to compute an optimal chunk size automatically.
#' @rdname s3-as_nanoarrow_array_stream
as_nanoarrow_array_stream.polars_lazy_frame <- function(
  x,
  ...,
  schema = NULL,
  polars_compat_level = c("newest", "oldest"),
  maintain_order = FALSE,
  chunk_size = NULL
) {
  polars_compat_level <- use_option_if_missing(
    polars_compat_level,
    missing(polars_compat_level),
    "newest",
    option_basename = "compat_level"
  )

  polars_compat_level <- arg_match_compat_level(polars_compat_level)

  if (!is.null(schema)) {
    warn(
      format_warning(
        c(
          `!` = sprintf(
            "The %s argument is not supported for polars lazy frames yet.",
            format_arg("schema")
          )
        )
      )
    )
  }

  stream <- nanoarrow::nanoarrow_allocate_array_stream()
  x$`_ldf`$to_arrow_c_stream(
    stream,
    polars_compat_level = polars_compat_level,
    engine = "streaming",
    maintain_order = maintain_order,
    chunk_size = chunk_size
  )
  stream
}
