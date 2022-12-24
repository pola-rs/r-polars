# This file zzz.R will be sourced last when building package.
# This is important as namespaces of other files are modified here.
# This modification happens only on building the package unlike .onLoad which occours on loading the package.

print(paste(
  "Modifying extendr bindings,",
  "originals converted to pure functions and saved to rpolars:::.pr"
))


## modify these Series methods
# env = rpolars:::Series
# env$to_r        = Series_to_r
# env$to_r_vector = Series_to_r_vector
# env$to_r_list   = Series_to_r_list
# env$abs         = Series_abs
# env$apply       = Series_apply
# env$value_counts= Series_value_counts
# env$is_unique   = Series_is_unique
# env$all         = Series_all
# env$shape       = Series_shape
# env$len         = Series_len
# env$ceil        = Series_ceil
# env$floor       = Series_floor
# env$chunk_lengths = Series_chunk_lengths
# env$append      = Series_append



# #rewrite all binary operators or other methods to accept something that can turn into a Series
# lapply(Series_ops, \(so) {
#   more_args = attr(so,"more_args")
#   if(!is.null(more_args)) more_args = paste0(", ",more_args,collapse=", ")
#
#   env[[so]] =eval(parse(text=paste0(
#     "function(other",more_args,") .Call(wrap__Series__",so,", self, wrap_s(other)",more_args,")"
#   )))
#   invisible(NULL)
# })


# modify these Dataframe methods
macro_add_syntax_check_to_class("DataFrame")
replace_private_with_pub_methods( rpolars:::DataFrame, "^DataFrame_")



# GroupBy
macro_add_syntax_check_to_class("GroupBy")
env = rpolars:::GroupBy
env$agg = GroupBy_agg
env$as_data_frame = GroupBy_as_data_frame


# LazyFrame
macro_add_syntax_check_to_class ("LazyFrame")
replace_private_with_pub_methods( rpolars:::LazyFrame, "^LazyFrame_")
# env = rpolars:::LazyFrame
# env$collect = Lazy_collect
# env$select = Lazy_select
# env$with_columns = Lazy_with_columns
# env$groupby = Lazy_groupby
# env$join    = Lazy_join
# env$limit   = Lazy_limit
# env$describe_optimized_plan = Lazy_describe_optimized_plan


# LazyGroupBy
macro_add_syntax_check_to_class("LazyGroupBy")
env = rpolars:::LazyGroupBy
env$agg = LazyGroupBy_agg
env$apply = LazyGroupBy_apply
env$head = LazyGroupBy_head
env$tail  = LazyGroupBy_tail
rm(env)

# Expr
temp_keepers = character()
macro_add_syntax_check_to_class("Expr")
replace_private_with_pub_methods(
  rpolars:::Expr, "^Expr_",
  keep  = temp_keepers
)



macro_add_syntax_check_to_class("Series")
replace_private_with_pub_methods( rpolars:::Series, "^Series_")





#expression constructors
move_env_elements(Expr,pl,c("lit"), remove=  FALSE)



#pl$[readers]
pl$lazy_csv_reader = rpolars:::lazy_csv_reader
pl$csv_reader = rpolars:::csv_reader
pl$read_csv = rpolars:::read_csv_

#functions
pl$concat = rpolars:::concat



#' Get Memory Address
#' @name mem_address
#' @description mimics pl$mem_address
#' @param robj an R object
#' @aliases mem_address
#' @return String of mem address
#' @examples pl$mem_address(pl$Series(1:3))
pl$mem_address = rpolars:::mem_address



# tell testthat data.table is suggested
.datatable.aware=TRUE


.onLoad <- function(libname, pkgname){

  #instanciate one of each DataType (it's just an enum)
  all_types = .pr$DataType$get_all_simple_type_names()
  names(all_types) = all_types
  pl$dtypes = c(
    lapply(all_types,.pr$DataType$new), #instanciate all simple flag-like types
    rpolars:::DataType_constructors # add function constructors for the remainders
  )
  #export dtypes directly into pl, because py-polars does that
  move_env_elements(pl$dtypes,pl,names(pl$dtypes),remove = FALSE)



  pl$numeric_dtypes = pl$dtypes[substr(names(pl$dtypes),1,3) %in% c("Int","Flo")]

  #' Select from an empty DataFrame
  #' @param ... expressions passed to select
  #' @details experimental
  #' @name pl_select
  #' @usage pl_select
  #' @keywords DataFrame
  #' @aliases pl_select
  #' @return DataFrame
  #'
  #' @examples pl$select(pl$lit(1:4))
  pl$select = pl$DataFrame(list())$select

  lockEnvironment(pl,bindings = TRUE)

}

print("")
print("done source")

