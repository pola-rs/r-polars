#' Inner workings of the LazyFrame-class
#'
#' @name LazyFrame_class
#' @aliases RPolarsLazyFrame
#' @description The `LazyFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the polars rust side. The
#' instantiated `LazyFrame`-object is an `externalptr` to a lowlevel rust polars
#' LazyFrame  object. The pointer address is the only statefullness of the
#' LazyFrame object on the R side. Any other state resides on the rust side. The
#' S3 method `.DollarNames.RPolarsLazyFrame` exposes all public `$foobar()`-methods which
#' are callable onto the object.
#'
#' Most methods return another `LazyFrame`-class instance or similar which allows
#' for method chaining. This class system in lack of a better name could be called
#' "environment classes" and is the same class system extendr provides, except
#' here there is both a public and private set of methods. For implementation
#' reasons, the private methods are external and must be called from
#' `.pr$LazyFrame$methodname()`. Also, all private methods must take
#' any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' `DataFrame` and `LazyFrame` can both be said to be a `Frame`. To convert use
#' [`<DataFrame>$lazy()`][DataFrame_lazy] and [`<LazyFrame>$collect()`][LazyFrame_collect].
#' You can also create a `LazyFrame` directly with [`pl$LazyFrame()`][pl_LazyFrame].
#' This is quite similar to the lazy-collect syntax of the `dplyr` package to
#' interact with database connections such as SQL variants. Most SQL databases
#' would be able to perform the same optimizations as polars such predicate pushdown
#' and projection pushdown. However polars can interact and optimize queries with both
#' SQL DBs and other data sources such parquet files simultaneously.
#'
#' @section Active bindings:
#'
#' ## columns
#'
#' `$columns` returns a character vector with the column names.
#'
#' ## dtypes
#'
#' `$dtypes` returns a unnamed list with the [data type][pl_dtypes] of each column.
#'
#' ## schema
#'
#' `$schema` returns a named list with the [data type][pl_dtypes] of each column.
#'
#' ## width
#'
#' `$width` returns the number of columns in the LazyFrame.
#'
#' @inheritSection DataFrame_class Conversion to R data types considerations
#' @keywords LazyFrame
#' @examples
#' # see all exported methods
#' ls(.pr$env$RPolarsLazyFrame)
#'
#' # see all private methods (not intended for regular use)
#' ls(.pr$LazyFrame)
#'
#'
#' ## Practical example ##
#' # First writing R iris dataset to disk, to illustrte a difference
#' temp_filepath = tempfile()
#' write.csv(iris, temp_filepath, row.names = FALSE)
#'
#' # Following example illustrates 2 ways to obtain a LazyFrame
#'
#' # The-Okay-way: convert an in-memory DataFrame to LazyFrame
#'
#' # eager in-mem R data.frame
#' Rdf = read.csv(temp_filepath)
#'
#' # eager in-mem polars DataFrame
#' Pdf = as_polars_df(Rdf)
#'
#' # lazy frame starting from in-mem DataFrame
#' Ldf_okay = Pdf$lazy()
#'
#' # The-Best-Way:  LazyFrame created directly from a data source is best...
#' Ldf_best = pl$scan_csv(temp_filepath)
#'
#' # ... as if to e.g. filter the LazyFrame, that filtering also caleld predicate will be
#' # pushed down in the executation stack to the csv_reader, and thereby only bringing into
#' # memory the rows matching to filter.
#' # apply filter:
#' filter_expr = pl$col("Species") == "setosa" # get only rows where Species is setosa
#' Ldf_okay = Ldf_okay$filter(filter_expr) # overwrite LazyFrame with new
#' Ldf_best = Ldf_best$filter(filter_expr)
#'
#' # the non optimized plans are similar, on entire in-mem csv, apply filter
#' Ldf_okay$explain(optimized = FALSE)
#' Ldf_best$explain(optimized = FALSE)
#'
#' # NOTE For Ldf_okay, the full time to load csv alrady paid when creating Rdf and Pdf
#'
#' # The optimized plan are quite different, Ldf_best will read csv and perform filter simultaneously
#' Ldf_okay$explain()
#' Ldf_best$explain()
#'
#'
#' # To acquire result in-mem use $colelct()
#' Pdf_okay = Ldf_okay$collect()
#' Pdf_best = Ldf_best$collect()
#'
#'
#' # verify tables would be the same
#' all.equal(
#'   Pdf_okay$to_data_frame(),
#'   Pdf_best$to_data_frame()
#' )
#'
#' # a user might write it as a one-liner like so:
#' Pdf_best2 = pl$scan_csv(temp_filepath)$filter(pl$col("Species") == "setosa")
NULL


# Active bindings

LazyFrame_columns = method_as_active_binding(
  \() {
    self$schema |>
      names() |>
      result() |>
      unwrap("in $columns")
  }
)


LazyFrame_dtypes = method_as_active_binding(
  \() {
    self$schema |>
      unlist() |>
      unname() |>
      result() |>
      unwrap("in $dtypes")
  }
)


LazyFrame_schema = method_as_active_binding(
  \() {
    .pr$LazyFrame$schema(self) |>
      unwrap("in $schema:")
  }
)


LazyFrame_width = method_as_active_binding(\() length(self$schema))


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x LazyFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd

.DollarNames.RPolarsLazyFrame = function(x, pattern = "") {
  paste0(ls(RPolarsLazyFrame, pattern = pattern), completion_symbols$method)
}

#' Create new LazyFrame
#'
#' This is simply a convenience function to create `LazyFrame`s in a quick way.
#' It is a wrapper around `pl$DataFrame()$lazy()`. Note that this should only
#' be used for making examples and quick demonstrations.
#'
#' @name pl_LazyFrame
#'
#' @param ... Anything that is accepted by `pl$DataFrame()`
#'
#' @return [LazyFrame][LazyFrame_class]
#'
#' @examples
#' pl$LazyFrame(
#'   a = list(c(1, 2, 3, 4, 5)),
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1:1, 1:2, 1:3, 1:4, 1:5)
#' ) # directly from vectors
#'
#' # from a list of vectors or data.frame
#' pl$LazyFrame(list(
#'   a = c(1, 2, 3, 4, 5),
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1L, 1:2, 1:3, 1:4, 1:5)
#' ))
#'
#' # custom schema
#' pl$LazyFrame(
#'   iris,
#'   schema = list(Sepal.Length = pl$Float32, Species = pl$String)
#' )$collect()
pl_LazyFrame = function(...) {
  pl$DataFrame(...)$lazy()
}

#' print LazyFrame s3 method
#' @keywords LazyFrame
#' @param x DataFrame
#' @param ... not used
#' @keywords LazyFrame
#'
#' @noRd
#' @return self
#' @export
#'
#' @examples pl$LazyFrame(iris)
print.RPolarsLazyFrame = function(x, ...) {
  cat("polars LazyFrame\n")
  cat(" $explain(): Show the optimized query plan.\n")
  cat("\n")
  cat("Naive plan:\n")
  cloned_x = x$print()
  invisible(cloned_x)
}

#' print LazyFrame internal method
#' @description can be used i the middle of a method chain
#' @param x LazyFrame
#' @keywords LazyFrame
#'
#' @return self
#' @docType NULL
#'
#' @usage LazyFrame_print(x)
#' @examples pl$LazyFrame(iris)$print()
LazyFrame_print = function() {
  .pr$LazyFrame$print(self) |>
    unwrap("in $print():")
  invisible(self)
}

#' Create a string representation of the query plan
#'
#' The query plan is read from bottom to top. When `optimized = FALSE`, the
#' query as it was written by the user is shown. This is not what Polars runs.
#' Instead, it applies optimizations that are displayed by default by `$explain()`.
#' One classic example is the predicate pushdown, which applies the filter as
#' early as possible (i.e. at the bottom of the plan).
#'
#' @inheritParams LazyFrame_collect
#' @param format The format to use for displaying the logical plan. Must be either
#' `"plain"` (default) or `"tree"`.
#' @param optimized Return an optimized query plan. If `TRUE` (default), the
#' subsequent optimization flags control which optimizations run.
#' @inheritParams LazyFrame_set_optimization_toggle
#'
#' @return A character value containing the query plan.
#' @examples
#' lazy_frame = pl$LazyFrame(iris)
#'
#' # Prepare your query
#' lazy_query = lazy_frame$sort("Species")$filter(pl$col("Species") != "setosa")
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
LazyFrame_explain = function(
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
  uw = \(res) unwrap(res, "in $explain():")

  if (!is.character(format) || !format %in% c("plain", "tree")) {
    Err_plain(r"(`format` must be one of `"plain"` or `"tree"`.)") |>
      uw()
  }

  ldf = self

  if (isTRUE(optimized)) {
    ldf = ldf |>
      .pr$LazyFrame$set_optimization_toggle(
        type_coercion = type_coercion,
        predicate_pushdown = predicate_pushdown,
        projection_pushdown = projection_pushdown,
        simplify_expression = simplify_expression,
        slice_pushdown = slice_pushdown,
        comm_subplan_elim = comm_subplan_elim,
        comm_subexpr_elim = comm_subexpr_elim,
        cluster_with_columns = cluster_with_columns,
        streaming = streaming,
        eager = FALSE
      ) |>
      uw()

    if (format == "tree") {
      out = ldf |>
        .pr$LazyFrame$describe_optimized_plan_tree()
    } else {
      out = ldf |>
        .pr$LazyFrame$describe_optimized_plan()
    }
  } else {
    if (format == "tree") {
      out = ldf |>
        .pr$LazyFrame$describe_plan_tree()
    } else {
      out = ldf |>
        .pr$LazyFrame$describe_plan()
    }
  }

  out |>
    uw()
}


