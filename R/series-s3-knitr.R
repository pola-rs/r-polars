# nolint start: object_name_linter

#' @rdname s3-knit_print
#' @exportS3Method NULL
knit_print.polars_series <- function(x, ...) {
  knit_print_impl(x$to_frame(), ..., from_series = TRUE)
}

# nolint end
