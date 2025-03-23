pl__field <- function(...) {
  check_dots_unnamed()

  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  field(as.character(dots)) |>
    wrap()
}

pl__select <- function(...) {
  pl$DataFrame()$select(...)
}

#' Alias for an element being evaluated in an eval expression
#'
#' @inherit as_polars_expr return
#' @examples
#' # A horizontal rank computation by taking the elements of a list:
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2)
#' )
#' df$with_columns(
#'   rank = pl$concat_list(c("a", "b"))$list$eval(pl$element()$rank())
#' )
#'
#' # A mathematical operation on array elements:
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2)
#' )
#' df$with_columns(
#'   a_b_doubled = pl$concat_list(c("a", "b"))$list$eval(pl$element() * 2)
#' )
pl__element <- function() {
  pl$col("")
}

#' Folds the columns from left to right, keeping the first non-null value
#' @inherit as_polars_expr return
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Non-named objects can be referenced as columns.
#' Each object will be converted to [expression] by [as_polars_expr()].
#' Strings are parsed as column names, other non-expression inputs are parsed as literals.
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, NA, NA, NA),
#'   b = c(1, 2, NA, NA),
#'   c = c(5, NA, 3, NA)
#' )
#'
#' df$with_columns(d = pl$coalesce("a", "b", "c", 10))
#'
#' df$with_columns(d = pl$coalesce(pl$col("a", "b", "c"), 10))
pl__coalesce <- function(...) {
  check_dots_unnamed()

  parse_into_list_of_expressions(...) |>
    coalesce() |>
    wrap()
}

#' Return indices where `condition` evaluates to `TRUE`
#'
#' @param condition Boolean expression to evaluate.
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = 1:5)
#' df$select(
#'   pl$arg_where(pl$col("a") %% 2 == 0)
#' )
pl__arg_where <- function(condition) {
  arg_where(as_polars_expr(condition)$`_rexpr`) |>
    wrap()
}

#' Return the row indices that would sort the column(s)
#'
#' @inheritParams lazyframe__sort
#'
#' @inherit as_polars_expr return
#' @examples
#' # Pass a single column name to compute the arg sort by that column.
#' df <- pl$DataFrame(
#'   a = c(0, 1, 1, 0),
#'   b = c(3, 2, 3, 2),
#'   c = c(1, 2, 3, 4)
#' )
#' df$select(pl$arg_sort_by("a"))
#'
#' # Compute the arg sort by multiple columns by either passing a list of
#' # columns, or by specifying each column as a positional argument.
#' df$select(pl$arg_sort_by("a", "b", descending = TRUE))
#'
#' # Use gather to apply the arg sort to other columns.
#' df$select(pl$col("c")$gather(pl$arg_sort_by("a")))
pl__arg_sort_by <- function(
  ...,
  descending = FALSE,
  nulls_last = FALSE,
  multithreaded = TRUE,
  maintain_order = FALSE
) {
  wrap({
    check_dots_unnamed()
    if (missing(...)) {
      abort("`...` must contain at least one element.")
    }
    by <- parse_into_list_of_expressions(...)
    descending <- extend_bool(descending, length(by), "descending", "...")
    nulls_last <- extend_bool(nulls_last, length(by), "nulls_last", "...")

    arg_sort_by(
      by,
      descending = descending,
      nulls_last = nulls_last,
      multithreaded = multithreaded,
      maintain_order = maintain_order
    )
  })
}