#' Serialize the logical plan of this LazyFrame to a file or string in JSON format
#'
#' Note that not all LazyFrames can be serialized. For example, LazyFrames that
#' contain UDFs such as [`$map_elements()`][Expr_map_elements] cannot be serialized.
#'
#' @return A character of the JSON representation of the logical plan
#' @seealso
#' - [`pl$deserialize_lf()`][pl_deserialize_lf]
#' @examples
#' lf = pl$LazyFrame(a = 1:3)$sum()
#' json = lf$serialize()
#' json
#'
#' # The logical plan can later be deserialized back into a LazyFrame.
#' pl$deserialize_lf(json)$collect()
LazyFrame_serialize = function() {
  .pr$LazyFrame$serialize(self) |>
    unwrap("in $serialize():")
}


#' Read a logical plan from a JSON file to construct a LazyFrame
#' @inherit pl_LazyFrame return
#' @param json A character of the JSON representation of the logical plan.
#' @seealso
#' - [`<LazyFrame>$serialize()`][LazyFrame_serialize]
#' @examples
#' lf = pl$LazyFrame(a = 1:3)$sum()
#' json = lf$serialize()
#' pl$deserialize_lf(json)$collect()
pl_deserialize_lf = function(json) {
  .pr$LazyFrame$deserialize(json) |>
    unwrap("in pl$deserialize_lf():")
}


#' @title Select and modify columns of a LazyFrame
#' @inherit DataFrame_select description params
#' @return A LazyFrame
#' @examples
#' pl$LazyFrame(iris)$select(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
LazyFrame_select = function(...) {
  .pr$LazyFrame$select(self, unpack_list(..., .context = "in $select()")) |>
    unwrap("in $select()")
}

#' @inherit LazyFrame_select title
#' @inherit DataFrame_select_seq description params
#' @return A LazyFrame
#' @examples
#' pl$LazyFrame(iris)$select_seq(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
LazyFrame_select_seq = function(...) {
  .pr$LazyFrame$select_seq(self, unpack_list(..., .context = "in $select_seq()")) |>
    unwrap("in $select_seq()")
}

#' Select and modify columns of a LazyFrame
#'
#' @inherit DataFrame_with_columns description params
#'
#' @return A LazyFrame
#' @examples
#' pl$LazyFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#'
#' # same query
#' l_expr = list(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#' pl$LazyFrame(iris)$with_columns(l_expr)
#'
#' pl$LazyFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), # not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width") + 2)
#' )
LazyFrame_with_columns = function(...) {
  .pr$LazyFrame$with_columns(self, unpack_list(..., .context = "in $with_columns()")) |>
    unwrap("in $with_columns()")
}

#' @inherit LazyFrame_with_columns title
#' @inherit DataFrame_with_columns_seq description params
#'
#' @return A LazyFrame
#' @examples
#' pl$LazyFrame(iris)$with_columns_seq(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#'
#' # same query
#' l_expr = list(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
#' )
#' pl$LazyFrame(iris)$with_columns_seq(l_expr)
#'
#' pl$LazyFrame(iris)$with_columns_seq(
#'   pl$col("Sepal.Length")$abs(), # not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width") + 2)
#' )
LazyFrame_with_columns_seq = function(...) {
  .pr$LazyFrame$with_columns_seq(self, unpack_list(..., .context = "in $with_columns_seq()")) |>
    unwrap("in $with_columns_seq()")
}


#' @inherit DataFrame_with_row_index title description params
#' @return A new LazyFrame with a counter column in front
#' @docType NULL
#' @examples
#' df = pl$LazyFrame(mtcars)
#'
#' # by default, the index starts at 0 (to mimic the behavior of Python Polars)
#' df$with_row_index("idx")
#'
#' # but in R, we use a 1-index
#' df$with_row_index("idx", offset = 1)
LazyFrame_with_row_index = function(name, offset = NULL) {
  .pr$LazyFrame$with_row_index(self, name, offset) |>
    unwrap("in $with_row_index():")
}


#' Apply filter to LazyFrame
#'
#' Filter rows with an Expression defining a boolean column.
#' Multiple expressions are combined with `&` (AND).
#' This is equivalent to [dplyr::filter()].
#'
#' Rows where the condition returns `NA` are dropped.
#' @keywords LazyFrame
#' @param ... Polars expressions which will evaluate to a boolean.
#' @return A new `LazyFrame` object with add/modified column.
#' @docType NULL
#' @examples
#' lf = pl$LazyFrame(iris)
#'
#' lf$filter(pl$col("Species") == "setosa")$collect()
#'
#' # This is equivalent to
#' # lf$filter(pl$col("Sepal.Length") > 5 & pl$col("Petal.Width") < 1)
#' lf$filter(pl$col("Sepal.Length") > 5, pl$col("Petal.Width") < 1)
LazyFrame_filter = function(...) {
  bool_expr = unpack_bool_expr_result(...) |>
    unwrap("in $filter()")

  .pr$LazyFrame$filter(self, bool_expr)
}

#' @title Get optimization settings
#' @description Get the current optimization toggles for the lazy query
#' @keywords LazyFrame
#' @return List of optimization toggles
#' @examples
#' pl$LazyFrame(mtcars)$get_optimization_toggle()
LazyFrame_get_optimization_toggle = function() {
  self |>
    .pr$LazyFrame$get_optimization_toggle()
}

#' @title Configure optimization toggles
#' @description Configure the optimization toggles for the lazy query
#' @keywords LazyFrame
#' @param type_coercion Logical. Coerce types such that operations succeed and
#' run on minimal required memory.
#' @param predicate_pushdown Logical. Applies filters as early as possible at
#' scan level.
#' @param projection_pushdown Logical. Select only the columns that are needed
#' at the scan level.
#' @param simplify_expression Logical. Various optimizations, such as constant
#' folding and replacing expensive operations with faster alternatives.
#' @param slice_pushdown Logical. Only load the required slice from the scan
#' level. Don't materialize sliced outputs (e.g. `join$head(10)`).
#' @param comm_subplan_elim Logical. Will try to cache branching subplans that
#'  occur on self-joins or unions.
#' @param comm_subexpr_elim Logical. Common subexpressions will be cached and
#' reused.
#' @param cluster_with_columns Combine sequential independent calls to
#' [`with_columns()`][DataFrame_with_columns].
#' @param streaming Logical. Run parts of the query in a streaming fashion
#' (this is in an alpha state).
#' @param eager Logical. Run the query eagerly.
#' @return LazyFrame with specified optimization toggles
#' @examples
#' pl$LazyFrame(mtcars)$set_optimization_toggle(type_coercion = FALSE)
LazyFrame_set_optimization_toggle = function(
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    streaming = FALSE,
    eager = FALSE) {
  self |>
    .pr$LazyFrame$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim,
      comm_subexpr_elim,
      cluster_with_columns,
      streaming,
      eager
    )
}

#' @title Collect a query into a DataFrame
#' @description `$collect()` performs the query on the LazyFrame. It returns a
#' DataFrame
#' @inheritParams LazyFrame_set_optimization_toggle
#' @param ... Ignored.
#' @param no_optimization  Logical. Sets the following parameters to `FALSE`:
#'  `predicate_pushdown`, `projection_pushdown`, `slice_pushdown`,
#'  `comm_subplan_elim`, `comm_subexpr_elim`, `cluster_with_columns`.
#' @param inherit_optimization  Logical. Use existing optimization settings
#' regardless the settings specified in this function call.
#' @param collect_in_background Logical. Detach this query from R session.
#' Computation will start in background. Get a handle which later can be converted
#' into the resulting DataFrame. Useful in interactive mode to not lock R session.
#' @details
#' Note: use `$fetch(n)` if you want to run your query on the first `n` rows only.
#' This can be a huge time saver in debugging queries.
#' @keywords LazyFrame DataFrame_new
#' @return A `DataFrame`
#' @examples
#' pl$LazyFrame(iris)$filter(pl$col("Species") == "setosa")$collect()
#' @seealso
#'  - [`$fetch()`][LazyFrame_fetch] - fast limited query check
#'  - [`$profile()`][LazyFrame_profile] - same as `$collect()` but also returns
#'    a table with each operation profiled.
#'  - [`$collect_in_background()`][LazyFrame_collect_in_background] - non-blocking
#'    collect returns a future handle. Can also just be used via
#'    `$collect(collect_in_background = TRUE)`.
#'  - [`$sink_parquet()`][LazyFrame_sink_parquet()] streams query to a parquet file.
#'  - [`$sink_ipc()`][LazyFrame_sink_ipc()] streams query to a arrow file.

