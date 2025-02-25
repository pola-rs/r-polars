#' @export
print.polars_dtype <- function(x, ...) {
  x$`_dt`$as_str() |>
    writeLines()
  invisible(x)
}
