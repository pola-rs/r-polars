#' @title Polars Expr
#'
#' @description Polars pl$Expr
#' @rdname Expr
#' @name Expr
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
#' @rdname Expr
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



#' @export
.DollarNames.Expr = function(x, pattern = "") {
  paste0(ls(minipolars:::Expr),"()")
}


#' construct proto Expr array from args
#'
#' @param ...  any Expr or string
#'
#' @importFrom rlang is_string
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
#'
#' @param e an Expr(polars) or any R expression
#' @details tiny wrapper to allow skipping calling lit on rhs of binary operator
#'
#' @return Expr
#'
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
#' @rdname Expr
#' @return Expr
#' @aliases reverse
#' @name prefix
#' @examples pl$DataFrame(list(a=1:5))$select(pl$col("a")$reverse())
Expr_reverse = function() {
  .pr$Expr$reverse(self)
}
