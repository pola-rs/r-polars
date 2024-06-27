# The env for storing all expr meta methods
polars_expr_meta_methods <- new.env(parent = emptyenv())

namespace_expr_meta <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_meta_methods), function(name) {
    fn <- polars_expr_meta_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_expr", "polars_object"
  )
  self
}

expr_meta__selector_add <- function(other) {
  self$`_rexpr`$meta_selector_add(other$`_rexpr`) |>
    wrap()
}

expr_meta__selector_and <- function(other) {
  self$`_rexpr`$meta_selector_and(other$`_rexpr`) |>
    wrap()
}

expr_meta__selector_sub <- function(other) {
  self$`_rexpr`$meta_selector_sub(other$`_rexpr`) |>
    wrap()
}

expr_meta__as_selector <- function() {
  self$`_rexpr`$meta_as_selector() |>
    wrap()
}
