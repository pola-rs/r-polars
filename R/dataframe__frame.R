#' @title Inner workings of the DataFrame-class
#'
#' @name DataFrame_class
#' @description The `DataFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the polars rust side. The instantiated
#' `DataFrame`-object is an `externalptr` to a lowlevel rust polars DataFrame  object.
#' The pointer address is the only statefullness of the DataFrame object on the R side.
#' Any other state resides on the rust side. The S3 method `.DollarNames.DataFrame`
#' exposes all public `$foobar()`-methods which are callable onto the object. Most methods return
#' another `DataFrame`-class instance or similar which allows for method chaining.
#' This class system in lack of a better name could be called "environment classes"
#' and is the same class system extendr provides, except here there is
#' both a public and private set of methods. For implementation reasons, the private methods are
#' external and must be called from `.pr$DataFrame$methodname()`, also all private methods
#' must take any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' @details Check out the source code in R/dataframe_frame.R how public methods are derived from
#' private methods. Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These
#' are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named
#' zzz to be last file sourced) the extendr-methods are removed and replaced by any function
#' prefixed `DataFrame_`.
#'
#' @keywords DataFrame
#' @return not applicable
#' @examples
#' # see all public exported method names (normally accessed via a class instance with $)
#' ls(.pr$env$DataFrame)
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
#' # use a private method, which has mutability
#' result = .pr$DataFrame$set_column_from_robj(df, 150:1, "some_ints")
#'
#' # column exists in both dataframes-objects now, as they are just pointers to the same object
#' # there are no public methods with mutability
#' df$columns
#' df2$columns
#'
#' # set_column_from_robj-method is fallible and returned a result which could be ok or an err.
#' # No public method or function will ever return a result.
#' # The `result` is very close to the same as output from functions decorated with purrr::safely.
#' # To use results on R side, these must be unwrapped first such that
#' # potentially errors can be thrown. unwrap(result) is a way to
#' # bridge rust not throwing errors with R. Extendr default behavior is to use panic!(s) which
#' # would case some unneccesary confusing and  some very verbose error messages on the inner
#' # workings of rust. unwrap(result) #in this case no error, just a NULL because this mutable
#' # method does not return any ok-value.
#'
#' # try unwrapping an error from polars due to unmatching column lengths
#' err_result = .pr$DataFrame$set_column_from_robj(df, 1:10000, "wrong_length")
#' tryCatch(unwrap(err_result, call = NULL), error = \(e) cat(as.character(e)))
DataFrame





#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x DataFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @return Doesn't return a value. This is used for autocompletion in RStudio.
#' @keywords internal
.DollarNames.DataFrame = function(x, pattern = "") {
  get_method_usages(DataFrame, pattern = pattern)
}


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x VecDataFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.DataFrame return
#' @keywords internal
.DollarNames.VecDataFrame = function(x, pattern = "") {
  get_method_usages(VecDataFrame, pattern = pattern)
}




