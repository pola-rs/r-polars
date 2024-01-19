#' @title Inner workings of the DataFrame-class
#'
#' @name DataFrame_class
#' @description
#' The `DataFrame`-class is simply two environments of respectively the public
#' and private methods/function calls to the polars Rust side. The instantiated
#' `DataFrame`-object is an `externalptr` to a low-level Rust polars DataFrame
#' object.
#'
#' The S3 method `.DollarNames.RPolarsDataFrame` exposes all public `$foobar()`-methods
#' which are callable onto the object. Most methods return another `DataFrame`-
#' class instance or similar which allows for method chaining. This class system
#' could be called "environment classes" (in lack of a better name) and is the
#' same class system `extendr` provides, except here there are both a public and
#' private set of methods. For implementation reasons, the private methods are
#' external and must be called from `.pr$DataFrame$methodname()`. Also, all
#' private methods must take any `self` as an argument, thus they are pure
#' functions. Having the private methods as pure functions solved/simplified
#' self-referential complications.
#'
#' @details
#' Check out the source code in [R/dataframe_frame.R](https://github.com/pola-rs/r-polars/blob/main/R/dataframe__frame.R)
#' to see how public methods are derived from private methods. Check out
#' [extendr-wrappers.R](https://github.com/pola-rs/r-polars/blob/main/R/extendr-wrappers.R)
#' to see the `extendr`-auto-generated methods. These are moved to `.pr` and
#' converted into pure external functions in [after-wrappers.R](https://github.com/pola-rs/r-polars/blob/main/R/after-wrappers.R). In [zzz.R](https://github.com/pola-rs/r-polars/blob/main/R/zzz.R)
#' (named `zzz` to be last file sourced) the `extendr`-methods are removed and
#' replaced by any function prefixed `DataFrame_`.
#'
#' @keywords DataFrame
#' @return Not applicable
#' @examples
#' # see all public exported method names (normally accessed via a class
#' # instance with $)
#' ls(.pr$env$RPolarsDataFrame)
#'
#' # see all private methods (not intended for regular use)
#' ls(.pr$DataFrame)
#'
#'
#' # make an object
#' df = pl$DataFrame(iris)
#'
#'
#' # use a public method/property
#' df$shape
#' df2 = df
#'
#' # use a private method, which has mutability
#' result = .pr$DataFrame$set_column_from_robj(df, 150:1, "some_ints")
#'
#' # Column exists in both dataframes-objects now, as they are just pointers to
#' # the same object
#' # There are no public methods with mutability.
#' df$columns
#' df2$columns
#'
#' # set_column_from_robj-method is fallible and returned a result which could
#' # be "ok" or an error.
#' # No public method or function will ever return a result.
#' # The `result` is very close to the same as output from functions decorated
#' # with purrr::safely.
#' # To use results on the R side, these must be unwrapped first such that
#' # potentially errors can be thrown. `unwrap(result)` is a way to communicate
#' # errors happening on the Rust side to the R side. `Extendr` default behavior
#' # is to use `panic!`(s) which would cause some unnecessarily confusing and
#' # some very verbose error messages on the inner workings of rust.
#' # `unwrap(result)` in this case no error, just a NULL because this mutable
#' # method does not return any ok-value.
#'
#' # Try unwrapping an error from polars due to unmatching column lengths
#' err_result = .pr$DataFrame$set_column_from_robj(df, 1:10000, "wrong_length")
#' tryCatch(unwrap(err_result, call = NULL), error = \(e) cat(as.character(e)))
NULL


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x DataFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @return Doesn't return a value. This is used for autocompletion in RStudio.
#' @noRd
.DollarNames.RPolarsDataFrame = function(x, pattern = "") {
  get_method_usages(RPolarsDataFrame, pattern = pattern)
}


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RPolarsVecDataFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsVecDataFrame = function(x, pattern = "") {
  get_method_usages(RPolarsVecDataFrame, pattern = pattern)
}




#' Create new DataFrame
#' @name pl_DataFrame
#'
#' @param ... One of the following:
#'  - a data.frame or something that inherits data.frame or DataFrame
#'  - a list of mixed vectors and Series of equal length
#'  - mixed vectors and/or Series of equal length
#'
#' Columns will be named as of named arguments or alternatively by names of
#' Series or given a placeholder name.
#'
#' @param make_names_unique If `TRUE` (default), any duplicated names will be
#'  prefixed a running number.
#' @param schema A named list that will be used to convert a variable to a
#' specific DataType. See Examples.
#'
#' @return DataFrame
#' @keywords DataFrame_new
#'
#' @examples
#' pl$DataFrame(
#'   a = list(c(1, 2, 3, 4, 5)), # NB if first column should be a list, wrap it in a Series
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1:1, 1:2, 1:3, 1:4, 1:5)
#' ) # directly from vectors
#'
#' # from a list of vectors
#' pl$DataFrame(list(
#'   a = c(1, 2, 3, 4, 5),
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1L, 1:2, 1:3, 1:4, 1:5)
#' ))
#'
#' # from a data.frame
#' pl$DataFrame(mtcars)
#'
#' # custom schema
#' pl$DataFrame(iris, schema = list(Sepal.Length = pl$Float32, Species = pl$String))
pl_DataFrame = function(..., make_names_unique = TRUE, schema = NULL) {
  uw = \(res) unwrap(res, "in $DataFrame():")

  largs = unpack_list(...) |>
    result() |>
    uw()

  if (!is.null(schema) && !all(names(schema) %in% names(largs))) {
    Err_plain("Some columns in `schema` are not in the DataFrame.") |>
      uw()
  }

  # no args crete empty DataFrame
  if (length(largs) == 0L) {
    return(.pr$DataFrame$default())
  }

  # pass through if already a DataFrame
  if (inherits(largs[[1L]], "RPolarsDataFrame")) {
    return(largs[[1L]])
  }

  # keys are tentative new column names
  keys = names(largs)
  if (length(keys) == 0) keys = rep(NA_character_, length(largs))
  keys = mapply(largs, keys, FUN = function(column, key) {
    if (is.na(key) || nchar(key) == 0) {
      if (inherits(column, "RPolarsSeries")) {
        key = column$name
      } else {
        key = "new_column"
      }
    }
    return(key)
  })

  result({
    # check for conflicting names, to avoid silent overwrite
    if (anyDuplicated(keys) > 0) {
      if (make_names_unique) {
        keys = make.unique(keys, sep = "_")
      } else {
        stop(
          paste(
            "conflicting column names not allowed:",
            paste(unique(keys[duplicated(keys)]), collapse = ", ")
          )
        )
      }
    }

    ## pass each arg to pl$lit and all args to pl$select
    names(largs) = keys
    lapply(seq_along(largs), \(x) {
      varname = keys[x]
      out = pl$lit(largs[[x]])
      if (!is.null(schema) && varname %in% names(schema)) {
        out = out$cast(schema[[varname]], strict = TRUE)
      }
      out$alias(varname)
    }) |>
      do.call(what = pl$select)
  }) |>
    uw()
}


#' S3 method to print a DataFrame
#'
#' @noRd
#' @param x DataFrame
#' @param ... not used
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
print.RPolarsDataFrame = function(x, ...) {
  x$print()
  invisible(x)
}

#' internal method print DataFrame
#' @noRd
#' @return self
#'
#' @examples pl$DataFrame(iris)
DataFrame_print = function() {
  .pr$DataFrame$print(self)
  invisible(self)
}

## internal bookkeeping of methods which should behave as properties
DataFrame.property_setters = new.env(parent = emptyenv())

