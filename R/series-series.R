# TODO: create macro to execute this
PlSeries <- function(`_s`) {
  e <- new.env(parent = emptyenv())
  e$`_s` <- `_s`

  class(e) <- "PlSeries"
  e
}

#' @export
print.PlSeries <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}
