# The env for storing all expr name methods
polars_expr_name_methods <- new.env(parent = emptyenv())

namespace_expr_name <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_name_methods), function(name) {
    fn <- polars_expr_name_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_expr",
    "polars_object"
  )
  self
}

expr_name_keep <- function() {
  self$`_rexpr`$name_keep() |>
    wrap()
}

expr_name_prefix <- function(prefix) {
  self$`_rexpr`$name_prefix(prefix) |>
    wrap()
}

expr_name_suffix <- function(suffix) {
  self$`_rexpr`$name_suffix(suffix) |>
    wrap()
}

expr_name_to_lowercase <- function() {
  self$`_rexpr`$name_to_lowercase() |>
    wrap()
}

expr_name_to_uppercase <- function() {
  self$`_rexpr`$name_to_uppercase() |>
    wrap()
}

expr_name_prefix_fields <- function(prefix) {
  self$`_rexpr`$name_prefix_fields(prefix) |>
    wrap()
}

expr_name_suffix_fields <- function(suffix) {
  self$`_rexpr`$name_suffix_fields(suffix) |>
    wrap()
}
