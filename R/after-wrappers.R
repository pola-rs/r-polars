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
#' @title polars-API: private calls to rust-polars
#' @description `.pr`
#' Original extendr bindings converted into pure functions
#' @aliases  .pr
#' @keywords api_private
#' @examples
#' #.pr$DataFrame$print() is an external function where self is passed as arg
#' minipolars:::.pr$DataFrame$print(self = pl$DataFrame(iris))
#' @export
#' @examples
#'
#' minipolars:::print_env(.pr,".pr the collection of private method calls to rust-polars")
.pr            = new.env(parent=emptyenv())
.pr$Series     = extendr_method_to_pure_functions(minipolars:::Series)
.pr$DataFrame  = extendr_method_to_pure_functions(minipolars:::DataFrame)
.pr$GroupBy    = NULL # derived from DataFrame in R, has no  rust calls
.pr$LazyFrame  = extendr_method_to_pure_functions(minipolars:::LazyFrame)
.pr$LazyGroupBy= extendr_method_to_pure_functions(minipolars:::LazyGroupBy)
.pr$DataType   = extendr_method_to_pure_functions(minipolars:::DataType)
.pr$DataTypeVector = extendr_method_to_pure_functions(minipolars:::DataTypeVector)
.pr$Expr       = extendr_method_to_pure_functions(minipolars:::Expr)
.pr$ProtoExprArray = extendr_method_to_pure_functions(minipolars:::ProtoExprArray)
.pr$VecDataFrame = extendr_method_to_pure_functions(minipolars:::VecDataFrame)
.pr$RNullValues = extendr_method_to_pure_functions(minipolars:::RNullValues)
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
#' @examples
#' minipolars:::macro_add_syntax_check_to_class("DataFrame")
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
is_env_class = sapply(mget(ls()),\(x) typeof(x)=="environment")
env_class_names = names(is_env_class)[is_env_class]
cat("\nadd syntax check to: ")
for (i_class in env_class_names) {
  cat(i_class,", ",sep="")
  if(!exists(paste0("$.",i_class))) abort("internal assertion failed, env class without a dollarsign method")
  macro_add_syntax_check_to_class(i_class)
}
cat("\n")


#' Give a class method property behavior
#' @description Internal function, see use in source
#' @param f a function
#' @param setter bool, if true a property method can be modified by user
#' @return function subclassed into c("property","function") or c("setter","property","function")
method_as_property = function(f, setter=FALSE) {
  class(f) = if(setter) {
    c("setter","property","function")
  } else {
    c("property","function")
  }
  f
}


#' @title The complete minipolars public API.
#' @description `pl`-object is a environment of all public functions and class constructors.
#' Public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions. All object-methods are accessed with object$method()
#' via the new class functions.
#'
#' Having all functions in an namespace is similar to the rust- and python- polars api.
#' @rdname pl
#' @name pl
#' @aliases pl
#' @keywords api
#' @details If someone do not particularly like the letter combination `pl`, they are free to
#' bind the environment to another variable name as `simon_says = pl` or even do `attach(pl)`
#'
#' @export
#' @examples
#' #how to use polars via `pl`
#' pl$col("colname")$sum() / pl$lit(42L)  #expression ~ chain-method / literal-expression
#'
#' #pl inventory
#' minipolars:::print_env(pl,"minipolars public functions")
#'
#' #all accessible classes and their public methods
#' minipolars:::print_env(minipolars:::pl_pub_class_env,"minipolars public class methods, access via object$method()")
pl = new.env(parent=emptyenv())

#used for printing public environment
pl_class_names = sort(c("LazyFrame","Series","LazyGroupBy","DataType","Expr","DataFrame"))  #TODO discover all public class automatic
pl_pub_env = as.environment(asNamespace("minipolars"))
pl_pub_class_env = as.environment(mget(pl_class_names,envir=pl_pub_env))


#' @title Any minipolars class object is made of this
#' @description One SEXP of Rtype: "externalptr" + a class attribute
#' @keywords api_object
#'
#' @details
#'  - `object$method()` calls are facilitated by a `$.ClassName`- s3method see 'R/after-wrappers.R'
#'  - Code completion is facilitted by `.DollarNames.ClassName`-s3method see e.g. 'R/dataframe__frame.R'
#'  - Implementation of property-methods as DataFrame_columns() and syntax checking is an extension to `$.ClassName`
#'  See function macro_add_syntax_check_to_class().
#'
#' @export
#' @examples
#' #all a minipolars object is made of:
#' some_minipolars_object = pl$DataFrame(iris)
#' str(some_minipolars_object) #External Pointer tagged with a class attribute.
object = "place_holder"
