#' Either return an expression representing all columns, or evaluate a bitwise
#' AND operation
#'
#' If no arguments are passed, this function is syntactic sugar for `col("*")`.
#' Otherwise, this function is syntactic sugar for `col(names)$all()`.
#'
#' @inheritParams expr__all
#' @inheritParams rlang::args_dots_empty
#' @param names Name(s) of the columns to use in the aggregation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(TRUE, FALSE, TRUE),
#'   b = c(FALSE, FALSE, FALSE)
#' )
#'
#' # Selecting all columns
#' df$select(pl$all()$sum())
#'
#' # Evaluate bitwise AND for a column.
#' df$select(pl$all("a"))
pl__all <- function(names, ..., ignore_nulls = TRUE) {
  check_dots_empty0(...)
  if (missing(names)) {
    pl$col("*")
  } else {
    pl$col(names)$all(
      ignore_nulls = ignore_nulls
    )
  }
}

#' Evaluate a bitwise OR operation
#'
#' This function is syntactic sugar for `col(names)$any()`.
#'
#' @param names Name(s) of the columns to use in the aggregation.
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__any
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(TRUE, FALSE, TRUE),
#'   b = c(FALSE, FALSE, FALSE)
#' )
#'
#' df$select(pl$any("a"))
pl__any <- function(names, ..., ignore_nulls = TRUE) {
  check_dots_empty0(...)
  pl$col(names)$any(
    ignore_nulls = ignore_nulls
  )
}

#' Get the maximum value
#'
#' This function is syntactic sugar for `col(names)$max()`.
#'
#' @param names Name(s) of the columns to use in the aggregation.
#' @inheritParams rlang::args_dots_empty
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' # Get the maximum value of a column
#' df$select(pl$max("a"))
#'
#' # Get the maximum value of multiple columns
#' df$select(pl$max(c("a", "b")))
pl__max <- function(names, ...) {
  check_dots_empty0(...)
  pl$col(names)$max()
}

#' Get the minimum value
#'
#' This function is syntactic sugar for `col(names)$min()`.
#'
#' @param names Name(s) of the columns to use in the aggregation.
#' @inheritParams rlang::args_dots_empty
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' # Get the minimum value of a column
#' df$select(pl$min("a"))
#'
#' # Get the minimum value of multiple columns
#' df$select(pl$min(c("a", "b")))
pl__min <- function(names, ...) {
  check_dots_empty0(...)
  pl$col(names)$min()
}

#' Sum all values
#'
#' This function is syntactic sugar for `col(names)$sum()`.
#'
#' @param names Name(s) of the columns to use in the aggregation.
#' @inheritParams rlang::args_dots_empty
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' # Get the sum of a column
#' df$select(pl$sum("a"))
#'
#' # Get the sum of multiple columns
#' df$select(pl$sum(c("a", "b")))
pl__sum <- function(names, ...) {
  check_dots_empty0(...)
  pl$col(names)$sum()
}

#' Cumulatively sum all values
#'
#' This function is syntactic sugar for `col(names)$cum_sum()`.
#'
#' @param names Name(s) of the columns to use in the aggregation.
#' @inheritParams rlang::args_dots_empty
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' # Get the cum_sum of a column
#' df$select(pl$cum_sum("a"))
#'
#' # Get the cum_sum of multiple columns
#' df$select(pl$cum_sum(c("a", "b")))
pl__cum_sum <- function(names, ...) {
  check_dots_empty0(...)
  pl$col(names)$cum_sum()
}
