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
#'\dontrun{
#'  pl$Series(1:4)$apply(\(x) letters[x])
#'}
#' #The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]
#' #specifying the output DataType: Utf8 solves the problem
#' pl$Series(1:4)$apply(\(x) letters[x],datatype = pl$dtypes$Utf8)
42



datatype = function(...) {
  do.call(minipolars:::DataType$new,list2(...))
}
#' @export
"==.DataType" <- function(e1,e2) e1$eq(e2)
#' @export
"!=.DataType" <- function(e1,e2) e1$ne(e2)

#' print a polars datatype
#'
#' @param x DataType
#'
#' @return self
#' @export
#'
#' @examples minipolars:::DataType$new("Boolean")
print.DataType = function(x) {
  cat("polars DataType: ")
  x$print()
  invisible(x)
}

