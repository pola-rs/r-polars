#' check if schema
#' @name is_schema
#' @param x object to test if schema
#' @return bool
#' @format function
#' @keywords functions
#' @examples
#' pl$is_schema(pl$DataFrame(iris)$schema)
#' pl$is_schema(list("alice", "bob"))
is_schema = \(x) {
  is.list(x) && !is.null(names(x)) && !anyNA(names(x)) &&
    do.call(all, lapply(x, inherits, "RPolarsDataType"))
}
pl$is_schema = is_schema


#' wrap proto schema
#' @noRd
#' @name wrap_proto_schema
#' @param x either schema, or incomplete schema where dataType can be NULL
#' or schema is just char vec, implicitly the same as if all DataType are NULL,
#' mean undefined.
#' @return bool
#' @format function
#' @keywords internal
#' @examples
#' .pr$env$wrap_proto_schema(c("alice", "bob"))
#' .pr$env$wrap_proto_schema(list("alice" = pl$Int64, "bob" = NULL))
wrap_proto_schema = function(x) {
  pcase(
    is.list(x) && !is.null(names(x)),
    x,
    is.character(x) && !anyNA(x),
    {
      names(x) = x
      lapply(x, \(x) NULL)
    },
    or_else = stopf(
      "arg schema must be a list of named DataType/RPolarsDataType or char vec of no NAs"
    )
  )
}



#' @title DataTypes (RPolarsDataType)
#'
#' @name pl_dtypes
#' @description `DataType` any polars type (ported so far)
#' @return not applicable
#' @examples
#' print(ls(pl$dtypes))
#' pl$dtypes$Float64
#' pl$dtypes$Utf8
#'
#' pl$List(pl$List(pl$UInt64))
#'
#' pl$Struct(pl$Field("CityNames", pl$Utf8))
#'
#' # The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]
#' # specifying the output DataType: Utf8 solves the problem
#' pl$Series(1:4)$apply(\(x) letters[x], datatype = pl$dtypes$Utf8)
#'
NULL



#' print a polars datatype
#'
#' @param x DataType
#' @param ... not used
#'
#' @return self
#' @export
#'
#' @keywords internal
#' @examples
#' pl$dtypes$Boolean # implicit print
print.RPolarsDataType = function(x, ...) {
  cat("DataType: ")
  x$print()
  invisible(x)
}


#' @export
"==.RPolarsDataType" = function(e1, e2) e1$eq(e2)
#' @export
"!=.RPolarsDataType" = function(e1, e2) e1$ne(e2)


#' check if x is a valid RPolarsDataType
#' @name is_polars_dtype
#' @noRd
#' @param x a candidate
#' @keywords internal
#' @return a list DataType with an inner DataType
#' @examples .pr$env$is_polars_dtype(pl$Int64)
is_polars_dtype = function(x, include_unknown = FALSE) {
  inherits(x, "RPolarsDataType") && (x != pl$Unknown || include_unknown)
}

#' check if x is a valid RPolarsDataType
#' @name same_outer_datatype
#' @param lhs an RPolarsDataType
#' @param rhs an RPolarsDataType
#' @keywords internal
#' @return bool TRUE if outer datatype is the same.
#' @examples
#' # TRUE
#' pl$same_outer_dt(pl$Datetime("us"), pl$Datetime("ms"))
#' pl$same_outer_dt(pl$List(pl$Int64), pl$List(pl$Float32))
#'
#' # FALSE
#' pl$same_outer_dt(pl$Int64, pl$Float64)
pl$same_outer_dt = function(lhs, rhs) {
  .pr$DataType$same_outer_datatype(lhs, rhs)
}


#' DataType_new (simple DataType's)
#' @noRd
#' @description Create a new flag like DataType
#' @param str name of DataType to create
#' @keywords internal
#' @details
#' This function is mainly used in `zzz.R` `.onLoad` to instantiate singletons of all
#' flag-like DataType.
#'
#' Non-flag like DataType called composite DataTypes also carries extra information
#' e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType
#' inside. Composite DataTypes use DataType constructors.
#'
#' Any DataType can be found in pl$dtypes
#'
#' @return DataType
#' @examples
#' .pr$env$DataType_new("Int64")
DataType_new = function(str) {
  .pr$DataType$new(str)
}

#' DataType_constructors (composite DataType's)
#' @description List of all composite DataType constructors
#' @keywords internal
#' @details
#' This list is mainly used in `zzz.R` `.onLoad` to instantiate singletons of all
#' flag-like DataTypes.
#'
#' Non-flag like DataType called composite DataTypes also carries extra information
#' e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType
#' inside. Composite DataTypes use DataType constructors.
#'
#' Any DataType can be found in pl$dtypes
#'
#' @return DataType
#' @examples
#' # constructors are finally available via pl$... or pl$dtypes$...
#' pl$List(pl$List(pl$Int64))
DataType_constructors = list(

  # docs bwlow pl_DataTime
  Datetime = function(tu = "us", tz = NULL) {
    if (!is.null(tz) && (!is_string(tz) || !tz %in% base::OlsonNames())) {
      stopf("Datetime: the tz '%s' is not a valid timezone string, see base::OlsonNames()", tz)
    }
    unwrap(.pr$DataType$new_datetime(tu, tz))
  },

  # doc below pl_List
  List = function(datatype = "unknown") {
    if (is.character(datatype) && length(datatype) == 1) {
      datatype = .pr$DataType$new(datatype)
    }
    if (!inherits(datatype, "RPolarsDataType")) {
      stopf(paste(
        "input for generating a list DataType must be another DataType",
        "or an interpretable name thereof."
      ))
    }
    .pr$DataType$new_list(datatype)
  },

  # doc below pl_Struct
  Struct = function(...) {
    result({
      largs = list2(...)
      if (length(largs) >= 1 && is.list(largs[[1]])) {
        largs = largs[[1]]
        element_name = "list element"
      } else {
        element_name = "positional argument"
      }
      mapply(
        names(largs) %||% character(length(largs)),
        largs,
        seq_along(largs),
        FUN = \(name, arg, i) {
          if (inherits(arg, "RPolarsDataType")) {
            return(pl$Field(name, arg))
          }
          if (inherits(arg, "RField")) {
            return(arg)
          }
          stopf(
            "%s [%s] {name:'%s', value:%s} must either be a Field (pl$Field) or a named %s",
            element_name, i, name, arg, "DataType see (pl$dtypes), see examples for pl$Struct()"
          )
        }, SIMPLIFY = FALSE
      )
    }) |>
      and_then(DataType$new_struct) |>
      unwrap("in pl$Struct:")
  }
)

#' Create Datetime DataType
#' @name pl_Datetime
#' @description Datetime DataType constructor
#' @param tu string option either "ms", "us" or "ns"
#' @param tz string the Time Zone, see details
#' @details all allowed TimeZone designations can be found in `base::OlsonNames()`
#' @keywords pl
#' @format function
#' @return Datetime DataType
#' @examples
#' pl$Datetime("ns", "Pacific/Samoa")
NULL

#' Create Struct DataType
#' @name pl_Struct_datatype
#' @description Struct DataType Constructor
#' @param datatype an inner DataType
#' @return a list DataType with an inner DataType
#' @format function
#' @examples
#' # create a Struct-DataType
#' pl$List(pl$List(pl$Boolean))
#'
#' # Find any DataType via pl$dtypes
#' print(pl$dtypes)
NULL

#' Create List DataType
#' @keywords pl
#' @name pl_List
#' @param datatype an inner DataType
#' @return a list DataType with an inner DataType
#' @format function
#' @examples pl$List(pl$List(pl$Boolean))
NULL