LazyFrame_collect = function(
    ...,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    streaming = FALSE,
    no_optimization = FALSE,
    inherit_optimization = FALSE,
    collect_in_background = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
    comm_subplan_elim = FALSE
    comm_subexpr_elim = FALSE
    cluster_with_columns = FALSE
  }

  if (isTRUE(streaming)) {
    comm_subplan_elim = FALSE
  }

  collect_f = ifelse(isTRUE(collect_in_background), \(...) Ok(.pr$LazyFrame$collect_in_background(...)), .pr$LazyFrame$collect)

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim,
      comm_subexpr_elim,
      cluster_with_columns,
      streaming
    ) |> unwrap("in $collect():")
  }

  lf |>
    collect_f() |>
    unwrap("in $collect():")
}


#' @title Collect a query in background
#' @description This doesn't block the R session as it calls `$collect()` in a
#' a detached thread. This can also be used via `$collect(collect_in_background = TRUE)`.
#'
#' @details
#' This function immediately returns an [RThreadHandle][RThreadHandle_class].
#' Use [`<RPolarsRThreadHandle>$is_finished()`][RThreadHandle_is_finished] to see if done.
#' Use [`<RPolarsRThreadHandle>$join()`][RThreadHandle_join] to wait and get the final result.
#'
#' It is useful to not block the R session while query executes. If you use
#' [`<Expr>$map_batches()`][Expr_map_batches] or
#' [`<Expr>$map_elements()`][Expr_map_elements] to run R functions in the query,
#' then you must pass `in_background = TRUE` in [`$map_batches()`][Expr_map_batches] (or
#' [`$map_elements()`][Expr_map_elements]). Otherwise, `$collect_in_background()` will fail because
#' the main R session is not available for polars execution. See also examples
#' below.
#'
#' @keywords LazyFrame DataFrame_new
#' @return RThreadHandle, a future-like thread handle for the task
#' @examples
#' # Some expression which does contain a map
#' expr = pl$col("mpg")$map_batches(
#'   \(x) {
#'     Sys.sleep(.1)
#'     x * 0.43
#'   },
#'   in_background = TRUE # set TRUE if collecting in background queries with $map or $apply
#' )$alias("kml")
#'
#' # return is immediately a handle to another thread.
#' handle = pl$LazyFrame(mtcars)$with_columns(expr)$collect_in_background()
#'
#' # ask if query is done
#' if (!handle$is_finished()) print("not done yet")
#'
#' # get result, blocking until polars query is done
#' df = handle$join()
#' df
LazyFrame_collect_in_background = function() {
  .pr$LazyFrame$collect_in_background(self)
}

#' @title Stream the output of a query to a Parquet file
#' @description
#' This writes the output of a query directly to a Parquet file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#' @param path A character. File path to which the file should be written.
#' @param ... Ignored.
#' @param compression String. The compression method. One of:
#' * "lz4": fast compression/decompression.
#' * "uncompressed"
#' * "snappy": this guarantees that the parquet file will be compatible with
#'   older parquet readers.
#' * "gzip"
#' * "lzo"
#' * "brotli"
#' * "zstd": good compression performance.
#' @param compression_level `NULL` or Integer. The level of compression to use.
#'  Only used if method is one of 'gzip', 'brotli', or 'zstd'. Higher compression
#'  means smaller files on disk:
#'  * "gzip": min-level: 0, max-level: 10.
#'  * "brotli": min-level: 0, max-level: 11.
#'  * "zstd": min-level: 1, max-level: 22.
#' @param statistics Whether statistics should be written to the Parquet
#' headers. Possible values:
#' * `TRUE`: enable default set of statistics (default)
#' * `FALSE`: disable all statistics
#' * `"full"`: calculate and write all available statistics.
#' * A named list where all values must be `TRUE` or `FALSE`, e.g.
#'   `list(min = TRUE, max = FALSE)`. Statistics available are `"min"`, `"max"`,
#'   `"distinct_count"`, `"null_count"`.
#' @param row_group_size `NULL` or Integer. Size of the row groups in number of
#' rows. If `NULL` (default), the chunks of the DataFrame are used. Writing in
#' smaller chunks may reduce memory pressure and improve writing speeds.
#' @param data_page_size Size of the data page in bytes. If `NULL` (default), it
#' is set to 1024^2 bytes.
#' will be ~1MB.
#' @param maintain_order Maintain the order in which data is processed. Setting
#' this to `FALSE` will be slightly faster.
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#' @inheritParams LazyFrame_collect
#'
#' @rdname IO_sink_parquet
#' @return Invisibly returns the input LazyFrame
#'
#' @examples
#' # sink table 'mtcars' from mem to parquet
#' tmpf = tempfile()
#' pl$LazyFrame(mtcars)$sink_parquet(tmpf)
#'
#' # stream a query end-to-end
#' tmpf2 = tempfile()
#' pl$scan_parquet(tmpf)$select(pl$col("cyl") * 2)$sink_parquet(tmpf2)
#'
#' # load parquet directly into a DataFrame / memory
#' pl$scan_parquet(tmpf2)$collect()
LazyFrame_sink_parquet = function(
    path,
    ...,
    compression = "zstd",
    compression_level = 3,
    statistics = TRUE,
    row_group_size = NULL,
    data_page_size = NULL,
    maintain_order = TRUE,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim = FALSE,
      comm_subexpr_elim = FALSE,
      streaming = FALSE
    ) |> unwrap("in $sink_parquet()")
  }

  statistics = translate_statistics(statistics) |>
    unwrap("in $sink_parquet():")

  lf |>
    .pr$LazyFrame$sink_parquet(
      path,
      compression,
      compression_level,
      statistics,
      row_group_size,
      data_page_size,
      maintain_order
    ) |>
    unwrap("in $sink_parquet():")

  invisible(self)
}


#' Stream the output of a query to an Arrow IPC file
#'
#' This writes the output of a query directly to an Arrow IPC file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#' @param compression `NULL` or a character of the compression method,
#' `"uncompressed"` or "lz4" or "zstd". `NULL` is equivalent to `"uncompressed"`.
#' Choose "zstd" for good compression performance. Choose "lz4"
#' for fast compression/decompression.
#' @inheritParams LazyFrame_sink_parquet
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#'
#' @inherit LazyFrame_sink_parquet return
#'
#' @rdname IO_sink_ipc
#'
#' @examples
#' # sink table 'mtcars' from mem to ipc
#' tmpf = tempfile()
#' pl$LazyFrame(mtcars)$sink_ipc(tmpf)
#'
#' # stream a query end-to-end (not supported yet, https://github.com/pola-rs/polars/issues/1040)
#' # tmpf2 = tempfile()
#' # pl$scan_ipc(tmpf)$select(pl$col("cyl") * 2)$sink_ipc(tmpf2)
#'
#' # load ipc directly into a DataFrame / memory
#' # pl$scan_ipc(tmpf2)$collect()
LazyFrame_sink_ipc = function(
    path,
    ...,
    compression = c("zstd", "lz4", "uncompressed"),
    maintain_order = TRUE,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim = FALSE,
      comm_subexpr_elim = FALSE,
      streaming = FALSE
    ) |> unwrap("in $sink_ipc()")
  }

  lf |>
    .pr$LazyFrame$sink_ipc(
      path,
      compression %||% "uncompressed",
      maintain_order
    ) |>
    unwrap("in $sink_ipc()")

  invisible(self)
}


#' @title Stream the output of a query to a CSV file
#' @description
#' This writes the output of a query directly to a CSV file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#'
#' @inheritParams DataFrame_write_csv
#' @inheritParams LazyFrame_sink_parquet
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#'
#' @inherit LazyFrame_sink_parquet return
#' @rdname IO_sink_csv
#'
#' @examples
#' # sink table 'mtcars' from mem to CSV
#' tmpf = tempfile()
#' pl$LazyFrame(mtcars)$sink_csv(tmpf)
#'
#' # stream a query end-to-end
#' tmpf2 = tempfile()
#' pl$scan_csv(tmpf)$select(pl$col("cyl") * 2)$sink_csv(tmpf2)
#'
#' # load parquet directly into a DataFrame / memory
#' pl$scan_csv(tmpf2)$collect()
LazyFrame_sink_csv = function(
    path,
    ...,
    include_bom = FALSE,
    include_header = TRUE,
    separator = ",",
    line_terminator = "\n",
    quote = '"',
    batch_size = 1024,
    datetime_format = NULL,
    date_format = NULL,
    time_format = NULL,
    float_precision = NULL,
    null_values = "",
    quote_style = "necessary",
    maintain_order = TRUE,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim = FALSE,
      comm_subexpr_elim = FALSE,
      streaming = FALSE
    ) |> unwrap("in $sink_csv()")
  }

  lf |>
    .pr$LazyFrame$sink_csv(
      path,
      include_bom,
      include_header,
      separator,
      line_terminator,
      quote,
      batch_size,
      datetime_format,
      date_format,
      time_format,
      float_precision,
      null_values,
      quote_style,
      maintain_order
    ) |>
    unwrap("in $sink_csv()")

  invisible(self)
}


