# TODO: create macro to create wrap S3 methods

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

  makeActiveBinding("name", function(self = e) series_name(e), e)

  e$clone <- function() series_clone(e)
  e$rename <- function(name) series_rename(e, name)

  class(e) <- "polars_series"
  e
}

#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}

series_name <- function(self) {
  self$`_s`$name()
}

series_clone <- function(self) {
  self$`_s`$clone() |>
    wrap()
}

series_rename <- function(self, name) {
  s <- self$clone()

  s$`_s`$rename(name)
  s
}
