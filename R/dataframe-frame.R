# TODO: link to data type docs
# TODO: link to pl__select
#' Polars DataFrame class (`polars_data_frame`)
#'
#' DataFrames are two-dimensional data structure representing data
#' as a table with rows and columns. Polars DataFrames are similar to
#' [R Data Frames][data.frame]. R Data Frame's columns are [R vectors][vector],
#' while Polars DataFrame's columns are [Polars Series][Series].
#'
#' The `pl$DataFrame()` function mimics the constructor of the DataFrame class of Python Polars.
#' This function is basically a shortcut for `list(...) |> as_polars_df()`,
#' so each argument in `...` is converted to a Polars Series by [as_polars_series()]
#' and then passed to [as_polars_df()].
#' @aliases polars_data_frame DataFrame
#' @section Active bindings:
#' - `columns`: `$columns` returns a character vector with the names of the columns.
#' - `dtypes`: `$dtypes` returns a nameless list of the data type of each column.
#' - `schema`: `$schema` returns a named list with the column names as names and the data types as values.
#' - `shape`: `$shape` returns a integer vector of length two with the number of rows and columns of the DataFrame.
#' - `height`: `$height` returns a integer with the number of rows of the DataFrame.
#' - `width`: `$width` returns a integer with the number of columns of the DataFrame.
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Name-value pairs of objects to be converted to polars [Series]
#' by the [as_polars_series()] function.
#' Each [Series] will be used as a column of the [DataFrame].
#' All values must be the same length.
#' Each name will be used as the column name. If the name is empty,
#' the original name of the [Series] will be used.
#' @return A polars [DataFrame]
#' @examples
#' # Constructing a DataFrame from vectors:
#' pl$DataFrame(a = 1:2, b = 3:4)
#'
#' # Constructing a DataFrame from Series:
#' pl$DataFrame(pl$Series("a", 1:2), pl$Series("b", 3:4))
#'
#' # Constructing a DataFrame from a list:
#' data <- list(a = 1:2, b = 3:4)
#'
#' ## Using the as_polars_df function (recommended)
#' as_polars_df(data)
#'
#' ## Using dynamic dots feature
#' pl$DataFrame(!!!data)
#'
#' # Active bindings:
#' df <- pl$DataFrame(a = 1:3, b = c("foo", "bar", "baz"))
#'
#' df$columns
#' df$dtypes
#' df$schema
#' df$shape
#' df$height
#' df$width
pl__DataFrame <- function(...) {
  .data <- list2(...)

  # Special error to show hint to use `pl$select` instead of `pl$DataFrame`
  for (val in .data) {
    if (is_polars_expr(val)) {
      abort(
        c(
          "passing polars expression objects to `pl$DataFrame()` is not supported.",
          i = "Try evaluating the expression first using `pl$select()`."
        )
      )
    }
  }

  .data |>
    as_polars_df()
}

# The env for storing dataframe methods
polars_dataframe__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRDataFrame <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_df` <- x

  # TODO: flags
  makeActiveBinding("columns", function() self$`_df`$columns(), self)
  makeActiveBinding("dtypes", function() {
    self$`_df`$dtypes() |>
      lapply(\(x) .savvy_wrap_PlRDataType(x) |> wrap())
  }, self)
  makeActiveBinding("schema", function() structure(self$dtypes, names = self$columns), self)
  makeActiveBinding("shape", function() self$`_df`$shape(), self)
  makeActiveBinding("height", function() self$`_df`$height(), self)
  makeActiveBinding("width", function() self$`_df`$width(), self)

  lapply(names(polars_dataframe__methods), function(name) {
    fn <- polars_dataframe__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_data_frame", "polars_object")
  self
}

dataframe__set_column_names <- function(names) {
  wrap({
    df <- self$clone()

    df$`_df`$set_column_names(names)
    df
  })
}

# TODO: link to data type docs
#' Convert a DataFrame to a Series of type Struct
#'
#' @param name A character. Name for the struct [Series].
#' @return A [Series] of the struct type
#' @seealso
#' - [as_polars_series()]
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:5,
#'   b = c("one", "two", "three", "four", "five"),
#' )
#' df$to_struct("nums")
dataframe__to_struct <- function(name = "") {
  self$`_df`$to_struct(name) |>
    wrap()
}

dataframe__lazy <- function() {
  self$`_df`$lazy() |>
    wrap()
}

dataframe__clone <- function() {
  self$`_df`$clone() |>
    wrap()
}

#' Get the DataFrame as a List of Series
#'
#' @return A [list] of [Series]
#' @seealso
#' - [`as.list(<polars_data_frame>)`][as.list.polars_data_frame]
#' @examples
#' df <- pl$DataFrame(foo = c(1, 2, 3), bar = c(4, 5, 6))
#' df$get_columns()
#'
#' df <- pl$DataFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE)
#' )
#' df$get_columns()
dataframe__get_columns <- function() {
  self$`_df`$get_columns() |>
    lapply(\(ptr) {
      .savvy_wrap_PlRSeries(ptr) |>
        wrap()
    })
}

dataframe__group_by <- function(..., maintain_order = FALSE) {
  wrap_to_group_by(self, list2(...), maintain_order)
}

dataframe__select <- function(...) {
  self$lazy()$select(...)$collect(`_eager` = TRUE) |>
    wrap()
}

dataframe__with_columns <- function(...) {
  self$lazy()$with_columns(...)$collect(`_eager` = TRUE) |>
    wrap()
}

dataframe__to_series <- function(index = 0) {
  self$`_df`$to_series(index) |>
    wrap()
}

dataframe__equals <- function(other, ..., null_equal = TRUE) {
  wrap({
    check_dots_empty0(...)
    check_polars_df(other)

    self$`_df`$equals(other$`_df`, null_equal)
  })
}

dataframe__slice <- function(offset, length = NULL) {
  wrap({
    check_number_decimal(offset, allow_infinite = FALSE)
    if (isTRUE(length < 0)) {
      length <- self$height - offset + length
    }
    self$`_df`$slice(offset, length)
  })
}

dataframe__head <- function(n = 5) {
  wrap({
    if (isTRUE(n < 0)) {
      n <- max(0, self$height + n)
    }
    self$`_df`$head(n)
  })
}

dataframe__tail <- function(n = 5) {
  wrap({
    if (isTRUE(n < 0)) {
      n <- max(0, self$height + n)
    }
    self$`_df`$tail(n)
  })
}

dataframe__drop <- function(..., strict = TRUE) {
  self$lazy()$drop(..., strict = strict)$collect(`_eager` = TRUE) |>
    wrap()
}

# TODO: accept formulas for type mapping
dataframe__cast <- function(..., strict = TRUE) {
  self$lazy()$cast(..., strict = strict)$collect(`_eager` = TRUE) |>
    wrap()
}

dataframe__filter <- function(...) {
  self$lazy()$filter(...)$collect(`_eager` = TRUE) |>
    wrap()
}

dataframe__sort <- function(
    ...,
    descending = FALSE,
    nulls_last = FALSE,
    multithreaded = TRUE,
    maintain_order = FALSE) {
  self$lazy()$sort(
    ...,
    descending = descending,
    nulls_last = nulls_last,
    multithreaded = multithreaded,
    maintain_order = maintain_order
  )$collect(`_eager` = TRUE) |>
    wrap()
}
