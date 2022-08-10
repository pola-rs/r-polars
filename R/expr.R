#' construct proto Rexpr array from args
#'
#' @param ...  any Rexpr or string
#'
#' @importFrom rlang is_string
#'
#' @return ProtoRexprArray object
#'
#' @examples construct_ProtoRexprArray(pl::col("Species"),"Sepal.Width")
construct_ProtoRexprArray = function(...) {
  pra = minipolars:::ProtoRexprArray$new()
  args = list(...)
  for (i in args) {
    if (is_string(i)) {
      pra$push_back_str(i) #rust method
      next
    }
    if (inherits(i,"Rexpr")) {
      pra$push_back_rexpr(i) #rust method
      next
    }
    abort(paste("cannot handle object:", capture.output(str(i))))
  }

  pra
}

#' @export
"!.Rexpr" <- function(e1,e2) e1$not()

#' @export
"<.Rexpr" <- function(e1,e2) e1$lt(e2)

#' @export
">.Rexpr" <- function(e1,e2) e1$gt(e2)

#' @export
"==.Rexpr" <- function(e1,e2) e1$eq(e2)

#' @export
"!=.Rexpr" <- function(e1,e2) e1$neq(e2)

#' @export
"<=.Rexpr" <- function(e1,e2) e1$lt_eq(e2)

#' @export
">=.Rexpr" <- function(e1,e2) e1$gt_eq(e2)


#' polars literal
#'
#' @param x any R expression yielding an integer or float
#'
#' @return Rexpr, literal of that value
#'
#' @examples pl::lit(42L)
lit = function(x) {
  minipolars:::rlit(x)
}

