#' Inner workings of the Series-class
#'
#' The `Series`-class is simply two environments of respectively
#' the public and private methods/function calls to the polars rust side. The
#' instantiated `Series`-object is an `externalptr` to a lowlevel rust polars
#' Series  object. The pointer address is the only statefullness of the Series
#' object on the R side. Any other state resides on the rust side. The S3
#' method `.DollarNames.RPolarsSeries` exposes all public `$foobar()`-methods
#' which are callable onto the object. Most methods return another
#' `Series`-class instance or similar which allows for method chaining. This
#' class system in lack of a better name could be called "environment classes"
#' and is the same class system extendr provides, except here there is both a
#' public and private set of methods. For implementation reasons, the private
#' methods are external and must be called from `.pr$Series$methodname()`,
#' also all private methods must take any self as an argument, thus they are
#' pure functions. Having the private methods as pure functions
#' solved/simplified self-referential complications.
#'
#' Check out the source code in R/Series_frame.R how public methods are
#' derived from private methods. Check out  extendr-wrappers.R to see the
#' extendr-auto-generated methods. These are moved to .pr and converted into
#' pure external functions in after-wrappers.R. In zzz.R (named zzz to be last
#' file sourced) the extendr-methods are removed and replaced by any function
#' prefixed `Series_`.
#'
#' @name Series_class
#' @aliases RPolarsSeries
#' @section Active bindings:
#'
#' ## dtype
#'
#' `$dtype` returns the [data type][pl_dtypes] of the Series.
#'
#' ## flags
#'
#' `$flags` returns a named list with flag names and their values.
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
#' ## name
#'
#' `$name` returns the name of the Series.
#'
#' ## shape
#'
#' `$shape` returns a numeric vector of length two with the number of length
#' of the Series and width of the Series (always 1).
#'
#' @section Expression methods:
#'
#' Series stores most of all [Expr][Expr_class] methods.
#'
#' Some of these are stored in sub-namespaces.
#'
#' ## arr
#'
#' `$arr` stores all array related methods.
#'
#' ## bin
#'
#' `$bin` stores all binary related methods.
#'
#' ## cat
#'
#' `$cat` stores all categorical related methods.
#'
#' ## dt
#'
#' `$dt` stores all temporal related methods.
#'
#' ## list
#'
#' `$list` stores all list related methods.
#'
#' ## str
#'
#' `$str` stores all string related methods.
#'
#' ## struct
#'
#' `$struct` stores all struct related methods and active bindings.
#'
#' Active bindings specific to Series:
#'
#' - `$struct$fields`: Returns a character vector of the fields in the struct.
#'
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @keywords Series
#'
#' @examples
#' # make a Series
#' s = as_polars_series(c(1:3, 1L))
#'
#' # call an active binding
#' s$shape
#'
#' # show flags
#' s$sort()$flags
#'
#' # use Expr method
#' s$cos()
#'
#' # use Expr method in subnamespaces
#' as_polars_series(list(3:1, 1:2, NULL))$list$first()
#' as_polars_series(c(1, NA, 2))$str$join("-")
#'
#' s = pl$date_range(
#'   as.Date("2024-02-18"), as.Date("2024-02-24"),
#'   interval = "1d"
#' )$to_series()
#' s
#' s$dt$day()
#'
#' # Other active bindings in subnamespaces
#' as_polars_series(data.frame(a = 1:2, b = 3:4))$struct$fields
#'
#' # show all available methods for Series
#' pl$show_all_public_methods("RPolarsSeries")
#'
NULL


# Active bindings

Series_dtype = method_as_active_binding(\() .pr$Series$dtype(self))


Series_flags = method_as_active_binding(
  \() {
    out = list(
      "SORTED_ASC" = .pr$Series$is_sorted_ascending_flag(self),
      "SORTED_DESC" = .pr$Series$is_sorted_descending_flag(self)
    )

    # the width value given here doesn't matter, but pl$Array() must have one
    if (pl$same_outer_dt(self$dtype, pl$List()) ||
      pl$same_outer_dt(self$dtype, pl$Array(width = 1))) {
      out[["FAST_EXPLODE"]] = .pr$Series$can_fast_explode_flag(self)
    }

    out
  }
)


Series_name = method_as_active_binding(\() .pr$Series$name(self))


Series_shape = method_as_active_binding(\() .pr$Series$shape(self))


