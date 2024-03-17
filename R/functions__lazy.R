# TODO: rewrite with generic function `as_polars_lit`
#' Create a literal value
#'
#' @param x A vector of any length
#'
#' @return Expr
#'
#' @details
#' `pl$lit(NULL)` translates into a polars `null`.
#'
#' @examples
#' # scalars to literal, explicit `pl$lit(42)` implicit `+ 2`
#' pl$col("some_column") / pl$lit(42) + 2
#'
#' # vector to literal explicitly via Series and back again
#' # R vector to expression and back again
#' pl$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]]
#'
#' # r vector to literal and back r vector
#' pl$lit(1:4)$to_r()
#'
#' # r vector to literal to dataframe
#' pl$select(pl$lit(1:4))
#'
#' # r vector to literal to Series
#' pl$lit(1:4)$to_series()
#'
#' # vectors to literal implicitly
#' (pl$lit(2) + 1:4) / 4:1
pl_lit = function(x) {
  .pr$Expr$lit(x) |>
    unwrap("in pl$lit():")
}


#' New Expr referring to all columns
#'
#' Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by
#' AND' method.
#'
#' @param name Character vector indicating on which columns the AND operation
#' should be applied.
#'
#' @return Boolean literal
#'
#' @examples
#' test = pl$DataFrame(col_1 = c(TRUE, TRUE), col_2 = c(TRUE, FALSE))
#' test
#'
#' # here, the first `$all()` selects all columns, and the second `$all()` checks
#' # whether all values are true in each column
#' test$with_columns(pl$all()$all())
pl_all = function(name = NULL) {
  if (is.null(name)) {
    return(.pr$Expr$col("*"))
  }

  stop("not implemented")
  # TODO implement input list of Expr as in:
  # https://github.com/pola-rs/polars/blob/589f36432de6e95e81d9715a77d6fe78360512e5/py-polars/polars/internals/lazy_functions.py#L1095
}


#' Create an expression representing column(s) in a dataframe
#'
#' @param ...
#' One of the following:
#' - character vectors
#'   - Single wildcard `"*"` has a special meaning: check the examples.
#' - [RPolarsDataTypes][pl_dtypes]
#' - a list of [RPolarsDataTypes][pl_dtypes]
#' @return [Expr][Expr_class] of a column or columns
#' @examples
#' # a single column by a character
#' pl$col("foo")
#'
#' # multiple columns by characters
#' pl$col("foo", "bar")
#'
#' # multiple columns by RPolarsDataTypes
#' pl$col(pl$Float64, pl$String)
#'
#' # Single `"*"` is converted to a wildcard expression
#' pl$col("*")
#'
#' # multiple character vectors and a list of RPolarsDataTypes are also allowed
#' pl$col(c("foo", "bar"), "baz")
#' pl$col("foo", c("bar", "baz"))
#' pl$col(list(pl$Float64, pl$String))
#'
#' # there are some special notations for selecting columns
#' df = pl$DataFrame(foo = 1:3, bar = 4:6, baz = 7:9)
#'
#' ## select all columns with a wildcard `"*"`
#' df$select(pl$col("*"))
#'
#' ## select multiple columns by a regular expression
#' ## starts with `^` and ends with `$`
#' df$select(pl$col(c("^ba.*$")))
pl_col = function(...) {
  uw = \(x) unwrap(x, "in pl$col():")

  if (!nargs()) {
    Err_plain("pl$col() requires at least one argument.") |>
      uw()
  }

  dots = list2(...)

  if (is.character(dots[[1]])) {
    if (length(dots) == 1L && length(dots[[1]]) == 1L) {
      res = create_col(dots[[1]])
    } else {
      res = create_cols_from_strs(unlist(dots))
    }
  } else if (length(dots) == 1L && is.list(dots[[1]])) {
    # A list of RPolarsDataTypes
    res = create_cols_from_datatypes(dots[[1]])
  } else {
    # RPolarsDataTypes
    res = create_cols_from_datatypes(dots)
  }

  if (!is_ok(res)) {
    Err_plain(
      "pl$col()'s arguments must be one of the following:\n",
      "- character vectors\n",
      "- RPolarsDataTypes\n",
      "- a list of RPolarsDataTypes"
    ) |>
      uw()
  } else {
    res$ok
  }
}


#' an element in 'eval'-expr
#' @description Alias for an element in evaluated in an `eval` expression.
#' @keywords Expr
#' @return Expr
#' @aliases element
#' @examples
#' pl$lit(1:5)$cumulative_eval(pl$element()$first() - pl$element()$last()**2)$to_r()
pl_element = function() pl$col("")