#' @title Stream the output of a query to a JSON file
#' @description
#' This writes the output of a query directly to a JSON file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#'
#' @inheritParams DataFrame_write_csv
#' @inheritParams LazyFrame_sink_parquet
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#'
#' @inherit LazyFrame_sink_parquet return
#' @rdname IO_sink_ndjson
#'
#' @examples
#' # sink table 'mtcars' from mem to JSON
#' tmpf = tempfile(fileext = ".json")
#' pl$LazyFrame(mtcars)$sink_ndjson(tmpf)
#'
#' # load parquet directly into a DataFrame / memory
#' pl$scan_ndjson(tmpf)$collect()
LazyFrame_sink_ndjson = function(
    path,
    ...,
    maintain_order = TRUE,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim = FALSE,
      comm_subexpr_elim = FALSE,
      streaming = FALSE
    ) |> unwrap("in $sink_ndjson()")
  }

  lf |>
    .pr$LazyFrame$sink_json(
      path,
      maintain_order
    ) |>
    unwrap("in $sink_ndjson()")

  invisible(self)
}


#' Get the first `n` rows.
#'
#' A shortcut for [`$slice(0, n)`][LazyFrame_slice].
#' Consider using the [`$fetch()`][LazyFrame_fetch] method if you want to test your query.
#' The [`$fetch()`][LazyFrame_fetch] operation will load the first `n` rows at
#' the scan level, whereas `$head()` is applied at the end.
#'
#' `$limit()` is an alias for `$head()`.
#' @param n Number of rows to return.
#' @inherit LazyFrame_slice return
#' @examples
#' lf = pl$LazyFrame(a = 1:6, b = 7:12)
#'
#' lf$head()$collect()
#'
#' lf$head(2)$collect()
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_head = function(n = 5L) {
  result(self$slice(0, n)) |>
    unwrap("in $head():")
}

LazyFrame_limit = LazyFrame_head


#' @title Get the first row of a LazyFrame
#' @keywords DataFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$first()$collect()
LazyFrame_first = use_extendr_wrapper

#' @title Get the last row of a LazyFrame
#' @description Aggregate the columns in the LazyFrame to their maximum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$last()$collect()
LazyFrame_last = use_extendr_wrapper

#' @title Max
#' @description Aggregate the columns in the LazyFrame to their maximum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$max()$collect()
LazyFrame_max = use_extendr_wrapper

#' @title Mean
#' @description Aggregate the columns in the LazyFrame to their mean value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$mean()$collect()
LazyFrame_mean = use_extendr_wrapper

#' @title Median
#' @description Aggregate the columns in the LazyFrame to their median value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$median()$collect()
LazyFrame_median = use_extendr_wrapper

#' @title Min
#' @description Aggregate the columns in the LazyFrame to their minimum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$min()$collect()
LazyFrame_min = use_extendr_wrapper

#' @title Sum
#' @description Aggregate the columns of this LazyFrame to their sum values.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$sum()$collect()
LazyFrame_sum = use_extendr_wrapper

#' @title Var
#' @description Aggregate the columns of this LazyFrame to their variance values.
#' @keywords LazyFrame
#' @inheritParams DataFrame_var
#' @return A LazyFrame with one row
#' @examples pl$LazyFrame(mtcars)$var()$collect()
LazyFrame_var = function(ddof = 1) {
  unwrap(.pr$LazyFrame$var(self, ddof), "in $var():")
}