#' generic setter method
#' @noRd
#' @param self DataFrame
#' @param name name method/property to set
#' @param value value to insert
#'
#' @description set value of properties of DataFrames
#'
#' @return value
#' @keywords DataFrame
#' @details settable polars object properties may appear to be R objects, but they are not.
#' See `[[method_name]]` example
#'
#' @export
#' @examples
#' # For internal use
#' # show what methods of DataFrame have active property setters
#' with(.pr$env, ls(DataFrame.property_setters))
#'
#' # specific use case for one object property 'columns' (names)
#' df = pl$DataFrame(iris)
#'
#' # get values
#' df$columns
#'
#' # set + get values
#' df$columns = letters[1:5] #<- is fine too
#' df$columns
#'
#' # Rstudio is not using the standard R code completion tool
#' # and it will backtick any special characters. It is possible
#' # to completely customize the R / Rstudio code completion except
#' # it will trigger Rstudio to backtick any completion! Also R does
#' # not support package isolated customization.
#'
#'
#' # Concrete example if tabbing on 'df$' the raw R suggestion is df$columns<-
#' # however Rstudio backticks it into df$`columns<-`
#' # to make life simple, this is valid polars syntax also, and can be used in fast scripting
#' df$`columns<-` = letters[5:1]
#'
#' # for stable code prefer e.g.  df$columns = letters[5:1]
#'
#' # to verify inside code of a property, use the [[]] syntax instead.
#' df[["columns"]] # to see property code, .pr is the internal polars api into rust polars
#' DataFrame.property_setters$columns # and even more obscure to see setter code
"$<-.RPolarsDataFrame" = function(self, name, value) {
  name = sub("<-$", "", name)

  # stop if method is not a setter
  if (!inherits(self[[name]], "setter")) {
    pstop(err = paste("no setter method for", name))
  }

  if (polars_optenv$strictly_immutable) self = self$clone()
  func = DataFrame.property_setters[[name]]
  func(self, value)
  self
}

#' @title Add a column for row indices
#' @description Add a new column at index 0 that counts the rows
#' @keywords DataFrame
#' @param name string name of the created column
#' @param offset positive integer offset for the start of the counter
#' @return A new `DataFrame` object with a counter column in front
#' @docType NULL
#' @examples
#' df = pl$DataFrame(mtcars)
#'
#' # by default, the index starts at 0 (to mimic the behavior of Python Polars)
#' df$with_row_count("idx")
#'
#' # but in R, we use a 1-index
#' df$with_row_count("idx", offset = 1)
DataFrame_with_row_count = function(name, offset = NULL) {
  .pr$DataFrame$with_row_count(self, name, offset) |> unwrap()
}

#' Get and set column names of a DataFrame
#' @name DataFrame_columns
#' @rdname DataFrame_columns
#'
#' @return A character vector with the column names.
#' @keywords DataFrame
#'
#' @examples
#' df = pl$DataFrame(iris)
#'
#' # get values
#' df$columns
#'
#' # set + get values
#' df$columns = letters[1:5] # <- is fine too
#' df$columns
DataFrame_columns = method_as_property(function() {
  .pr$DataFrame$columns(self)
}, setter = TRUE)

# define setter function
DataFrame.property_setters$columns = function(self, names) {
  unwrap(.pr$DataFrame$set_column_names_mut(self, names))
}


#' @title Drop columns of a DataFrame
#' @keywords DataFrame
#' @param columns A character vector with the names of the column(s) to remove.
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$drop(c("mpg", "hp"))
DataFrame_drop = function(columns) {
  self$lazy()$drop(columns)$collect()
}


#' @title Drop nulls (missing values)
#' @description Drop all rows that contain nulls (which correspond to `NA` in R).
#' @keywords DataFrame
#' @param subset A character vector with the names of the column(s) for which
#' nulls are considered. If `NULL` (default), use all columns.
#'
#' @return DataFrame
#' @examples
#' tmp = mtcars
#' tmp[1:3, "mpg"] = NA
#' tmp[4, "hp"] = NA
#' tmp = pl$DataFrame(tmp)
#'
#' # number of rows in `tmp` before dropping nulls
#' tmp$height
#'
#' tmp$drop_nulls()$height
#' tmp$drop_nulls("mpg")$height
#' tmp$drop_nulls(c("mpg", "hp"))$height
DataFrame_drop_nulls = function(subset = NULL) {
  self$lazy()$drop_nulls(subset)$collect()
}


#' @title Drop duplicated rows
#'
#' @keywords DataFrame
#'
#' @param subset A character vector with the names of the column(s) to use to
#'  identify duplicates. If `NULL` (default), use all columns.
#' @param keep Which of the duplicate rows to keep:
#' * "first": Keep first unique row.
#' * "last": Keep last unique row.
#' * "none": Don’t keep duplicate rows.
#' @param maintain_order Keep the same order as the original `DataFrame`. Setting
#'  this to `TRUE` makes it more expensive to compute and blocks the possibility
#'  to run on the streaming engine. The default value can be changed with
#' `pl$set_options(maintain_order = TRUE)`.
#'
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(
#'   x = sample(10, 100, rep = TRUE),
#'   y = sample(10, 100, rep = TRUE)
#' )
#' df$height
#'
#' df$unique()$height
#' df$unique(subset = "x")$height
#'
#' df$unique(keep = "last")
#'
#' # only keep unique rows
#' df$unique(keep = "none")
DataFrame_unique = function(subset = NULL, keep = "first", maintain_order = FALSE) {
  self$lazy()$unique(subset, keep, maintain_order)$collect()
}


#' Dimensions of a DataFrame
#' @name DataFrame_shape
#' @description Get shape/dimensions of DataFrame
#'
#' @return Numeric vector of length two with the number of rows and the number
#' of columns.
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$shape
DataFrame_shape = method_as_property(function() {
  .pr$DataFrame$shape(self)
})



#' Number of rows of a DataFrame
#' @name DataFrame_height
#' @description Get the number of rows (height) of a DataFrame
#'
#' @return The number of rows of the DataFrame
#' @aliases height nrow
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$height
DataFrame_height = method_as_property(function() {
  .pr$DataFrame$shape(self)[1L]
})


#' Number of columns of a DataFrame
#' @name DataFrame_width
#' @description Get the number of columns (width) of a DataFrame
#'
#' @return The number of columns of a DataFrame
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$width
DataFrame_width = method_as_property(function() {
  .pr$DataFrame$shape(self)[2L]
})


#' Data types information
#' @name DataFrame_dtypes
#' @description Get the data type of all columns. You can see all available
#' types with `names(pl$dtypes)`. The data type of each column is also shown
#' when printing the DataFrame.
#'
#' @return
#' `$dtypes` returns an unnamed list with the data type of each column.
#' `$schema` returns a named list with the column names and the data type of
#' each column.
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$dtypes
#'
#' pl$DataFrame(iris)$schema
DataFrame_dtypes = method_as_property(function() {
  .pr$DataFrame$dtypes(self)
})

#' Data types information
#' @name DataFrame_dtype_strings
#' @description Get the data type of all columns as strings. You can see all
#' available types with `names(pl$dtypes)`. The data type of each column is also
#' shown when printing the DataFrame.
#'
#' @docType NULL
#' @format NULL
#' @return A character vector with the data type of each column
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$dtype_strings()
DataFrame_dtype_strings = use_extendr_wrapper

#' @rdname DataFrame_dtypes

DataFrame_schema = method_as_property(function() {
  .pr$DataFrame$schema(self)
})


#' Convert an existing DataFrame to a LazyFrame
#' @name DataFrame_lazy
#' @description Start a new lazy query from a DataFrame.
#'
#' @docType NULL
#' @format NULL
#' @return A LazyFrame
#' @aliases lazy
#' @keywords  DataFrame LazyFrame_new
#' @examples
#' pl$DataFrame(iris)$lazy()
DataFrame_lazy = use_extendr_wrapper

#' Clone a DataFrame
#' @name DataFrame_clone
#' @description This is rarely useful as a DataFrame is nearly 100% immutable.
#' Any modification of a DataFrame would lead to a clone anyway.
#'
#' @return A DataFrame
#' @aliases DataFrame_clone
#' @keywords  DataFrame
#' @examples
#' df1 = pl$DataFrame(iris)
#' df2 = df1$clone()
#' df3 = df1
#'
#' # the clone and the original don't have the same address...
#' pl$mem_address(df1) != pl$mem_address(df2)
#'
#' # ... but simply assigning df1 to df3 change the address anyway
#' pl$mem_address(df1) == pl$mem_address(df3)
DataFrame_clone = function() {
  .pr$DataFrame$clone_in_rust(self)
}

#' Get columns (as Series)
#' @name DataFrame_get_columns
#' @description Extract all DataFrame columns as a list of Polars series.
#'
#' @return A list of series
#' @keywords  DataFrame
#' @docType NULL
#' @format NULL
#' @examples
#' df = pl$DataFrame(iris[1:2, ])
#' df$get_columns()
DataFrame_get_columns = use_extendr_wrapper

#' Get column (as one Series)
#' @name DataFrame_get_column
#' @description Extract a DataFrame column as a Polars series.
#'
#' @param name Name of the column to extract.
#'
#' @return Series
#' @aliases DataFrame_get_column
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1:2, ])
#' df$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self, name), "in $get_column():")
}

