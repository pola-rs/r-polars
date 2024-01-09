#' New Expr referring to all columns
#' @description
#' Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by AND' method.
#' @param name Character vector indicating on which columns the AND operation
#' should be applied.
#' @keywords Expr_new
#'
#' @return Boolean literal
#'
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#'
#' @examples
#' pl$DataFrame(list(all = c(TRUE, TRUE), some = c(TRUE, FALSE)))$select(pl$all()$all())
pl_all = function(name = NULL) {
  if (is.null(name)) {
    return(.pr$Expr$col("*"))
  }

  stop("not implemented")
  # TODO implement input list of Expr as in:
  # https://github.com/pola-rs/polars/blob/589f36432de6e95e81d9715a77d6fe78360512e5/py-polars/polars/internals/lazy_functions.py#L1095
}

#' Start Expression with a column
#' @description
#' Return an expression representing a column in a DataFrame.
#' @param name
#' - a single column by a string
#' - all columns by using a wildcard `"*"`
#' - multiple columns as vector of strings
#' - column by regular expression if the regex starts with `^` and ends with `$`
#' e.g. pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))
#' - a single DataType or an R list of DataTypes, select any column of any such DataType
#' - Series of utf8 strings abiding to above options
#' @param ... Additional column names can be passed as strings, separated by commas.
#'
#' @return Column Expression
#'
#' @keywords Expr_new
#' @examples
#'
#' df = pl$DataFrame(list(foo = 1, bar = 2L, foobar = "3"))
#'
#' # a single column by a string
#' df$select(pl$col("foo"))
#'
#' # two columns as strings separated by commas
#' df$select(pl$col("foo", "bar"))
#'
#' # all columns by wildcard
#' df$select(pl$col("*"))
#' df$select(pl$all())
#'
#' # multiple columns as vector of strings
#' df$select(pl$col(c("foo", "bar")))
#'
#' # column by regular expression if the regex starts with `^` and ends with `$`
#' df$select(pl$col("^foo.*$"))
#'
#' # a single DataType
#' df$select(pl$col(pl$dtypes$Float64))
#'
#' # ... or an R list of DataTypes, select any column of any such DataType
#' df$select(pl$col(list(pl$dtypes$Float64, pl$dtypes$String)))
#'
#' # from Series of names
#' df$select(pl$col(pl$Series(c("bar", "foobar"))))
pl_col = function(name = "", ...) {
  robj_to_col(name, list2(...)) |>
    unwrap("in pl$col()")
}

#' an element in 'eval'-expr
#' @description Alias for an element in evaluated in an `eval` expression.
#' @keywords Expr
#' @return Expr
#' @aliases element
#' @examples
#' pl$lit(1:5)$cumulative_eval(pl$element()$first() - pl$element()$last()**2)$to_r()
pl_element = function() pl$col("")

# TODO move all lazy functions to a new keyword lazy functions

#' pl$count
#' @description Count the number of values in this column/context.
#' @param column if dtype is:
#' - Series: count length of Series
#' - str: count values of this column
#' - NULL: count the number of value in this context.
#'
#'
#' @keywords Expr_new
#'
#' @return Expr or value-count in case Series
#'
#' @examples
#'
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#' df$select(pl$count())
#'
#'
#' df$group_by("c", maintain_order = TRUE)$agg(pl$count())
pl_count = function(column = NULL) { # -> Expr | int:
  if (is.null(column)) {
    return(.pr$Expr$new_count())
  }
  if (inherits(column, "RPolarsSeries")) {
    return(column$len())
  }
  # add context to any error from pl$col
  unwrap(result(pl$col(column)$count()), "in pl$count():")
}

#' Aggregate all column values into a list.
#' @param name Name of the column(s) that should be imploded, passed to pl$col()
#' @keywords Expr
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$implode("Species"))
pl_implode = function(name) { # -> Expr
  result(pl$col(name)) |>
    map(.pr$Expr$implode) |>
    unwrap("in pl$implode():")
}

