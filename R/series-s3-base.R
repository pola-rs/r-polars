#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}

# TODO: add the mode argument
#' @export
as.vector.polars_series <- function(x) {
  x$to_r_vector()
}

# TODO: as.character.polars_series

#' @export
length.polars_series <- function(x) x$len()