#' Get column by index
#'
#' @name DataFrame_to_series
#' @description Extract a DataFrame column (by index) as a Polars series. Unlike
#' `get_column()`, this method will not fail but will return a `NULL` if the
#' index doesn't exist in the DataFrame. Keep in mind that Polars is 0-indexed
#' so "0" is the first column.
#'
#' @param idx Index of the column to return as Series. Defaults to 0, which is
#' the first column.
#'
#' @return Series or NULL
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1:10, ])
#'
#' # default is to extract the first column
#' df$to_series()
#'
#' # Polars is 0-indexed, so we use idx = 1 to extract the *2nd* column
#' df$to_series(idx = 1)
#'
#' # doesn't error if the column isn't there
#' df$to_series(idx = 8)
DataFrame_to_series = function(idx = 0) {
  if (!is.numeric(idx) || isTRUE(idx < 0)) {
    pstop(err = "idx must be non-negative numeric")
  }
  .pr$DataFrame$select_at_idx(self, idx)$ok
}

#' Sort a DataFrame
#' @inheritParams DataFrame_unique
#' @inherit LazyFrame_sort details description params
#' @return DataFrame
#' @keywords  DataFrame
#' @examples
#' df = mtcars
#' df$mpg[1] = NA
#' df = pl$DataFrame(df)
#' df$sort("mpg")
#' df$sort("mpg", nulls_last = TRUE)
#' df$sort("cyl", "mpg")
#' df$sort(c("cyl", "mpg"))
#' df$sort(c("cyl", "mpg"), descending = TRUE)
#' df$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE))
#' df$sort(pl$col("cyl"), pl$col("mpg"))
DataFrame_sort = function(
    by,
    ...,
    descending = FALSE,
    nulls_last = FALSE,
    maintain_order = FALSE) {
  self$lazy()$sort(
    by, ...,
    descending = descending, nulls_last = nulls_last, maintain_order = maintain_order
  )$collect()
}


#' Select and modify columns of a DataFrame
#' @name DataFrame_select
#' @description Similar to `dplyr::mutate()`. However, it discards unmentioned
#' columns (like `.()` in `data.table`).
#'
#' @param ... Columns to keep. Those can be expressions (e.g `pl$col("a")`),
#' column names  (e.g `"a"`), or list containing expressions or column names
#' (e.g `list(pl$col("a"))`).
#'
#' @aliases select
#' @return DataFrame
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$select(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
DataFrame_select = function(...) {
  .pr$DataFrame$select(self, unpack_list(..., .context = "in $select()")) |>
    unwrap("in $select()")
}

#' Drop in place
#' @name DataFrame_drop_in_place
#' @description Drop a single column in-place and return the dropped column.
#'
#' @param name string Name of the column to drop.
#' @return Series
#' @keywords  DataFrame
#' @examples
#' dat = pl$DataFrame(iris)
#' x = dat$drop_in_place("Species")
#' x
#' dat$columns
DataFrame_drop_in_place = function(name) {
  .pr$DataFrame$drop_in_place(self, name)
}

#' Compare two DataFrames
#' @name DataFrame_equals
#' @description Check if two DataFrames are equal.
#'
#' @param other DataFrame to compare with.
#' @return A boolean.
#' @keywords DataFrame
#' @examples
#' dat1 = pl$DataFrame(iris)
#' dat2 = pl$DataFrame(iris)
#' dat3 = pl$DataFrame(mtcars)
#' dat1$equals(dat2)
#' dat1$equals(dat3)
DataFrame_equals = function(other) {
  .pr$DataFrame$equals(self, other)
}

#' Shift a DataFrame
#'
#' @description Shift the values by a given period. If the period (`n`) is positive,
#' then `n` rows will be inserted at the top of the DataFrame and the last `n`
#' rows will be discarded. Vice-versa if the period is negative. In the end,
#' the total number of rows of the DataFrame doesn't change.
#'
#' @keywords DataFrame
#' @param periods Number of periods to shift (can be negative).
#' @return DataFrame
#' @examples
#' pl$DataFrame(mtcars)$shift(2)
#'
#' pl$DataFrame(mtcars)$shift(-2)
DataFrame_shift = function(periods = 1) {
  self$lazy()$shift(periods)$collect()
}

#' @title Shift and fill
#'
#' @description Shift the values by a given period and fill the resulting null
#' values. See the docs of `$shift()` for more details on shifting.
#' @keywords DataFrame
#'
#' @param fill_value Fill new `NULL` values with this value. Must of length 1.
#' A logical value will be converted to numeric.
#' @param periods Number of periods to shift (can be negative).
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(mtcars)
#'
#' # insert two rows filled with 0 at the top of the DataFrame
#' df$shift_and_fill(0, 2)
#'
#' # automatic conversion of logical value to numeric
#' df$shift_and_fill(TRUE, 2)
DataFrame_shift_and_fill = function(fill_value, periods = 1) {
  self$lazy()$shift_and_fill(fill_value, periods)$collect()
}

#' Modify/append column(s)
#'
#' Add columns or modify existing ones with expressions. This is
#' the equivalent of `dplyr::mutate()` as it keeps unmentioned columns (unlike
#' `$select()`).
#'
#' @name DataFrame_with_columns
#' @aliases with_columns
#' @param ... Any expressions or string column name, or same wrapped in a list.
#' If first and only element is a list, it is unwrapped as a list of args.
#' @keywords DataFrame
#' @return A DataFrame
#' @examples
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#'
#' # same query
#' l_expr = list(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#' pl$DataFrame(iris)$with_columns(l_expr)
#'
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), # not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width") + 2)
#' )
DataFrame_with_columns = function(...) {
  .pr$DataFrame$with_columns(self, unpack_list(..., .context = "in $with_columns()")) |>
    unwrap("in $with_columns()")
}



#' Limit a DataFrame
#' @name DataFrame_limit
#' @description Take some maximum number of rows.
#' @param n Positive number not larger than 2^32.
#'
#' @details Any number will converted to u32. Negative raises error.
#' @keywords  DataFrame
#' @return DataFrame
#' @examples
#' pl$DataFrame(iris)$limit(6)
DataFrame_limit = function(n) {
  self$lazy()$limit(n)$collect()
}

#' Head of a DataFrame
#' @name DataFrame_head
#' @description Get the first `n` rows of the query.
#' @param n Positive number not larger than 2^32.
#'
#' @inherit DataFrame_limit details
#' @keywords  DataFrame
#' @return DataFrame

DataFrame_head = function(n) {
  self$lazy()$head(n)$collect()
}

