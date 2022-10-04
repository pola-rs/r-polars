#' @title Polars Expr
#'
#' @description Polars pl$Expr
#' @rdname Expr
#' @name Expr
#' @keywords Expr
#'
#' @aliases Expr
#'
#' @examples
#' #Expr has the following methods/constructors
#' ls(minipolars:::Expr)
#'
#' pl$col("this_column")$sum()$over("that_column")
42


#' Print expr
#'
#' @param x Expr
#' @keywords Expr
#'
#' @return self
#' @export
#'
#' @examples pl$col("some_column")$sum()$over("some_other_column")
print.Expr = function(x) {
  cat("polars Expr: ")
  x$print()
  invisible(x)
}

#' internal method print Expr
#' @name Expr$print()
#' @keywords Expr
#' @examples pl$DataFrame(iris)
Expr_print = function() {
  .pr$Expr$print(self)
  invisible(self)
}



#' @export
.DollarNames.Expr = function(x, pattern = "") {
  paste0(ls(minipolars:::Expr),"()")
}



#' Abs
#' @description Compute absolute values
#' @keywords Expr
#' @return Exprs abs
#' @examples
#' pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
Expr_abs = function() {
  .pr$Expr$abs(self)
}


#' Add
#' @description Addition
#' @keywords Expr
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #three syntaxes same result
#' pl$lit(5) + 10
#' pl$lit(5) + pl$lit(10)
#' pl$lit(5)$add(pl$lit(10))
Expr_add = function(other) {
  .pr$Expr$add(self, other)
}

#' aggregate groups
#' @description
#' @keywords Expr
#' Get the group indexes of the group by operation.
#' Should be used in aggregation context only.
#' @return Exprs
#' @export
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("one","one","one","two","two","two"),
#'   value =  c(94, 95, 96, 97, 97, 99)
#' ))
#' df$groupby("group", maintain_order=TRUE)$agg(pl$col("value")$agg_groups())
Expr_agg_groups = function() {
  .pr$Expr$agg_groups(self)
}


#' Rename Expr output
#' @description
#' @keywords Expr
#' Rename the output of an expression.
#' @param string new name of output
#' @return Expr
#' @examples pl$col("bob")$alias("alice")
Expr_alias = function(name) {
  .pr$Expr$alias(self, name)
}

#' All (is true)
#' @description
#' @keywords Expr
#'Check if all boolean values in a Boolean column are `TRUE`.
# This method is an expression - not to be confused with
#:`pl$all` which is a function to select all columns.
#'
#' @return Boolean literal
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$all())
Expr_all = function() {
  .pr$Expr$all(self)
}

#' Any (is true)
#' @description
#' @keywords Expr
#' Check if any boolean value in a Boolean column is `TRUE`.
#' @return Boolean literal
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$any())
Expr_any = function() {
  .pr$Expr$any(self)
}


#' Count values
#' @description
#' @keywords Expr
#' Count the number of values in this expression.
#' Similar to R length()
#' @return Expr
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$count())
Expr_count = function() {
  .pr$Expr$count(self)
}



#' construct proto Expr array from args
#'
#' @param ...  any Expr or string
#'
#' @importFrom rlang is_string
#'
#' @keywords Expr
#'
#' @return ProtoExprArray object
#'
#' @examples construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
construct_ProtoExprArray = function(...) {
  pra = minipolars:::ProtoExprArray$new()
  args = list(...)
  for (i in args) {
    if (is_string(i)) {
      pra$push_back_str(i) #rust method
      next
    }
    if (inherits(i,"Expr")) {
      pra$push_back_rexpr(i) #rust method
      next
    }
    abort(paste("cannot handle object:", capture.output(str(i))))
  }

  pra
}

#' wrap as literal
#' @param e an Expr(polars) or any R expression
#' @details tiny wrapper to allow skipping calling lit on rhs of binary operator
#' @keywords Expr
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e = function(e) {
  if(inherits(e,"Expr")) e else Expr$lit(e)
}

#' @export
"!.Expr" <- function(e1,e2) e1$not()

#' @export
"<.Expr" <- function(e1,e2) e1$lt(wrap_e(e2))

#' @export
">.Expr" <- function(e1,e2) e1$gt(wrap_e(e2))

#' @export
"==.Expr" <- function(e1,e2) e1$eq(wrap_e(e2))

#' @export
"!=.Expr" <- function(e1,e2) e1$neq(wrap_e(e2))

#' @export
"<=.Expr" <- function(e1,e2) e1$lt_eq(wrap_e(e2))

#' @export
">=.Expr" <- function(e1,e2) e1$gt_eq(wrap_e(e2))

#' @export
"+.Expr" <- function(e1,e2) e1$add(wrap_e(e2))

#' @export
"-.Expr" <- function(e1,e2) e1$sub(wrap_e(e2))

#' @export
"/.Expr" <- function(e1,e2) e1$div(wrap_e(e2))

#' @export
"*.Expr" <- function(e1,e2) e1$mul(wrap_e(e2))



#' polars map
#' @keywords Expr
#'
#' @param lambda r function mapping a series
#' @param output_type NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
#' @param `_agg_list` #not implemented yet
#'
#' @rdname Expr_map
#' @return Expr
#' @aliases Expr_map
#' @details in minipolars lambda return should be a series or any R vector convertable into a Series. In PyPolars likely return must be Series.
#' @name Expr_map
#' @examples pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) paste("cheese",as.character(x$to_r_vector())),pl$dtypes$Utf8))
Expr_map = function(lambda, output_type=NULL, `_agg_list`=NULL) {
  .pr$Expr$map(self,lambda,output_type,`_agg_list`)
}


#' polars literal
#' @keywords Expr
#'
#' @param x any R expression yielding an integer, float or bool
#' @rdname Expr
#' @return Expr, literal of that value
#' @aliases lit
#' @name lit
#' @examples pl$col("some_column") / pl$lit(42)
Expr_lit = function(x) {
  unwrap(.pr$Expr$lit(x))
}

#' polars suffix
#' @keywords Expr
#'
#' @param suffix string suffix to be added to a name
#' @rdname Expr
#' @return Expr
#' @aliases suffix
#' @name suffix
#' @examples pl$col("some")$suffix("_column")
Expr_suffix = function(suffix) {
  .pr$Expr$suffix(self, suffix)
}

#' polars prefix
#' @keywords Expr
#'
#' @param prefix string suffix to be added to a name
#' @rdname Expr
#' @return Expr
#' @aliases prefix
#' @name prefix
#' @examples pl$col("some")$suffix("_column")
Expr_prefix = function(prefix) {
  .pr$Expr$prefix(self, prefix)
}

#' polars reverse
#' @keywords Expr
#' @rdname Expr
#' @return Expr
#' @aliases reverse
#' @name prefix
#' @examples pl$DataFrame(list(a=1:5))$select(pl$col("a")$reverse())
Expr_reverse = function() {
  .pr$Expr$reverse(self)
}
