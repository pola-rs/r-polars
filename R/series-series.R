# TODO: create macro to create wrap S3 methods

# Allow namespace to be added from external packages
polars_namespaces_series <- new.env(parent = emptyenv())

#' @export
wrap.PlRSeries <- function(x) {
  .self <- new.env(parent = emptyenv())
  .self$`_s` <- x

  makeActiveBinding("name", function(self = .self) series_name(self), .self)

  for (namespace in names(polars_namespaces_series)) {
    local({
      namespace <- namespace
      makeActiveBinding(namespace, function(x = .self) polars_namespaces_series[[namespace]](x), .self)
    })
  }

  .self$add <- function(other) series_add(.self, other)
  .self$sub <- function(other) series_sub(.self, other)
  .self$true_div <- function(other) series_true_div(.self, other)
  .self$mul <- function(other) series_mul(.self, other)
  .self$mod <- function(other) series_mod(.self, other)

  .self$clone <- function() series_clone(.self)
  .self$rename <- function(name) series_rename(.self, name)

  class(.self) <- "polars_series"
  .self
}

#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}

series_name <- function(self) {
  self$`_s`$name()
}

series_add <- function(self, other) {
  self$`_s`$add(as_polars_series(other)$`_s`) |>
    wrap()
}

series_sub <- function(self, other) {
  self$`_s`$sub(as_polars_series(other)$`_s`) |>
    wrap()
}

series_true_div <- function(self, other) {
  self$`_s`$div(as_polars_series(other)$`_s`) |>
    wrap()
}

# TODO: implement floor_div, requires DataFrame.select_seq, col function, Expr

series_mul <- function(self, other) {
  self$`_s`$mul(as_polars_series(other)$`_s`) |>
    wrap()
}

series_mod <- function(self, other) {
  self$`_s`$rem(as_polars_series(other)$`_s`) |>
    wrap()
}

series_clone <- function(self) {
  self$`_s`$clone() |>
    wrap()
}

series_rename <- function(self, name) {
  s <- self$clone()

  s$`_s`$rename(name)
  s
}
