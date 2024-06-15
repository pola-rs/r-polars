#' @export
as_polars_series <- function(x, name = NULL, ...) {
  UseMethod("as_polars_series")
}

#' @export
as_polars_series.default  <- function(x, name = NULL,...) {
  NextMethod()
}

#' @export
as_polars_series.double <- function(x, name = NULL, ...) {
  PlRSeries$new_f32(name %||% "", x) |>
    PlSeries()
}
