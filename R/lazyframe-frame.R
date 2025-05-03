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

  class(self) <- c("polars_lazy_frame", "polars_object")
  self
}

#' Serialize the logical plan of this LazyFrame
#'
#' @inheritParams rlang::args_dots_empty
#' @param format A character of the format in which to serialize.
#' One of:
#' - `"binary"` (default): Serialize to binary format (raw vector).
#' - `"json"`: `r lifecycle::badge("deprecated")`
#'   Serialize to JSON format (character vector).
#' @return
#' - `<lazyframe>$serialize()` returns raw or character, depending on the `format` argument.
#' - `pl$deserialize_lf()` returns a deserialized [LazyFrame].
#' @examples
#' lf <- pl$LazyFrame(a = 1:3)$sum()
#'
#' # Serialize the logical plan to a binary representation.
#' serialized <- lf$serialize()
#' serialized
#'
#' # The bytes can later be deserialized back into a LazyFrame.
#' pl$deserialize_lf(serialized)$collect()
lazyframe__serialize <- function(..., format = c("binary", "json")) {
  wrap({
    check_dots_empty0(...)
    format <- arg_match0(format, values = c("binary", "json"))

    if (format == "binary") {
      self$`_ldf`$serialize_binary()
    } else {
      deprecate_warn(c(`!` = '"json" serialization format of LazyFrame is deprecated.'))
      self$`_ldf`$serialize_json()
    }
  })
}

