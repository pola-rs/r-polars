#s3 wrapper for Series

#' Series
#'
#' @description Polars pl$Series
#' @rdname Series
#' @name Series
#'
#' @export
#' @aliases Series
#'
42

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
#' @examples Series(1:4)
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
    .pr$Series$append_mut(x,other)
  }

  x
}




#' Print rpl$Series
#'
#' @param x Series

#'
#' @return selfie
#' @export
#'
#' @examples pl$Series(letters,"lowercase_letters")
print.Series = \(x) {
  cat("polars Series: ")
  x$print()
  x
}



Series_udf_handler = function(f,rs) {
  fps = Series_constructor(f(rs))
  rs_ptr_adr = xptr::xptr_address(fps)
  rs_ptr_adr
}



#modified Series bindings


Series_to_r_vector = \() unwrap(.pr$Series$to_r_vector(self))
Series_abs         = \() unwrap(.pr$Series$abs(self))
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


