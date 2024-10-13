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

# TODO: tests: pl$col("a", "b")$meta$has_multiple_outputs()
expr_meta_has_multiple_outputs <- function() {
  self$`_rexpr`$meta_has_multiple_outputs() |>
    wrap()
}

# TODO: add tests for undetermined output: pl$all()$name$suffix("_")$meta$output_name()
expr_meta_output_name <- function(..., raise_if_undetermined = TRUE) {
  wrap({
    check_dots_empty0(...)

    if (isTRUE(raise_if_undetermined)) {
      self$`_rexpr`$meta_output_name()
    } else {
      tryCatch(
        self$`_rexpr`$meta_output_name(),
        error = function(e) {
          NULL
        }
      )
    }
  })
}

# TODO: tests: pl$col("foo")$alias("bar")$meta$undo_aliases()
expr_meta_undo_aliases <- function() {
  self$`_rexpr`$meta_undo_aliases() |>
    wrap()
}

expr_meta__selector_add <- function(other) {
  self$`_rexpr`$`_meta_selector_add`(other$`_rexpr`) |>
    wrap()
}

expr_meta__selector_and <- function(other) {
  self$`_rexpr`$`_meta_selector_and`(other$`_rexpr`) |>
    wrap()
}

expr_meta__selector_sub <- function(other) {
  self$`_rexpr`$`_meta_selector_sub`(other$`_rexpr`) |>
    wrap()
}

expr_meta__as_selector <- function() {
  self$`_rexpr`$`_meta_as_selector`() |>
    wrap()
}

expr_meta_serialize <- function(..., format = c("binary", "json")) {
  wrap({
    check_dots_empty0(...)

    format <- arg_match0(format, c("binary", "json"))

    switch(format,
      binary = self$`_rexpr`$serialize_binary(),
      json = self$`_rexpr`$serialize_json(),
      abort("Unreachable")
    )
  })
}
