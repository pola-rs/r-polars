#' field
#'
#' @aliases expr_struct_field
#' @description Retrieve a ``Struct`` field as a new Series.
#' By default base 2.
#' @keywords ExprStruct
#' @param name string, the Name of the struct field to retrieve.
#' @return Expr: Series of same and name selected field.
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
  .pr$Expr$struct_field_by_name(self, result(name)) |> unwrap("in struct$field:")
}


#' rename fields
#'
#' @aliases expr_struct_rename_fields
#' @description Rename the fields of the struct.
#' By default base 2.
#' @keywords ExprStruct
#' @param names char vec or list of strings given in the same order as the struct's fields.
#' Providing fewer names will drop the latter fields. Providing too many names is ignored.
#' @return Expr: struct-series with new names for the fields
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
  .pr$Expr$struct_rename_fields(self, result(names)) |> unwrap("in struct$rename_fields:")
}
