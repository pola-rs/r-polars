# TODO: link to data type page
#' Create an expression representing column(s) in a DataFrame
#'
#' @inherit as_polars_expr return
#' @param names The name(s) or [data type][DataType] of the column(s) to
#' represent. It accepts one of the following:
#' - A character vector representing column names
#'   - Regular expressions starting with `^` and ending with `$` are allowed.
#'   - Single wildcard `"*"`  has a special meaning: check the examples.
#' - A [Polars DataType][DataType] or list of Polars data types
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Deprecated compatibility
#' interface for passing multiple names or data types.
#' @examples
#' # a single column by a character
#' pl$col("foo")
#'
#' # multiple columns by characters
#' pl$col(c("foo", "bar"))
#'
#' # multiple columns by polars data types
#' pl$col(list(pl$Float64, pl$String))
#'
#' # Single `"*"` is converted to a wildcard expression
#' pl$col("*")
#'
#' # The old dynamic-dots interface is deprecated:
#' pl$col("foo", "bar")
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
pl__col <- function(..., names) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...)
    has_names <- !missing(names)

    if (has_names && length(dots) > 0L) {
      abort("Can't combine `names` with positional values in `...`.")
    }

    if (!has_names && length(dots) >= 2L) {
      warn_deprecated_selector_dots("pl$col", "names")
      legacy_names <- dots

      if (is_list_of_string(legacy_names)) {
        if (length(legacy_names) == 1L) {
          col(legacy_names[[1L]])
        } else {
          cs__by_name(
            vapply(legacy_names, `[[`, character(1L), 1L),
            require_all = TRUE,
            expand_patterns = TRUE
          )$as_expr()
        }
      } else if (is_list_of_polars_dtype(legacy_names)) {
        cs__by_dtype(legacy_names)$as_expr()
      } else {
        abort(c(
          "Invalid input for `pl$col()`.",
          `*` = paste0(
            "`pl$col()` accepts either a single character vector or a list ",
            "of Polars data types."
          )
        ))
      }
    } else {
      selected <- if (has_names) {
        names
      } else if (length(dots) == 0L) {
        warn_deprecated_selector_dots("pl$col", "names", empty = TRUE)
        character()
      } else {
        dots[[1L]]
      }

      if (is_character(selected)) {
        if (anyNA(selected)) {
          abort(c(
            "Invalid input for `pl$col()`.",
            `*` = paste0(
              "`pl$col()` accepts either a single character vector or a list ",
              "of Polars data types."
            )
          ))
        }
        if (length(selected) == 1L) {
          col(selected[[1L]])
        } else {
          cs__by_name(
            selected,
            require_all = TRUE,
            expand_patterns = TRUE
          )$as_expr()
        }
      } else if (is_polars_dtype(selected)) {
        cs__by_dtype(list(selected))$as_expr()
      } else if (is_list_of_polars_dtype(selected)) {
        cs__by_dtype(selected)$as_expr()
      } else {
        abort(c(
          "Invalid input for `pl$col()`.",
          `*` = paste0(
            "`pl$col()` accepts either a single character vector or a list ",
            "of Polars data types."
          )
        ))
      }
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
