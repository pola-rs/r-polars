# TODO: create macro to create wrap S3 methods

# Allow namespace to be added from external packages
polars_namespaces_series <- new.env(parent = emptyenv())

#' @export
wrap.PlRSeries <- function(x) {
  .self <- new.env(parent = emptyenv())
  .self$`_s` <- x

  makeActiveBinding("name", function(self = .self) series_name(self), .self)

  for (namespace in names(polars_namespaces_series)) {
    makeActiveBinding(namespace, function(x = .self) polars_namespaces_series[[namespace]](x), .self)
  }

  .self$clone <- function() series_clone(.self)
  .self$rename <- function(name) series_rename(.self, name)

  class(.self) <- "polars_series"
  .self
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