## Methods from Expr

#' Function to add Expr methods to Series
#'
#' Executed in zzz.R
#' @noRd
add_expr_methods_to_series = function() {
  methods_exclude = c(
    "agg_groups",
    "exclude",
    "inspect",
    "over",
    "rolling",
    "to_series"
  )
  methods_diff = setdiff(ls(RPolarsExpr), ls(RPolarsSeries))

  for (method in setdiff(methods_diff, methods_exclude)) {
    if (!inherits(RPolarsExpr[[method]], "property")) {
      # make a modified Expr function
      new_f = eval(parse(text = paste0(r"(function() {
        f = RPolarsExpr$)", method, r"(

        df = self$to_frame()
        col_name = self$name
        self = pl$col(col_name)
        # Override `self` in `$.RPolarsExpr`
        environment(f) = environment()

        expr = do.call(f, as.list(match.call()[-1]), envir = parent.frame())

        pcase(
          inherits(expr, "RPolarsExpr"), df$select(expr)$to_series(0),
          or_else = expr
        )
      })")))
      # set new_method to have the same formals arguments
      formals(new_f) = formals(method, RPolarsExpr)
      RPolarsSeries[[method]] <<- new_f
    }
  }
}


## Sub-namespaces

#' Make sub namespace of Series from Expr sub namespace
#' @param ... Addtional funtions to add to the namespace
#' @noRd
series_make_sub_ns = function(pl_series, .expr_make_sub_ns_fn, ...) {
  # Override `self` in `$.RPolarsExpr`
  self = pl$col(pl_series$name) # nolint: object_usage_linter

  fns = .expr_make_sub_ns_fn(pl$col(pl_series$name))
  new_fns = lapply(fns, \(f) {
    environment(f) = parent.frame(2L)
    new_f = function() {
      expr = do.call(f, as.list(match.call()[-1]), envir = parent.frame())
      pcase(
        inherits(expr, "RPolarsExpr"), pl_series$to_frame()$select(expr)$to_series(0),
        or_else = expr
      )
    }

    formals(new_f) = formals(f)
    new_f
  })

  if (!missing(...)) {
    additional_fns = list(...) |>
      lapply(\(f) {
        environment(f) = parent.frame(2L)
        new_f = function() {
          do.call(f, as.list(match.call()[-1]), envir = parent.frame())
        }

        formals(new_f) = formals(f)
        class(new_f) = class(f)
        new_f
      })

    new_fns = c(additional_fns, new_fns)
  }

  new_fns |>
    lapply(\(f) {
      if (inherits(f, "property")) {
        f()
      } else {
        f
      }
    })
}

Series_arr = method_as_active_binding(\() series_make_sub_ns(self, expr_arr_make_sub_ns))

Series_bin = method_as_active_binding(\() series_make_sub_ns(self, expr_bin_make_sub_ns))

Series_cat = method_as_active_binding(\() series_make_sub_ns(self, expr_cat_make_sub_ns))

Series_dt = method_as_active_binding(\() series_make_sub_ns(self, expr_dt_make_sub_ns))

Series_list = method_as_active_binding(\() series_make_sub_ns(self, expr_list_make_sub_ns))

Series_str = method_as_active_binding(\() series_make_sub_ns(self, expr_str_make_sub_ns))

Series_struct = method_as_active_binding(
  \() {
    pl_series = NULL # Workaround for R CMD check `Undefined global functions or variables` error
    series_make_sub_ns(
      self, expr_struct_make_sub_ns,
      fields = method_as_active_binding(function() {
        unwrap(.pr$Series$struct_fields(pl_series), "in $struct$fields:")
      })
    )
  }
)


#' Create new Series
#'
#' This function is a simple way to convert R vectors to
#' [the Series class object][Series_class].
#' Internally, this function is a simple wrapper of [as_polars_series()].
#'
#' Python Polars has a feature that automatically interprets something like `polars.Series([1])`
#' as `polars.Series(values=[1])` if you specify Array like objects as the first argument.
#' This feature is not available in R Polars, so something like `pl$Series(1)` will raise an error.
#' You should use `pl$Series(values = 1)` or [`as_polars_series(1)`][as_polars_series] instead.
#' @param values Object to convert into a polars Series.
#' Passed to the `x` argument in [as_polars_series()][as_polars_series].
#' @param name A character to use as the name of the Series, or `NULL` (default).
#' Passed to the `name` argument in [as_polars_series()][as_polars_series].
#' @param dtype One of [polars data type][pl_dtypes] or `NULL`.
#' If not `NULL`, that data type is used to [cast][Expr_cast] the Series created from the vector
#' to a specific data type internally.
#' @param ... Ignored.
#' @param strict A logical. If `TRUE` (default), throw an error if any value does not exactly match
#' the given data type by the `dtype` argument. If `FALSE`, values that do not match the data type
#' are cast to that data type or, if casting is not possible, set to `null` instead.
#' Passed to the `strict` argument of the [`$cast()`][Expr_cast] method internally.
#' @param nan_to_null If `TRUE`, `NaN` values contained in the Series are replaced to `null`.
#' Using the [`$fill_nan()`][Expr_fill_nan] method internally.
#' @return [Series][Series_class]
#' @aliases Series
#' @seealso
#' - [as_polars_series()]
#' @examples
#' # Constructing a Series by specifying name and values positionally:
#' s = pl$Series("a", 1:3)
#' s
#'
#' # Notice that the dtype is automatically inferred as a polars Int32:
#' s$dtype
#'
#' # Constructing a Series with a specific dtype:
#' s2 = pl$Series(values = 1:3, name = "a", dtype = pl$Float32)
#' s2
pl_Series = function(
    name = NULL,
    values = NULL,
    dtype = NULL,
    ...,
    strict = TRUE,
    nan_to_null = FALSE) {
  uw = function(x) unwrap(x, "in pl$Series():")

  if (!is.null(dtype) && !isTRUE(is_polars_dtype(dtype))) {
    Err_plain("The dtype argument is not a valid Polars data type and cannot be converted into one.") |>
      uw()
  }

  out = result(as_polars_series(values, name)) |>
    uw()

  if (!is.null(dtype)) {
    out = result(out$cast(dtype, strict)) |>
      uw()
  }

  if (isTRUE(nan_to_null)) {
    out = result(out$fill_nan(NULL)) |>
      uw()
  }

  out
}

#' Print Series
#' @rdname Series_print
#' @return self
#'
#' @examples as_polars_series(1:3)
Series_print = function() {
  .pr$Series$print(self)
  invisible(self)
}


#' Add Series
#'
#' Method equivalent of addition operator `series + other`.
#' @param other [Series][Series_class] like object of numeric or string values.
#' Converted to [Series][Series_class] by [as_polars_series()] in this method.
#' @return [Series][Series_class]
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:3)$add(as_polars_series(11:13))
#' as_polars_series(1:3)$add(11:13)
#' as_polars_series(1:3)$add(1L)
#'
#' as_polars_series("a")$add("-z")
Series_add = function(other) {
  .pr$Series$add(self, as_polars_series(other)) |>
    unwrap("in $add():")
}


