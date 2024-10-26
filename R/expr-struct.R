# The env for storing all expr struct methods
polars_expr_struct_methods <- new.env(parent = emptyenv())

namespace_expr_struct <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_struct_methods), function(name) {
    fn <- polars_expr_struct_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_expr", "polars_struct_namespace", "polars_object"
  )
  self
}

expr_struct_field_by_index <- function(index) {
  self$`_rexpr`$struct_field_by_index(index) |>
    wrap()
}

expr_struct_field <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...) |>
      unlist(recursive = FALSE)
    check_character(dots, arg = "...", allow_na = FALSE)

    self$`_rexpr`$struct_multiple_fields(dots)
  })
}

expr_struct_rename_fields <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...) |>
      unlist(recursive = FALSE)
    check_character(dots, arg = "...", allow_na = FALSE)

    self$`_rexpr`$struct_rename_fields(dots)
  })
}

expr_struct_json_encode <- function() {
  self$`_rexpr`$struct_json_encode() |>
    wrap()
}

expr_struct_with_fields <- function(...) {
  parse_into_list_of_expressions(...) |>
    self$`_rexpr`$struct_with_fields() |>
    wrap()
}