#' Return the number of rows in the context.
#'
#' This is similar to `COUNT(*)` in SQL.
#' @return [Expression][Expr_class] of data type [UInt32][pl_dtypes]
#' @seealso
#' - [`<Expr>$count()`][Expr_count]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, NA),
#'   b = c(3, NA, NA),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$len())
pl_len = function() .pr$Expr$new_len()


#' Return the number of non-null values in the column.
#'
#' This function is syntactic sugar for `pl$col(...)$count()`.
#'
#' Calling this function without any arguments returns the number of rows in the context.
#' This way of using the function is deprecated.
#' Please use [`pl$len()`][pl_len] instead.
#'
#' @inheritParams pl_head
#' @inherit pl_len return
#' @seealso
#' - [`pl$len()`][pl_len]
#' - [`<Expr>$count()`][Expr_count]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, NA),
#'   b = c(3, NA, NA),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$count("a"))
#'
#' df$select(pl$count(c("b", "c")))
pl_count = function(...) {
  result(pl$col(...)$count()) |>
    unwrap("in pl$count():")
}


#' Aggregate all column values into a list.
#'
#' This function is syntactic sugar for `pl$col(...)$implode()`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @examples
#' pl$DataFrame(iris)$select(pl$implode("Species"))
pl_implode = function(...) {
  result(pl$col(...)$implode()) |>
    unwrap("in pl$implode():")
}


#' Get the first value.
#'
#' This function has different behavior depending on arguments:
#' - Missing -> Takes first column of a context.
#' - Character vectors -> Syntactic sugar for `pl$col(...)$first()`.
#' @param ... Characters indicating the column names
#' (passed to [`pl$col()`][pl_col], see [`?pl_col`][pl_col] for details),
#' or empty. If empty (default), returns an expression to take the first column
#' of the context instead.
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$first()`][Expr_first]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$first())
#'
#' df$select(pl$first("b"))
#'
#' df$select(pl$first(c("a", "c")))
pl_first = function(...) {
  if (!nargs()) {
    res = result(.pr$Expr$new_first())
  } else {
    res = result(pl$col(...)$first())
  }

  res |>
    unwrap("in pl$first():")
}

#' Get the last value.
#'
#' This function has different behavior depending on the input type:
#' - Missing -> Takes last column of a context.
#' - Character vectors -> Syntactic sugar for `pl$col(...)$last()`.
#' @param ... Characters indicating the column names
#' (passed to [`pl$col()`][pl_col], see [`?pl_col`][pl_col] for details),
#' or empty. If empty (default), returns an expression to take the last column
#' of the context instead.
#' @inherit pl_first return
#' @seealso
#' - [`<Expr>$last()`][Expr_last]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "baz")
#' )
#'
#' df$select(pl$last())
#'
#' df$select(pl$last("a"))
#'
#' df$select(pl$last(c("b", "c")))
pl_last = function(...) {
  if (!nargs()) {
    res = result(.pr$Expr$new_last())
  } else {
    res = result(pl$col(...)$last())
  }

  res |>
    unwrap("in pl$last():")
}

#' Get the first `n` rows.
#'
#' This function is syntactic sugar for `pl$col(...)$head(n)`.
#' @param ... Characters indicating the column names, passed to [`pl$col()`][pl_col].
#' See [`?pl_col`][pl_col] for details.
#' @param n Number of rows to return.
#' @return [Expr][Expr_class]
#' @seealso
#' - [`<Expr>$head()`][Expr_head]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$head("a"))
#'
#' df$select(pl$head("a", "b", n = 2))
pl_head = function(..., n = 10) {
  result(pl$col(...)$head(n)) |>
    unwrap("in pl$head():")
}


#' Get the last `n` rows.
#'
#' This function is syntactic sugar for `pl$col(...)$tail(n)`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$tail()`][Expr_tail]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$tail("a"))
#'
#' df$select(pl$tail("a", "b", n = 2))
pl_tail = function(..., n = 10) {
  result(pl$col(...)$tail(n)) |>
    unwrap("in pl$tail():")
}

# TODO: add pl_mean_horizontal
#' Get the mean value.
#'
#' This function is syntactic sugar for `pl$col(...)$mean()`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$mean()`][Expr_mean]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$mean("a"))
#'
#' df$select(pl$mean("a", "b"))
pl_mean = function(...) {
  result(pl$col(...)$mean()) |>
    unwrap("in pl$mean():")
}

#' Get the median value.
#'
#' This function is syntactic sugar for `pl$col(...)$median()`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$median()`][Expr_median]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$median("a"))
#'
#' df$select(pl$median("a", "b"))
pl_median = function(...) {
  result(pl$col(...)$median()) |>
    unwrap("in pl$median():")
}

