#
#' @title DataTypes polars types
#'
#' @name DataType
#' @description `DataType` any polars type (ported so far)
#' @examples
#' print(ls(pl$dtypes))
#' pl$dtypes$Float64
#' pl$dtypes$Utf8
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
  cat("RPolarsDataType: ")
  x$print()
  invisible(x)
}

#' @export
"==.RPolarsDataType" <- function(e1,e2) e1$eq(e2)
#' @export
"!=.RPolarsDataType" <- function(e1,e2) e1$ne(e2)

#create any flag-like DataType
DataType_new = function(str) {
  .pr$DataType$new_list(str)
}


#' internal collection of datatype constructors
DataType_constructors = list(
  Datetime = function(tu="us", tz = NULL) {
    if (!is.null(tz) && (!is_string(tz) || !tz %in% base::OlsonNames())) {
      stopf("Datetime: the tz '%s' is not a valid timezone string, see base::OlsonNames()",tz)
    }
    unwrap(.pr$DataType$new_datetime(tu,tz))
  }
)


#' create list data type
#' @name pl_list
#' @param datatype an inner DataType
#' @return a list DataType with an inner DataType
#' @examples pl$list(pl$list(pl$Boolean))
pl$list = function(datatype) {
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
}







