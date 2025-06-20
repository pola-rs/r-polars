# The env for storing lazygroupby methods
polars_lazygroupby__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRLazyGroupBy <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$lgb <- x

  class(self) <- c("polars_lazy_group_by", "polars_object")
  self
}

#' Compute aggregations for each group of a group by operation
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Aggregations to compute for
#' each group of the group by operation. Accepts expression input. Strings are
#' parsed as column names.
#'
#' @inherit as_polars_lf return
#' @examples
#' # Compute the aggregation of the columns for each group.
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#' lf$group_by("a")$agg(pl$col("b"), pl$col("c"))$collect()
#'
#' # Compute the sum of a column for each group.
#' lf$group_by("a")$agg(pl$col("b")$sum())$collect()
#'
#' # Compute multiple aggregates at once by passing a list of expressions.
#' lf$group_by("a")$agg(pl$sum("b"), pl$col("c")$mean())$collect()
#'
#' # Use keyword arguments to easily name your expression inputs.
#' lf$group_by("a")$agg(
#'   b_sum = pl$sum("b"),
#'   c_mean_squared = (pl$col("c") ** 2)$mean()
#' )$collect()
lazygroupby__agg <- function(...) {
  exprs <- parse_into_list_of_expressions(...)
  self$lgb$agg(exprs) |>
    wrap()
}

#' Get the first `n` rows of each group
#'
#' @inheritParams lazyframe__head
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   letters = c("c", "c", "a", "c", "a", "b"),
#'   nrs = 1:6
#' )
#' lf$collect()
#'
#' lf$group_by("letters")$head(2)$sort("letters")$collect()
lazygroupby__head <- function(n = 5) {
  self$lgb$head(n) |>
    wrap()
}

#' Get the last `n` rows of each group
#'
#' @inheritParams lazyframe__tail
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   letters = c("c", "c", "a", "c", "a", "b"),
#'   nrs = 1:6
#' )
#' lf$collect()
#'
#' lf$group_by("letters")$tail(2)$sort("letters")$collect()
lazygroupby__tail <- function(n = 5) {
  self$lgb$tail(n) |>
    wrap()
}

#' Reduce the groups to the maximal value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$max()$collect()
lazygroupby__max <- function() {
  self$agg(pl$all()$max()) |>
    wrap()
}

#' Reduce the groups to the minimal value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$min()$collect()
lazygroupby__min <- function() {
  self$agg(pl$all()$min()) |>
    wrap()
}

#' Return the median per group
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$median()$collect()
lazygroupby__median <- function() {
  self$agg(pl$all()$median()) |>
    wrap()
}

#' Return the mean per group
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$mean()$collect()
lazygroupby__mean <- function() {
  self$agg(pl$all()$mean()) |>
    wrap()
}

#' Return the sum per group
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$sum()$collect()
lazygroupby__sum <- function() {
  self$agg(pl$all()$sum()) |>
    wrap()
}

#' Compute the quantile per group
#'
#' @inheritParams lazyframe__quantile
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$quantile(0.5)$collect()
lazygroupby__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  wrap({
    self$agg(pl$all()$quantile(quantile = quantile, interpolation = interpolation))
  })
}

#' Count the unique values per group
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' lf$collect()
#'
#' lf$group_by("grp")$n_unique()$collect()
lazygroupby__n_unique <- function() {
  self$agg(pl$all()$n_unique()) |>
    wrap()
}
