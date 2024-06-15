#' @export
wrap.PlRDataFrame <- function(x) {
  .self <- new.env(parent = emptyenv())
  .self$`_df` <- x

  .self$to_struct <- function(name = "") dataframe_to_struct(.self, name)

  class(.self) <- "polars_data_frame"
  .self
}

#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$print()
  invisible(x)
}

dataframe_to_struct <- function(self, name = "") {
  self$`_df`$to_struct(name) |>
    wrap()
}
