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
    x, ..., as_series = FALSE, ambiguous = "raise", non_existent = "raise") {
  if (isTRUE(as_series)) {
    x$get_columns()
  } else {
    x$to_r_list(ambiguous = ambiguous, non_existent = non_existent)
  }
}

#' @export
as.data.frame.polars_data_frame <- function(
    x, ..., ambiguous = "raise", non_existent = "raise") {
  out <- as.list(
    x,
    as_series = FALSE, ambiguous = ambiguous, non_existent = non_existent
  )
  class(out) <- "data.frame"
  attr(out, "row.names") <- .set_row_names(x$height)
  out
}
