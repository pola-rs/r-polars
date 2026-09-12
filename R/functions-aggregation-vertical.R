parse_vertical_agg_input <- function(
  ...,
  names = NULL,
  has_names = FALSE,
  fn
) {
  check_dots_unnamed()
  dots <- list2(...)

  if (has_names && length(dots) > 0L) {
    abort("Can't combine `names` with positional values in `...`.")
  }

  if (has_names) {
    return(names)
  }

  if (length(dots) == 0L) {
    warn_deprecated_selector_dots(
      fn,
      "names",
      empty = TRUE,
      user_env = caller_env(2)
    )
    return(character())
  }

  if (length(dots) >= 2L) {
    warn_deprecated_selector_dots(
      fn,
      "names",
      user_env = caller_env(2)
    )
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
#' @param names The name(s) or [data type][DataType] of the column(s) to use in
#'   the aggregation. A character vector or a Polars data type/list of data
#'   types can be supplied.
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Deprecated compatibility
#'   interface for passing multiple names or data types.
#' @inheritParams expr__all
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
#' df$select(pl$all(names = "a"))
pl__all <- function(..., names, ignore_nulls = TRUE) {
  if (missing(...) && missing(names)) {
    return(pl$col("*"))
  }

  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$all"
  )
  pl$col(names = selected)$all(
    ignore_nulls = ignore_nulls
  )
}

#' Evaluate a bitwise OR operation
#'
#' This function is syntactic sugar for `col(names)$any()`.
#'
#' @param names The name(s) or [data type][DataType] of the column(s) to use in
#'   the aggregation. A character vector or a Polars data type/list of data
#'   types can be supplied.
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Deprecated compatibility
#'   interface for passing multiple names or data types.
#' @inheritParams expr__any
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(TRUE, FALSE, TRUE),
#'   b = c(FALSE, FALSE, FALSE)
#' )
#'
#' df$select(pl$any(names = "a"))
pl__any <- function(..., names, ignore_nulls = TRUE) {
  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$any"
  )
  pl$col(names = selected)$any(
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
#' df$select(pl$max(names = "a"))
#'
#' # Get the maximum value of multiple columns
#' df$select(pl$max(names = c("a", "b")))
pl__max <- function(..., names) {
  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$max"
  )
  pl$col(names = selected)$max()
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
#' df$select(pl$min(names = "a"))
#'
#' # Get the minimum value of multiple columns
#' df$select(pl$min(names = c("a", "b")))
pl__min <- function(..., names) {
  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$min"
  )
  pl$col(names = selected)$min()
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
#' df$select(pl$sum(names = "a"))
#'
#' # Get the sum of multiple columns
#' df$select(pl$sum(names = c("a", "b")))
pl__sum <- function(..., names) {
  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$sum"
  )
  pl$col(names = selected)$sum()
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
#' df$select(pl$cum_sum(names = "a"))
#'
#' # Get the cum_sum of multiple columns
#' df$select(pl$cum_sum(names = c("a", "b")))
pl__cum_sum <- function(..., names) {
  selected <- parse_vertical_agg_input(
    ...,
    names = if (missing(names)) NULL else names,
    has_names = !missing(names),
    fn = "pl$cum_sum"
  )
  pl$col(names = selected)$cum_sum()
}
