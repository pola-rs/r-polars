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
#' `r lifecycle::badge("experimental")`
#' Get whether the output DataType matches a certain selector.
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

#' Get a formatted version of the output DataType
#'
#' `r lifecycle::badge("experimental")`
#' Get a formatted version of the output DataType.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(x = 1:2, y = c("a", "b"), z = c(1, 2))
#' df$select(
#'   x = pl$dtype_of("x")$display(),
#'   y = pl$dtype_of("y")$display(),
#'   z = pl$dtype_of("z")$display(),
#' )$transpose(include_header = TRUE)
datatype_expr__display <- function() {
  wrap({
    self$`_datatype_expr`$display()
  })
}

#' Get the inner DataType of a List or Array
#'
#' `r lifecycle::badge("experimental")`
#' Get the inner DataType of a List or Array.
#'
#' @inherit pl__dtype_of return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1L),
#'   b = list(list("a")),
#'   c = list(data.frame(x = 1, y = 2))
#' )
#'
#' df$select(
#'   a_inner_dtype = pl$dtype_of("a")$inner_dtype()$display(),
#'   b_inner_dtype = pl$dtype_of("b")$inner_dtype()$display(),
#'   c_inner_dtype = pl$dtype_of("c")$inner_dtype()$display()
#' )
datatype_expr__inner_dtype <- function() {
  wrap({
    self$`_datatype_expr`$inner_dtype()
  })
}