#' Count unique values.
#'
#' This function is syntactic sugar for `pl$col(...)$n_unique()`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$n_unique()`][Expr_n_unique]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 1),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$n_unique("a"))
#'
#' df$select(pl$n_unique("b", "c"))
pl_n_unique = function(...) {
  result(pl$col(...)$n_unique()) |>
    unwrap("in pl$n_unique():")
}

#' Approximate count of unique values
#'
#' This function is syntactic sugar for `pl$col(...)$approx_n_unique()`,
#' and uses the HyperLogLog++ algorithm for cardinality estimation.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$approx_n_unique()`][Expr_approx_n_unique]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 1),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$approx_n_unique("a"))
#'
#' df$select(pl$approx_n_unique("b", "c"))
pl_approx_n_unique = function(...) {
  result(pl$col(...)$approx_n_unique()) |>
    unwrap("in pl$approx_n_unique():")
}

#' Sum all values.
#'
#' Syntactic sugar for `pl$col(...)$sum()`.
#' @inheritParams pl_head
#' @inherit pl_head return
#' @seealso
#' - [`<Expr>$sum()`][Expr_sum]
#' - [`pl$sum_horizontal()`][pl_sum_horizontal]
#' @examples
#' df = pl$DataFrame(col_a = 1:2, col_b = 3:4, c = 5:6)
#'
#' df$select(pl$sum("col_a"))
#'
#' # Sum multiple columns
#' df$select(pl$sum("col_a", "col_b"))
#'
#' df$select(pl$sum("^col_.*$"))
pl_sum = function(...) {
  result(pl$col(...)$sum()) |>
    unwrap("in pl$sum():")
}


#' Get the minimum value.
#'
#' Syntactic sugar for `pl$col(...)$min()`.
#' @inheritParams pl_sum
#' @inherit pl_sum return
#' @seealso
#' - [`<Expr>$min()`][Expr_min]
#' - [`pl$min_horizontal()`][pl_min_horizontal]
#' @examples
#' df = pl$DataFrame(
#'   num_1 = c(1, 8, 3),
#'   num_2 = c(4, 5, 2),
#'   chr_1 = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$min("num_1"))
#'
#' # Get the minimum value of multiple columns.
#' df$select(pl$min(r"(^num_\d+$)"))
#'
#' df$select(pl$min("num_1", "num_2"))
pl_min = function(...) {
  result(pl$col(...)$min()) |>
    unwrap("in pl$min():")
}

#' Get the maximum value.
#'
#' Syntactic sugar for `pl$col(...)$max()`.
#' @inheritParams pl_sum
#' @inherit pl_sum return
#' @seealso
#' - [`<Expr>$max()`][Expr_max]
#' - [`pl$max_horizontal()`][pl_max_horizontal]
#' @examples
#' df = pl$DataFrame(
#'   num_1 = c(1, 8, 3),
#'   num_2 = c(4, 5, 2),
#'   chr_1 = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$max("num_1"))
#'
#' # Get the maximum value of multiple columns.
#' df$select(pl$max(r"(^num_\d+$)"))
#'
#' df$select(pl$max("num_1", "num_2"))
pl_max = function(...) {
  result(pl$col(...)$max()) |>
    unwrap("in pl$max():")
}

#' Coalesce
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name pl_coalesce
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or expressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2, NA_real_, NA_real_),
#'   c = c(1:3, NA_real_)
#' )
#' # use coalesce to get first non Null value for each row, otherwise insert 99.9
#' df$with_columns(
#'   pl$coalesce("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl_coalesce = function(...) {
  column = list2(...)
  pra = do.call(construct_ProtoExprArray, column)
  coalesce_exprs(pra)
}


#' Get the standard deviation.
#'
#' This function is syntactic sugar for `pl$col(...)$std(ddof)`.
#' @inheritParams pl_sum
#' @param ddof An integer representing "Delta Degrees of Freedom":
#' the divisor used in the calculation is `N - ddof`,
#' where `N` represents the number of elements. By default ddof is `1`.
#' @inherit pl_sum return
#' @seealso
#' - [`<Expr>$std()`][Expr_std]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$std("a"))
#'
#' df$select(pl$std(c("a", "b")))
pl_std = function(..., ddof = 1) {
  result(pl$col(...)$std(ddof)) |>
    unwrap("in pl$std():")
}

