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
#' @param fields Character vector of field names. `NULL` (default) and
#'   function-valued fields are deprecated; use an explicit character vector,
#'   which will be required in Polars 2.0.
#' @param ... A character vector of field names can be supplied as the first
#'   positional argument. Scalar `"first_non_null"` and `"max_width"` values
#'   are interpreted as legacy `n_field_strategy`; use `fields = ...` when
#'   either is a field name. Additional positional arguments are deprecated
#'   compatibility arguments.
#' @param n_field_strategy `r lifecycle::badge("deprecated")` One of
#'   `"first_non_null"` or `"max_width"`.
#'   Strategy to determine the number of fields of the struct.
#'
#'   - `"first_non_null"` (default): Set number of fields equal to
#'     the length of the first non zero-length sublist.
#'   - `"max_width"`: Set number of fields as max length of all sublists.
#'
#'   If the `fields` argument is character, this argument will be ignored.
#' @seealso
#' - [`<expr>$list$to_struct()`][expr_list_to_struct]
#' @examples
#' # Convert list to struct with explicit field names:
#' s1 <- as_polars_series(list(0:2, 0:1))
#' s2 <- s1$list$to_struct(c("one", "two", "three"))
#' s2
#' s2$struct$fields
#'
#' # Dynamic field-name functions are deprecated:
#' s3 <- s1$list$to_struct(fields = \(idx) sprintf("n%02d", idx))
#' s3$struct$fields
#'
#' # Convert list to struct with field name assignment by
#' # index from a list of names:
#' s1$list$to_struct(fields = c("one", "two", "three"))$struct$unnest()
series_list_to_struct <- function(
  ...,
  fields = NULL,
  n_field_strategy = deprecated()
) {
  fields_present <- !missing(fields)
  wrap({
    args <- parse_to_struct_args(
      ...,
      fields = fields,
      fields_present = fields_present,
      n_field_strategy = n_field_strategy,
      method = "<series>$list$to_struct()",
      max_positional = 2L,
      allow_upper_bound = FALSE
    )
    fields <- args$fields
    n_field_strategy <- args$n_field_strategy

    if (args$deprecated) {
      warn_deprecated_to_struct("<series>$list$to_struct()")
    }

    if (is_character(fields)) {
      s <- wrap(self$`_s`)
      s$to_frame()$select_seq(pl__col(s$name)$list$to_struct(fields = fields))$to_series()
    } else {
      if (!is_present(n_field_strategy)) {
        n_field_strategy <- "first_non_null"
      }
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
