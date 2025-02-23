# The env for storing all series struct methods
polars_series_struct_methods <- new.env(parent = emptyenv())

namespace_series_struct <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  makeActiveBinding("fields", function() self$`_s`$struct_fields(), self)

  lapply(names(polars_series_struct_methods), function(name) {
    fn <- polars_series_struct_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  # Dispatch expr struct methods
  lapply(setdiff(names(polars_expr_struct_methods), names(self)), function(name) {
    fn <- polars_expr_struct_methods[[name]]
    wraped_fn <- expr_wrap_function_factory(fn, self)
    assign(name, wraped_fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_series",
    "polars_struct_namespace",
    "polars_object"
  )
  self
}

#' Convert this struct Series to a DataFrame with a separate column for each field
#'
#' @inherit pl__DataFrame return
#' @inherit series__to_frame seealso
#' @examples
#' s <- as_polars_series(data.frame(a = c(1, 3), b = c(2, 4)))
#' s$struct$unnest()
series_struct_unnest <- function() {
  self$`_s`$struct_unnest() |>
    wrap()
}
