#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$print()
  invisible(x)
}

#' @export
dim.polars_data_frame <- function(x) x$shape

#' @export
length.polars_data_frame <- function(x) x$width

#' @export
as.list.polars_data_frame <- function(
    x, ...,
    as_series = FALSE,
    int64 = "double",
    ambiguous = "raise",
    non_existent = "raise") {
  if (isTRUE(as_series)) {
    x$get_columns()
  } else {
    x$to_r_list(
      int64 = int64,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
  }
}

#' @export
as.data.frame.polars_data_frame <- function(
    x,
    ...,
    int64 = "double",
    ambiguous = "raise",
    non_existent = "raise") {
  out <- as.list(
    x,
    int64 = int64,
    as_series = FALSE,
    ambiguous = ambiguous,
    non_existent = non_existent
  )
  class(out) <- "data.frame"
  attr(out, "row.names") <- .set_row_names(x$height)
  out
}
