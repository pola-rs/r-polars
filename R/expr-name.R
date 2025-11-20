# The env for storing all expr name methods
polars_expr_name_methods <- new.env(parent = emptyenv())

namespace_expr_name <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  class(self) <- c(
    "polars_namespace_expr_name",
    "polars_namespace_expr",
    "polars_object"
  )
  self
}

#' Keep the original root name of the expression.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(alice = 1:3)
#' df$select(pl$col("alice")$alias("bob")$name$keep())
expr_name_keep <- function() {
  self$`_rexpr`$name_keep() |>
    wrap()
}

#' Add a prefix to a column name
#'
#' @param prefix Prefix to be added to column name(s)
#' @inherit as_polars_expr return
#' @seealso
#' [`$suffix()`][expr_name_suffix] to add a suffix
#'
#' @examples
#' dat <- as_polars_df(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$prefix("name_"),
#'   pl$col("cyl", "drat")$name$prefix("bar_")
#' )
expr_name_prefix <- function(prefix) {
  self$`_rexpr`$name_prefix(prefix) |>
    wrap()
}

#' Add a suffix to a column name
#'
#' @param suffix Suffix to be added to column name(s)
#' @inherit as_polars_expr return
#' @seealso
#' [`$prefix()`][expr_name_prefix] to add a prefix
#'
#' @examples
#' dat <- as_polars_df(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$suffix("_foo"),
#'   pl$col("cyl", "drat")$name$suffix("_bar")
#' )
expr_name_suffix <- function(suffix) {
  self$`_rexpr`$name_suffix(suffix) |>
    wrap()
}

#' Make the root column name lowercase
#'
#' Due to implementation constraints, this method can only be called as the last
#' expression in a chain.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(Foo = 1:3, BAR = 4:6)
#' df$select(pl$all()$name$to_lowercase())
expr_name_to_lowercase <- function() {
  self$`_rexpr`$name_to_lowercase() |>
    wrap()
}

#' Make the root column name uppercase
#'
#' Due to implementation constraints, this method can only be called as the last
#' expression in a chain.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(Foo = 1:3, bar = 4:6)
#' df$select(pl$all()$name$to_uppercase())
expr_name_to_uppercase <- function() {
  self$`_rexpr`$name_to_uppercase() |>
    wrap()
}

#' Add a prefix to all fields name of a struct
#'
#' @param prefix Prefix to add to the field name.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = 1, b = 2)$select(
#'   pl$struct(pl$all())$alias("my_struct")
#' )
#'
#' df$with_columns(
#'   pl$col("my_struct")$name$prefix_fields("col_")
#' )$unnest("my_struct")
expr_name_prefix_fields <- function(prefix) {
  self$`_rexpr`$name_prefix_fields(prefix) |>
    wrap()
}

#' Add a suffix to all fields name of a struct
#'
#' @param suffix Suffix to add to the field name.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = 1, b = 2)$select(
#'   pl$struct(pl$all())$alias("my_struct")
#' )
#'
#' df$with_columns(
#'   pl$col("my_struct")$name$suffix_fields("_post")
#' )$unnest("my_struct")
expr_name_suffix_fields <- function(suffix) {
  self$`_rexpr`$name_suffix_fields(suffix) |>
    wrap()
}

#' Replace matching regex/literal substring in the name with a new value
#'
#' @description
#' This will undo any previous renaming operations on the expression.
#'
#' Due to implementation constraints, this method can only be called as the last
#' expression in a chain. Only one name operation per expression will work.
#'
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams cs__matches
#' @param value String that will replace the matched substring.
#' @param literal Treat `pattern` as a literal string, not a regex.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n_foo = 1, n_bar = 2)
#' df$select(pl$all()$name$replace("^n_", "col_"))
#'
#' df$select(pl$all()$name$replace("(a|e|i|o|u)", "@"))$schema
expr_name_replace <- function(pattern, value, ..., literal = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$name_replace(pattern, value, literal)
  })
}
