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

# TODO: change to dynamic dots?
expr_struct_field <- function(name) {
  self$`_rexpr`$struct_field_by_name(name) |>
    wrap()
}