#' Tail of a DataFrame
#' @name DataFrame_tail
#' @description Get the last `n` rows.
#' @param n Positive number not larger than 2^32.
#'
#' @inherit DataFrame_limit details
#' @keywords  DataFrame
#' @return DataFrame

DataFrame_tail = function(n) {
  self$lazy()$tail(n)$collect()
}


#' Filter rows of a DataFrame
#' @name DataFrame_filter
#'
#' @inherit LazyFrame_filter description params details
#'
#' @keywords DataFrame
#' @return A DataFrame with only the rows where the conditions are `TRUE`.
#' @examples
#' df = pl$DataFrame(iris)
#'
#' df$filter(pl$col("Sepal.Length") > 5)
#'
#' # This is equivalent to
#' # df$filter(pl$col("Sepal.Length") > 5 & pl$col("Petal.Width") < 1)
#' df$filter(pl$col("Sepal.Length") > 5, pl$col("Petal.Width") < 1)
#'
#' # rows where condition is NA are dropped
#' iris2 = iris
#' iris2[c(1, 3, 5), "Species"] = NA
#' df = pl$DataFrame(iris2)
#'
#' df$filter(pl$col("Species") == "setosa")
DataFrame_filter = function(...) {
  .pr$DataFrame$lazy(self)$filter(...)$collect()
}

#' Group a DataFrame
#' @inheritParams DataFrame_unique
#' @inherit LazyFrame_group_by description params
#' @keywords DataFrame
#' @return GroupBy (a DataFrame with special groupby methods like `$agg()`)
#' @examples
#' gb = pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$group_by("foo", maintain_order = TRUE)
#'
#' gb
#'
#' gb$agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
DataFrame_group_by = function(..., maintain_order = pl$options$maintain_order) {
  # clone the DataFrame, bundle args as attributes. Non fallible.
  construct_group_by(
    self,
    groupby_input = unpack_list(..., .context = "$group_by()"),
    maintain_order = maintain_order
  )
}


#' Return Polars DataFrame as R data.frame
#'
#' @param ... Any args pased to `as.data.frame()`.
#'
#' @return An R data.frame
#' @keywords DataFrame
#' @examples
#' df = pl$DataFrame(iris[1:3, ])
#' df$to_data_frame()
DataFrame_to_data_frame = function(...) {
  # do not unnest structs and mark with I to also preserve categoricals as is
  l = lapply(self$to_list(unnest_structs = FALSE), I)

  # similar to as.data.frame, but avoid checks, whcih would edit structs
  df = data.frame(seq_along(l[[1L]]), ...)
  for (i in seq_along(l)) df[[i]] = l[[i]]
  names(df) = .pr$DataFrame$columns(self)

  # remove AsIs (I) subclass from columns
  df[] = lapply(df, unAsIs)
  df
}


#' Return Polars DataFrame as a list of vectors
#'
#' @param unnest_structs Boolean. If `TRUE` (default), then `$unnest()` is applied
#' on any struct column.
#'
#' @details
#' For simplicity reasons, this implementation relies on unnesting all structs
#' before exporting to R. If `unnest_structs = FALSE`, then `struct` columns
#' will be returned as nested lists, where each row is a list of values. Such a
#' structure is not very typical or efficient in R.
#'
#' @return R list of vectors
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$to_list()
DataFrame_to_list = function(unnest_structs = TRUE) {
  if (unnest_structs) {
    unwrap(.pr$DataFrame$to_list(self))
  } else {
    restruct_list(unwrap(.pr$DataFrame$to_list_tag_structs(self)))
  }
}

#' Join DataFrames
#'
#' This function can do both mutating joins (adding columns based on matching
#' observations, for example with `how = "left"`) and filtering joins (keeping
#' observations based on matching observations, for example with `how = "inner"`).
#'
#' @param other DataFrame
#' @param on Either a vector of column names or a list of expressions and/or
#' strings. Use `left_on` and `right_on` if the column names to match on are
#' different between the two DataFrames.
#' @param left_on,right_on Same as `on` but only for the left or the right
#' DataFrame. They must have the same length.
#' @param how One of the following methods: "inner", "left", "outer", "semi",
#' "anti", "cross".
#' @param suffix Suffix to add to duplicated column names.
#' @param allow_parallel Boolean.
#' @param force_parallel Boolean.
#' @return DataFrame
#' @keywords DataFrame
#' @examples
#' # inner join by default
#' df1 = pl$DataFrame(list(key = 1:3, payload = c("f", "i", NA)))
#' df2 = pl$DataFrame(list(key = c(3L, 4L, 5L, NA_integer_)))
#' df1$join(other = df2, on = "key")
#'
#' # cross join
#' df1 = pl$DataFrame(x = letters[1:3])
#' df2 = pl$DataFrame(y = 1:4)
#' df1$join(other = df2, how = "cross")
DataFrame_join = function(
    other, # : LazyFrame or DataFrame,
    left_on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    right_on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    how = c("inner", "left", "outer", "semi", "anti", "cross"),
    suffix = "_right",
    allow_parallel = TRUE,
    force_parallel = FALSE) {
  .pr$DataFrame$lazy(self)$join(
    other = other$lazy(), left_on = left_on, right_on = right_on,
    on = on, how = how, suffix = suffix, allow_parallel = allow_parallel,
    force_parallel = force_parallel
  )$collect()
}

#' Convert DataFrame to a Series of type "struct"
#' @param name Name given to the new Series
#' @return A Series of type "struct"
#' @aliases to_struct
#' @keywords DataFrame
#' @examples
#' # round-trip conversion from DataFrame with two columns
#' df = pl$DataFrame(a = 1:5, b = c("one", "two", "three", "four", "five"))
#' s = df$to_struct()
#' s
#'
#' # convert to an R list
#' s$to_r()
#'
#' # Convert back to a DataFrame
#' df_s = s$to_frame()
#' df_s
DataFrame_to_struct = function(name = "") {
  unwrap(.pr$DataFrame$to_struct(self, name), "in $to_struct():")
}


## TODO contribute polars add r-polars defaults for to_struct and unnest
#' Unnest the Struct columns of a DataFrame
#' @keywords DataFrame
#' @param names Names of the struct columns to unnest. If `NULL` (default), then
#' all "struct" columns are unnested.
#' @return A DataFrame where all "struct" columns are unnested. Non-struct
#' columns are not modified.
#' @examples
#' df = pl$DataFrame(
#'   a = 1:5,
#'   b = c("one", "two", "three", "four", "five"),
#'   c = 6:10
#' )$
#'   select(
#'   pl$col("b")$to_struct(),
#'   pl$col("a", "c")$to_struct()$alias("a_and_c")
#' )
#' df
#'
#' # by default, all struct columns are unnested
#' df$unnest()
#'
#' # we can specify specific columns to unnest
#' df$unnest("a_and_c")
DataFrame_unnest = function(names = NULL) {
  if (is.null(names)) {
    names = names(which(dtypes_are_struct(.pr$DataFrame$schema(self))))
  }
  unwrap(.pr$DataFrame$unnest(self, names), "in $unnest():")
}



#' @title Get the first row of the DataFrame.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$first()
DataFrame_first = function() {
  self$lazy()$first()$collect()
}


