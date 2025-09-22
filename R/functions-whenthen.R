#'' Start a when-then-otherwise expression
#'
#' @description
#' Always initiated with a `pl$when()$then()` and optionally followed by
#' chaining one or more `$when()$then()` statements.
#'
#' An optional `$otherwise()` can be appended at the end. If not declared, a
#' default of `$otherwise(NA)` is used.
#'
#' Similar to [pl$coalesce][pl__coalesce], the value from the first condition
#' that evaluates to `TRUE` will be picked. If all conditions are `FALSE`, the
#' `otherwise` value is picked.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Condition(s) that must be met
#' in order to apply the subsequent statement. Accepts one or more boolean
#' expressions, which are implicitly combined with `&`.
#'
#' @details
#' Polars computes all expressions passed to when-then-otherwise in parallel and
#' filters afterwards. This means each expression must be valid on its own,
#' regardless of the conditions in the when-then-otherwise chain.
#'
#' String inputs e.g. `when("string")`, `then("string")` or `otherwise("string")`
#' are parsed as column names. [pl$lit()][pl__lit] can be used to create string
#' values.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' # Below we add a column with the value 1, where column "foo" > 2 and the
#' # value 1 + column "bar" where it isn’t.
#' df <- pl$DataFrame(foo = c(1, 3, 4), bar = c(3, 4, 0))
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$then(1)$otherwise(1 + pl$col("bar"))
#' )
#'
#' # Note that when-then always executes all expressions.
#' # The results are folded left to right, picking the then value from the first
#' # when condition that is true.
#' # If no when condition is true the otherwise value is picked.
#' df$with_columns(
#'   when = pl$col("foo") > 2,
#'   then = 1,
#'   otherwise = 1 + pl$col("bar")
#' )$with_columns(
#'   val = pl$when("when")$then("then")$otherwise("otherwise")
#' )
#'
#' # Strings are parsed as column names
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$then("foo")$otherwise("bar")
#' )
#'
#' # Use pl$lit() to create literal values
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$then(pl$lit("foo"))$otherwise(pl$lit("bar"))
#' )
#'
#' # Multiple when-then statements can be chained.
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2)$
#'     then(1)$
#'     when(pl$col("bar") > 2)$
#'     then(4)$
#'     otherwise(-1)
#' )
#'
#' # The otherwise statement is optional and defaults to $otherwise(NA) if not given.
#' # This idiom is commonly used to null out values.
#' df$with_columns(pl$when(pl$col("foo") == 3)$then("bar"))
#'
#' # Multiple predicates passed to when are combined with &
#' df$with_columns(
#'   val = pl$when(pl$col("foo") > 2, pl$col("bar") < 3)$
#'     then(pl$lit("Yes"))$
#'     otherwise(pl$lit("No"))
#' )
#'
#' # Structs can be used as a way to return multiple values.
#' # Here we swap the "foo" and "bar" values when "foo" is greater than 2.
#' df$with_columns(
#'   pl$when(pl$col("foo") > 2)$
#'     then(pl$struct(foo = "bar", bar = "foo"))$
#'     otherwise(pl$struct("foo", "bar"))$
#'     struct$
#'     unnest()
#' )
#'
#' # The output name of a when-then expression comes from the first then branch.
#' # Here we try to set all columns to 0 if any column contains a value less than 2.
#' tryCatch(
#'   df$with_columns(
#'     pl$when(pl$any_horizontal(pl$all() < 2))$then(0)$otherwise(pl$all())
#'   ),
#'   error = function(e) e
#' )
#'
#' # name$keep() could be used to give preference to the column expression.
#' df$with_columns(
#'   pl$when(pl$any_horizontal(pl$all() < 2))$then(0)$otherwise(pl$all())$name$keep()
#' )
#'
#' # The logic could also be changed to move the column expression inside then.
#' df$with_columns(
#'   pl$when(pl$any_horizontal(pl$all() < 2)$not())$then(pl$all())$otherwise(0)
#' )
pl__when <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    when() |>
    wrap()
}