# TODO: support json format
#' @param data A raw vector of serialized [LazyFrame].
#' @rdname lazyframe__serialize
pl__deserialize_lf <- function(data) {
  PlRLazyFrame$deserialize_binary(data) |>
    wrap()
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
#' Characters are parsed as column names, other non-expression inputs are parsed as
#' [literals][pl__lit]. Each name will be used as the expression name.
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

#' Select columns from this LazyFrame
#'
#' This will run all expression sequentially instead of in parallel. Use this
#' when the work per expression is cheap.
#'
#' @inherit as_polars_lf return
#' @inheritParams lazyframe__select
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = letters[1:3]
#' )
#' lf$select_seq("foo", bar2 = pl$col("bar") * 2)$collect()
lazyframe__select_seq <- function(...) {
  wrap({
    structify <- parse_env_auto_structify()
    parse_into_list_of_expressions(..., `__structify` = structify) |>
      self$`_ldf`$select_seq()
  })
}

#' Start a group by operation
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column(s) to group by.
#' Accepts expression input. Strings are parsed as column names.
#' @param .maintain_order Ensure that the order of the groups is consistent with
#' the input data. This is slower than a default group by. Setting this to
#' `TRUE` blocks the possibility to run on the streaming engine.
#'
# TODO: need a proper definition to link to
#' @return A lazy groupby
#' @examples
#' # Group by one column and call agg() to compute the grouped sum of another
#' # column.
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#' lf$group_by("a")$agg(pl$col("b")$sum())$collect()
#'
#' # Set .maintain_order = TRUE to ensure the order of the groups is consistent
#' # with the input.
#' lf$group_by("a", .maintain_order = TRUE)$agg(pl$col("b")$sum())$collect()
#'
#' # Group by multiple columns by passing a vector of column names.
#' lf$group_by(c("a", "b"))$agg(pl$col("c")$max())$collect()
#'
#' # Or use positional arguments to group by multiple columns in the same way.
#' # Expressions are also accepted.
#' lf$
#'   group_by("a", pl$col("b") / 2)$
#'   agg(pl$col("c")$mean())$collect()
lazyframe__group_by <- function(..., .maintain_order = FALSE) {
  wrap({
    exprs <- parse_into_list_of_expressions(...)
    if (has_name(exprs, "maintain_order")) {
      warn(
        c(
          `!` = "In `$group_by()`, `...` contain an argument named `maintain_order`.",
          i = "You may want to specify the argument `.maintain_order` instead."
        )
      )
    }
    self$`_ldf`$group_by(exprs, .maintain_order)
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
#' @param comm_subplan_elim A logical, indicats tring to cache branching subplans that occur
#' on self-joins or unions.
#' @param comm_subexpr_elim A logical, indicats tring to cache common subexpressions.
#' @param cluster_with_columns A logical, indicats to combine sequential independent calls
#' to with_columns.
#' @param collapse_joins Collapse a join and filters into a faster join.
#' @param no_optimization A logical. If `TRUE`, turn off (certain) optimizations.
#' @param streaming `r lifecycle::badge("deprecated")`
#' A logical. If `TRUE`, process the query in batches to handle larger-than-memory data.
#' If `FALSE` (default), the entire query is processed in a single batch.
#' Note that streaming mode is considered unstable.
#' It may be changed at any point without it being considered a breaking change.
#' @param engine The engine name to use for processing the query.
#' One of the followings:
#' - `"auto"` (default): Select the engine automatically.
#'   The `"in-memory"` engine will be selected for most cases.
#' - `"in-memory"`: Use the in-memory engine.
#' - `"streaming"`: `r lifecycle::badge("experimental")` Use the (new) streaming engine.
#' - `"old-streaming"`: `r lifecycle::badge("superseded")` Use the old streaming engine.
#' @param _eager A logical, indicates to turn off multi-node optimizations and
#' the other optimizations. This option is intended for internal use only.
#' @param _check_order,_type_check For internal use only.
#'
#' @inherit as_polars_lf return
#'
#' @seealso
#'  - [`$profile()`][lazyframe__profile] - same as `$collect()` but also returns
#'    a table with each operation profiled.
#'  - [`$sink_parquet()`][lazyframe__sink_parquet()] streams query to a parquet file.
#'  - [`$sink_ipc()`][lazyframe__sink_ipc()] streams query to a arrow file.
#'
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
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  collapse_joins = TRUE,
  no_optimization = FALSE,
  engine = c("auto", "in-memory", "streaming", "old-streaming"),
  streaming = FALSE,
  `_check_order` = TRUE,
  `_eager` = FALSE
) {
  wrap({
    check_dots_empty0(...)
    engine <- arg_match0(engine, c("auto", "in-memory", "streaming", "old-streaming"))
    # TODO: remove the streaming argument
    if (!missing(streaming)) {
      deprecate_warn(
        c(
          "The `streaming` argument is deprecated and will be removed in the future.",
          i = "Use `engine = \"old-streaming\"` for traditional streaming mode.",
          i = "Use `engine = \"streaming\"` for the new streaming mode.",
          i = "Use `engine = \"in-memory\"` for non-streaming mode."
        ),
        always = TRUE
      )
      if (isTRUE(streaming)) engine <- "old-streaming"
      if (isFALSE(streaming)) engine <- "in-memory"
    }

    if (isTRUE(no_optimization) || isTRUE(`_eager`)) {
      predicate_pushdown <- FALSE
      projection_pushdown <- FALSE
      slice_pushdown <- FALSE
      comm_subplan_elim <- FALSE
      comm_subexpr_elim <- FALSE
      cluster_with_columns <- FALSE
      collapse_joins <- FALSE
      `_check_order` <- FALSE
    }

    ldf <- self$`_ldf`$optimization_toggle(
      type_coercion = type_coercion,
      `_type_check` = `_type_check`,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      comm_subplan_elim = comm_subplan_elim,
      comm_subexpr_elim = comm_subexpr_elim,
      cluster_with_columns = cluster_with_columns,
      collapse_joins = collapse_joins,
      streaming = FALSE,
      `_check_order` = `_check_order`,
      `_eager` = `_eager`
    )

    ldf$collect(engine)
  })
}

#' Collect and profile a lazy query
#'
#' @description
#' This will run the query and return a list containing the
#' materialized DataFrame and a DataFrame that contains profiling information
#' of each node that is executed.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__collect
#' @param show_plot Show a Gantt chart of the profiling result
#' @param truncate_nodes Truncate the label lengths in the Gantt chart to this
#' number of characters. If `0` (default), do not truncate.
#'
#' @details The units of the timings are microseconds.
#'
#' @return List of two `DataFrame`s: one with the collected result, the other
#' with the timings of each step. If `show_graph = TRUE`, then the plot is
#' also stored in the list.
#' @seealso
#'  - [`$collect()`][lazyframe__collect] - regular collect.
#'  - [`$sink_parquet()`][lazyframe__sink_parquet()] streams query to a parquet file.
#'  - [`$sink_ipc()`][lazyframe__sink_ipc()] streams query to a arrow file.
#'
#' @examples
#' ## Simplest use case
#' pl$LazyFrame()$select(pl$lit(2) + 2)$profile()
#'
#' ## Use $profile() to compare two queries
#'
#' # -1-  map each Species-group with native polars
#' as_polars_lf(iris)$
#'   sort("Sepal.Length")$
#'   group_by("Species", maintain_order = TRUE)$
#'   agg(pl$col(pl$Float64)$first() + 5)$
#'   profile()
# TODO-REWRITE: uncomment when map_elements() is implemented
# 2-  map each Species-group of each numeric column with an R function
#' ## some R function, prints `.` for each time called by polars
# r_func <- \(s) {
#' #  cat(".")
#' #  s$to_r()[1] + 5
# }
# as_polars_lf(iris)$
#' #  sort("Sepal.Length")$
#' #  group_by("Species", maintain_order = TRUE)$
#' #  agg(pl$col(pl$Float64)$map_elements(r_func))$
#' #  profile()
lazyframe__profile <- function(
  ...,
  type_coercion = TRUE,
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  collapse_joins = TRUE,
  streaming = FALSE,
  no_optimization = FALSE,
  `_check_order` = TRUE,
  show_plot = FALSE,
  truncate_nodes = 0
) {
  wrap({
    check_dots_empty0(...)

    if (isTRUE(no_optimization)) {
      predicate_pushdown <- FALSE
      projection_pushdown <- FALSE
      slice_pushdown <- FALSE
      comm_subplan_elim <- FALSE
      comm_subexpr_elim <- FALSE
      cluster_with_columns <- FALSE
      collapse_joins <- FALSE
      `_check_order` <- FALSE
    }

    if (isTRUE(streaming)) {
      comm_subplan_elim <- FALSE
    }

    lf <- self$`_ldf`$optimization_toggle(
      type_coercion = type_coercion,
      `_type_check` = `_type_check`,
      predicate_pushdown = predicate_pushdown,
      projection_pushdown = projection_pushdown,
      simplify_expression = simplify_expression,
      slice_pushdown = slice_pushdown,
      comm_subplan_elim = comm_subplan_elim,
      comm_subexpr_elim = comm_subexpr_elim,
      cluster_with_columns = cluster_with_columns,
      collapse_joins = collapse_joins,
      streaming = streaming,
      `_check_order` = `_check_order`,
      `_eager` = FALSE
    )

    out <- lapply(lf$profile(), \(x) {
      x |>
        .savvy_wrap_PlRDataFrame() |>
        wrap()
    })

    if (isTRUE(show_plot)) {
      out[["plot"]] <- make_profile_plot(out, truncate_nodes)
    }

    out
  })
}

#' Create a string representation of the query plan
#'
#' The query plan is read from bottom to top. When `optimized = FALSE`, the
#' query as it was written by the user is shown. This is not what Polars runs.
#' Instead, it applies optimizations that are displayed by default by `$explain()`.
#' One classic example is the predicate pushdown, which applies the filter as
#' early as possible (i.e. at the bottom of the plan).
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__collect
#' @param format The format to use for displaying the logical plan. Must be
#' either `"plain"` (default) or `"tree"`.
#' @param optimized Return an optimized query plan. If `TRUE` (default), the
#' subsequent optimization flags control which optimizations run.
#'
#' @return A character value containing the query plan.
#' @examples
#' lazy_frame <- as_polars_lf(iris)
#'
#' # Prepare your query
#' lazy_query <- lazy_frame$sort("Species")$filter(pl$col("Species") != "setosa")
#'
#' # This is the query that was written by the user, without any optimizations
#' # (use cat() for better printing)
#' lazy_query$explain(optimized = FALSE) |> cat()
#'
#' # This is the query after `polars` optimizes it: instead of sorting first and
#' # then filtering, it is faster to filter first and then sort the rest.
#' lazy_query$explain() |> cat()
#'
#' # Also possible to see this as tree format
#' lazy_query$explain(format = "tree") |> cat()
lazyframe__explain <- function(
  ...,
  format = c("plain", "tree"),
  optimized = TRUE,
  type_coercion = TRUE,
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  collapse_joins = TRUE,
  streaming = FALSE,
  `_check_order` = TRUE
) {
  wrap({
    check_dots_empty0(...)

    format <- arg_match0(format, c("plain", "tree"))

    if (isTRUE(optimized)) {
      ldf <- self$`_ldf`$optimization_toggle(
        type_coercion = type_coercion,
        `_type_check` = `_type_check`,
        predicate_pushdown = predicate_pushdown,
        projection_pushdown = projection_pushdown,
        simplify_expression = simplify_expression,
        slice_pushdown = slice_pushdown,
        comm_subplan_elim = comm_subplan_elim,
        comm_subexpr_elim = comm_subexpr_elim,
        cluster_with_columns = cluster_with_columns,
        collapse_joins = collapse_joins,
        streaming = streaming,
        `_check_order` = `_check_order`,
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

#' Resolve the schema of this LazyFrame
#'
#' This resolves the query plan but does not trigger computations.
#'
#' @return A named list with names indicating column names and values indicating
#' column data types.
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = c("a", "b", "c")
#' )
#'
#' lf$collect_schema()
#'
#' lf$with_columns(
#'   baz = (pl$col("foo") + pl$col("bar"))$cast(pl$String),
#'   pl$col("bar")$cast(pl$Int64)
#' )$collect_schema()
lazyframe__collect_schema <- function() {
  self$`_ldf`$collect_schema() |>
    lapply(function(x) {
      .savvy_wrap_PlRDataType(x) |>
        wrap()
    }) |>
    wrap()
}

#' Cast LazyFrame column(s) to the specified dtype(s)
#'
#' This allows to convert all columns to a datatype or to convert only specific
#' columns. Contrarily to the Python implementation, it is not possible to
#' convert all columns of a specific datatype to another datatype.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Either a datatype to which
#' all columns will be cast, or a list where the names are column names and the
#' values are the datatypes to convert to.
#' @param .strict If `TRUE` (default), throw an error if a cast could not be
#' done (for instance, due to an overflow). Otherwise, return `null`.
#'
#' @return A LazyFrame
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06"))
#' )
#'
#' # Cast only some columns
#' lf$cast(foo = pl$Float32, bar = pl$UInt8)$collect()
#'
#' # Cast all columns to the same type
#' lf$cast(pl$String)$collect()
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

#' Filter the rows in the LazyFrame based on a predicate expression
#'
#' The original order of the remaining rows is preserved. Rows where the filter
#' does not evaluate to `TRUE` are discarded, including nulls.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Expression that evaluates to
#' a boolean Series.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = c(1, 2, 3, NA, 4, NA, 0),
#'   bar = c(6, 7, 8, NA, NA, 9, 0),
#'   ham = c("a", "b", "c", NA, "d", "e", "f")
#' )
#'
#' # Filter on one condition
#' lf$filter(pl$col("foo") > 1)$collect()
#'
#' # Filter on multiple conditions
#' lf$filter((pl$col("foo") < 3) & (pl$col("ham") == "a"))$collect()
#'
#' # Filter on an OR condition
#' lf$filter((pl$col("foo") == 1) | (pl$col("ham") == " c"))$collect()
#'
#' # Filter by comparing two columns against each other
#' lf$filter(pl$col("foo") == pl$col("bar"))$collect()
#' lf$filter(pl$col("foo") != pl$col("bar"))$collect()
#'
#' # Notice how the row with null values is filtered out$ In order to keep the
#' # rows with nulls, use:
#' lf$filter(pl$col("foo")$ne_missing(pl$col("bar")))$collect()
lazyframe__filter <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_ldf`$filter() |>
    wrap()
}

#' Sort the LazyFrame by the given columns
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column(s) to sort by. Can be
#' character values indicating column names or Expr(s).
#' @param descending Sort in descending order. When sorting by multiple
#' columns, this can be specified per column by passing a logical vector.
#' @param nulls_last Place null values last. When sorting by multiple
#' columns, this can be specified per column by passing a logical vector.
#' @param maintain_order Whether the order should be maintained if elements are
#' equal. If `TRUE`, streaming is not possible and performance might be worse
#' since this requires a stable search.
#' @param multithreaded Sort using multiple threads.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c(1, 2, NA, 4),
#'   b = c(6, 5, 4, 3),
#'   c = c("a", "c", "b", "a")
#' )
#'
#' # Pass a single column name to sort by that column.
#' lf$sort("a")$collect()
#'
#' # Sorting by expressions is also supported
#' lf$sort(pl$col("a") + pl$col("b") * 2, nulls_last = TRUE)$collect()
#'
#' # Sort by multiple columns by passing a vector of columns
#' lf$sort(c("c", "a"), descending = TRUE)$collect()
#'
#' # Or use positional arguments to sort by multiple columns in the same way
#' lf$sort("c", "a", descending = c(FALSE, TRUE))$collect()
lazyframe__sort <- function(
  ...,
  descending = FALSE,
  nulls_last = FALSE,
  multithreaded = TRUE,
  maintain_order = FALSE
) {
  wrap({
    check_dots_unnamed()

    if (missing(...)) {
      abort("`...` must contain at least one element.")
    }
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
  structify <- parse_env_auto_structify()

  parse_into_list_of_expressions(..., `__structify` = structify) |>
    self$`_ldf`$with_columns() |>
    wrap()
}

#' Modify/append column(s) of a LazyFrame
#'
#' @description
#' This will run all expression sequentially instead of in parallel. Use this
#' only when the work per expression is cheap.
#'
#' Add columns or modify existing ones with expressions. This is similar to
#' `dplyr::mutate()` as it keeps unmentioned columns (unlike `$select()`).
#'
#' However, unlike `dplyr::mutate()`, one cannot use new variables in subsequent
#' expressions in the same `$with_columns_seq()`call. For instance, if you create a
#' variable `x`, you will only be able to use it in another `$with_columns_seq()`
#' or `$select()` call.
#'
#' @inherit as_polars_lf return
#' @inheritParams lazyframe__select
#' @examples
#' # Pass an expression to add it as a new column.
#' lf <- pl$LazyFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE),
#' )
#' lf$with_columns_seq((pl$col("a")^2)$alias("a^2"))$collect()
#'
#' # Added columns will replace existing columns with the same name.
#' lf$with_columns_seq(a = pl$col("a")$cast(pl$Float64))$collect()
#'
#' # Multiple columns can be added
#' lf$with_columns_seq(
#'   (pl$col("a")^2)$alias("a^2"),
#'   (pl$col("b") / 2)$alias("b/2"),
#'   (pl$col("c")$not())$alias("not c"),
#' )$collect()
#'
#' # Name expression instead of `$alias()`
#' lf$with_columns_seq(
#'   `a^2` = pl$col("a")^2,
#'   `b/2` = pl$col("b") / 2,
#'   `not c` = pl$col("c")$not(),
#' )$collect()
#'
#' # Expressions with multiple outputs can automatically be instantiated
#' # as Structs by enabling the experimental setting `POLARS_AUTO_STRUCTIFY`:
#' if (requireNamespace("withr", quietly = TRUE)) {
#'   withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
#'     lf$drop("c")$with_columns_seq(
#'       diffs = pl$col("a", "b")$diff()$name$suffix("_diff"),
#'     )$collect()
#'   })
#' }
lazyframe__with_columns_seq <- function(...) {
  wrap({
    structify <- parse_env_auto_structify()

    parse_into_list_of_expressions(..., `__structify` = structify) |>
      self$`_ldf`$with_columns_seq()
  })
}

#' Remove columns
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Names of the columns that
#' should be removed. Accepts column selector input.
#' @param strict Validate that all column names exist in the current schema,
#' and throw an exception if any do not.
#'
#' @inherit as_polars_lf return
#' @examples
#' # Drop columns by passing the name of those columns
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = c("a", "b", "c")
#' )
#' lf$drop("ham")$collect()
#' lf$drop("ham", "bar")$collect()
#'
#' # Drop multiple columns by passing a selector
#' lf$drop(cs$all())$collect()
lazyframe__drop <- function(..., strict = TRUE) {
  wrap({
    check_dots_unnamed()

    parse_into_list_of_expressions(...) |>
      self$`_ldf`$drop(strict)
  })
}

#' Get a slice of the LazyFrame.
#'
#' @param offset Start index. Negative indexing is supported.
#' @param length Length of the slice. If `NULL` (default), all rows starting at
#' the offset will be selected.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(x = c("a", "b", "c"), y = 1:3, z = 4:6)
#' lf$slice(1, 2)$collect()
lazyframe__slice <- function(offset, length = NULL) {
  wrap({
    if (isTRUE(length < 0)) {
      abort(sprintf("Negative slice `length` (%s) are invalid for LazyFrame.", length))
    }
    self$`_ldf`$slice(offset, length)
  })
}

#' Get the first `n` rows
#'
#' `$limit()` is an alias for `$head()`.
#'
#' @param n Number of rows to return.
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:6, b = 7:12)
#' lf$head()$collect()
#' lf$head(2)$collect()
lazyframe__head <- function(n = 5) {
  self$slice(0, n) |>
    wrap()
}

#' @rdname lazyframe__head
lazyframe__limit <- lazyframe__head

#' Get the last `n` rows.
#'
#' @inherit lazyframe__head return params
#' @inheritParams lazyframe__head
#' @seealso [`<LazyFrame>$head()`][lazyframe__head]
#' @examples
#' lf <- pl$LazyFrame(a = 1:6, b = 7:12)
#' lf$tail()$collect()
#' lf$tail(2)$collect()
lazyframe__tail <- function(n = 5L) {
  self$`_ldf`$tail(n) |>
    wrap()
}

#' Get the first row of the LazyFrame
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$first()$collect()
lazyframe__first <- function() {
  self$slice(0, 1) |>
    wrap()
}

#' Get the last row of the LazyFrame
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$last()$collect()
lazyframe__last <- function() {
  self$tail(1) |>
    wrap()
}

#' Aggregate the columns in the LazyFrame to their maximum value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$max()$collect()
lazyframe__max <- function() {
  self$`_ldf`$max() |>
    wrap()
}

#' Aggregate the columns in the LazyFrame to their mean value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$mean()$collect()
lazyframe__mean <- function() {
  self$`_ldf`$mean() |>
    wrap()
}

#' Aggregate the columns in the LazyFrame to their median value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$median()$collect()
lazyframe__median <- function() {
  self$`_ldf`$median() |>
    wrap()
}

#' Aggregate the columns in the LazyFrame to their minimum value
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$min()$collect()
lazyframe__min <- function() {
  self$`_ldf`$min() |>
    wrap()
}

#' Aggregate the columns of this LazyFrame to their sum values
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$sum()$collect()
lazyframe__sum <- function() {
  self$`_ldf`$sum() |>
    wrap()
}

#' Aggregate the columns in the LazyFrame to their variance value
#'
#' @param ddof "Delta Degrees of Freedom": the divisor used in the calculation
#' is `N - ddof`, where `N` represents the number of elements. By default
#' `ddof` is 1.
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$var()$collect()
#' lf$var(ddof = 0)$collect()
lazyframe__var <- function(ddof = 1) {
  self$`_ldf`$var(ddof) |>
    wrap()
}

#' Aggregate the columns of this LazyFrame to their standard deviation values
#'
#' @inheritParams lazyframe__var
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$std()$collect()
#' lf$std(ddof = 0)$collect()
lazyframe__std <- function(ddof = 1) {
  self$`_ldf`$std(ddof) |>
    wrap()
}

#' Aggregate the columns to a unique quantile value
#'
#' @param quantile Quantile between 0.0 and 1.0.
#' @param interpolation Interpolation method.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, 1))
#' lf$quantile(0.7)$collect()
lazyframe__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  wrap({
    interpolation <- arg_match0(
      interpolation,
      values = c("nearest", "higher", "lower", "midpoint", "linear")
    )
    self$`_ldf`$quantile(as_polars_expr(quantile, as_lit = TRUE)$`_rexpr`, interpolation)
  })
}

#' @inherit expr__fill_nan title params
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c(1.5, 2, NaN, 4),
#'   b = c(1.5, NaN, NaN, 4)
#' )
#' lf$fill_nan(99)$collect()
lazyframe__fill_nan <- function(value) {
  self$`_ldf`$fill_nan(as_polars_expr(value)$`_rexpr`) |>
    wrap()
}

#' Fill null values using the specified value or strategy
#'
#' @inheritParams rlang::args_dots_empty
#' @param value Value used to fill null values.
#' @param strategy Strategy used to fill null values. Must be one of:
#' `"forward"`, `"backward"`, `"min"`, `"max"`, `"mean"`, `"zero"`, `"one"`,
#' or `NULL` (default).
#' @param limit Number of consecutive null values to fill when using the
#' `"forward"` or `"backward"` strategy.
#' @param matches_supertype Fill all matching supertypes of the fill `value`
#' literal.
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c(1.5, 2, NA, 4),
#'   b = c(1.5, NA, NA, 4)
#' )
#' lf$fill_null(99)$collect()
#'
#' lf$fill_null(strategy = "forward")$collect()
#'
#' lf$fill_null(strategy = "max")$collect()
#'
#' lf$fill_null(strategy = "zero")$collect()
lazyframe__fill_null <- function(
  value,
  strategy = NULL,
  limit = NULL,
  ...,
  matches_supertype = TRUE
) {
  wrap({
    check_exclusive_or_null(value, strategy)
    check_dots_empty0(...)
    if (!missing(value) && !is.null(value)) {
      if (is_polars_expr(value)) {
        dtypes <- NULL
      } else {
        dtype <- infer_polars_dtype(value)
        if (dtype$is_numeric() && isTRUE(matches_supertype)) {
          dtypes <- c(
            pl$Int8,
            pl$Int16,
            pl$Int32,
            pl$Int64,
            pl$Int128,
            pl$UInt8,
            pl$UInt16,
            pl$UInt32,
            pl$UInt64,
            pl$Float32,
            pl$Float64,
            pl$Decimal()
          )
        } else if (inherits(dtype, "polars_dtype_string")) {
          dtypes <- c(pl$String, pl$Categorical("physical"), pl$Categorical("lexical"))
        } else {
          dtypes <- dtype
        }
      }

      if (is_polars_dtype(dtypes)) {
        dtypes <- list(dtypes)
      }

      if (!is.null(dtypes)) {
        return(
          self$with_columns(
            # do not specify strategy otherwise check_exclusive() errors
            pl$col(!!!dtypes)$fill_null(value = value, limit = limit)
          ) |>
            wrap()
        )
      }
    }
    self$select(pl$all()$fill_null(value, strategy, limit))
  })
}

#' Shift values by the given number of indices
#'
#' @inheritParams rlang::args_dots_empty
#' @param n Number of indices to shift forward. If a negative value is passed,
#' values are shifted in the opposite direction instead.
#' @param fill_value Fill the resulting null values with this value. Accepts
#' expression input. Non-expression inputs are parsed as literals.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = 5:8)
#'
#' # By default, values are shifted forward by one index.
#' lf$shift()$collect()
#'
#' # Pass a negative value to shift in the opposite direction instead.
#' lf$shift(-2)$collect()
#'
#' # Specify fill_value to fill the resulting null values.
#' lf$shift(-2, fill_value = 100)$collect()
lazyframe__shift <- function(n = 1, ..., fill_value = NULL) {
  wrap({
    check_dots_empty0(...)
    self$`_ldf`$shift(
      as_polars_expr(n)$`_rexpr`,
      as_polars_expr(fill_value, as_lit = TRUE)$`_rexpr`
    )
  })
}

#' Reverse the LazyFrame
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(key = c("a", "b", "c"), val = 1:3)
#' lf$reverse()$collect()
lazyframe__reverse <- function() {
  self$`_ldf`$reverse() |>
    wrap()
}

#' Drop all rows that contain null values
#'
#' The original order of the remaining rows is preserved.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column name(s) for which null
#' values are considered. If empty (default), use all columns.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = c(6L, NA, 8L),
#'   ham = c("a", "b", NA)
#' )
#'
#' # The default behavior of this method is to drop rows where any single value
#' # of the row is null.
#' lf$drop_nulls()$collect()
#'
#' # This behaviour can be constrained to consider only a subset of columns, as
#' # defined by name or with a selector. For example, dropping rows if there is
#' # a null in any of the integer columns:
#' lf$drop_nulls(cs$integer())$collect()
lazyframe__drop_nulls <- function(...) {
  wrap({
    check_dots_unnamed()
    subset <- parse_into_list_of_expressions(...)
    if (length(subset) == 0) {
      subset <- NULL
    }
    self$`_ldf`$drop_nulls(subset)
  })
}

#' Drop all rows that contain NaN values
#'
#' The original order of the remaining rows is preserved.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column name(s) for which null
#' values are considered. If empty (default), use all columns (note that only
#' floating-point columns can contain `NaN`s).
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = c(1, NaN, 2.5),
#'   bar = c(NaN, 110, 25.5),
#'   ham = c("a", "b", NA)
#' )
#'
#' # The default behavior of this method is to drop rows where any single value
#' # of the row is null.
#' lf$drop_nans()$collect()
#'
#' # This behaviour can be constrained to consider only a subset of columns, as
#' # defined by name or with a selector. For example, dropping rows if there is
#' # a null in the "bar" column:
#' lf$drop_nans("bar")$collect()
#'
#' # Dropping a row only if *all* values are NaN requires a different
#' # formulation:
#' df <- pl$LazyFrame(
#'   a = c(NaN, NaN, NaN, NaN),
#'   b = c(10.0, 2.5, NaN, 5.25),
#'   c = c(65.75, NaN, NaN, 10.5)
#' )
#' df$filter(!pl$all_horizontal(pl$all()$is_nan()))$collect()
lazyframe__drop_nans <- function(...) {
  wrap({
    check_dots_unnamed()
    subset <- parse_into_list_of_expressions(...)
    if (length(subset) == 0) {
      subset <- NULL
    }
    self$`_ldf`$drop_nans(subset)
  })
}

#' Drop duplicate rows
#'
#' @inheritParams rlang::args_dots_empty
#' @param subset Column name(s) or selector(s), to consider when identifying
#' duplicate rows. If `NULL` (default), use all columns.
#' @param keep Which of the duplicate rows to keep. Must be one of:
#' * `"any"`: does not give any guarantee of which row is kept. This allows
#'   more optimizations.
#' * `"none"`: don’t keep duplicate rows.
#' * `"first"`: keep first unique row.
#' * `"last"`: keep last unique row.
#' @param maintain_order Keep the same order as the original data. This is
#' more expensive to compute. Setting this to `TRUE` blocks the possibility to
#' run on the streaming engine.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = c(1, 2, 3, 1),
#'   bar = c("a", "a", "a", "a"),
#'   ham = c("b", "b", "b", "b"),
#' )
#' lf$unique(maintain_order = TRUE)$collect()
#'
#' lf$unique(subset = c("bar", "ham"), maintain_order = TRUE)$collect()
#'
#' lf$unique(keep = "last", maintain_order = TRUE)$collect()
lazyframe__unique <- function(
  subset = NULL,
  ...,
  keep = c("any", "none", "first", "last"),
  maintain_order = FALSE
) {
  wrap({
    check_dots_empty0(...)
    keep <- arg_match0(keep, values = c("any", "none", "first", "last"))
    if (!is.null(subset)) {
      subset <- parse_into_list_of_expressions(!!!subset)
    }
    self$`_ldf`$unique(subset = subset, keep = keep, maintain_order = maintain_order)
  })
}

#' Join LazyFrames
#'
#' This function can do both mutating joins (adding columns based on matching
#' observations, for example with `how = "left"`) and filtering joins (keeping
#' observations based on matching observations, for example with `how =
#' "inner"`).
#'
#' @inheritParams rlang::args_dots_empty
#' @param other LazyFrame to join with.
#' @param on Either a vector of column names or a list of expressions and/or
#'   strings. Use `left_on` and `right_on` if the column names to match on are
#'   different between the two LazyFrames.
#' @param how One of the following methods:
#' * "inner": returns rows that have matching values in both tables
#' * "left": returns all rows from the left table, and the matched rows from
#'   the right table
#' * "right": returns all rows from the right table, and the matched rows from
#'   the left table
#' * "full": returns all rows when there is a match in either left or right
#'   table
#' * "cross": returns the Cartesian product of rows from both tables
#' * "semi": returns rows from the left table that have a match in the right
#'   table.
#' * "anti": returns rows from the left table that have no match in the right
#'   table.
#' @param left_on,right_on Same as `on` but only for the left or the right
#'   DataFrame. They must have the same length.
#' @param suffix Suffix to add to duplicated column names.
#' @param validate Checks if join is of specified type:
#' * `"m:m"` (default): many-to-many, doesn't perform any checks;
#' * `"1:1"`: one-to-one, check if join keys are unique in both left and right
#'   datasets;
#' * `"1:m"`: one-to-many, check if join keys are unique in left dataset
#' * `"m:1"`: many-to-one, check if join keys are unique in right dataset
#'
#' Note that this is currently not supported by the streaming engine.
#'
#' @param join_nulls Join on null values. By default null values will never
#'   produce matches.
#' @param allow_parallel Allow the physical plan to optionally evaluate the
#'   computation of both LazyFrames up to the join in parallel.
#' @param force_parallel Force the physical plan to evaluate the computation of
#'   both LazyFrames up to the join in parallel.
#' @param coalesce Coalescing behavior (merging of join columns).
#' - `NULL`: join specific.
#' - `TRUE`: Always coalesce join columns.
#' - `FALSE`: Never coalesce join columns.
#' Note that joining on any other expressions than `col` will turn off
#' coalescing.
#' @param maintain_order Which frame row order to preserve, if any. Do not rely
#' on any observed ordering without explicitly setting this parameter, as your
#' code may break in a future release. Not specifying any ordering can improve
#' performance. Supported for inner, left, right and full joins.
#'
#' * `"none"`: No specific ordering is desired. The ordering might differ
#'   across Polars versions or even between different runs.
#' * `"left"`: Preserves the order of the left frame.
#' * `"right"`: Preserves the order of the right frame.
#' * `"left_right"`: First preserves the order of the left frame, then the
#'   right.
#' * `"right_left"`: First preserves the order of the right frame, then the
#'   left.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = c(6, 7, 8),
#'   ham = c("a", "b", "c")
#' )
#' other_lf <- pl$LazyFrame(
#'   apple = c("x", "y", "z"),
#'   ham = c("a", "b", "d")
#' )
#' lf$join(other_lf, on = "ham")$collect()
#'
#' lf$join(other_lf, on = "ham", how = "full")$collect()
#'
#' lf$join(other_lf, on = "ham", how = "left", coalesce = TRUE)$collect()
#'
#' lf$join(other_lf, on = "ham", how = "semi")$collect()
#'
#' lf$join(other_lf, on = "ham", how = "anti")$collect()
lazyframe__join <- function(
  other,
  on = NULL,
  how = c("inner", "full", "left", "right", "semi", "anti", "cross"),
  ...,
  left_on = NULL,
  right_on = NULL,
  suffix = "_right",
  validate = c("m:m", "1:m", "m:1", "1:1"),
  join_nulls = FALSE,
  maintain_order = c("none", "left", "right", "left_right", "right_left"),
  allow_parallel = TRUE,
  force_parallel = FALSE,
  coalesce = NULL
) {
  wrap({
    check_dots_empty0(...)
    check_polars_lf(other)
    how <- arg_match0(
      how,
      values = c("inner", "full", "left", "right", "semi", "anti", "cross")
    )
    maintain_order <- arg_match0(
      maintain_order,
      values = c("none", "left", "right", "left_right", "right_left")
    )
    validate <- arg_match0(validate, values = c("m:m", "1:m", "m:1", "1:1"))
    uses_on <- !is.null(on)
    uses_left_on <- !is.null(left_on)
    uses_right_on <- !is.null(right_on)
    uses_lr_on <- uses_left_on | uses_right_on

    # TODO: improve error message
    if (uses_on && uses_lr_on) {
      abort("Can't use `on` in conjunction with `left_on` or `right_on`.")
    }
    if (uses_left_on && !uses_right_on) {
      abort("`left_on` requires corresponding `right_on`.")
    }
    if (!uses_left_on && uses_right_on) {
      abort("`right_on` requires corresponding `left_on`.")
    }
    if (how == "cross") {
      if (uses_on | uses_lr_on) {
        abort("cross join should not pass join keys.")
      }
      return(
        self$`_ldf`$join(
          other$`_ldf`,
          left_on = list(),
          right_on = list(),
          how = how,
          validate = validate,
          join_nulls = join_nulls,
          suffix = suffix,
          allow_parallel = allow_parallel,
          force_parallel = force_parallel,
          coalesce = coalesce,
          maintain_order = maintain_order
        ) |>
          wrap()
      )
    }

    if (uses_on) {
      rexprs_right <- rexprs_left <- parse_into_list_of_expressions(!!!on)
    } else if (uses_lr_on) {
      rexprs_left <- parse_into_list_of_expressions(!!!left_on)
      rexprs_right <- parse_into_list_of_expressions(!!!right_on)
    } else {
      abort("Must specify either `on`, or `left_on` and `right_on`.")
    }
    self$`_ldf`$join(
      other$`_ldf`,
      left_on = rexprs_left,
      right_on = rexprs_right,
      how = how,
      validate = validate,
      join_nulls = join_nulls,
      suffix = suffix,
      allow_parallel = allow_parallel,
      force_parallel = force_parallel,
      coalesce = coalesce,
      maintain_order = maintain_order
    )
  })
}

#' Perform a join based on one or multiple (in)equality predicates
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This performs an inner join, so only rows where all predicates are true are
#' included in the result, and a row from either LazyFrame may be included
#' multiple times in the result.
#'
#' Note that the row order of the input LazyFrames is not preserved.
#'
#' @param other LazyFrame to join with.
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> (In)Equality condition to
#' join the two tables on. When a column name occurs in both tables, the proper
#' suffix must be applied in the predicate. For example, if both tables have a
#' column `"x"` that you want to use in the conditions, you must refer to the
#' column of the right table as `"x<suffix>"`.
#' @param suffix Suffix to append to columns with a duplicate name.
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' east <- pl$LazyFrame(
#'   id = c(100, 101, 102),
#'   dur = c(120, 140, 160),
#'   rev = c(12, 14, 16),
#'   cores = c(2, 8, 4)
#' )
#'
#' west <- pl$LazyFrame(
#'   t_id = c(404, 498, 676, 742),
#'   time = c(90, 130, 150, 170),
#'   cost = c(9, 13, 15, 16),
#'   cores = c(4, 2, 1, 4)
#' )
#'
#' east$join_where(
#'   west,
#'   pl$col("dur") < pl$col("time"),
#'   pl$col("rev") < pl$col("cost")
#' )$collect()
lazyframe__join_where <- function(
  other,
  ...,
  suffix = "_right"
) {
  wrap({
    check_polars_lf(other)
    by <- parse_into_list_of_expressions(...)
    self$`_ldf`$join_where(other$`_ldf`, by, suffix)
  })
}

#' Unpivot a frame from wide to long format
#'
#' This function is useful to massage a frame into a format where one or
#' more columns are identifier variables (`index`) while all other columns,
#' considered measured variables (`on`), are "unpivoted" to the row axis
#' leaving just two non-identifier columns, "variable" and "value".
#'
#' @inheritParams rlang::args_dots_empty
#' @param on Values to use as identifier variables. If `value_vars` is
#' empty all columns that are not in `id_vars` will be used.
#' @param index Columns to use as identifier variables.
#' @param variable_name Name to give to the new column containing the names of
#' the melted columns. Defaults to "variable".
#' @param value_name Name to give to the new column containing the values of
#' the melted columns. Defaults to `"value"`.
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c("x", "y", "z"),
#'   b = c(1, 3, 5),
#'   c = c(2, 4, 6)
#' )
#' lf$unpivot(index = "a", on = c("b", "c"))$collect()
lazyframe__unpivot <- function(
  on = NULL,
  ...,
  index = NULL,
  variable_name = NULL,
  value_name = NULL
) {
  wrap({
    check_dots_empty0(...)
    if (!is.null(on)) {
      on <- parse_into_list_of_expressions(!!!on)
    } else {
      on <- list()
    }
    if (!is.null(index)) {
      index <- parse_into_list_of_expressions(!!!index)
    }
    self$`_ldf`$unpivot(on, index, value_name, variable_name)
  })
}

#' Rename column names
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Either a function that takes
#' a character vector as input and returns a character vector as output, or
#' named values where names are old column names and values are the new ones.
#' @param .strict Validate that all column names exist in the current schema,
#' and throw an error if any do not. (Note that this parameter is a no-op when
#' passing a function to `...`).
#'
#' @details
#' If existing names are swapped (e.g. 'A' points to 'B' and 'B' points to
#' 'A'), polars will block projection and predicate pushdowns at this node.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = letters[1:3]
#' )
#'
#' lf$rename(foo = "apple")$collect()
lazyframe__rename <- function(..., .strict = TRUE) {
  wrap({
    mapping <- list2(...)
    if (length(mapping) == 1 && is_function(mapping[[1]]) && !is_named(mapping)) {
      # TODO: this requires $name$map()
      abort("Not implemented yet")
      return(self$select(pl$all()$name$map(mapping[[1]])))
    }
    if (!is_list_of_string(mapping)) {
      abort("`...` only accepts an unnamed function or named single strings.")
    }
    existing <- names(mapping)
    new <- unlist(mapping)
    self$`_ldf`$rename(existing, new, .strict)
  })
}

#' Explode the frame to long format by exploding the given columns
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column names, expressions, or
#' a selector defining them. The underlying columns being exploded must be of
#' the `List` or `Array` data type.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   letters = c("a", "a", "b", "c"),
#'   numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8))
#' )
#'
#' lf$explode("numbers")$collect()
lazyframe__explode <- function(...) {
  wrap({
    check_dots_unnamed()
    by <- parse_into_list_of_expressions(...)
    self$`_ldf`$explode(by)
  })
}

#' Clone a LazyFrame
#'
#' This makes a very cheap deep copy/clone of an existing
#' [LazyFrame]. Rarely useful as `LazyFrame`s are nearly 100%
#' immutable. Any modification of a `LazyFrame` should lead to a clone anyways,
#' but this can be useful when dealing with attributes (see examples).
#'
#'
#' @inherit as_polars_lf return
#' @examples
#' df1 <- as_polars_lf(iris)
#'
#' # Make a function to take a LazyFrame, add an attribute, and return a LazyFrame
#' give_attr <- function(data) {
#'   attr(data, "created_on") <- "2024-01-29"
#'   data
#' }
#' df2 <- give_attr(df1)
#'
#' # Problem: the original LazyFrame also gets the attribute while it shouldn't!
#' attributes(df1)
#'
#' # Use $clone() inside the function to avoid that
#' give_attr <- function(data) {
#'   data <- data$clone()
#'   attr(data, "created_on") <- "2024-01-29"
#'   data
#' }
#' df1 <- as_polars_lf(iris)
#' df2 <- give_attr(df1)
#'
#' # now, the original LazyFrame doesn't get this attribute
#' attributes(df1)
lazyframe__clone <- function() {
  self$`_ldf`$clone() |>
    wrap()
}


#' Decompose struct columns into separate columns for each of their fields
#'
#' The new columns will be inserted at the location of the struct column.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Name of the struct column(s)
#' that should be unnested.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(
#'   a = 1:5,
#'   b = c("one", "two", "three", "four", "five"),
#'   c = 6:10
#' )$
#'   select(
#'   pl$struct("b"),
#'   pl$struct(c("a", "c"))$alias("a_and_c")
#' )
#' lf$collect()
#'
#' lf$unnest("a_and_c")$collect()
#' lf$unnest(pl$col("a_and_c"))$collect()
lazyframe__unnest <- function(...) {
  wrap({
    check_dots_unnamed()
    columns <- parse_into_list_of_expressions(...)
    self$`_ldf`$unnest(columns)
  })
}

#' Create rolling groups based on a date/time or integer column
#'
#' @description
#' Different from `group_by_dynamic()`, the windows are now determined by the
#' individual values and are not of constant intervals. For constant intervals
#' use `group_by_dynamic()`.
#'
#' If you have a time series `<t_0, t_1, ..., t_n>`, then by default the
#' windows created will be:
#' * `(t_0 - period, t_0]`
#' * `(t_1 - period, t_1]`
#' * …
#' * `(t_n - period, t_n]`
#'
#' whereas if you pass a non-default `offset`, then the windows will be:
#' * `(t_0 + offset, t_0 + offset + period]`
#' * `(t_1 + offset, t_1 + offset + period]`
#' * …
#' * `(t_n + offset, t_n + offset + period]`
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams lazyframe__group_by_dynamic
#' @param period Length of the window - must be non-negative.
#' @param offset Offset of the window. Default is `-period`.
#'
#' @inherit expr__rolling_max params details
#' @return A [LazyGroupBy][LazyGroupBy_class] object
#' @seealso
#' - [`<LazyFrame>$group_by_dynamic()`][lazyframe__group_by_dynamic]
#' @examples
#' dates <- c(
#'   "2020-01-01 13:45:48",
#'   "2020-01-01 16:42:13",
#'   "2020-01-01 16:45:09",
#'   "2020-01-02 18:12:48",
#'   "2020-01-03 19:45:32",
#'   "2020-01-08 23:16:43"
#' )
#'
#' df <- pl$LazyFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
#'   pl$col("dt")$str$strptime(pl$Datetime())
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   sum_a = pl$col("a")$sum(),
#'   min_a = pl$col("a")$min(),
#'   max_a = pl$col("a")$max()
#' )$collect()
lazyframe__rolling <- function(
  index_column,
  ...,
  period,
  offset = NULL,
  closed = c("right", "left", "both", "none"),
  group_by = NULL
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    period <- parse_as_duration_string(period)
    if (!is.null(offset)) {
      offset <- parse_as_duration_string(offset)
    } else {
      offset <- negate_duration_string(period)
    }
    if (!is.null(group_by) && !is.list(group_by)) {
      group_by <- list(group_by)
    }
    by <- parse_into_list_of_expressions(!!!group_by)
    self$`_ldf`$rolling(
      as_polars_expr(index_column)$`_rexpr`,
      period,
      offset,
      closed,
      by
    )
  })
}


#' Group based on a date/time or integer column
#'
#' @description
#' Time windows are calculated and rows are assigned to windows. Different from
#' a normal group by is that a row can be member of multiple groups. By
#' default, the windows look like:
#' * [start, start + period)
#' * [start + every, start + every + period)
#' * [start + 2 * every, start + 2 * every + period)
#' * …
#'
#' where `start` is determined by `start_by`, `offset`, `every`, and the
#' earliest datapoint. See the `start_by` argument description for details.
#'
#' @inheritParams rlang::args_dots_empty
#' @param index_column Column used to group based on the time window. Often of
#' type Date/Datetime. This column must be sorted in ascending order (or, if
#' `group_by` is specified, then it must be sorted in ascending order within
#' each group).
#' In case of a dynamic group by on indices, the data type needs to be either
#' Int32 or In64. Note that Int32 gets temporarily cast to Int64, so if
#' performance matters, use an Int64 column.
#' @param every Interval of the window.
#' @param period Length of the window. If `NULL` (default), it will equal
#' `every`.
#' @param offset Offset of the window, does not take effect if
#' `start_by = "datapoint"`. Defaults to zero.
#' @param include_boundaries Add two columns `"_lower_boundary"` and
#' `"_upper_boundary"` columns that show the boundaries of the window. This will
#' impact performance because it’s harder to parallelize.
#' @param closed Define which sides of the interval are closed (inclusive).
#' Default is `"left"`.
#' @param label Define which label to use for the window:
#' * `"left"`: lower boundary of the window
#' * `"right"`: upper boundary of the window
#' * `"datapoint"`: the first value of the index column in the given window. If
#' you don’t need the label to be at one of the boundaries, choose this option
#' for maximum performance.
#' @param group_by Also group by this column/these columns. Can be expressions
#' or objects coercible to expressions.
#' @param start_by The strategy to determine the start of the first window by:
#' * `"window"`: start by taking the earliest timestamp, truncating it with
#'   `every`, and then adding `offset`. Note that weekly windows start on
#'   Monday.
#' * `"datapoint"`: start from the first encountered data point.
#' * a day of the week (only takes effect if `every` contains `"w"`): `"monday"`
#'   starts the window on the Monday before the first data point, etc.
#'
#' @details
#' The `every`, `period`, and `offset` arguments are created with the following
#' string language:
#' - 1ns # 1 nanosecond
#' - 1us # 1 microsecond
#' - 1ms # 1 millisecond
#' - 1s  # 1 second
#' - 1m  # 1 minute
#' - 1h  # 1 hour
#' - 1d  # 1 day
#' - 1w  # 1 calendar week
#' - 1mo # 1 calendar month
#' - 1y  # 1 calendar year
#' These strings can be combined:
#'   - 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' In case of a `group_by_dynamic` on an integer column, the windows are
#' defined by:
#' - 1i # length 1
#' - 10i # length 10
#'
# TODO: Add LazyGroupBy docs
#' @return A [LazyGroupBy] object
#' @seealso
#' - [`<LazyFrame>$rolling()`][lazyframe__rolling]
#'
#' @examples
#' lf <- pl$select(
#'   time = pl$datetime_range(
#'     start = strptime("2021-12-16 00:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     end = strptime("2021-12-16 03:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     interval = "30m"
#'   ),
#'   n = 0:6
#' )$lazy()
#' lf$collect()
#'
#' # Group by windows of 1 hour.
#' lf$group_by_dynamic("time", every = "1h", closed = "right")$agg(
#'   vals = pl$col("n")
#' )$collect()
#'
#' # The window boundaries can also be added to the aggregation result
#' lf$group_by_dynamic(
#'   "time",
#'   every = "1h", include_boundaries = TRUE, closed = "right"
#' )$agg(
#'   pl$col("n")$mean()
#' )$collect()
#'
#' # When closed = "left", the window excludes the right end of interval:
#' # [lower_bound, upper_bound)
#' lf$group_by_dynamic("time", every = "1h", closed = "left")$agg(
#'   pl$col("n")
#' )$collect()
#'
#' # When closed = "both" the time values at the window boundaries belong to 2
#' # groups.
#' lf$group_by_dynamic("time", every = "1h", closed = "both")$agg(
#'   pl$col("n")
#' )$collect()
#'
#' # Dynamic group bys can also be combined with grouping on normal keys
#' lf <- lf$with_columns(
#'   groups = as_polars_series(c("a", "a", "a", "b", "b", "a", "a"))
#' )
#' lf$collect()
#'
#' lf$group_by_dynamic(
#'   "time",
#'   every = "1h",
#'   closed = "both",
#'   group_by = "groups",
#'   include_boundaries = TRUE
#' )$agg(pl$col("n"))$collect()
#'
#' # We can also create a dynamic group by based on an index column
#' lf <- pl$LazyFrame(
#'   idx = 0:5,
#'   A = c("A", "A", "B", "B", "B", "C")
#' )$with_columns(pl$col("idx")$set_sorted())
#' lf$collect()
#'
#' lf$group_by_dynamic(
#'   "idx",
#'   every = "2i",
#'   period = "3i",
#'   include_boundaries = TRUE,
#'   closed = "right"
#' )$agg(A_agg_list = pl$col("A"))$collect()
lazyframe__group_by_dynamic <- function(
  index_column,
  ...,
  every,
  period = NULL,
  offset = NULL,
  include_boundaries = FALSE,
  closed = c("left", "right", "both", "none"),
  label = c("left", "right", "datapoint"),
  group_by = NULL,
  start_by = "window"
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    label <- arg_match0(label, values = c("left", "right", "datapoint"))
    start_by <- arg_match0(
      start_by,
      values = c(
        "window",
        "datapoint",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday"
      )
    )
    every <- parse_as_duration_string(every)
    offset <- parse_as_duration_string(offset) %||% "0ns"
    period <- parse_as_duration_string(period) %||% every
    group_by <- if (is_polars_expr(group_by)) {
      list(group_by$`_rexpr`)
    } else {
      parse_into_list_of_expressions(!!!group_by)
    }

    self$`_ldf`$group_by_dynamic(
      as_polars_expr(index_column)$`_rexpr`,
      every,
      period,
      offset,
      label,
      include_boundaries,
      closed,
      group_by,
      start_by
    )
  })
}

#' Plot the query plan
#'
#' This only returns the "dot" output that can be passed to other packages, such
#' as `DiagrammeR::grViz()`.
#'
#' @param ... Not used..
#' @param optimized Optimize the query plan.
#' @inheritParams lazyframe__explain
#'
#' @return A character vector
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = 1:6,
#'   c = 6:1
#' )
#'
#' query <- lf$group_by("a", .maintain_order = TRUE)$agg(
#'   pl$all()$sum()
#' )$sort("a")
#'
#' query$to_dot() |> cat()
#'
#' # You could print the graph by using DiagrammeR for example, with
#' # query$to_dot() |> DiagrammeR::grViz().
lazyframe__to_dot <- function(
  ...,
  optimized = TRUE,
  type_coercion = TRUE,
  `_type_check` = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  collapse_joins = TRUE,
  streaming = FALSE,
  `_check_order` = TRUE
) {
  ldf <- self$`_ldf`$optimization_toggle(
    type_coercion = type_coercion,
    `_type_check` = `_type_check`,
    predicate_pushdown = predicate_pushdown,
    projection_pushdown = projection_pushdown,
    simplify_expression = simplify_expression,
    slice_pushdown = slice_pushdown,
    comm_subplan_elim = comm_subplan_elim,
    comm_subexpr_elim = comm_subexpr_elim,
    cluster_with_columns = cluster_with_columns,
    collapse_joins = collapse_joins,
    streaming = streaming,
    `_check_order` = `_check_order`,
    `_eager` = FALSE
  )

  ldf$to_dot(optimized)
}

#' Create an empty or `n`-row null-filled copy of the frame
#'
#' Returns a `n`-row null-filled frame with an identical schema. `n` can be
#' greater than the current number of rows in the frame.
#'
#' @param n Number of (null-filled) rows to return in the cleared frame.
#'
#' @inherit as_polars_lf return
#' @examples
#' df <- pl$LazyFrame(
#'   a = c(NA, 2, 3, 4),
#'   b = c(0.5, NA, 2.5, 13),
#'   c = c(TRUE, TRUE, FALSE, NA)
#' )
#' df$clear()$collect()
#'
#' df$clear(n = 2)$collect()
lazyframe__clear <- function(n = 0) {
  wrap({
    cols <- names(self)
    dat <- vector("list", length(cols))
    names(dat) <- cols
    pl$DataFrame(!!!dat, .schema_overrides = self$collect_schema())$clear(n)$lazy()
  })
}

#' Take every nth row in the LazyFrame
#'
#' @param n Gather every `n`-th row.
#' @param offset Starting index.
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = 5:8)
#' lf$gather_every(2)$collect()
#'
#' lf$gather_every(2, offset = 1)$collect()
lazyframe__gather_every <- function(n, offset = 0) {
  self$select(pl$col("*")$gather_every(n, offset))
}

#' Return the number of non-null elements for each column
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, NA), c = rep(NA, 4))
#' lf$count()$collect()
lazyframe__count <- function() {
  self$`_ldf`$count() |>
    wrap()
}

#' Return the number of null elements for each column
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(a = 1:4, b = c(1, 2, 1, NA), c = rep(NA, 4))
#' lf$null_count()$collect()
lazyframe__null_count <- function() {
  self$`_ldf`$null_count() |>
    wrap()
}

#' Return the `k` smallest rows
#'
#' @description
#' Non-null elements are always preferred over null elements, regardless of the
#' value of `reverse`. The output is not guaranteed to be in any particular
#' order, call `sort()` after this function if you wish the output to be sorted.
#'
#' @inheritParams rlang::args_dots_empty
#' @param k Number of rows to return.
#' @param by Column(s) used to determine the bottom rows. Accepts expression
#' input. Strings are parsed as column names.
#' @param reverse Consider the `k` largest elements of the by column(s)
#' (instead of the k smallest). This can be specified per column by passing a
#' sequence of booleans.
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = c(2, 1, 1, 3, 2, 1)
#' )
#'
#' # Get the rows which contain the 4 smallest values in column b.
#' lf$bottom_k(4, by = "b")$collect()
#'
#' # Get the rows which contain the 4 smallest values when sorting on column a
#' # and b$
#' lf$bottom_k(4, by = c("a", "b"))$collect()
lazyframe__bottom_k <- function(k, ..., by, reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    by <- parse_into_list_of_expressions(!!!by)
    reverse <- extend_bool(reverse, length(by), "reverse", "...")
    self$`_ldf`$bottom_k(k, by, reverse)
  })
}