#' Subtract Series
#'
#' Method equivalent of subtraction operator `series - other`.
#' @inherit Series_add return
#' @param other [Series][Series_class] like object of numeric.
#' Converted to [Series][Series_class] by [as_polars_series()] in this method.
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:3)$sub(11:13)
#' as_polars_series(1:3)$sub(as_polars_series(11:13))
#' as_polars_series(1:3)$sub(1L)
#' 1L - as_polars_series(1:3)
#' as_polars_series(1:3) - 1L
Series_sub = function(other) {
  .pr$Series$sub(self, as_polars_series(other)) |>
    unwrap("in $sub():")
}


#' Divide Series
#'
#' Method equivalent of division operator `series / other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:3)$div(11:13)
#' as_polars_series(1:3)$div(as_polars_series(11:13))
#' as_polars_series(1:3)$div(1L)
Series_div = function(other) {
  .pr$Series$div(self, as_polars_series(other)) |>
    unwrap("in $div():")
}


#' Floor Divide Series
#'
#' Method equivalent of floor division operator `series %/% other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:3)$floor_div(11:13)
#' as_polars_series(1:3)$floor_div(as_polars_series(11:13))
#' as_polars_series(1:3)$floor_div(1L)
Series_floor_div = function(other) {
  self$to_frame()$select(pl$col(self$name)$floor_div(as_polars_series(other)))$to_series(0)
}