#' @title Number of chunks of the Series in a DataFrame
#' @description
#' Number of chunks (memory allocations) for all or first Series in a DataFrame.
#' @details
#' A DataFrame is a vector of Series. Each Series in rust-polars is a wrapper
#' around a ChunkedArray, which is like a virtual contiguous vector physically
#' backed by an ordered set of chunks. Each chunk of values has a contiguous
#' memory layout and is an arrow array. Arrow arrays are a fast, thread-safe and
#' cross-platform memory layout.
#'
#' In R, combining with `c()` or `rbind()` requires immediate vector re-allocation
#' to place vector values in contiguous memory. This is slow and memory consuming,
#' and it is why repeatedly appending to a vector in R is discouraged.
#'
#' In polars, when we concatenate or append to Series or DataFrame, the
#' re-allocation can be avoided or delayed by simply appending chunks to each
#' individual Series. However, if chunks become many and small or are misaligned
#' across Series, this can hurt the performance of subsequent operations.
#'
#' Most places in the polars api where chunking could occur, the user have to
#' typically actively opt-out by setting an argument `rechunk = FALSE`.
#'
#' @keywords DataFrame
#' @param strategy Either `"all"` or `"first"`. `"first"` only returns chunks
#' for the first Series.
#' @return A real vector of chunk counts per Series.
#' @seealso [`<DataFrame>$rechunk()`][DataFrame_rechunk]
#' @examples
#' # create DataFrame with misaligned chunks
#' df = pl$concat(
#'   1:10, # single chunk
#'   pl$concat(1:5, 1:5, rechunk = FALSE, how = "vertical")$rename("b"), # two chunks
#'   how = "horizontal"
#' )
#' df
#' df$n_chunks()
#'
#' # rechunk a chunked DataFrame
#' df$rechunk()$n_chunks()
#'
#' # rechunk is not an in-place operation
#' df$n_chunks()
#'
#' # The following toy example emulates the Series "chunkyness" in R. Here it a
#' # S3-classed list with same type of vectors and where have all relevant S3
#' # generics implemented to make behave as if it was a regular vector.
#' "+.chunked_vector" = \(x, y) structure(list(unlist(x) + unlist(y)), class = "chunked_vector")
#' print.chunked_vector = \(x, ...) print(unlist(x), ...)
#' c.chunked_vector = \(...) {
#'   structure(do.call(c, lapply(list(...), unclass)), class = "chunked_vector")
#' }
#' rechunk = \(x) structure(unlist(x), class = "chunked_vector")
#' x = structure(list(1:4, 5L), class = "chunked_vector")
#' x
#' x + 5:1
#' lapply(x, tracemem) # trace chunks to verify no re-allocation
#' z = c(x, x)
#' z # looks like a plain vector
#' lapply(z, tracemem) # mem allocation  in z are the same from x
#' str(z)
#' z = rechunk(z)
#' str(z)
DataFrame_n_chunks = function(strategy = "all") {
  .pr$DataFrame$n_chunks(self, strategy) |>
    unwrap("in n_chunks():")
}


#' @title Rechunk a DataFrame
#' @description Rechunking re-allocates any "chunked" memory allocations to
#' speed-up e.g. vectorized operations.
#' @inherit DataFrame_n_chunks details examples
#'
#' @keywords DataFrame
#' @return A DataFrame
#' @seealso [`<DataFrame>$n_chunks()`][DataFrame_n_chunks]
DataFrame_rechunk = function() {
  .pr$DataFrame$rechunk(self)
}


#' @title Get the last row of the DataFrame.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$last()
DataFrame_last = function() {
  self$lazy()$last()$collect()
}

#' @title Max
#' @description Aggregate the columns in the DataFrame to their maximum value.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$max()
DataFrame_max = function() {
  self$lazy()$max()$collect()
}

#' @title Mean
#' @description Aggregate the columns in the DataFrame to their mean value.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$mean()
DataFrame_mean = function() {
  self$lazy()$mean()$collect()
}

#' @title Median
#' @description Aggregate the columns in the DataFrame to their median value.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$median()
DataFrame_median = function() {
  self$lazy()$median()$collect()
}

#' @title Min
#' @description Aggregate the columns in the DataFrame to their minimum value.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$min()
DataFrame_min = function() {
  self$lazy()$min()$collect()
}

#' @title Sum
#' @description Aggregate the columns of this DataFrame to their sum values.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$sum()
DataFrame_sum = function() {
  self$lazy()$sum()$collect()
}

#' @title Var
#' @description Aggregate the columns of this DataFrame to their variance values.
#' @keywords DataFrame
#' @param ddof Delta Degrees of Freedom: the divisor used in the calculation is
#' N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$var()
DataFrame_var = function(ddof = 1) {
  self$lazy()$var(ddof)$collect()
}

