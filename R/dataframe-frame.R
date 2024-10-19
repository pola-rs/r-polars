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
#'
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

#' Convert an existing DataFrame to a LazyFrame
#' @description Start a new lazy query from a DataFrame.
#'
#' @inherit as_polars_lf return
#' @examples
#' pl$DataFrame(a = 1:2, b = c(NA, "a"))$lazy()
dataframe__lazy <- function() {
  self$`_df`$lazy() |>
    wrap()
}

#' Clone a DataFrame
#'
#' This is a cheap operation that does not copy data. Assigning does not copy
#' the DataFrame (environment object). This is because environment objects have
#' reference semantics. Calling $clone() creates a new environment, which can
#' be useful when dealing with attributes (see examples).
#'
#' @inherit as_polars_df return
#' @examples
#' df1 <- as_polars_df(iris)
#'
#' # Assigning does not copy the DataFrame (environment object), calling
#' # $clone() creates a new environment.
#' df2 <- df1
#' df3 <- df1$clone()
#' rlang::env_label(df1)
#' rlang::env_label(df2)
#' rlang::env_label(df3)
#'
#' # Cloning can be useful to add attributes to data used in a function without
#' # adding those attributes to the original object.
#'
#' # Make a function to take a DataFrame, add an attribute, and return a
#' # DataFrame:
#' give_attr <- function(data) {
#'   attr(data, "created_on") <- "2024-01-29"
#'   data
#' }
#' df2 <- give_attr(df1)
#'
#' # Problem: the original DataFrame also gets the attribute while it shouldn't
#' attributes(df1)
#'
#' # Use $clone() inside the function to avoid that
#' give_attr <- function(data) {
#'   data <- data$clone()
#'   attr(data, "created_on") <- "2024-01-29"
#'   data
#' }
#' df1 <- as_polars_df(iris)
#' df2 <- give_attr(df1)
#'
#' # now, the original DataFrame doesn't get this attribute
#' attributes(df1)
dataframe__clone <- function() {
  self$`_df`$clone() |>
    wrap()
}

#' Get the DataFrame as a list of Series
#'
#' @return A list of [Series]
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

#' Group a DataFrame
#'
#' @inherit LazyFrame_group_by description params
#' @details Within each group, the order of the rows is always preserved,
#' regardless of the `maintain_order` argument.
#' @return [GroupBy][GroupBy_class] (a DataFrame with special groupby methods like `$agg()`)
#' @seealso
#' - [`<DataFrame>$partition_by()`][DataFrame_partition_by]
#' @examples
#' df <- pl$DataFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#'
#' df$group_by("a")$agg(pl$col("b")$sum())
#'
#' # Set `maintain_order = TRUE` to ensure the order of the groups is
#' # consistent with the input.
#' df$group_by("a", maintain_order = TRUE)$agg(pl$col("c"))
#'
#' # Group by multiple columns by passing a list of column names.
#' df$group_by(c("a", "b"))$agg(pl$max("c"))
#'
#' # Or pass some arguments to group by multiple columns in the same way.
#' # Expressions are also accepted.
#' df$group_by("a", pl$col("b") %/% 2)$agg(
#'   pl$col("c")$mean()
#' )
#'
#' # The columns will be renamed to the argument names.
#' df$group_by(d = "a", e = pl$col("b") %/% 2)$agg(
#'   pl$col("c")$mean()
#' )
dataframe__group_by <- function(..., maintain_order = FALSE) {
  wrap_to_group_by(self, list2(...), maintain_order)
}

