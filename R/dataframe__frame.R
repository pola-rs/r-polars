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
#' @param parallel bool default FALSE, experimental multithreaded interpretation of R vectors
#' into a polars DataFrame. This is experimental as multiple threads read from R mem simultaneously.
#' So far no issues parallel read from R has been found.
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
#' # from a list of vectors or data.frame
#' pl$DataFrame(list(
#'   a = c(1, 2, 3, 4, 5),
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1L, 1:2, 1:3, 1:4, 1:5)
#' ))
#'
pl$DataFrame = function(..., make_names_unique = TRUE, parallel = FALSE) {
  largs = list2(...)

  # no args crete empty DataFrame
  if (length(largs) == 0L) {
    return(.pr$DataFrame$default())
  }

  # pass through if already a DataFrame
  if (inherits(largs[[1L]], "DataFrame")) {
    return(largs[[1L]])
  }

  # if input is one list of expression unpack this one
  Data = if (length(largs) == 1L && is.list(largs[[1]])) {
    largs = largs[[1L]]
    if (length(largs) == 0) {
      return(.pr$DataFrame$default())
    }
    largs
  }



  # input guard
  if (!is_DataFrame_data_input(largs)) {
    stopf("input must inherit data.frame or be a list of vectors and/or  Series")
  }

  if (inherits(largs, "data.frame")) {
    largs = as.data.frame(largs)
  }


  ## step 00 get max length to allow cycle 1-length inputs
  largs_lengths = sapply(largs, length)
  largs_lengths_max = if (is.integer(largs_lengths)) max(largs_lengths) else NULL

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

  ## step 4

  if (parallel) {
    # interpret R vectors into series in DataFrame in parallel
    aux_df = NULL # save Series temp to here
    l = mapply(largs, keys, SIMPLIFY = FALSE, FUN = function(column, key) {
      if (inherits(column, "Series")) {
        if (is.null(aux_df)) {
          aux_df <<- .pr$DataFrame$new_with_capacity(length(largs))
        }
        .pr$Series$rename_mut(column, key)
        unwrap(.pr$DataFrame$set_column_from_series(aux_df, column))
        column = NULL
      } else {
        if (length(column) == 1L && isTRUE(largs_lengths_max > 1L)) {
          column = rep(column, largs_lengths_max)
        }
        column = convert_to_fewer_types(column) # type conversions on R side
      }
      column
    })
    names(l) = keys
    # drop series from converted columns
    l = l |> (\(x) if (length(x)) x[!sapply(x, is.null)] else x)()



    if (length(l)) {
      self = unwrap(.pr$DataFrame$new_par_from_list(l))
    } else {
      self = aux_df
    }

    # combine DataFrame if both defined and reorder columns
    if (!is.null(aux_df) && length(l)) {
      self = pl$concat(list(self, aux_df), rechunk = FALSE, how = "horizontal")
      self = do.call(self$select, unname(lapply(keys, pl$col))) # reorder columns by keys
    }
  } else {
    # buildDataFrame one column at the time
    self = .pr$DataFrame$new_with_capacity(length(largs))
    mapply(largs, keys, FUN = function(column, key) {
      if (inherits(column, "Series")) {
        .pr$Series$rename_mut(column, key)

        unwrap(.pr$DataFrame$set_column_from_series(self, column))
      } else {
        if (length(column) == 1L && isTRUE(largs_lengths_max > 1L)) {
          column = rep(column, largs_lengths_max)
        }
        column = convert_to_fewer_types(column) # type conversions on R side
        unwrap(.pr$DataFrame$set_column_from_robj(self, column, key))
      }
      return(NULL)
    })
  }

  return(self)
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

#' @title Eager with_row_count
#' @description Add a new column at index 0 that counts the rows
#' @keywords DataFrame
#' @param name string name of the created column
#' @param offset positive integer offset for the start of the counter
#' @return A new `DataFrame` object with a counter column in front
#' @docType NULL
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
DataFrame.property_setters$columns =
  function(self, names) unwrap(.pr$DataFrame$set_column_names_mut(self, names))


#' @title Drop columns of a DataFrame
#' @keywords DataFrame
#' @param columns A character vector containing the names of the column(s) to
#' remove from the DataFrame.
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$drop(c("mpg", "hp"))
DataFrame_drop = function(columns) {
  self$lazy()$drop(columns)$collect()
}


#' @title Drop nulls
#' @description Drop all rows that contain null values.
#' @keywords DataFrame
#' @param subset string or vector of strings. Column name(s) for which null values are considered. If set to NULL (default), use all columns.
#'
#' @return DataFrame
#' @examples
#' tmp = mtcars
#' tmp[1:3, "mpg"] = NA
#' tmp[4, "hp"] = NA
#' pl$DataFrame(tmp)$drop_nulls()$height
#' pl$DataFrame(tmp)$drop_nulls("mpg")$height
#' pl$DataFrame(tmp)$drop_nulls(c("mpg", "hp"))$height
DataFrame_drop_nulls = function(subset = NULL) {
  self$lazy()$drop_nulls(subset)$collect()
}


#' @title DataFrame_unique
#' @description Drop duplicate rows from this dataframe.
#' @keywords DataFrame
#'
#' @param subset string or vector of strings. Column name(s) to consider when
#'  identifying duplicates. If set to NULL (default), use all columns.
#' @param keep string. Which of the duplicate rows to keep:
#' * "first": Keep first unique row.
#' * "last": Keep last unique row.
#' * "none": Don’t keep duplicate rows.
#' @param maintain_order Keep the same order as the original `DataFrame`. Setting
#'  this to `TRUE` makes it more expensive to compute and blocks the possibility
#'  to run on the streaming engine.
#'
#' @return DataFrame
#' @examples
#' df = pl$DataFrame(
#'   x = as.numeric(c(1, 1:5)),
#'   y = as.numeric(c(1, 1:5)),
#'   z = as.numeric(c(1, 1, 1:4))
#' )
#' df$unique()$height
#' df$unique(subset = c("x", "z"), keep = "last")$height
DataFrame_unique = function(subset = NULL, keep = "first", maintain_order = FALSE) {
  self$lazy()$unique(subset, keep, maintain_order)$collect()
}


#' Shape of  DataFrame
#' @name DataFrame_shape
#' @description Get shape/dimensions of DataFrame
#'
#' @return two length numeric vector of c(nrows,ncols)
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris)$shape
#'
DataFrame_shape = method_as_property(function() {
  .pr$DataFrame$shape(self)
})



