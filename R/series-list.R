# The env for storing all series list methods
polars_series_list_methods <- new.env(parent = emptyenv())

namespace_series_list <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_list",
    "polars_namespace_series",
    "polars_object"
  )
  self
}

#' Convert the series of type List to a series of type Struct
#'
#' @inherit as_polars_series return
#' @param fields A character vector of field names.
#' @seealso
#' - [`<expr>$list$to_struct()`][expr_list_to_struct]
#' @examples
#' # Convert list to struct with explicit field names:
#' s1 <- as_polars_series(list(0:2, 0:1))
#' s2 <- s1$list$to_struct(c("one", "two", "three"))
#' s2
#' s2$struct$fields
#'
#' # Convert list to struct with field name assignment by
#' # index from a list of names:
#' s1$list$to_struct(fields = c("one", "two", "three"))$struct$unnest()
series_list_to_struct <- function(fields) {
  wrap({
    check_character(fields, allow_na = FALSE, allow_null = FALSE)
    self$`_s`$list_to_struct(fields)
  })
}