#' Select and modify columns of a DataFrame
#'
#' @inherit lazyframe__select description params
#' @inherit as_polars_df return
#' @examples
#' as_polars_df(iris)$select(
#'   abs_SL = pl$col("Sepal.Length")$abs(),
#'   add_2_SL = pl$col("Sepal.Length") + 2
#' )
dataframe__select <- function(...) {
  self$lazy()$select(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Modify/append column(s) of a DataFrame
#'
#' @inherit lazyframe__with_columns description params
#' @inherit as_polars_df return
#' @examples
#' as_polars_df(iris)$with_columns(
#'   abs_SL = pl$col("Sepal.Length")$abs(),
#'   add_2_SL = pl$col("Sepal.Length") + 2
#' )
#'
#' # same query
#' l_expr <- list(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#' as_polars_df(iris)$with_columns(l_expr)
#'
#' as_polars_df(iris)$with_columns(
#'   SW_add_2 = (pl$col("Sepal.Width") + 2),
#'   # unnamed expr will keep name "Sepal.Length"
#'   pl$col("Sepal.Length")$abs()
#' )
dataframe__with_columns <- function(...) {
  self$lazy()$with_columns(...)$collect(`_eager` = TRUE) |>
    wrap()
}

# TODO-REWRITE: before release, add in news that param idx was renamed "index"
# and mention that it errors if out of bounds
#' Select column as Series at index location
#'
#' @param index Index of the column to return as Series. Defaults to 0, which is
#' the first column.
#'
#' @return Series or NULL
#' @examples
#' df <- as_polars_df(iris[1:10, ])
#'
#' # default is to extract the first column
#' df$to_series()
#'
#' # Polars is 0-indexed, so we use index = 1 to extract the *2nd* column
#' df$to_series(index = 1)
#'
#' # doesn't error if the column isn't there
#' df$to_series(index = 8)
dataframe__to_series <- function(index = 0) {
  self$`_df`$to_series(index) |>
    wrap()
}

#' Check whether the DataFrame is equal to another DataFrame
#'
#' @param other DataFrame to compare with.
#' @return A logical value
#' @examples
#' dat1 <- as_polars_df(iris)
#' dat2 <- as_polars_df(iris)
#' dat3 <- as_polars_df(mtcars)
#' dat1$equals(dat2)
#' dat1$equals(dat3)
dataframe__equals <- function(other, ..., null_equal = TRUE) {
  wrap({
    check_dots_empty0(...)
    check_polars_df(other)

    self$`_df`$equals(other$`_df`, null_equal)
  })
}

#' Get a slice of the DataFrame.
#'
#' @inherit as_polars_df return
#' @param offset Start index, can be a negative value. This is 0-indexed, so
#' `offset = 1` skips the first row.
#' @param length Length of the slice. If `NULL` (default), all rows starting at
#' the offset will be selected.
#' @examples
#' # skip the first 2 rows and take the 4 following rows
#' as_polars_df(mtcars)$slice(2, 4)
#'
#' # this is equivalent to:
#' mtcars[3:6, ]
dataframe__slice <- function(offset, length = NULL) {
  wrap({
    check_number_decimal(offset, allow_infinite = FALSE)
    if (isTRUE(length < 0)) {
      length <- self$height - offset + length
    }
    self$`_df`$slice(offset, length)
  })
}

#' @inherit LazyFrame_head title details
#' @param n Number of rows to return. If a negative value is passed,
#' return all rows except the last [`abs(n)`][abs].
#' @return A [DataFrame][DataFrame_class]
#' @examples
#' df <- pl$DataFrame(foo = 1:5, bar = 6:10, ham = letters[1:5])
#'
#' df$head(3)
#'
#' # Pass a negative value to get all rows except the last `abs(n)`.
#' df$head(-3)
dataframe__head <- function(n = 5) {
  wrap({
    if (isTRUE(n < 0)) {
      n <- max(0, self$height + n)
    }
    self$`_df`$head(n)
  })
}

#' @inherit LazyFrame_tail title
#' @param n Number of rows to return. If a negative value is passed,
#' return all rows except the first [`abs(n)`][abs].
#' @inherit DataFrame_head return
#' @examples
#' df <- pl$DataFrame(foo = 1:5, bar = 6:10, ham = letters[1:5])
#'
#' df$tail(3)
#'
#' # Pass a negative value to get all rows except the first `abs(n)`.
#' df$tail(-3)
dataframe__tail <- function(n = 5) {
  wrap({
    if (isTRUE(n < 0)) {
      n <- max(0, self$height + n)
    }
    self$`_df`$tail(n)
  })
}

#' Drop columns of a DataFrame
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Characters of column names to
#' drop. Passed to [`pl$col()`][pl__col].
#' @param strict Validate that all column names exist in the schema and throw an
#' exception if a column name does not exist in the schema.
#'
#' @inherit as_polars_df return
#' @examples
#' as_polars_df(mtcars)$drop(c("mpg", "hp"))
#'
#' # equivalent
#' as_polars_df(mtcars)$drop("mpg", "hp")
dataframe__drop <- function(..., strict = TRUE) {
  self$lazy()$drop(..., strict = strict)$collect(`_eager` = TRUE) |>
    wrap()
}

# TODO: accept formulas for type mapping
#' Cast DataFrame column(s) to the specified dtype
#'
#' @inherit LazyFrame_cast description params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06"))
#' )
#'
#' # Cast only some columns
#' df$cast(list(foo = pl$Float32, bar = pl$UInt8))
#'
#' # Cast all columns to the same type
#' df$cast(pl$String)
dataframe__cast <- function(..., strict = TRUE) {
  self$lazy()$cast(..., strict = strict)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Filter rows of a DataFrame
#'
#' @inherit LazyFrame_filter description params details
#'
#' @inherit as_polars_df return
#' @examples
#' df <- as_polars_df(iris)
#'
#' df$filter(pl$col("Sepal.Length") > 5)
#'
#' # This is equivalent to
#' # df$filter(pl$col("Sepal.Length") > 5 & pl$col("Petal.Width") < 1)
#' df$filter(pl$col("Sepal.Length") > 5, pl$col("Petal.Width") < 1)
#'
#' # rows where condition is NA are dropped
#' iris2 <- iris
#' iris2[c(1, 3, 5), "Species"] <- NA
#' df <- as_polars_df(iris2)
#'
#' df$filter(pl$col("Species") == "setosa")
dataframe__filter <- function(...) {
  self$lazy()$filter(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Sort a DataFrame
#' @inherit LazyFrame_sort details description params
#' @inheritParams DataFrame_unique
#' @inherit as_polars_df return
#' @examples
#' df <- mtcars
#' df$mpg[1] <- NA
#' df <- as_polars_df(df)
#' df$sort("mpg")
#' df$sort("mpg", nulls_last = TRUE)
#' df$sort("cyl", "mpg")
#' df$sort(c("cyl", "mpg"))
#' df$sort(c("cyl", "mpg"), descending = TRUE)
#' df$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE))
#' df$sort(pl$col("cyl"), pl$col("mpg"))
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
