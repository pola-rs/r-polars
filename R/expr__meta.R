#' Meta Equal
#' @name ExprMeta_eq
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
#' @name ExprMeta_neq
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
#' @name ExprMeta_pop
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
#' @name ExprMeta_root_names
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
#' @name ExprMeta_output_name
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
#' @name ExprMeta_undo_aliases
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
#' @name ExprMeta_has_multiple_outputs
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


#' Is regex projecion.
#' @name ExprMeta_is_regex_projection
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