#' Get the variance.
#'
#' This function is syntactic sugar for `pl$col(...)$var(ddof)`.
#' @inheritParams pl_std
#' @inherit pl_sum return
#' @seealso
#' - [`<Expr>$var()`][Expr_var]
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' df$select(pl$var("a"))
#'
#' df$select(pl$var("a", "b"))
pl_var = function(..., ddof = 1) {
  result(pl$col(...)$var(ddof)) |>
    unwrap("in pl$var():")
}


#' Concat the arrays in a Series dtype List in linear time.
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @param exprs list of Into<Expr>, strings interpreted as column names
#' @return Expr
#'
#' @keywords Expr_new
#'
#' @examples
#' # Create lagged columns and collect them into a list. This mimics a rolling window.
#' df = pl$DataFrame(A = c(1, 2, 9, 2, 13))
#' df$with_columns(lapply(
#'   0:2,
#'   \(i) pl$col("A")$shift(i)$alias(paste0("A_lag_", i))
#' ))$select(
#'   pl$concat_list(lapply(2:0, \(i) pl$col(paste0("A_lag_", i))))$alias(
#'     "A_rolling"
#'   )
#' )
#'
#' # concat Expr a Series and an R obejct
#' pl$concat_list(list(
#'   pl$lit(1:5),
#'   pl$Series(5:1),
#'   rep(0L, 5)
#' ))$alias("alice")$to_series()
#'
pl_concat_list = function(exprs) {
  concat_list(as.list(exprs)) |>
    unwrap(" in pl$concat_list():")
}

#' Collect columns into a struct column
#'
#' @param exprs Columns/Expressions to collect into a Struct.
#' @param schema Optional schema named list that explicitly defines the struct
#'   field dtypes. Each name must match a column name wrapped in the struct. Can
#'   only be used to cast some or all dtypes, not to change the names. If `NULL`
#'   (default), columns datatype are not modified. Columns that do not exist are
#'   silently ignored and not included in the final struct.
#'
#' @details
#'
#' `pl$struct()` creates an Expr of DataType [`Struct()`][DataType_Struct].
#'
#' Compared to the Python implementation, `pl$struct()` doesn't have the
#' argument `eager` and always returns an Expr. Use `$to_series()` to return a
#' Series.
#'
#' @return Expr with dtype Struct
#'
#' @examples
#' # isolated expression to wrap all columns in a struct aliased 'my_struct'
#' pl$struct(pl$all())$alias("my_struct")
#'
#' # wrap all column into on column/Series
#' df = pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L)
#' )$select(
#'   pl$struct(pl$all())$alias("my_struct")
#' )
#'
#' print(df)
#' print(df$schema) # returns a schema, a named list containing one element a Struct named my_struct
#'
#' # wrap two columns in a struct and provide a schema to set all or some DataTypes by name
#' e1 = pl$struct(
#'   pl$col(c("int", "str")),
#'   schema = list(int = pl$Int64, str = pl$String)
#' )$alias("my_struct")
#' # same result as e.g. wrapping the columns in a struct and casting afterwards
#' e2 = pl$struct(
#'   list(pl$col("int"), pl$col("str"))
#' )$cast(
#'   pl$Struct(int = pl$Int64, str = pl$String)
#' )$alias("my_struct")
#'
#' df = pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L)
#' )
#'
#' # verify equality in R
#' identical(df$select(e1)$to_list(), df$select(e2)$to_list())
#'
#' df$select(e2)
#' df$select(e2)$to_data_frame()
pl_struct = function(exprs, schema = NULL) {
  # convert any non expr to expr and catch error in a result
  as_struct(wrap_elist_result(exprs, str_to_lit = FALSE)) |>
    and_then(\(struct_expr) { # if no errors continue struct_expr
      # cast expression
      if (!is.null(schema)) {
        struct_expr = struct_expr$cast(pl$Struct(schema))
      }
      Ok(struct_expr)
    }) |>
    unwrap( # raise any error with context
      "in pl$struct:"
    )
}

#' Horizontally concatenate columns into a single string column
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals. Non-String columns are cast to String
#' @param separator String that will be used to separate the values of each
#' column.
#' @param ignore_nulls If `FALSE` (default), null values are propagated: if the
#' row contains any null values, the output is null.
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   a = 1:3,
#'   b = c("dogs", "cats", NA),
#'   c = c("play", "swim", "walk")
#' )
#'
#' df$with_columns(
#'   pl$concat_str(
#'     pl$col("a") * 2L, "b", "c", pl$lit("!"),
#'     separator = " "
#'   )$alias("full_sentence")
#' )
#'
#' df$with_columns(
#'   pl$concat_str(
#'     pl$col("a") * 2L, "b", "c", pl$lit("!"),
#'     separator = " ",
#'     ignore_nulls = TRUE
#'   )$alias("full_sentence")
#' )
pl_concat_str = function(..., separator = "", ignore_nulls = FALSE) {
  concat_str(list2(...), separator, ignore_nulls) |> unwrap("in $concat_str()")
}

