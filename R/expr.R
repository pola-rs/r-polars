#' construct proto Rexpr array from args
#'
#' @param ...  any Rexpr or string
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
