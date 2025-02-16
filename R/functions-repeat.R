#' Construct a column of length n`` filled with the given value
#'
#' @inheritParams rlang::args_dots_empty
#' @param value Value to repeat.
#' @param n Length of the resulting column
#' @param dtype Data type of the resulting column. If `NULL` (default), data
#' type is inferred from the given value. Defaults to Int32 for integer values,
#' unless Int64 is required to fit the given value. Defaults to Float64 for
#' float values.
#'
#' @details
#' If you want to construct a column in lazy mode and do not need a
#' pre-determined length, use `pl$lit()` instead.
#' @inherit as_polars_expr return
#' @examples
#' # Construct a column with a repeated value in a lazy context.
#' pl$select(pl$repeat_("z", n = 3))
#'
#' # Specify an output dtype
#' pl$select(pl$repeat_(3, n = 3, dtype = pl$Int8))
pl__repeat_ <- function(value, n, ..., dtype = NULL) {
  wrap({
    check_polars_dtype(dtype, allow_null = TRUE)
    if (is_integerish(n)) {
      if (n < 0) {
        abort("`n` must be greater than or equal to 0.")
      }
      n <- pl$lit(n)$cast(pl$Int64)
    }
    value <- as_polars_expr(value, as_lit = TRUE)
    repeat_(value$`_rexpr`, n$`_rexpr`, dtype$`_dt`)
  })
}