#' pl$first
#' @description  Depending on the input type this function does different things:
#' @param column if dtype is:
#' - Series: Take first value in `Series`
#' - str: syntactic sugar for `pl.col(..).first()`
#' - NULL: expression to take first column of a context.
#'
#'
#' @keywords Expr_new
#'
#' @return Expr or first value of input Series
#'
#' @examples
#'
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#' df$select(pl$first())
#'
#' df$select(pl$first("a"))
#'
#' pl$first(df$get_column("a"))
#'
pl_first = function(column = NULL) { #-> Expr | Any:
  pcase(
    is.null(column), Ok(.pr$Expr$new_first()),
    inherits(column, "RPolarsSeries"), if (column$len() == 0) {
      Err("The series is empty, so no first value can be returned.")
    } else {
      # TODO impl a direct slicing Series e.g. as pl$lit(series)$slice(x,y)$to_r()
      # or if rust series has a dedicated method.
      Ok(pl$lit(column)$slice(0, 1)$to_r())
    },
    # pl$col is fallible catch any error result and add new calling context
    or_else = result(pl$col(column)$first())
  ) |>
    unwrap("in pl$first():")
}

#' pl$last
#' @description Depending on the input type this function does different things:
#' @param column if dtype is:
#' - Series: Take last value in `Series`
#' - str: syntactic sugar for `pl.col(..).last()`
#' - NULL: expression to take last column of a context.
#'
#' @keywords Expr_new
#'
#' @return Expr or last value of input Series
#'
#' @examples
#'
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#' df$select(pl$last())
#'
#' df$select(pl$last("a"))
#'
#' pl$last(df$get_column("a"))
#'
pl_last = function(column = NULL) { #-> Expr | Any:
  pcase(
    is.null(column), Ok(.pr$Expr$new_last()),
    inherits(column, "RPolarsSeries"), if (column$len() == 0) {
      Err("The series is empty, so no last value can be returned.")
    } else {
      # TODO impl a direct slicing Series e.g. as pl$lit(series)$slice(x,y)$to_r()
      # or if rust series has a dedicated method.
      Ok(pl$lit(column)$slice(-1, 1)$to_r())
    },
    # pl$col is fallible catch any error result and add new calling context
    or_else = result(pl$col(column)$last())
  ) |>
    unwrap("in pl$last():")
}

#' Get the first `n` rows.
#'
#' @param column if dtype is:
#' - Series: Take head value in `Series`
#' - str or int: syntactic sugar for `pl.col(..).head()`
#' @param n Number of rows to take
#' @keywords Expr_new
#' @return Expr or head value of input Series
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' expr_head = pl$head("a")
#' print(expr_head)
#' df$select(expr_head)
#'
#' df$select(pl$head("a", 2))
#' pl$head(df$get_column("a"), 2)
pl_head = function(column, n = 10) { #-> Expr | Any:
  pcase(
    inherits(column, "RPolarsSeries"), result(column$expr$head(n)),
    is.character(column), result(pl$col(column)$head(n)),
    inherits(column, "RPolarsExpr"), result(column$head(n)),
    or_else = Err(paste0(
      "param [column] type is neither Series, charvec nor Expr, but ",
      str_string(column)
    ))
  ) |>
    unwrap("in pl$head():")
}


#' Get the last `n` rows.
#'
#' @param column if dtype is:
#' - Series: Take tail value in `Series`
#' - str or in: syntactic sugar for `pl.col(..).tail()`
#' @param n Number of rows to take
#' @return Expr or tail value of input Series
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#'
#' expr_tail = pl$head("a")
#' print(expr_tail)
#' df$select(expr_tail)
#'
#' df$select(pl$tail("a", 2))
#'
#' pl$tail(df$get_column("a"), 2)
pl_tail = function(column, n = 10) { #-> Expr | Any:
  pcase(
    inherits(column, "RPolarsSeries"), result(column$expr$tail(n)),
    is.character(column), result(pl$col(column)$tail(n)),
    inherits(column, "RPolarsExpr"), result(column$tail(n)),
    or_else = Err(paste0(
      "param [column] type is neither Series, charvec nor Expr, but ",
      str_string(column)
    ))
  ) |>
    unwrap("in pl$tail():")
}