#' Covariance
#' @description Calculates the covariance between two columns / expressions.
#' @param a One column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param b Another column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

#' @return Expr for the computed covariance
#' @examples
#' lf = pl$LazyFrame(data.frame(a = c(1, 8, 3), b = c(4, 5, 2)))
#' lf$select(pl$cov("a", "b"))$collect()
#' pl$cov(c(1, 8, 3), c(4, 5, 2))$to_r()
pl_cov = function(a, b, ddof = 1) {
  .pr$Expr$cov(a, b, ddof) |>
    unwrap("in pl$cov()")
}

#' Rolling covariance
#' @description Calculates the rolling covariance between two columns
#' @param a One column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param b Another column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param window_size int The length of the window
#' @param min_periods NULL or int The number of values in the window that should be non-null before computing a result.
#' If NULL, it will be set equal to window size.
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return Expr for the computed rolling covariance
#' @examples
#' lf = pl$LazyFrame(data.frame(a = c(1, 8, 3), b = c(4, 5, 2)))
#' lf$select(pl$rolling_cov("a", "b", window_size = 2))$collect()
pl_rolling_cov = function(a, b, window_size, min_periods = NULL, ddof = 1) {
  if (is.null(min_periods)) {
    min_periods = window_size
  }
  .pr$Expr$rolling_cov(a, b, window_size, min_periods, ddof) |> unwrap("in pl$rolling_cov()")
}


#' Correlation
#' @description Calculates the correlation between two columns
#' @param a One column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param b Another column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param method str One of 'pearson' or 'spearman'
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @param propagate_nans bool Used only when calculating the spearman rank correlation.
#' If `True` any `NaN` encountered will lead to `NaN` in the output.
#' Defaults to `False` where `NaN` are regarded as larger than any finite number and thus lead to the highest rank.
#' @return Expr for the computed correlation
#' @examples
#' lf = pl$LazyFrame(data.frame(a = c(1, 8, 3), b = c(4, 5, 2)))
#' lf$select(pl$corr("a", "b", method = "spearman"))$collect()
pl_corr = function(a, b, method = "pearson", ddof = 1, propagate_nans = FALSE) {
  .pr$Expr$corr(a, b, method, ddof, propagate_nans) |> unwrap("in pl$corr()")
}

#' Rolling correlation
#' @description Calculates the rolling correlation between two columns
#' @param a One column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param b Another column name or Expr or anything convertible Into<Expr> via `pl$col()`.
#' @param window_size int The length of the window
#' @param min_periods NULL or int The number of values in the window that should be non-null before computing a result.
#' If NULL, it will be set equal to window size.
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return Expr for the computed rolling correlation
#' @examples
#' lf = pl$LazyFrame(data.frame(a = c(1, 8, 3), b = c(4, 5, 2)))
#' lf$select(pl$rolling_corr("a", "b", window_size = 2))$collect()
pl_rolling_corr = function(a, b, window_size, min_periods = NULL, ddof = 1) {
  if (is.null(min_periods)) {
    min_periods = window_size
  }
  .pr$Expr$rolling_corr(a, b, window_size, min_periods, ddof) |> unwrap("in pl$rolling_corr()")
}


#' Accumulate over multiple columns horizontally with an R function
#'
#' This allows one to do rowwise operations, starting with an initial value
#' (`acc`). See [`pl$reduce()`][pl_reduce] to do rowwise operations without this initial
#' value.
#'
#' @param acc an Expr or Into<Expr> of the initial accumulator.
#' @param lambda R function which takes two polars Series as input and return one.
#' @param exprs Expressions to aggregate over. May also be a wildcard expression.
#'
#' @return An expression that will be applied rowwise
#'
#' @examples
#' df = pl$DataFrame(mtcars)
#'
#' # Make the row-wise sum of all columns
#' df$with_columns(
#'   pl$fold(
#'     acc = pl$lit(0),
#'     lambda = \(acc, x) acc + x,
#'     exprs = pl$col("*")
#'   )$alias("mpg_drat_sum_folded")
#' )
pl_fold = function(acc, lambda, exprs) {
  fold(acc, lambda, exprs) |>
    unwrap("in pl$fold():")
}