#' Return the `k` largest rows
#'
#' @inherit lazyframe__bottom_k description params
#' @inheritParams rlang::args_dots_empty
#' @param reverse Consider the `k` smallest elements of the `by` column(s)
#' (instead of the `k` largest). This can be specified per column by passing a
#' sequence of booleans.

#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = c(2, 1, 1, 3, 2, 1)
#' )
#'
#' # Get the rows which contain the 4 largest values in column b.
#' lf$top_k(4, by = "b")$collect()
#'
#' # Get the rows which contain the 4 largest values when sorting on column a
#' # and b
#' lf$top_k(4, by = c("a", "b"))$collect()
lazyframe__top_k <- function(k, ..., by, reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    by <- parse_into_list_of_expressions(!!!by)
    reverse <- extend_bool(reverse, length(by), "reverse", "...")
    self$`_ldf`$top_k(k, by, reverse)
  })
}

#' Interpolate intermediate values
#'
#' The interpolation method is linear.
#' @inherit as_polars_lf return
#'
#' @examples
#' lf <- pl$LazyFrame(
#'   foo = c(1, NA, 9, 10),
#'   bar = c(6, 7, 9, NA),
#'   ham = c(1, NA, NA, 9)
#' )
#'
#' lf$interpolate()$collect()
lazyframe__interpolate <- function() {
  self$select(pl$col("*")$interpolate()) |>
    wrap()
}

