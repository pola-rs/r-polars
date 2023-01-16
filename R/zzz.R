

# This file zzz.R will be sourced last when building package.
# This is important as namespaces of other files are modified here.
# This modification happens only on building the package unlike .onLoad which occours on loading the
# package.
if(build_debug_print) print(paste(
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
replace_private_with_pub_methods(DataFrame, "^DataFrame_")

# GroupBy
macro_add_syntax_check_to_class("GroupBy")
env = GroupBy
env$agg = GroupBy_agg
env$as_data_frame = GroupBy_as_data_frame

# LazyFrame
macro_add_syntax_check_to_class ("LazyFrame")
replace_private_with_pub_methods(LazyFrame, "^LazyFrame_")
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
env = LazyGroupBy
env$agg = LazyGroupBy_agg
env$apply = LazyGroupBy_apply
env$head = LazyGroupBy_head
env$tail  = LazyGroupBy_tail
rm(env)

# Expr


macro_add_syntax_check_to_class("Expr")
replace_private_with_pub_methods(Expr, "^Expr_")
expr_arr_make_sub_ns = macro_new_subnamespace("^ExprArr_", "ExprArrNameSpace")

#Series
macro_add_syntax_check_to_class("Series")
replace_private_with_pub_methods(Series, "^Series_")



#expression constructors
move_env_elements(Expr,pl,c("lit"), remove=  FALSE)


#pl$[readers]
pl$lazy_csv_reader = lazy_csv_reader
pl$csv_reader = csv_reader
pl$read_csv = read_csv_

#functions
pl$concat = concat



#' Get Memory Address
#' @name mem_address
#' @description mimics pl$mem_address
#' @param robj an R object
#' @aliases mem_address
#' @return String of mem address
#' @examples pl$mem_address(pl$Series(1:3))
pl$mem_address = mem_address



# tell testthat data.table is suggested
.datatable.aware=TRUE


.onLoad <- function(libname, pkgname){

  #instanciate one of each DataType (it's just an enum)
  all_types = .pr$DataType$get_all_simple_type_names()
  names(all_types) = all_types
  pl$dtypes = c(
    lapply(all_types,.pr$DataType$new), #instanciate all simple flag-like types
    DataType_constructors # add function constructors for the remainders
  )
  #export dtypes directly into pl, because py-polars does that
  move_env_elements(pl$dtypes,pl,names(pl$dtypes),remove = FALSE)

  # register S3 methods for packages in Suggests
  s3_register("nanoarrow::as_nanoarrow_array_stream", "DataFrame")
  s3_register("nanoarrow::infer_nanoarrow_schema", "DataFrame")
  s3_register("arrow::as_record_batch_reader", "DataFrame")
  s3_register("arrow::as_arrow_table", "DataFrame")

  pl$numeric_dtypes = pl$dtypes[substr(names(pl$dtypes),1,3) %in% c("Int","Flo")]


  #see doc below, R CMD check did not like this function def
  pl$select = pl$DataFrame(list())$select

  lockEnvironment(pl,bindings = TRUE)

}

#' Select from an empty DataFrame
#' @details
#' param ... expressions passed to select
#' `pl$select` is a shorthand for `pl$DataFrame(list())$select`
#'
#' NB param of this function
#'
#' @name pl_select
#' @keywords DataFrame
#' @return DataFrame
#' @format method
#' @examples
#' pl$select(
#'   pl$lit(1:4)$alias("ints"),
#'   pl$lit(letters[1:4])$alias("letters")
#' )
NULL

# From the `vctrs` package (this function is intended to be copied
# without attribution or license requirements to avoid a hard dependency on
# vctrs:
# https://github.com/r-lib/vctrs/blob/c2a7710fe55e3a2249c4fdfe75bbccbafcf38804/R/register-s3.R#L25-L31
s3_register <- function(generic, class, method = NULL) {
  stopifnot(is.character(generic), length(generic) == 1)
  stopifnot(is.character(class), length(class) == 1)

  pieces <- strsplit(generic, "::")[[1]]
  stopifnot(length(pieces) == 2)
  package <- pieces[[1]]
  generic <- pieces[[2]]

  caller <- parent.frame()

  get_method_env <- function() {
    top <- topenv(caller)
    if (isNamespace(top)) {
      asNamespace(environmentName(top))
    } else {
      caller
    }
  }
  get_method <- function(method, env) {
    if (is.null(method)) {
      get(paste0(generic, ".", class), envir = get_method_env())
    } else {
      method
    }
  }

  register <- function(...) {
    envir <- asNamespace(package)

    # Refresh the method each time, it might have been updated by
    # `devtools::load_all()`
    method_fn <- get_method(method)
    stopifnot(is.function(method_fn))


    # Only register if generic can be accessed
    if (exists(generic, envir)) {
      registerS3method(generic, class, method_fn, envir = envir)
    } else if (identical(Sys.getenv("NOT_CRAN"), "true")) {
      warning(sprintf(
        "Can't find generic `%s` in package %s to register S3 method.",
        generic,
        package
      ))
    }
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(packageEvent(package, "onLoad"), register)

  # Avoid registration failures during loading (pkgload or regular)
  if (isNamespaceLoaded(package)) {
    register()
  }

  invisible()
}
# nocov end
