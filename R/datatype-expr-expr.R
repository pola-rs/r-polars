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

#' Get a default value of a specific type
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' Get a default value of a specific type:
#' - Integers and floats are their zero value as default, unless otherwise
#'   specified;
#' - Temporals are a physical zero as default;
#' - `pl$Decimal` is zero as default;
#' - `pl$String` and `pl$Binary` are an empty string;
#' - `pl$List` is an empty list, unless otherwise specified;
#' - `pl$Array` is the inner default value repeated over the shape;
#' - `pl$Struct` is the inner default value for all fields;
#' - `pl$Enum` is the first category if it exists;
#' - `pl$Null` and `pl$Categorical` are `null`.
#'
#' @inheritParams rlang::args_dots_empty
#' @param n Number of types you want the value.
#' @param numeric_to_one Use `1` instead of `0` as the default value for numeric
#' types.
#' @param num_list_values The amount of values a list contains.
#'
#' @inherit as_polars_expr
#' @examples
#' uint32 <- pl$UInt32$to_dtype_expr()
#' string <- pl$String$to_dtype_expr()
#' array <- pl$Array(pl$Float64, 2)$to_dtype_expr()
#'
#' pl$select(
#'   uint32_default = uint32$default_value(),
#'   uint32_default_bis = uint32$default_value(numeric_to_one = TRUE),
#'   string_default = string$default_value(),
#'   array_default = array$default_value()
#' )
#'
#' # Return more values with `n`
#' pl$select(uint32_default = uint32$default_value(n = 3))
#'
#' # Customize the number of default values in a list with `num_list_values`
#' l <- pl$List(pl$Float64)$to_dtype_expr()
#' pl$select(
#'   list_default = l$default_value(),
#'   list_default_bis = l$default_value(num_list_values = 3),
#' )
datatype_expr__default_value <- function(n = 1, ..., numeric_to_one = FALSE, num_list_values = 0) {
  wrap({
    check_dots_empty0(...)
    self$`_datatype_expr`$default_value(
      n = n,
      numeric_to_one = numeric_to_one,
      num_list_values = num_list_values
    )
  })
}
