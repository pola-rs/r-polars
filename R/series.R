
#' Print Series
#'
#' @param x Series
#'
#' @return selfie
#' @export
#'
print.Series = function(x) {
  cat("polars Series: ")
  x$print()
  invisible(x)
}

#' @export
.DollarNames.Series = function(x, pattern = "") {
  paste0(ls(minipolars:::Series),"()")
}

#' Series
#'
#' @description Polars pl$Series
#' @rdname Series
#' @name Series
#'
#' @export
#' @aliases Series
#'
Series




#' Series constructor
#'
#' @description found in api as pl$Series named Series_constructor internally
#'
#' @param x any vector
#' @param name string
#' @rdname Series
#'
#' @return Series
#' @importFrom  rlang is_string
#' @export
#' @aliases Series
#'
#' @examples {
#' pl$Series(1:4)
#' }
Series_constructor =  function(x, name=NULL){
  if(inherits(x,"Series")) return(x)
  if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x)) {
    if(is.null(name)) name = ""
    if(!is_string(name)) abort("name must be NULL or a string")
    return(minipolars:::Series$new(x,name))
  }
  abort("x must be a double, interger, char, or logical vector")
}



#' @export
c.Series = \(x,...) {
  l = list(...)
  x = x$clone() #clone to retain an immutable api, append_mut is not mutable

  #append each element of i being either Series or R vector
  for(i in seq_along(l)) {
    other = l[[i]]

    #wrap in Series
    if(!inherits(other,"Series")) {
      other = pl$Series(other)
    }
    unwrap(.pr$Series$append_mut(x,other))
  }

  x
}







#' wrap as literal
#'
#' @param e an Expr(polars) or any R expression
#' @details tiny wrapper to allow skipping calling lit on rhs of binary operator
#'
#' @return Expr
#'
#' @examples pl$col("foo") < 5
wrap_s = function(x) {
  if(inherits(x,"Series")) x else pl$Series(x)
}


##make list of methods, which should be modified from Series as input
# to any type which can be converted into a series, see use of Series_ops in zzz.R
Series_ops = list()
Series_ops_add = function(name, more_args=NULL) {
  if(!is.null(more_args)) {
    attr(name,"more_args") = more_args
  }
  Series_ops <<- c(Series_ops,list(name))
}

#' @export
"+.Series" <- function(s1,s2) wrap_s(s1)$add(s2); Series_ops_add("add")
#' @export
"-.Series" <- function(s1,s2) wrap_s(s1)$sub(s2); Series_ops_add("sub")
#' @export
"/.Series" <- function(s1,s2) wrap_s(s1)$div(s2); Series_ops_add("div")
#' @export
"*.Series" <- function(s1,s2) wrap_s(s1)$mul(s2); Series_ops_add("mul")
#' @export
"%%.Series" <- function(s1,s2) wrap_s(s1)$rem(s2); Series_ops_add("rem")


Series_ops_add("compare",more_args = "op")
#' @export
"==.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"equal"))
#' @export
"!=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"not_equal"))
#' @export
"<.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"lt"))
#' @export
">.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"gt"))
#' @export
"<=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"lt_eq"))
#' @export
">=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"gt_eq"))


#' Shape of series
#'
#' @return dimension vector of Series
#' @export
#'
#' @examples identical(pl$Series(1:2)$shape, 2:1)
Series_shape = function() {
  .pr$Series$shape(self)
}
class(Series_shape) = c("property","function")

Series_udf_handler = function(f,rs) {
  fps = Series_constructor(f(rs))
  fps
  # rs_ptr_adr = xptr::xptr_address(fps)
  # rs_ptr_adr
}



#modified Series bindings

Series_to_r_vector = \() unwrap(.pr$Series$to_r_vector(self))
Series_abs         = \() unwrap(.pr$Series$abs(self))
Series_value_counts =\(sorted=TRUE, multithreaded=FALSE) {
  unwrap(.pr$Series$value_counts(self, multithreaded, sorted))
}
Series_repeat = \(name, val, n, dtype=NULL) {

  # choose dtype given val
  if(is.null(dtype)) {
    dtype = pcase(
      is.integer(val),   pl$dtypes$Int32,
      is.double(val),    pl$dtypes$Float64,
      is.character(val), pl$dtypes$Utf8,
      is.logical(val),   pl$dtypes$Boolean,
      or_else = abort(paste("must specify dtype for val: ",str(val)))
    )
  }

  #any conversion of val given dtype
  val = pcase(
    # spoof int64 by setting val to float64, correct until 2^52 or so, that's how we (R)oll
    dtype == pl$dtypes$Int64, (\() as.double(val))(),
    or_else = val
  )


  .pr$Series$repeat_(name,val,n,dtype)
}



Series_apply   = \(
  fun, datatype=NULL, strict_return_type = TRUE, allow_fail_eval = FALSE
) {

  if(!is.function(fun)) abort("fun arg must be a function")

  internal_datatype = (\(){
    if(is.null(datatype)) return(datatype) #same as lambda input
    if(inherits(datatype,"DataType")) return(datatype)
    if(is.character(datatype)) return(pl$dtypes$Utf8)
    if(is.logical(datatype)) return(pl$dtypes$Boolean)
    if(is.integer(datatype)) return(pl$dtypes$Int32)
    if(is.double(datatype)) return(pl$dtypes$Float64)
    abort(paste("failed to interpret datatype arg:",datatype()))
  })()

  unwrap(.pr$Series$apply(
    self, fun, datatype, strict_return_type, allow_fail_eval
  ))

}


#' Series_is_unique
#'
#'
#' @return Series
#' @examples
#' pl$Series(c(1:2,2L))$is_unique()
#'
Series_is_unique = function() {
  unwrap(.pr$Series$is_unique(self))
}


#' Series_all
#'
#'
#' @return bool
#' @examples
#' pl$Series(1:10)$is_unique()$all()
#'
Series_all = function() {
  unwrap(.pr$Series$all(self))
}


