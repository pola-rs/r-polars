#' Make a then-when-otherwise expression
#'
#' `when-then-otherwise` is similar to R [`ifelse()`]. This has to start with
#' `pl$when(<condition>)$then(<value if condition>)`. From there, it can:
#' * be chained to an `$otherwise()` statement that specifies the Expr to apply
#'   to the rows where the condition is `FALSE`;
#' * or be chained to other `$when()$then()` to specify more cases, and then use
#'   `$otherwise()` when you arrive at the end of your chain.
#' Note that one difference with the Python implementation is that we *must*
#' end the chain with an `$otherwise()` statement.
#'
#' If you want to use the class of those `when-then-otherwise` statement, note
#' that there are 6 different classes corresponding to the different steps:
#'
#' * `pl$when()`returns a `When` object,
#' * `pl$then()`returns a `Then` object,
#' * `<Then>$otherwise()`returns an [Expression][Expr_class] object,
#' * `<Then>$when()`returns a `ChainedWhen` object,
#' * `<ChainedWhen>$then()`returns a `ChainedThen` object,
#' * `<ChainedThen>$otherwise()`returns an [Expression][Expr_class] object.
#'
#' @name Expr_when_then_otherwise
#' @param ... Expr or something coercible to an Expr into a boolean mask to
#'   branch by.
#' @param statement Expr or something coercible to an Expr value to insert in
#'   when() or otherwise(). Strings interpreted as column.
#' @return an polars object, see details.
#' @aliases when then otherwise When Then ChainedWhen ChainedThen
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
#' # Pass multiple predicates, each of which must be met:
#' df$with_columns(
#'   val = pl$when(
#'     pl$col("bar") > 0,
#'     pl$col("foo") %% 2 != 0
#'   )
#'   $then(99)
#'   $otherwise(-1)
#' )
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


##  -------- print methods ---------

#' print When
#' @param x When object
#' @param ... not used
#' @noRd
#'
#' @return self
#' @export
#' @examples
#' print(pl$when(pl$col("a") > 2))
print.RPolarsWhen = function(x, ...) {
  print("When")
  invisible(x)
}

#' print Then
#' @param x When object
#' @param ... not used
#' @keywords WhenThen internal
#' @return self
#' @export
#' @examples
#' print(pl$when(pl$col("a") > 2)$then(pl$lit("more than two")))
print.RPolarsThen = function(x, ...) {
  print("Then")
  invisible(x)
}


#' print ChainedWhen
#' @param x ChainedWhen object
#' @param ... not used
#' @keywords WhenThen internal
#' @return self
#' @export
#' @examples
#' #
#' print(pl$when(pl$col("a") > 2)$then(pl$lit("more than two"))$when(pl$col("b") < 5))
print.RPolarsChainedWhen = function(x, ...) {
  print("ChainedWhen")
  invisible(x)
}

#' print ChainedThen
#' @param x ChainedThen object
#' @param ... not used
#' @keywords WhenThen internal
#' @return self
#' @export
#' @examples
#' print(pl$when(pl$col("a") > 2)$then(pl$lit("more than two"))$when(pl$col("b") < 5))
print.RPolarsChainedThen = function(x, ...) {
  print("ChainedThen")
  invisible(x)
}


##  -------- DollarNames methods ---------

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x When
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsWhen = function(x, pattern = "") {
  paste0(ls(RPolarsWhen, pattern = pattern), completion_symbols$method)
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x Then
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsThen = function(x, pattern = "") {
  paste0(ls(RPolarsThen, pattern = pattern), completion_symbols$method)
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x ChainedWhen
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsChainedThen = function(x, pattern = "") {
  paste0(ls(RPolarsChainedThen, pattern = pattern), completion_symbols$method)
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x ChainedWhen
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsChainedWhen = function(x, pattern = "") {
  paste0(ls(RPolarsChainedWhen, pattern = pattern), completion_symbols$method)
}
