#' Set Ordering
#' @name ExprCat_set_ordering
#' @aliases expr_cat_set_ordering
#' @description Determine how this categorical series should be sorted.
#' @keywords ExprCat
#' @param ordering string either 'physical' or 'lexical'
#' - 'physical' -> Use the physical representation of the categories to
#'                 determine the order (default).
#' - 'lexical' -> Use the string values to determine the ordering.
#' @return bool: TRUE if equal
#' @examples
#' df = pl$DataFrame(
#'   cats = factor(c("z", "z", "k", "a", "b")),
#'   vals = c(3, 1, 2, 2, 3)
#' )$with_columns(
#'   pl$col("cats")$cat$set_ordering("physical")
#' )
#' df$select(pl$all()$sort())
ExprCat_set_ordering = function(ordering) {
  .pr$Expr$cat_set_ordering(self, ordering) |> unwrap("in $cat$set_ordering:")
}
# TODO use df$sort(c("cats","vals")) when implemented


#' Get the categories stored in this data type
#' @name ExprCat_get_categories
#' @keywords ExprCat
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
  .pr$Expr$cat_get_categories(self) |> unwrap("in $cat$get_categories:")
}
