#' Set Ordering
#'
#' Determine how this categorical series should be sorted.
#'
#' @param ordering string either 'physical' or 'lexical'
#' - `"physical"`: use the physical representation of the categories to
#'   determine the order (default).
#' - `"lexical"`: use the string values to determine the order.
#'
#' @return An Expr of datatype Categorical
#' @examples
#' df = pl$DataFrame(
#'   cats = factor(c("z", "z", "k", "a", "b")),
#'   vals = c(3, 1, 2, 2, 3)
#' )
#'
#' # sort by the string value of categories
#' df$with_columns(
#'   pl$col("cats")$cat$set_ordering("lexical")
#' )$sort("cats", "vals")
#'
#' # sort by the underlying value of categories
#' df$with_columns(
#'   pl$col("cats")$cat$set_ordering("physical")
#' )$sort("cats", "vals")
ExprCat_set_ordering = function(ordering) {
  .pr$Expr$cat_set_ordering(self, ordering) |>
    unwrap("in $cat$set_ordering:")
}


#' Get the categories stored in this data type
#'
#' @return A polars DataFrame with the categories for each categorical Series.
#' @examples
#' df = pl$DataFrame(
#'   cats = factor(c("z", "z", "k", "a", "b")),
#'   vals = factor(c(3, 1, 2, 2, 3))
#' )
#' df
#'
#' df$select(
#'   pl$col("cats")$cat$get_categories()
#' )
#' df$select(
#'   pl$col("vals")$cat$get_categories()
#' )
ExprCat_get_categories = function() {
  .pr$Expr$cat_get_categories(self)
}
