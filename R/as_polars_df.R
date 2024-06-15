#' @export
as_polars_df <- function(x, ...) {
  UseMethod("as_polars_df")
}

#' @export
as_polars_df.default <- function(x, ...) {
  stop("Unsupported class")
}

#' @export
as_polars_df.list <- function(x, ...) {
  lapply(x, \(column) as_polars_series(column)$`_s`) |>
    PlRDataFrame$init() |>
    wrap()
}

#' @export
as_polars_df.data.frame <- function(x, ...) {
  as.list(x) |>
    as_polars_df.list()
}
