# TODO: link to data type page
#' Create an expression representing column(s) in a DataFrame
#'
#' @inherit as_polars_expr return
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' The name or datatype of the column(s) to represent.
#' Unnamed objects one of the following:
#' - character vectors
#'   - Single wildcard `"*"` has a special meaning: check the examples.
#' - (lists of) `polars_dtype` objects
#' @examples
#' # a single column by a character
#' pl$col("foo")
#'
#' # multiple columns by characters
#' pl$col("foo", "bar")
#'
#' # multiple columns by polars data types
#' pl$col(pl$Float64, pl$String)
#'
#' # Single `"*"` is converted to a wildcard expression
#' pl$col("*")
#'
#' # multiple character vectors and a list of polars data types are also allowed
#' pl$col(c("foo", "bar"), "baz")
#' pl$col("foo", c("bar", "baz"))
#' pl$col(list(pl$Float64, pl$String), list(pl$UInt32))
#'
#' # there are some special notations for selecting columns
#' df <- pl$DataFrame(foo = 1:3, bar = 4:6, baz = 7:9)
#'
#' ## select all columns with a wildcard `"*"`
#' df$select(pl$col("*"))
#'
#' ## select multiple columns by a regular expression
#' ## starts with `^` and ends with `$`
#' df$select(pl$col("^ba.*$"))
pl__col <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...) |>
      unlist(recursive = FALSE)

    if (is.character(dots)) {
      if (anyNA(dots)) {
        abort("`NA` is not a valid column name")
      }

      if (length(dots) == 1L) {
        col(dots[[1]])
      } else {
        cols(dots)
      }
    } else if (is_polars_dtype(dots[[1]])) {
      dots |>
        lapply(\(x) {
          if (!isTRUE(is_polars_dtype(x))) {
            # TODO: error message improvement
            abort(
              sprintf("Expect polars data type, got %s", toString(class(x))),
              call = parent.frame(3L)
            )
          }
          x$`_dt`
        }) |>
        dtype_cols()
    } else {
      # TODO: error message improvement
      abort("invalid input for `pl$col()`.")
    }
  })
}
