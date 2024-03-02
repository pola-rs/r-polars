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


#' Wrap as Series
#' @noRd
#' @description input is either already a Series of will be passed to the Series constructor
#' @param x a Series or something-turned-into-Series
#' @return Series
wrap_s = function(x) {
  if (inherits(x, "RPolarsSeries")) x else pl$Series(x)
}

#' Create new Series
#' @description found in api as pl$Series named Series_constructor internally
#'
#' @param x any vector
#' @param name string
#' @name pl_Series
#' @keywords Series_new
#' @return Series
#' @aliases Series
#'
#' @examples
#' pl$Series(1:4)
pl_Series = function(x, name = NULL) {
  .pr$Series$new(x, name) |>
    unwrap("in pl$Series()")
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

#' add Series
#' @name Series_add
#' @description Series arithmetics
#' @param other Series or into Series
#' @return Series
#' @aliases add
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$add(11:13)
#' pl$Series(1:3)$add(pl$Series(11:13))
#' pl$Series(1:3)$add(1L)
#' 1L + pl$Series(1:3)
#' pl$Series(1:3) + 1L
Series_add = function(other) {
  .pr$Series$add(self, wrap_s(other))
}
#' @export
#' @rdname Series_add
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"+.RPolarsSeries" = function(s1, s2) wrap_s(s1)$add(s2)

#' sub Series
#' @name Series_sub
#' @description Series arithmetics
#' @param other Series or into Series
#' @return Series
#' @aliases sub
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$sub(11:13)
#' pl$Series(1:3)$sub(pl$Series(11:13))
#' pl$Series(1:3)$sub(1L)
#' 1L - pl$Series(1:3)
#' pl$Series(1:3) - 1L
Series_sub = function(other) {
  .pr$Series$sub(self, wrap_s(other))
}
#' @export
#' @rdname Series_sub
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"-.RPolarsSeries" = function(s1, s2) wrap_s(s1)$sub(s2)

#' div Series
#' @name Series_div
#' @description Series arithmetics
#' @param other Series or into Series
#' @return Series
#' @aliases div
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$div(11:13)
#' pl$Series(1:3)$div(pl$Series(11:13))
#' pl$Series(1:3)$div(1L)
#' 2L / pl$Series(1:3)
#' pl$Series(1:3) / 2L
Series_div = function(other) {
  .pr$Series$div(self, wrap_s(other))
}
#' @export
#' @rdname Series_div
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"/.RPolarsSeries" = function(s1, s2) wrap_s(s1)$div(s2)

#' mul Series
#' @name Series_mul
#' @description Series arithmetics
#' @param other Series or into Series
#' @return Series
#' @aliases mul
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$mul(11:13)
#' pl$Series(1:3)$mul(pl$Series(11:13))
#' pl$Series(1:3)$mul(1L)
#' 2L * pl$Series(1:3)
#' pl$Series(1:3) * 2L
Series_mul = function(other) {
  .pr$Series$mul(self, wrap_s(other))
}
#' @export
#' @rdname Series_mul
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"*.RPolarsSeries" = function(s1, s2) wrap_s(s1)$mul(s2)

#' rem Series
#' @description Series arithmetics, remainder
#' @param other Series or into Series
#' @return Series
#' @keywords Series
#' @aliases rem
#' @name Series_rem
#' @examples
#' pl$Series(1:4)$rem(2L)
#' pl$Series(1:3)$rem(pl$Series(11:13))
#' pl$Series(1:3)$rem(1L)
Series_rem = function(other) {
  .pr$Series$rem(self, wrap_s(other))
}

#' Compare Series
#' @name Series_compare
#' @description compare two Series
#' @param other A Series or something a Series can be created from
#' @param op the chosen operator a String either: 'equal', 'not_equal', 'lt', 'gt', 'lt_eq' or 'gt_eq'
#' @return Series
#' @aliases compare
#' @keywords  Series
#' @examples
#' pl$Series(1:5) == pl$Series(c(1:3, NA_integer_, 10L))
Series_compare = function(other, op) {
  other_s = wrap_s(other)
  s_len = self$len()
  o_len = other_s$len()
  if (
    s_len != o_len &&
      o_len != 1 &&
      s_len != 1
  ) {
    stop("in compare Series: not same length or either of length 1.")
  }
  .pr$Series$compare(self, wrap_s(other), op)
}
#' @export
#' @rdname Series_compare
#' @param s1 lhs Series
#' @param s2 rhs Series or any into Series
"==.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "equal"))
#' @export
#' @rdname Series_compare
"!=.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "not_equal"))
#' @export
#' @rdname Series_compare
"<.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "lt"))
#' @export
#' @rdname Series_compare
">.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "gt"))
#' @export
#' @rdname Series_compare
"<=.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "lt_eq"))
#' @export
#' @rdname Series_compare
">=.RPolarsSeries" = function(s1, s2) unwrap(wrap_s(s1)$compare(s2, "gt_eq"))


#' Get r vector/list
#' @description return R list (if polars Series is list)  or vector (any other polars Series type)
#'
#' @inheritParams DataFrame_to_data_frame
#'
#' @return R list or vector
#' @keywords Series
#' @details
#' Fun fact: Nested polars Series list must have same inner type, e.g. List(List(Int32))
#' Thus every leaf(non list type) will be placed on the same depth of the tree, and be the same type.
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @examples
#'
#' series_vec = pl$Series(letters[1:3])
#'
#' # Series_non_list
#' series_vec$to_r() # as vector because Series DataType is not list (is String)
#' series_vec$to_r_list() # implicit call as.list(), convert to list
#' series_vec$to_vector() # implicit call unlist(), same as to_r() as already vector
#'
#'
#' # make nested Series_list of Series_list of Series_Int32
#' # using Expr syntax because currently more complete translated
#' series_list = pl$DataFrame(list(a = c(1:5, NA_integer_)))$select(
#'   pl$col("a")$implode()$implode()$append(
#'     (
#'       pl$col("a")$head(2)$implode()$append(
#'         pl$col("a")$tail(1)$implode()
#'       )
#'     )$implode()
#'   )
#' )$get_column("a") # get series from DataFrame
#'
#' # Series_list
#' series_list$to_r() # as list because Series DataType is list
#' series_list$to_r_list() # implicit call as.list(), same as to_r() as already list
#' series_list$to_vector() # implicit call unlist(), append into a vector
Series_to_r = \(int64_conversion = polars_options()$int64_conversion) {
  unwrap(.pr$Series$to_r(self, int64_conversion), "in $to_r():")
}
# TODO replace list example with Series only syntax

#' @rdname Series_to_r
#' @name Series_to_vector
#' @description return R vector (implicit unlist)
#' @inheritParams DataFrame_to_data_frame
#' @return R vector
#' @keywords Series
#' series_vec = pl$Series(letters[1:3])
#' series_vec$to_vector()
Series_to_vector = \(int64_conversion = polars_options()$int64_conversion) {
  unlist(unwrap(.pr$Series$to_r(self, int64_conversion)), "in $to_vector():")
}

#' Alias to Series_to_vector (backward compatibility)
#' @return R vector
#' @noRd
Series_to_r_vector = Series_to_vector

#' @rdname Series_to_r
#' @name Series_to_r_list
#' @description return R list (implicit as.list)
#' @inheritParams DataFrame_to_data_frame
#' @return R list
#' @keywords Series
#' @examples #
Series_to_r_list = \(int64_conversion = polars_options()$int64_conversion) {
  as.list(unwrap(.pr$Series$to_r(self, int64_conversion)), "in $to_r_list():")
}


#' Value Counts as DataFrame
#'
#' @param sort bool, default TRUE: sort table by value; FALSE: random
#' @param parallel bool, default FALSE, process multithreaded. Likely faster
#' to have TRUE for a big Series. If called within an already multithreaded context
#' such calling apply on a GroupBy with many groups, then likely slightly faster to leave FALSE.
#'
#' @return DataFrame
#' @keywords Series
#' @name Series_value_count
#' @examples
#' pl$Series(iris$Species, "flower species")$value_counts()
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
#' @return Series
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


#' Series_len
#' @description Length of this Series.
#'
#' @return numeric
#' @docType NULL
#' @format NULL
#' @keywords Series
#' @aliases Series_len
#' @name Series_len
#'
#' @examples
#' pl$Series(1:10)$len()
#'
Series_len = use_extendr_wrapper

#' Lengths of Series memory chunks
#' @description Get the Lengths of Series memory chunks as vector.
#'
#' @return numeric vector. Length is number of chunks. Sum of lengths is equal to size of Series.
#' @keywords Series
#' @aliases chunk_lengths
#' @name Series_chunk_lengths
#'
#' @examples
#' chunked_series = c(pl$Series(1:3), pl$Series(1:10))
#' chunked_series$chunk_lengths()
Series_chunk_lengths = use_extendr_wrapper

#' append (default immutable)
#' @description append two Series, see details for mutability
#' @param other Series to append
#' @param immutable bool should append be immutable, default TRUE as mutable operations should
#' be avoided in plain R API's.
#'
#' @details if immutable = FLASE, the Series object will not behave as immutable. This mean
#' appending to this Series will affect any variable pointing to this memory location. This will break
#' normal scoping rules of R. Polars-clones are cheap. Mutable operations are likely never needed in
#' any sense.
#'
#' @return Series
#' @keywords Series
#' @aliases Series_append
#' @name Series_append
#' @examples
#'
#' # default immutable behavior, s_imut and s_imut_copy stay the same
#' s_imut = pl$Series(1:3)
#' s_imut_copy = s_imut
#' s_new = s_imut$append(pl$Series(1:3))
#' identical(s_imut$to_vector(), s_imut_copy$to_vector())
#'
#' # pypolars-like mutable behavior,s_mut_copy become the same as s_new
#' s_mut = pl$Series(1:3)
#' s_mut_copy = s_mut
#' # must deactivate this to allow to use immutable=FALSE
#' options(polars.strictly_immutable = FALSE)
#' s_new = s_mut$append(pl$Series(1:3), immutable = FALSE)
#' identical(s_new$to_vector(), s_mut_copy$to_vector())
Series_append = function(other, immutable = TRUE) {
  if (!isFALSE(immutable)) {
    c(self, other)
  } else {
    if (polars_options()$strictly_immutable) {
      stop(paste(
        "append(other , immutable=FALSE) breaks immutability, to enable mutable features run:\n",
        "`options(polars.strictly_immutable = FALSE)`"
      ))
    }
    unwrap(.pr$Series$append_mut(self, other), "in $append():")
    self
  }
}

#' Alias
#' @description Change name of Series
#' @param name a String as the new name
#' @return Series
#' @docType NULL
#' @format NULL
#' @keywords Series
#' @aliases alias
#' @name Series_alias
#' @usage Series_alias(name)
#' @examples
#' pl$Series(1:3, name = "alice")$alias("bob")
Series_alias = use_extendr_wrapper


#' Reduce Boolean Series with ANY
#'
#' @return bool
#' @keywords Series
#' @name Series_any
#' @examples
#' pl$Series(c(TRUE, FALSE, NA))$any()
Series_any = function() {
  unwrap(.pr$Series$any(self), "in $any():")
}

#' Reduce Boolean Series with ALL
#'
#' @return bool
#' @keywords Series
#' @aliases Series_all
#' @name Series_all
#' @examples
#' pl$Series(c(TRUE, TRUE, NA))$all()
Series_all = function() {
  unwrap(.pr$Series$all(self), "in $all():")
}

#' idx to max value
#'
#' @return bool
#' @docType NULL
#' @format NULL
#' @keywords Series
#' @aliases Series_arg_max
#' @name Series_arg_max
#' @examples
#' pl$Series(c(5, 1))$arg_max()
Series_arg_max = use_extendr_wrapper

#' idx to min value
#'
#' @return bool
#' @docType NULL
#' @format NULL
#' @keywords Series
#' @name Series_arg_min
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
#' @return Series
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


#' Sum
#' @description  Reduce Series with sum
#' @return R scalar value
#' @keywords Series
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to
#' Int64 before summing to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$sum() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$sum() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$sum() # Inf-Inf is NaN
Series_sum = function() {
  unwrap(.pr$Series$sum(self), "in $sum()")
}

#' Mean
#' @description  Reduce Series with mean
#' @return R scalar value
#' @keywords Series
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to
#' Int64 before meanming to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$mean() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$mean() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$mean() # Inf-Inf is NaN
Series_mean = function() {
  unwrap(.pr$Series$mean(self), "in $mean()")
}

#' Median
#' @description  Reduce Series with median
#' @return  R scalar value
#' @keywords Series
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to
#' Int64 before medianming to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$median() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$median() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$median() # Inf-Inf is NaN
Series_median = function() {
  unwrap(.pr$Series$median(self), "in $median()")
}

#' max
#' @description  Reduce Series with max
#' @return R scalar value
#' @keywords Series
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to
#' Int64 before maxming to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$max() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$max() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$max() # Inf-Inf is NaN
Series_max = function() {
  unwrap(.pr$Series$max(self), "in $max()")
}

#' min
#' @description  Reduce Series with min
#' @return R scalar value
#' @keywords Series
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to
#' Int64 before taking the min to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2, NA, 3, 5))$min() # a NA is dropped always
#' pl$Series(c(1:2, NA, 3, NaN, 4, Inf))$min() # NaN carries / poisons
#' pl$Series(c(1:2, 3, Inf, 4, -Inf, 5))$min() # Inf-Inf is NaN
Series_min = function() {
  unwrap(.pr$Series$min(self), "in $min()")
}

#' @title Var
#' @description Aggregate the columns of this Series to their variance values.
#' @keywords R scalar value
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `Series` object with applied aggregation.
#' @examples pl$Series(1:10)$var()
Series_var = function(ddof = 1) {
  unwrap(.pr$Series$var(self, ddof), "in $var():")
}

#' @title Std
#' @description Aggregate the columns of this Series to their standard deviation.
#' @keywords R scalar value
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `Series` object with applied aggregation.
#' @examples pl$Series(1:10)$std()
Series_std = function(ddof = 1) {
  unwrap(.pr$Series$std(self, ddof), "in $std():")
}


## wait until in included in next py-polars release
### contribute polars, exposee nulls_last option
#' is_sorted
#' @keywords Series
#' @param descending Check if the Series is sorted in descending order.
#' @return DataType
#' @aliases is_sorted
#' @details property sorted flags are not settable, use set_sorted
#' @examples
#' pl$Series(1:4)$sort()$is_sorted()
Series_is_sorted = function(descending = FALSE) {
  .pr$Series$is_sorted(self, descending) |> unwrap("in $is_sorted()")
}


#' Set sorted
#' @keywords Series
#' @param descending Sort the columns in descending order.
#' @param in_place if TRUE, will set flag mutably and return NULL. Remember to use
#' options(polars.strictly_immutable = FALSE) otherwise an error will be thrown. If FALSE
#' will return a cloned Series with set_flag which in the very most cases should be just fine.
#' @return Series invisible
#' @aliases Series_set_sorted
#' @examples
#' s = pl$Series(1:4)$set_sorted()
#' s$flags
Series_set_sorted = function(descending = FALSE, in_place = FALSE) {
  if (in_place && polars_options()$strictly_immutable) {
    stop(paste(
      "in_place set_sorted() breaks immutability, to enable mutable features run:\n",
      "`options(polars.strictly_immutable = FALSE)`"
    ))
  }

  if (!in_place) {
    self = self$clone()
  }

  .pr$Series$set_sorted_mut(self, descending)
  if (in_place) invisible(NULL) else invisible(self)
}

#' Sort this Series
#' @keywords Series
#' @aliases Series_sort
#' @param descending Sort in descending order.
#' @param nulls_last Place null values last instead of first.
#' @param in_place bool sort mutable in-place, breaks immutability
#' If true will throw an error unless this option has been set:
#' `options(polars.strictly_immutable = FALSE)`
#'
#' @return Series
#'
#' @examples
#' pl$Series(c(1, NA, NaN, Inf, -Inf))$sort()
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


#' Series to DataFrame
#' @name Series_to_frames
#' @return Series
#' @keywords Series
#' @aliases Series_to_frame
#' @format method
#'
#' @examples
#' pl$Series(1:4, "bob")$to_frame()
Series_to_frame = function() {
  unwrap(.pr$Series$to_frame(self), "in $to_frame():")
}


#' Are Series's equal?
#'
#' @param other Series to compare with
#' @param null_equal bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by strict.
#' @param strict bool if TRUE, do not allow similar DataType comparison. Overrides null_equal.
#'
#' @description  Check if series is equal with another Series.
#' @name Series_equals
#' @return bool
#' @keywords Series
#' @aliases equals
#' @format method
#'
#' @examples
#' pl$Series(1:4, "bob")$equals(pl$Series(1:4))
Series_equals = function(other, null_equal = FALSE, strict = FALSE) {
  .pr$Series$equals(self, other, null_equal, strict)
}

#' Rename a series
#'
#' @param name string the new name
#' @param in_place bool rename in-place, breaks immutability
#' If true will throw an error unless this option has been set:
#' `options(polars.strictly_immutable = FALSE)`
#'
#' @name Series_rename
#' @return bool
#' @keywords Series
#' @aliases rename
#' @format method
#'
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


#' duplicate and concatenate a series
#'
#' @param n number of times to repeat
#' @param rechunk bool default true, reallocate object in memory.
#' If FALSE the Series will take up less space, If TRUE calculations might be faster.
#' @name Series_rep
#' @return bool
#' @keywords Series
#' @aliases rep
#' @format method
#' @details  This function in not implemented in pypolars
#'
#' @examples
#' pl$Series(1:2, "bob")$rep(3)
Series_rep = function(n, rechunk = TRUE) {
  if (!is.numeric(n)) stop("n must be numeric")
  if (!is_scalar_bool(rechunk)) stop("rechunk must be a bool")
  unwrap(.pr$Series$rep(self, n, rechunk), "in $rep():")
}

in_DataType = function(l, rs) any(sapply(rs, function(r) l == r))

#' is_numeric
#' @description return bool whether series is numeric
#'
#' @return bool
#' @keywords Series
#' @aliases is_numeric
#' @format method
#' @details  true of series dtype is member of pl$numeric_dtypes
#'
#' @examples
#' pl$Series(1:4)$is_numeric()
#' pl$Series(c("a", "b", "c"))$is_numeric()
#' pl$numeric_dtypes
Series_is_numeric = function() {
  in_DataType(self$dtype, pl$numeric_dtypes)
}


#' Series to Literal
#' @description
#' convert Series to literal to perform modification and return
#' @keywords Series
#' @return Expr
#' @aliases to_lit
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
#' @description Return count of unique values in Series
#' @keywords Series
#' @return Expr
#' @examples
#' pl$Series(1:4)$n_unique()
Series_n_unique = function() {
  unwrap(.pr$Series$n_unique(self), "in $n_unique():")
}