#' pl$mean
#' @description Depending on the input type this function does different things:
#' @param ... One or several elements:
#' - Series: Take mean value in `Series`
#' - DataFrame or LazyFrame: Take mean value of each column
#' - character vector: parsed as column names
#' - NULL: expression to take mean column of a context.
#'
#' @keywords Expr_new
#'
#' @return Expr or mean value of input Series
#'
#' @examples
#'
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#' df$select(pl$mean("a"))
#'
#' df$select(pl$mean("a", "b"))
#'
pl_mean = function(...) { #-> Expr | Any:
  column = list2(...)
  lc = length(column)
  stringflag = all(sapply(column, is_string))
  pcase(
    lc == 0L,
    Err("pl$mean() needs at least one argument."),
    lc > 1L && !stringflag,
    Err("When there are more than one arguments in pl$mean(), all arguments must be strings."),
    lc > 1L && stringflag,
    Ok(pl$col(unlist(column))$mean()),
    lc == 1L && inherits(column[[1]], "RPolarsSeries") && column[[1]]$len() == 0,
    Err("The series is empty, so no mean value can be returned."),
    lc == 1L && inherits(column[[1]], c("RPolarsSeries", "RPolarsLazyFrame", "RPolarsDataFrame")),
    Ok(column[[1]]$mean()),
    or_else = Ok(pl$col(column[[1]])$mean())
  ) |>
    unwrap("in pl$mean():")
}

#' pl$median
#' @description Depending on the input type this function does different things:
#' @inheritParams pl_mean
#'
#' @keywords Expr_new
#'
#' @return Expr or median value of input Series
#'
#' @examples
#'
#' df = pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2),
#'   c = c("foo", "bar", "foo")
#' )
#' df$select(pl$median("a"))
#'
#' df$select(pl$median("a", "b"))
#'
pl_median = function(...) { #-> Expr | Any:
  column = list2(...)
  lc = length(column)
  stringflag = all(sapply(column, is_string))
  pcase(
    lc == 0L,
    Err("pl$median() needs at least one argument."),
    lc > 1L && !stringflag,
    Err("When there are more than one arguments in pl$median(), all arguments must be strings."),
    lc > 1L && stringflag,
    Ok(pl$col(unlist(column))$median()),
    lc == 1L && inherits(column[[1]], "RPolarsSeries") && column[[1]]$len() == 0,
    Err("The series is empty, so no median value can be returned."),
    lc == 1L && inherits(column[[1]], c("RPolarsSeries", "RPolarsLazyFrame", "RPolarsDataFrame")),
    Ok(column[[1]]$median()),
    or_else = Ok(pl$col(column[[1]])$median())
  ) |>
    unwrap("in pl$median():")
}

#' Count `n` unique values
#' @description Depending on the input type this function does different things:
#' @param column if dtype is:
#' - Series: call method n_unique() to return value of unique values.
#' - String: syntactic sugar for `pl$col(column)$n_unique()`, returns Expr
#' - Expr: syntactic sugar for `column$n_unique()`, returns Expr
#'
#' @keywords Expr_new
#'
#' @return Expr or value
#'
#' @examples
#' # column as Series
#' pl$n_unique(pl$Series(1:4)) == 4
#'
#' # column as String
#' expr = pl$n_unique("bob")
#' print(expr)
#' pl$DataFrame(bob = 1:4)$select(expr)
#'
#' # colum as Expr
#' pl$DataFrame(bob = 1:4)$select(pl$n_unique(pl$col("bob")))
pl_n_unique = function(column) { #-> int or Expr
  pcase(
    inherits(column, c("RPolarsSeries", "RPolarsExpr")), result(column$n_unique()),
    is_string(column), result(pl$col(column)$n_unique()),
    or_else = Err(paste("arg [column] is neither Series, Expr or String, but", str_string(column)))
  ) |>
    unwrap("in pl$n_unique():")
}

