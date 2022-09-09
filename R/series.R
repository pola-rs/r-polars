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


#'
#' polars_pl$Series = \(x, name=NULL) {
#'
#'   if(!is.null(name) && !is_string(name)) abort("name must be a string")
#'
#'   private = (\(){
#'     if(inherits(x,"Series")) return(x)
#'     if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x)) {
#'       if(is.null(name)) name = ""
#'       return(minipolars:::Series$new(x,name))
#'     }
#'     abort("failed to initialize pl$Series")
#'   })()
#'
#'   #make structure
#'   wrap = function(f) function(...) polars_pl$Series(f(...))
#'
#'   l = list()
#'   l$private = private
#'   l$print   = private$print
#'   l$name    = private$name
#'   l$dtype   = private$dtype #R6 property feature is more suited
#'   l$shape   = private$shape
#'   l$to_r_vector = \() unwrap(private$to_r_vector())
#'   l$to_r        = \() unwrap(private$to_r_vector())
#'   l$clone = wrap(private$clone)
#'   l$abs        = \() polars_pl$Series(unwrap(private$abs()))
#'   l$abs_unsafe = \() {
#'     polars_pl$Series(private$abs_unsafe()) #might leak alot
#'   }
#'   l$alias   = wrap(private$alias)
#'   l$all     = wrap(private$all)
#'   l$any     = wrap(private$any)
#'   l$append_mut   = function(other) {
#'     private$append_mut(other$private)
#'     invisible(NULL)
#'   }
#'
#'   l$is_unique = wrap(private$is_unique)
#'   l$cumsum  = \() polars_pl$Series(private$cumsum())
#'   l$apply   = \(fun, datatype=NULL, strict_return_type = TRUE, allow_fail_eval = FALSE) {
#'     if(!is.function(fun)) abort("fun arg must be a function")
#'     internal_datatype = (function(){
#'       if(is.null(datatype)) return(datatype) #same as lambda input
#'       if(inherits(datatype,"DataType")) return(datatype)
#'       if(is.character(datatype)) return(minipolars:::DataType$new("Utf8"))
#'       if(is.logical(datatype)) return(minipolars:::DataType$new("Boolean"))
#'       if(is.integer(datatype)) return(minipolars:::DataType$new("Int32"))
#'       if(is.double(datatype)) return(minipolars:::DataType$new("Float64"))
#'       abort(paste("failed to interpret datatype arg:",datatype()))
#'     })()
#'
#'     result = private$apply(fun,internal_datatype,strict_return_type, allow_fail_eval)
#'     Series = unwrap(result)
#'     polars_pl$Series(Series)
#'   }
#'   l$to_frame = function() polar_frame$new(private$to_frame())
#'
#'
#'   class(l) <- "polars_pl$Series"
#'   l
#' }

#' @export
c.Series = \(x,...) {
  l = list(...)
  x = x$clone() #clone to retain an immutable api, append_mut is not mutable

  #get append function from either polars_pl$Series or Series
  fx = (function() {
    if(inherits(x,"polars_pl$Series")) return(x$private$append_mut)
    if(inherits(x,"Series")) return(x$append_mut)
    abort("internal error failed to disbatch append method")
  })()

  #append each element of i being either polars_pl$Series, Series or likely a vector
  for(i in l) {
    rser = (function() {
      if(inherits(i,"polars_pl$Series")) return(i$private)
      if(inherits(i,"Series")) return(i)
      minipolars:::Series$new(i,"anyname")
    })()
    fx(rser)
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
  cat("polars pl$Series: ")
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


