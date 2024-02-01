#' Check if two expressions are equivalent
#'
#' Indicate if this expression is the same as another expression. See also the
#' counterpart [`$meta$neq()`][ExprMeta_neq].
#'
#' @param other Expr to compare with
#' @return A boolean: `TRUE` if equal, `FALSE` otherwise
#' @examples
#' # three naive expression literals
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)
#' e3 = pl$lit(40) + 2
#'
#' # e1 and e3 are identical expressions
#' e1$meta$eq(e3)
#'
#' # when evaluated, e1 and e2 are equal
#' e1$eq(e2)$to_r()
#'
#' # however, on the meta-level, e1 and e2 are NOT identical expressions
#' e1$meta$eq(e2)
ExprMeta_eq = function(other) {
  .pr$Expr$meta_eq(self, wrap_e_result(other)) |> unwrap("in $meta$eq")
}


#' Check if two expressions are different
#'
#' Indicate if this expression is different from another expression. See also
#' the counterpart [`$meta$eq()`][ExprMeta_eq].
#'
#' @inheritParams ExprMeta_eq
#' @return A boolean: `TRUE` if different, `FALSE` otherwise
#' @examples
#' # three naive expression literals
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)
#' e3 = pl$lit(40) + 2
#'
#' # e1 and e3 are identical expressions
#' e1$meta$neq(e3)
#'
#' # when evaluated, e1 and e2 are equal
#' e1$neq(e2)$to_r()
#'
#' # however, on the meta-level, e1 and e2 are different
#' e1$meta$neq(e2)
ExprMeta_neq = function(other) {
  !(.pr$Expr$meta_eq(self, wrap_e_result(other)) |> unwrap("in $meta$neq"))
}

#' Pop
#'
#' Pop the latest expression and return the input(s) of the popped expression.
#'
#' @return A list of expressions which in most cases will have a unit length.
#'   This is not the case when an expression has multiple inputs, for instance
#'   in a [`$fold()`][pl_fold] expression.
#' @examples
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)$sum()
#'
#' e1
#' e1$meta$pop()
#'
#' e2
#' e2$meta$pop()
ExprMeta_pop = function() {
  .pr$Expr$meta_pop(self)
}


#' Get the root column names
#'
#' This returns the names of input columns. Use
#' [`$meta$output_name()`][ExprMeta_output_name] to get the name of output
#' column.
#'
#' @return A character vector
#' @examples
#' e = (pl$col("alice") + pl$col("eve"))$alias("bob")
#' e$meta$root_names()
ExprMeta_root_names = function() {
  .pr$Expr$meta_roots(self)
}

#' Get the output column names
#'
#' Get the column name that this expression would produce. It might not always
#' be possible to determine the output name as it might depend on the schema of
#' the context. In that case this will raise an error. Use
#' [`$meta$root_names()`][ExprMeta_root_names] to get the name of input column.
#'
#' @return A character vector
#' @examples
#' e = (pl$col("alice") + pl$col("eve"))$alias("bob")
#' e$meta$output_name()
ExprMeta_output_name = function() {
  .pr$Expr$meta_output_name(self) |> unwrap("in $meta$output_name")
}

#' Undo any renaming operation
#'
#' This removes any renaming operation like [`$alias()`][Expr_alias] or
#' [`$name$keep()`][ExprName_keep]. Polars uses the "leftmost rule" to determine
#' naming, meaning that the first element of the expression will be used to
#' name the output.
#'
#' @return Expr with aliases undone
#' @examples
#' e = (pl$col("alice") + pl$col("eve"))$alias("bob")
#' e$meta$output_name()
#' e$meta$undo_aliases()$meta$output_name()
ExprMeta_undo_aliases = function() {
  .pr$Expr$meta_undo_aliases(self)
}


#' Indicate if an expression has multiple outputs
#'
#' @return Boolean
#' @examples
#' e = (pl$col("alice") + pl$col("eve"))$alias("bob")
#' e$meta$has_multiple_outputs()
#'
#' # pl$all() select multiple cols to modify them, so it has multiple outputs
#' pl$all()$meta$has_multiple_outputs()
ExprMeta_has_multiple_outputs = function() {
  .pr$Expr$meta_has_multiple_outputs(self)
}


#' Indicate if an expression uses a regex projection
#'
#' @return Boolean
#' @examples
#' pl$col("^Sepal.*$")$meta$is_regex_projection()
#' pl$col("Sepal.Length")$meta$is_regex_projection()
ExprMeta_is_regex_projection = function() {
  .pr$Expr$meta_is_regex_projection(self)
}

#' Format an expression as a tree
#'
#' @param return_as_string Return the tree as a character vector? If `FALSE`
#' (default), the tree is printed in the console.
#'
#' @return
#' If `return_as_string` is `TRUE`, a character vector describing the tree.
#'
#' If `return_as_string` is `FALSE`, prints the tree in the console but doesn't
#' return any value.
#'
#'
#' @examples
#' my_expr = (pl$col("foo") * pl$col("bar"))$sum()$over(pl$col("ham")) / 2
#' my_expr$meta$tree_format()
ExprMeta_tree_format = function(return_as_string = FALSE) {
  out = .pr$Expr$meta_tree_format(self) |>
    unwrap("in $tree_format():")
  if (isTRUE(return_as_string)) {
    out
  } else {
    cat(out)
  }
}