#' Approximate count of unique values.
#' @description This is done using the HyperLogLog++ algorithm for cardinality estimation.
#' @param column if dtype is:
#' - String: syntactic sugar for `pl$col(column)$approx_n_unique()`, returns Expr
#' - Expr: syntactic sugar for `column$approx_n_unique()`, returns Expr
#'
#' @keywords Expr_new
#'
#' @return Expr
#'
#' @details The approx_n_unique is likely only warranted for large columns. See example.
#' It appears approx_n_unique scales better than n_unique, such that the relative performance
#' difference increases with column size.
#'
#' @examples
#' # column as Series
#' pl$approx_n_unique(pl$lit(1:4)) == 4
#'
#' # column as String
#' expr = pl$approx_n_unique("bob")
#' print(expr)
#' pl$DataFrame(bob = 1:80)$select(expr)
#'
#' # colum as Expr
#' pl$DataFrame(bob = 1:4)$select(pl$approx_n_unique(pl$col("bob")))
#'
#' # comparison with n_unique for 2 million integers. (try change example to 20 million ints)
#' lit_series = pl$lit(c(1:1E6, 1E6:1, 1:1E6))
#' system.time(pl$approx_n_unique(lit_series)$to_series()$print())
#' system.time(pl$n_unique(lit_series)$to_series()$print())
pl_approx_n_unique = function(column) { #-> int or Expr
  pcase(
    inherits(column, "RPolarsExpr"), result(column$approx_n_unique()),
    is_string(column), result(pl$col(column)$approx_n_unique()),
    or_else = Err(paste("arg [column] is neither Expr or String, but", str_string(column)))
  ) |>
    unwrap("in pl$approx_n_unique():")
}

#' Compute sum in one or several columns
#'
#' This is syntactic sugar for `pl$col(...)$sum()`.
#'
#' @param ...  One or several elements. Each element can be:
#'  - Series or Expr
#'  - string, that is parsed as columns
#'  - numeric, that is parsed as literal
#'
#' @return Expr
#' @keywords Expr_new
#' @examples
#' # column as string
#' pl$DataFrame(iris)$select(pl$sum("Petal.Width"))
#'
#' # column as Expr (prefer pl$col("Petal.Width")$sum())
#' pl$DataFrame(iris)$select(pl$sum(pl$col("Petal.Width")))
#'
#' df = pl$DataFrame(a = 1:2, b = 3:4, c = 5:6)
#'
#' # Compute sum in several columns
#' df$with_columns(pl$sum("*"))
pl_sum = function(...) {
  column = list2(...)
  if (length(column) == 1L) column = column[[1L]]
  if (inherits(column, "RPolarsSeries") || inherits(column, "RPolarsExpr")) {
    return(column$sum())
  }
  if (is_string(column)) {
    return(pl$col(column)$sum())
  }
  if (is.numeric(column)) {
    return(pl$lit(column)$sum())
  }
  if (is.list(column)) {
    return(pl$col(column)$sum())
  }
  stop("pl$sum: this input is not supported")
}


#' Find minimum value in one or several columns
#'
#' This is syntactic sugar for `pl$col(...)$min()`.
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or expressions to add up as expr1 + expr2 + expr3 + ...
#' If several args, then wrapped in a list and handled as above.
#'
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2, NA_real_, NA_real_),
#'   c = c(1:4)
#' )
#' df
#'
pl_min = function(...) {
  column = list2(...)
  if (length(column) == 1L) column = column[[1L]]
  if (inherits(column, "RPolarsSeries") || inherits(column, "RPolarsExpr")) {
    return(column$min())
  }
  if (is_string(column)) {
    return(pl$col(column)$min())
  }
  if (is.numeric(column)) {
    return(pl$lit(column)$min())
  }
  if (is.list(column)) {
    return(pl$col(column)$min())
  }
  stop("pl$min: this input is not supported")
}

