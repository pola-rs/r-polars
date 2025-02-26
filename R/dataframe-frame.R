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
#' This function is basically a shortcut for
#' `as_polars_df(list(...))$cast(!!!.schema_overrides, .strict = .strict)`, so each argument in `...` is
#' converted to a Polars Series by [as_polars_series()] and then passed to [as_polars_df()].
#' @aliases polars_data_frame DataFrame
#'
#' @section Active bindings:
#' - `columns`: `$columns` returns a character vector with the names of the columns.
#' - `dtypes`: `$dtypes` returns a nameless list of the data type of each column.
#' - `schema`: `$schema` returns a named list with the column names as names and the data types as values.
#' - `shape`: `$shape` returns a integer vector of length two with the number of rows and columns of the DataFrame.
#' - `height`: `$height` returns a integer with the number of rows of the DataFrame.
#' - `width`: `$width` returns a integer with the number of columns of the DataFrame.
#' - `flags`: `$flags` returns a list with column names as names and a named
#'   logical vector with the flags as values.
#'
#' @section Flags:
#'
#' Flags are used internally to avoid doing unnecessary computations, such as
#' sorting a variable that we know is already sorted. The number of flags
#' varies depending on the column type: columns of type `array` and `list`
#' have the flags `SORTED_ASC`, `SORTED_DESC`, and `FAST_EXPLODE`, while other
#' column types only have the former two.
#'
#' - `SORTED_ASC` is set to `TRUE` when we sort a column in increasing order, so
#'   that we can use this information later on to avoid re-sorting it.
#' - `SORTED_DESC` is similar but applies to sort in decreasing order.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Name-value pairs of objects to be converted to polars [Series]
#' by the [as_polars_series()] function.
#' Each [Series] will be used as a column of the [DataFrame].
#' All values must be the same length.
#' Each name will be used as the column name. If the name is empty,
#' the original name of the [Series] will be used.
#' @param .schema_overrides `r lifecycle::badge("experimental")`
#' A list of polars data types or `NULL` (default).
#' Passed to the [`$cast()`][dataframe__cast] method as dynamic-dots.
#' @param .strict `r lifecycle::badge("experimental")`
#' A logical value. Passed to the [`$cast()`][dataframe__cast] method's `.strict` argument.
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
pl__DataFrame <- function(..., .schema_overrides = NULL, .strict = TRUE) {
  wrap({
    check_list_of_polars_dtype(.schema_overrides, allow_null = TRUE)

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

    as_polars_df(.data)$cast(!!!.schema_overrides, .strict = .strict)
  })
}

