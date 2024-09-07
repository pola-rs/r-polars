# TODO: link to the lazy method of dataframe
#' Polars LazyFrame class (`polars_lazy_frame`)
#'
#' Representation of a Lazy computation graph/query against a [DataFrame].
#' This allows for whole-query optimisation in addition to parallelism,
#' and is the preferred (and highest-performance) mode of operation for polars.
#'
#' The `pl$LazyFrame(...)` function is a shortcut for `pl$DataFrame(...)$lazy()`.
#' @aliases plars_lazy_frame LazyFrame
#' @inheritParams pl__DataFrame
#' @return A polars [LazyFrame]
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
pl__LazyFrame <- function(...) {
  pl$DataFrame(...)$lazy()
}

# The env for storing lazyrame methods
polars_lazyframe__methods <- new.env(parent = emptyenv())

#' @export
is_polars_lf <- function(x) {
  inherits(x, "polars_lazy_frame")
}

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

lazyframe__select <- function(...) {
  wrap({
    exprs <- parse_into_list_of_expressions(...)
    self$`_ldf`$select(exprs)
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
#' @param `_eager` A logical, indicates to turn off multi-node optimizations and the other optimizations.
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
    format = "plain",
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
    check_string(format)

    if (!format %in% c("plain", "tree")) {
      abort(sprintf("`format` must be one of ('plain', 'tree'), got '%s'", format))
    }

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

lazyframe__cast <- function(..., strict = TRUE) {
  wrap({
    dtypes <- parse_into_list_of_datatypes(...)

    if (length(dtypes) == 1L && !is_named(dtypes)) {
      self$`_ldf`$cast_all(dtypes[[1]], strict)
    } else {
      self$`_ldf`$cast(dtypes, strict)
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

lazyframe__with_columns <- function(...) {
  parse_into_list_of_expressions(...) |>
    self$`_ldf`$with_columns() |>
    wrap()
}
