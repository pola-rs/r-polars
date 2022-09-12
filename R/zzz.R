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


# modify these Dataframe methods
env = minipolars:::DataFrame
env$as_data_frame = DataFrame_as_data_frame
env$groupby = DataFrame_groupby
env$select = DataFrame_select
env$filter = DataFrame_filter
env$groupby_agg = NULL #this method belongs to GroupBy

# GroupBy
env = minipolars:::GroupBy
env$agg = GroupBy_agg
env$as_data_frame = GroupBy_as_data_frame

# LazyFrame
env = minipolars:::LazyFrame
env$select = Lazy_select
env$groupby = Lazy_groupby

# LazyGroupBy
env = minipolars:::LazyGroupBy
env$agg = LazyGroupBy_agg
env$apply = LazyGroupBy_apply
env$head = LazyGroupBy_head
env$tail  = LazyGroupBy_tail

# Expr
env = minipolars:::Expr
env$map = Expr_map
env=""



#clean up
rm(env)




#' @title The complete minipolars public API.
#' @description `pl`-object is a list of all public functions and class constructors
#' public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions. All object-methods are accesed with $
#' via the constructed objects.
#'
#' Having all functions in an namespace is similar to the rust- and python- polars api.
#' Speaking of namespace this pl can be converted into and actual namespace by calling
#' import_polars_as_("pl"), but this not recemmended.
#' @rdname pl
#' @name pl
#' @aliases pl
#' @usage
#'
#' pl$col("colname")$sum() / pl$lit()  #expression ~ chain-method / literal-expression
#' @export
pl = new.env(parent=emptyenv())

#expression constructors
pl$col = Expr$col
pl$lit = Expr$lit
pl$all = Expr$all_constructor #different from Expr$all (method)

#DataFrame
pl$DataFrame = minipolars:::DataFrame_constructor

#pl$Series
pl$Series    = minipolars:::Series_constructor

#pl$[readers]
pl$lazy_csv_reader = minipolars:::lazy_csv_reader
pl$csv_reader = minipolars:::csv_reader
pl$read_csv = minipolars:::read_csv_

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
