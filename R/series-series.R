# The env storing series namespaces
polars_namespaces_series <- new.env(parent = emptyenv())

# The env for storing series methods
polars_series__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRSeries <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x

  makeActiveBinding("name", function() self$`_s`$name(), self)

  lapply(names(polars_series__methods), function(name) {
    fn <- polars_series__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  for (namespace in names(polars_namespaces_series)) {
    local({
      namespace <- namespace
      makeActiveBinding(namespace, function() polars_namespaces_series[[namespace]](self), self)
    })
  }

  class(self) <- "polars_series"
  self
}

#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}

series__add <- function(other) {
  self$`_s`$add(as_polars_series(other)$`_s`) |>
    wrap()
}

series__sub <- function(other) {
  self$`_s`$sub(as_polars_series(other)$`_s`) |>
    wrap()
}

series__true_div <- function(other) {
  self$`_s`$div(as_polars_series(other)$`_s`) |>
    wrap()
}

# TODO: implement floor_div, requires DataFrame.select_seq, col function, Expr

series__mul <- function(other) {
  self$`_s`$mul(as_polars_series(other)$`_s`) |>
    wrap()
}

series__mod <- function(other) {
  self$`_s`$rem(as_polars_series(other)$`_s`) |>
    wrap()
}

series__clone <- function() {
  self$`_s`$clone() |>
    wrap()
}

series__rename <- function(name) {
  s <- self$clone()

  s$`_s`$rename(name)
  s
}