#' @title Std
#' @description Aggregate the columns of this LazyFrame to their standard
#' deviation values.
#' @keywords LazyFrame
#' @inheritParams DataFrame_std
#' @return A LazyFrame with one row
#' @examples pl$LazyFrame(mtcars)$std()$collect()
LazyFrame_std = function(ddof = 1) {
  unwrap(.pr$LazyFrame$std(self, ddof), "in $std():")
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to a unique quantile
#' value. Use `$describe()` to specify several quantiles.
#' @inheritParams DataFrame_quantile
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$quantile(.4)$collect()
LazyFrame_quantile = function(quantile, interpolation = "nearest") {
  unwrap(.pr$LazyFrame$quantile(self, wrap_e_result(quantile), interpolation), "in $quantile():")
}

#' @inherit DataFrame_fill_nan title description params
#' @keywords LazyFrame
#' @return LazyFrame
#' @examples
#' df = pl$LazyFrame(
#'   a = c(1.5, 2, NaN, 4),
#'   b = c(1.5, NaN, NaN, 4)
#' )
#' df$fill_nan(99)$collect()
LazyFrame_fill_nan = function(fill_value) {
  unwrap(.pr$LazyFrame$fill_nan(self, wrap_e_result(fill_value)), "in $fill_nan():")
}

#' @inherit DataFrame_fill_null title description params
#' @keywords LazyFrame
#' @return LazyFrame
#' @examples
#' df = pl$LazyFrame(
#'   a = c(1.5, 2, NA, 4),
#'   b = c(1.5, NA, NA, 4)
#' )
#' df$fill_null(99)$collect()
LazyFrame_fill_null = function(fill_value) {
  unwrap(.pr$LazyFrame$fill_null(self, wrap_e_result(fill_value)), "in $fill_null():")
}

#' @title Shift
#' @description Shift the values by a given period.
#' @keywords LazyFrame
#' @param periods integer Number of periods to shift (may be negative).
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$shift(2)$collect()
LazyFrame_shift = function(periods = 1) {
  unwrap(.pr$LazyFrame$shift(self, periods), "in $shift():")
}

#' Shift a LazyFrame
#'
#' @description Shift the values by a given period. If the period (`n`) is positive,
#' then `n` rows will be inserted at the top of the LazyFrame and the last `n`
#' rows will be discarded. Vice-versa if the period is negative. In the end,
#' the total number of rows of the LazyFrame doesn't change.
#' @inheritParams DataFrame_shift_and_fill
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$shift_and_fill(0., 2.)$collect()$to_data_frame()
LazyFrame_shift_and_fill = function(fill_value, periods = 1) {
  unwrap(.pr$LazyFrame$shift_and_fill(self, wrap_e(fill_value), periods), "in $shift_and_fill():")
}

#' Drop columns of a LazyFrame
#'
#' @inheritParams DataFrame_drop
#'
#' @return LazyFrame
#' @examples
#' pl$LazyFrame(mtcars)$drop(c("mpg", "hp"))$collect()
#'
#' # equivalent
#' pl$LazyFrame(mtcars)$drop("mpg", "hp")$collect()
LazyFrame_drop = function(...) {
  uw = \(res) unwrap(res, "in $drop():")
  cols = result(dots_to_colnames(self, ...)) |>
    uw()
  .pr$LazyFrame$drop(self, cols) |>
    uw()
}

#' @title Reverse
#' @description Reverse the LazyFrame (the last row becomes the first one, etc.).
#' @keywords LazyFrame
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$reverse()$collect()
LazyFrame_reverse = use_extendr_wrapper

#' @title Slice
#' @description Get a slice of the LazyFrame.
#' @inheritParams DataFrame_slice
#' @return A [LazyFrame][LazyFrame_class]
#' @examples
#' pl$LazyFrame(mtcars)$slice(2, 4)$collect()
#' pl$LazyFrame(mtcars)$slice(30)$collect()
#' mtcars[2:6, ]
LazyFrame_slice = function(offset, length = NULL) {
  unwrap(.pr$LazyFrame$slice(self, offset, length), "in $slice():")
}

#' Get the last `n` rows.
#'
#' @inherit LazyFrame_head return params
#' @inheritParams LazyFrame_head
#' @seealso [`<LazyFrame>$head()`][LazyFrame_head]
#' @examples
#' lf = pl$LazyFrame(a = 1:6, b = 7:12)
#'
#' lf$tail()$collect()
#'
#' lf$tail(2)$collect()
LazyFrame_tail = function(n = 5L) {
  unwrap(.pr$LazyFrame$tail(self, n), "in $tail():")
}

#' @inherit DataFrame_drop_nulls title description params
#'
#' @return LazyFrame
#' @examples
#' tmp = mtcars
#' tmp[1:3, "mpg"] = NA
#' tmp[4, "hp"] = NA
#' tmp = pl$LazyFrame(tmp)
#'
#' # number of rows in `tmp` before dropping nulls
#' tmp$collect()$height
#'
#' tmp$drop_nulls()$collect()$height
#' tmp$drop_nulls("mpg")$collect()$height
#' tmp$drop_nulls(c("mpg", "hp"))$collect()$height
LazyFrame_drop_nulls = function(subset = NULL) {
  if (!is.null(subset)) subset = as.list(subset)
  .pr$LazyFrame$drop_nulls(self, subset) |>
    unwrap("in $drop_nulls():")
}

#' @inherit DataFrame_unique title description params
#'
#' @return LazyFrame
#' @examples
#' df = pl$LazyFrame(
#'   x = sample(10, 100, rep = TRUE),
#'   y = sample(10, 100, rep = TRUE)
#' )
#' df$collect()$height
#'
#' df$unique()$collect()$height
#' df$unique(subset = "x")$collect()$height
#'
#' df$unique(keep = "last")
#'
#' # only keep unique rows
#' df$unique(keep = "none")
LazyFrame_unique = function(
    subset = NULL,
    ...,
    keep = "any",
    maintain_order = FALSE) {
  unwrap(.pr$LazyFrame$unique(self, subset, keep, maintain_order), "in unique():")
}

#' Group a LazyFrame
#' @description This doesn't modify the data but only stores information about
#' the group structure. This structure can then be used by several functions
#' (`$agg()`, `$filter()`, etc.).
#' @keywords LazyFrame
#' @param ... Column(s) to group by.
#' Accepts [expression][Expr_class] input. Characters are parsed as column names.
#' @param maintain_order Ensure that the order of the groups is consistent with the input data.
#' This is slower than a default group by.
#' Setting this to `TRUE` blocks the possibility to run on the streaming engine.
#' The default value can be changed with `options(polars.maintain_order = TRUE)`.
#' @return [LazyGroupBy][LazyGroupBy_class] (a LazyFrame with special groupby methods like `$agg()`)
#' @examples
#' lf = pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "c"),
#'   b = c(1, 2, 1, 3, 3),
#'   c = c(5, 4, 3, 2, 1)
#' )
#'
#' lf$group_by("a")$agg(pl$col("b")$sum())$collect()
#'
#' # Set `maintain_order = TRUE` to ensure the order of the groups is consistent with the input.
#' lf$group_by("a", maintain_order = TRUE)$agg(pl$col("c"))$collect()
#'
#' # Group by multiple columns by passing a list of column names.
#' lf$group_by(c("a", "b"))$agg(pl$max("c"))$collect()
#'
#' # Or pass some arguments to group by multiple columns in the same way.
#' # Expressions are also accepted.
#' lf$group_by("a", pl$col("b") %/% 2)$agg(
#'   pl$col("c")$mean()
#' )$collect()
#'
#' # The columns will be renamed to the argument names.
#' lf$group_by(d = "a", e = pl$col("b") %/% 2)$agg(
#'   pl$col("c")$mean()
#' )$collect()
LazyFrame_group_by = function(..., maintain_order = polars_options()$maintain_order) {
  .pr$LazyFrame$group_by(self, unpack_list(..., .context = "in $group_by():"), maintain_order) |>
    unwrap("in $group_by():")
}

#' Join LazyFrames
#'
#' This function can do both mutating joins (adding columns based on matching
#' observations, for example with `how = "left"`) and filtering joins (keeping
#' observations based on matching observations, for example with `how =
#' "inner"`).
#'
#' @param other LazyFrame to join with.
#' @param on Either a vector of column names or a list of expressions and/or
#'   strings. Use `left_on` and `right_on` if the column names to match on are
#'   different between the two DataFrames.
#' @param how One of the following methods: "inner", "left", "full", "semi",
#'   "anti", "cross".
#' @param ... Ignored.
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
#' Note that this is currently not supported by the streaming engine, and is
#' only supported when joining by single columns.
#'
#' @param join_nulls Join on null values. By default null values will never
#'   produce matches.
#' @param allow_parallel Allow the physical plan to optionally evaluate the
#'   computation of both DataFrames up to the join in parallel.
#' @param force_parallel Force the physical plan to evaluate the computation of
#'   both DataFrames up to the join in parallel.
#' @param coalesce Coalescing behavior (merging of join columns).
#' - `NULL`: join specific.
#' - `TRUE`: Always coalesce join columns.
#' - `FALSE`: Never coalesce join columns.
#'
#' @return LazyFrame
#' @examples
#' # inner join by default
#' df1 = pl$LazyFrame(list(key = 1:3, payload = c("f", "i", NA)))
#' df2 = pl$LazyFrame(list(key = c(3L, 4L, 5L, NA_integer_)))
#' df1$join(other = df2, on = "key")
#'
#' # cross join
#' df1 = pl$LazyFrame(x = letters[1:3])
#' df2 = pl$LazyFrame(y = 1:4)
#' df1$join(other = df2, how = "cross")
#'
#' # use "validate" to ensure join keys are not duplicated
#' df1 = pl$LazyFrame(x = letters[1:5], y = 1:5)
#' df2 = pl$LazyFrame(x = c("a", letters[1:4]), y2 = 6:10)
#'
#' # this throws an error because there are two keys in df2 that match the key
#' # in df1
#' tryCatch(
#'   df1$join(df2, on = "x", validate = "1:1")$collect(),
#'   error = function(e) print(e)
#' )
LazyFrame_join = function(
    other,
    on = NULL,
    how = "inner",
    ...,
    left_on = NULL,
    right_on = NULL,
    suffix = "_right",
    validate = "m:m",
    join_nulls = FALSE,
    allow_parallel = TRUE,
    force_parallel = FALSE,
    coalesce = NULL) {
  uw = \(res) unwrap(res, "in $join():")

  if (!is_polars_lf(other)) {
    Err_plain("`other` must be a LazyFrame.") |> uw()
  }

  if (how == "cross") {
    if (!is.null(on) || !is.null(left_on) || !is.null(right_on)) {
      Err_plain("cross join should not pass join keys.") |> uw()
    }
    rexprs_left = as.list(NULL)
    rexprs_right = as.list(NULL)
  } else {
    if (!is.null(on)) {
      rexprs_right = rexprs_left = as.list(on)
    } else if ((!is.null(left_on) && !is.null(right_on))) {
      rexprs_left = as.list(left_on)
      rexprs_right = as.list(right_on)
    } else {
      Err_plain("must specify either `on`, or `left_on` and `right_on`.") |> uw()
    }
  }

  .pr$LazyFrame$join(
    self, other, rexprs_left, rexprs_right, how, validate, join_nulls, suffix,
    allow_parallel, force_parallel, coalesce
  ) |>
    uw()
}


#' Sort the LazyFrame by the given columns
#'
#' @inheritParams Series_sort
#' @param by Column(s) to sort by. Can be character vector of column names,
#' a list of Expr(s) or a list with a mix of Expr(s) and column names.
#' @param ... More columns to sort by as above but provided one Expr per argument.
#' @param descending Logical. Sort in descending order (default is `FALSE`). This must be
#' either of length 1 or a logical vector of the same length as the number of
#' Expr(s) specified in `by` and `...`.
#' @param nulls_last A logical or logical vector of the same length as the number of columns.
#' If `TRUE`, place `null` values last insead of first.
#' @param maintain_order Whether the order should be maintained if elements are
#' equal. If `TRUE`, streaming is not possible and performance might be worse
#' since this requires a stable search.
#' @return LazyFrame
#' @keywords  LazyFrame
#' @examples
#' df = mtcars
#' df$mpg[1] = NA
#' df = pl$LazyFrame(df)
#' df$sort("mpg")$collect()
#' df$sort("mpg", nulls_last = TRUE)$collect()
#' df$sort("cyl", "mpg")$collect()
#' df$sort(c("cyl", "mpg"))$collect()
#' df$sort(c("cyl", "mpg"), descending = TRUE)$collect()
#' df$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE))$collect()
#' df$sort(pl$col("cyl"), pl$col("mpg"))$collect()
LazyFrame_sort = function(
    by,
    ...,
    descending = FALSE,
    nulls_last = FALSE,
    maintain_order = FALSE,
    multithreaded = TRUE) {
  .pr$LazyFrame$sort_by_exprs(
    self, unpack_list(by, .context = "in $sort():"), err_on_named_args(...),
    descending, nulls_last, maintain_order, multithreaded
  ) |>
    unwrap("in $sort():")
}


#' Perform joins on nearest keys
#'
#' This is similar to a left-join except that we match on nearest key rather
#' than equal keys.
#'
#' Both tables (DataFrames or LazyFrames) must be sorted by the asof_join key.
#' @param other LazyFrame
#' @param ...  Not used, blocks use of further positional arguments
#' @inheritParams DataFrame_join
#' @param by Join on these columns before performing asof join. Either a vector
#' of column names or a list of expressions and/or strings. Use `left_by` and
#' `right_by` if the column names to match on are different between the two
#' tables.
#' @param by_left,by_right Same as `by` but only for the left or the right
#' table. They must have the same length.
#' @param strategy Strategy for where to find match:
#' * "backward" (default): search for the last row in the right table whose `on`
#'   key is less than or equal to the left key.
#' * "forward": search for the first row in the right table whose `on` key is
#'   greater than or equal to the left key.
#' * "nearest": search for the last row in the right table whose value is nearest
#'   to the left key. String keys are not currently supported for a nearest
#'   search.
#' @param tolerance
#' Numeric tolerance. By setting this the join will only be done if the near
#' keys are within this distance. If an asof join is done on columns of dtype
#' "Date", "Datetime", "Duration" or "Time", use the Polars duration string language.
#' About the language, see the `Polars duration string language` section for details.
#'
#' There may be a circumstance where R types are not sufficient to express a
#' numeric tolerance. In that case, you can use the expression syntax like
#' `tolerance = pl$lit(42)$cast(pl$Uint64)`
#' @inheritSection polars_duration_string  Polars duration string language
#' @examples #
#' # create two LazyFrame to join asof
#' gdp = pl$LazyFrame(
#'   date = as.Date(c("2015-1-1", "2016-1-1", "2017-5-1", "2018-1-1", "2019-1-1")),
#'   gdp = c(4321, 4164, 4411, 4566, 4696),
#'   group = c("b", "a", "a", "b", "b")
#' )
#'
#' pop = pl$LazyFrame(
#'   date = as.Date(c("2016-5-12", "2017-5-12", "2018-5-12", "2019-5-12")),
#'   population = c(82.19, 82.66, 83.12, 83.52),
#'   group = c("b", "b", "a", "a")
#' )
#'
#' # optional make sure tables are already sorted with "on" join-key
#' gdp = gdp$sort("date")
#' pop = pop$sort("date")
#'
#'
#' # Left-join_asof LazyFrame pop with gdp on "date"
#' # Look backward in gdp to find closest matching date
#' pop$join_asof(gdp, on = "date", strategy = "backward")$collect()
#'
#' # .... and forward
#' pop$join_asof(gdp, on = "date", strategy = "forward")$collect()
#'
#' # join by a group: "only look within groups"
#' pop$join_asof(gdp, on = "date", by = "group", strategy = "backward")$collect()
#'
#' # only look 2 weeks and 2 days back
#' pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = "2w2d")$collect()
#'
#' # only look 11 days back (numeric tolerance depends on polars type, <date> is in days)
#' pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = 11)$collect()
LazyFrame_join_asof = function(
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
    force_parallel = FALSE) {
  if (!is.null(by)) by_left = by_right = by
  if (!is.null(on)) left_on = right_on = on
  tolerance_str = if (is.character(tolerance)) tolerance else NULL
  tolerance_num = if (!is.character(tolerance)) tolerance else NULL

  .pr$LazyFrame$join_asof(
    self, other,
    left_on, right_on,
    by_left, by_right,
    allow_parallel, force_parallel,
    suffix, strategy,
    tolerance_num, tolerance_str
  ) |>
    unwrap("in join_asof( ):")
}


#' Unpivot a Frame from wide to long format
#'
#' @param on Values to use as identifier variables. If `value_vars` is
#' empty all columns that are not in `id_vars` will be used.
#' @param ... Not used.
#' @param index Columns to use as identifier variables.
#' @param variable_name Name to give to the new column containing the names of
#' the melted columns. Defaults to "variable".
#' @param value_name Name to give to the new column containing the values of
#' the melted columns. Defaults to `"value"`.
#'
#' @details
#' Optionally leaves identifiers set.
#'
#' This function is useful to massage a Frame into a format where one or more
#' columns are identifier variables (id_vars), while all other columns, considered
#' measured variables (value_vars), are "unpivoted" to the row axis, leaving just
#' two non-identifier columns, 'variable' and 'value'.
#'
#' @keywords LazyFrame
#'
#' @return A LazyFrame
#'
#' @examples
#' lf = pl$LazyFrame(
#'   a = c("x", "y", "z"),
#'   b = c(1, 3, 5),
#'   c = c(2, 4, 6)
#' )
#' lf$unpivot(index = "a", on = c("b", "c"))$collect()
LazyFrame_unpivot = function(
    on = NULL,
    ...,
    index = NULL,
    variable_name = NULL,
    value_name = NULL) {
  .pr$LazyFrame$unpivot(
    self, on %||% character(), index %||% character(),
    value_name, variable_name
  ) |> unwrap("in $unpivot( ): ")
}

#' Rename column names of a LazyFrame
#'
#' @details
#' If existing names are swapped (e.g. `A` points to `B` and `B` points to `A`),
#' polars will block projection and predicate pushdowns at this node.
#' @inherit pl_LazyFrame return
#' @param ... One of the following:
#' - Key value pairs that map from old name to new name, like `old_name = "new_name"`.
#' - As above but with params wrapped in a list
#' - An R function that takes the old names character vector as input and
#'   returns the new names character vector.
#' @examples
#' lf = pl$LazyFrame(
#'   foo = 1:3,
#'   bar = 6:8,
#'   ham = letters[1:3]
#' )
#'
#' lf$rename(foo = "apple")$collect()
#'
#' lf$rename(
#'   \(column_name) paste0("c", substr(column_name, 2, 100))
#' )$collect()
LazyFrame_rename = function(...) {
  uw = \(res) unwrap(res, "in $rename():")

  if (!nargs()) {
    Err_plain("No arguments provided for `$rename()`.") |>
      uw()
  }

  mapping = list2(...)
  if (is.function(mapping[[1L]])) {
    result({
      existing = names(self)
      new = mapping[[1L]](existing)
    }) |>
      uw()
  } else {
    if (is.list(mapping[[1L]])) {
      mapping = mapping[[1L]]
    }
    new = unname(unlist(mapping))
    existing = names(mapping)
  }
  .pr$LazyFrame$rename(self, existing, new) |>
    uw()
}

#' Fetch `n` rows of a LazyFrame
#'
#' This is similar to `$collect()` but limit the number of rows to collect. It
#' is mostly useful to check that a query works as expected.
#'
#' @keywords LazyFrame
#' @details
#' `$fetch()` does not guarantee the final number of rows in the DataFrame output.
#' It only guarantees that `n` rows are used at the beginning of the query.
#' Filters, join operations and a lower number of rows available in the scanned
#' file influence the final number of rows.
#'
#' @param n_rows Integer. Maximum number of rows to fetch.
#' @inheritParams LazyFrame_collect
#' @return A DataFrame of maximum n_rows
#' @seealso
#'  - [`$collect()`][LazyFrame_collect] - regular collect.
#'  - [`$profile()`][LazyFrame_profile] - same as `$collect()` but also returns
#'    a table with each operation profiled.
#'  - [`$collect_in_background()`][LazyFrame_collect_in_background] - non-blocking
#'    collect returns a future handle. Can also just be used via
#'    `$collect(collect_in_background = TRUE)`.
#'  - [`$sink_parquet()`][LazyFrame_sink_parquet()] streams query to a parquet file.
#'  - [`$sink_ipc()`][LazyFrame_sink_ipc()] streams query to a arrow file.
#'
#' @examples
#' # fetch 3 rows
#' pl$LazyFrame(iris)$fetch(3)
#'
#' # this fetch-query returns 4 rows, because we started with 3 and appended one
#' # row in the query (see section 'Details')
#' pl$LazyFrame(iris)$
#'   select(pl$col("Species")$append("flora gigantica, alien"))$
#'   fetch(3)
LazyFrame_fetch = function(
    n_rows = 500,
    ...,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    streaming = FALSE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
    comm_subplan_elim = FALSE
    comm_subexpr_elim = FALSE
    cluster_with_columns = FALSE
  }

  if (isTRUE(streaming)) {
    comm_subplan_elim = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim,
      comm_subexpr_elim,
      cluster_with_columns,
      streaming
    ) |> unwrap("in $fetch()")
  }

  .pr$LazyFrame$fetch(lf, n_rows) |>
    unwrap("in $fetch()")
}

