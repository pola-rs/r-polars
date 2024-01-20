#' Add a suffix to a column name
#'
#' @param suffix Suffix to be added to column name(s)
#' @return Expr
#' @seealso
#' [`$prefix()`][ExprName_prefix] to add a prefix
#'
#' @examples
#' dat = pl$DataFrame(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$suffix("_foo"),
#'   pl$col("cyl", "drat")$name$suffix("_bar")
#' )
ExprName_suffix = function(suffix) {
  .pr$Expr$name_suffix(self, suffix) |>
    unwrap("in $name$suffix():")
}

#' Add a prefix to a column name
#'
#' @param prefix Prefix to be added to column name(s)
#' @return Expr
#' @seealso
#' [`$suffix()`][ExprName_suffix] to add a suffix
#'
#' @examples
#' dat = pl$DataFrame(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$prefix("name_"),
#'   pl$col("cyl", "drat")$name$prefix("bar_")
#' )
ExprName_prefix = function(prefix) {
  .pr$Expr$name_prefix(self, prefix) |>
    unwrap("in $name$prefix():")
}

# TODO contribute pypolars keep_name example does not showcase an example where the name changes

#' Keep the original root name of the expression.
#'
#' @return Expr
#'
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(pl$col("alice")$alias("bob")$name$keep())
ExprName_keep = function() {
  .pr$Expr$name_keep(self) |>
    unwrap("in $name$keep():")
}

# TODO contribute polars, $name$map unwrap user function errors instead of passing them back

#' Map alias of expression with an R function
#'
#' Rename the output of an expression by mapping a function over the root name.
#'
#' @param fun an R function which takes a string as input and return a string
#' @return Expr
#'
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(
#'   pl$col("alice")$alias("joe_is_not_root")$name$map(\(x) paste0(x, "_and_bob"))
#' )
ExprName_map = function(fun) {
  if (
    !getOption("polars.no_messages") &&
      !exists(".warn_map_alias", envir = runtime_state)
  ) {
    assign(".warn_map_alias", 1L, envir = runtime_state)
    # it does not seem map alias is executed multi-threaded but rather immediately during building lazy query
    # if ever crashing, any lazy method like select, filter, with_columns must use something like filter_with_r_func_support()
    message("$name$map() function is experimentally without some thread-safeguards, please report any crashes") # TODO resolve
  }
  if (!is.function(fun)) pstop(err = "$name$map() fun must be a function")
  if (length(formals(fun)) == 0) pstop(err = "$name$map() fun must take at least one parameter")
  .pr$Expr$name_map(self, fun) |>
    unwrap("in $name$map():")
}


#' Make the root column name lowercase
#'
#' Due to implementation constraints, this method can only be called as the last
#' expression in a chain.
#'
#' @return Expr
#'
#' @examples
#' pl$DataFrame(Alice = 1:3)$with_columns(pl$col("Alice")$name$to_lowercase())
ExprName_to_lowercase = function() {
  .pr$Expr$name_to_lowercase(self) |>
    unwrap("in $name$to_lowercase():")
}

#' Make the root column name uppercase
#'
#' @inherit ExprName_to_lowercase description
#'
#' @return Expr
#'
#' @examples
#' pl$DataFrame(Alice = 1:3)$with_columns(pl$col("Alice")$name$to_uppercase())
ExprName_to_uppercase = function() {
  .pr$Expr$name_to_uppercase(self) |>
    unwrap("in $name$to_uppercase():")
}
