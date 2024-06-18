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

pl__Categorical <- function(ordering = "physical") {
  PlRDataType$new_categorical(ordering) |>
    wrap()
}

pl__Datetime <- function(time_unit = "us", time_zone = NULL) {
  PlRDataType$new_datetime(time_unit, time_zone) |>
    wrap()
}

pl__Duration <- function(time_unit = "us") {
  PlRDataType$new_duration(time_unit) |>
    wrap()
}
