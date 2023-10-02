# ANY NEW ERROR MUST IMPLEMENT THESE S3 METHODS, these are the "trait" of a polars error
# ALSO MUST IMPLEMENT THESE BASE METHODS: print

#' Internal generic method to convert some Robj into Series
#' @param x object to convert into a polars Series
#' @param ... optional others args which may be used by a specific class implementation
#' @keywords internal
#' @return a Series or an Robj that pl$Series can convert natively
#' @export
#' @examples
#'
#' pl$Series(1:5)
#'
#' # warning this method makes polars very useless
#' as_polars_series.numeric = function(x, ...) {
#'   head(x, 3)
#' }
#'
#' pl$Series(1:5)
#'
as_polars_series = function(x, ...) {
  UseMethod("as_polars_series", x)
}

#' @export
as_polars_series.default = function(x, ...) {
  stop("no `as_polars_series` impl for:", class(x))
}

#' @export
as_polars_series.POSIXlt = function(x, ...) {
  as.POSIXct(x)
}

#' @export
as_polars_series.vctrs_rcrd = function(x, ...) {
  pl$DataFrame(unclass(x))$to_struct()
}