#' @inherit pl_fold title params return
#'
#' @description
#' This allows one to do rowwise operations. See [`pl$fold()`][pl_fold] to do rowwise
#' operations with an initial value.
#'
#' @examples
#' df = pl$DataFrame(mtcars)
#'
#' # Make the row-wise sum of all columns
#' df$with_columns(
#'   pl$reduce(
#'     lambda = \(acc, x) acc + x,
#'     exprs = pl$col("*")
#'   )$alias("mpg_drat_sum_reduced")
#' )
pl_reduce = function(lambda, exprs) {
  reduce(lambda, exprs) |>
    unwrap("in pl$reduce():")
}

#' Get the minimum value rowwise
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(2:1, NA_real_, NA_real_),
#'   c = c(1:2, NA_real_, -Inf)
#' )
#' df$with_columns(
#'   pl$min_horizontal("a", "b", "c", 99.9)$alias("min")
#' )
pl_min_horizontal = function(...) {
  min_horizontal(list2(...)) |>
    unwrap("in $min_horizontal():")
}

#' Get the maximum value rowwise
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(2:1, NA_real_, NA_real_),
#'   c = c(1:2, NA_real_, Inf)
#' )
#' df$with_columns(
#'   pl$max_horizontal("a", "b", "c", 99.9)$alias("max")
#' )
pl_max_horizontal = function(...) {
  max_horizontal(list2(...)) |>
    unwrap("in $max_horizontal():")
}

#' Apply the AND logical rowwise
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = c(TRUE, FALSE, NA, NA),
#'   b = c(TRUE, FALSE, NA, NA),
#'   c = c(TRUE, FALSE, NA, TRUE)
#' )
#' df
#'
#' df$with_columns(
#'   pl$all_horizontal("a", "b", "c")$alias("all")
#' )
#'
#' # drop rows that have at least one missing value
#' # == keep rows that only have non-missing values
#' df$filter(
#'   pl$all_horizontal(pl$all()$is_not_null())
#' )
pl_all_horizontal = function(...) {
  all_horizontal(list2(...)) |>
    unwrap("in $all_horizontal():")
}

#' Apply the OR logical rowwise
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = c(FALSE, FALSE, NA, NA),
#'   b = c(TRUE, FALSE, NA, NA),
#'   c = c(TRUE, FALSE, NA, TRUE)
#' )
#' df
#'
#' df$with_columns(
#'   pl$any_horizontal("a", "b", "c")$alias("any")
#' )
#'
#' # drop rows that only have missing values == keep rows that have at least one
#' # non-missing value
#' df$filter(
#'   pl$any_horizontal(pl$all()$is_not_null())
#' )
pl_any_horizontal = function(...) {
  any_horizontal(list2(...)) |>
    unwrap("in $any_horizontal():")
}

#' Compute the sum rowwise
#'
#' @param ... Columns to concatenate into a single string column. Accepts
#' expressions. Strings are parsed as column names, other non-expression inputs
#' are parsed as literals.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(3:4, NA_real_, NA_real_),
#'   c = c(1:2, NA_real_, -Inf)
#' )
#' df$with_columns(
#'   pl$sum_horizontal("a", "b", "c", 2)$alias("sum")
#' )
pl_sum_horizontal = function(...) {
  sum_horizontal(list2(...)) |>
    unwrap("in $sum_horizontal():")
}


