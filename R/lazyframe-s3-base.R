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
#' @rdname s3-as.data.frame
as.data.frame.polars_lazy_frame <- function(
    x, ...,
    int64 = c("double", "character", "integer", "integer64"),
    date = c("Date", "IDate"),
    time = c("hms", "ITime"),
    decimal = c("double", "character"),
    as_clock_class = FALSE,
    ambiguous = c("raise", "earliest", "latest", "null"),
    non_existent = c("raise", "null")) {
  as_polars_df(x, ...) |>
    as.data.frame.polars_data_frame(
      int64 = int64,
      date = date,
      time = time,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
}
