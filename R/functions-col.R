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
        cs__by_name(!!!dots, require_all = TRUE, expand_patterns = TRUE)$as_expr()
      }
    } else if (is_list_of_polars_dtype(dots)) {
      cs__by_dtype(!!!dots)$as_expr()
    } else {
      abort(c(
        "Invalid input for `pl$col()`.",
        `*` = "`pl$col()` accepts either single strings or Polars data types."
      ))
    }
  })
}

#' Get the nth column(s) of the context
#'
#' @param indices One or more indices representing the columns to retrieve.
#' @param strict `r lifecycle::badge("experimental")` Passed to
#'   [`cs$by_index()`][cs__by_index]'s `require_all` argument.
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
pl__nth <- function(indices, strict = TRUE) {
  cs__by_index(indices, require_all = strict)$as_expr()
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
  cs__first()$as_expr()
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
  cs__last()$as_expr()
}
