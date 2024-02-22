# This file zzz.R will be sourced last when building package.
# This is important as namespaces of other files are modified here.
# This modification happens only on building the package unlike .onLoad which occours on loading the
# package.
if (build_debug_print) {
  print(paste(
    "Modifying extendr bindings,",
    "originals converted to pure functions and saved to .pr"
  ))
}

# modify these Dataframe methods
replace_private_with_pub_methods(RPolarsDataFrame, "^DataFrame_")

# GroupBy - is special read header info in groupby.R
replace_private_with_pub_methods(RPolarsGroupBy, "^GroupBy_")
macro_add_syntax_check_to_class("RPolarsGroupBy") # not activated automatically as GroupBy is not extendr

# LazyFrame
replace_private_with_pub_methods(RPolarsLazyFrame, "^LazyFrame_")

# LazyGroupBy
replace_private_with_pub_methods(RPolarsLazyGroupBy, "^LazyGroupBy_")

# RollingGroupBy
replace_private_with_pub_methods(RPolarsRollingGroupBy, "^RollingGroupBy_")

# DynamicGroupBy
replace_private_with_pub_methods(RPolarsDynamicGroupBy, "^DynamicGroupBy_")

# Expr
replace_private_with_pub_methods(RPolarsExpr, "^Expr_")

# configure subnames spaces of Expr
#' @export
`$.RPolarsExprListNameSpace` = sub_name_space_accessor_function
expr_list_make_sub_ns = macro_new_subnamespace("^ExprList_", "RPolarsExprListNameSpace")

#' @export
`$.RPolarsExprArrNameSpace` = sub_name_space_accessor_function
expr_arr_make_sub_ns = macro_new_subnamespace("^ExprArr_", "RPolarsExprArrNameSpace")

#' @export
`$.RPolarsExprStrNameSpace` = sub_name_space_accessor_function
expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "RPolarsExprStrNameSpace")

#' @export
`$.RPolarsExprNameNameSpace` = sub_name_space_accessor_function
expr_name_make_sub_ns = macro_new_subnamespace("^ExprName_", "RPolarsExprNameNameSpace")

#' @export
`$.RPolarsExprDTNameSpace` = sub_name_space_accessor_function
expr_dt_make_sub_ns = macro_new_subnamespace("^ExprDT_", "RPolarsExprDTNameSpace")

#' @export
`$.RPolarsExprStructNameSpace` = sub_name_space_accessor_function
expr_struct_make_sub_ns = macro_new_subnamespace("^ExprStruct_", "RPolarsExprStructNameSpace")

#' @export
`$.RPolarsExprMetaNameSpace` = sub_name_space_accessor_function
expr_meta_make_sub_ns = macro_new_subnamespace("^ExprMeta_", "RPolarsExprMetaNameSpace")

#' @export
`$.RPolarsExprCatNameSpace` = sub_name_space_accessor_function
expr_cat_make_sub_ns = macro_new_subnamespace("^ExprCat_", "RPolarsExprCatNameSpace")

#' @export
`$.RPolarsExprBinNameSpace` = sub_name_space_accessor_function
expr_bin_make_sub_ns = macro_new_subnamespace("^ExprBin_", "RPolarsExprBinNameSpace")

replace_private_with_pub_methods(RPolarsWhen, "^When_")
replace_private_with_pub_methods(RPolarsThen, "^Then_")
replace_private_with_pub_methods(RPolarsChainedWhen, "^ChainedWhen_")
replace_private_with_pub_methods(RPolarsChainedThen, "^ChainedThen_")

# any sub-namespace inherits 'method_environment'
# This s3 method performs auto-completion
#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x string, name of method in method_environment (sub-namespace)
#' @param pattern code-stump as string to auto-complete
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.method_environment = function(x, pattern = "") {
  # I ponder why R chose to let attributes of environments be mutable also?!
  # temp store full class and upcast to plain environment
  old_class = class(x)
  class(x) = "environment"

  # use environment function to complete available methods
  found_usages = get_method_usages(x, pattern = pattern)

  # restore class, before returning to not cause havoc somewhere else
  class(x) = old_class
  found_usages
}