#' Create polars Duration from distinct time components
#'
#' @param weeks Number of weeks to add. Expr or something coercible to an Expr.
#'   Strings are parsed as column names. *Same thing for argument `days` to
#'   `nanoseconds`*.
#' @param days Number of days to add.
#' @param hours Number of hours to add.
#' @param minutes Number of minutes to add.
#' @param seconds Number of seconds to add.
#' @param milliseconds Number of milliseconds to add.
#' @param microseconds Number of microseconds to add.
#' @param nanoseconds Number of nanoseconds to add.
#' @param time_unit Time unit of the resulting expression.
#' @param ... Not used.
#'
#' @details
#' A duration represents a fixed amount of time. For example,
#' `pl$duration(days = 1)` means "exactly 24 hours". By contrast,
#' `Expr$dt$offset_by('1d')` means "1 calendar day", which could sometimes be 23
#' hours or 25 hours depending on Daylight Savings Time. For non-fixed durations
#' such as "calendar month" or "calendar day", please use `Expr$dt$offset_by()`
#' instead.
#'
#'
#' @return Expr
#'
#' @examples
#' test = pl$DataFrame(
#'   dt = c(
#'     "2022-01-01 00:00:00",
#'     "2022-01-02 00:00:00"
#'   ),
#'   add = 1:2
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Datetime("us"), format = NULL)
#' )
#'
#' test$with_columns(
#'   (pl$col("dt") + pl$duration(weeks = "add"))$alias("add_weeks"),
#'   (pl$col("dt") + pl$duration(days = "add"))$alias("add_days"),
#'   (pl$col("dt") + pl$duration(seconds = "add"))$alias("add_seconds"),
#'   (pl$col("dt") + pl$duration(milliseconds = "add"))$alias("add_millis"),
#'   (pl$col("dt") + pl$duration(hours = "add"))$alias("add_hours")
#' )
#'
#' # we can also pass an Expr
#' test$with_columns(
#'   (pl$col("dt") + pl$duration(weeks = pl$col("add") + 1))$alias("add_weeks"),
#'   (pl$col("dt") + pl$duration(days = pl$col("add") + 1))$alias("add_days"),
#'   (pl$col("dt") + pl$duration(seconds = pl$col("add") + 1))$alias("add_seconds"),
#'   (pl$col("dt") + pl$duration(milliseconds = pl$col("add") + 1))$alias("add_millis"),
#'   (pl$col("dt") + pl$duration(hours = pl$col("add") + 1))$alias("add_hours")
#' )
pl_duration = function(
    ...,
    weeks = NULL,
    days = NULL,
    hours = NULL,
    minutes = NULL,
    seconds = NULL,
    milliseconds = NULL,
    microseconds = NULL,
    nanoseconds = NULL,
    time_unit = "us") {
  duration(weeks, days, hours, minutes, seconds, milliseconds, microseconds, nanoseconds, time_unit) |>
    unwrap("in $duration():")
}


#' Convert a Unix timestamp to date(time)
#'
#' Depending on the `time_unit` provided, this function will return a different
#' dtype:
#' * `time_unit = "d"` returns `pl$Date`
#' * `time_unit = "s"` returns [`pl$Datetime("us")`][DataType_Datetime]
#'   (`pl$Datetime`’s default)
#' * `time_unit = "ms"` returns [`pl$Datetime("ms")`][DataType_Datetime]
#' * `time_unit = "us"` returns [`pl$Datetime("us")`][DataType_Datetime]
#' * `time_unit = "ns"` returns [`pl$Datetime("ns")`][DataType_Datetime]
#'
#' @param column An Expr from which integers will be parsed. If this is a float
#' column, then the decimal part of the float will be ignored. Character are
#' parsed as column names, but other literal values must be passed to
#' [`pl$lit()`][pl_lit].
#' @param time_unit One of `"ns"`, `"us"`, `"ms"`, `"s"`, `"d"`
#'
#' @return Expr as Date or [Datetime][DataType_Datetime] depending on the
#' `time_unit`.
#'
#' @examples
#' # pass an integer column
#' df = pl$DataFrame(timestamp = c(1666683077, 1666683099))
#' df$with_columns(
#'   timestamp_to_datetime = pl$from_epoch(pl$col("timestamp"), time_unit = "s")
#' )
#'
#' # pass a literal
#' pl$from_epoch(pl$lit(c(1666683077, 1666683099)), time_unit = "s")$to_series()
#'
#' # use different time_unit
#' df = pl$DataFrame(timestamp = c(12345, 12346))
#' df$with_columns(
#'   timestamp_to_date = pl$from_epoch(pl$col("timestamp"), time_unit = "d")
#' )
pl_from_epoch = function(column, time_unit = "s") {
  uw = \(res) unwrap(res, "in $from_epoch():")
  if (is.character(column)) {
    column = pl$col(column)
  }

  if (!time_unit %in% c("ns", "us", "ms", "s", "d")) {
    Err_plain("`time_unit` must be one of 'ns', 'us', 'ms', 's', 'd'") |>
      uw()
  }

  switch(time_unit,
    "d" = column$cast(pl$Date),
    "s" = (column$cast(pl$Int64) * 1000000L)$cast(pl$Datetime("us")),
    column$cast(pl$Datetime(time_unit))
  )
}

