#' Make a when-then-otherwise expression
#'
#' `when-then-otherwise` is similar to R [`ifelse()`]. Always initiated by a
#' `pl$when(<condition>)$then(<value if condition>)`, and optionally followed
#' by chaining one or more `$when(<condition>)$then(<value if condition>)`
#' statements.
#'
#' Chained when-then operations should be read like `if, else if, else if, ...` in R,
#' not as `if, if, if, ...`, i.e. the first condition that evaluates to `true` will
#' be picked.
#'
#' If none of the conditions are `true`, an optional
#' `$otherwise(<value if all statements are false>)` can be appended at the end.
#' If not appended, and none of the conditions are `true`, `null` will be returned.
#'
#' `RPolarsThen` objects and `RPolarsChainedThen` objects (returned by `$then()`)
#' stores the same methods as [Expr][Expr_class].
#' @name Expr_when_then_otherwise
#' @param ... [Expr][Expr_class] or something coercible to an Expr that returns a
#' boolian each row.
#' @param statement [Expr][Expr_class] or something coercible to
#' an [Expr][Expr_class] value to insert in `$then()` or `$otherwise()`.
#' A character vector is parsed as column names.
#' @return
#' - `pl$when()` returns a `When` object
#' - `<When>$then()` returns a `Then` object
#' - `<Then>$when()` returns a `ChainedWhen` object
#' - `<ChainedWhen>$then()` returns a `ChainedThen` object
#' - `$otherwise()` returns an [Expr][Expr_class] object.
#' @aliases when then otherwise When Then ChainedWhen ChainedThen
#' RPolarsWhen RPolarsThen RPolarsChainedWhen RPolarsChainedThen
#' @examples
#' df = pl$DataFrame(foo = c(1, 3, 4), bar = c(3, 4, 0))
#'
#' # Add a column with the value 1, where column "foo" > 2 and the value -1
#' # where it isn’t.
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$then(1)$otherwise(-1)
#' )
#'
#' # With multiple when-then chained:
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)
#'   $then(1)
#'   $when(pl$col("bar") > 2)
#'   $then(4)
#'   $otherwise(-1)
#' )
#'
#' # The `$otherwise` at the end is optional.
#' # If left out, any rows where none of the `$when()` expressions are evaluate to `true`,
#' # are set to `null`
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$then(1)
#' )
#'
#' # Pass multiple predicates, each of which must be met:
#' df$with_columns(
#'   val = pl$when(
#'     pl$col("bar") > 0,
#'     pl$col("foo") %% 2 != 0
#'   )
#'   $then(99)
#'   $otherwise(-1)
#' )
#'
#' # In `$then()`, a character vector is parsed as column names
#' df$with_columns(baz = pl$when(pl$col("foo") %% 2 == 1)$then("bar"))
#'
#' # So use `pl$lit()` to insert a string
#' df$with_columns(baz = pl$when(pl$col("foo") %% 2 == 1)$then(pl$lit("bar")))
pl_when = function(...) {
  unpack_bool_expr_result(...) |>
    and_then(.pr$When$new) |>
    unwrap("in pl$when():")
}


##  -------- all when-then-otherwise methods of state-machine ---------

#' @rdname Expr_when_then_otherwise
When_then = function(statement) {
  .pr$When$then(self, statement) |>
    unwrap("in $then():")
}

#' @rdname Expr_when_then_otherwise
Then_when = function(...) {
  unpack_bool_expr_result(...) |>
    and_then(\(condition) .pr$Then$when(self, condition)) |>
    unwrap("in $when():")
}

#' @rdname Expr_when_then_otherwise
Then_otherwise = function(statement) {
  .pr$Then$otherwise(self, statement) |>
    unwrap("in $otherwise():")
}

#' @rdname Expr_when_then_otherwise
ChainedWhen_then = function(statement) {
  .pr$ChainedWhen$then(self, statement) |>
    unwrap("in $then():")
}

#' @rdname Expr_when_then_otherwise
ChainedThen_when = function(...) {
  unpack_bool_expr_result(...) |>
    and_then(\(condition) .pr$ChainedThen$when(self, condition)) |>
    unwrap("in $when():")
}

