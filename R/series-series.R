# TODO: link to data type docs
# TODO: section for name spaces
#' Polars Series class (`polars_series`)
#'
#' Series are a 1-dimensional data structure, which are similar to [R vectors][vector].
#' Within a series all elements have the same Data Type.
#'
#' The `pl$Series()` function mimics the constructor of the Series class of Python Polars.
#' This function calls [as_polars_series()] internally to convert the input object to a Polars Series.
#' @aliases polars_series Series
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
wrap.PlRSeries <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x

  makeActiveBinding("dtype", function() self$`_s`$dtype() |> wrap(), self)
  makeActiveBinding("name", function() self$`_s`$name(), self)
  makeActiveBinding("shape", function() c(wrap(self$`_s`$len()), 1L), self)
  makeActiveBinding(
    "flags",
    function() {
      out <- c(
        SORTED_ASC = self$`_s`$is_sorted_ascending_flag(),
        SORTED_DESC = self$`_s`$is_sorted_descending_flag()
      )
      if (inherits(self$dtype, "polars_dtype_list")) {
        out["FAST_EXPLODE"] <- self$`_s`$can_fast_explode_flag()
      }
      out
    },
    self
  )

  lapply(names(polars_namespaces_series), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_series[[namespace]](self), self)
  })

  class(self) <- c("polars_series", "polars_object")
  self
}

series__eq <- function(other) {
  pl$select(pl$lit(self)$eq(as_polars_series(other)))$to_series() |>
    wrap()
}

series__eq_missing <- function(other) {
  pl$select(pl$lit(self)$eq_missing())$to_series() |>
    wrap()
}

series__neq <- function(other) {
  pl$select(pl$lit(self)$neq(as_polars_series(other)))$to_series() |>
    wrap()
}

series__neq_missing <- function(other) {
  pl$select(pl$lit(self)$neq_missing())$to_series() |>
    wrap()
}

series__gt <- function(other) {
  pl$select(pl$lit(self)$gt(as_polars_series(other)))$to_series() |>
    wrap()
}

series__gt_eq <- function(other) {
  pl$select(pl$lit(self)$gt_eq(as_polars_series(other)))$to_series() |>
    wrap()
}

series__lt <- function(other) {
  pl$select(pl$lit(self)$lt(as_polars_series(other)))$to_series() |>
    wrap()
}

series__lt_eq <- function(other) {
  pl$select(pl$lit(self)$lt_eq(as_polars_series(other)))$to_series() |>
    wrap()
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

#' Rename the Series
#'
#' [`<Series>$rename()`][series__rename] is an alias for [`<Series>$alias()`][series__alias].
#' @param name The new name.
#'
#' @inherit as_polars_series return
#' @examples
#' series <- pl$Series("a", 1:3)
#'
#' series$alias("b")
#' series$rename("b")
series__alias <- function(name) {
  wrap({
    s <- self$clone()

    s$`_s`$rename(name)
    s
  })
}

#' @rdname series__alias
series__rename <- series__alias

series__slice <- function(offset, length = NULL) {
  self$`_s`$slice(offset, length) |>
    wrap()
}

series__equals <- function(
  other,
  ...,
  check_dtypes = FALSE,
  check_names = FALSE,
  null_equal = TRUE
) {
  wrap({
    check_dots_empty0(...)
    check_polars_series(other)

    self$`_s`$equals(other$`_s`, check_dtypes, check_names, null_equal)
  })
}

series__cast <- function(dtype, ..., strict = TRUE) {
  wrap({
    check_polars_dtype(dtype)

    self$`_s`$cast(dtype$`_dt`, strict)
  })
}

series__reshape <- function(dimensions) {
  wrap({
    if (is.numeric(dimensions) && anyNA(dimensions)) {
      abort("`dimensions` must not contain any NA values.")
    }
    self$`_s`$reshape(dimensions)
  })
}

#' Cast this Series to a DataFrame
#'
#' @inherit pl__DataFrame return
#' @param name A character or `NULL`. If not `NULL`,
#' name/rename the [Series] column in the new [DataFrame].
#' If `NULL`, the column name is taken from the [Series] name.
#' @seealso
#' - [as_polars_df()]
#' @examples
#' s <- pl$Series("a", c(123, 456))
#' df <- s$to_frame()
#' df
#'
#' df <- s$to_frame("xyz")
#' df
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

#' Get the number of chunks that this Series contains
#'
#' @return An integer value
#' @examples
#' s <- pl$Series("a", c(1, 2, 3))
#' s$n_chunks()
#'
#' s2 <- pl$Series("a", c(4, 5, 6))
#'
#' # Concatenate Series with rechunk = TRUE
#' pl$concat(s, s2, rechunk = TRUE)$n_chunks()
#'
#' # Concatenate Series with rechunk = FALSE
#' pl$concat(s, s2, rechunk = FALSE)$n_chunks()
series__n_chunks <- function() {
  self$`_s`$n_chunks() |>
    wrap()
}

#' Get the length of each individual chunk
#'
#' @return A numeric vector
#' @examples
#' s <- pl$Series("a", c(1, 2, 3))
#' s$chunk_lengths()
#'
#' s2 <- pl$Series("a", c(4, 5, 6))
#'
#' # Concatenate Series with rechunk = TRUE
#' pl$concat(s, s2, rechunk = TRUE)$chunk_lengths()
#'
#' # Concatenate Series with rechunk = FALSE
#' pl$concat(s, s2, rechunk = FALSE)$chunk_lengths()
series__chunk_lengths <- function() {
  self$`_s`$chunk_lengths() |>
    wrap()
}

#' Create a single chunk of memory for this Series
#'
#' @inherit as_polars_series return
#' @inheritParams rlang::args_dots_empty
#' @param in_place Bool to indicate if the operation should be done in place.
#' @examples
#' s <- pl$Series("a", c(1, 2, 3))
#' s$n_chunks()
#'
#' s2 <- pl$Series("a", c(4, 5, 6))
#' s <- pl$concat(s, s2, rechunk = FALSE)
#' s$n_chunks()
#'
#' s$rechunk()$n_chunks()
series__rechunk <- function(..., in_place = FALSE) {
  wrap({
    check_dots_empty0(...)

    opt_s <- self$`_s`$rechunk(in_place)
    if (in_place) {
      self
    } else {
      opt_s |>
        .savvy_wrap_PlRSeries()
    }
  })
}
