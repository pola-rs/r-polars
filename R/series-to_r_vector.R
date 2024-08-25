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
#'   If the value is out of the range of [bit64::integer64], export as [bit64::NA_integer64_].
#' @return A [vector]
#' @examples
#' # Create a Series of UInt64
#' series_uint64 <- as_polars_series(
#'   c(NA, "0", "4294967295", "18446744073709551615")
#' )$cast(pl$UInt64)
#' series_uint64
#'
#' ## Export Int64 as double
#' series_uint64$to_r_vector(int64 = "double")
#'
#' ## Export Int64 as character
#' series_uint64$to_r_vector(int64 = "character")
#'
#' ## Export Int64 as integer
#' series_uint64$to_r_vector(int64 = "integer")
#'
#' ## Export Int64 as bit64::integer64
#' if (requireNamespace("bit64", quietly = TRUE)) {
#'   series_uint64$to_r_vector(int64 = "integer64")
#' }
series__to_r_vector <- function(
    ...,
    int64 = "double",
    ambiguous = "raise",
    non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    # Ensure the bit64 package is loaded if int64 is set to 'integer64'
    if (identical(int64, "integer64")) {
      if (!is_installed("bit64")) {
        abort("If the `int64` argument is set to 'integer64', the `bit64` package must be installed.")
      }
    }

    ambiguous <- as_polars_expr(ambiguous, str_as_lit = TRUE)$`_rexpr`
    self$`_s`$to_r_vector(
      int64 = int64,
      ambiguous = ambiguous,
      non_existent = non_existent,
      local_time_zone = Sys.timezone()
    )
  })
}