# The env for storing dataframe methods
polars_dataframe__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRDataFrame <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_df` <- x

  makeActiveBinding("columns", function() self$`_df`$columns(), self)
  makeActiveBinding(
    "dtypes",
    function() {
      self$`_df`$dtypes() |>
        lapply(\(x) .savvy_wrap_PlRDataType(x) |> wrap())
    },
    self
  )
  makeActiveBinding("schema", function() structure(self$dtypes, names = self$columns), self)
  makeActiveBinding("shape", function() self$`_df`$shape(), self)
  makeActiveBinding("height", function() self$`_df`$height(), self)
  makeActiveBinding("width", function() self$`_df`$width(), self)
  makeActiveBinding(
    "flags",
    function() lapply(self$get_columns(), \(x) x$flags),
    self
  )

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

dataframe__collect_schema <- function() self$schema

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
#' @inherit lazyframe__group_by description params
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
dataframe__group_by <- function(..., .maintain_order = FALSE) {
  wrap_to_group_by(self, list2(...), .maintain_order)
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
#' # Pass an expression to add it as a new column.
#' df <- pl$DataFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE),
#' )
#' df$with_columns((pl$col("a")^2)$alias("a^2"))
#'
#' # Added columns will replace existing columns with the same name.
#' df$with_columns(a = pl$col("a")$cast(pl$Float64))
#'
#' # Multiple columns can be added
#' df$with_columns(
#'   (pl$col("a")^2)$alias("a^2"),
#'   (pl$col("b") / 2)$alias("b/2"),
#'   (pl$col("c")$not())$alias("not c"),
#' )
#'
#' # Name expression instead of `$alias()`
#' df$with_columns(
#'   `a^2` = pl$col("a")^2,
#'   `b/2` = pl$col("b") / 2,
#'   `not c` = pl$col("c")$not(),
#' )
#'
#' # Expressions with multiple outputs can automatically be instantiated
#' # as Structs by enabling the experimental setting `POLARS_AUTO_STRUCTIFY`:
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
#'     df$drop("c")$with_columns(
#'       diffs = pl$col("a", "b")$diff()$name$suffix("_diff"),
#'     )
#'   })
#' }
dataframe__with_columns <- function(...) {
  self$lazy()$with_columns(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Modify/append column(s) of a DataFrame
#'
#' @inherit lazyframe__with_columns_seq description
#' @inherit pl__DataFrame return
#' @inheritParams lazyframe__select
#' @examples
#' # Pass an expression to add it as a new column.
#' df <- pl$DataFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE),
#' )
#' df$with_columns_seq((pl$col("a")^2)$alias("a^2"))
#'
#' # Added columns will replace existing columns with the same name.
#' df$with_columns_seq(a = pl$col("a")$cast(pl$Float64))
#'
#' # Multiple columns can be added
#' df$with_columns_seq(
#'   (pl$col("a")^2)$alias("a^2"),
#'   (pl$col("b") / 2)$alias("b/2"),
#'   (pl$col("c")$not())$alias("not c"),
#' )
#'
#' # Name expression instead of `$alias()`
#' df$with_columns_seq(
#'   `a^2` = pl$col("a")^2,
#'   `b/2` = pl$col("b") / 2,
#'   `not c` = pl$col("c")$not(),
#' )
#'
#' # Expressions with multiple outputs can automatically be instantiated
#' # as Structs by enabling the experimental setting `POLARS_AUTO_STRUCTIFY`:
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
#'     df$drop("c")$with_columns_seq(
#'       diffs = pl$col("a", "b")$diff()$name$suffix("_diff"),
#'     )
#'   })
#' }
dataframe__with_columns_seq <- function(...) {
  self$lazy()$with_columns_seq(...)$collect(`_eager` = TRUE) |>
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

#' @inherit lazyframe__head title details
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

#' @inherit lazyframe__tail title
#' @param n Number of rows to return. If a negative value is passed,
#' return all rows except the first [`abs(n)`][abs].
#' @inherit dataframe__head return
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

#' @inherit lazyframe__drop title params
#'
#' @inherit as_polars_df return
#' @examples
#' # Drop columns by passing the name of those columns
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = c("a", "b", "c")
#' )
#' df$drop("ham")
#' df$drop("ham", "bar")
#'
#' # Drop multiple columns by passing a selector
#' df$drop(cs$all())
dataframe__drop <- function(..., strict = TRUE) {
  self$lazy()$drop(..., strict = strict)$collect(`_eager` = TRUE) |>
    wrap()
}

# TODO: accept formulas for type mapping
#' Cast DataFrame column(s) to the specified dtype
#'
#' @inherit lazyframe__cast description params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06"))
#' )
#'
#' # Cast only some columns
#' df$cast(foo = pl$Float32, bar = pl$UInt8)
#'
#' # Cast all columns to the same type
#' df$cast(pl$String)
dataframe__cast <- function(..., .strict = TRUE) {
  self$lazy()$cast(..., .strict = .strict)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Filter rows of a DataFrame
#'
#' @inherit lazyframe__filter description params details
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

#' Sort a DataFrame by the given columns
#'
#' @inherit lazyframe__sort description params details
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA, 4),
#'   b = c(6, 5, 4, 3),
#'   c = c("a", "c", "b", "a")
#' )
#'
#' # Pass a single column name to sort by that column.
#' df$sort("a")
#'
#' # Sorting by expressions is also supported
#' df$sort(pl$col("a") + pl$col("b") * 2, nulls_last = TRUE)
#'
#' # Sort by multiple columns by passing a vector of columns
#' df$sort(c("c", "a"), descending = TRUE)
#'
#' # Or use positional arguments to sort by multiple columns in the same way
#' df$sort("c", "a", descending = c(FALSE, TRUE))
dataframe__sort <- function(
  ...,
  descending = FALSE,
  nulls_last = FALSE,
  multithreaded = TRUE,
  maintain_order = FALSE
) {
  self$lazy()$sort(
    ...,
    descending = descending,
    nulls_last = nulls_last,
    multithreaded = multithreaded,
    maintain_order = maintain_order
  )$collect(`_eager` = TRUE) |>
    wrap()
}

#' Get number of chunks used by the ChunkedArrays of this DataFrame
#'
#' @param strategy Return the number of chunks of the `"first"` column, or
#' `"all"` columns in this DataFrame.
#'
#' @return An integer vector.
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, 3, 4),
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE)
#' )
#'
#' df$n_chunks()
#' df$n_chunks(strategy = "all")
dataframe__n_chunks <- function(strategy = c("first", "all")) {
  wrap({
    strategy <- arg_match0(strategy, values = c("first", "all"))
    if (strategy == "first") {
      self$`_df`$n_chunks()
    } else {
      vapply(as.list(self, as_series = TRUE), \(x) x$n_chunks(), FUN.VALUE = integer(1))
    }
  })
}

#' Rechunk the data in this DataFrame to a contiguous allocation
#'
#' This will make sure all subsequent operations have optimal and predictable
#' performance.
#'
#' @inherit as_polars_df return
dataframe__rechunk <- function() {
  wrap({
    self$`_df`$rechunk()
  })
}

#' @inherit lazyframe__bottom_k title description params
#' @inherit as_polars_df return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = c(2, 1, 1, 3, 2, 1)
#' )
#'
#' # Get the rows which contain the 4 smallest values in column b.
#' df$bottom_k(4, by = "b")
#'
#' # Get the rows which contain the 4 smallest values when sorting on column a
#' # and b$
#' df$bottom_k(4, by = c("a", "b"))
dataframe__bottom_k <- function(k, ..., by, reverse = FALSE) {
  self$lazy()$bottom_k(k, by = by, reverse = reverse)$collect(
    projection_pushdown = FALSE,
    predicate_pushdown = FALSE,
    comm_subplan_elim = FALSE,
    slice_pushdown = TRUE
  ) |>
    wrap()
}

#' @inherit lazyframe__top_k title description params
#' @inherit as_polars_df return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = c(2, 1, 1, 3, 2, 1)
#' )
#'
#' # Get the rows which contain the 4 largest values in column b.
#' df$top_k(4, by = "b")
#'
#' # Get the rows which contain the 4 largest values when sorting on column a
#' # and b
#' df$top_k(4, by = c("a", "b"))
dataframe__top_k <- function(k, ..., by, reverse = FALSE) {
  self$lazy()$top_k(k, by = by, reverse = reverse)$collect(
    projection_pushdown = FALSE,
    predicate_pushdown = FALSE,
    comm_subplan_elim = FALSE,
    slice_pushdown = TRUE
  ) |>
    wrap()
}

#' Take two sorted DataFrames and merge them by the sorted key
#'
#' The output of this operation will also be sorted. It is the callers
#' responsibility that the frames are sorted by that key, otherwise the output
#' will not make sense. The schemas of both DataFrames must be equal.
#'
#' @param other Other DataFrame that must be merged.
#' @inheritParams lazyframe__merge_sorted
#'
#' @inherit as_polars_df return
#'
#' @examples
#' df1 <- pl$DataFrame(
#'   name = c("steve", "elise", "bob"),
#'   age = c(42, 44, 18)
#' )$sort("age")
#'
#' df2 <- pl$DataFrame(
#'   name = c("anna", "megan", "steve", "thomas"),
#'   age = c(21, 33, 42, 20)
#' )$sort("age")
#'
#' df1$merge_sorted(df2, key = "age")
dataframe__merge_sorted <- function(other, key) {
  self$lazy()$merge_sorted(other$lazy(), key)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__set_sorted title description params
#'
#' @inherit as_polars_df return
#' @examples
#' # We mark the data as sorted by "age" but this is not the case!
#' # It is up to the user to ensure that the column is actually sorted.
#' df1 <- pl$DataFrame(
#'   name = c("steve", "elise", "bob"),
#'   age = c(42, 44, 18)
#' )$set_sorted("age")
#'
#' df1$flags
dataframe__set_sorted <- function(column, ..., descending = FALSE) {
  self$lazy()$set_sorted(column, descending = descending)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__unique title params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 3, 1),
#'   bar = c("a", "a", "a", "a"),
#'   ham = c("b", "b", "b", "b"),
#' )
#' df$unique(maintain_order = TRUE)
#'
#' df$unique(subset = c("bar", "ham"), maintain_order = TRUE)
#'
#' df$unique(keep = "last", maintain_order = TRUE)
dataframe__unique <- function(
  subset = NULL,
  ...,
  keep = c("any", "none", "first", "last"),
  maintain_order = FALSE
) {
  self$lazy()$unique(subset = subset, keep = keep, maintain_order = maintain_order)$collect(
    `_eager` = TRUE
  ) |>
    wrap()
}

#' Join DataFrames
#'
#' @inherit lazyframe__join description params
#'
#' @param other DataFrame to join with.
#' @param on Either a vector of column names or a list of expressions and/or
#'   strings. Use `left_on` and `right_on` if the column names to match on are
#'   different between the two DataFrames.
#' @param allow_parallel Allow the physical plan to optionally evaluate the
#'   computation of both DataFrames up to the join in parallel.
#' @param force_parallel Force the physical plan to evaluate the computation of
#'   both DataFrames up to the join in parallel.
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = c("a", "b", "c")
#' )
#' other_df <- pl$DataFrame(
#'   apple = c("x", "y", "z"),
#'   ham = c("a", "b", "d")
#' )
#' df$join(other_df, on = "ham")
#'
#' df$join(other_df, on = "ham", how = "full")
#'
#' df$join(other_df, on = "ham", how = "left", coalesce = TRUE)
#'
#' df$join(other_df, on = "ham", how = "semi")
#'
#' df$join(other_df, on = "ham", how = "anti")
dataframe__join <- function(
  other,
  on = NULL,
  how = c("inner", "full", "left", "right", "semi", "anti", "cross"),
  ...,
  left_on = NULL,
  right_on = NULL,
  suffix = "_right",
  validate = c("m:m", "1:m", "m:1", "1:1"),
  join_nulls = FALSE,
  maintain_order = c("none", "left", "right", "left_right", "right_left"),
  allow_parallel = TRUE,
  force_parallel = FALSE,
  coalesce = NULL
) {
  wrap({
    check_polars_df(other)
    self$lazy()$join(
      other = other$lazy(),
      left_on = left_on,
      right_on = right_on,
      on = on,
      how = how,
      suffix = suffix,
      validate = validate,
      join_nulls = join_nulls,
      coalesce = coalesce,
      maintain_order = maintain_order
    )$collect(`_eager` = TRUE)
  })
}

#' @inherit lazyframe__drop_nans title description params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, NaN, 2.5),
#'   bar = c(NaN, 110, 25.5),
#'   ham = c("a", "b", NA)
#' )
#'
#' # The default behavior of this method is to drop rows where any single value
#' # of the row is null.
#' df$drop_nans()
#'
#' # This behaviour can be constrained to consider only a subset of columns, as
#' # defined by name or with a selector. For example, dropping rows if there is
#' # a null in the "bar" column:
#' df$drop_nans("bar")
#'
#' # Dropping a row only if *all* values are NaN requires a different
#' # formulation:
#' df <- pl$DataFrame(
#'   a = c(NaN, NaN, NaN, NaN),
#'   b = c(10.0, 2.5, NaN, 5.25),
#'   c = c(65.75, NaN, NaN, 10.5)
#' )
#' df$filter(!pl$all_horizontal(pl$all()$is_nan()))
dataframe__drop_nans <- function(...) {
  self$lazy()$drop_nans(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__drop_nulls title description params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = c(6L, NA, 8L),
#'   ham = c("a", "b", NA)
#' )
#'
#' # The default behavior of this method is to drop rows where any single value
#' # of the row is null.
#' df$drop_nulls()
#'
#' # This behaviour can be constrained to consider only a subset of columns, as
#' # defined by name or with a selector. For example, dropping rows if there is
#' # a null in any of the integer columns:
#' df$drop_nulls(cs$integer())
dataframe__drop_nulls <- function(...) {
  self$lazy()$drop_nulls(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Take every nth row in the DataFrame
#'
#' @inheritParams lazyframe__gather_every
#' @inherit as_polars_df return
#'
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = 5:8)
#' df$gather_every(2)
#'
#' df$gather_every(2, offset = 1)
dataframe__gather_every <- function(n, offset = 0) {
  self$select(pl$col("*")$gather_every(n, offset)) |>
    wrap()
}

#' @inherit lazyframe__rename title params details
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = letters[1:3]
#' )
#'
#' df$rename(foo = "apple")
dataframe__rename <- function(..., .strict = TRUE) {
  self$lazy()$rename(..., .strict = .strict)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__fill_null title description params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1.5, 2, NA, 4),
#'   b = c(1.5, NA, NA, 4)
#' )
#' df$fill_null(99)
#'
#' df$fill_null(strategy = "forward")
#'
#' df$fill_null(strategy = "max")
#'
#' df$fill_null(strategy = "zero")
dataframe__fill_null <- function(
  value,
  strategy = NULL,
  limit = NULL,
  ...,
  matches_supertype = TRUE
) {
  self$lazy()$fill_null(value, strategy, limit, matches_supertype = matches_supertype)$collect(
    `_eager` = TRUE
  ) |>
    wrap()
}

#' @inherit lazyframe__explode title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   letters = c("a", "a", "b", "c"),
#'   numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8))
#' )
#'
#' df$explode("numbers")
dataframe__explode <- function(...) {
  self$lazy()$explode(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__unnest title description params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:5,
#'   b = c("one", "two", "three", "four", "five"),
#'   c = 6:10
#' )$
#'   select(
#'   pl$struct("b"),
#'   pl$struct(c("a", "c"))$alias("a_and_c")
#' )
#' df
#'
#' df$unnest("a_and_c")
#' df$unnest(pl$col("a_and_c"))
dataframe__unnest <- function(...) {
  self$lazy()$unnest(...)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__join_asof title description params
#'
#' @param other DataFrame to join with.
#'
#' @inheritSection polars_duration_string Polars duration string language
#' @inherit as_polars_df return
#' @examples
#' gdp <- pl$DataFrame(
#'   date = as.Date(c("2016-1-1", "2017-5-1", "2018-1-1", "2019-1-1", "2020-1-1")),
#'   gdp = c(4164, 4411, 4566, 4696, 4827)
#' )
#'
#' pop <- pl$DataFrame(
#'   date = as.Date(c("2016-3-1", "2018-8-1", "2019-1-1")),
#'   population = c(82.19, 82.66, 83.12)
#' )
#'
#' # optional make sure tables are already sorted with "on" join-key
#' gdp <- gdp$sort("date")
#' pop <- pop$sort("date")
#'
#'
#' # Note how the dates don’t quite match. If we join them using join_asof and
#' # strategy = 'backward', then each date from population which doesn’t have
#' # an exact match is matched with the closest earlier date from gdp:
#' pop$join_asof(gdp, on = "date", strategy = "backward")
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2016-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2018-01-01 from gdp.
#' # You can verify this by passing coalesce = FALSE:
#' pop$join_asof(
#'   gdp,
#'   on = "date", strategy = "backward", coalesce = FALSE
#' )
#'
#' # If we instead use strategy = 'forward', then each date from population
#' # which doesn’t have an exact match is matched with the closest later date
#' # from gdp:
#' pop$join_asof(gdp, on = "date", strategy = "forward")
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2017-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2019-01-01 from gdp.
#'
#' # Finally, strategy = 'nearest' gives us a mix of the two results above, as
#' # each date from population which doesn’t have an exact match is matched
#' # with the closest date from gdp, regardless of whether it’s earlier or
#' # later:
#' pop$join_asof(gdp, on = "date", strategy = "nearest")
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2016-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2019-01-01 from gdp.
#'
#' # The `by` argument allows joining on another column first, before the asof
#' # join. In this example we join by country first, then asof join by date, as
#' # above.
#' gdp2 <- pl$DataFrame(
#'   country = rep(c("Germany", "Netherlands"), each = 5),
#'   date = rep(
#'     as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1", "2020-1-1")),
#'     2
#'   ),
#'   gdp = c(4164, 4411, 4566, 4696, 4827, 784, 833, 914, 910, 909)
#' )$sort("country", "date")
#' gdp2
#'
#' pop2 <- pl$DataFrame(
#'   country = rep(c("Germany", "Netherlands"), each = 3),
#'   date = rep(as.Date(c("2016-3-1", "2018-8-1", "2019-1-1")), 2),
#'   population = c(82.19, 82.66, 83.12, 17.11, 17.32, 17.40)
#' )$sort("country", "date")
#' pop2
#'
#' pop2$join_asof(
#'   gdp2,
#'   by = "country", on = "date", strategy = "nearest"
#' )
dataframe__join_asof <- function(
  other,
  ...,
  left_on = NULL,
  right_on = NULL,
  on = NULL,
  by_left = NULL,
  by_right = NULL,
  by = NULL,
  strategy = c("backward", "forward", "nearest"),
  suffix = "_right",
  tolerance = NULL,
  allow_parallel = TRUE,
  force_parallel = FALSE,
  coalesce = TRUE,
  allow_exact_matches = TRUE,
  check_sortedness = TRUE
) {
  self$lazy()$join_asof(
    other$lazy(),
    left_on = left_on,
    right_on = right_on,
    on = on,
    by_left = by_left,
    by_right = by_right,
    by = by,
    strategy = strategy,
    suffix = suffix,
    tolerance = tolerance,
    allow_parallel = allow_parallel,
    force_parallel = force_parallel,
    coalesce = coalesce,
    allow_exact_matches = allow_exact_matches,
    check_sortedness = check_sortedness,
  )$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__quantile title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$quantile(0.7)
dataframe__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  self$lazy()$quantile(quantile, interpolation)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__fill_nan title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1.5, 2, NaN, 4),
#'   b = c(1.5, NaN, NaN, 4)
#' )
#' df$fill_nan(99)
dataframe__fill_nan <- function(value) {
  self$lazy()$fill_nan(value)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__clear title description params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(NA, 2, 3, 4),
#'   b = c(0.5, NA, 2.5, 13),
#'   c = c(TRUE, TRUE, FALSE, NA)
#' )
#' df$clear()
#'
#' df$clear(n = 2)
dataframe__clear <- function(n = 0) {
  wrap({
    if (!is_integerish(n)) {
      abort("`n` must be an integer.")
    }
    if (n < 0) {
      abort("`n` must be greater than or equal to 0.")
    }
    if (n == 0) {
      return(
        self$`_df`$clear() |>
          wrap()
      )
    }
    sch <- self$schema
    lst <- lapply(seq_along(sch), \(x) {
      pl$lit(NA, dtype = sch[[x]])$extend_constant(NA, n - 1)$alias(names(sch)[x])
    })
    pl$select(!!!lst)
  })
}

#' @inherit lazyframe__shift title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = 5:8)
#'
#' # By default, values are shifted forward by one index.
#' df$shift()
#'
#' # Pass a negative value to shift in the opposite direction instead.
#' df$shift(-2)
#'
#' # Specify fill_value to fill the resulting null values.
#' df$shift(-2, fill_value = 100)
dataframe__shift <- function(n = 1, ..., fill_value = NULL) {
  wrap({
    check_dots_empty0(...)
    self$lazy()$shift(n, fill_value = fill_value)$collect(`_eager` = TRUE)
  })
}

#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This performs an inner join, so only rows where all predicates are true are
#' included in the result, and a row from either DataFrame may be included
#' multiple times in the result.
#'
#' Note that the row order of the input DataFrames is not preserved.
#'
#' @inherit lazyframe__join_where title params
#' @param other DataFrame to join with.
#'
#' @inherit as_polars_df return
#'
#' @examples
#' east <- pl$DataFrame(
#'   id = c(100, 101, 102),
#'   dur = c(120, 140, 160),
#'   rev = c(12, 14, 16),
#'   cores = c(2, 8, 4)
#' )
#'
#' west <- pl$DataFrame(
#'   t_id = c(404, 498, 676, 742),
#'   time = c(90, 130, 150, 170),
#'   cost = c(9, 13, 15, 16),
#'   cores = c(4, 2, 1, 4)
#' )
#'
#' east$join_where(
#'   west,
#'   pl$col("dur") < pl$col("time"),
#'   pl$col("rev") < pl$col("cost")
#' )
dataframe__join_where <- function(
  other,
  ...,
  suffix = "_right"
) {
  wrap({
    check_polars_df(other)
    self$lazy()$join_where(other$lazy(), ..., suffix = suffix)$collect(`_eager` = TRUE)
  })
}

#' @inherit lazyframe__unpivot title description params
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c("x", "y", "z"),
#'   b = c(1, 3, 5),
#'   c = c(2, 4, 6)
#' )
#' df$unpivot(index = "a", on = c("b", "c"))
dataframe__unpivot <- function(
  on = NULL,
  ...,
  index = NULL,
  variable_name = NULL,
  value_name = NULL
) {
  wrap({
    check_dots_empty0(...)
    # TODO: add selectors handling when py-polars' _expand_selectors() has moved
    # to Rust
    self$`_df`$unpivot(
      on = on %||% character(),
      index = index,
      value_name = value_name,
      variable_name = variable_name
    )
  })
}

#' Convert categorical variables into dummy/indicator variables
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column name(s)
#' that should be converted to dummy variables. If empty (default), convert
#' all columns.
#' @param separator Separator/delimiter used when generating column names.
#' @param drop_first Remove the first category from the variables being encoded.
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1L, 2L),
#'   bar = c(3L, 4L),
#'   ham = c("a", "b")
#' )
#' df$to_dummies()
#'
#' df$to_dummies(drop_first = TRUE)
#' df$to_dummies("foo", "bar", separator = ":")
# df$to_dummies(cs$integer(), separator=":")
# df$to_dummies(cs$integer(), drop_first = TRUE, separator = ":")
dataframe__to_dummies <- function(
  ...,
  separator = "_",
  drop_first = FALSE
) {
  # TODO: add selectors handling when py-polars' _expand_selectors() has moved
  # to Rust (and update examples above)
  wrap({
    check_dots_unnamed()

    dots <- list2(...)
    check_list_of_string(dots, arg = "...")

    if (length(dots) == 0L) {
      columns <- NULL
    } else {
      columns <- as.character(dots)
    }

    self$`_df`$to_dummies(
      columns = columns,
      separator = separator,
      drop_first = drop_first
    )
  })
}

#' Group by the given columns and return the groups as separate dataframes
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column name(s) to group by.
#' @param maintain_order Ensure that the order of the groups is consistent with
#' the input data. This is slower than a default partition by operation.
#' @param include_key Include the columns used to partition the DataFrame in
#' the output.
#'
#' @return A list of polars [DataFrame]s
#' @examples
#' # Pass a single column name to partition by that column.
#' df <- pl$DataFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#' df$partition_by("a")
#'
#' # Partition by multiple columns:
#' df$partition_by("a", "b")
dataframe__partition_by <- function(..., maintain_order = TRUE, include_key = TRUE) {
  wrap({
    # TODO: add selectors handling when py-polars' _expand_selectors() has moved
    # to Rust
    check_dots_unnamed()
    dots <- list2(...)

    if (!is_list_of_string(dots)) {
      abort("`...` only accepts column names.")
    }
    if (length(dots) == 0L) {
      abort("`...` must contain at least one column name.")
    }

    self$`_df`$partition_by(
      by = as.character(dots),
      maintain_order = maintain_order,
      include_key = include_key
    ) |>
      lapply(\(ptr) .savvy_wrap_PlRDataFrame(ptr) |> wrap())
  })
}

#' Pivot a frame from long to wide format
#'
#' Only available in eager mode. See "Examples" section below for how to do a
#' "lazy pivot" if you know the unique column values in advance.
#'
#' @inheritParams rlang::args_dots_empty
#' @param on The column(s) whose values will be used as the new columns of the
#' output DataFrame.
#' @param index The column(s) that remain from the input to the output. The
#' output DataFrame will have one row for each unique combination of the
#' `index`'s values. If `NULL`, all remaining columns not specified in `on` and
#' `values` will be used. At least one of `index` and `values` must be
#' specified.
#' @param values The existing column(s) of values which will be moved under the
#' new columns from `index`. If an aggregation is specified, these are the
#' values on which the aggregation will be computed. If `NULL`, all remaining
#' columns not specified in `on` and `index` will be used. At least one of
#' `index` and `values` must be specified.
#' @param aggregate_function Choose from:
#' * `NULL`: no aggregation takes place, will raise error if multiple values
#'   are in group;
#' * A predefined aggregate function string, one of `"min"`, `"max"`,
#'   `"first"`, `"last"`, `"sum"`, `"mean"`, `"median"`, `"len"`;
#' * An expression to do the aggregation.
#' @param maintain_order Ensure the values of `index` are sorted by discovery
#' order.
#' @param sort_columns Sort the transposed columns by name. Default is by order
#' of discovery.
#' @param separator Used as separator/delimiter in generated column names in
#' case of multiple values columns.
#'
#' @inherit as_polars_df return
#' @examples
#' # Suppose we have a dataframe of test scores achieved by some students,
#' # where each row represents a distinct test.
#' df <- pl$DataFrame(
#'   name = c("Cady", "Cady", "Karen", "Karen"),
#'   subject = c("maths", "physics", "maths", "physics"),
#'   test_1 = c(98, 99, 61, 58),
#'   test_2 = c(100, 100, 60, 60)
#' )
#' df
#'
#' # Using pivot(), we can reshape so we have one row per student, with
#' # different subjects as columns, and their `test_1` scores as values:
#' df$pivot("subject", index = "name", values = "test_1")
#'
# You can use selectors too - here we include all test scores in the pivoted
# table:
# df$pivot("subject", values = cs$starts_with("test"))
#'
#' # If you end up with multiple values per cell, you can specify how to
#' # aggregate them with `aggregate_function`:
#' df <- pl$DataFrame(
#'   ix = c(1, 1, 2, 2, 1, 2),
#'   col = c("a", "a", "a", "a", "b", "b"),
#'   foo = c(0, 1, 2, 2, 7, 1),
#'   bar = c(0, 2, 0, 0, 9, 4)
#' )
#' df
#'
#' df$pivot("col", index = "ix", aggregate_function = "sum")
#'
#' # You can also pass a custom aggregation function using `pl$element()`:
#' df <- pl$DataFrame(
#'   col1 = c("a", "a", "a", "b", "b", "b"),
#'   col2 = c("x", "x", "x", "x", "y", "y"),
#'   col3 = c(6, 7, 3, 2, 5, 7),
#' )
#' df$pivot(
#'   "col2",
#'   index = "col1",
#'   values = "col3",
#'   aggregate_function = pl$element()$tanh()$mean(),
#' )
#'
#' # Note that pivot is only available in eager mode. If you know the unique
#' # column values in advance, you can use `$group_by()` on a LazyFrame to get
#' # the same result as above in lazy mode:
#' index <- pl$col("col1")
#' on <- pl$col("col2")
#' values <- pl$col("col3")
#' unique_column_values <- c("x", "y")
#' aggregate_function <- \(col) col$tanh()$mean()
#' funs <- lapply(unique_column_values, \(value) {
#'   aggregate_function(values$filter(on == value))$alias(value)
#' })
#' df$lazy()$group_by(index)$agg(!!!funs)$collect()
dataframe__pivot <- function(
  on,
  ...,
  index = NULL,
  values = NULL,
  aggregate_function = NULL,
  maintain_order = TRUE,
  sort_columns = FALSE,
  separator = "_"
) {
  # TODO: add selectors handling when py-polars' _expand_selectors() has moved
  # to Rust (and uncomment example above)

  wrap({
    check_dots_empty0(...)
    aggregate_expr <- NULL
    if (is_character(aggregate_function)) {
      aggregate_function <- arg_match0(
        aggregate_function,
        values = c("min", "max", "first", "last", "sum", "mean", "median", "len")
      )
      # fmt: skip
      aggregate_expr <- switch(aggregate_function,
        "min" = pl$element()$min()$`_rexpr`,
        "max" = pl$element()$max()$`_rexpr`,
        "first" = pl$element()$first()$`_rexpr`,
        "last" = pl$element()$last()$`_rexpr`,
        "sum" = pl$element()$sum()$`_rexpr`,
        "mean" = pl$element()$mean()$`_rexpr`,
        "median" = pl$element()$median()$`_rexpr`,
        "len" = pl$len()$`_rexpr`,
        abort("unreachable")
      )
    } else if (is_polars_expr(aggregate_function)) {
      aggregate_expr <- aggregate_function$`_rexpr`
    } else if (!is.null(aggregate_function)) {
      abort("`aggregate_function` must be `NULL`, a character, or a Polars expression.")
    }

    self$`_df`$pivot_expr(
      on = on,
      index = index,
      values = values,
      maintain_order = maintain_order,
      sort_columns = sort_columns,
      aggregate_expr = aggregate_expr,
      separator = separator
    )
  })
}

#' Get the maximum value horizontally across columns.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 3),
#'   bar = c(4.0, 5.0, 6.0),
#' )
#' df$max_horizontal()
dataframe__max_horizontal <- function() {
  self$select(max = pl$max_horizontal(pl$all()))$to_series() |>
    wrap()
}

#' Take the mean of all values horizontally across columns.
#'
#' @inheritParams rlang::args_dots_empty
#' @param ignore_nulls Ignore null values (default). If `FALSE`, any null value
#' in the input will lead to a null output.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 3),
#'   bar = c(4.0, 5.0, 6.0),
#' )
#' df$mean_horizontal()
dataframe__mean_horizontal <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$select(mean = pl$mean_horizontal(pl$all(), ignore_nulls = ignore_nulls))$to_series()
  })
}

#' Get the minimum value horizontally across columns.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 3),
#'   bar = c(4.0, 5.0, 6.0),
#' )
#' df$min_horizontal()
dataframe__min_horizontal <- function() {
  self$select(min = pl$min_horizontal(pl$all()))$to_series() |>
    wrap()
}

#' Sum all values horizontally across columns.
#'
#' @inheritParams rlang::args_dots_empty
#' @param ignore_nulls Ignore null values (default). If `FALSE`, any null value
#' in the input will lead to a null output.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 3),
#'   bar = c(4.0, 5.0, 6.0),
#' )
#' df$sum_horizontal()
dataframe__sum_horizontal <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$select(sum = pl$sum_horizontal(pl$all(), ignore_nulls = ignore_nulls))$to_series()
  })
}

#' Aggregate the columns in the DataFrame to their maximum value
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$max()
dataframe__max <- function() {
  self$lazy()$max()$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns in the DataFrame to their minimum value
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$min()
dataframe__min <- function() {
  self$lazy()$min()$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns in the DataFrame to their mean value
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$mean()
dataframe__mean <- function() {
  self$lazy()$mean()$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns in the DataFrame to their median value
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$median()
dataframe__median <- function() {
  self$lazy()$median()$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns of this DataFrame to their sum values
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$sum()
dataframe__sum <- function() {
  self$lazy()$sum()$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns in the DataFrame to their variance value
#'
#' @inheritParams lazyframe__var
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$var()
#' df$var(ddof = 0)
dataframe__var <- function(ddof = 1) {
  self$lazy()$var(ddof)$collect(`_eager` = TRUE) |>
    wrap()
}

#' Aggregate the columns of this DataFrame to their standard deviation values
#'
#' @inheritParams lazyframe__std
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$std()
#' df$std(ddof = 0)
dataframe__std <- function(ddof = 1) {
  self$lazy()$std(ddof)$collect(`_eager` = TRUE) |>
    wrap()
}

#' @inherit lazyframe__quantile title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(a = 1:4, b = c(1, 2, 1, 1))
#' df$quantile(0.7)
dataframe__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  wrap({
    interpolation <- arg_match0(
      interpolation,
      values = c("nearest", "higher", "lower", "midpoint", "linear")
    )
    self$lazy()$quantile(quantile, interpolation)$collect(`_eager` = TRUE)
  })
}

#' Get a mask of all unique rows in this DataFrame.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, 3, 1),
#'   b = c("x", "y", "z", "x")
#' )
#' df$is_unique()
#'
#' # This mask can be used to visualize the unique lines like this:
#' df$filter(df$is_unique())
dataframe__is_unique <- function() {
  self$`_df`$is_unique() |>
    wrap()
}

#' Get a mask of all duplicated rows in this DataFrame.
#'
#' @inherit as_polars_series return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, 3, 1),
#'   b = c("x", "y", "z", "x")
#' )
#' df$is_duplicated()
#'
#' # This mask can be used to visualize the duplicated lines like this:
#' df$filter(df$is_duplicated())
dataframe__is_duplicated <- function() {
  self$`_df`$is_duplicated() |>
    wrap()
}

#' Returns `TRUE` if the DataFrame contains no rows.
#'
#' @return A logical value
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, 3, 1),
#'   b = c("x", "y", "z", "x")
#' )
#' df$is_empty()
#' df$filter(pl$col("a") > 99)$is_empty()
dataframe__is_empty <- function() {
  self$`_df`$is_empty() |>
    wrap()
}

#' @inherit lazyframe__rolling title description params
#'
#' @return [RollingGroupBy][RollingGroupBy_class] (a DataFrame with special
#' rolling groupby methods like `$agg()`).
#' @seealso
#' - [`<DataFrame>$group_by_dynamic()`][dataframe__group_by_dynamic]
#' @examples
#' dates <- c(
#'   "2020-01-01 13:45:48",
#'   "2020-01-01 16:42:13",
#'   "2020-01-01 16:45:09",
#'   "2020-01-02 18:12:48",
#'   "2020-01-03 19:45:32",
#'   "2020-01-08 23:16:43"
#' )
#'
#' df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
#'   pl$col("dt")$str$strptime(pl$Datetime())
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   sum_a = pl$col("a")$sum(),
#'   min_a = pl$col("a")$min(),
#'   max_a = pl$col("a")$max()
#' )
dataframe__rolling <- function(
  index_column,
  ...,
  period,
  offset = NULL,
  closed = c("right", "left", "both", "none"),
  group_by = NULL
) {
  wrap({
    check_dots_empty0(...)
    wrap_to_rolling_group_by(
      self,
      index_column = index_column,
      period = period,
      offset = offset,
      closed = closed,
      group_by = group_by
    )
  })
}

#' Transpose a DataFrame over the diagonal
#'
#' @inheritParams rlang::args_dots_empty
#' @param include_header If set, the column names will be added as first column.
#' @param header_name If `include_header` is set, this determines the name of
#' the column that will be inserted.
#' @param column_names Optional string naming an existing column, or a function
#' that takes an integer vector representing the position of value (non-header)
#' columns and returns a character vector of same length. Column position is
#' 0-indexed.
#'
#' @inherit as_polars_df return
#'
#' @details
#' This is a very expensive operation. Perhaps you can do it differently.
#'
#' @examples
#' df <- pl$DataFrame(a = c(1, 2, 3), b = c(4, 5, 6))
#' df$transpose(include_header = TRUE)
#'
#' # Replace the auto-generated column names with a list
#' df$transpose(include_header = FALSE, column_names = c("x", "y", "z"))
#'
#' # Include the header as a separate column
#' df$transpose(
#'   include_header = TRUE, header_name = "foo", column_names = c("x", "y", "z")
#' )
#'
#' # Use a function to produce the new column names
#' name_generator <- function(x) {
#'   paste0("my_column_", x)
#' }
#' df$transpose(include_header = FALSE, column_names = name_generator)
#'
#' # Use an existing column as the new column names
#' df <- pl$DataFrame(id = c("i", "j", "k"), a = c(1, 2, 3), b = c(4, 5, 6))
#' df$transpose(column_names = "id")
#' df$transpose(include_header = TRUE, header_name = "new_id", column_names = "id")
dataframe__transpose <- function(
  ...,
  include_header = FALSE,
  header_name = "column",
  column_names = NULL
) {
  wrap({
    check_dots_empty0(...)
    keep_names_as <- if (isTRUE(include_header)) {
      check_string(header_name, allow_null = TRUE)
      header_name
    } else {
      NULL
    }
    if (is_function(column_names)) {
      n_elems <- nrow(self)
      column_names <- column_names(seq_len(n_elems) - 1)
      if (!is_character(column_names, n = n_elems)) {
        abort(
          paste(
            "The function in `column_names` must return a character vector with",
            n_elems,
            "elements."
          )
        )
      }
    }
    self$`_df`$transpose(
      keep_names_as = keep_names_as,
      column_names = column_names %||% character()
    )
  })
}

#' Write to Parquet file
#'
#' @inheritParams lazyframe__sink_parquet
#' @param file File path to which the result should be written. This should be
#' a path to a directory if writing a partitioned dataset.
#' @param partition_by A character vector indicating column(s) to partition by.
#' A partitioned dataset will be written if this is specified.
#' @param partition_chunk_size_bytes Approximate size to split DataFrames within
#' a single partition when writing. Note this is calculated using the size of
#' the DataFrame in memory (the size of the output file may differ depending
#' on the file format / compression).
#'
#' @return The input DataFrame is returned.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' dat = as_polars_df(mtcars)
#'
#' # write data to a single parquet file
#' destination = withr::local_tempfile(fileext = ".parquet")
#' dat$write_parquet(destination)
#'
#' # write data to folder with a hive-partitioned structure
#' dest_folder = withr::local_tempdir()
#' dat$write_parquet(dest_folder, partition_by = c("gear", "cyl"))
#' list.files(dest_folder, recursive = TRUE)
dataframe__write_parquet <- function(
  file,
  ...,
  compression = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd"),
  compression_level = NULL,
  statistics = TRUE,
  row_group_size = NULL,
  data_page_size = NULL,
  partition_by = NULL,
  partition_chunk_size_bytes = 4294967296,
  storage_options = NULL,
  retries = 2
) {
  wrap({
    compression <- compression %||% "uncompressed"
    check_dots_empty0(...)
    check_character(partition_by, allow_null = TRUE)
    compression <- arg_match0(
      compression,
      values = c("lz4", "uncompressed", "snappy", "gzip", "lzo", "brotli", "zstd")
    )
    if (is_bool(statistics)) {
      statistics <- parquet_statistics(
        min = statistics,
        max = statistics,
        distinct_count = FALSE,
        null_count = statistics
      )
    } else if (identical(statistics, "full")) {
      statistics <- parquet_statistics(
        min = TRUE,
        max = TRUE,
        distinct_count = TRUE,
        null_count = TRUE
      )
    }
    if (!inherits(statistics, "polars_parquet_statistics")) {
      abort("`statistics` must be TRUE, FALSE, 'full', or a call to `parquet_statistics()`.")
    }
    self$`_df`$write_parquet(
      path = file,
      compression = compression,
      compression_level = compression_level,
      stat_min = statistics[["min"]],
      stat_max = statistics[["max"]],
      stat_null_count = statistics[["null_count"]],
      stat_distinct_count = statistics[["distinct_count"]],
      row_group_size = row_group_size,
      data_page_size = data_page_size,
      partition_by = partition_by,
      partition_chunk_size_bytes = partition_chunk_size_bytes,
      storage_options = storage_options,
      retries = retries
    )
    invisible(self)
  })
}
