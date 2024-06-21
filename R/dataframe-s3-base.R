#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$print()
  invisible(x)
}

#' @export
as.list.polars_data_frame <- function(x, ..., as_series = FALSE) {
  if (isTRUE(as_series)) {
    x$get_columns()
  } else {
    x$to_list()
  }
}

#' @export
as.data.frame.polars_data_frame <- function(x, ...) {
  as.list(x, as_series = FALSE) |>
    lapply(\(column) {
      if (is.list(column)) {
        I(column)
      } else {
        column
      }
    }) |>
    as.data.frame()
}