#' Take two sorted LazyFrames and merge them by the sorted key
#'
#' The output of this operation will also be sorted. It is the callers
#' responsibility that the frames are sorted by that key, otherwise the output
#' will not make sense. The schemas of both LazyFrames must be equal.
#'
#' @param other Other LazyFrame that must be merged.
#' @param key Key that is sorted.
#'
#' @inherit as_polars_lf return
#'
#' @examples
#' lf1 <- pl$LazyFrame(
#'   name = c("steve", "elise", "bob"),
#'   age = c(42, 44, 18)
#' )$sort("age")
#'
#' lf2 <- pl$LazyFrame(
#'   name = c("anna", "megan", "steve", "thomas"),
#'   age = c(21, 33, 42, 20)
#' )$sort("age")
#'
#' lf1$merge_sorted(lf2, key = "age")$collect()
lazyframe__merge_sorted <- function(other, key) {
  self$`_ldf`$merge_sorted(other$`_ldf`, key) |>
    wrap()
}

#' Indicate that one or multiple columns are sorted
#'
#' This can speed up future operations, but it can lead to incorrect results if
#' the data is **not** sorted! Use with care!
#'
#' @inheritParams rlang::args_dots_empty
#' @param column Column that is sorted.
#' @param descending Whether the columns are sorted in descending order.
#'
#' @inherit as_polars_lf return
lazyframe__set_sorted <- function(column, ..., descending = FALSE) {
  wrap({
    check_dots_empty0(...)
    if (length(column) != 1 || !is.character(column)) {
      abort("`column` must be a single column name.")
    }
    self$with_columns(pl$col(column)$set_sorted(descending = descending))
  })
}

