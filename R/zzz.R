# This file zzz.R will be sourced last when building package.
# This is important as namespaces of other files are modified here.
# This modification happens only on building the package unlike .onLoad which occours on loading the package.

print(paste(
  "Modifying extendr bindings,",
  "originals converted to pure functions and saved to minipolars:::.pr"
))


## modify these Series methods
env = minipolars:::Series
env$to_r_vector = Series_to_r_vector
env$to_r        = Series_to_r_vector
env$abs         = Series_abs
env$apply       = Series_apply
env$value_counts= Series_value_counts
env$is_unique   = Series_is_unique
env$all         = Series_all
env$shape       = Series_shape

#rewrite all binary operators or other methods to accept something that can turn into a Series
lapply(Series_ops, \(so) {
  more_args = attr(so,"more_args")
  if(!is.null(more_args)) more_args = paste0(", ",more_args,collapse=", ")

  env[[so]] =eval(parse(text=paste0(
    "function(other",more_args,") .Call(wrap__Series__",so,", self, wrap_s(other)",more_args,")"
  )))
  invisible(NULL)
})


# modify these Dataframe methods
macro_add_syntax_check_to_class("DataFrame")
#browser()
env = minipolars:::DataFrame
rm(list=ls(env),envir = env)
impl_methods_DataFrame = ls(pattern="DataFrame_")
name_methods_DataFrame = sub("^DataFrame_","",impl_methods_DataFrame)

for(i in seq_along(impl_methods_DataFrame)) {
  env[[name_methods_DataFrame[i]]] = get(impl_methods_DataFrame[i])
}
#local(env,rm(list=ls()))
#browser()
# env$as_data_frame = DataFrame_as_data_frame
# env$groupby = DataFrame_groupby
# env$select = DataFrame_select
# env$with_columns = DataFrame_with_columns
# env$filter = DataFrame_filter
# #env$groupby_agg = NULL #this method belongs to GroupBy
# env$get_column = DataFrame_get_column
# env$join = DataFrame_join
# env$limit = DataFrame_limit
# env$shap




# GroupBy
macro_add_syntax_check_to_class("GroupBy")
env = minipolars:::GroupBy
env$agg = GroupBy_agg
env$as_data_frame = GroupBy_as_data_frame


# LazyFrame
macro_add_syntax_check_to_class ("LazyFrame")
env = minipolars:::LazyFrame
env$collect = Lazy_collect
env$select = Lazy_select
env$with_columns = Lazy_with_columns
env$groupby = Lazy_groupby
env$join    = Lazy_join
env$limit   = Lazy_limit
env$Lazy_describe_optimized_plan = Lazy_describe_optimized_plan


# LazyGroupBy
macro_add_syntax_check_to_class("LazyGroupBy")
env = minipolars:::LazyGroupBy
env$agg = LazyGroupBy_agg
env$apply = LazyGroupBy_apply
env$head = LazyGroupBy_head
env$tail  = LazyGroupBy_tail

# Expr
macro_add_syntax_check_to_class("Expr")
env = minipolars:::Expr
env$map = Expr_map
env$lit = Expr_lit
env$prefix = Expr_prefix
env$suffix = Expr_suffix
env$reverse = Expr_reverse
env=""



#clean up
rm(env)




#' @title The complete minipolars public API.
#' @description `pl`-object is a list of all public functions and class constructors
#' public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions. All object-methods are accesed with object$method
#' via the constructed objects.
#'
#' Having all functions in an namespace is similar to the rust- and python- polars api.
#' Speaking of namespace this pl can be converted into and actual namespace by calling
#' import_polars_as_("pl"), but this not recemmended.
#' @rdname pl
#' @name pl
#' @aliases pl
#'
#' pl$col("colname")$sum() / pl$lit()  #expression ~ chain-method / literal-expression
#' @export
pl = new.env(parent=emptyenv())

#expression constructors
move_env_elements(Expr,pl,c("col","lit",all="all_constructor"), remove=  FALSE)
#TODO decide on namespace rules, should there be a env for methods only?

#DataFrame
pl$DataFrame = minipolars:::DataFrame_constructor

#pl$Series
pl$Series    = minipolars:::Series_constructor

#pl$[readers]
pl$lazy_csv_reader = minipolars:::lazy_csv_reader
pl$csv_reader = minipolars:::csv_reader
pl$read_csv = minipolars:::read_csv_

#functions
pl$concat = minipolars:::concat

#TODO simplify maybe datatype should not be generated from strings
.onLoad <- function(libname, pkgname){
  pl$dtypes = list(
    Float64 = DataType$new("Float64"),
    Float32 = DataType$new("Float32"),
    Int64 = DataType$new("Int64"),
    Int32 = DataType$new("Int32"),
    Boolean = DataType$new("Boolean"),
    Utf8 = DataType$new("Utf8")
  )
  lockEnvironment(pl,bindings = TRUE)
}
