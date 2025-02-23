# The env for storing all expr struct methods
polars_expr_struct_methods <- new.env(parent = emptyenv())

namespace_expr_struct <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_struct_methods), function(name) {
    fn <- polars_expr_struct_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_expr",
    "polars_struct_namespace",
    "polars_object"
  )
  self
}

expr_struct_field_by_index <- function(index) {
  self$`_rexpr`$struct_field_by_index(index) |>
    wrap()
}

#' Retrieve one or multiple Struct field(s) as a new Series
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Names of struct fields to
#' retrieve.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   aaa = c(1, 2),
#'   bbb = c("ab", "cd"),
#'   ccc = c(TRUE, NA),
#'   ddd = list(1:2, 3)
#' )$select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))
#' df
#'
#' # Retrieve struct field(s) as Series:
#' df$select(pl$col("struct_col")$struct$field("bbb"))
#'
#' df$select(
#'   pl$col("struct_col")$struct$field("bbb"),
#'   pl$col("struct_col")$struct$field("ddd")
#' )
#'
#' # Use wildcard expansion:
#' df$select(pl$col("struct_col")$struct$field("*"))
#'
#' # Retrieve multiple fields by name:
#' df$select(pl$col("struct_col")$struct$field("aaa", "bbb"))
#'
#' # Retrieve multiple fields by regex expansion:
#' df$select(pl$col("struct_col")$struct$field("^a.*|b.*$"))
expr_struct_field <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...)
    check_list_of_string(dots, arg = "...")

    self$`_rexpr`$struct_multiple_fields(as.character(dots))
  })
}

#' Rename the fields of the struct
#'
#' @param names New names, given in the same order as the struct's fields.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   aaa = c(1, 2),
#'   bbb = c("ab", "cd"),
#'   ccc = c(TRUE, NA),
#'   ddd = list(1:2, 3)
#' )$select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))
#' df
#'
#' df <- df$select(
#'   pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
#' )
#' df$select(pl$col("struct_col")$struct$field("*"))
#'
#' # Following a rename, the previous field names cannot be referenced:
#' tryCatch(
#'   {
#'     df$select(pl$col("struct_col")$struct$field("aaa"))
#'   },
#'   error = function(e) print(e)
#' )
expr_struct_rename_fields <- function(names) {
  wrap({
    check_character(names, allow_na = FALSE)
    self$`_rexpr`$struct_rename_fields(names)
  })
}

#' Convert this struct to a string column with json values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:2, c(9, 1, 3)),
#'   b = list(45, NA)
#' )$select(a = pl$struct("a", "b"))
#'
#' df
#'
#' df$with_columns(encoded = pl$col("a")$struct$json_encode())
expr_struct_json_encode <- function() {
  self$`_rexpr`$struct_json_encode() |>
    wrap()
}

#' Add or overwrite fields of this struct
#'
#' This is similar to `with_columns()` on DataFrame and LazyFrame.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Field(s) to add. Accepts
#' expression input. Strings are parsed as column names, other non-expression
#' inputs are parsed as literals.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   x = c(1, 4, 9),
#'   y = c(4, 9, 16),
#'   multiply = c(10, 2, 3)
#' )$select(coords = pl$struct("x", "y"), "multiply")
#' df
#'
#' df <- df$with_columns(
#'   pl$col("coords")$struct$with_fields(
#'     pl$field("x")$sqrt(),
#'     y_mul = pl$field("y") * pl$col("multiply")
#'   )
#' )
#'
#' df
#' df$select(pl$col("coords")$struct$field("*"))
expr_struct_with_fields <- function(...) {
  parse_into_list_of_expressions(...) |>
    self$`_rexpr`$struct_with_fields() |>
    wrap()
}

#' Expand the struct into its individual fields
#'
#' This is an alias for [`Expr$struct$field("*")`][expr_struct_field].
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   aaa = c(1, 2),
#'   bbb = c("ab", "cd"),
#'   ccc = c(TRUE, NA),
#'   ddd = list(1:2, 3)
#' )$select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))
#' df
#'
#' df$select(pl$col("struct_col")$struct$unnest())
expr_struct_unnest <- function() {
  self$field("*") |>
    wrap()
}