#' @title Collect and profile a lazy query.
#' @description This will run the query and return a list containing the
#' materialized DataFrame and a DataFrame that contains profiling information
#' of each node that is executed.
#'
#' @inheritParams LazyFrame_collect
#' @param show_plot Show a Gantt chart of the profiling result
#' @param truncate_nodes Truncate the label lengths in the Gantt chart to this
#' number of characters. If `0` (default), do not truncate.
#'
#' @details The units of the timings are microseconds.
#'
#' @keywords LazyFrame
#' @return List of two `DataFrame`s: one with the collected result, the other
#' with the timings of each step. If `show_graph = TRUE`, then the plot is
#' also stored in the list.
#' @seealso
#'  - [`$collect()`][LazyFrame_collect] - regular collect.
#'  - [`$fetch()`][LazyFrame_fetch] - fast limited query check
#'  - [`$collect_in_background()`][LazyFrame_collect_in_background] - non-blocking
#'    collect returns a future handle. Can also just be used via
#'    `$collect(collect_in_background = TRUE)`.
#'  - [`$sink_parquet()`][LazyFrame_sink_parquet()] streams query to a parquet file.
#'  - [`$sink_ipc()`][LazyFrame_sink_ipc()] streams query to a arrow file.
#'
#' @examples
#' ## Simplest use case
#' pl$LazyFrame()$select(pl$lit(2) + 2)$profile()
#'
#' ## Use $profile() to compare two queries
#'
#' # -1-  map each Species-group with native polars, takes ~120us only
#' pl$LazyFrame(iris)$
#'   sort("Sepal.Length")$
#'   group_by("Species", maintain_order = TRUE)$
#'   agg(pl$col(pl$Float64)$first() + 5)$
#'   profile()
#'
#' # -2-  map each Species-group of each numeric column with an R function, takes ~7000us (slow!)
#'
#' # some R function, prints `.` for each time called by polars
#' r_func = \(s) {
#'   cat(".")
#'   s$to_r()[1] + 5
#' }
#'
#' pl$LazyFrame(iris)$
#'   sort("Sepal.Length")$
#'   group_by("Species", maintain_order = TRUE)$
#'   agg(pl$col(pl$Float64)$map_elements(r_func))$
#'   profile()
LazyFrame_profile = function(
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    streaming = FALSE,
    no_optimization = FALSE,
    inherit_optimization = FALSE,
    collect_in_background = FALSE,
    show_plot = FALSE,
    truncate_nodes = 0) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
    comm_subplan_elim = FALSE
    comm_subexpr_elim = FALSE
    cluster_with_columns = FALSE
  }

  if (isTRUE(streaming)) {
    comm_subplan_elim = FALSE
  }

  lf = self

  if (isFALSE(inherit_optimization)) {
    lf = self$set_optimization_toggle(
      type_coercion,
      predicate_pushdown,
      projection_pushdown,
      simplify_expression,
      slice_pushdown,
      comm_subplan_elim,
      comm_subexpr_elim,
      cluster_with_columns,
      streaming
    ) |> unwrap("in $profile():")
  }

  out = lf |>
    .pr$LazyFrame$profile() |>
    unwrap("in $profile()")

  if (isTRUE(show_plot)) {
    out[["plot"]] = make_profile_plot(out, truncate_nodes) |>
      result() |>
      unwrap("in $profile()")
  }

  out
}

