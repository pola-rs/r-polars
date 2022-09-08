#s3 wrapper for Series


#' series wrapper
#'
#' @param x input to form new series from
#' @param name name of series
#'
#' @return a polar_series object
#' @export
#'
#' @examples new_polar_series(1:3,name="some_name")
polars_series = \(x, name=NULL) {

  if(!is.null(name) && !is_string(name)) abort("name must be a string")

  private = (\(){
    if(inherits(x,"Series")) return(x)
    if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x)) {
      if(is.null(name)) name = ""
      return(minipolars:::Series$new(x,name))
    }
    abort("failed to initialize series")
  })()

  #make structure
  wrap = function(f) function(...) polars_series(f(...))

  l = list()
  l$private = private
  l$print   = private$print
  l$name    = private$name
  l$dtype   = private$dtype #R6 property feature is more suited
  l$shape   = private$shape
  l$to_r_vector = \() unwrap(private$to_r_vector())
  l$to_r        = \() unwrap(private$to_r_vector())
  l$clone = wrap(private$clone)
  l$abs        = \() polars_series(unwrap(private$abs()))
  l$abs_unsafe = \() {
    polars_series(private$abs_unsafe()) #might leak alot
  }
  l$alias   = wrap(private$alias)
  l$all     = wrap(private$all)
  l$any     = wrap(private$any)
  l$append_mut   = function(other) {
    private$append_mut(other$private)
    invisible(NULL)
  }

  l$is_unique = wrap(private$is_unique)
  l$cumsum  = \() polars_series(private$cumsum())
  l$apply   = \(fun, datatype=NULL, strict_return_type = TRUE, allow_fail_eval = FALSE) {
    if(!is.function(fun)) abort("fun arg must be a function")
    internal_datatype = (function(){
      if(is.null(datatype)) return(datatype) #same as lambda input
      if(inherits(datatype,"DataType")) return(datatype)
      if(is.character(datatype)) return(minipolars:::DataType$new("Utf8"))
      if(is.logical(datatype)) return(minipolars:::DataType$new("Boolean"))
      if(is.integer(datatype)) return(minipolars:::DataType$new("Int32"))
      if(is.double(datatype)) return(minipolars:::DataType$new("Float64"))
      abort(paste("failed to interpret datatype arg:",datatype()))
    })()

    result = private$apply(fun,internal_datatype,strict_return_type, allow_fail_eval)
    Series = unwrap(result)
    polars_series(Series)
  }
  l$to_frame = function() polar_frame$new(private$to_frame())


  class(l) <- "polars_series"
  l
}

#' @export
c.polars_series = \(x,...) {
  l = list(...)
  x = x$clone() #clone to retain an immutable api, append_mut is not mutable

  #get append function from either polars_series or Series
  fx = (function() {
    if(inherits(x,"polars_series")) return(x$private$append_mut)
    if(inherits(x,"Series")) return(x$append_mut)
    abort("internal error failed to disbatch append method")
  })()

  #append each element of i being either polars_series, Series or likely a vector
  for(i in l) {
    rser = (function() {
      if(inherits(i,"polars_series")) return(i$private)
      if(inherits(i,"Series")) return(i)
      minipolars:::Series$new(i,"anyname")
    })()
    fx(rser)
  }

  x
}

#' @export
c.Series = c.polars_series


#' Print rseries
#'
#' @param x Series

#'
#' @return selfie
#' @export
#'
#' @examples pl::series(letters,"lowercase_letters")
print.polars_series = \(x) {
  cat("polars series: ")
  x$print()
  x
}

polars_series_unwrap = function(x) {
  if(!inherits(x,"polars_series")) {
    if(inherits(x,"Series")) {
      return(x)
    } else {
      return(minipolars:::Series$new(x,""))
    }
  }
  x$private
}

series_udf_wrapper= function(f) {
  function(rs) polars_series_unwrap(f(polars_series(rs)))
}

series_udf_handler = function(f,rs) {
  fps = f(rs)
  rs_ptr_adr = xptr::xptr_address(rs)
  rs_ptr_adr
}


#' onstructor to tempoariliy replace polars_series
#'
#' @param x any vector
#' @param name string
#'
#' @return Series
#' @importFrom  rlang is_string
#' @export
#'
#' @examples Series(1:4)
series =  function(x, name=NULL){
  if(inherits(x,"Series")) return(x)
  if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x)) {
    if(is.null(name)) name = ""
    if(!is_string(name)) abort("name must be NULL or a string")
    return(minipolars:::Series$new(x,name))
  }
  abort("x must be a double, interger, char, or logical vector")
}

Series_to_r_vector = \() unwrap(.Call(wrap__Series__to_r_vector, self))
Series_abs         = \() unwrap(.Call(wrap__Series__abs, self))
Series_apply   = \(fun, datatype=NULL, strict_return_type = TRUE, allow_fail_eval = FALSE) {
  if(!is.function(fun)) abort("fun arg must be a function")
  internal_datatype = (\(){
    if(is.null(datatype)) return(datatype) #same as lambda input
    if(inherits(datatype,"DataType")) return(datatype)
    if(is.character(datatype)) return(minipolars:::DataType$new("Utf8"))
    if(is.logical(datatype)) return(minipolars:::DataType$new("Boolean"))
    if(is.integer(datatype)) return(minipolars:::DataType$new("Int32"))
    if(is.double(datatype)) return(minipolars:::DataType$new("Float64"))
    abort(paste("failed to interpret datatype arg:",datatype()))
  })()

  unwrap(.Call(
    wrap__Series__apply,
    self, fun, datatype, strict_return_type, allow_fail_eval
  ))
}