#' Create new DataFrame
#' @name pl_DataFrame
#'
#' @param ... One of the following:
#'  - a data.frame or something that inherits data.frame or DataFrame
#'  - a list of mixed vectors and Series of equal length
#'  - mixed vectors and/or Series of equal length
#'
#' Columns will be named as of named arguments or alternatively by names of Series or given a
#' placeholder name.
#'
#' @param make_names_unique default TRUE, any duplicated names will be prefixed a running number
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
pl$DataFrame = function(..., make_names_unique = TRUE, parallel = FALSE, via_select = TRUE) {
  largs = unpack_list(...)

  # no args crete empty DataFrame
  if (length(largs) == 0L) {
    return(.pr$DataFrame$default())
  }

  # pass through if already a DataFrame
  if (inherits(largs[[1L]], "DataFrame")) {
    return(largs[[1L]])
  }


  # input guard
  if (!is_DataFrame_data_input(largs)) {
    stopf("input must inherit data.frame or be a list of vectors and/or  Series")
  }

  if (inherits(largs, "data.frame")) {
    largs = as.data.frame(largs)
  }


  ## step 00 get max length to allow cycle 1-length inputs
  # largs_lengths = sapply(largs, length)
  # largs_lengths_max = if (is.integer(largs_lengths)) max(largs_lengths) else NULL

  ## step1 handle column names
  # keys are tentative new column names
  # fetch keys from names, if missing set as NA
  keys = names(largs)
  if (length(keys) == 0) keys <- rep(NA_character_, length(largs))

  ## step2
  # if missing key use pl$Series name or generate new
  keys = mapply(largs, keys, FUN = function(column, key) {
    if (is.na(key) || nchar(key) == 0) {
      if (inherits(column, "Series")) {
        key = column$name
      } else {
        key = "new_column"
      }
    }
    return(key)
  })

  ## step 3
  # check for conflicting names, to avoid silent overwrite
  if (any(duplicated(keys))) {
    if (make_names_unique) {
      keys = make.unique(keys, sep = "_")
    } else {
      stopf(
        paste(
          "conflicting column names not allowed:",
          paste(unique(keys[duplicated(keys)]), collapse = ", ")
        )
      )
    }
  }

  ## pass to pl$
  names(largs) = keys
  result(
    lapply(largs, pl$lit) |>
      do.call(what = pl$select)
  ) |>
    unwrap("in pl$DataFrame()")
}


#' s3 method print DataFrame
#'
#' @keywords internal
#' @param x DataFrame
#' @param ... not used
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
print.DataFrame = function(x, ...) {
  x$print()
  invisible(x)
}

#' internal method print DataFrame
#' @noRd
#' @keywords internal
#' @return self
#'
#' @examples pl$DataFrame(iris)
DataFrame_print = function() {
  .pr$DataFrame$print(self)
  invisible(self)
}

## "Class methods"

#' Validate data input for create Dataframe with pl$DataFrame
#' @noRd
#' @param x any R object to test if suitable as input to DataFrame
#' @keywords internal
#' @description The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.
#'
#' @return bool
#'
#' @examples
#' .pr$env$is_DataFrame_data_input(iris)
#' .pr$env$is_DataFrame_data_input(list(1:5, pl$Series(1:5), letters[1:5]))
is_DataFrame_data_input = function(x) {
  inherits(x, "data.frame") ||
    is.list(x) ||
    all(sapply(x, function(x) is.vector(x) || inherits(x, "Series")))
}