#' @title Explode columns containing a list of values
#' @description This will take every element of a list column and add it on an
#' additional row.
#'
#' @keywords LazyFrame
#'
#' @param ... Column(s) to be exploded as individual `Into<Expr>` or list/vector
#' of `Into<Expr>`. In a handful of places in rust-polars, only the plain variant
#' `Expr::Column` is accepted. This is currenly one of such places. Therefore
#' `pl$col("name")` and `pl$all()` is allowed, not `pl$col("name")$alias("newname")`.
#' `"name"` is implicitly converted to `pl$col("name")`.
#'
#' @details
#' Only columns of DataType `List` or `Array` can be exploded.
#'
#' Named expressions like `$explode(a = pl$col("b"))` will not implicitly trigger
#' `$alias("a")` here, due to only variant `Expr::Column` is supported in
#' rust-polars.
#'
#' @return LazyFrame
#' @examples
#' df = pl$LazyFrame(
#'   letters = c("aa", "aa", "bb", "cc"),
#'   numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8)),
#'   numbers_2 = list(0, c(1, 2), c(3, 4), c(5, 6, 7)) # same structure as numbers
#' )
#' df
#'
#' # explode a single column, append others
#' df$explode("numbers")$collect()
#'
#' # explode two columns of same nesting structure, by names or the common dtype
#' # "List(Float64)"
#' df$explode("numbers", "numbers_2")$collect()
#' df$explode(pl$col(pl$List(pl$Float64)))$collect()
LazyFrame_explode = function(...) {
  dotdotdot_args = unpack_list(..., .context = "in explode():")
  .pr$LazyFrame$explode(self, dotdotdot_args) |>
    unwrap("in explode():")
}

#' Clone a LazyFrame
#'
#' This makes a very cheap deep copy/clone of an existing
#' [`LazyFrame`][LazyFrame_class]. Rarely useful as `LazyFrame`s are nearly 100%
#' immutable. Any modification of a `LazyFrame` should lead to a clone anyways,
#' but this can be useful when dealing with attributes (see examples).
#'
#'
#' @return A LazyFrame
#' @examples
#' df1 = pl$LazyFrame(iris)
#'
#' # Make a function to take a LazyFrame, add an attribute, and return a LazyFrame
#' give_attr = function(data) {
#'   attr(data, "created_on") = "2024-01-29"
#'   data
#' }
#' df2 = give_attr(df1)
#'
#' # Problem: the original LazyFrame also gets the attribute while it shouldn't!
#' attributes(df1)
#'
#' # Use $clone() inside the function to avoid that
#' give_attr = function(data) {
#'   data = data$clone()
#'   attr(data, "created_on") = "2024-01-29"
#'   data
#' }
#' df1 = pl$LazyFrame(iris)
#' df2 = give_attr(df1)
#'
#' # now, the original LazyFrame doesn't get this attribute
#' attributes(df1)
LazyFrame_clone = function() {
  .pr$LazyFrame$clone_in_rust(self)
}


#' Unnest the Struct columns of a LazyFrame
#'
#' @inheritParams DataFrame_unnest
#'
#' @return A LazyFrame where some or all columns of datatype Struct are unnested.
#' @examples
#' lf = pl$LazyFrame(
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
#' # by default, all struct columns are unnested
#' lf$unnest()$collect()
#'
#' # we can specify specific columns to unnest
#' lf$unnest("a_and_c")$collect()
LazyFrame_unnest = function(...) {
  columns = unpack_list(..., .context = "in $unnest():")
  if (length(columns) == 0) {
    columns = names(which(dtypes_are_struct(.pr$LazyFrame$schema(self)$ok)))
  } else {
    columns = unlist(columns)
  }
  unwrap(.pr$LazyFrame$unnest(self, columns), "in $unnest():")
}

#' Add an external context to the computation graph
#'
#' This allows expressions to also access columns from DataFrames or LazyFrames
#' that are not part of this one.
#'
#' @param other Data/LazyFrame to have access to. This can be a list of DataFrames
#' and LazyFrames.
#' @return A LazyFrame
#'
#' @examples
#' lf = pl$LazyFrame(a = c(1, 2, 3), b = c("a", "c", NA))
#' lf_other = pl$LazyFrame(c = c("foo", "ham"))
#'
#' lf$with_context(lf_other)$select(
#'   pl$col("b") + pl$col("c")$first()
#' )$collect()
#'
#' # Fill nulls with the median from another lazyframe:
#' train_lf = pl$LazyFrame(
#'   feature_0 = c(-1.0, 0, 1), feature_1 = c(-1.0, 0, 1)
#' )
#' test_lf = pl$LazyFrame(
#'   feature_0 = c(-1.0, NA, 1), feature_1 = c(-1.0, 0, 1)
#' )
#'
#' test_lf$with_context(train_lf$select(pl$all()$name$suffix("_train")))$select(
#'   pl$col("feature_0")$fill_null(pl$col("feature_0_train")$median())
#' )$collect()
LazyFrame_with_context = function(other) {
  .pr$LazyFrame$with_context(self, other) |>
    unwrap("in with_context():")
}


#' Create rolling groups based on a date/time or integer column
#'
#' @inherit Expr_rolling description details params
#' @param index_column Column used to group based on the time window. Often of
#' type Date/Datetime. This column must be sorted in ascending order (or, if `by`
#' is specified, then it must be sorted in ascending order within each group). In
#' case of a rolling group by on indices, dtype needs to be either Int32 or Int64.
#' Note that Int32 gets temporarily cast to Int64, so if performance matters use
#' an Int64 column.
#' @param group_by Also group by this column/these columns.
#'
#' @inheritSection polars_duration_string  Polars duration string language
#' @return A [LazyGroupBy][LazyGroupBy_class] object
#' @seealso
#' - [`<LazyFrame>$group_by_dynamic()`][LazyFrame_group_by_dynamic]
#' @examples
#' dates = c(
#'   "2020-01-01 13:45:48",
#'   "2020-01-01 16:42:13",
#'   "2020-01-01 16:45:09",
#'   "2020-01-02 18:12:48",
#'   "2020-01-03 19:45:32",
#'   "2020-01-08 23:16:43"
#' )
#'
#' df = pl$LazyFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
#'   pl$col("dt")$str$strptime(pl$Datetime())$set_sorted()
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   sum_a = pl$sum("a"),
#'   min_a = pl$min("a"),
#'   max_a = pl$max("a")
#' )$collect()
LazyFrame_rolling = function(
    index_column,
    ...,
    period,
    offset = NULL,
    closed = "right",
    group_by = NULL) {
  period = parse_as_polars_duration_string(period)
  offset = parse_as_polars_duration_string(offset) %||% negate_duration_string(period)
  .pr$LazyFrame$rolling(
    self, index_column, period, offset, closed,
    wrap_elist_result(group_by, str_to_lit = FALSE)
  ) |>
    unwrap("in $rolling():")
}


