#' Add a suffix to a column name
#' @keywords Expr
#'
#' @param suffix Suffix to be added to column name(s)
#' @name ExprName_suffix
#' @rdname ExprName_suffix
#' @return Expr
#' @aliases suffix
#' @seealso
#' [`$prefix()`][ExprName_prefix] to add a prefix
#' @examples
#' dat = pl$DataFrame(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$suffix("_foo"),
#'   pl$col("cyl", "drat")$name$suffix("_bar")
#' )
ExprName_suffix = function(suffix) {
  .pr$Expr$name_suffix(self, suffix)
}

#' Add a prefix to a column name
#' @keywords Expr
#'
#' @param prefix Prefix to be added to column name(s)
#' @name ExprName_prefix
#' @rdname ExprName_prefix
#' @return Expr
#' @aliases prefix
#' @seealso
#' [`$suffix()`][ExprName_suffix] to add a suffix
#' @examples
#' dat = pl$DataFrame(mtcars)
#'
#' dat$select(
#'   pl$col("mpg"),
#'   pl$col("mpg")$name$prefix("name_"),
#'   pl$col("cyl", "drat")$name$prefix("bar_")
#' )
ExprName_prefix = function(prefix) {
  .pr$Expr$name_prefix(self, prefix)
}

# TODO contribute pypolars keep_name example does not showcase an example where the name changes
#' Keep the original root name of the expression.
#'
#' @keywords Expr
#' @return Expr
#' @aliases keep_name
#' @name ExprName_keep
#' @docType NULL
#' @format NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(pl$col("alice")$alias("bob")$name$keep())
ExprName_keep = "use_extendr_wrapper"

# TODO contribute polars, $name$map unwrap user function errors instead of passing them back
#' Map alias of expression with an R function
#'
#' @param fun an R function which takes a string as input and return a string
#'
#' @description Rename the output of an expression by mapping a function over the root name.
#' @keywords Expr
#' @return Expr
#' @name ExprName_map
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(
#'   pl$col("alice")$alias("joe_is_not_root")$name$map(\(x) paste0(x, "_and_bob"))
#' )
ExprName_map = function(fun) {
  if (
    !polars_optenv$no_messages &&
    !exists(".warn_map_alias", envir = runtime_state)
  ) {
    assign(".warn_map_alias", 1L, envir = runtime_state)
    # it does not seem map alias is executed multi-threaded but rather immediately during building lazy query
    # if ever crashing, any lazy method like select, filter, with_columns must use something like filter_with_r_func_support()
    message("$name$map() function is experimentally without some thread-safeguards, please report any crashes") # TODO resolve
  }
  if (!is.function(fun)) pstop(err = "$name$map() fun must be a function")
  if (length(formals(fun)) == 0) pstop(err = "$name$map() fun must take at least one parameter")
  .pr$Expr$name$map(self, fun)
}
