#' Test if the object is a polars DataFrame
#'
#' These functions test if the object is a polars DataFrame.
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
#' These functions test if the object is a polars LazyFrame.
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
#' These functions test if the object is a polars Series.
#' @inherit is_polars_df params return
#' @export
#' @examples
#' is_polars_series(1:3)
#'
#' is_polars_series(as_polars_series(1:3))
is_polars_series = function(x) {
  inherits(x, "RPolarsSeries")
}