#' Height of DataFrame
#' @name DataFrame_height
#' @description Get height(nrow) of DataFrame
#'
#' @return height as numeric
#' @aliases height nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$height
#'
DataFrame_height = method_as_property(function() {
  .pr$DataFrame$shape(self)[1L]
})



#' Width of DataFrame
#' @name DataFrame_width
#' @description Get width(ncol) of DataFrame
#'
#' @return width as numeric scalar
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$width
#'
DataFrame_width = method_as_property(function() {
  .pr$DataFrame$shape(self)[2L]
})




#' DataFrame dtypes
#' @name DataFrame_dtypes
#' @description Get the data types of columns in DataFrame.
#' Data types can also be found in column headers when printing the DataFrame.
#'
#' @return width as numeric scalar
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$dtypes
#'
DataFrame_dtypes = method_as_property(function() {
  .pr$DataFrame$dtypes(self)
})

#' DataFrame dtype strings
#' @name DataFrame_dtype_strings
#' @description Get column types as strings.
#'
#' @docType NULL
#' @format NULL
#' @return string vector
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$dtype_strings()
DataFrame_dtype_strings = "use_extendr_wrapper"

#' DataFrame dtypes
#' @name DataFrame_dtypes
#' @description Get dtypes of columns in DataFrame.
#' Dtypes can also be found in column headers when printing the DataFrame.
#'
#' @return width as numeric scalar
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$schema
#'
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
#'
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
#' pl$mem_address(df1) != pl$mem_address(df2)
#' pl$mem_address(df1) == pl$mem_address(df3)
#'
DataFrame_clone = function() {
  .pr$DataFrame$clone_see_me_macro(self)
}

