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
    if(inherits(x,"Rseries")) return(x)
    if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x)) {
      if(is.null(name)) name = ""
      return(minipolars:::Rseries$new(x,name))
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
      if(inherits(datatype,"Rdatatype")) return(datatype)
      if(is.character(datatype)) return(minipolars:::Rdatatype$new("Utf8"))
      if(is.logical(datatype)) return(minipolars:::Rdatatype$new("Boolean"))
      if(is.integer(datatype)) return(minipolars:::Rdatatype$new("Int32"))
      if(is.double(datatype)) return(minipolars:::Rdatatype$new("Float64"))
      abort(paste("failed to interpret datatype arg:",datatype()))
    })()

    result = private$apply(fun,internal_datatype,strict_return_type, allow_fail_eval)
    Rseries = unwrap(result)
    polars_series(Rseries)
  }
  l$to_frame = function() polar_frame$new(private$to_frame())


  class(l) <- "polars_series"
  l
}

#' @export
c.polars_series = \(x,...) {
  l = list(...)
  x = x$clone() #clone to retain an immutable api, append_mut is not mutable

  #get append function from either polars_series or Rseries
  fx = (function() {
    if(inherits(x,"polars_series")) return(x$private$append_mut)
    if(inherits(x,"Rseries")) return(x$append_mut)
    abort("internal error failed to disbatch append method")
  })()

  #append each element of i being either polars_series, Rseries or likely a vector
  for(i in l) {
    rser = (function() {
      if(inherits(i,"polars_series")) return(i$private)
      if(inherits(i,"Rseries")) return(i)
      minipolars:::Rseries$new(i,"anyname")
    })()
    fx(rser)
  }

  x
}

#' @export
c.Rseries = c.polars_series


#' Print rseries
#'
#' @param x Rseries

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

