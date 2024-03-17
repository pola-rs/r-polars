#' Test if the object is a polars DataFrame
#'
#' This function tests if the object is a polars DataFrame.
#' @param x An object
#' @return A logical value
#' @export
#' @examples
#' is_polars_df(mtcars)
#'
#' is_polars_df(as_polars_df(mtcars))
is_polars_df = function(x) {
  inherits(x, "RPolarsDataFrame")
}


#' Test if the object is a polars LazyFrame
#'
#' This function tests if the object is a polars LazyFrame.
#' @inherit is_polars_df params return
#' @export
#' @examples
#' is_polars_lf(mtcars)
#'
#' is_polars_lf(as_polars_lf(mtcars))
is_polars_lf = function(x) {
  inherits(x, "RPolarsLazyFrame")
}


#' Test if the object is a polars Series
#'
#' This function tests if the object is a polars Series.
#' @inherit is_polars_df params return
#' @export
#' @examples
#' is_polars_series(1:3)
#'
#' is_polars_series(as_polars_series(1:3))
is_polars_series = function(x) {
  inherits(x, "RPolarsSeries")
}

#' Test if the object a polars DataType
#'
#' @inherit is_polars_df params return
#' @param include_unknown If `FALSE` (default), `pl$Unknown` is considered as
#' an invalid datatype.
#'
#' @export
#' @examples
#' is_polars_dtype(pl$Int64)
#' is_polars_dtype(mtcars)
#' is_polars_dtype(pl$Unknown)
#' is_polars_dtype(pl$Unknown, include_unknown = TRUE)
is_polars_dtype = function(x, include_unknown = FALSE) {
  inherits(x, "RPolarsDataType") && (x != pl$Unknown || include_unknown)
}
