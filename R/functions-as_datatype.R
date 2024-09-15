# TODO: support `schema` argument
#' Collect columns into a struct column
#'
#' @inherit as_polars_expr return
#' @inheritParams lazyframe__select
#' @examples
#' # Collect all columns of a dataframe into a struct by passing pl.all().
#' df <- pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L),
#' )
#' df$select(pl$struct(pl$all())$alias("my_struct"))
#'
#' # Name each struct field.
#' df$select(pl$struct(p = "int", q = "bool")$alias("my_struct"))$schema
pl__struct <- function(...) {
  parse_into_list_of_expressions(...) |>
    as_struct() |>
    wrap()
}
