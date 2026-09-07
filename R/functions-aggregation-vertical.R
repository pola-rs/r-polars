# TODO: @2.0 Replace the dynamic-dots `...` interface with a single `names`
# argument and remove this compatibility helper.
parse_vertical_agg_input <- function(...) {
  check_dots_unnamed()
  dots <- list2(...)

  if (length(dots) == 0L) {
    return(character())
  }

  if (all(vapply(dots, is_character, logical(1L)))) {
    return(unlist(dots, use.names = FALSE))
  }

  if (length(dots) == 1L) {
    return(dots[[1L]])
  }

  dots
}

#' Either return an expression representing all columns, or evaluate a bitwise
#' AND operation
#'
#' If no arguments are passed, this function is syntactic sugar for `col("*")`.
#' Otherwise, this function is syntactic sugar for `col(names)$all()`.
#'
#' @inheritParams expr__all
#' @param ... Name(s) of the columns to use in the aggregation.
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
pl__all <- function(..., ignore_nulls = TRUE) {
  if (missing(...)) {
    pl$col("*")
  } else {
    pl$col(names = parse_vertical_agg_input(...))$all(
      ignore_nulls = ignore_nulls
    )
  }
}

#' Evaluate a bitwise OR operation
#'
#' This function is syntactic sugar for `col(names)$any()`.
#'
#' @param ... Name(s) of the columns to use in the aggregation.
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
pl__any <- function(..., ignore_nulls = TRUE) {
  pl$col(names = parse_vertical_agg_input(...))$any(
    ignore_nulls = ignore_nulls
  )
}

#' Get the maximum value
#'
#' This function is syntactic sugar for `col(names)$max()`.
#'
#' @inheritParams pl__all
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
#' df$select(pl$max("a", "b"))
pl__max <- function(...) {
  pl$col(names = parse_vertical_agg_input(...))$max()
}

#' Get the minimum value
#'
#' This function is syntactic sugar for `col(names)$min()`.
#'
#' @inheritParams pl__all
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
#' df$select(pl$min("a", "b"))
pl__min <- function(...) {
  pl$col(names = parse_vertical_agg_input(...))$min()
}

#' Sum all values
#'
#' This function is syntactic sugar for `col(names)$sum()`.
#'
#' @inheritParams pl__all
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
#' df$select(pl$sum("a", "b"))
pl__sum <- function(...) {
  pl$col(names = parse_vertical_agg_input(...))$sum()
}

#' Cumulatively sum all values
#'
#' This function is syntactic sugar for `col(names)$cum_sum()`.
#'
#' @inheritParams pl__all
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
#' df$select(pl$cum_sum("a", "b"))
pl__cum_sum <- function(...) {
  pl$col(names = parse_vertical_agg_input(...))$cum_sum()
}