#' Get columns (as Series)
#' @name DataFrame_get_columns
#' @description get columns as list of series
#'
#' @return list of series
#' @keywords  DataFrame
#' @docType NULL
#' @format NULL
#' @examples
#' df = pl$DataFrame(iris[1, ])
#' df$get_columns()
DataFrame_get_columns = "use_extendr_wrapper"

#' Get Column (as one Series)
#' @name DataFrame_get_column
#' @description get one column by name as series
#'
#' @param name name of column to extract as Series
#'
#' @return Series
#' @aliases DataFrame_get_column
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1, ])
#' df$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self, name), "in $get_column():")
}

#' Get Series by idx, if there
#'
#' @param idx numeric default 0, zero-index of what column to return as Series
#'
#' @name DataFrame_to_series
#' @description get one column by idx as series from DataFrame.
#' Unlike get_column this method will not fail if no series found at idx but
#' return a NULL, idx is zero idx.
#'
#' @return Series or NULL
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(a = 1:4)$to_series()
DataFrame_to_series = function(idx = 0) {
  if (!is.numeric(idx) || isTRUE(idx < 0)) {
    pstop(err = "idx must be non-negative numeric")
  }
  .pr$DataFrame$select_at_idx(self, idx)$ok
}

#' DataFrame Sort
#' @inherit LazyFrame_sort details description
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
    maintain_order = FALSE
  ) {
  self$lazy()$sort(
    by, ..., descending = descending, nulls_last = nulls_last, maintain_order = maintain_order
  )$collect()
}


#' Select and modify columns of a DataFrame
#' @name DataFrame_select
#' @description Related to dplyr `mutate()`. However, it discards unmentioned
#' columns (like `.()` in `data.table`).
#'
#' @param ... Columns to keep. Those can be expressions (e.g `pl$col("a")`),
#' column names  (e.g `"a"`), or list containing expressions or column names
#' (e.g `list(pl$col("a"))`).
#'
#' @aliases select
#' @return DataFrame
#' @keywords  DataFrame
#' @return DataFrame
#' @examples
#' pl$DataFrame(iris)$select(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
DataFrame_select = function(...) {
  args = unpack_list(...)
  .pr$DataFrame$select(self, args) |>
    and_then(\(df) result(msg = "internal error while renaming columns", {
      expr_names = names(args)
      if (!is.null(expr_names)) {
        old_names = df$columns
        new_names = old_names
        has_expr_name = nchar(expr_names) >= 1L
        new_names[has_expr_name] = expr_names[has_expr_name]
        df$columns = new_names
      }
      df
    })) |>
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

#' Drop in place
#' @name DataFrame_frame_equal
#' @description Check if DataFrame is equal to other.
#'
#' @param other DataFrame to compare with.
#' @return bool
#' @keywords  DataFrame
#' @examples
#' dat1 = pl$DataFrame(iris)
#' dat2 = pl$DataFrame(iris)
#' dat3 = pl$DataFrame(mtcars)
#' dat1$frame_equal(dat2)
#' dat1$frame_equal(dat3)
DataFrame_frame_equal = function(other) {
  .pr$DataFrame$frame_equal(self, other)
}

#' @title Shift
#' @description Shift the values by a given period.
#' @keywords DataFrame
#' @param periods integer Number of periods to shift (may be negative).
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$shift(2)
DataFrame_shift = function(periods = 1) {
  self$lazy()$shift(periods)$collect()
}

#' @title Shift and fill
#' @description Shift the values by a given period and fill the resulting null values.
#' @keywords DataFrame
#' @param fill_value Fill values with the result of this expression.
#' @param periods Integer indicating the number of periods to shift (may be
#' negative).
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$shift_and_fill(0, 2)
DataFrame_shift_and_fill = function(fill_value, periods = 1) {
  self$lazy()$shift_and_fill(fill_value, periods)$collect()
}

#' @title Modify/append column(s)
#' @description Add or modify columns with expressions
#' @name DataFrame_with_columns
#' @aliases with_columns
#' @param ... any expressions or string column name, or same wrapped in a list
#' @keywords  DataFrame
#' @return DataFrame
#' @details   Like dplyr `mutate()` as it keeps unmentioned columns unlike $select().
#' @examples
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#'
#' # rename columns by naming expression is concidered experimental
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), # not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width") + 2)
#' )
DataFrame_with_columns = function(...) {
  largs = list2(...)

  # unpack a single list
  if (length(largs) == 1 && is.list(largs[[1]])) {
    largs = largs[[1]]
  }

  do.call(self$lazy()$with_columns, largs)$collect()
}