#' Find maximum value in one or several columns
#'
#' This is syntactic sugar for `pl$col(...)$max()`.
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or expressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#'
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2, NA_real_, NA_real_),
#'   c = c(1:4)
#' )
#' df
#'
pl_max = function(...) {
  column = list2(...)
  if (length(column) == 1L) column = column[[1L]]
  if (inherits(column, "RPolarsSeries") || inherits(column, "RPolarsExpr")) {
    return(column$max())
  }
  if (is_string(column)) {
    return(pl$col(column)$max())
  }
  if (is.numeric(column)) {
    return(pl$lit(column)$max())
  }
  if (is.list(column)) {
    return(pl$col(column)$max())
  }
  stop("pl$max: this input is not supported")
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


#' Standard deviation
#' @description  syntactic sugar for starting a expression with std
#' @param column Column name.
#' @param ddof Delta Degrees of Freedom: the divisor used in the calculation is
#' N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return Expr or Series matching type of input column
pl_std = function(column, ddof = 1) {
  if (inherits(column, "RPolarsSeries") || inherits(column, "RPolarsExpr")) {
    return(column$std(ddof))
  }
  if (is_string(column)) {
    return(pl$col(column)$std(ddof))
  }
  if (is.numeric(column)) {
    return(pl$lit(column)$std(ddof))
  }
  stop("pl$std: this input is not supported")
}

#' Variance
#' @description  syntactic sugar for starting a expression with var
#' @inheritParams pl_std
#' @return Expr or Series matching type of input column
pl_var = function(column, ddof = 1) {
  if (inherits(column, "RPolarsSeries") || inherits(column, "RPolarsExpr")) {
    return(column$var(ddof))
  }
  if (is_string(column)) {
    return(pl$col(column)$var(ddof))
  }
  if (is.numeric(column)) {
    return(pl$lit(column)$var(ddof))
  }
  stop("pl$var: this input is not supported")
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

#' struct
#' @aliases struct
#' @description Collect several columns into a Series of dtype Struct.
#' @param exprs Columns/Expressions to collect into a Struct.
#' @param eager Evaluate immediately.
#' @param schema Optional schema named list that explicitly defines the struct field dtypes.
#' Each name must match a column name wrapped in the struct. Can only be used to cast some or all
#' dtypes, not to change the names. NULL means to include keep columns into the struct by their
#' current DataType. If a column is not included in the schema it is removed from the final struct.
#'
#' @details pl$struct creates Expr or Series of DataType Struct()
#' pl$Struct creates the DataType Struct()
#' In polars a schema is a named list of DataTypes. #' A schema describes e.g. a DataFrame.
#' More formally schemas consist of Fields.
#' A Field is an object describing the name and DataType of a column/Series, but same same.
#' A struct is a DataFrame wrapped into a Series, the DataType is Struct, and each
#' sub-datatype within are Fields.
#' In a dynamic language schema and a Struct (the DataType) are quite the same, except
#' schemas describe DataFrame and Struct's describe some Series.
#'
#' @return Eager=FALSE: Expr of Series with dtype Struct | Eager=TRUE: Series with dtype Struct
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
pl_struct = function(
    exprs, # list of exprs, str or Series or Expr or Series,
    eager = FALSE,
    schema = NULL) {
  # convert any non expr to expr and catch error in a result
  as_struct(wrap_elist_result(exprs, str_to_lit = FALSE)) |>
    and_then(\(struct_expr) { # if no errors continue struct_expr
      # cast expression
      if (!is.null(schema)) {
        struct_expr = struct_expr$cast(pl$Struct(schema))
      }
      if (!is_bool(eager)) {
        return(Err("arg [eager] is not a bool"))
      }
      if (eager) {
        result(pl$select(struct_expr)$to_series())
      } else {
        Ok(struct_expr)
      }
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
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 3),
#'   b = c("dogs", "cats", NA),
#'   c = c("play", "swim", "walk")
#' )
#'
#' df$with_columns(
#'   pl$concat_str(
#'     pl$col("a") * 2,
#'     "b",
#'     "c",
#'     pl$lit("!"),
#'     separator = " "
#'   )$alias("full_sentence")
#' )
#'
pl_concat_str = function(..., separator = "") {
  concat_str(list2(...), separator) |> unwrap("in $concat_str()")
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
#' This allows one to do rowwise operations. See `pl$fold()` to do rowwise
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