#' @rdname Expr_when_then_otherwise
ChainedThen_otherwise = function(statement) {
  .pr$ChainedThen$otherwise(self, statement) |>
    unwrap("in $otherwise():")
}


## Methods from Expr

#' Function to add Expr methods to Then and ChainedThen
#'
#' Executed in zzz.R
#' @noRd
add_expr_methods_to_then = function(then_like_class) {
  methods_exclude = c()
  methods_diff = setdiff(ls(RPolarsExpr), ls(then_like_class))

  for (method in setdiff(methods_diff, methods_exclude)) {
    if (!inherits(RPolarsExpr[[method]], "property")) {
      # make a modified Expr function
      new_f = eval(parse(text = paste0(r"(function() {
        f = RPolarsExpr$)", method, r"(

        # get the future args the new function will be called with
        # not using ... as this will erase tooltips and defaults
        # instead using sys.call/do.call
        scall = as.list(sys.call()[-1])

        self = self$otherwise(pl$lit(NULL))
        # Override `self` in `$.RPolarsExpr`
        environment(f) = environment()

        do.call(f, scall)
      })")))
      # set new_method to have the same formals arguments
      formals(new_f) = formals(method, RPolarsExpr)
      then_like_class[[method]] = new_f
    }
  }
}

### Sub namespaces

#' Make sub namespace of Then from Expr sub namespace
#' @noRd
then_make_sub_ns = function(then_like_object, .expr_make_sub_ns_fn) {
  arr = .expr_make_sub_ns_fn(then_like_object$otherwise(pl$lit(NULL)))
  lapply(arr, \(f) {
    \(...) f(...)
  })
}


Then_arr = ChainedThen_arr = method_as_active_binding(\() then_make_sub_ns(self, expr_arr_make_sub_ns))

Then_bin = ChainedThen_bin = method_as_active_binding(\() then_make_sub_ns(self, expr_bin_make_sub_ns))

Then_cat = ChainedThen_cat = method_as_active_binding(\() then_make_sub_ns(self, expr_cat_make_sub_ns))

Then_dt = ChainedThen_dt = method_as_active_binding(\() then_make_sub_ns(self, expr_dt_make_sub_ns))

Then_list = ChainedThen_list = method_as_active_binding(\() then_make_sub_ns(self, expr_list_make_sub_ns))

Then_meta = ChainedThen_meta = method_as_active_binding(\() then_make_sub_ns(self, expr_meta_make_sub_ns))

Then_name = ChainedThen_name = method_as_active_binding(\() then_make_sub_ns(self, expr_name_make_sub_ns))

Then_str = ChainedThen_str = method_as_active_binding(\() then_make_sub_ns(self, expr_str_make_sub_ns))

Then_struct = ChainedThen_struct = method_as_active_binding(\() then_make_sub_ns(self, expr_struct_make_sub_ns))


##  -------- print methods ---------

#' @export
print.RPolarsWhen = function(x, ...) {
  print("When")
  invisible(x)
}


#' @export
print.RPolarsThen = function(x, ...) {
  print("Then")
  invisible(x)
}


#' @export
print.RPolarsChainedWhen = function(x, ...) {
  print("ChainedWhen")
  invisible(x)
}


#' @export
print.RPolarsChainedThen = function(x, ...) {
  print("ChainedThen")
  invisible(x)
}


##  -------- DollarNames methods ---------

#' @export
.DollarNames.RPolarsWhen = function(x, pattern = "") {
  paste0(ls(RPolarsWhen, pattern = pattern), completion_symbols$method)
}


#' @export
.DollarNames.RPolarsThen = function(x, pattern = "") {
  paste0(ls(RPolarsThen, pattern = pattern), completion_symbols$method)
}


#' @export
.DollarNames.RPolarsChainedThen = function(x, pattern = "") {
  paste0(ls(RPolarsChainedThen, pattern = pattern), completion_symbols$method)
}


#' @export
.DollarNames.RPolarsChainedWhen = function(x, pattern = "") {
  paste0(ls(RPolarsChainedWhen, pattern = pattern), completion_symbols$method)
}
