#' Meta Equal
#' @name ExprMeta_eq
#' @aliases expr_meta_equal
#' @description Are two expressions on a meta level equal
#' @keywords ExprMeta
#' @param other Expr to compare with
#' @return bool: TRUE if equal
#' @examples
#' #three naive expression literals
#' e1 = pl$lit(40) + 2
#' e2 = pl$lit(42)
#' e3 = pl$lit(40) +2
#'
#' #e1 and e3 are identical expressions
#' e1$meta$eq(e3)
#'
#' #e_test is an expression testing whether e1 and e2 evaluates to the same value.
#' e_test = e1 == e2 # or e_test = e1$eq(e2)
#'
#' #direct evaluate e_test, possible because only made up of literals
#' e_test$to_r()
#'
#' #e1 and e2 are on the meta-level NOT identical expressions
#' e1$meta$neq(e2)
ExprBin_contains = function(lit) {
  .pr$Expr$meta_eq(self, wrap_e_result(other)) |> unwrap("in $meta$eq")
}