#' modify/append one column
#' @rdname DataFrame_with_columns
#' @aliases with_column
#' @param expr a single expression or string
#' @keywords  DataFrame
#' @return DataFrame
#' @details with_column is derived from with_columns but takes only one expression argument
DataFrame_with_column = function(expr) {
  warning("`with_column()` is deprecated and will be removed in polars 0.9.0. Please use `with_columns()` instead.")
  self$with_columns(expr)
}



#' Limit a DataFrame
#' @name DataFrame_limit
#' @description Take some maximum number of rows.
#' @param n Positive numeric or integer number not larger than 2^32
#'
#' @details Any number will converted to u32.
#' @keywords  DataFrame
#' @return DataFrame
#' @examples
#' pl$DataFrame(iris)$limit(6)
#'
DataFrame_limit = function(n) {
  self$lazy()$limit(n)$collect()
}

#' Head of a DataFrame
#' @name DataFrame_head
#' @description Get the first n rows of the query.
#' @param n positive numeric or integer number not larger than 2^32
#'
#' @details any number will converted to u32. Negative raises error
#' @keywords  DataFrame
#' @return DataFrame
DataFrame_head = function(n) {
  self$lazy()$head(n)$collect()
}

#' Tail a DataFrame
#' @name DataFrame_tail
#' @description Get the last n rows.
#' @param n positive numeric of integer number not larger than 2^32
#'
#' @details any number will converted to u32. Negative raises error
#' @keywords  DataFrame
#' @return DataFrame
DataFrame_tail = function(n) {
  self$lazy()$tail(n)$collect()
}


#' filter DataFrame
#' @aliases DataFrame_filter
#' @description DataFrame$filter(bool_expr)
#'
#' @param bool_expr Polars expression which will evaluate to a bool pl$Series
#' @keywords DataFrame
#' @return filtered DataFrame
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
#' @name DataFrame_filter
DataFrame_filter = function(bool_expr) {
  .pr$DataFrame$lazy(self)$filter(bool_expr)$collect()
}

#' groupby a DataFrame
#' @description create GroupBy from DataFrame
#' @inherit LazyFrame_groupby
#' @keywords DataFrame
#' @return GroupBy (a DataFrame with special groupby methods like `$agg()`)
#' @examples
#' gb = pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$groupby("foo", maintain_order = TRUE)
#' print(gb)
#'
#' gb$agg(
#'   pl$col("bar")$sum()$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
DataFrame_groupby = function(..., maintain_order = pl$options$default_maintain_order()) {
  # clone the DataFrame, bundle args as attributes. Non fallible.
  construct_groupby(self, groupby_input = unpack_list(...), maintain_order = maintain_order)
}





#' Return Polars DataFrame as R data.frame
#'
#' @param ... any args pased to as.data.frame()
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
#' @param x DataFrame
#' @param ... any params passed to as.data.frame
#'
#' @return data.frame
#' @export
as.data.frame.DataFrame = function(x, ...) {
  x$to_data_frame(...)
}

