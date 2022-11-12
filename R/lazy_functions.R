#' New Expr referring to all columns
#' @name all
#' @description
#' Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by AND' method.
#'
#' @keywords Expr_new
#'
#' @return Boolean literal
#'
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#'
#' @examples
#' pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
pl$all = function(name=NULL) {

  if(is.null(name)) return(.pr$Expr$col("*"))

  abort("not implemented")
  #TODO implement input list of Expr as in:
  #https://github.com/pola-rs/polars/blob/589f36432de6e95e81d9715a77d6fe78360512e5/py-polars/polars/internals/lazy_functions.py#L1095
}


#' Start Expression with a column
#' @name col
#' @description
#'Return an expression representing a column in a DataFrame.
#' @param name
#' - a single column by a string
#' - all columns by using a wildcard `"*"`
#' - multiple columns as vector of strings
#' - column by regular expression if the regex starts with `^` and ends with `$`
#' e.g. pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))
#' - a single DataType or an R list of DataTypes, select any column of any such DataType
#' - Series of utf8 strings abiding to above options
#'
#' @return Column Exprression
#'
#' @keywords Expr_new
#' @examples
#'
#' df = pl$DataFrame(list(foo=1, bar=2L,foobar="3"))
#'
#' #a single column by a string
#' df$select(pl$col("foo"))
#'
#' #all columns by wildcard
#' df$select(pl$col("*"))
#' df$select(pl$all())
#'
#' #multiple columns as vector of strings
#' df$select(pl$col(c("foo","bar")))
#'
#' #column by regular expression if the regex starts with `^` and ends with `$`
#' df$select(pl$col("^foo.*$"))
#'
#' #a single DataType
#' df$select(pl$col(pl$dtypes$Float64))
#'
#' # ... or an R list of DataTypes, select any column of any such DataType
#' df$select(pl$col(list(pl$dtypes$Float64, pl$dtypes$Utf8)))
#'
#' # from Series of names
#' df$select(pl$col(pl$Series(c("bar","foobar"))))
pl$col = function(name) {

  #preconvert Series into char name(s)
  if(inherits(name,"Series")) name = name$to_r_vector()

  if(is_string(name)) return(.pr$Expr$col(name))
  if(is.character(name)) {
    if(any(sapply(name, \(x) {
      isTRUE(substr(x,1,1)=="^") && isTRUE(substr(x,nchar(x),nchar(x))=="$")
    }))) {
      warning("cannot use regex syntax when param name, has length > 1")
    }
    return(.pr$Expr$cols(name))
  }
  if(inherits(name, "DataType"))return(.pr$Expr$dtype_cols(construct_DataTypeVector(list(name))))
  if(is.list(name)) {
    if(all(sapply(name, inherits,"DataType"))) {
      return(.pr$Expr$dtype_cols(construct_DataTypeVector(name)))
    } else {
      abort("all elements of list must be a DataType")
    }
  }
  #TODO implement series, DataType
  abort("not supported implement input")
}


#TODO contribute polars, rewrite pl$sum(list) without python lambda but as chained add columns
pl$sum = function(column) {

  if (inherits(column, "Series")) return(column$sum())
  if (is_string(column)) return(pl$col(column)$sum())
  if (is.numeric(column)) return(pl$lit(column)$sum())

  #TODO implement fold operation
  if (is.list(column)) abort("pl$sum: list fold not implemented yet")

  abort("pl$sum: this input is not supported")
  # (Expr): use u32 as that will not cast to float as eagerly
  #return fold(lit(0).cast(UInt32), lambda a, b: a + b, column).alias("sum")

}
