# The env for storing group_by methods
polars_groupby__methods <- new.env(parent = emptyenv())

wrap_to_group_by <- function(x, by, maintain_order, predicates) {
  self <- new.env(parent = emptyenv())
  self$df <- x
  self$by <- by
  self$maintain_order <- maintain_order
  self$predicates <- predicates

  class(self) <- c("polars_group_by", "polars_object")
  self
}

#' @inherit lazygroupby__agg title params
#'
#' @inherit as_polars_df return
#' @examples
#' # Compute the aggregation of the columns for each group.
#' df <- pl$DataFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#' df$group_by("a")$agg(pl$col("b"), pl$col("c"))
#'
#' # Compute the sum of a column for each group.
#' df$group_by("a")$agg(pl$col("b")$sum())
#'
#' # Compute multiple aggregates at once by passing a list of expressions.
#' df$group_by("a")$agg(pl$sum("b"), pl$col("c")$mean())
#'
#' # Use keyword arguments to easily name your expression inputs.
#' df$group_by("a")$agg(
#'   b_sum = pl$sum("b"),
#'   c_mean_squared = (pl$col("c") ** 2)$mean()
#' )
groupby__agg <- function(...) {
  wrap({
    out <- self$df$lazy()$group_by(
      !!!self$by,
      .maintain_order = self$maintain_order
    )

    if ("predicates" %in% names(self)) {
      out <- out$having(!!!self$predicates)
    }

    out$agg(...)$collect(optimizations = QueryOptFlags()$no_optimizations())
  })
}

#' @inherit lazygroupby__head title params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   letters = c("c", "c", "a", "c", "a", "b"),
#'   nrs = 1:6
#' )
#' df
#'
#' df$group_by("letters")$head(2)$sort("letters")
groupby__head <- function(n = 5) {
  self$df$lazy()$group_by(
    !!!self$by,
    .maintain_order = self$maintain_order
  )$head(n)$collect(optimizations = QueryOptFlags()$no_optimizations()) |>
    wrap()
}

#' @inherit lazygroupby__tail title params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   letters = c("c", "c", "a", "c", "a", "b"),
#'   nrs = 1:6
#' )
#' df
#'
#' df$group_by("letters")$tail(2)$sort("letters")
groupby__tail <- function(n = 5) {
  self$df$lazy()$group_by(
    !!!self$by,
    .maintain_order = self$maintain_order
  )$tail(n)$collect(optimizations = QueryOptFlags()$no_optimizations()) |>
    wrap()
}

#' @inherit lazygroupby__max title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$max()
groupby__max <- function() {
  self$agg(pl$all()$max()) |>
    wrap()
}

#' @inherit lazygroupby__min title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$min()
groupby__min <- function() {
  self$agg(pl$all()$min()) |>
    wrap()
}

#' @inherit lazygroupby__median title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$median()
groupby__median <- function() {
  self$agg(pl$all()$median()) |>
    wrap()
}

#' @inherit lazygroupby__mean title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$mean()
groupby__mean <- function() {
  self$agg(pl$all()$mean()) |>
    wrap()
}

#' @inherit lazygroupby__sum title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$sum()
groupby__sum <- function() {
  self$agg(pl$all()$sum()) |>
    wrap()
}

#' @inherit lazygroupby__quantile title params
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$quantile(0.5)
groupby__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear", "equiprobable")
) {
  wrap({
    self$agg(pl$all()$quantile(quantile = quantile, interpolation = interpolation))
  })
}

#' @inherit lazygroupby__n_unique title
#'
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   grp = c("c", "c", "a", "c", "a", "b"),
#'   x = c(0.5, 0.5, 4, 10, 13, 14),
#'   y = 1:6,
#'   z = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE)
#' )
#' df
#'
#' df$group_by("grp")$n_unique()
groupby__n_unique <- function() {
  self$agg(pl$all()$n_unique()) |>
    wrap()
}

#' @inherit lazygroupby__len title params
#' @inherit as_polars_df return
#' @examples
#' df <- pl$DataFrame(
#'   a = c("Apple", "Apple", "Orange"),
#'   b = c(1, NA, 2)
#' )
#' df$group_by("a")$len()
#'
#' df$group_by("a")$len("n")
groupby__len <- function(name = NULL) {
  wrap({
    len_expr <- pl$len()
    if (!is.null(name)) {
      len_expr <- len_expr$alias(name)
    }
    self$agg(len_expr)
  })
}

#' @inherit lazygroupby__having title description params
#' @inherit dataframe__group_by return
#' @examples
#' df <- pl$DataFrame(x = c("a", "b", "a", "b", "c"))
#'
#' # Only keep groups that contain more than one element:
#' df$group_by("x")$having(
#'   pl$len() > 1
#' )$agg()
groupby__having <- function(...) {
  wrap_to_group_by(
    self$df,
    by = self$by,
    maintain_order = self$maintain_order,
    predicates = c(self$predicates, list2(...))
  )
}
