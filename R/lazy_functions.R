#' All columns
#' @name all
#' @description
#' Check if all boolean values in a Boolean column are `TRUE`.
#' This method is an expression - not to be confused with
#' `pl$all` which is a function to select all columns.
#'
#' @return Boolean literal
#'
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#'
#' @examples
#'
#' pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
pl$all = function(name=NULL) {
  if(is.null(name)) return(.pr$Expr$col("*"))
  if(is_string(name)) return(.pr$Expr$col(name)$all())
  abort("not implemented")
  #TODO implement input list of Expr as in:
  #https://github.com/pola-rs/polars/blob/589f36432de6e95e81d9715a77d6fe78360512e5/py-polars/polars/internals/lazy_functions.py#L1095
}


#' Start Expression with a column
#' @name all
#' @description
#'Return an expression representing a column in a DataFrame.
#' @param name
#' - a single column by a string
#' - all columns by using a wildcard `"*"`
#' - column by regular expression if the regex starts with `^` and ends with `$`
#'
#' @return Boolean literal
#'
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#'
#' @examples
#'
#' pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
pl$col = function(name) {
  if(is_string(name)) return(.pr$Expr$col(name))
  #TODO implement series, DataType, Sequence string, and string sequence
  abort("not implemented input")
}
