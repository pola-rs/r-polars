# ANY NEW ERROR MUST IMPLEMENT THESE S3 METHODS, these are the "trait" of a polars error
# ALSO MUST IMPLEMENT THESE BASE METHODS: print

#' Internal generic method to convert some Robj into Series
#' @param x object to convert into a polars Series
#' @param ... optional others args which may be used by a specific class implementation
#' @keywords internal
#' @return a Series or an Robj that pl$Series can convert natively
#' @examples
#'
#' pl$Series(1:5)
#'
#' #warning this method makes polars very useless
#' as_polars_series.numeric = function(x, ...) {
#'   head(x,3)
#' }
#'
#' pl$Series(1:5)
#'
as_polars_series = function(x, ...) {
    UseMethod("as_polars_series", x)
}

#' @export
as_polars_series.default = function(x, ...) {
  # Err(
  #   .pr$RPolarsErr$
  #     new()$
  #     bad_robj(x)$
  #     plain("polars did not know how to handle this R object")$
  #     when("converting into a Series")$
  #     plain("advice: define as_polars_series.YourClass to solve this see more at ?as_polars_series")
  # )
  stop(paste("no as_polars_series implemented for", str_string(x))) #|>
    #unwrap("in S3 method as_polars_series()")
}

#' @export
as_polars_series.POSIXlt = function(x, ...) {
  as.POSIXct(x)
}