#' Add a row index as the first column in the LazyFrame
#'
#' Using this function can have a negative effect on query performance. This
#' may, for instance, block predicate pushdown optimization.
#'
#' @param name Name of the index column.
#' @param offset Start the index at this offset. Cannot be negative.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf <- pl$LazyFrame(x = c(1, 3, 5), y = c(2, 4, 6))
#' lf$with_row_index()$collect()
#'
#' lf$with_row_index("id", offset = 1000)$collect()
#'
#' # An index column can also be created using the expressions int_range()
#' # and len()$
#' lf$with_columns(
#'   index = pl$int_range(pl$len(), dtype = pl$UInt32)
#' )$collect()
lazyframe__with_row_index <- function(name = "index", offset = 0) {
  wrap({
    tryCatch(
      self$`_ldf`$with_row_index(name, offset),
      error = function(e) {
        is_overflow_error <- grepl("out of range", e$message)
        if (isTRUE(is_overflow_error)) {
          issue <- if (offset < 0) {
            "negative"
          } else {
            "greater than the maximum index value"
          }
          msg <- paste0("`offset` input for `with_row_index` cannot be ", issue, ", got ", offset)
        } else {
          msg <- e$message
        }
        abort(msg, call = caller_env(4))
      }
    )
  })
}

#' Perform joins on nearest keys
#'
#' @description
#' This is similar to a left-join except that we match on nearest key rather
#' than equal keys. Both frames must be sorted by the `asof_join` key.
#'
#' @inheritParams rlang::args_dots_empty
#' @param other LazyFrame to join with.
#' @inheritParams lazyframe__join
#' @param by Join on these columns before performing asof join. Either a vector
#' of column names or a list of expressions and/or strings. Use `left_by` and
#' `right_by` if the column names to match on are different between the two
#' tables.
#' @param by_left,by_right Same as `by` but only for the left or the right
#' table. They must have the same length.
#' @param strategy Strategy for where to find match:
#' * `"backward"` (default): search for the last row in the right table whose
#'   `on` key is less than or equal to the left key.
#' * `"forward"`: search for the first row in the right table whose `on` key is
#'   greater than or equal to the left key.
#' * `"nearest"`: search for the last row in the right table whose value is
#'   nearest to the left key. String keys are not currently supported for a
#'   nearest search.
#' @param tolerance Numeric tolerance. By setting this the join will only be
#' done if the near keys are within this distance. If an asof join is done on
#' columns of dtype "Date", "Datetime", "Duration" or "Time", use the Polars
#' duration string language (see details).
#'
#' @param coalesce Coalescing behavior (merging of `on` / `left_on` /
#' `right_on` columns):
#' * `TRUE`: Always coalesce join columns;
#' * `FALSE`: Never coalesce join columns.
#' Note that joining on any other expressions than `col` will turn off
#' coalescing.
#' @param allow_exact_matches Whether exact matches are valid join predicates.
#' If `TRUE` (default), allow matching with the same on value (i.e.
#' less-than-or-equal-to / greater-than-or-equal-to). Otherwise, don’t match
#' the same on value (i.e., strictly less-than / strictly greater-than).
#' @param check_sortedness Check the sortedness of the asof keys. If the keys
#' are not sorted, polars will error, or raise a warning if the `by` argument
#' is provided. This might become a hard error in the future.
#'
#' @inheritSection polars_duration_string Polars duration string language
#' @inherit as_polars_lf return
#' @examples
#' gdp <- pl$LazyFrame(
#'   date = as.Date(c("2016-1-1", "2017-5-1", "2018-1-1", "2019-1-1", "2020-1-1")),
#'   gdp = c(4164, 4411, 4566, 4696, 4827)
#' )
#'
#' pop <- pl$LazyFrame(
#'   date = as.Date(c("2016-3-1", "2018-8-1", "2019-1-1")),
#'   population = c(82.19, 82.66, 83.12)
#' )
#'
#' # optional make sure tables are already sorted with "on" join-key
#' gdp <- gdp$sort("date")
#' pop <- pop$sort("date")
#'
#'
#' # Note how the dates don’t quite match. If we join them using join_asof and
#' # strategy = 'backward', then each date from population which doesn’t have
#' # an exact match is matched with the closest earlier date from gdp:
#' pop$join_asof(gdp, on = "date", strategy = "backward")$collect()
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2016-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2018-01-01 from gdp.
#' # You can verify this by passing coalesce = FALSE:
#' pop$join_asof(
#'   gdp,
#'   on = "date", strategy = "backward", coalesce = FALSE
#' )$collect()
#'
#' # If we instead use strategy = 'forward', then each date from population
#' # which doesn’t have an exact match is matched with the closest later date
#' # from gdp:
#' pop$join_asof(gdp, on = "date", strategy = "forward")$collect()
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2017-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2019-01-01 from gdp.
#'
#' # Finally, strategy = 'nearest' gives us a mix of the two results above, as
#' # each date from population which doesn’t have an exact match is matched
#' # with the closest date from gdp, regardless of whether it’s earlier or
#' # later:
#' pop$join_asof(gdp, on = "date", strategy = "nearest")$collect()
#'
#' # Note how:
#' # - date 2016-03-01 from population is matched with 2016-01-01 from gdp;
#' # - date 2018-08-01 from population is matched with 2019-01-01 from gdp.
#'
#' # The `by` argument allows joining on another column first, before the asof
#' # join. In this example we join by country first, then asof join by date, as
#' # above.
#' gdp2 <- pl$LazyFrame(
#'   country = rep(c("Germany", "Netherlands"), each = 5),
#'   date = rep(
#'     as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1", "2020-1-1")),
#'     2
#'   ),
#'   gdp = c(4164, 4411, 4566, 4696, 4827, 784, 833, 914, 910, 909)
#' )$sort("country", "date")
#' gdp2$collect()
#'
#' pop2 <- pl$LazyFrame(
#'   country = rep(c("Germany", "Netherlands"), each = 3),
#'   date = rep(as.Date(c("2016-3-1", "2018-8-1", "2019-1-1")), 2),
#'   population = c(82.19, 82.66, 83.12, 17.11, 17.32, 17.40)
#' )$sort("country", "date")
#' pop2$collect()
#'
#' pop2$join_asof(
#'   gdp2,
#'   by = "country", on = "date", strategy = "nearest"
#' )$collect()
lazyframe__join_asof <- function(
  other,
  ...,
  left_on = NULL,
  right_on = NULL,
  on = NULL,
  by_left = NULL,
  by_right = NULL,
  by = NULL,
  strategy = c("backward", "forward", "nearest"),
  suffix = "_right",
  tolerance = NULL,
  allow_parallel = TRUE,
  force_parallel = FALSE,
  coalesce = TRUE,
  allow_exact_matches = TRUE,
  check_sortedness = TRUE
) {
  wrap({
    check_dots_empty0(...)
    strategy <- arg_match0(strategy, values = c("backward", "forward", "nearest"))
    if (!is.null(by)) by_left <- by_right <- by
    if (!is.null(on)) left_on <- right_on <- on

    tolerance_str <- NULL
    tolerance_num <- NULL
    if (is_string(tolerance)) {
      tolerance_str <- tolerance
    } else if (!is.null(tolerance)) {
      # TODO: duration string conversion support
      series <- as_polars_series(tolerance)
      if (series$len() == 1L) {
        tolerance_num <- series$`_s`
      } else {
        abort(
          c(
            "invalid `tolerance`. `tolerance` must be one of the followings:",
            `*` = "`NULL`.",
            `*` = "A single string.",
            `*` = "Something convertible to a Polars Series of length 1."
          )
        )
      }
    }

    self$`_ldf`$join_asof(
      other = other$`_ldf`,
      left_on = as_polars_expr(left_on)$`_rexpr`,
      right_on = as_polars_expr(right_on)$`_rexpr`,
      left_by = by_left,
      right_by = by_right,
      allow_parallel = allow_parallel,
      force_parallel = force_parallel,
      suffix = suffix,
      strategy = strategy,
      tolerance = tolerance_num,
      tolerance_str = tolerance_str,
      coalesce = coalesce,
      allow_eq = allow_exact_matches,
      check_sortedness = check_sortedness
    )
  })
}