#' Multiply Series
#'
#' Method equivalent of multiplication operator `series * other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:3)$mul(11:13)
#' as_polars_series(1:3)$mul(as_polars_series(11:13))
#' as_polars_series(1:3)$mul(1L)
Series_mul = function(other) {
  .pr$Series$mul(self, as_polars_series(other)) |>
    unwrap("in $mul():")
}


#' Modulo Series
#'
#' Method equivalent of modulo operator `series %% other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' as_polars_series(1:4)$mod(2L)
#' as_polars_series(1:3)$mod(as_polars_series(11:13))
#' as_polars_series(1:3)$mod(1L)
Series_mod = function(other) {
  .pr$Series$rem(self, as_polars_series(other)) |>
    unwrap("in $mod():")
}


#' Power Series
#'
#' Method equivalent of power operator `series ^ other`.
#' @inherit Series_sub return
#' @param exponent [Series][Series_class] like object of numeric.
#' Converted to [Series][Series_class] by [as_polars_series()] in this method.
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' s = as_polars_series(1:4, name = "foo")
#'
#' s$pow(3L)
Series_pow = function(exponent) {
  self$to_frame()$select(pl$col(self$name)$pow(as_polars_series(exponent)))$to_series(0)
}

#' @export
`==.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(s1)$eq(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}

#' @export
`!=.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(self)$neq(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}

#' @export
`<.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(s1)$lt(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}

#' @export
`>.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(s1)$gt(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}

