# The env for storing all datatype_expr-expr methods
polars_datatype_expr__methods <- new.env(parent = emptyenv())

namespace_datatype_expr <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_datatype_expr` <- x$`_datatype_expr`

  class(self) <- c(
    "polars_namespace_datatype_expr",
    "polars_object"
  )
  self
}

#' @export
wrap.PlRDataTypeExpr <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_datatype_expr` <- x

  class(self) <- c("polars_datatype_expr", "polars_object")
  self
}

#' Get whether the output DataType matches a certain selector
#'
#' @inherit pl__dtype_of return
#' @param selector A [selector][cs] presenting the data types to match.
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(
#'   a_is_string = pl$dtype_of("a")$matches(cs$string()),
#'   a_is_integer = pl$dtype_of("a")$matches(cs$integer()),
#' )
datatype_expr__matches <- function(selector) {
  wrap({
    check_polars_selector(selector)
    self$`_datatype_expr`$matches(selector$`_rselector`)
  })
}
