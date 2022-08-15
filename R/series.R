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
      if(is.null(name)) name = "newname"
      return(minipolars:::Rseries$new(x,name))
    }
    abort("failed to initialize series")
  })()

  #make structure
  l = list()
  l$private = private
  l$print   = private$print
  l$name    = private$name
  l$rename  = private$rename
  l$cumsum  = \() polars_series(private$cumsum())
  l$apply   = function(fun, datatype=NULL) {
    if(is_string(datatype)) datatype = Rdatatype(datatype)
    polars_series(private$apply(fun,datatype))
  }

  class(l) <- "polars_series"
  l
}

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
