
# Build time options
build_debug_print = FALSE

#' extendr methods into pure functions
#'
#' @param env environment object output from extendr-wrappers.R classes
#' @param class_name optional class string, only used for debug printing
#' Default NULL, will infer class_name automatically
#' @keywords internal
#' @description self is a global of extendr wrapper methods
#' this function copies the function into a new environment and
#' modify formals to have a self argument
#'
#' @return env of pure function calls to rust
#'
extendr_method_to_pure_functions = function(env,class_name=NULL) {
  if(is.null(class_name)) class_name = as.character(sys.call()[2])
  e = as.environment(lapply(env,function(f) {
    if(!is.function(f)) return(f)
    if("self" %in% codetools::findGlobals(f)) {
      formals(f) <- c(alist(self=),formals(f))
    }
    f
  }))
  class(e) = c("private_polars_env", paste0("pr_",class_name) ,"environment")
  e
}


#' get private method from Class
#' @details This method if polars_optenv$debug_polars == TRUE will print what methods are called
#' @export
#' @keywords internal
"$.private_polars_env" = function(self, name) {
  #print called private class in debug mode
  if(polars_optenv$debug_polars) {
    cat(
      "[",format(subtimer_ms(),digits = 4),"ms]\n   .pr$",
      substr(class(self)[2],4,99), "$",name,"() -> ", sep= ""
    )
  }
  self[[name]]
}


#' @include extendr-wrappers.R
#' @title polars-API: private calls to rust-polars
#' @description `.pr`
#' Original extendr bindings converted into pure functions
#' @aliases  .pr
#' @keywords internal api_private
#' @export
#' @examples
#' #.pr$DataFrame$print() is an external function where self is passed as arg
#' polars:::.pr$DataFrame$print(self = pl$DataFrame(iris))
#' @keywords internal
#' @examples
#' polars:::print_env(.pr,".pr the collection of private method calls to rust-polars")
.pr            = new.env(parent=emptyenv())
.pr$Series     = extendr_method_to_pure_functions(Series)
.pr$DataFrame  = extendr_method_to_pure_functions(DataFrame)
.pr$GroupBy    = NULL # derived from DataFrame in R, has no rust calls
.pr$LazyFrame  = extendr_method_to_pure_functions(LazyFrame)
.pr$LazyGroupBy= extendr_method_to_pure_functions(LazyGroupBy)
.pr$PolarsBackgroundHandle = extendr_method_to_pure_functions(PolarsBackgroundHandle)
.pr$DataType   = extendr_method_to_pure_functions(RPolarsDataType)
.pr$DataTypeVector = extendr_method_to_pure_functions(DataTypeVector)
.pr$RField      = extendr_method_to_pure_functions(RField)
.pr$Expr       = extendr_method_to_pure_functions(Expr)
.pr$ProtoExprArray = extendr_method_to_pure_functions(ProtoExprArray)
.pr$When           = extendr_method_to_pure_functions(When)
.pr$WhenThen       = extendr_method_to_pure_functions(WhenThen)
.pr$WhenThenThen   = extendr_method_to_pure_functions(WhenThenThen)
.pr$VecDataFrame = extendr_method_to_pure_functions(VecDataFrame)
.pr$RNullValues = extendr_method_to_pure_functions(RNullValues)


#TODO remove export



##this macro must be defined now

#' @title add syntax verification to class
#' @include utils.R
#' @param Class_name string name of env class
#' @rdname macro_add_syntax_check_to
#'
#' @keywords internal
#' @return dollarsign method with syntax verification
#'
#' @details this function overrides dollarclass method of a extendr env_class
#' to run first verify_method_call() to check for syntax error and return
#' more user friendly error if issues
#'
#' All R functions coined 'macro'-functions use eval(parse()) but only at package build time
#' to solve some tricky self-referential problem. If possible to deprecate a macro in a clean way
#' , go ahead.
#'
#' see zzz.R for usage examples
#'
#' @seealso verify_method_call
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
if (build_debug_print) cat("\nadd syntax check to: ")
for (i_class in env_class_names) {
  if (build_debug_print) cat(i_class,", ",sep="")
  if(!exists(paste0("$.",i_class))) {
    stopf("internal assertion failed, env class without a dollarsign method")
  }
  macro_add_syntax_check_to_class(i_class)
}
if (build_debug_print) cat("\n")


#' Give a class method property behavior
#' @description Internal function, see use in source
#' @param f a function
#' @param setter bool, if true a property method can be modified by user
#' @keywords internal
#' @return function subclassed into c("property","function") or c("setter","property","function")
method_as_property = function(f, setter=FALSE) {
  class(f) = if(setter) {
    c("setter","property","function")
  } else {
    c("property","function")
  }
  f
}


#' @title The complete polars public API.
#' @description `pl`-object is a environment of all public functions and class constructors.
#' Public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions. All object-methods are accessed with object$method()
#' via the new class functions.
#'
#' Having all functions in an namespace is similar to the rust- and python- polars api.
#' @name pl_pl
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
#' polars:::print_env(pl,"polars public functions")
#'
#' #all accessible classes and their public methods
#' polars:::print_env(
#'   polars:::pl_pub_class_env,
#'   "polars public class methods, access via object$method()"
#' )
pl = new.env(parent=emptyenv())

class(pl) = c("pl_polars_env", "environment")



#' get public function from pl namespace/env
#' @details This method if polars_optenv$debug_polars == TRUE will print what methods are called
#' @export
#' @keywords internal
"$.pl_polars_env" = function(self, name) {
  #print called private class in debug mode
  if(polars_optenv$debug_polars) {
    cat(
      "[",format(subtimer_ms(),digits = 4),"ms]\npl$",name,"() -> ", sep= ""
    )
  }
  self[[name]]
}



#remap
DataType = clone_env_one_level_deep(RPolarsDataType)

#used for printing public environment
pl_class_names = sort(
  c("LazyFrame","Series","LazyGroupBy","DataType","Expr","DataFrame", "PolarsBackgroundHandle",
    "When", "WhenThen", "WhenThenThen"
  )
) #TODO discover all public class automaticly

pl_pub_env = as.environment(asNamespace("polars"))
pl_pub_class_env = as.environment(mget(pl_class_names,envir=pl_pub_env))


#' @title Any polars class object is made of this
#' @description One SEXP of Rtype: "externalptr" + a class attribute
#' @keywords api_object
#'
#' @details
#'  - `object$method()` calls are facilitated by a `$.ClassName`- s3method see 'R/after-wrappers.R'
#'  - Code completion is facilitted by `.DollarNames.ClassName`-s3method see e.g. 'R/dataframe__frame.R'
#'  - Implementation of property-methods as DataFrame_columns() and syntax checking is an extension to `$.ClassName`
#'  See function macro_add_syntax_check_to_class().
#'
#' @importFrom utils .DollarNames
#' @examples
#' #all a polars object is made of:
#' some_polars_object = pl$DataFrame(iris)
#' str(some_polars_object) #External Pointer tagged with a class attribute.
object = "place_holder"


