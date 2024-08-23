# TODO: link to data type docs
# TODO: name spaces
#' Polars Series class
#'
#' Series are a 1-dimensional data structure, which are similar to [R vectors][vector].
#' Within a series all elements have the same Data Type.
#'
#' The `pl$Series()` function mimics the constructor of the Series class in Python Polars.
#' This function calls [as_polars_series()] internally to convert the input object to a Polars Series.
#' @aliases polars_series
#' @section Active bindings:
#' - `dtype`: `$dtype` returns the data type of the Series.
#' - `name`: `$name` returns the name of the Series.
#' - `shape`: `$shape` returns a integer vector of length two with the number of length
#'   of the Series and width of the Series (always 1).
#' @inheritParams as_polars_series
#' @param values An R object. Passed as the `x` param of [as_polars_series()].
#' @seealso
#' - [as_polars_series()]
#' @examples
#' # Constructing a Series by specifying name and values positionally:
#' s <- pl$Series("a", 1:3)
#' s
#'
#' # Active bindings:
#' s$dtype
#' s$name
#' s$shape
pl__Series <- function(name = NULL, values = NULL) {
  wrap({
    as_polars_series(values, name = name)
  })
}

# The env storing series namespaces
polars_namespaces_series <- new.env(parent = emptyenv())

# The env for storing series methods
polars_series__methods <- new.env(parent = emptyenv())

#' @export
is_polars_series <- function(x) {
  inherits(x, "polars_series")
}

#' @export
wrap.PlRSeries <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x

  makeActiveBinding("dtype", function() self$`_s`$dtype() |> wrap(), self)
  makeActiveBinding("name", function() self$`_s`$name(), self)
  makeActiveBinding("shape", function() c(wrap(self$`_s`$len()), 1L), self)

  lapply(names(polars_series__methods), function(name) {
    fn <- polars_series__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(names(polars_namespaces_series), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_series[[namespace]](self), self)
  })

  class(self) <- c("polars_series", "polars_object")
  self
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

series__equals <- function(other, ..., check_dtypes = FALSE, check_names = FALSE, null_equal = FALSE) {
  wrap({
    check_dots_empty0(...)

    if (!isTRUE(is_polars_series(other))) {
      abort("`other` must be a polars series")
    }

    self$`_s`$equals(other$`_s`, check_dtypes, check_names, null_equal)
  })
}

series__cast <- function(dtype, ..., strict = TRUE) {
  dtype <- as_polars_dtype(dtype)
  self$`_s`$cast(dtype$`_dt`, strict) |>
    wrap()
}

series__reshape <- function(dimensions) {
  self$`_s`$reshape(dimensions) |>
    wrap()
}

# TODO: add options for ambiguous and non-existent times
# TODO: add options for i64 etc. conversion
series__to_r_vector <- function() {
  self$`_s`$to_r_vector(local_time_zone = Sys.timezone()) |>
    wrap()
}

series__to_frame <- function(name = NULL) {
  PlRDataFrame$init(
    list(as_polars_series(self, name)$`_s`)
  ) |>
    wrap()
}

series__len <- function() {
  self$`_s`$len() |>
    wrap()
}