# "properties"

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
"$<-.DataFrame" = function(self, name, value) {
  name = sub("<-$", "", name)

  # stop if method is not a setter
  if (!inherits(self[[name]], "setter")) {
    pstop(err = paste("no setter method for", name))
  }

  # if(is.null(func)) pstop(err= paste("no setter method for",name)))
  if (polars_optenv$strictly_immutable) self <- self$clone()
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
#' `pl$options$maintain_order(TRUE/FALSE)`.
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
DataFrame_dtype_strings = "use_extendr_wrapper"

#' @rdname DataFrame_dtypes

DataFrame_schema = method_as_property(function() {
  .pr$DataFrame$schema(self)
})



#
DataFrameCompareToOtherDF = function(self, other, op) {
  stopf("not done yet")
  #    """Compare a DataFrame with another DataFrame."""
  if (!identical(self$columns, other$columns)) stopf("DataFrame columns do not match")
  if (!identical(self$shape, other$shape)) stopf("DataFrame dimensions do not match")

  suffix = "__POLARS_CMP_OTHER"
  other_renamed = other$select(pl$all()$suffix(suffix))
  # combined = concat([self, other_renamed], how="horizontal")

  # if op == "eq":
  #   expr = [pli.col(n) == pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "neq":
  #   expr = [pli.col(n) != pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "gt":
  #   expr = [pli.col(n) > pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "lt":
  #   expr = [pli.col(n) < pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "gt_eq":
  #   expr = [pli.col(n) >= pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "lt_eq":
  #   expr = [pli.col(n) <= pli.col(f"{n}{suffix}") for n in self.columns]
  # else:
  #   raise ValueError(f"got unexpected comparison operator: {op}")
  #
  # return combined.select(expr)
}



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
DataFrame_lazy = "use_extendr_wrapper"

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
  .pr$DataFrame$clone_see_me_macro(self)
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
DataFrame_get_columns = "use_extendr_wrapper"

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
  .pr$DataFrame$select(self, unpack_list(...)) |>
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
#' @name DataFrame_frame_equal
#' @description Check if two DataFrames are equal.
#'
#' @param other DataFrame to compare with.
#' @return A boolean.
#' @keywords DataFrame
#' @examples
#' dat1 = pl$DataFrame(iris)
#' dat2 = pl$DataFrame(iris)
#' dat3 = pl$DataFrame(mtcars)
#' dat1$frame_equal(dat2)
#' dat1$frame_equal(dat3)
DataFrame_frame_equal = function(other) {
  .pr$DataFrame$frame_equal(self, other)
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
#' **`$with_column()` function is deprecated, use `$with_columns()` instead.**
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
  .pr$DataFrame$with_columns(self, unpack_list(...)) |>
    unwrap("in $with_columns()")
}

#' @rdname DataFrame_with_columns
#' @aliases with_column
#' @param expr a single expression or string

DataFrame_with_column = function(expr) {
  warning("`with_column()` is deprecated and will be removed in polars 0.9.0. Please use `with_columns()` instead.")
  self$with_columns(expr)
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
#' @description This is equivalent to `dplyr::filter()`. Note that rows where
#' the condition returns `NA` are dropped, unlike base subsetting with `[`.
#'
#' @param bool_expr Polars expression which will evaluate to a boolean.
#' @keywords DataFrame
#' @return A DataFrame with only the rows where the conditions are `TRUE`.
#' @examples
#' df = pl$DataFrame(iris)
#'
#' df$filter(pl$col("Sepal.Length") > 5)
#'
#' # rows where condition is NA are dropped
#' iris2 = iris
#' iris2[c(1, 3, 5), "Species"] = NA
#' df = pl$DataFrame(iris2)
#'
#' df$filter(pl$col("Species") == "setosa")
DataFrame_filter = function(bool_expr) {
  .pr$DataFrame$lazy(self)$filter(bool_expr)$collect()
}

#' Group a DataFrame
#' @inherit LazyFrame_groupby description params
#' @keywords DataFrame
#' @return GroupBy (a DataFrame with special groupby methods like `$agg()`)
#' @examples
#' gb = pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$groupby("foo", maintain_order = TRUE)
#'
#' gb
#'
#' gb$agg(
#'   pl$col("bar")$sum()$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
DataFrame_groupby = function(..., maintain_order = pl$options$maintain_order()) {
  # clone the DataFrame, bundle args as attributes. Non fallible.
  construct_groupby(self, groupby_input = unpack_list(...), maintain_order = maintain_order)
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

#' Alias for to_data_frame (backward compatibility)
#' @return An R data.frame
#' @noRd
DataFrame_as_data_frame = DataFrame_to_data_frame

# #' @rdname DataFrame_to_data_frame
# #' @description to_data_frame is an alias
# #' @keywords DataFrame
# DataFrame_to_data_frame = DataFrame_to_data_frame

#' @rdname DataFrame_to_data_frame
#' @param x A DataFrame
#'
#' @return data.frame
#' @export
as.data.frame.DataFrame = function(x, ...) {
  x$to_data_frame(...)
}

#' Return Polars DataFrame as a list of vectors
#'
#' @param unnest_structs Boolean. If `TRUE` (default), then `$unnest()` is applied
#' on any struct column.
#'
#' @name to_list
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
    left_on = NULL, # : str | pli.Expr | Sequence[str | pli.Expr] | None = None,
    right_on = NULL, # : str | pli.Expr | Sequence[str | pli.Expr] | None = None,
    on = NULL, # : str | pli.Expr | Sequence[str | pli.Expr] | None = None,
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
  .pr$DataFrame$to_struct(self, name)
}


## TODO contribute polars add r-polars defaults for to_struct and unnest
#' Unnest a DataFrame struct columns.
#' @keywords DataFrame
#' @param names Names of the struct columns to unnest. If `NULL` (default), then
#' all "struct" columns are unnested.
#' @return A DataFrame where all "struct" columns are unnested. Non-struct
#' columns are not modified.
#' @examples
#' df = pl$DataFrame(a = 1:5, b = c("one", "two", "three", "four", "five"))
#' df = df$to_struct()$to_frame()
#' df
#'
#' df$unnest()
DataFrame_unnest = function(names = NULL) {
  unwrap(.pr$DataFrame$unnest(self, names), "in $unnest():")
}



#' @title Get the first row of the DataFrame.
#' @keywords DataFrame
#' @return A DataFrame with one row.
#' @examples pl$DataFrame(mtcars)$first()
DataFrame_first = function() {
  self$lazy()$first()$collect()
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
DataFrame_null_count = "use_extendr_wrapper"


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
DataFrame_estimated_size = "use_extendr_wrapper"



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
    inherits(other, "DataFrame"), Ok(other$lazy()),
    inherits(other, "LazyFrame"), Ok(other),
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
    is_string(aggregate_function), result(`$.Expr`(pl$element(), aggregate_function)()),

    # Expr or NULL pass as is
    is.null(aggregate_function) || inherits(aggregate_function, "Expr"), Ok(aggregate_function),

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
#' pl$DataFrame(iris)$describe()
DataFrame_describe = function(percentiles = c(.25, .75)) {
  perc = percentiles

  # guard input
  # styler: off
  pcase(
    is.null(perc), Ok(numeric()),
    !is.numeric(perc), Err(bad_robj(perc)$mistyped("numeric")),
    isFALSE(all(perc > 0) && all(perc < 1)), {
      Err(bad_robj(perc)$misvalued("has all vector elements within 0 and 1"))
    },
    or_else = Ok(perc)
    # styler: on
  ) |>
    map_err(
      \(err)  err$bad_arg("percentiles")
    ) |>
    and_then(
      \(perc) {
        # this polars query should always succeed else flag as ...
        result(msg = "internal error", {
          # make percentile expressions
          perc_exprs = lapply(
            perc, \(x) pl$all()$quantile(x)$prefix(paste0(as.character(x * 100), "pct:"))
          )

          # bundle all expressions
          largs = c(
            list(
              pl$all()$count()$prefix("count:"),
              pl$all()$null_count()$prefix("null_count:"),
              pl$all()$mean()$prefix("mean:"),
              pl$all()$std()$prefix("std:"),
              pl$all()$min()$prefix("min:"),
              pl$all()$max()$prefix("max:"),
              pl$all()$median()$prefix("median:")
            ),
            perc_exprs
          )

          # compute aggregates
          df_aggs = do.call(self$select, largs)
          e_col_row_names = pl$lit(df_aggs$columns)$str$splitn(":", 2)

          # pivotize
          df_pivot = pl$select(
            e_col_row_names$struct$field("field_0")$alias("rowname"),
            e_col_row_names$struct$field("field_1")$alias("colname"),
            pl$lit(unlist(as.data.frame(df_aggs)))$alias("value")
          )$pivot(
            values = "value", index = "rowname", columns = "colname"
          )
          df_pivot$columns[1] = "describe"
          df_pivot
        })
      }
    ) |>
    unwrap("in $describe():")
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
    if (inherits(dtype, "RPolarsDataType")) dtype_str <- paste0(" <", dtype_str, ">")
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
#' # it doesn't change anything if the input is not a list-column
#' df$explode("letters")
#'
#' # explode two columns of same nesting structure, by names or the common dtype
#' # "List(Float64)"
#' df$explode(c("numbers", "numbers_2"))
#' df$explode(pl$col(pl$List(pl$Float64)))
DataFrame_explode = function(...) {
  self$lazy()$explode(...)$collect()
}
