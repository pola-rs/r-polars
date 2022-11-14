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


#TODO contribute polars, python pl.sum(list) states uses lambda, however it is folds expressions in rust
#docs should reflect that

#' sum across expressions / literals / Series
#' @description  syntactic sugar for starting a expression with sum
#' @name sum
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#'
#' @examples
#' #column as string
#' pl$DataFrame(iris)$select(pl$sum("Petal.Width"))
#'
#' #column as Expr (prefer pl$col("Petal.Width")$sum())
#' pl$DataFrame(iris)$select(pl$sum(pl$col("Petal.Width")))
#'
#' #column as numeric
#' pl$DataFrame()$select(pl$sum(1:5))
#'
#' #column as list
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c")))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", 42L)))
#'
#' #three eqivalent lines
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", pl$sum(list("a","b","c")))))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list(pl$col("a")+pl$col("b"),"c")))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("*")))
pl$sum = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$sum())
  if (is_string(column)) return(pl$col(column)$sum())
  if (is.numeric(column)) return(pl$lit(column)$sum())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(minipolars:::sum_exprs(pra))
  }
  abort("pl$sum: this input is not supported")
}


#' min across expressions / literals / Series
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name min
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(2:1,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_),
#'   d = c(1:3,NA_real_,-Inf)
#' )
#' #use min to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$min("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$min = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$min())
  if (is_string(column)) return(pl$col(column)$min())
  if (is.numeric(column)) return(pl$lit(column)$min())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(minipolars:::min_exprs(pra))
  }
  abort("pl$min: this input is not supported")
}





#' max across expressions / literals / Series
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name max
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_)
#' )
#' #use coalesce to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$coalesce("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$max = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$max())
  if (is_string(column)) return(pl$col(column)$max())
  if (is.numeric(column)) return(pl$lit(column)$max())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(minipolars:::max_exprs(pra))
  }
  abort("pl$max: this input is not supported")
}




#' Coalesce
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name coalesce
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_)
#' )
#' #use coalesce to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$coalesce("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$coalesce = function(...) {
  column = list2(...)
  pra = do.call(construct_ProtoExprArray,column)
  minipolars:::coalesce_exprs(pra)
}

