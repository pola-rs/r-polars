# Unlike Python Polars, the DataType object is defined on the Rust side, so this file provide wrappers

# The env for storing data type methods
polars_datatype__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRDataType <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_dt` <- x

  lapply(names(polars_datatype__methods), function(name) {
    fn <- polars_datatype__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- "polars_data_type"
  self
}

#' @export
print.polars_data_type <- function(x, ...) {
  x$`_dt`$print()
  x
}
