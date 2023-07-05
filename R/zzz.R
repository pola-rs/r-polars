# This file zzz.R will be sourced last when building package.
# This is important as namespaces of other files are modified here.
# This modification happens only on building the package unlike .onLoad which occours on loading the
# package.
if (build_debug_print) {
  print(paste(
    "Modifying extendr bindings,",
    "originals converted to pure functions and saved to polars:::.pr"
  ))
}


# modify these Dataframe methods
replace_private_with_pub_methods(DataFrame, "^DataFrame_")

# GroupBy - is special read header info in groupby.R
replace_private_with_pub_methods(GroupBy, "^GroupBy_")
macro_add_syntax_check_to_class("GroupBy") # not activated automatically as GroupBy is not extendr

# LazyFrame
replace_private_with_pub_methods(LazyFrame, "^LazyFrame_")

# LazyGroupBy
replace_private_with_pub_methods(LazyGroupBy, "^LazyGroupBy_")

# PolarsBackgroundHandle
replace_private_with_pub_methods(PolarsBackgroundHandle, "^PolarsBackgroundHandle_")

# Expr
replace_private_with_pub_methods(Expr, "^Expr_")

# configure subnames spaces of Expr
#' @export
`$.ExprArrNameSpace` = sub_name_space_accessor_function
expr_arr_make_sub_ns = macro_new_subnamespace("^ExprArr_", "ExprArrNameSpace")

#' @export
`$.ExprStrNameSpace` = sub_name_space_accessor_function
expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "ExprStrNameSpace")

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

replace_private_with_pub_methods(When, "^When_")
replace_private_with_pub_methods(WhenThen, "^WhenThen_")
replace_private_with_pub_methods(WhenThenThen, "^WhenThenThen_")



# any sub-namespace inherits 'method_environment'
# This s3 method performs auto-completion
#' @export
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
replace_private_with_pub_methods(RField, "^RField_")


# Series
replace_private_with_pub_methods(Series, "^Series_")

# RThreadHandle
replace_private_with_pub_methods(RThreadHandle, "^RThreadHandle_")

# Global R process pool configuration
pl$get_global_rpool_cap = function() get_global_rpool_cap() |> unwrap()
pl$set_global_rpool_cap = function(c) set_global_rpool_cap(c) |> unwrap() |> invisible()


# expression constructors
move_env_elements(Expr, pl, c("lit"), remove = FALSE)


#' Get Memory Address
#' @name pl_mem_address
#' @description mimics pl$mem_address
#' @param robj an R object
#' @aliases mem_address
#' @return String of mem address
#' @examples pl$mem_address(pl$Series(1:3))
pl$mem_address = mem_address



# tell testthat data.table is suggested
.datatable.aware = TRUE


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
  s3_register("nanoarrow::as_nanoarrow_array_stream", "DataFrame")
  s3_register("nanoarrow::infer_nanoarrow_schema", "DataFrame")
  s3_register("arrow::as_record_batch_reader", "DataFrame")
  s3_register("arrow::as_arrow_table", "DataFrame")
  s3_register("knitr::knit_print", "DataFrame")

  pl$numeric_dtypes = pl$dtypes[substr(names(pl$dtypes), 1, 3) %in% c("Int", "Flo")]


  # see doc below, R CMD check did not like this function def
  pl$select = .pr$DataFrame$default()$select


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