#' Creates a summary of statistics for a LazyFrame, returning a DataFrame.
#'
#' @description
#' This method does not maintain the laziness of the frame, and will collect
#' the final result. This could potentially be an expensive operation.
#'
#' We do not guarantee the output of `describe()` to be stable. It will show
#' statistics that we deem informative, and may be updated in the future. Using
#' `describe()` programmatically (versus interactive exploration) is not
#' recommended for this reason.
#'
#' @inheritParams rlang::args_dots_empty
#' @param percentiles One or more percentiles to include in the summary
#' statistics. All values must be in the range `[0; 1]`.
#' @param interpolation Interpolation method for computing quantiles. Must be
#' one of `"nearest"`, `"higher"`, `"lower"`, `"midpoint"`, or `"linear"`.
#'
#' @details
#' The median is included by default as the 50% percentile.
#'
#' @inherit as_polars_df return
#' @examples
#' lf <- pl$LazyFrame(
#'   int = 1:3,
#'   float = c(0.5, NA, 2.5),
#'   string = c(letters[1:2], NA),
#'   date = c(as.Date("2024-01-20"), as.Date("2024-01-21"), NA),
#'   cat = factor(c(letters[1:2], NA)),
#'   bool = c(TRUE, FALSE, NA)
#' )
#' lf$collect()
#'
#' # Show default frame statistics:
#' lf$describe()
#'
#' # Customize which percentiles are displayed, applying linear interpolation:
#' lf$describe(
#'   percentiles = c(0.1, 0.3, 0.5, 0.7, 0.9),
#'   interpolation = "linear"
#' )
lazyframe__describe <- function(
  percentiles = c(0.25, 0.5, 0.75),
  ...,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  wrap({
    check_dots_empty0(...)
    schema <- self$collect_schema()
    if (length(schema) == 0) {
      abort("Can't describe a LazyFrame without any columns")
    }

    # create list of metrics
    metrics <- c("count", "null_count", "mean", "std", "min")
    quantiles <- parse_percentiles(percentiles)
    if (length(quantiles) > 0) {
      metrics <- c(metrics, paste0(percentiles * 100, "%"))
    }
    metrics <- c(metrics, "max")

    skip_minmax <- function(x) {
      dtypes <- class(dtype)
      dtype$is_nested() ||
        inherits(
          dtypes,
          c(
            "polars_dtype_categorical",
            "polars_dtype_enum",
            "polars_dtype_null",
            "polars_dtype_unknown"
          )
        )
    }

    # determine which columns will produce std/mean/percentile/etc
    # statistics in a single pass over the frame schema
    has_numeric_result <- c()
    sort_cols <- c()
    metric_exprs <- list()

    for (i in seq_along(schema)) {
      name <- names(schema)[i]
      dtype <- schema[[i]]

      is_numeric <- dtype$is_numeric()
      is_temporal <- !is_numeric && dtype$is_temporal()

      # counts
      count_exprs <- c(
        pl$col(name)$count()$name$prefix("count:"),
        pl$col(name)$null_count()$name$prefix("null_count:")
      )

      # mean
      mean_expr <- if (is_temporal || is_numeric || inherits(dtype, "polars_dtype_boolean")) {
        pl$col(name)$mean()
      } else {
        pl$lit(NA, dtype = dtype)
      }

      # standard deviation, min, max
      expr_std <- if (is_numeric) {
        pl$col(name)$std()
      } else {
        pl$lit(NA, dtype = dtype)
      }
      min_expr <- if (!skip_minmax(dtype)) {
        pl$col(name)$min()
      } else {
        pl$lit(NA, dtype = dtype)
      }
      max_expr <- if (!skip_minmax(dtype)) {
        pl$col(name)$max()
      } else {
        pl$lit(NA, dtype = dtype)
      }

      # percentiles
      pct_exprs <- c()
      for (index_quantile in seq_along(quantiles)) {
        p <- quantiles[index_quantile]
        pct_expr <- if (is_temporal) {
          pl$col(name)$to_physical()$quantile(p, interpolation)$cast(dtype)
        } else if (is_numeric) {
          pl$col(name)$quantile(p, interpolation)
        } else {
          pl$lit(NA, dtype = dtype)
        }
        sort_cols <- c(sort_cols, name)
        pct_exprs <- c(pct_exprs, pct_expr$alias(paste0(p, ":", name)))
      }

      if (
        is_numeric ||
          dtype$is_nested() ||
          inherits(self, "polars_dtype_null") ||
          inherits(dtype, "polars_dtype_boolean")
      ) {
        has_numeric_result <- c(has_numeric_result, name)
      }

      # add column expressions (in end-state 'metrics' list order)
      metric_exprs <- c(
        metric_exprs,
        count_exprs,
        mean_expr$alias(paste0("mean:", name)),
        expr_std$alias(paste0("std:", name)),
        min_expr$alias(paste0("min:", name)),
        pct_exprs,
        max_expr$alias(paste0("max:", name))
      )
    }

    # calculate requested metrics in parallel, then collect the result
    df_metrics <- if (length(sort_cols) > 0) {
      self$with_columns(pl$col(!!!unique(sort_cols))$sort())
    } else {
      self
    }

    df_metrics <- df_metrics$select(!!!metric_exprs)$collect()

    # Cast by column type (numeric/bool -> float), (other -> string)
    # This is done later in py-polars but we need to do it here. When we gather
    # values in the list, we coerce the types, meaning that stats for date (for
    # instance) are coerced to numeric. Casting those to string beforehand
    # fixes this.
    df_metrics_schema <- df_metrics$schema
    for (i in seq_along(df_metrics_schema)) {
      nm <- names(df_metrics_schema)[i]
      dtype <- df_metrics_schema[[i]]
      df_metrics_dtype <- if (dtype$is_numeric() || inherits(dtype, "polars_dtype_boolean")) {
        pl$Float64
      } else {
        pl$String
      }
      df_metrics <- df_metrics$with_columns(pl$col(names(df_metrics_schema)[i])$cast(
        df_metrics_dtype
      ))
    }

    # From the 1 x (metrics * variables) table, we extract the stats for each
    # variable in a list with length(metrics) elements.
    # Probably could be optimized.
    output <- vector("list", length = length(schema))
    names(output) <- names(schema)
    for (nm in seq_along(names(output))) {
      for (i in seq_along(metrics)) {
        output[[nm]][i] <- as.vector(df_metrics$to_series((nm - 1) * length(metrics) + i - 1))
      }
    }

    append(list(statistic = metrics), output) |>
      as_polars_df()
  })
}

