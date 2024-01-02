#' Meta Equal
#'
#' @aliases expr_meta_equal
#' @description Are two expressions on a meta level equal
#' @keywords ExprMeta
#' @param other Expr to compare with
#' @return bool: TRUE if equal
#' @examples
#' # three naive expression literals
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)
#' e3 = pl$lit(40) + 2
#'
#' # e1 and e3 are identical expressions
#' e1$meta$eq(e3)
#'
#' # e_test is an expression testing whether e1 and e2 evaluates to the same value.
#' e_test = e1 == e2 # or e_test = e1$eq(e2)
#'
#' # direct evaluate e_test, possible because only made up of literals
#' e_test$to_r()
#'
#' # e1 and e2 are on the meta-level NOT identical expressions
#' e1$meta$neq(e2)
ExprMeta_eq = function(other) {
  .pr$Expr$meta_eq(self, wrap_e_result(other)) |> unwrap("in $meta$eq")
}


#' Meta Not Equal
#'
#' @aliases expr_meta_not_equal
#' @description Are two expressions on a meta level NOT equal
#' @keywords ExprMeta
#' @param other Expr to compare with
#' @return bool: TRUE if NOT equal
#' @examples
#' # three naive expression literals
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)
#' e3 = pl$lit(40) + 2
#'
#' # e1 and e3 are identical expressions
#' e1$meta$eq(e3)
#'
#' # e_test is an expression testing whether e1 and e2 evaluates to the same value.
#' e_test = e1 == e2 # or e_test = e1$eq(e2)
#'
#' # direct evaluate e_test, possible because only made up of literals
#' e_test$to_r()
#'
#' # e1 and e2 are on the meta-level NOT identical expressions
#' e1$meta$neq(e2)
ExprMeta_neq = function(other) {
  !(.pr$Expr$meta_eq(self, wrap_e_result(other)) |> unwrap("in $meta$neq"))
}

#' Pop
#'
#' @aliases expr_meta_pop
#' @description Pop the latest expression and return the input(s) of the popped expression.
#' @keywords ExprMeta
#' @return R list of Expr(s) usually one, only multiple if top Expr took more Expr as input.
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


#' Root Name
#'
#' @aliases expr_meta_root_names
#' @description Get a vector with the root column name
#' @keywords ExprMeta
#' @return R charvec of root names.
#' @examples
#' e = pl$col("alice")$alias("bob")
#' e$meta$root_names() == "alice"
#' e$meta$output_name() == "bob"
#' e$meta$undo_aliases()$meta$output_name() == "alice"
ExprMeta_root_names = function() {
  .pr$Expr$meta_roots(self)
}

#' Output Name
#'
#' @aliases expr_meta_output_names
#' @description Get the column name that this expression would produce.
#' It might not always be possible to determine the output name
#' as it might depend on the schema of the context. In that case
#' this will raise an error.
#' @keywords ExprMeta
#' @return R charvec of output names.
#' @examples
#' e = pl$col("alice")$alias("bob")
#' e$meta$root_names() == "alice"
#' e$meta$output_name() == "bob"
#' e$meta$undo_aliases()$meta$output_name() == "alice"
ExprMeta_output_name = function() {
  .pr$Expr$meta_output_name(self) |> unwrap("in $meta$output_name")
}

#' Undo aliases
#'
#' @aliases expr_meta_undo_aliases
#' @description Undo any renaming operation like ``alias`` or ``keep_name``.
#' @keywords ExprMeta
#' @return Expr with aliases undone
#' @examples
#' e = pl$col("alice")$alias("bob")
#' e$meta$root_names() == "alice"
#' e$meta$output_name() == "bob"
#' e$meta$undo_aliases()$meta$output_name() == "alice"
ExprMeta_undo_aliases = function() {
  .pr$Expr$meta_undo_aliases(self)
}


#' Has multiple outputs
#'
#' @aliases expr_has_multiple_outputs
#' @description Whether this expression expands into multiple expressions.
#' @keywords ExprMeta
#' @return Bool
#' @examples
#' pl$all()$meta$has_multiple_outputs()
#' pl$col("some_colname")$meta$has_multiple_outputs()
ExprMeta_has_multiple_outputs = function() {
  .pr$Expr$meta_has_multiple_outputs(self)
}


#' Is regex projection.
#'
#' @aliases expr_is_regex_projection
#' @description Whether this expression expands to columns that match a regex pattern.
#' @keywords ExprMeta
#' @return Bool
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