#' return polars DataFrame as R lit of vectors
#'
#' @param unnest_structs bool default true, as calling $unnest() on any struct column
#'
#' @name to_list
#'
#' @details
#' This implementation for simplicity reasons relies on unnesting all structs before
#' exporting to R. unnest_structs = FALSE, the previous struct columns will be re-
#' nested. A struct in a R is a lists of lists, where each row is a list of values.
#' Such a structure is not very typical or efficient in R.
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



#' join DataFrame with other DataFrame
#'
#'
#' @param other DataFrame
#' @param on named columns as char vector of named columns, or list of expressions and/or strings.
#' @param left_on names of columns in self LazyFrame, order should match. Type, see on param.
#' @param right_on names of columns in other LazyFrame, order should match. Type, see on param.
#' @param how a string selecting one of the following methods: inner, left, outer, semi, anti, cross
#' @param suffix name to added right table
#' @param allow_parallel bool
#' @param force_parallel bool
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
#'
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

#' to_struct
#' @param name name of new Series
#' @return to_struct() returns a Series
#' @aliases to_struct
#' @keywords DataFrame
#' @examples
#' # round-trip conversion from DataFrame with two columns
#' df = pl$DataFrame(a = 1:5, b = c("one", "two", "three", "four", "five"))
#' s = df$to_struct()
#' s
#' s$to_r() # to r list
#' df_s = s$to_frame() # place series in a new DataFrame
#' df_s$unnest() # back to starting df
DataFrame_to_struct = function(name = "") {
  .pr$DataFrame$to_struct(self, name)
}


## TODO contribute polars add r-polars defaults for to_struct and unnest
#' Unnest a DataFrame struct columns.
#' @keywords DataFrame
#' @param names names of struct columns to unnest, default NULL unnest any struct column
#' @return $unnest() returns a DataFrame with all column including any that has been unnested
DataFrame_unnest = function(names = NULL) {
  unwrap(.pr$DataFrame$unnest(self, names), "in $unnest():")
}




#' @title First
#' @description Get the first row of the DataFrame.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied filter.
#' @examples pl$DataFrame(mtcars)$first()
DataFrame_first = function() {
  self$lazy()$first()$collect()
}

#' @title Last
#' @description Get the last row of the DataFrame.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied filter.
#' @examples pl$DataFrame(mtcars)$last()
DataFrame_last = function() {
  self$lazy()$last()$collect()
}

#' @title Max
#' @description Aggregate the columns in the DataFrame to their maximum value.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$max()
DataFrame_max = function() {
  self$lazy()$max()$collect()
}

#' @title Mean
#' @description Aggregate the columns in the DataFrame to their mean value.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$mean()
DataFrame_mean = function() {
  self$lazy()$mean()$collect()
}

#' @title Median
#' @description Aggregate the columns in the DataFrame to their median value.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$median()
DataFrame_median = function() {
  self$lazy()$median()$collect()
}

#' @title Min
#' @description Aggregate the columns in the DataFrame to their minimum value.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$min()
DataFrame_min = function() {
  self$lazy()$min()$collect()
}

#' @title Sum
#' @description Aggregate the columns of this DataFrame to their sum values.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$sum()
DataFrame_sum = function() {
  self$lazy()$sum()$collect()
}

#' @title Var
#' @description Aggregate the columns of this DataFrame to their variance values.
#' @keywords DataFrame
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$var()
DataFrame_var = function(ddof = 1) {
  self$lazy()$var(ddof)$collect()
}

