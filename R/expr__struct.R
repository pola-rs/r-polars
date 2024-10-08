#' Retrieve one of the fields of this Struct as a new Series
#'
#' @param name Name of the field.
#'
#' @return Expr of datatype Struct
#' @examples
#' df = pl$DataFrame(
#'   aaa = c(1, 2),
#'   bbb = c("ab", "cd"),
#'   ccc = c(TRUE, NA),
#'   ddd = list(c(1, 2), 3)
#' )$select(
#'   pl$struct(pl$all())$alias("struct_col")
#' )
#' # struct field into a new Series
#' df$select(
#'   pl$col("struct_col")$struct$field("bbb"),
#'   pl$col("struct_col")$struct$field("ddd")
#' )
ExprStruct_field = function(name) {
  .pr$Expr$struct_field_by_name(self, name) |>
    unwrap("in $struct$field():")
}


#' Rename the fields of the struct
#'
#' @param names Vector or list of strings given in the same order as the struct's
#' fields. Providing fewer names will drop the latter fields. If too many names
#' are given, the extra names are ignored.
#'
#' @return Expr of datatype Struct
#' @examples
#' df = pl$DataFrame(
#'   aaa = 1:2,
#'   bbb = c("ab", "cd"),
#'   ccc = c(TRUE, NA),
#'   ddd = list(1:2, 3L)
#' )$select(
#'   pl$struct(pl$all())$alias("struct_col")
#' )$select(
#'   pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
#' )
#' df$unnest()
ExprStruct_rename_fields = function(names) {
  .pr$Expr$struct_rename_fields(self, names) |>
    unwrap("in $struct$rename_fields:")
}

#' Add or overwrite fields of this struct
#'
#' This is similar to [`$with_columns()`][DataFrame_with_columns] on
#' [`DataFrame`][RPolarsDataFrame]. Use [`pl$field()`][pl_field] to quickly
#' select a field in a `$struct$with_fields()` context.
#'
#' @param ... Field(s) to add. Accepts expression input. Strings are parsed as
#' column names, other non-expression inputs are parsed as literals.
#'
#' @return An [`Expr`][RPolarsExpr] of data type Struct.
#'
#' @examples
#' df = pl$DataFrame(x = c(1, 4, 9), y = c(4, 9, 16), multiply = c(10, 2, 3))$
#'   with_columns(coords = pl$struct(c("x", "y")))$
#'   select("coords", "multiply")
#'
#' df
#'
#' df = df$with_columns(
#'   pl$col("coords")$struct$with_fields(
#'     pl$field("x")$sqrt(),
#'     y_mul = pl$field("y") * pl$col("multiply")
#'   )
#' )
#'
#' df
#'
#' df$unnest("coords")
ExprStruct_with_fields = function(...) {
  .pr$Expr$struct_with_fields(self, unpack_list(..., .context = "in $struct$with_fields()")) |>
    unwrap("in $struct$with_fields:")
}
