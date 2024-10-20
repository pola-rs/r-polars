# TODO: link to dataframe__lazy
#' Polars LazyFrame class (`polars_lazy_frame`)
#'
#' Representation of a Lazy computation graph/query against a [DataFrame].
#' This allows for whole-query optimisation in addition to parallelism,
#' and is the preferred (and highest-performance) mode of operation for polars.
#'
#' The `pl$LazyFrame(...)` function is a shortcut for `pl$DataFrame(...)$lazy()`.
#' @aliases polars_lazy_frame LazyFrame
#' @inheritParams pl__DataFrame
#' @return A polars [LazyFrame]
#' @seealso
#' - [`<LazyFrame>$collect()`][lazyframe__collect]: Materialize a [LazyFrame] into a [DataFrame].
#' @examples
#' # Constructing a LazyFrame from vectors:
#' pl$LazyFrame(a = 1:2, b = 3:4)
#'
#' # Constructing a LazyFrame from Series:
#' pl$LazyFrame(pl$Series("a", 1:2), pl$Series("b", 3:4))
#'
#' # Constructing a LazyFrame from a list:
#' data <- list(a = 1:2, b = 3:4)
#'
#' ## Using dynamic dots feature
#' pl$LazyFrame(!!!data)
pl__LazyFrame <- function(..., .schema_overrides = NULL, .strict = TRUE) {
  pl$DataFrame(..., .schema_overrides = .schema_overrides, .strict = .strict)$lazy()
}

# The env for storing lazyrame methods
polars_lazyframe__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRLazyFrame <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_ldf` <- x

  lapply(names(polars_lazyframe__methods), function(name) {
    fn <- polars_lazyframe__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_lazy_frame", "polars_object")
  self
}

# TODO: link to pl__select
#' Select and modify columns of a LazyFrame
#'
#' @description
#' Select and perform operations on a subset of columns only. This discards
#' unmentioned columns (like `.()` in `data.table` and contrarily to
#' `dplyr::mutate()`).
#'
#' One cannot use new variables in subsequent expressions in the same
#' `$select()` call. For instance, if you create a variable `x`, you will only
#' be able to use it in another `$select()` or `$with_columns()` call.
#'
#' @inherit pl__LazyFrame return
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Name-value pairs of objects to be converted to polars [expressions][Expr]
#' by the [as_polars_expr()] function.
#' Characters are parsed as column names, other non-expression inputs are parsed as [literals][pl__lit].
#' Each name will be used as the expression name.
#' @examples
#' # Pass the name of a column to select that column.
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = letters[1:3]
#' )
#' lf$select("foo")$collect()
#'
#' # Multiple columns can be selected by passing a list of column names.
#' lf$select("foo", "bar")$collect()
#'
#' # Expressions are also accepted.
#' lf$select(pl$col("foo"), pl$col("bar") + 1)$collect()
#'
#' # Name expression (used as the column name of the output DataFrame)
#' lf$select(
#'   threshold = pl$when(pl$col("foo") > 2)$then(10)$otherwise(0)
#' )$collect()
#'
#' # Expressions with multiple outputs can be automatically instantiated
#' # as Structs by setting the `POLARS_AUTO_STRUCTIFY` environment variable.
#' # (Experimental)
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
#'     lf$select(
#'       is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd"),
#'     )$collect()
#'   })
#' }
lazyframe__select <- function(...) {
  wrap({
    structify <- parse_env_auto_structify()

    parse_into_list_of_expressions(..., `__structify` = structify) |>
      self$`_ldf`$select()
  })
}

lazyframe__group_by <- function(..., maintain_order = FALSE) {
  wrap({
    exprs <- parse_into_list_of_expressions(...)
    self$`_ldf`$group_by(exprs, maintain_order)
  })
}

# TODO: see also section
#' Materialize this LazyFrame into a DataFrame
#'
#' By default, all query optimizations are enabled.
#' Individual optimizations may be disabled by setting the corresponding parameter to `FALSE`.
#' @inherit pl__DataFrame return
#' @inheritParams rlang::args_dots_empty
#' @param type_coercion A logical, indicats type coercion optimization.
#' @param predicate_pushdown A logical, indicats predicate pushdown optimization.
#' @param projection_pushdown A logical, indicats projection pushdown optimization.
#' @param simplify_expression A logical, indicats simplify expression optimization.
#' @param slice_pushdown A logical, indicats slice pushdown optimization.
#' @param comm_subplan_elim A logical, indicats tring to cache branching subplans that occur on self-joins or unions.
#' @param comm_subexpr_elim A logical, indicats tring to cache common subexpressions.
#' @param cluster_with_columns A logical, indicats to combine sequential independent calls to with_columns.
#' @param no_optimization A logical. If `TRUE`, turn off (certain) optimizations.
#' @param streaming A logical. If `TRUE`, process the query in batches to handle larger-than-memory data.
#' If `FALSE` (default), the entire query is processed in a single batch.
#' Note that streaming mode is considered unstable.
#' It may be changed at any point without it being considered a breaking change.
#' @param _eager A logical, indicates to turn off multi-node optimizations and the other optimizations.
#' This option is intended for internal use only.
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = 1:6,
#'   c = 6:1,
#' )
#' lf$group_by("a")$agg(pl$all()$sum())$collect()
#'
#' # Collect in streaming mode
#' lf$group_by("a")$agg(pl$all()$sum())$collect(
#'   streaming = TRUE
#' )
lazyframe__collect <- function(
    ...,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    no_optimization = FALSE,
    streaming = FALSE,
    `_eager` = FALSE) {
  wrap({
    check_dots_empty0(...)

    if (isTRUE(no_optimization) || isTRUE(`_eager`)) {
      predicate_pushdown <- FALSE
      projection_pushdown <- FALSE
      slice_pushdown <- FALSE
      comm_subplan_elim <- FALSE
      comm_subexpr_elim <- FALSE
      cluster_with_columns <- FALSE
    }

    ldf <- self$`_ldf`$optimization_toggle(
      type_coercion = type_coercion,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      comm_subplan_elim = comm_subplan_elim,
      comm_subexpr_elim = comm_subexpr_elim,
      cluster_with_columns = cluster_with_columns,
      streaming = streaming,
      `_eager` = `_eager`
    )

    ldf$collect()
  })
}

lazyframe__explain <- function(
    ...,
    format = c("plain", "tree"),
    optimized = TRUE,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    streaming = FALSE) {
  wrap({
    check_dots_empty0(...)

    format <- arg_match0(format, c("plain", "tree"))

    if (isTRUE(optimized)) {
      ldf <- self$`_ldf`$optimization_toggle(
        type_coercion = type_coercion,
        predicate_pushdown = predicate_pushdown,
        projection_pushdown = projection_pushdown,
        simplify_expression = simplify_expression,
        slice_pushdown = slice_pushdown,
        comm_subplan_elim = comm_subplan_elim,
        comm_subexpr_elim = comm_subexpr_elim,
        cluster_with_columns = cluster_with_columns,
        streaming = streaming,
        `_eager` = FALSE
      )

      if (format == "tree") {
        ldf$describe_optimized_plan_tree()
      } else {
        ldf$describe_optimized_plan()
      }
    } else {
      if (format == "tree") {
        self$`_ldf`$describe_plan_tree()
      } else {
        self$`_ldf`$describe_plan()
      }
    }
  })
}

lazyframe__cast <- function(..., .strict = TRUE) {
  wrap({
    check_bool(.strict)
    dtypes <- parse_into_list_of_datatypes(...)

    if (length(dtypes) == 1L && !is_named(dtypes)) {
      self$`_ldf`$cast_all(dtypes[[1]], strict = .strict)
    } else {
      self$`_ldf`$cast(dtypes, strict = .strict)
    }
  })
}

lazyframe__filter <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_ldf`$filter() |>
    wrap()
}

