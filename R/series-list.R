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
#' @inheritParams expr_list_to_struct
#' @param n_field_strategy One of `"first_non_null"` or `"max_width"`.
#'   Strategy to determine the number of fields of the struct.
#'
#'   - `"first_non_null"` (default): Set number of fields equal to
#'     the length of the first non zero-length sublist.
#'   - `"max_width"`: Set number of fields as max length of all sublists.
#'
#'   If the `field` argument is character, this argument will be ignored.
#' @examples
#' # Convert list to struct with default field name assignment:
#' s1 <- as_polars_series(list(0:2, 0:1))
#' s2 <- s1$list$to_struct()
#' s2
#' s2$struct$fields
#'
#' # Convert list to struct with field name assignment by
#' # function/index:
#' s3 <- s1$list$to_struct(fields = \(idx) sprintf("n%02d", idx))
#' s3$struct$fields
#'
#' # Convert list to struct with field name assignment by
#' # index from a list of names:
#' s1$list$to_struct(fields = c("one", "two", "three"))$struct$unnest()
series_list_to_struct <- function(
  n_field_strategy = c("first_non_null", "max_width"),
  fields = NULL
) {
  wrap({
    if (is_character(fields)) {
      s <- wrap(self$`_s`)
      s$to_frame()$select_seq(pl__col(s$name)$list$to_struct(fields = fields))$to_series()
    } else {
      n_field_strategy <- arg_match0(n_field_strategy, values = c("first_non_null", "max_width"))

      name_gen <- if (is.null(fields)) {
        NULL
      } else {
        fields <- as_function(fields)
        \(idx) fields(idx)
      }

      self$`_s`$list_to_struct(n_field_strategy, name_gen)
    }
  })
}
