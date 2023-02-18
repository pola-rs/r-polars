#' @title DataTypes polars types
#'
#' @name DataType
#' @description `DataType` any polars type (ported so far)
#' @examples
#' print(ls(pl$dtypes))
#' pl$dtypes$Float64
#' pl$dtypes$Utf8
#'
#' pl$List(pl$List(pl$UInt64))
#'
#' pl$Struct(pl$Field("CityNames", pl$Utf8))
#'
#' # Some DataType use case, this user function fails because....
#' \dontrun{
#'   pl$Series(1:4)$apply(\(x) letters[x])
#' }
#' #The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]
#' #specifying the output DataType: Utf8 solves the problem
#' pl$Series(1:4)$apply(\(x) letters[x],datatype = pl$dtypes$Utf8)
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
#' @examples
#' pl$dtypes$Boolean #implicit print
print.RPolarsDataType = function(x, ...) {
  cat("DataType: ")
  x$print()
  invisible(x)
}


#' @export
"==.RPolarsDataType" <- function(e1,e2) e1$eq(e2)
#' @export
"!=.RPolarsDataType" <- function(e1,e2) e1$ne(e2)


#' chek if x is a valid RPolarsDataType
#' @name is_polars_dtype
#' @param x a candidate
#' @keywords internal
#' @return a list DataType with an inner DataType
#' @examples rpolars:::is_polars_dtype(pl$Int64)
is_polars_dtype = function(x, include_unknown = FALSE) {
  inherits(x,"RPolarsDataType") && (x != pl$Unknown || include_unknown)
}

#' check if x is a valid RPolarsDataType
#' @name same_outer_datatype
#' @param lhs an RPolarsDataType
#' @param rhs an RPolarsDataType
#' @keywords internal
#' @return bool TRUE if outer datatype is the same.
#' @examples
#' # TRUE
#' pl$same_outer_dt(pl$Datetime("us"),pl$Datetime("ms"))
#' pl$same_outer_dt(pl$List(pl$Int64),pl$List(pl$Float32))
#'
#' #FALSE
#' pl$same_outer_dt(pl$Int64,pl$Float64)
pl$same_outer_dt = function(lhs, rhs) {
  .pr$DataType$same_outer_datatype(lhs,rhs)
}


#' DataType_new (simple DataType's)
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
#' rpolars:::DataType_new("Int64")
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
#' #constructors are finally available via pl$... or pl$dtypes$...
#' pl$List(pl$List(pl$Int64))
DataType_constructors = list(

  #docs bwlow pl_DataTime
  Datetime = function(tu="us", tz = NULL) {
    if (!is.null(tz) && (!is_string(tz) || !tz %in% base::OlsonNames())) {
      stopf("Datetime: the tz '%s' is not a valid timezone string, see base::OlsonNames()",tz)
    }
    unwrap(.pr$DataType$new_datetime(tu,tz))
  },

  #doc below pl_List
  List = function(datatype) {
    if(is.character(datatype) && length(datatype)==1 ) {
      datatype = .pr$DataType$new(datatype)
    }
    if(!inherits(datatype,"RPolarsDataType")) {
      stopf(paste(
        "input for generating a list DataType must be another DataType",
        "or an interpretable name thereof."
      ))
    }
    .pr$DataType$new_list(datatype)
  },

  #doc below pl_Struct
  Struct = function(...) {
    largs = list2(...)
    if (is.list(largs[[1]])) {
       rpolars:::DataType$new_struct(largs[[1]])
    } else {
       rpolars:::DataType$new_struct(largs)
    } |> unwrap()
  }

)

#' Create Datetime DataType
#' @name pl_Datetime
#' @description Datetime DataType constructor
#' @param tu string option either "ms", "us" or "ns"
#' @param tz string the Time Zone, see details
#' @details all allowed TimeZone designations can be found in `base::OlsonNames()`
#' @format function
#' @return Datetime DataType
#' @examples
#' pl$Datetime("ns","Pacific/Samoa")
NULL

#' Create Struct DataType
#' @name pl_Struct
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
#' @name pl_List
#' @param datatype an inner DataType
#' @return a list DataType with an inner DataType
#' @format function
#' @examples pl$List(pl$List(pl$Boolean))
NULL




