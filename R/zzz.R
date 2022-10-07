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
replace_private_with_pub_methods( minipolars:::DataFrame, "^DataFrame_")



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
temp_keepers = character()
macro_add_syntax_check_to_class("Expr")
replace_private_with_pub_methods(
  minipolars:::Expr, "^Expr_",
  keep  = temp_keepers
)



#clean up
rm(env)





#TODO add to pl directly at source

#expression constructors
move_env_elements(Expr,pl,c("lit"), remove=  FALSE)
#TODO decide on namespace rules, should there be a env for methods only?

#pl$Series
pl$Series    = minipolars:::Series_constructor

#pl$[readers]
pl$lazy_csv_reader = minipolars:::lazy_csv_reader
pl$csv_reader = minipolars:::csv_reader
pl$read_csv = minipolars:::read_csv_

#functions
pl$concat = minipolars:::concat

#lazy_functions

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