#' @title Std
#' @description Aggregate the columns of this DataFrame to their standard
#' deviation values.
#' @keywords DataFrame
#' @param ddof Delta Degrees of Freedom: the divisor used in the calculation is
#' N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$std()
DataFrame_std = function(ddof = 1) {
  self$lazy()$std(ddof)$collect()
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to a unique quantile
#' value. Use `$describe()` to specify several quantiles.
#' @keywords DataFrame
#' @param quantile Numeric of length 1 between 0 and 1.
#' @param interpolation Interpolation method: "nearest", "higher", "lower",
#' "midpoint", or "linear".
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$quantile(.4)
DataFrame_quantile = function(quantile, interpolation = "nearest") {
  self$lazy()$quantile(quantile, interpolation)$collect()
}

#' @title Reverse
#' @description Reverse the DataFrame (the last row becomes the first one, etc.).
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$reverse()
DataFrame_reverse = function() {
  self$lazy()$reverse()$collect()
}

#' @title Fill `NaN`
#' @description Fill `NaN` values by an Expression evaluation.
#' @keywords DataFrame
#' @param fill_value Value to fill `NaN` with.
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(
#'   a = c(1.5, 2, NaN, 4),
#'   b = c(1.5, NaN, NaN, 4)
#' )
#' df$fill_nan(99)
DataFrame_fill_nan = function(fill_value) {
  self$lazy()$fill_nan(fill_value)$collect()
}

#' @title Fill nulls
#' @description Fill null values (which correspond to `NA` in R) using the
#' specified value or strategy.
#' @keywords DataFrame
#' @param fill_value Value to fill nulls with.
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(
#'   a = c(1.5, 2, NA, 4),
#'   b = c(1.5, NA, NA, 4)
#' )
#'
#' df$fill_null(99)
#'
#' df$fill_null(pl$col("a")$mean())
DataFrame_fill_null = function(fill_value) {
  self$lazy()$fill_null(fill_value)$collect()
}

#' @title Slice
#' @description Get a slice of the DataFrame.
#' @return DataFrame
#' @param offset Start index, can be a negative value. This is 0-indexed, so
#' `offset = 1` doesn't include the first row.
#' @param length Length of the slice. If `NULL` (default), all rows starting at
#' the offset will be selected.
#' @examples
#' # skip the first 2 rows and take the 4 following rows
#' pl$DataFrame(mtcars)$slice(2, 4)
#'
#' # this is equivalent to:
#' mtcars[3:6, ]
DataFrame_slice = function(offset, length = NULL) {
  self$lazy()$slice(offset, length)$collect()
}


#' @title Count null values
#' @description Create a new DataFrame that shows the null (which correspond
#' to `NA` in R) counts per column.
#' @keywords DataFrame
#' @return DataFrame
#' @docType NULL
#' @format NULL
#' @format function
#' @examples
#' x = mtcars
#' x[1, 2:3] = NA
#' pl$DataFrame(x)$null_count()
DataFrame_null_count = use_extendr_wrapper


#' @title Estimated size
#' @description Return an estimation of the total (heap) allocated size of the
#' DataFrame.
#' @keywords DataFrame
#' @return Estimated size in bytes
#' @docType NULL
#' @format NULL
#' @format function
#' @examples
#' pl$DataFrame(mtcars)$estimated_size()
DataFrame_estimated_size = use_extendr_wrapper



#' Perform joins on nearest keys
#' @inherit LazyFrame_join_asof
#' @param other DataFrame or LazyFrame
#' @keywords DataFrame
#' @return New joined DataFrame
#' @examples
#' # create two DataFrames to join asof
#' gdp = pl$DataFrame(
#'   date = as.Date(c("2015-1-1", "2016-1-1", "2017-5-1", "2018-1-1", "2019-1-1")),
#'   gdp = c(4321, 4164, 4411, 4566, 4696),
#'   group = c("b", "a", "a", "b", "b")
#' )
#'
#' pop = pl$DataFrame(
#'   date = as.Date(c("2016-5-12", "2017-5-12", "2018-5-12", "2019-5-12")),
#'   population = c(82.19, 82.66, 83.12, 83.52),
#'   group = c("b", "b", "a", "a")
#' )
#'
#' # optional make sure tables are already sorted with "on" join-key
#' gdp = gdp$sort("date")
#' pop = pop$sort("date")
#'
#' # Left-join_asof DataFrame pop with gdp on "date"
#' # Look backward in gdp to find closest matching date
#' pop$join_asof(gdp, on = "date", strategy = "backward")
#'
#' # .... and forward
#' pop$join_asof(gdp, on = "date", strategy = "forward")
#'
#' # join by a group: "only look within within group"
#' pop$join_asof(gdp, on = "date", by = "group", strategy = "backward")
#'
#' # only look 2 weeks and 2 days back
#' pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = "2w2d")
#'
#' # only look 11 days back (numeric tolerance depends on polars type, <date> is in days)
#' pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = 11)
DataFrame_join_asof = function(
    other,
    ...,
    left_on = NULL,
    right_on = NULL,
    on = NULL,
    by_left = NULL,
    by_right = NULL,
    by = NULL,
    strategy = "backward",
    suffix = "_right",
    tolerance = NULL,
    allow_parallel = TRUE,
    force_parallel = FALSE) {
  # convert other to LazyFrame, capture any Error as a result, and pass it on

  other_df_result = pcase(
    inherits(other, "RPolarsDataFrame"), Ok(other$lazy()),
    inherits(other, "RPolarsLazyFrame"), Ok(other),
    or_else = Err(" not a LazyFrame or DataFrame")
  )

  self$lazy()$join_asof(
    other = other_df_result,
    on = on,
    left_on = left_on,
    right_on = right_on,
    by = by,
    by_left = by_left,
    by_right = by_right,
    allow_parallel = allow_parallel,
    force_parallel = force_parallel,
    suffix = suffix,
    strategy = strategy,
    tolerance = tolerance
  )$collect()
}




#' @inherit LazyFrame_melt
#' @keywords DataFrame
#'
#' @return A new `DataFrame`
#'
#' @examples
#' df = pl$DataFrame(
#'   a = c("x", "y", "z"),
#'   b = c(1, 3, 5),
#'   c = c(2, 4, 6),
#'   d = c(7, 8, 9)
#' )
#' df$melt(id_vars = "a", value_vars = c("b", "c", "d"))
DataFrame_melt = function(
    id_vars = NULL,
    value_vars = NULL,
    variable_name = NULL,
    value_name = NULL) {
  .pr$DataFrame$melt(
    self, id_vars %||% character(), value_vars %||% character(),
    value_name, variable_name
  ) |> unwrap("in $melt( ): ")
}



#' Pivot data from long to wide
#' @param values Column values to aggregate. Can be multiple columns if the
#' `columns` arguments contains multiple columns as well.
#' @param index  One or multiple keys to group by.
#' @param columns  Name of the column(s) whose values will be used as the header
#' of the output DataFrame.
#' @param aggregate_function One of:
#'   - string indicating the expressions to aggregate with, such as 'first',
#'     'sum', 'max', 'min', 'mean', 'median', 'last', 'count'),
#'   - an Expr e.g. `pl$element()$sum()`
#' @inheritParams DataFrame_unique
#' @param sort_columns Sort the transposed columns by name. Default is by order
#' of discovery.
#' @param separator Used as separator/delimiter in generated column names.
#'
#' @return DataFrame
#' @keywords DataFrame
#' @examples
#' df = pl$DataFrame(
#'   foo = c("one", "one", "one", "two", "two", "two"),
#'   bar = c("A", "B", "C", "A", "B", "C"),
#'   baz = c(1, 2, 3, 4, 5, 6)
#' )
#' df
#'
#' df$pivot(
#'   values = "baz", index = "foo", columns = "bar"
#' )
#'
#' # Run an expression as aggregation function
#' df = pl$DataFrame(
#'   col1 = c("a", "a", "a", "b", "b", "b"),
#'   col2 = c("x", "x", "x", "x", "y", "y"),
#'   col3 = c(6, 7, 3, 2, 5, 7)
#' )
#' df
#'
#' df$pivot(
#'   index = "col1",
#'   columns = "col2",
#'   values = "col3",
#'   aggregate_function = pl$element()$tanh()$mean()
#' )
DataFrame_pivot = function(
    values,
    index,
    columns,
    aggregate_function = NULL,
    maintain_order = TRUE,
    sort_columns = FALSE,
    separator = "_") {
  pcase(
    # if string, call it on Expr-method of pl$element() and capture any Error as Result
    is_string(aggregate_function), result(`$.RPolarsExpr`(pl$element(), aggregate_function)()),

    # Expr or NULL pass as is
    is.null(aggregate_function) || inherits(aggregate_function, "RPolarsExpr"), Ok(aggregate_function),

    # anything else pass err
    or_else = Err(" is neither a string, NULL or an Expr")
  ) |>
    # add param context
    map_err(\(err_msg) paste(
      "param [aggregate_function] being ", str_string(aggregate_function), err_msg
    )) |>
    # run pivot when valid aggregate_expr
    and_then(\(aggregate_expr) .pr$DataFrame$pivot_expr(
      self, values, index, columns, maintain_order, sort_columns, aggregate_expr, separator
    )) |>
    # unwrap and add method context name
    unwrap("in $pivot():")
}

#' @title Rename columns of a DataFrame
#' @keywords DataFrame
#' @param ... One of the following:
#'  - params like `new_name = "old_name"` to rename selected variables.
#'  - as above but with params wrapped in a list
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(mtcars)
#'
#' df$rename(miles_per_gallon = "mpg", horsepower = "hp")
#'
#' replacements = list(miles_per_gallon = "mpg", horsepower = "hp")
#' df$rename(replacements)
DataFrame_rename = function(...) {
  self$lazy()$rename(...)$collect()
}

#' @title Summary statistics for a DataFrame
#'
#' @description This returns the total number of rows, the number of missing
#' values, the mean, standard deviation, min, max, median and the percentiles
#' specified in the argument `percentiles`.
#'
#' @param percentiles One or more percentiles to include in the summary statistics.
#' All values must be in the range `[0; 1]`.
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#' pl$DataFrame(mtcars)$describe()
DataFrame_describe = function(percentiles = c(.25, .75)) {

  uw = \(res) unwrap(res, "in $describe():")

  if (length(self$columns) == 0) {
    Err_plain("cannot describe a DataFrame without any columns") |>
      uw()
  }

  result(msg = "internal error", {
    # Determine which columns should get std/mean/percentile statistics
    stat_cols = lapply(self$schema, \(x) {
      is_num = lapply(pl$numeric_dtypes, \(w) w == x) |>
        unlist() |>
        any()
      if (!is_num) {
        return()
      } else {
        is_num
      }
    }) |>
      unlist() |>
      names()


    # separator used temporarily and used to split the column names later on
    # It's voluntarily weird so that it doesn't match actual column names
    custom_sep = "??-??"

    # Determine metrics and optional/additional percentiles
    metrics = c("count", "null_count", "mean", "std", "min")
    percentile_exprs = list()
    for (p in sort(percentiles)) {
      for (c in self$columns) {
        expr = if (c %in% stat_cols) {
          pl$col(c)$quantile(p)
        } else {
          pl$lit(NA)
        }
        expr = expr$alias(paste0(p, custom_sep, c))
        percentile_exprs = append(percentile_exprs, expr)
      }
      metrics = append(metrics, paste0(p * 100, "%"))
    }
    metrics = append(metrics, "max")

    mean_exprs = lapply(self$columns, function(x) {
      expr = if (x %in% stat_cols) {
        pl$col(x)$mean()
      } else {
        pl$lit(NA)
      }
      expr$alias(paste0("mean", custom_sep, x))
    })

    std_exprs = lapply(self$columns, function(x) {
      expr = if (x %in% stat_cols) {
        pl$col(x)$std()
      } else {
        pl$lit(NA)
      }
      expr$alias(paste0("std", custom_sep, x))
    })

    min_exprs = lapply(self$columns, function(x) {
      expr = if (x %in% stat_cols) {
        pl$col(x)$min()
      } else {
        pl$lit(NA)
      }
      expr$alias(paste0("min", custom_sep, x))
    })

    max_exprs = lapply(self$columns, function(x) {
      expr = if (x %in% stat_cols) {
        pl$col(x)$max()
      } else {
        pl$lit(NA)
      }
      expr$alias(paste0("max", custom_sep, x))
    })

    # Calculate metrics in parallel
    df_metrics = self$
      select(
        unlist(
          list(
            pl$all()$count()$name$prefix(paste0("count", custom_sep)),
            pl$all()$null_count()$name$prefix(paste0("null_count", custom_sep)),
            mean_exprs,
            std_exprs,
            min_exprs,
            percentile_exprs,
            max_exprs
          ),
          recursive = FALSE
        )
      )

    df_metrics$
      transpose(include_header = TRUE)$
      with_columns(
        pl$col("column")$str$split_exact(custom_sep, 1)$
          struct$rename_fields(c("describe", "variable"))$
          alias("fields")
      )$
      unnest("fields")$
      drop("column")$
      pivot(index = "describe", columns = "variable", values = "column_0")
  }) |>
    uw()
}

#' @title Glimpse values in a DataFrame
#' @keywords DataFrame
#' @param ... not used
#' @param return_as_string Boolean (default `FALSE`). If `TRUE`, return the
#' output as a string.
#' @return DataFrame
#' @examples
#' pl$DataFrame(iris)$glimpse()
DataFrame_glimpse = function(..., return_as_string = FALSE) {
  # guard input
  if (!is_bool(return_as_string)) {
    RPolarsErr$new()$
      bad_robj(return_as_string)$
      mistyped("bool")$
      bad_arg("return_as_string") |>
      Err() |>
      unwrap("in $glimpse() :")
  }

  # closure to extract col info from a column in <self>
  max_num_value = min(10, self$height)
  max_col_name_trunc = 50
  parse_column_ = \(col_name, dtype) {
    dtype_str = dtype_str_repr(dtype) |> unwrap_or(paste0("??", str_string(dtype)))
    if (inherits(dtype, "RPolarsDataType")) dtype_str = paste0(" <", dtype_str, ">")
    val = self$select(pl$col(col_name)$slice(0, max_num_value))$to_list()[[1]]
    val_str = paste(val, collapse = ", ")
    if (nchar(col_name) > max_col_name_trunc) {
      col_name = paste0(substr(col_name, 1, max_col_name_trunc - 3), "...")
    }
    list(
      col_name = col_name,
      dtype_str = dtype_str,
      val_str = val_str
    )
  }

  # construct print, flag any error as internal
  output = result(
    {
      schema = self$schema
      data = lapply(seq_along(schema), \(i) parse_column_(names(schema)[i], schema[[i]]))
      max_col_name = max(sapply(data, \(x) nchar(x$col_name)))
      max_col_dtyp = max(sapply(data, \(x) nchar(x$dtype)))
      max_col_vals = 100 - max_col_name - max_col_dtyp - 3

      sapply(data, \(x) {
        name_filler = paste(rep(" ", max_col_name - nchar(x$col_name)), collapse = "")
        dtyp_filler = paste(rep(" ", max_col_dtyp - nchar(x$dtype_str)), collapse = "")
        vals_filler = paste(rep(" ", max_col_dtyp - nchar(x$dtype_str)), collapse = "")
        paste0(
          "& ", x$col_name, name_filler, x$dtype_str, dtyp_filler, " ",
          substr(x$val_str, 1, max_col_vals), "\n"
        )
      }) |>
        paste0(collapse = "")
    },
    msg = "internal error"
  ) |>
    unwrap("in $glimpse() :")

  # chose return type
  if (return_as_string) output else invisible(cat(output))
}


#' @inherit LazyFrame_explode title params
#'
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(
#'   letters = c("aa", "aa", "bb", "cc"),
#'   numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8)),
#'   numbers_2 = list(0, c(1, 2), c(3, 4), c(5, 6, 7)) # same structure as numbers
#' )
#' df
#'
#' # explode a single column, append others
#' df$explode("numbers")
#'
#' # it is also possible to explode a character column to have one letter per row
#' df$explode("letters")
#'
#' # explode two columns of same nesting structure, by names or the common dtype
#' # "List(Float64)"
#' df$explode("numbers", "numbers_2")
#' df$explode(pl$col(pl$List(pl$Float64)))
DataFrame_explode = function(...) {
  self$lazy()$explode(...)$collect()
}

#' Take a sample of rows from a DataFrame
#'
#' @param n Number of rows to return. Cannot be used with `fraction`.
#' @param fraction Fraction of rows to return (between 0 and 1). Cannot be used
#' with `n`.
#' @param with_replacement Allow values to be sampled more than once.
#' @param shuffle If `TRUE`, the order of the sampled rows will be shuffled. If
#' `FALSE` (default), the order of the returned rows will be neither stable nor
#' fully random.
#' @param seed Seed for the random number generator. If set to `NULL` (default),
#' a random seed is generated for each sample operation.
#'
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(iris)
#' df$sample(n = 20)
#' df$sample(frac = 0.1)
DataFrame_sample = function(
    n = NULL, fraction = NULL, with_replacement = FALSE, shuffle = FALSE, seed = NULL) {
  seed = seed %||% sample(0:10000, 1)
  pcase(
    !xor(is.null(n), is.null(fraction)), Err_plain("Pass either arg `n` or `fraction`, not both."),
    is.null(fraction), .pr$DataFrame$sample_n(self, n, with_replacement, shuffle, seed),
    is.null(n), .pr$DataFrame$sample_frac(self, fraction, with_replacement, shuffle, seed),
    or_else = Err_plain("internal error")
  ) |>
    unwrap("in $sample():")
}


#' Transpose a DataFrame over the diagonal.
#'
#' @param include_header If `TRUE`, the column names will be added as first column.
#' @param header_name If `include_header` is `TRUE`, this determines the name of the column
#' that will be inserted.
#' @param column_names Character vector indicating the new column names. If `NULL` (default),
#' the columns will be named as "column_1", "column_2", etc. The length of this vector must match
#' the number of rows of the original input.
#'
#' @details
#' This is a very expensive operation.
#'
#' Transpose may be the fastest option to perform non foldable (see `fold()` or `reduce()`)
#' row operations like median.
#'
#' Polars transpose is currently eager only, likely because it is not trivial to deduce the schema.
#'
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#'
#' # simple use-case
#' pl$DataFrame(mtcars)$transpose(include_header = TRUE, column_names = rownames(mtcars))
#'
#' # All rows must have one shared supertype, recast Categorical to String which is a supertype
#' # of f64, and then dataset "Iris" can be transposed
#' pl$DataFrame(iris)$with_columns(pl$col("Species")$cast(pl$String))$transpose()
#'
DataFrame_transpose = function(
    include_header = FALSE,
    header_name = "column",
    column_names = NULL) {
  keep_names_as = if (isTRUE(include_header)) header_name else NULL
  .pr$DataFrame$transpose(self, keep_names_as, column_names) |>
    unwrap("in $transpose():")
}

#' Write to comma-separated values (CSV) file
#'
#' @param path File path to which the result should be written.
#' @param include_bom Whether to include UTF-8 BOM (byte order mark) in the CSV
#' output.
#' @param include_header Whether to include header in the CSV output.
#' @param separator Separate CSV fields with this symbol.
#' @param line_terminator String used to end each row.
#' @param quote Byte to use as quoting character.
#' @param batch_size Number of rows that will be processed per thread.
#' @param datetime_format A format string, with the specifiers defined by the
#' chrono Rust crate. If no format specified, the default fractional-second
#' precision is inferred from the maximum timeunit found in the frame’s Datetime
#'  cols (if any).
#' @param date_format A format string, with the specifiers defined by the chrono
#' Rust crate.
#' @param time_format A format string, with the specifiers defined by the chrono
#' Rust crate.
#' @param float_precision Number of decimal places to write, applied to both
#' Float32 and Float64 datatypes.
#' @param null_values A string representing null values (defaulting to the empty
#' string).
#' @param quote_style Determines the quoting strategy used.
#' * `"necessary"` (default): This puts quotes around fields only when necessary.
#'   They are necessary when fields contain a quote, delimiter or record
#'   terminator. Quotes are also necessary when writing an empty record (which
#'   is indistinguishable from a record with one empty field). This is the
#'   default.
#' * `"always"`: This puts quotes around every field.
#' * `"non_numeric"`: This puts quotes around all fields that are non-numeric.
#'   Namely, when writing a field that does not parse as a valid float or integer,
#'   then quotes will be used even if they aren`t strictly necessary.
#' * `"never"`: This never puts quotes around fields, even if that results in
#'   invalid CSV data (e.g. by not quoting strings containing the separator).
#'
#' @return
#' This doesn't return anything but creates a CSV file.
#'
#' @rdname IO_write_csv
#'
#' @examples
#' dat = pl$DataFrame(mtcars)
#'
#' destination = tempfile(fileext = ".csv")
#' dat$select(pl$col("drat", "mpg"))$write_csv(destination)
#'
#' pl$read_csv(destination)
DataFrame_write_csv = function(
    path,
    include_bom = FALSE,
    include_header = TRUE,
    separator = ",",
    line_terminator = "\n",
    quote = '"',
    batch_size = 1024,
    datetime_format = NULL,
    date_format = NULL,
    time_format = NULL,
    float_precision = NULL,
    null_values = "",
    quote_style = "necessary") {
  .pr$DataFrame$write_csv(
    self,
    path, include_bom, include_header, separator, line_terminator, quote,
    batch_size, datetime_format, date_format, time_format, float_precision,
    null_values, quote_style
  ) |>
    unwrap("in $write_csv():") |>
    invisible()
}


#' Write to JSON file
#'
#' @param file File path to which the result should be written.
#' @param pretty Pretty serialize JSON.
#' @param row_oriented Write to row-oriented JSON. This is slower, but more
#' common.
#'
#' @return
#' This doesn't return anything.
#'
#' @rdname IO_write_json
#'
#' @examples
#' if (require("jsonlite", quiet = TRUE)) {
#'   dat = pl$DataFrame(head(mtcars))
#'   destination = tempfile()
#'
#'   dat$select(pl$col("drat", "mpg"))$write_json(destination)
#'   jsonlite::fromJSON(destination)
#'
#'   dat$select(pl$col("drat", "mpg"))$write_json(destination, row_oriented = TRUE)
#'   jsonlite::fromJSON(destination)
#' }
DataFrame_write_json = function(
    file,
    pretty = FALSE,
    row_oriented = FALSE) {
  .pr$DataFrame$write_json(self, file, pretty, row_oriented) |>
    unwrap("in $write_json():") |>
    invisible()
}

#' Write to NDJSON file
#'
#' @inheritParams DataFrame_write_json
#'
#' @return
#' This doesn't return anything.
#'
#' @rdname IO_write_ndjson
#'
#' @examples
#' dat = pl$DataFrame(head(mtcars))
#'
#' destination = tempfile()
#' dat$select(pl$col("drat", "mpg"))$write_ndjson(destination)
#'
#' pl$read_ndjson(destination)
DataFrame_write_ndjson = function(file) {
  .pr$DataFrame$write_ndjson(self, file) |>
    unwrap("in $write_ndjson():") |>
    invisible()
}

#' @inherit LazyFrame_rolling title description params details
#' @return A [GroupBy][GroupBy_class] object
#'
#' @examples
#' df = pl$DataFrame(
#'   dt = c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-08"),
#'   a = c(3, 7, 5, 9, 2, 1)
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   pl$col("a"),
#'   pl$sum("a")$alias("sum_a"),
#'   pl$min("a")$alias("min_a"),
#'   pl$max("a")$alias("max_a")
#' )
DataFrame_rolling = function(index_column, period, offset = NULL, closed = "right", by = NULL, check_sorted = TRUE) {
  if (is.null(offset)) {
    offset = paste0("-", period)
  }
  construct_rolling_group_by(self, index_column, period, offset, closed, by, check_sorted)
}

#' @inherit LazyFrame_group_by_dynamic title description details params
#' @return A [GroupBy][GroupBy_class] object
#'
#' @examples
#' df = pl$DataFrame(
#'   time = pl$date_range(
#'     start = strptime("2021-12-16 00:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     end = strptime("2021-12-16 03:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     interval = "30m",
#'     eager = TRUE,
#'   ),
#'   n = 0:6
#' )
#'
#' # get the sum in the following hour relative to the "time" column
#' df$group_by_dynamic("time", every = "1h")$agg(
#'   vals = pl$col("n"),
#'   sum = pl$col("n")$sum()
#' )
#'
#' # using "include_boundaries = TRUE" is helpful to see the period considered
#' df$group_by_dynamic("time", every = "1h", include_boundaries = TRUE)$agg(
#'   vals = pl$col("n")
#' )
#'
#' # in the example above, the values didn't include the one *exactly* 1h after
#' # the start because "closed = 'left'" by default.
#' # Changing it to "right" includes values that are exactly 1h after. Note that
#' # the value at 00:00:00 now becomes included in the interval [23:00:00 - 00:00:00],
#' # even if this interval wasn't there originally
#' df$group_by_dynamic("time", every = "1h", closed = "right")$agg(
#'   vals = pl$col("n")
#' )
#' # To keep both boundaries, we use "closed = 'both'". Some values now belong to
#' # several groups:
#' df$group_by_dynamic("time", every = "1h", closed = "both")$agg(
#'   vals = pl$col("n")
#' )
#'
#' # Dynamic group bys can also be combined with grouping on normal keys
#' df = df$with_columns(groups = pl$Series(c("a", "a", "a", "b", "b", "a", "a")))
#' df
#'
#' df$group_by_dynamic(
#'   "time",
#'   every = "1h",
#'   closed = "both",
#'   by = "groups",
#'   include_boundaries = TRUE
#' )$agg(pl$col("n"))
#'
#' # We can also create a dynamic group by based on an index column
#' df = pl$LazyFrame(
#'   idx = 0:5,
#'   A = c("A", "A", "B", "B", "B", "C")
#' )$with_columns(pl$col("idx")$set_sorted())
#' df
#'
#' df$group_by_dynamic(
#'   "idx",
#'   every = "2i",
#'   period = "3i",
#'   include_boundaries = TRUE,
#'   closed = "right"
#' )$agg(A_agg_list = pl$col("A"))
DataFrame_group_by_dynamic = function(
    index_column,
    every,
    period = NULL,
    offset = NULL,
    include_boundaries = FALSE,
    closed = "left",
    label = "left",
    by = NULL,
    start_by = "window",
    check_sorted = TRUE) {
  if (is.null(offset)) {
    offset = paste0("-", every)
  }
  if (is.null(period)) {
    period = every
  }
  construct_group_by_dynamic(
    self, index_column, every, period, offset, include_boundaries, closed, label,
    by, start_by, check_sorted
  )
}
