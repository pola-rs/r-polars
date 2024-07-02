# The env for storing dataframe methods
polars_dataframe__methods <- new.env(parent = emptyenv())

#' @export
is_polars_df <- function(x) {
  inherits(x, "polars_data_frame")
}

#' @export
wrap.PlRDataFrame <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_df` <- x

  makeActiveBinding("shape", function() self$`_df`$shape(), self)
  makeActiveBinding("height", function() self$`_df`$height(), self)
  makeActiveBinding("width", function() self$`_df`$width(), self)

  lapply(names(polars_dataframe__methods), function(name) {
    fn <- polars_dataframe__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_data_frame", "polars_object")
  self
}

pl__DataFrame <- function(...) {
  list2(...) |>
    as_polars_df()
}

dataframe__to_struct <- function(name = "") {
  self$`_df`$to_struct(name) |>
    wrap()
}

dataframe__lazy <- function() {
  self$`_df`$lazy() |>
    wrap()
}

dataframe__get_columns <- function() {
  self$`_df`$get_columns() |>
    lapply(\(ptr) {
      .savvy_wrap_PlRSeries(ptr) |>
        wrap()
    })
}

dataframe__to_r_list <- function() {
  self$get_columns() |>
    lapply(as.vector)
}

dataframe__group_by <- function(..., maintain_order = FALSE) {
  wrap_to_group_by(self, list2(...), maintain_order)
}

dataframe__select <- function(...) {
  self$lazy()$select(...)$collect()
}

dataframe__to_series <- function(index = 0) {
  self$`_df`$to_series(index) |>
    wrap()
}

dataframe__equals <- function(other, ..., null_equal = TRUE) {
  check_dots_empty0(...)

  if (!isTRUE(is_polars_df(other))) {
    abort("`other` must be a polars data frame")
  }

  self$`_df`$equals(other$`_df`, null_equal) |>
    wrap()
}