# Field
replace_private_with_pub_methods(RPolarsRField, "^RField_")

# Series
replace_private_with_pub_methods(RPolarsSeries, "^Series_")

## Add methods from Expr
add_expr_methods_to_series()


# RThreadHandle
replace_private_with_pub_methods(RPolarsRThreadHandle, "^RThreadHandle_")

# SQLContext
replace_private_with_pub_methods(RPolarsSQLContext, "^SQLContext_")

# pl top level functions
replace_private_with_pub_methods(pl, "^pl_")

# expression constructors, why not just pl$lit = Expr_lit?
move_env_elements(RPolarsExpr, pl, c("lit"), remove = FALSE)

# tell testthat data.table is suggested
.datatable.aware = TRUE

# Package startup messages must be in .onAttach(), not in .onLoad() otherwise
# R CMD check throws a NOTE. See also: https://r-pkgs.org/r-cmd-check.html#r-code
.onAttach = function(libname, pkgname) {
  # activate improved code completion in RStudio only
  if (is_rstudio()) {
    packageStartupMessage(
      "Experimental RStudio code completion with polars methods is available.\n",
      "Activate it with `polars_code_completion_activate()`."
    )
  }
}

.onLoad = function(libname, pkgname) {
  # Auto limit the max number of threads used by polars
  if (
    isFALSE(cargo_rpolars_feature_info()[["disable_limit_max_threads"]]) &&
      !isFALSE(getOption("polars.limit_max_threads")) &&
      Sys.getenv("POLARS_MAX_THREADS") == "") {
    Sys.setenv(POLARS_MAX_THREADS = 2)
    # Call polars to lock the pool size
    invisible(thread_pool_size())
    Sys.unsetenv("POLARS_MAX_THREADS")
  }

  # Set options: this has to be done first because functions in the "pl"
  # namespace (used later in .onLoad) will validate options internally.
  # We use getOption() because the user could have set some options in .Rprofile.
  # If the user didn't, then we use the default value.
  # Note that the two options relative to rpool can't be set by the user in the
  # .Rprofile because they call some Rust functions.
  options(
    polars.debug_polars = getOption("polars.debug_polars", FALSE),
    polars.df_knitr_print = getOption("polars.df_knitr_print", "auto"),
    polars.do_not_repeat_call = getOption("polars.do_not_repeat_call", FALSE),
    polars.int64_conversion = getOption("polars.int64_conversion", "double"),
    polars.maintain_order = getOption("polars.maintain_order", FALSE),
    polars.no_messages = getOption("polars.no_messages", FALSE),
    polars.rpool_active = unwrap(get_global_rpool_cap())$active,
    polars.rpool_cap = unwrap(get_global_rpool_cap())$capacity,
    polars.strictly_immutable = getOption("polars.strictly_immutable", TRUE)
  )

  # instanciate one of each DataType (it's just an enum)
  all_types = c(.pr$DataType$get_all_simple_type_names(), "Utf8") # Allow "Utf8" as an alias of "String"
  names(all_types) = all_types
  pl$dtypes = c(
    lapply(all_types, DataType_new), # instanciate all simple flag-like types
    DataType_constructors() # add function constructors for the remainders
  )

  # export dtypes directly into pl, because py-polars does that
  move_env_elements(pl$dtypes, pl, names(pl$dtypes), remove = FALSE)

  # register S3 methods for packages in Suggests
  s3_register("nanoarrow::as_nanoarrow_array_stream", "RPolarsDataFrame")
  s3_register("nanoarrow::infer_nanoarrow_schema", "RPolarsDataFrame")
  s3_register("arrow::as_record_batch_reader", "RPolarsDataFrame")
  s3_register("arrow::as_arrow_table", "RPolarsDataFrame")
  s3_register("knitr::knit_print", "RPolarsDataFrame")

  pl$numeric_dtypes = pl$dtypes[substr(names(pl$dtypes), 1, 3) %in% c("Int", "Flo")]

  setup_renv()
  lockEnvironment(pl, bindings = TRUE)
}