#' Execute a SQL query against the LazyFrame
#'
#' @inheritParams rlang::args_dots_empty
#' @param query SQL query to execute.
#' @param table_name Optionally provide an explicit name for the table that
#' represents the calling frame (defaults to `"self"`).
#'
#' @details
#' The calling frame is automatically registered as a table in the SQL context
#' under the name `"self"`. If you want access to the DataFrames and LazyFrames
#' found in the current globals, use the top-level [`pl$sql()`][pl__sql].
#'
#' More control over registration and execution behaviour is available by using
#' the [`SQLContext`][pl__SQLContext] object.
#'
#' @inherit as_polars_lf return
#' @examples
#' lf1 <- pl$LazyFrame(a = 1:3, b = 6:8, c = c("z", "y", "x"))
#'
#' # Query the LazyFrame using SQL:
#' lf1$sql("SELECT c, b FROM self WHERE a > 1")$collect()
#'
#' # Apply SQL transforms (aliasing "self" to "frame") then filter natively
#' # (you can freely mix SQL and native operations):
#' lf1$sql(
#'   query = "
#'        SELECT
#'           a,
#'           (a % 2 == 0) AS a_is_even,
#'           (b::float4 / 2) AS 'b/2',
#'           CONCAT_WS(':', c, c, c) AS c_c_c
#'        FROM frame
#'        ORDER BY a
#'  ",
#'   table_name = "frame",
#' )$filter(!pl$col("c_c_c")$str$starts_with("x"))$collect()
lazyframe__sql <- function(query, ..., table_name = "self") {
  wrap({
    check_dots_empty0(...)
    ctx <- pl$SQLContext()
    ctx$register(name = table_name, frame = self)
    ctx$execute(query)
  })
}
