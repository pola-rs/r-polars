# TODO: mimic the Python's one
#' @export
print.polars_lazy_frame <- function(x, ...) {
  cat(sprintf("<polars_lazy_frame>\n"))
  cat("NAIVE QUERY PLAN\n")
  cat(" Run `<LazyFrame>$explain()` to see the optimized version.\n\n")
  cat(x$explain(optimized = FALSE))
  cat("\n")
  invisible(x)
}

#' @export
#' @rdname s3-as.list
as.list.polars_lazy_frame <- as.list.polars_data_frame

#' @export
#' @rdname s3-as.data.frame
as.data.frame.polars_lazy_frame <- as.data.frame.polars_data_frame
