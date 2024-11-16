# TODO: link to data type page
#' Create an expression representing column(s) in a DataFrame
#'
#' @inherit as_polars_expr return
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' The name or [data type][DataType] of the column(s) to represent.
#' Unnamed objects one of the following:
#' - Single string(s) representing column names
#'   - Regular expressions starting with `^` and ending with `$` are allowed.
#'   - Single wildcard `"*"`  has a special meaning: check the examples.
#' - [Polars DataType(s)][DataType]
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
#' # Character vectors with length > 1 should be used with `!!!`
#' pl$col(!!!c("foo", "bar"), "baz")
#' pl$col("foo", !!!c("bar", "baz"))
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

    dots <- list2(...)

    if (is_list_of_string(dots)) {
      if (length(dots) == 1L) {
        col(dots[[1]])
      } else {
        cols(as.character(dots))
      }
    } else if (is_list_of_polars_dtype(dots)) {
      dots |>
        lapply(\(x) x$`_dt`) |>
        dtype_cols()
    } else {
      abort(c(
        "Invalid input for `pl$col()`",
        i = "`pl$col()` accepts either single strings or polars data types"
      ))
    }
  })
}

#' Get the nth column(s) of the context
#'
#' @param indices One or more indices representing the columns to retrieve.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "baz")
#' )
#'
#' df$select(pl$nth(1))
#' df$select(pl$nth(c(2, 0)))
pl__nth <- function(indices) {
  wrap({
    if (is.numeric(indices) && anyNA(indices)) {
      abort("`indices` must not contain any NA values.")
    }
    index_cols(indices)
  })
}

#' Get the first column of the context
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "baz")
#' )
#'
#' df$select(pl$first())
pl__first <- function() {
  first() |>
    wrap()
}

#' Get the last column of the context
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "baz")
#' )
#'
#' df$select(pl$last())
pl__last <- function() {
  last() |>
    wrap()
}
