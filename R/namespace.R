
#' Title
#'
#' @param ...
#'
#' @return
#' @export
#' @importFrom xptr xptr_address
#' @importFrom rlang abort
#'
#' @examples
new_df = function(...) {

  values = as.list(...)
  keys = names(values)
  unname(values)

  #pass entire dataframe from to rust side to convert
  if (!any(sapply(values,inherits,"Rseries"))) {
    return(minipolars:::Rdataframe$new(values))
  }


  #already series? send series mem pointers to rust
  pos_arg = 0
  ptr_adrs = mapply(val=values, key=keys, FUN = function(key, val) {
    pos_arg <<- pos_arg + 1
    if(is.na(key) || nchar(key)==0) abort(paste("column no.",pos_arg, "is not named"))
    if(!inherits(val,"Rseries")) {
      abort(paste("column '",key, "' is not an Rseries"))
    }
    xptr::xptr_address(val)
  })

  minipolars:::Rdataframe$from_series(ptr_adrs,ptr_adrs)

}


#' bind polars function to a namespace pl
#'
#' @return NULL
#' @export
#'
#' @examples import_polars_as_("pl")
import_polars_as_ <- function(name = "pl") {
  fake_package(
    name,
    list(
      col = minipolars:::Rexpr$col,
      df  = minipolars:::new_df,
      series = minipolars:::Rseries$new
    ),
    attach=FALSE
  )
  invisible(NULL)
}

print_Rexpr = function(x) {
  cat("polars_expr: ")
  x$print()
}

print_Rdataframe = function(x) {
  cat("polars_dataframe: ")
  x$print()
}

print_Rseries = function(x) {
  cat("polars_series: ")
  x$print()
}

.S3method("print", "Rexpr", print_Rexpr)
.S3method("print", "Rdataframe", print_Rdataframe)
.S3method("print", "Rseries", print_Rseries)
