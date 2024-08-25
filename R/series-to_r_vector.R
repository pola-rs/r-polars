# TODO: use options to set the default arguments
# TODO: more notes about naive time
# TODO: link to the type mapping vignette
#' Export the Series as an R vector
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr_dt_replace_time_zone
#' @param int64 Determine how to convert Polars' Int64, UInt32, or UInt64 type values to R type.
#' One of the followings:
#' - `"double"`: Convert to the R's [double] type.
#' - `"character"`: Convert to the R's [character] type.
#' - `"integer"`: Convert to the R's [integer] type.
#'   If the value is out of the range of R's integer type, export as [NA_integer_].
#' - `"integer64"`: Convert to the [bit64::integer64] class.
#'   The [bit64][bit64::bit64-package] package must be installed.
#' @return A [vector]
#' @examples
#' # Create a Series of Int64
#' series_int64 <- as_polars_series(c(NA, "0", "4294967295"))$cast(pl$Int64)
#' series_int64
#'
#' ## Export Int64 as double
#' series_int64$to_r_vector(int64 = "double")
#'
#' ## Export Int64 as character
#' series_int64$to_r_vector(int64 = "character")
#'
#' ## Export Int64 as integer
#' series_int64$to_r_vector(int64 = "integer")
#'
#' ## Export Int64 as bit64::integer64
#' if (requireNamespace("bit64", quietly = TRUE)) {
#'   series_int64$to_r_vector(int64 = "integer64")
#' }
series__to_r_vector <- function(
    ...,
    int64 = "double",
    ambiguous = "raise",
    non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    ambiguous <- as_polars_expr(ambiguous, str_as_lit = TRUE)$`_rexpr`
    self$`_s`$to_r_vector(
      int64 = int64,
      ambiguous = ambiguous,
      non_existent = non_existent,
      local_time_zone = Sys.timezone()
    )
  })
}
