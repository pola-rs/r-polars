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

datatype__is_temporal <- function() {
  self$`_dt`$is_temporal()
}

datatype__is_enum <- function() {
  self$`_dt`$is_enum()
}

datatype__is_categorical <- function() {
  self$`_dt`$is_categorical()
}

datatype__is_string <- function() {
  self$`_dt`$is_string()
}

datatype__is_logical <- function() {
  self$`_dt`$is_bool()
}

datatype__is_float <- function() {
  self$`_dt`$is_float()
}

datatype__is_numeric <- function() {
  self$`_dt`$is_numeric()
}

datatype__is_integer <- function() {
  self$`_dt`$is_integer()
}

datatype__is_signed_integer <- function() {
  self$`_dt`$is_signed_integer()
}

datatype__is_unsigned_integer <- function() {
  self$`_dt`$is_unsigned_integer()
}

datatype__is_null <- function() {
  self$`_dt`$is_null()
}

datatype__is_binary <- function() {
  self$`_dt`$is_binary()
}

datatype__is_primitive <- function() {
  self$`_dt`$is_primitive()
}

datatype__is_bool <- function() {
  self$`_dt`$is_bool()
}

datatype__is_array <- function() {
  self$`_dt`$is_list()
}

datatype__is_list <- function() {
  self$`_dt`$is_list()
}

datatype__is_nested <- function() {
  self$`_dt`$is_nested()
}

datatype__is_struct <- function() {
  self$`_dt`$is_struct()
}

datatype__is_ord <- function() {
  self$`_dt`$is_ord()
}

datatype__is_known <- function() {
  self$`_dt`$is_known()
}
