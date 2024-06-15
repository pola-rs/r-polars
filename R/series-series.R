# TODO: create macro to execute this

wrap <- function(x, ...) {
  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  stop("Unimplemented class!")
}

#' @export
wrap.PlRSeries <- function(x) {
  e <- new.env(parent = emptyenv())
  e$`_s` <- x

  class(e) <- "polars_series"
  e
}

#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}