#' Create a Datetime expression
#'
#' @param year An Expr or something coercible to an Expr, that must return an
#'   integer. Strings are parsed as column names. Floats are cast to integers.
#' @param month An Expr or something coercible to an Expr, that must return an
#'   integer between 1 and 12. Strings are parsed as column names. Floats are
#'   cast to integers.
#' @param day An Expr or something coercible to an Expr, that must return an
#'   integer between 1 and 31. Strings are parsed as column names. Floats are
#'   cast to integers.
#' @param hour An Expr or something coercible to an Expr, that must return an
#'   integer between 0 and 23. Strings are parsed as column names. Floats are
#'   cast to integers.
#' @param minute An Expr or something coercible to an Expr, that must return an
#'   integer between 0 and 59. Strings are parsed as column names. Floats are
#'   cast to integers.
#' @param second An Expr or something coercible to an Expr, that must return an
#'   integer between 0 and 59. Strings are parsed as column names. Floats are
#'   cast to integers.
#' @param microsecond An Expr or something coercible to an Expr, that must
#'   return an integer between 0 and 999,999. Strings are parsed as column
#'   names. Floats are cast to integers.
#' @param ... Not used.
#' @inheritParams DataType_Datetime
#' @inheritParams ExprDT_replace_time_zone
#'
#' @return An Expr of type Datetime
#' @seealso
#' - [`pl$date()`][pl_date]
#' - [`pl$time()`][pl_time]
#'
#' @examples
#' df = pl$DataFrame(
#'   year = 2019:2021,
#'   month = 9:11,
#'   day = 10:12,
#'   min = 55:57
#' )
#'
#' df$with_columns(
#'   dt_from_cols = pl$datetime("year", "month", "day", minute = "min"),
#'   dt_from_lit = pl$datetime(2020, 3, 5, hour = 20:22),
#'   dt_from_mix = pl$datetime("year", 3, 5, second = 1)
#' )
#'
#' # floats are coerced to integers
#' df$with_columns(
#'   dt_floats = pl$datetime(2018.8, 5.3, 1, second = 2.1)
#' )
#'
#' # if datetime can't be constructed, it returns null
#' df$with_columns(
#'   dt_floats = pl$datetime(pl$lit("abc"), -2, 1)
#' )
#'
#' # can control the time_unit
#' df$with_columns(
#'   dt_from_cols = pl$datetime("year", "month", "day", minute = "min", time_unit = "ms")
#' )
pl_datetime = function(year, month, day, hour = NULL, minute = NULL, second = NULL, microsecond = NULL, ..., time_unit = "us", time_zone = NULL, ambiguous = "raise") {
  datetime(year, month, day, hour, minute, second, microsecond, time_unit, time_zone, ambiguous) |>
    unwrap("in pl$datetime():")
}

#' Create a Date expression
#'
#' @inheritParams pl_datetime
#'
#' @return An Expr of type Date
#' @seealso
#' - [`pl$datetime()`][pl_datetime]
#' - [`pl$time()`][pl_time]
#'
#' @examples
#' df = pl$DataFrame(year = 2019:2021, month = 9:11, day = 10:12)
#'
#' df$with_columns(
#'   date_from_cols = pl$date("year", "month", "day"),
#'   date_from_lit = pl$date(2020, 3, 5),
#'   date_from_mix = pl$date("year", 3, 5)
#' )
#'
#' # floats are coerced to integers
#' df$with_columns(
#'   date_floats = pl$date(2018.8, 5.3, 1)
#' )
#'
#' # if date can't be constructed, it returns null
#' df$with_columns(
#'   date_floats = pl$date(pl$lit("abc"), -2, 1)
#' )
pl_date = function(year, month, day) {
  pl$datetime(year, month, day)$cast(pl$Date)$alias("date") |>
    result() |>
    unwrap("in pl$date():")
}

#' Create a Time expression
#'
#' @inheritParams pl_datetime
#'
#' @return An Expr of type Time
#' @seealso
#' - [`pl$datetime()`][pl_datetime]
#' - [`pl$date()`][pl_date]
#'
#' @examples
#' df = pl$DataFrame(hour = 19:21, min = 9:11, sec = 10:12, micro = 1)
#'
#' df$with_columns(
#'   time_from_cols = pl$time("hour", "min", "sec", "micro"),
#'   time_from_lit = pl$time(12, 3, 5),
#'   time_from_mix = pl$time("hour", 3, 5)
#' )
#'
#' # floats are coerced to integers
#' df$with_columns(
#'   time_floats = pl$time(12.5, 5.3, 1)
#' )
#'
#' # if time can't be constructed, it returns null
#' df$with_columns(
#'   time_floats = pl$time(pl$lit("abc"), -2, 1)
#' )
pl_time = function(hour = NULL, minute = NULL, second = NULL, microsecond = NULL) {
  pl$datetime(year = 1970, month = 1, day = 1, hour, minute, second, microsecond)$cast(pl$Time)$alias("time") |>
    result() |>
    unwrap("in pl$time():")
}

#' Return indices that match a condition
#'
#' @param condition An Expr that gives a boolean.
#'
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(a = c(1, 2, 3, 4, 5))
#' df$select(
#'   pl$arg_where(pl$col("a") %% 2 == 0)
#' )
pl_arg_where = function(condition) {
  arg_where(condition) |>
    unwrap("in $arg_where():")
}
