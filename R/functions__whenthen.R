#' when-then-otherwise Expr
#' @name Expr_when_then_otherwise
#' @description Start a “when, then, otherwise” expression.
#' @keywords Expr
#' @param ... Into Expr into a boolean mask to branch by.
#' @param statement Into Expr value to insert in when() or otherwise().
#' Strings interpreted as column.
#' @return Expr
#' @aliases when then otherwise When Then ChainedWhen ChainedThen
#' @details
#'
#' when-then-otherwise is similar to R `ifelse()`. `pl$when(condition)` takes a condition as input
#' this will an polars `<Expr>` which renderes to a Boolean column. Then it is chained with a
#' `$then(statement)` when arg statement is an `<Expr>` which produces a column with values if
#' idealy all Boolean are true. Then finally an `$otherwise(statement)` with values if false.
#' `$otherwise()` returns an `Expr` which will mix the `$then()` statement with the `$otherwise()`
#' as given by the when-condition.
#'
#' State-machine details below. The state machine consists of 4 classes `<When>`, `<Then>`,
#' `<ChainedWhen>` & `<ChainedThen>` and a starter function `pl$when()` and the final expression
#' class  a polars `<Expr>`.
#'
#' `pl$when`return a `<When>` object.
#' `pl$when(condition) -> <When>`
#'
#'  `<When>` has a single public method `$then(statement)`
#'  `<When>$then(statement) -> <Then>`
#'
#'  #the follow objects and methods are
#'  `<Then>$when(condition) -> <ChainedWhen>`
#'  `<Then>$otherwise(statement) -> <Expr>`
#'  `<ChainedWhen>$then(statement) -> <ChainedThen>`
#'  `<ChainedThen>$when(condition) -> <Expr>`
#'  `<ChainedThen>$otherwise(statement) -> <Expr>`
#'
#'  This statemachine ensures only syntacticly allowed methods are availble at any specific place in
#'  a nested when-then-otherwise expression.
#'
#' @examples
#' df = pl$DataFrame(foo = c(1, 3, 4), bar = c(3, 4, 0))
#'
#' # Add a column with the value 1, where column "foo" > 2 and the value -1 where it isn’t.
#' df$with_columns(
#'   pl$when(pl$col("foo") > 2)$then(1)$otherwise(-1)$alias("val")
#' )
#'
#' # With multiple when, thens chained:
#' df$with_columns(
#'   pl$when(pl$col("foo") > 2)
#'   $then(1)
#'   $when(pl$col("bar") > 2)
#'   $then(4)
#'   $otherwise(-1)
#'   $alias("val")
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

When_then = function(statement) {
  .pr$When$then(self, statement) |>
    unwrap("in $then():")
}

Then_when = function(...) {
  unpack_bool_expr_result(...) |>
    and_then(\(condition) .pr$Then$when(self, condition)) |>
    unwrap("in $when():")
}

Then_otherwise = function(statement) {
  .pr$Then$otherwise(self, statement) |>
    unwrap("in $otherwise():")
}

ChainedWhen_then = function(statement) {
  .pr$ChainedWhen$then(self, statement) |>
    unwrap("in $then():")
}

ChainedThen_when = function(...) {
  unpack_bool_expr_result(...) |>
    and_then(\(condition) .pr$ChainedThen$when(self, condition)) |>
    unwrap("in $when():")
}

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
  paste0(ls(RPolarsWhen, pattern = pattern), "()")
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
  paste0(ls(RPolarsThen, pattern = pattern), "()")
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
  paste0(ls(RPolarsChainedThen, pattern = pattern), "()")
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
  paste0(ls(RPolarsChainedWhen, pattern = pattern), "()")
}