lazyframe__sort <- function(
    ...,
    descending = FALSE,
    nulls_last = FALSE,
    multithreaded = TRUE,
    maintain_order = FALSE) {
  wrap({
    check_dots_unnamed()

    by <- parse_into_list_of_expressions(...)
    descending <- extend_bool(descending, length(by), "descending", "...")
    nulls_last <- extend_bool(nulls_last, length(by), "nulls_last", "...")

    self$`_ldf`$sort_by_exprs(
      by,
      descending = descending,
      nulls_last = nulls_last,
      multithreaded = multithreaded,
      maintain_order = maintain_order
    )
  })
}

#' Modify/append column(s) of a LazyFrame
#'
#' @description
#' Add columns or modify existing ones with expressions. This is similar to
#' `dplyr::mutate()` as it keeps unmentioned columns (unlike `$select()`).
#'
#' However, unlike `dplyr::mutate()`, one cannot use new variables in subsequent
#' expressions in the same `$with_columns()`call. For instance, if you create a
#' variable `x`, you will only be able to use it in another `$with_columns()`
#' or `$select()` call.
#'
#' @inherit pl__LazyFrame return
#' @inheritParams lazyframe__select
#' @examples
#' # Pass an expression to add it as a new column.
#' lf <- pl$LazyFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE),
#' )
#' lf$with_columns((pl$col("a")^2)$alias("a^2"))$collect()
#'
#' # Added columns will replace existing columns with the same name.
#' lf$with_columns(a = pl$col("a")$cast(pl$Float64))$collect()
#'
#' # Multiple columns can be added
#' lf$with_columns(
#'   (pl$col("a")^2)$alias("a^2"),
#'   (pl$col("b") / 2)$alias("b/2"),
#'   (pl$col("c")$not())$alias("not c"),
#' )$collect()
#'
#' # Name expression instead of `$alias()`
#' lf$with_columns(
#'   `a^2` = pl$col("a")^2,
#'   `b/2` = pl$col("b") / 2,
#'   `not c` = pl$col("c")$not(),
#' )$collect()
#'
#' # Expressions with multiple outputs can automatically be instantiated
#' # as Structs by enabling the experimental setting `POLARS_AUTO_STRUCTIFY`:
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
#'     lf$drop("c")$with_columns(
#'       diffs = pl$col("a", "b")$diff()$name$suffix("_diff"),
#'     )$collect()
#'   })
#' }
lazyframe__with_columns <- function(...) {
  wrap({
    structify <- parse_env_auto_structify()

    parse_into_list_of_expressions(..., `__structify` = structify) |>
      self$`_ldf`$with_columns()
  })
}

lazyframe__drop <- function(..., strict = TRUE) {
  wrap({
    check_dots_unnamed()

    parse_into_list_of_expressions(...) |>
      self$`_ldf`$drop(strict)
  })
}

lazyframe__slice <- function(offset, length = NULL) {
  wrap({
    if (isTRUE(length < 0)) {
      abort(sprintf("negative slice length (%s) are invalid for LazyFrame", length))
    }
    self$`_ldf`$slice(offset, length)
  })
}

lazyframe__head <- function(n = 5) {
  self$slice(0, n) |>
    wrap()
}

lazyframe__tail <- function(n = 5) {
  self$`_ldf`$tail(n) |>
    wrap()
}
