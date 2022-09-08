#
#' @title polars-API: internal extendr bindings to polars
#' @description `.pr`
#' Contains original rextendr bindings to polars
#' @aliases  .pr
#' @usage not for public use
.pr           = new.env(parent=emptyenv())
.pr$Series    = extendr_method_to_pure_functions(minipolars:::Series)
.pr$DataFrame = extendr_method_to_pure_functions(minipolars:::DataFrame)
.pr$DataType  = extendr_method_to_pure_functions(minipolars:::DataType)






#' @title The complete minipolars public API.
#' @description `pl`-object is a list of all public functions and class constructors
#' public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions.
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


print("modifying extendr bindings, original saved in minipolars:::.pr")
env = minipolars:::Series
env$to_r_vector = Series_to_r_vector
env$to_r        = Series_to_r_vector
env$abs         = Series_abs
env$apply       = Series_apply
rm(env)


env = minipolars:::DataFrame
env$agg      = DataFrame_agg
env$as_data_frame = DataFrame_as_data_frame
env$groupby = DataFrame_groupby
env$select = DataFrame_select
env$filter = DataFrame_filter
# rm(env)
env=""
rm(env)

#
#' @title DataTypes polars types
#'
#' @name DataType
#' @description `DataType` are any types available in polars
.spoof_datatype = function(){}






#expression constructors
pl$col = Expr$col
pl$lit = Expr$lit
pl$all = Expr$all_constructor #different from Expr$all (method)

#DataFrame
pl$DataFrame = minipolars:::DataFrame_constructor

#series
pl$series    = minipolars:::series


int_env = as.environment(minipolars:::DataType)
parent.env(int_env) <- .GlobalEnv


#data loaders
pl$lazy_csv_reader = minipolars:::lazy_csv_reader
pl$csv_reader = minipolars:::csv_reader
pl$read_csv = minipolars:::read_csv_


#


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
}



