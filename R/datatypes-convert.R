# TODO: export?
as_polars_dtype <- function(x, ...) {
  UseMethod("as_polars_dtype")
}

#' @export
as_polars_dtype.default <- function(x, ...) {
  classes <- class(x)
  stop("Unsupported class: ", paste(classes, collapse = ", "))
}

#' @export
as_polars_dtype.polars_data_type <- function(x, ...) {
  x
}
