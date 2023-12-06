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
replace_private_with_pub_methods(GroupBy, "^GroupBy_")
macro_add_syntax_check_to_class("GroupBy") # not activated automatically as GroupBy is not extendr

# LazyFrame
replace_private_with_pub_methods(RPolarsLazyFrame, "^LazyFrame_")

# LazyGroupBy
replace_private_with_pub_methods(RPolarsLazyGroupBy, "^LazyGroupBy_")

# Expr
replace_private_with_pub_methods(RPolarsExpr, "^Expr_")

# configure subnames spaces of Expr
#' @export
`$.ExprListNameSpace` = sub_name_space_accessor_function
expr_list_make_sub_ns = macro_new_subnamespace("^ExprList_", "ExprListNameSpace")

#' @export
`$.ExprStrNameSpace` = sub_name_space_accessor_function
expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "ExprStrNameSpace")

#' @export
`$.ExprNameNameSpace` = sub_name_space_accessor_function
expr_name_make_sub_ns = macro_new_subnamespace("^ExprName_", "ExprNameNameSpace")

#' @export
`$.ExprDTNameSpace` = sub_name_space_accessor_function
expr_dt_make_sub_ns = macro_new_subnamespace("^ExprDT_", "ExprDTNameSpace")

#' @export
`$.ExprStructNameSpace` = sub_name_space_accessor_function
expr_struct_make_sub_ns = macro_new_subnamespace("^ExprStruct_", "ExprStructNameSpace")

#' @export
`$.ExprMetaNameSpace` = sub_name_space_accessor_function
expr_meta_make_sub_ns = macro_new_subnamespace("^ExprMeta_", "ExprMetaNameSpace")

#' @export
`$.ExprCatNameSpace` = sub_name_space_accessor_function
expr_cat_make_sub_ns = macro_new_subnamespace("^ExprCat_", "ExprCatNameSpace")

#' @export
`$.ExprBinNameSpace` = sub_name_space_accessor_function
expr_bin_make_sub_ns = macro_new_subnamespace("^ExprBin_", "ExprBinNameSpace")

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
#' @keywords internal
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

# RThreadHandle
replace_private_with_pub_methods(RPolarsRThreadHandle, "^RThreadHandle_")

# SQLContext
replace_private_with_pub_methods(RPolarsSQLContext, "^SQLContext_")



# expression constructors, why not just pl$lit = Expr_lit?
move_env_elements(RPolarsExpr, pl, c("lit"), remove = FALSE)


#' Get Memory Address
#' @name pl_mem_address
#' @description Get underlying mem address a rust object (via ExtPtr). Expert use only.
#' @details Does not give meaningful answers for regular R objects.
#' @param robj an R object
#' @aliases mem_address
#' @return String of mem address
#' @examples pl$mem_address(pl$Series(1:3))
pl$mem_address = mem_address


# tell testthat data.table is suggested
.datatable.aware = TRUE


# subtype all public functions pl_f
for (i in names(pl)) {
  if(is.function(pl[[i]])) {
    class(pl[[i]]) = c("pl_f",class(pl[[i]]))
  }
}
#allow using [ ] as ( ) for all functions
#' @export
"[.pl_f" = \(x, ...) {
  if(is.null(formals(x))) {
    x()
  } else {
    x(...)
  }
}




.onLoad = function(libname, pkgname) {
  # instanciate one of each DataType (it's just an enum)
  all_types = .pr$DataType$get_all_simple_type_names()
  names(all_types) = all_types
  pl$dtypes = c(
    lapply(all_types, DataType_new), # instanciate all simple flag-like types
    DataType_constructors # add function constructors for the remainders
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

  # see doc below, R CMD check did not like this function def
  pl$select = .pr$DataFrame$default()$select

  # create the binding for options on loading, otherwise its values are frozen
  # to what the default values were at build time
  makeActiveBinding("options", \() as.list(polars_optenv), env = pl)
  makeActiveBinding(
    "rpool_cap",
    \(arg) {
      if (missing(arg)) {
        unwrap(get_global_rpool_cap())$capacity
      } else {
        unwrap(set_global_rpool_cap(arg))
      }
    },
    env = polars_optenv
  )
  makeActiveBinding(
    "rpool_active",
    \(arg) {
      if (missing(arg)) {
        unwrap(get_global_rpool_cap())$active
      } else {
        unwrap(stop("internal error: polars_optenv$rpool_active cannot be set directly"))
      }
    },
    env = polars_optenv
  )

  setup_renv()
  lockEnvironment(pl, bindings = TRUE)
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