#' @title Std
#' @description Aggregate the columns of this DataFrame to their standard deviation values.
#' @keywords DataFrame
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `DataFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$std()
DataFrame_std = function(ddof = 1) {
  self$lazy()$std(ddof)$collect()
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to their quantile value.
#' @keywords DataFrame
#' @param quantile numeric Quantile between 0.0 and 1.0.
#' @param interpolation string Interpolation method: "nearest", "higher", "lower", "midpoint", or "linear".
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$quantile(.4)
DataFrame_quantile = function(quantile, interpolation = "nearest") {
  self$lazy()$quantile(quantile, interpolation)$collect()
}

#' @title Reverse
#' @description Reverse the DataFrame.
#' @keywords LazyFrame
#' @return DataFrame
#' @examples pl$DataFrame(mtcars)$reverse()
DataFrame_reverse = function() {
  self$lazy()$reverse()$collect()
}

#' @title Fill NaN
#' @description Fill floating point NaN values by an Expression evaluation.
#' @keywords DataFrame
#' @param fill_value Value to fill NaN with.
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

#' @title Fill null
#' @description Fill null values using the specified value or strategy.
#' @keywords DataFrame
#' @param fill_value Value to fill `NA` with.
#' @return DataFrame
#' @examples
#' pl$DataFrame(
#'   a = c(1.5, 2, NA, 4),
#'   b = c(1.5, NA, NA, 4)
#' )$fill_null(99)
DataFrame_fill_null = function(fill_value) {
  self$lazy()$fill_null(fill_value)$collect()
}

#' @title Slice
#' @description Get a slice of this DataFrame.
#' @keywords LazyFrame
#' @return DataFrame
#' @param offset integer
#' @param length integer or NULL
#' @examples
#' pl$DataFrame(mtcars)$slice(2, 4)
#' mtcars[2:6, ]
DataFrame_slice = function(offset, length = NULL) {
  self$lazy()$slice(offset, length)$collect()
}


#' @title Null count
#' @description Create a new DataFrame that shows the null counts per column.
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
#' @description Return an estimation of the total (heap) allocated size of the DataFrame.
#' @keywords DataFrame
#' @return Bytes
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
#' @return new joined DataFrame
#' @examples
#' # create two DataFrame to join asof
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
#'   c = c(2, 4, 6)
#' )
#' df$melt(id_vars = "a", value_vars = c("b", "c"))
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



#' Create a spreadsheet-style pivot table as a DataFrame.
#' @param values Column values to aggregate. Can be multiple columns if the `columns`
#'             arguments contains multiple columns as well.
#' @param index  One or multiple keys to group by.
#' @param columns  Name of the column(s) whose values will be used as the header of the output
#'            DataFrame.
#' @param aggregate_function
#'             String naming Expr to aggregate with, or an Expr e.g. `pl$element()$sum()`,
#'             examples of strings:'first', 'sum', 'max', 'min', 'mean', 'median', 'last', 'count'
#' @param maintain_order  Sort the grouped keys so that the output order is predictable.
#' @param sort_columns  Sort the transposed columns by name. Default is by order of discovery.
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
#' df$pivot(
#'   values = "baz", index = "foo", columns = "bar", aggregate_function = "first"
#' )
#'
#'
#' # Run an expression as aggregation function
#' df = pl$DataFrame(
#'   col1 = c("a", "a", "a", "b", "b", "b"),
#'   col2 = c("x", "x", "x", "x", "y", "y"),
#'   col3 = c(6, 7, 3, 2, 5, 7)
#' )
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
#'  - as above but, but params wrapped in a list
#' @return DataFrame
#' @examples
#' pl$DataFrame(mtcars)$
#'   rename(miles_per_gallon = "mpg", horsepower = "hp")
DataFrame_rename = function(...) {
  self$lazy()$rename(...)$collect()
}

#' @title Summary statistics for a DataFrame
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
#' @param return_as_string Boolean (default `FALSE`). If `TRUE`, return the output as a string.
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
    if (inherits(dtype, "RPolarsDataType")) dtype_str <- paste0("<", dtype_str, ">")
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
#'   letters = c("a", "a", "b", "c"),
#'   numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8))
#' )
#' df
#'
#' df$explode("numbers")
DataFrame_explode = function(...) {
  self$lazy()$explode(...)$collect()
}
