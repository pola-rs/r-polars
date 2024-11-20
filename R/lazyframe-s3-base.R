# TODO: mimic the Python's one
#' @export
print.polars_lazy_frame <- function(x, ...) {
  cat(sprintf("<polars_lazy_frame at %s>\n", obj_address(x)))
  invisible(x)
}

#' @export
dim.polars_lazy_frame <- function(x) c(NA_integer_, length(x$collect_schema()))

#' @export
length.polars_lazy_frame <- function(x) length(x$collect_schema())

#' @export
names.polars_lazy_frame <- function(x) names(x$collect_schema())

#' @export
#' @rdname s3-as.list
as.list.polars_lazy_frame <- as.list.polars_data_frame

#' @export
#' @rdname s3-as.data.frame
as.data.frame.polars_lazy_frame <- as.data.frame.polars_data_frame
