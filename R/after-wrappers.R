#' extendr methods into pure functions
#' @description self is a global of extendr wrapper methods
#' this function copies the function into a new environment and
#' modify formals to have a self argument
#'
#' @return env of pure function calls to rust
#'
extendr_method_to_pure_functions = function(env) {
  as.environment(lapply(env,function(f) {
    if(!is.function(f)) return(f)
    if("self" %in% codetools::findGlobals(f)) {
      formals(f) <- c(alist(self=),formals(f))
    }
    f
  }))
}


#' @include extendr-wrappers.R
#' @title polars-API: internal extendr bindings to polars
#' @description `.pr`
#' Contains original rextendr bindings to polars
#' @aliases  .pr
#' @examples
#' #.pr$DataFrame$print() is an external function where self is passed as arg
#' minipolars:::.pr$DataFrame$print(self = DataFrame(iris))
#' @export
.pr            = new.env(parent=emptyenv())
.pr$Series     = extendr_method_to_pure_functions(minipolars:::Series)
.pr$DataFrame  = extendr_method_to_pure_functions(minipolars:::DataFrame)
.pr$GroupBy    = NULL # derived from DataFrame in R, has no internal functions
.pr$LazyFrame  = extendr_method_to_pure_functions(minipolars:::LazyFrame)
.pr$LazyGroupBy= extendr_method_to_pure_functions(minipolars:::LazyGroupBy)
.pr$DataType   = extendr_method_to_pure_functions(minipolars:::DataType)
.pr$Expr       = extendr_method_to_pure_functions(minipolars:::Expr)
.pr$ProtoExprArray = extendr_method_to_pure_functions(minipolars:::ProtoExprArray)
#TODO remove export