#' Group based on a date/time or integer column
#'
#' @inherit LazyFrame_rolling description details params
#'
#' @param every Interval of the window.
#' @param include_boundaries Add two columns `"_lower_boundary"` and
#' `"_upper_boundary"` columns that show the boundaries of the window. This will
#' impact performance because it’s harder to parallelize.
#' @param label Define which label to use for the window:
#' * `"left"`: lower boundary of the window
#' * `"right"`: upper boundary of the window
#' * `"datapoint"`: the first value of the index column in the given window. If
#' you don’t need the label to be at one of the boundaries, choose this option
#' for maximum performance.
#' @param start_by The strategy to determine the start of the first window by:
#' * `"window"`: start by taking the earliest timestamp, truncating it with `every`,
#'   and then adding `offset`. Note that weekly windows start on Monday.
#' * `"datapoint"`: start from the first encountered data point.
#' * a day of the week (only takes effect if `every` contains `"w"`): `"monday"`
#'   starts the window on the Monday before the first data point, etc.
#'
#' @return A [LazyGroupBy][LazyGroupBy_class] object
#' @seealso
#' - [`<LazyFrame>$rolling()`][LazyFrame_rolling]
#' @examples
#' lf = pl$LazyFrame(
#'   time = pl$datetime_range(
#'     start = strptime("2021-12-16 00:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     end = strptime("2021-12-16 03:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     interval = "30m"
#'   ),
#'   n = 0:6
#' )
#' lf$collect()
#'
#' # get the sum in the following hour relative to the "time" column
#' lf$group_by_dynamic("time", every = "1h")$agg(
#'   vals = pl$col("n"),
#'   sum = pl$col("n")$sum()
#' )$collect()
#'
#' # using "include_boundaries = TRUE" is helpful to see the period considered
#' lf$group_by_dynamic("time", every = "1h", include_boundaries = TRUE)$agg(
#'   vals = pl$col("n")
#' )$collect()
#'
#' # in the example above, the values didn't include the one *exactly* 1h after
#' # the start because "closed = 'left'" by default.
#' # Changing it to "right" includes values that are exactly 1h after. Note that
#' # the value at 00:00:00 now becomes included in the interval [23:00:00 - 00:00:00],
#' # even if this interval wasn't there originally
#' lf$group_by_dynamic("time", every = "1h", closed = "right")$agg(
#'   vals = pl$col("n")
#' )$collect()
#' # To keep both boundaries, we use "closed = 'both'". Some values now belong to
#' # several groups:
#' lf$group_by_dynamic("time", every = "1h", closed = "both")$agg(
#'   vals = pl$col("n")
#' )$collect()
#'
#' # Dynamic group bys can also be combined with grouping on normal keys
#' lf = lf$with_columns(
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
#' lf = pl$LazyFrame(
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
LazyFrame_group_by_dynamic = function(
    index_column,
    ...,
    every,
    period = NULL,
    offset = NULL,
    include_boundaries = FALSE,
    closed = "left",
    label = "left",
    group_by = NULL,
    start_by = "window") {
  every = parse_as_polars_duration_string(every)
  offset = parse_as_polars_duration_string(offset) %||% negate_duration_string(every)
  period = parse_as_polars_duration_string(period) %||% every

  .pr$LazyFrame$group_by_dynamic(
    self, index_column, every, period, offset, label, include_boundaries, closed,
    wrap_elist_result(group_by, str_to_lit = FALSE), start_by
  ) |>
    unwrap("in $group_by_dynamic():")
}

#' Plot the query plan
#'
#' This only returns the "dot" output that can be passed to other packages, such
#' as `DiagrammeR::grViz()`.
#'
#' @param ... Not used..
#' @param optimized Optimize the query plan.
#' @inheritParams LazyFrame_set_optimization_toggle
#'
#' @return A character vector
#'
#' @examples
#' lf = pl$LazyFrame(
#'   a = c("a", "b", "a", "b", "b", "c"),
#'   b = 1:6,
#'   c = 6:1
#' )
#'
#' query = lf$group_by("a", maintain_order = TRUE)$agg(
#'   pl$all()$sum()
#' )$sort(
#'   "a"
#' )
#'
#' query$to_dot() |> cat()
#'
#' # You could print the graph by using DiagrammeR for example, with
#' # query$to_dot() |> DiagrammeR::grViz().
LazyFrame_to_dot = function(
    ...,
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
  lf = self$set_optimization_toggle(
    type_coercion,
    predicate_pushdown,
    projection_pushdown,
    simplify_expression,
    slice_pushdown,
    comm_subplan_elim,
    comm_subexpr_elim,
    streaming
  ) |> unwrap("in $to_dot():")

  .pr$LazyFrame$to_dot(lf, optimized) |>
    unwrap("in $to_dot():")
}

#' Create an empty or n-row null-filled copy of the LazyFrame
#'
#' Returns a n-row null-filled LazyFrame with an identical schema. `n` can be
#' greater than the current number of rows in the LazyFrame.
#'
#' @inheritParams DataFrame_clear
#'
#' @return A n-row null-filled LazyFrame with an identical schema
#'
#' @examples
#' df = pl$LazyFrame(
#'   a = c(NA, 2, 3, 4),
#'   b = c(0.5, NA, 2.5, 13),
#'   c = c(TRUE, TRUE, FALSE, NA)
#' )
#'
#' df$clear()
#'
#' df$clear(n = 5)
LazyFrame_clear = function(n = 0) {
  pl$DataFrame(schema = self$schema)$clear(n)$lazy()
}


# TODO: we can't use % in the SQL query
# <https://github.com/r-lib/roxygen2/issues/1616>
#' Execute a SQL query against the LazyFrame
#'
#' The calling frame is automatically registered as a table in the SQL context
#' under the name `"self"`. All [DataFrames][DataFrame_class] and
#' [LazyFrames][LazyFrame_class] found in the `envir` are also registered,
#' using their variable name.
#' More control over registration and execution behaviour is available by
#' the [SQLContext][SQLContext_class] object.
#'
#' This functionality is considered **unstable**, although it is close to
#' being considered stable. It may be changed at any point without it being
#' considered a breaking change.
#' @inherit pl_LazyFrame return
#' @inheritParams SQLContext_execute
#' @inheritParams SQLContext_register_globals
#' @param table_name `NULL` (default) or a character of an explicit name for the table
#' that represents the calling frame (the alias `"self"` will always be registered/available).
#' @seealso
#' - [SQLContext][SQLContext_class]
#' @examplesIf polars_info()$features$sql
#' lf1 = pl$LazyFrame(a = 1:3, b = 6:8, c = c("z", "y", "x"))
#' lf2 = pl$LazyFrame(a = 3:1, d = c(125, -654, 888))
#'
#' # Query the LazyFrame using SQL:
#' lf1$sql("SELECT c, b FROM self WHERE a > 1")$collect()
#'
#' # Join two LazyFrames:
#' lf1$sql(
#'   "
#' SELECT self.*, d
#' FROM self
#' INNER JOIN lf2 USING (a)
#' WHERE a > 1 AND b < 8
#' "
#' )$collect()
#'
#' # Apply SQL transforms (aliasing "self" to "frame") and subsequently
#' # filter natively (you can freely mix SQL and native operations):
#' lf1$sql(
#'   query = r"(
#' SELECT
#'  a,
#' MOD(a, 2) == 0 AS a_is_even,
#' (b::float / 2) AS 'b/2',
#' CONCAT_WS(':', c, c, c) AS c_c_c
#' FROM frame
#' ORDER BY a
#' )",
#'   table_name = "frame"
#' )$filter(!pl$col("c_c_c")$str$starts_with("x"))$collect()
LazyFrame_sql = function(query, ..., table_name = NULL, envir = parent.frame()) {
  result({
    ctx = pl$SQLContext()$register_globals(envir = envir)$register("self", self)

    if (!is.null(table_name)) {
      ctx$register(table_name, self)
    }

    ctx$execute(query)
  }) |>
    unwrap("in $sql():")
}
