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
#' `$struct` stores all struct related methods.
#'
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @keywords Series
#'
#' @examples
#' # make a Series
#' s = pl$Series(c(1:3, 1L))
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
#' pl$Series(list(3:1, 1:2, NULL))$list$first()
#' pl$Series(c(1, NA, 2))$str$concat("-")
#'
#' s = pl$date_range(
#'   as.Date("2024-02-18"), as.Date("2024-02-24"),
#'   interval = "1d"
#' )$to_series()
#' s
#' s$dt$day()
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
      "SORTED_ASC" = .pr$Series$is_sorted_flag(self),
      "SORTED_DESC" = .pr$Series$is_sorted_reverse_flag(self)
    )

    # the width value given here doesn't matter, but pl$Array() must have one
    if (pl$same_outer_dt(self$dtype, pl$List()) ||
      pl$same_outer_dt(self$dtype, pl$Array(width = 1))) {
      out[["FAST_EXPLODE"]] = .pr$Series$fast_explode_flag(self)
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
    "to_series"
  )
  methods_diff = setdiff(ls(RPolarsExpr), ls(RPolarsSeries))

  for (method in setdiff(methods_diff, methods_exclude)) {
    if (!inherits(RPolarsExpr[[method]], "property")) {
      # make a modified Expr function
      new_f = eval(parse(text = paste0(r"(function() {
        f = RPolarsExpr$)", method, r"(

        # get the future args the new function will be called with
        # not using ... as this will erase tooltips and defaults
        # instead using sys.call/do.call
        scall = as.list(sys.call()[-1])

        df = self$to_frame()
        col_name = self$name
        self = pl$col(col_name)
        # Override `self` in `$.RPolarsExpr`
        environment(f) = environment()
        expr = do.call(f, scall)

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
#' @noRd
series_make_sub_ns = function(pl_series, .expr_make_sub_ns_fn) {
  df = pl_series$to_frame()
  # Override `self` in `$.RPolarsExpr`
  self = pl$col(pl_series$name) # nolint: object_usage_linter

  fns = .expr_make_sub_ns_fn(pl$col(pl_series$name))
  lapply(fns, \(f) {
    environment(f) = parent.frame(2L)
    new_f = function() {
      scall = as.list(sys.call()[-1])
      expr = do.call(f, scall)
      pcase(
        inherits(expr, "RPolarsExpr"), df$select(expr)$to_series(0),
        or_else = expr
      )
    }

    formals(new_f) = formals(f)
    new_f
  })
}

Series_arr = method_as_active_binding(\() series_make_sub_ns(self, expr_arr_make_sub_ns))

Series_bin = method_as_active_binding(\() series_make_sub_ns(self, expr_bin_make_sub_ns))

Series_cat = method_as_active_binding(\() series_make_sub_ns(self, expr_cat_make_sub_ns))

Series_dt = method_as_active_binding(\() series_make_sub_ns(self, expr_dt_make_sub_ns))

Series_list = method_as_active_binding(\() series_make_sub_ns(self, expr_list_make_sub_ns))

Series_str = method_as_active_binding(\() series_make_sub_ns(self, expr_str_make_sub_ns))

Series_struct = method_as_active_binding(\() series_make_sub_ns(self, expr_struct_make_sub_ns))


# TODO: change the arguments to be match to Python Polars before 0.16.0
#' Create new Series
#'
#' This function is a simple way to convert basic types of vectors provided by base R to
#' [the Series class object][Series_class].
#' For converting more types properly, use the generic function [as_polars_series()].
#' @param x any vector
#' @param name Name of the Series. If `NULL`, an empty string is used.
#' @param dtype One of [polars data type][pl_dtypes] or `NULL`.
#' If not `NULL`, that data type is used to [cast][Expr_cast] the Series created from the vector
#' to a specific data type internally.
#' @param ... Ignored.
#' @param nan_to_null If `TRUE`, `NaN` values contained in the Series are replaced to `null`.
#' Using the [`$fill_nan()`][Expr_fill_nan] method internally.
#' @return [Series][Series_class]
#' @aliases Series
#' @seealso
#' - [as_polars_series()]
#' @examples
#' # Constructing a Series by specifying name and values positionally:
#' s = pl$Series(1:3, "a")
#' s
#'
#' # Notice that the dtype is automatically inferred as a polars Int32:
#' s$dtype
#'
#' # Constructing a Series with a specific dtype:
#' s2 = pl$Series(1:3, "a", dtype = pl$Float32)
#' s2
pl_Series = function(
    x,
    name = NULL,
    dtype = NULL,
    ...,
    nan_to_null = FALSE) {
  uw = function(x) unwrap(x, "in pl$Series():")

  if (!is.null(dtype) && !isTRUE(is_polars_dtype(dtype))) {
    Err_plain("The dtype argument is not a valid Polars data type and cannot be converted into one.") |>
      uw()
  }

  out = .pr$Series$new(x, name) |>
    uw()

  if (!is.null(dtype)) {
    out = result(out$cast(dtype)) |>
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
#' @examples pl$Series(1:3)
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
#' pl$Series(1:3)$add(pl$Series(11:13))
#' pl$Series(1:3)$add(11:13)
#' pl$Series(1:3)$add(1L)
#'
#' pl$Series("a")$add("-z")
Series_add = function(other) {
  .pr$Series$add(self, as_polars_series(other))
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
#' pl$Series(1:3)$sub(11:13)
#' pl$Series(1:3)$sub(pl$Series(11:13))
#' pl$Series(1:3)$sub(1L)
#' 1L - pl$Series(1:3)
#' pl$Series(1:3) - 1L
Series_sub = function(other) {
  .pr$Series$sub(self, as_polars_series(other))
}


#' Divide Series
#'
#' Method equivalent of division operator `series / other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' pl$Series(1:3)$div(11:13)
#' pl$Series(1:3)$div(pl$Series(11:13))
#' pl$Series(1:3)$div(1L)
Series_div = function(other) {
  .pr$Series$div(self, as_polars_series(other))
}


#' Floor Divide Series
#'
#' Method equivalent of floor division operator `series %/% other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' pl$Series(1:3)$floor_div(11:13)
#' pl$Series(1:3)$floor_div(pl$Series(11:13))
#' pl$Series(1:3)$floor_div(1L)
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
#' pl$Series(1:3)$mul(11:13)
#' pl$Series(1:3)$mul(pl$Series(11:13))
#' pl$Series(1:3)$mul(1L)
Series_mul = function(other) {
  .pr$Series$mul(self, as_polars_series(other))
}


#' Modulo Series
#'
#' Method equivalent of modulo operator `series %% other`.
#' @inherit Series_sub params return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' pl$Series(1:4)$mod(2L)
#' pl$Series(1:3)$mod(pl$Series(11:13))
#' pl$Series(1:3)$mod(1L)
Series_mod = function(other) {
  .pr$Series$rem(self, as_polars_series(other))
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


#' Compare Series
#'
#' Check the (in)equality of two Series.
#'
#' @param other A Series or something a Series can be created from
#' @param op The chosen operator, must be one of `"equal"`, `"not_equal"`,
#' `"lt"`, `"gt"`, `"lt_eq"` or `"gt_eq"`
#' @return [Series][Series_class]
#' @examples
#' # We can either use `compare()`...
#' pl$Series(1:5)$compare(pl$Series(c(1:3, NA_integer_, 10L)), op = "equal")
#'
#' # ... or the more classic way
#' pl$Series(1:5) == pl$Series(c(1:3, NA_integer_, 10L))
Series_compare = function(other, op) {
  other_s = as_polars_series(other)
  s_len = self$len()
  o_len = other_s$len()
  if (
    s_len != o_len &&
      o_len != 1 &&
      s_len != 1
  ) {
    stop("in compare Series: not same length or either of length 1.")
  }
  .pr$Series$compare(self, as_polars_series(other), op) |>
    unwrap(paste0("in $compare() with operator `", op, "`:"))
}


# TODO: move to the other file
#' @export
#' @rdname Series_compare
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"==.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "equal")
#' @export
#' @rdname Series_compare
"!=.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "not_equal")
#' @export
#' @rdname Series_compare
"<.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "lt")
#' @export
#' @rdname Series_compare
">.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "gt")
#' @export
#' @rdname Series_compare
"<=.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "lt_eq")
#' @export
#' @rdname Series_compare
">=.RPolarsSeries" = function(s1, s2) as_polars_series(s1)$compare(s2, "gt_eq")


#' Convert Series to R vector or list
#'
#' `$to_r()` automatically returns an R vector or list based on the Polars
#' DataType. It is possible to force the output type by using `$to_vector()` or
#' `$to_r_list()`.
#'
#' @inheritParams DataFrame_to_data_frame
#'
#' @return R list or vector
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @examples
#' # Series with non-list type
#' series_vec = pl$Series(letters[1:3])
#'
#' series_vec$to_r() # as vector because Series DataType is not list (is String)
#' series_vec$to_r_list() # implicit call as.list(), convert to list
#' series_vec$to_vector() # implicit call unlist(), same as to_r() as already vector
#'
#'
#' # make a Series with nested lists
#' series_list = pl$Series(
#'   list(
#'     list(c(1:5, NA_integer_)),
#'     list(1:2, NA_integer_)
#'   )
#' )
#' series_list
#'
#' series_list$to_r() # as list because Series DataType is list
#' series_list$to_r_list() # implicit call as.list(), same as to_r() as already list
#' series_list$to_vector() # implicit call unlist(), append into a vector
Series_to_r = \(int64_conversion = polars_options()$int64_conversion) {
  unwrap(.pr$Series$to_r(self, int64_conversion), "in $to_r():")
}

#' @rdname Series_to_r
#' @inheritParams DataFrame_to_data_frame
Series_to_vector = \(int64_conversion = polars_options()$int64_conversion) {
  unlist(unwrap(.pr$Series$to_r(self, int64_conversion)), "in $to_vector():")
}

#' Alias to Series_to_vector (backward compatibility)
#' @return R vector
#' @noRd
Series_to_r_vector = Series_to_vector

#' @rdname Series_to_r
#' @inheritParams DataFrame_to_data_frame
Series_to_r_list = \(int64_conversion = polars_options()$int64_conversion) {
  as.list(unwrap(.pr$Series$to_r(self, int64_conversion)), "in $to_r_list():")
}

#' Count the occurrences of unique values
#'
#' @inheritParams Expr_value_counts
#'
#' @return DataFrame
#' @examples
#' pl$Series(iris$Species, name = "flower species")$value_counts()
Series_value_counts = function(sort = TRUE, parallel = FALSE) {
  unwrap(.pr$Series$value_counts(self, sort, parallel), "in $value_counts():")
}

#' Apply every value with an R fun
#' @description About as slow as regular non-vectorized R. Similar to using R sapply on a vector.
#' @param fun r function, should take a scalar value as input and return one.
#' @param datatype DataType of return value. Default NULL means same as input.
#' @param strict_return_type bool, default TRUE: fail on wrong return type, FALSE: convert to polars Null
#' @param allow_fail_eval bool, default FALSE: raise R fun error, TRUE: convert to polars Null
#'
#' @return [Series][Series_class]
#' @keywords Series
#' @aliases apply
#'
#' @examples
#' s = pl$Series(letters[1:5], "ltrs")
#' f = \(x) paste(x, ":", as.integer(charToRaw(x)))
#' s$map_elements(f, pl$String)
#'
#' # same as
#' pl$Series(sapply(s$to_r(), f), s$name)
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
#' pl$Series(1:10)$len()
Series_len = use_extendr_wrapper

#' Lengths of Series memory chunks
#'
#' @return Numeric vector. Output length is the number of chunks, and the sum of
#' the output is equal to the length of the full Series.
#'
#' @examples
#' chunked_series = c(pl$Series(1:3), pl$Series(1:10))
#' chunked_series$chunk_lengths()
Series_chunk_lengths = use_extendr_wrapper

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
#' s_imut = pl$Series(1:3)
#' s_imut_copy = s_imut
#' s_new = s_imut$append(pl$Series(1:3))
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
#'     s_mut = pl$Series(1:3)
#'     s_mut_copy = s_mut
#'     s_new = s_mut$append(pl$Series(1:3), immutable = FALSE)
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
#' pl$Series(1:3, name = "alice")$alias("bob")
Series_alias = use_extendr_wrapper

#' Reduce boolean Series with ANY
#'
#' @return A logical value
#' @examples
#' pl$Series(c(TRUE, FALSE, NA))$any()
Series_any = function() {
  unwrap(.pr$Series$any(self), "in $any():")
}

#' Reduce Boolean Series with ALL
#'
#' @return A logical value
#' @examples
#' pl$Series(c(TRUE, TRUE, NA))$all()
Series_all = function() {
  unwrap(.pr$Series$all(self), "in $all():")
}

#' Index of max value
#'
#' Note that this is 0-indexed.
#'
#' @return A numeric value
#' @examples
#' pl$Series(c(5, 1))$arg_max()
Series_arg_max = use_extendr_wrapper

#' Index of min value
#'
#' Note that this is 0-indexed.
#'
#' @return A numeric value
#' @examples
#' pl$Series(c(5, 1))$arg_min()
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
#' df1 = pl$Series(1:10)
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
#' df1 = pl$Series(1:10)
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
#' pl$Series(c(1:2, NA, 3, 5))$sum() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$sum() # NaN poisons the result
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$sum() # Inf-Inf is NaN
Series_sum = function() {
  unwrap(.pr$Series$sum(self), "in $sum():")
}

#' Compute the mean of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$mean() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$mean() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$mean() # Inf-Inf is NaN
Series_mean = function() {
  unwrap(.pr$Series$mean(self), "in $mean():")
}

#' Compute the median of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$median() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$median() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$median() # Inf-Inf is NaN
Series_median = function() {
  unwrap(.pr$Series$median(self), "in $median():")
}

#' Find the max of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$max() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$max() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$max() # Inf-Inf is NaN
Series_max = function() {
  unwrap(.pr$Series$max(self), "in $max():")
}

#' Find the min of a Series
#'
#' @inherit Series_sum details return
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$min() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$min() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$min() # Inf-Inf is NaN
Series_min = function() {
  unwrap(.pr$Series$min(self), "in $min():")
}

#' Compute the variance of a Series
#'
#' @inheritParams DataFrame_var
#' @inherit Series_sum return
#' @examples
#' pl$Series(1:10)$var()
Series_var = function(ddof = 1) {
  unwrap(.pr$Series$var(self, ddof), "in $var():")
}

#' Compute the standard deviation of a Series
#'
#' @inheritParams DataFrame_var
#' @inherit Series_sum return
#' @examples
#' pl$Series(1:10)$std()
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
#' pl$Series(1:4)$sort()$is_sorted()
Series_is_sorted = function(descending = FALSE) {
  .pr$Series$is_sorted(self, descending) |> unwrap("in $is_sorted()")
}


#' Set a sorted flag on a Series
#'
#' @inheritParams Expr_set_sorted
#' @param in_place If `TRUE`, this will set the flag mutably and return NULL.
#' Remember to use `options(polars.strictly_immutable = FALSE)` before using
#' this parameter, otherwise an error will occur. If `FALSE` (default), it will
#' return a cloned Series with the flag.
#'
#' @details
#' Use [`$flags`][Series_class] to see the values of the sorted flags.
#'
#' @return A [Series][Series_class] with a flag
#' @examples
#' s = pl$Series(1:4)$set_sorted()
#' s$flags
Series_set_sorted = function(descending = FALSE, in_place = FALSE) {
  if (in_place && polars_options()$strictly_immutable) {
    stop(paste(
      "Using `in_place = TRUE` in `set_sorted()` breaks immutability. To enable mutable features run:\n",
      "`options(polars.strictly_immutable = FALSE)`"
    ))
  }

  if (!in_place) {
    self = self$clone()
  }

  .pr$Series$set_sorted_mut(self, descending)
  if (in_place) invisible(NULL) else invisible(self)
}

#' Sort a Series
#'
#' @param descending Sort in descending order.
#' @inheritParams Expr_sort
#' @inheritParams Series_set_sorted
#'
#' @return [Series][Series_class]
#'
#' @examples
#' pl$Series(c(1.5, NA, 1, NaN, Inf, -Inf))$sort()
#' pl$Series(c(1.5, NA, 1, NaN, Inf, -Inf))$sort(nulls_last = TRUE)
Series_sort = function(descending = FALSE, nulls_last = FALSE, in_place = FALSE) {
  if (in_place && polars_options()$strictly_immutable) {
    stop(paste(
      "in_place sort breaks immutability, to enable mutable features run:\n",
      "`options(polars.strictly_immutable = FALSE)`"
    ))
  }
  if (!in_place) {
    self = self$clone()
  }

  .pr$Series$sort_mut(self, descending, nulls_last)
}

#' Convert Series to DataFrame
#' @return DataFrame
#'
#' @examples
#' # default will be a DataFrame with empty name
#' pl$Series(1:4)$to_frame()
#'
#' pl$Series(1:4, "bob")$to_frame()
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
#' pl$Series(1:4)$equals(pl$Series(1:4))
#'
#' # names are different
#' pl$Series(1:4, "bob")$equals(pl$Series(1:4))
#'
#' # nulls are different by default
#' pl$Series(c(1:4, NA))$equals(pl$Series(c(1:4, NA)))
#' pl$Series(c(1:4, NA))$equals(pl$Series(c(1:4, NA)), null_equal = TRUE)
#'
#' # datatypes are ignored by default
#' pl$Series(1:4)$cast(pl$Int16)$equals(pl$Series(1:4))
#' pl$Series(1:4)$cast(pl$Int16)$equals(pl$Series(1:4), strict = TRUE)
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
#' pl$Series(1:4, "bob")$rename("alice")
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
#' pl$Series(1:2, "bob")$rep(3)
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
#' pl$Series(1:4)$is_numeric()
#' pl$Series(c("a", "b", "c"))$is_numeric()
#' pl$numeric_dtypes
Series_is_numeric = function() {
  in_DataType(self$dtype, pl$numeric_dtypes)
}


#' Convert a Series to literal
#'
#' @return [Expr][Expr_class]
#' @examples
#' pl$Series(list(1:1, 1:2, 1:3, 1:4))$
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
#' pl$Series(c(1, 2, 1, 4, 4, 1, 5))$n_unique()
Series_n_unique = function() {
  unwrap(.pr$Series$n_unique(self), "in $n_unique():")
}
