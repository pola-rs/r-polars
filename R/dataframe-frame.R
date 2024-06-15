#' @export
wrap.PlRDataFrame <- function(x) {
  .self <- new.env(parent = emptyenv())
  .self$`_df` <- x

  class(.self) <- "polars_data_frame"
  .self
}

#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$as_str()
  invisible(x)
}
