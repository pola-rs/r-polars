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




##this macro must be defined now

#' @title add syntax verification to class
#'
#' @param Class_name string name of env class
#'
#' @return dollarsign method with syntax verification
#'
#' @details this function overrides dollarclass method of a extendr env_class
#' to run first verify_method_call() to check for syntax error and return
#' more user friendly error if issues
#'
#' @seealso verify_method_call
#'
#' @examples macro_add_verify_to_class("DataFrame")
macro_add_syntax_check_to_class = function(Class_name) {
  tokens = paste0(
    "`$.",Class_name,"` <- function (self, name) {\n",
    "  verify_method_call(",Class_name,",name)\n",
    "  func <- ",Class_name,"[[name]]\n",
    "  environment(func) <- environment()\n",
    "  if(inherits(func,'property')) {\n",
    "    func()\n",
    "  } else {\n",
    "   func\n",
    "  }\n",
    "}"
  )

  eval(parse(text = tokens), envir = parent.frame())
}


##modify classes to perform syntax cheking
##this relies on no envrionment other than env_classes has been defined when macro called
##this mod should be run immediately after extendr-wrappers.R are sourced
print("add syntax checking to env_classes")
is_env_class = sapply(mget(ls()),\(x) typeof(x)=="environment")
env_class_names = names(is_env_class)[is_env_class]
for (i_class in env_class_names) {
  if(!exists(paste0("$.",i_class))) abort("internal assertion failed, env class without a dollarsign method")
  macro_add_syntax_check_to_class(i_class)
}


#' Give a class method property behavior
#' @description Internal function, see use in source
#' @param f a function
#' @return function subclassed into c("property","function")
method_as_property = function(f) {
  class(f) = c("property","function")
  f
}