#' @export
`<=.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(s1)$lt_eq(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}

#' @export
`>=.RPolarsSeries` = function(s1, s2) {
  pl$select(pl$lit(s1)$gt_eq(pl$lit(as_polars_series(s2))$cast(s1$dtype)))$to_series()
}


#' Convert Series to R vector or list
#'
#' `$to_r()` automatically returns an R vector or list based on the Polars
#' DataType. It is possible to force the output type by using `$to_vector()` or
#' `$to_list()`.
#'
#' @inheritParams DataFrame_to_data_frame
#'
#' @return R list or vector
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @examples
#' # Series with non-list type
#' series_vec = as_polars_series(letters[1:3])
#'
#' series_vec$to_r() # as vector because Series DataType is not list (is String)
#' series_vec$to_list() # implicit call as.list(), convert to list
#' series_vec$to_vector() # implicit call unlist(), same as to_r() as already vector
#'
#'
#' # make a Series with nested lists
#' series_list = as_polars_series(
#'   list(
#'     list(c(1:5, NA_integer_)),
#'     list(1:2, NA_integer_)
#'   )
#' )
#' series_list
#'
#' series_list$to_r() # as list because Series DataType is list
#' series_list$to_list() # implicit call as.list(), same as to_r() as already list
#' series_list$to_vector() # implicit call unlist(), append into a vector
Series_to_r = \(int64_conversion = polars_options()$int64_conversion) {
  unwrap(.pr$Series$to_r(self, int64_conversion), "in $to_r():")
}

#' @rdname Series_to_r
#' @inheritParams DataFrame_to_data_frame
Series_to_vector = \(int64_conversion = polars_options()$int64_conversion) {
  unlist(unwrap(.pr$Series$to_r(self, int64_conversion), "in $to_vector():"))
}

#' @rdname Series_to_r
#' @inheritParams DataFrame_to_data_frame
Series_to_list = \(int64_conversion = polars_options()$int64_conversion) {
  as.list(unwrap(.pr$Series$to_r(self, int64_conversion), "in $to_list():"))
}

#' Count the occurrences of unique values
#'
#' @inheritParams Expr_value_counts
#'
#' @return DataFrame
#' @examples
#' as_polars_series(iris$Species, name = "flower species")$value_counts()
Series_value_counts = function(..., sort = TRUE, parallel = FALSE, name = "count", normalize = FALSE) {
  .pr$Series$value_counts(self, sort, parallel, name, normalize) |>
    unwrap("in $value_counts():")
}

#' Apply every value with an R fun
#' @description About as slow as regular non-vectorized R. Similar to using R sapply on a vector.
#' @param fun r function, should take a single value as input and return one.
#' @param datatype DataType of return value. Default NULL means same as input.
#' @param strict_return_type bool, default TRUE: fail on wrong return type, FALSE: convert to polars Null
#' @param allow_fail_eval bool, default FALSE: raise R fun error, TRUE: convert to polars Null
#'
#' @return [Series][Series_class]
#' @keywords Series
#' @aliases apply
#'
#' @examples
#' s = as_polars_series(letters[1:5], "ltrs")
#' f = \(x) paste(x, ":", as.integer(charToRaw(x)))
#' s$map_elements(f, pl$String)
#'
#' # same as
#' as_polars_series(sapply(s$to_r(), f), s$name)
Series_map_elements = function(
    fun, datatype = NULL, strict_return_type = TRUE, allow_fail_eval = FALSE) {
  .pr$Series$map_elements(
    self, fun, datatype, strict_return_type, allow_fail_eval
  ) |> unwrap("in $map_elements():")
}


#' Length of a Series
#'
#' @return A numeric value
#' @examples
#' as_polars_series(1:10)$len()
Series_len = use_extendr_wrapper

#' Lengths of Series memory chunks
#'
#' @return Numeric vector. Output length is the number of chunks, and the sum of
#' the output is equal to the length of the full Series.
#'
#' @examples
#' chunked_series = c(as_polars_series(1:3), as_polars_series(1:10))
#' chunked_series$chunk_lengths()
Series_chunk_lengths = use_extendr_wrapper

#' Get the number of chunks that this Series contains.
#'
#' @return A numeric value
#' @examples
#' s = as_polars_series(1:3)
#' s$n_chunks()
#'
#' # Concatenate Series with rechunk = TRUE
#' s2 = as_polars_series(4:6)
#' pl$concat(s, s2, rechunk = TRUE)$n_chunks()
#'
#' # Concatenate Series with rechunk = FALSE
#' pl$concat(s, s2, rechunk = FALSE)$n_chunks()
Series_n_chunks = use_extendr_wrapper

#' Append two Series
#'
#' @param other Series to append.
#' @param immutable Should the `other` Series be immutable? Default is `TRUE`.
#'
#' @details
#' If `immutable = FALSE`, the Series object will not behave as immutable. This
#' means that appending to this Series will affect any variable pointing to this
#' memory location. This will break normal scoping rules of R. Setting
#' `immutable = FALSE` is discouraged as it can have undesirable side effects
#' and cloning Polars Series is a cheap operation.
#'
#' @return [Series][Series_class]
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # default immutable behavior, s_imut and s_imut_copy stay the same
#' s_imut = as_polars_series(1:3)
#' s_imut_copy = s_imut
#' s_new = s_imut$append(as_polars_series(1:3))
#' s_new
#'
#' # the original Series didn't change
#' s_imut
#' s_imut_copy
#'
#' # enabling mutable behavior requires setting a global option
#' withr::with_options(
#'   list(polars.strictly_immutable = FALSE),
#'   {
#'     s_mut = as_polars_series(1:3)
#'     s_mut_copy = s_mut
#'     s_new = s_mut$append(as_polars_series(1:3), immutable = FALSE)
#'     print(s_new)
#'
#'     # the original Series also changed since it's mutable
#'     print(s_mut)
#'     print(s_mut_copy)
#'   }
#' )
Series_append = function(other, immutable = TRUE) {
  if (!isFALSE(immutable)) {
    c(self, other)
  } else {
    if (polars_options()$strictly_immutable) {
      stop(paste(
        "`append(other, immutable = FALSE)` breaks immutability. To enable mutable features run:\n",
        "`options(polars.strictly_immutable = FALSE)`"
      ))
    }
    unwrap(.pr$Series$append_mut(self, other), "in $append():")
    self
  }
}

#' Change name of Series
#'
#' @param name New name.
#' @usage Series_alias(name)
#' @return [Series][Series_class]
#' @examples
#' as_polars_series(1:3, name = "alice")$alias("bob")
Series_alias = use_extendr_wrapper

#' Reduce boolean Series with ANY
#'
#' @return A logical value
#' @examples
#' as_polars_series(c(TRUE, FALSE, NA))$any()
Series_any = function() {
  unwrap(.pr$Series$any(self), "in $any():")
}

#' Reduce Boolean Series with ALL
#'
#' @return A logical value
#' @examples
#' as_polars_series(c(TRUE, TRUE, NA))$all()
Series_all = function() {
  unwrap(.pr$Series$all(self), "in $all():")
}

#' Index of max value
#'
#' Note that this is 0-indexed.
#'
#' @return A numeric value
#' @examples
#' as_polars_series(c(5, 1))$arg_max()
Series_arg_max = use_extendr_wrapper

#' Index of min value
#'
#' Note that this is 0-indexed.
#'
#' @return A numeric value
#' @examples
#' as_polars_series(c(5, 1))$arg_min()
Series_arg_min = use_extendr_wrapper


#' Clone a Series
#'
#' This makes a very cheap deep copy/clone of an existing
#' [`Series`][Series_class]. Rarely useful as `Series` are nearly 100%
#' immutable. Any modification of a `Series` should lead to a clone anyways, but
#' this can be useful when dealing with attributes (see examples).
#'
#' @return [Series][Series_class]
#' @examples
#' df1 = as_polars_series(1:10)
#'
#' # Make a function to take a Series, add an attribute, and return a Series
#' give_attr = function(data) {
#'   attr(data, "created_on") = "2024-01-29"
#'   data
#' }
#' df2 = give_attr(df1)
#'
#' # Problem: the original Series also gets the attribute while it shouldn't!
#' attributes(df1)
#'
#' # Use $clone() inside the function to avoid that
#' give_attr = function(data) {
#'   data = data$clone()
#'   attr(data, "created_on") = "2024-01-29"
#'   data
#' }
#' df1 = as_polars_series(1:10)
#' df2 = give_attr(df1)
#'
#' # now, the original Series doesn't get this attribute
#' attributes(df1)
Series_clone = use_extendr_wrapper


#' Compute the sum of a Series
#'
#' @return A numeric value
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#' @examples
#' as_polars_series(c(1:2, NA, 3, 5))$sum() # a NA is dropped always
#' as_polars_series(c(1:2, NA, 3, NaN, 4, Inf))$sum() # NaN poisons the result
#' as_polars_series(c(1:2, 3, Inf, 4, -Inf, 5))$sum() # Inf-Inf is NaN
Series_sum = function() {
  unwrap(.pr$Series$sum(self), "in $sum():")
}

#' Compute the mean of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' as_polars_series(c(1:2, NA, 3, 5))$mean() # a NA is dropped always
#' as_polars_series(c(1:2, NA, 3, NaN, 4, Inf))$mean() # NaN carries / poisons
#' as_polars_series(c(1:2, 3, Inf, 4, -Inf, 5))$mean() # Inf-Inf is NaN
Series_mean = function() {
  unwrap(.pr$Series$mean(self), "in $mean():")
}

#' Compute the median of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' as_polars_series(c(1:2, NA, 3, 5))$median() # a NA is dropped always
#' as_polars_series(c(1:2, NA, 3, NaN, 4, Inf))$median() # NaN carries / poisons
#' as_polars_series(c(1:2, 3, Inf, 4, -Inf, 5))$median() # Inf-Inf is NaN
Series_median = function() {
  unwrap(.pr$Series$median(self), "in $median():")
}

#' Find the max of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' as_polars_series(c(1:2, NA, 3, 5))$max() # a NA is dropped always
#' as_polars_series(c(1:2, NA, 3, NaN, 4, Inf))$max() # NaN carries / poisons
#' as_polars_series(c(1:2, 3, Inf, 4, -Inf, 5))$max() # Inf-Inf is NaN
Series_max = function() {
  unwrap(.pr$Series$max(self), "in $max():")
}

#' Find the min of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' as_polars_series(c(1:2, NA, 3, 5))$min() # a NA is dropped always
#' as_polars_series(c(1:2, NA, 3, NaN, 4, Inf))$min() # NaN carries / poisons
#' as_polars_series(c(1:2, 3, Inf, 4, -Inf, 5))$min() # Inf-Inf is NaN
Series_min = function() {
  unwrap(.pr$Series$min(self), "in $min():")
}

#' Compute the variance of a Series
#'
#' @inheritParams DataFrame_var
#' @inherit Series_sum return
#' @examples
#' as_polars_series(1:10)$var()
Series_var = function(ddof = 1) {
  unwrap(.pr$Series$var(self, ddof), "in $var():")
}

#' Compute the standard deviation of a Series
#'
#' @inheritParams DataFrame_var
#' @inherit Series_sum return
#' @examples
#' as_polars_series(1:10)$std()
Series_std = function(ddof = 1) {
  unwrap(.pr$Series$std(self, ddof), "in $std():")
}

#' Check if the Series is sorted
#' @param descending Check if the Series is sorted in descending order.
#' @return A logical value
#' @seealso
#' Use [`$set_sorted()`][Series_set_sorted] to add a "sorted" flag to the Series
#' that could be used for faster operations later on.
#' @examples
#' as_polars_series(1:4)$sort()$is_sorted()
Series_is_sorted = function(descending = FALSE) {
  .pr$Series$is_sorted(self, descending) |> unwrap("in $is_sorted()")
}


#' Set a sorted flag on a Series
#'
#' @inheritParams Expr_set_sorted
#' @param in_place If `TRUE`, this will set the flag mutably and return `NULL`.
#' Remember to use `options(polars.strictly_immutable = FALSE)` before using
#' this parameter, otherwise an error will occur. If `FALSE` (default), it will
#' return a cloned Series with the flag.
#'
#' @details
#' Use [`$flags`][Series_class] to see the values of the sorted flags.
#'
#' @return A [Series][Series_class] with a flag
#' @examples
#' s = as_polars_series(1:4)$set_sorted()
#' s$flags
Series_set_sorted = function(..., descending = FALSE, in_place = FALSE) {
  if (isTRUE(in_place) && polars_options()$strictly_immutable) {
    Err_plain(
      "Using `in_place = TRUE` in `set_sorted()` breaks immutability. To enable mutable features run:\n",
      "`options(polars.strictly_immutable = FALSE)`"
    ) |>
      unwrap("in $set_sorted():")
  }

  if (!isTRUE(in_place)) {
    self = self$clone()
  }

  .pr$Series$set_sorted_mut(self, descending)
  if (isTRUE(in_place)) invisible(NULL) else invisible(self)
}


#' Sort a Series
#'
#' @inheritParams Series_set_sorted
#' @param descending A logical. If `TRUE`, sort in descending order.
#' @param nulls_last A logical. If `TRUE`, place `null` values last insead of first.
#' @param multithreaded A logical. If `TRUE`, sort using multiple threads.
#' @return [Series][Series_class]
#' @examples
#' as_polars_series(c(1.5, NA, 1, NaN, Inf, -Inf))$sort()
#' as_polars_series(c(1.5, NA, 1, NaN, Inf, -Inf))$sort(nulls_last = TRUE)
Series_sort = function(
    ..., descending = FALSE, nulls_last = FALSE, multithreaded = TRUE,
    in_place = FALSE) {
  uw = \(res) unwrap(res, "in $sort():")
  if (isTRUE(in_place) && polars_options()$strictly_immutable) {
    Err_plain(
      "in place sort breaks immutability, to enable mutable features run:\n",
      "`options(polars.strictly_immutable = FALSE)`"
    ) |>
      uw()
  }
  if (!isTRUE(in_place)) {
    self = self$clone()
  }

  .pr$Series$sort(self, descending, nulls_last, multithreaded) |>
    uw()
}

#' Convert Series to DataFrame
#' @return DataFrame
#'
#' @examples
#' # default will be a DataFrame with empty name
#' as_polars_series(1:4)$to_frame()
#'
#' as_polars_series(1:4, "bob")$to_frame()
Series_to_frame = function() {
  unwrap(.pr$Series$to_frame(self), "in $to_frame():")
}

#' Are two Series equal?
#'
#' This checks whether two Series are equal in values and in their name.
#'
#' @param other Series to compare with.
#' @param null_equal If `TRUE`, consider that null values are equal. Overridden
#' by `strict`.
#' @param strict If `TRUE`, do not allow similar DataType comparison. Overrides
#' `null_equal`.
#'
#' @return A logical value
#' @examples
#' as_polars_series(1:4)$equals(as_polars_series(1:4))
#'
#' # names are different
#' as_polars_series(1:4, "bob")$equals(as_polars_series(1:4))
#'
#' # nulls are different by default
#' as_polars_series(c(1:4, NA))$equals(as_polars_series(c(1:4, NA)))
#' as_polars_series(c(1:4, NA))$equals(as_polars_series(c(1:4, NA)), null_equal = TRUE)
#'
#' # datatypes are ignored by default
#' as_polars_series(1:4)$cast(pl$Int16)$equals(as_polars_series(1:4))
#' as_polars_series(1:4)$cast(pl$Int16)$equals(as_polars_series(1:4), strict = TRUE)
Series_equals = function(other, null_equal = FALSE, strict = FALSE) {
  .pr$Series$equals(self, other, null_equal, strict)
}

#' Rename a series
#'
#' @param name New name.
#' @param in_place Rename in-place, which breaks immutability. If `TRUE`, you
#'   need to run `options(polars.strictly_immutable = FALSE)` before, otherwise
#'   it will throw an error.
#'
#' @return [Series][Series_class]
#' @examples
#' as_polars_series(1:4, "bob")$rename("alice")
Series_rename = function(name, in_place = FALSE) {
  if (identical(self$name, name)) {
    return(self)
  } # no change needed
  if (in_place && polars_options()$strictly_immutable) {
    stop(paste(
      "in_place breaks \"objects are immutable\" which is expected in R.",
      "To enable mutable features run: `options(polars.strictly_immutable = FALSE)`"
    ))
  }

  if (!in_place) {
    self = self$clone()
  }

  .pr$Series$rename_mut(self, name)
  self
}


#' Duplicate and concatenate a series
#'
#' Note that this function doesn't exist in Python Polars.
#'
#' @param n Number of times to repeat
#' @param rechunk If `TRUE` (default), reallocate object in memory which can
#'   speed up some calculations. If `FALSE`, the Series will take less space in
#'   memory.
#' @return [Series][Series_class]
#'
#' @examples
#' as_polars_series(1:2, "bob")$rep(3)
Series_rep = function(n, rechunk = TRUE) {
  if (!is.numeric(n)) stop("n must be numeric")
  if (!is_scalar_bool(rechunk)) stop("rechunk must be a bool")
  unwrap(.pr$Series$rep(self, n, rechunk), "in $rep():")
}

in_DataType = function(l, rs) any(sapply(rs, function(r) l == r))

#' Check if the Series is numeric
#'
#' This checks whether the Series DataType is in `pl$numeric_dtypes`.
#'
#' @return A logical value
#'
#' @examples
#' as_polars_series(1:4)$is_numeric()
#' as_polars_series(c("a", "b", "c"))$is_numeric()
#' pl$numeric_dtypes
Series_is_numeric = function() {
  in_DataType(self$dtype, pl$numeric_dtypes)
}


#' Convert a Series to literal
#'
#' @return [Expr][Expr_class]
#' @examples
#' as_polars_series(list(1:1, 1:2, 1:3, 1:4))$
#'   print()$
#'   to_lit()$
#'   list$len()$
#'   sum()$
#'   cast(pl$dtypes$Int8)$
#'   to_series()
Series_to_lit = function() {
  pl$lit(self)
}

#' Count unique values in Series
#'
#' @return A numeric value
#' @examples
#' as_polars_series(c(1, 2, 1, 4, 4, 1, 5))$n_unique()
Series_n_unique = function() {
  unwrap(.pr$Series$n_unique(self), "in $n_unique():")
}

#' Return the element at the given index
#'
#' @param index Index of the item to return.
#'
#' @return A value of length 1
#'
#' @examples
#' s1 = pl$Series(values = 1)
#'
#' s1$item()
#'
#' s2 = pl$Series(values = 9:7)
#'
#' s2$cum_sum()$item(-1)
Series_item = function(index = NULL) {
  if (is.null(index)) {
    if (self$len() != 1) {
      Err_plain("Can only call $item() if the Series is of length 1.") |>
        unwrap("in $item():")
    }
    index = 0
  }
  if (length(index) > 1 || !is.numeric(index)) {
    Err_plain("`index` must be an integer of length 1.") |>
      unwrap("in $item():")
  }
  self$gather(index)$to_r()
}


#' Create an empty or n-row null-filled copy of the Series
#'
#' Returns a n-row null-filled Series with an identical schema. `n` can be
#' greater than the current number of values in the Series.
#'
#' @inheritParams DataFrame_clear
#'
#' @return A n-value null-filled Series with an identical schema
#'
#' @examples
#' s = pl$Series(name = "a", values = 1:3)
#'
#' s$clear()
#'
#' s$clear(n = 5)
Series_clear = function(n = 0) {
  if (length(n) > 1 || !is.numeric(n) || n < 0) {
    Err_plain("`n` must be an integer greater or equal to 0.") |>
      unwrap("in $clear():")
  }

  if (n == 0) {
    out = .pr$Series$clear(self) |>
      unwrap("in $clear():")
  }

  if (n > 0) {
    out = pl$Series(name = self$name, dtype = self$dtype)$extend_constant(NA, n)
  }

  out
}
