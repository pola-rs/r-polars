#' @title Inner workings of the LazyFrame-class
#'
#' @name LazyFrame_class
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
#' `DataFrame_object$lazy() -> LazyFrame_object` and `LazyFrame_object$collect() -> DataFrame_object`. You can also create a `LazyFrame` directly with `pl$LazyFrame()`.
#' This is quite similar to the lazy-collect syntax of the dplyrpackage to
#' interact with database connections such as SQL variants. Most SQL databases
#' would be able to perform the same optimizations as polars such Predicate Pushdown
#' and Projection. However polars can interact and optimize queries with both
#' SQL DBs and other data sources such parquet files simultaneously. (#TODO
#' implement r-polars SQL ;).
#'
#' @details Check out the source code in R/LazyFrame__lazy.R how public methods
#' are derived from private methods. Check out  extendr-wrappers.R to see the
#' extendr-auto-generated methods. These are moved to `.pr` and converted into
#' pure external functions in after-wrappers.R. In zzz.R (named zzz to be last
#' file sourced) the extendr-methods are removed and replaced by any function
#' prefixed `LazyFrame_`.
#' @return not applicable
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
#' Pdf = pl$DataFrame(Rdf)
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
#' Ldf_okay$describe_plan()
#' Ldf_best$describe_plan()
#'
#' # NOTE For Ldf_okay, the full time to load csv alrady paid when creating Rdf and Pdf
#'
#' # The optimized plan are quite different, Ldf_best will read csv and perform filter simultaneously
#' Ldf_okay$describe_optimized_plan()
#' Ldf_best$describe_optimized_plan()
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


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x LazyFrame
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd

.DollarNames.RPolarsLazyFrame = function(x, pattern = "") {
  paste0(ls(RPolarsLazyFrame, pattern = pattern), "()")
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
#' @return LazyFrame
#' @keywords LazyFrame_new
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
  print("polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)")
  cloned_x = .pr$LazyFrame$print(x)
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
LazyFrame_print = "use_extendr_wrapper"

# TODO write missing examples in this file

#' @title Print the optimized or non-optimized plans of `LazyFrame`
#'
#' @rdname LazyFrame_describe_plan
#'
#' @description `$describe_plan()` shows the query in the format that `polars`
#' understands. `$describe_optimized_plan()` shows the optimized query plan that
#' `polars` will execute when `$collect()` is called. It is possible that both
#' plans are identical if `polars` doesn't find any way to optimize the query.
#' @keywords LazyFrame
#' @return This only prints the plan in the console, it doesn't return any value.
#' @examples
#' lazy_frame = pl$LazyFrame(iris)
#'
#' # Prepare your query
#' lazy_query = lazy_frame$sort("Species")$filter(pl$col("Species") != "setosa")
#'
#' # This is the query as `polars` understands it
#' lazy_query$describe_plan()
#'
#' # This is the query after `polars` optimizes it: instead of sorting first and
#' # then filtering, it is faster to filter first and then sort the rest.
#' lazy_query$describe_optimized_plan()
LazyFrame_describe_optimized_plan = function() {
  unwrap(.pr$LazyFrame$describe_optimized_plan(self), "in $describe_optimized_plan():")
  invisible(NULL)
}

#' @rdname LazyFrame_describe_plan
LazyFrame_describe_plan = "use_extendr_wrapper"

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

#' @title Select and modify columns of a LazyFrame
#' @inherit DataFrame_with_columns description params
#' @keywords LazyFrame
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


#' @inherit DataFrame_with_row_count title description params
#' @return A new LazyFrame with a counter column in front
#' @docType NULL
#' @examples
#' df = pl$LazyFrame(mtcars)
#'
#' # by default, the index starts at 0 (to mimic the behavior of Python Polars)
#' df$with_row_count("idx")
#'
#' # but in R, we use a 1-index
#' df$with_row_count("idx", offset = 1)
LazyFrame_with_row_count = function(name, offset = NULL) {
  .pr$LazyFrame$with_row_count(self, name, offset) |> unwrap()
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
#' @param type_coercion Boolean. Coerce types such that operations succeed and
#' run on minimal required memory.
#' @param predicate_pushdown Boolean. Applies filters as early as possible at
#' scan level.
#' @param projection_pushdown Boolean. Select only the columns that are needed
#' at the scan level.
#' @param simplify_expression Boolean. Various optimizations, such as constant
#' folding and replacing expensive operations with faster alternatives.
#' @param slice_pushdown Boolean. Only load the required slice from the scan
#' level. Don't materialize sliced outputs (e.g. `join$head(10)`).
#' @param comm_subplan_elim Boolean. Will try to cache branching subplans that
#'  occur on self-joins or unions.
#' @param comm_subexpr_elim Boolean. Common subexpressions will be cached and
#' reused.
#' @param streaming Boolean. Run parts of the query in a streaming fashion
#' (this is in an alpha state).
#' @param eager Boolean. Run the query eagerly.
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
      streaming,
      eager
    )
}

#' @title Collect a query into a DataFrame
#' @description `$collect()` performs the query on the LazyFrame. It returns a
#' DataFrame
#' @inheritParams LazyFrame_set_optimization_toggle
#' @param ... Ignored.
#' @param no_optimization  Boolean. Sets the following parameters to `FALSE`:
#'  `predicate_pushdown`, `projection_pushdown`, `slice_pushdown`,
#'  `comm_subplan_elim`, `comm_subexpr_elim`.
#' @param inherit_optimization  Boolean. Use existing optimization settings
#' regardless the settings specified in this function call.
#' @param collect_in_background Boolean. Detach this query from R session.
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
#' then you must pass `in_background = TRUE` in `$map_batches()` (or
#' `$map_elements()`). Otherwise, `$collect_in_background()` will fail because
#' the main R session is not available for polars execution. See also examples
#' below.
#'
#' @keywords LazyFrame DataFrame_new
#' @return RThreadHandle, a future-like thread handle for the task
#' @examples
#' # Some expression which does contain a map
#' expr = pl$col("mpg")$map(
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
#' @param path String. The path of the parquet file
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
#' @param statistics Boolean. Whether compute and write column statistics.
#' This requires extra compute.
#' @param row_group_size `NULL` or Integer. Size of the row groups in number of
#' rows. If `NULL` (default), the chunks of the DataFrame are used. Writing in
#' smaller chunks may reduce memory pressure and improve writing speeds.
#' @param data_pagesize_limit `NULL` or Integer. If `NULL` (default), the limit
#' will be ~1MB.
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#' @inheritParams LazyFrame_collect
#'
#' @rdname IO_sink_parquet
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
    compression = "zstd",
    compression_level = 3,
    statistics = FALSE,
    row_group_size = NULL,
    data_pagesize_limit = NULL,
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

  lf |>
    .pr$LazyFrame$sink_parquet(
      path,
      compression,
      compression_level,
      statistics,
      row_group_size,
      data_pagesize_limit,
      maintain_order
    ) |>
    unwrap("in $sink_parquet()") |>
    invisible()
}


#' @title Stream the output of a query to an Arrow IPC file
#' @description
#' This writes the output of a query directly to an Arrow IPC file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#' @param path String. The path to the Arrow IPC file
#' @param compression `NULL` or string, the compression method. One of `NULL`,
#' "lz4" or "zstd". Choose "zstd" for good compression performance. Choose "lz4"
#' for fast compression/decompression.
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
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
    compression = "zstd",
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
      compression,
      maintain_order
    ) |>
    unwrap("in $sink_ipc()") |>
    invisible()
}


#' @title Stream the output of a query to a CSV file
#' @description
#' This writes the output of a query directly to a CSV file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#'
#' @inheritParams DataFrame_write_csv
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#'
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
    unwrap("in $sink_csv()") |>
    invisible()
}


#' @title Stream the output of a query to a JSON file
#' @description
#' This writes the output of a query directly to a JSON file without collecting
#' it in the R session first. This is useful if the output of the query is still
#' larger than RAM as it would crash the R session if it was collected into R.
#'
#' @inheritParams DataFrame_write_csv
#' @inheritParams LazyFrame_collect
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
#'
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
    unwrap("in $sink_ndjson()") |>
    invisible()
}


#' @title Limit a LazyFrame
#' @inherit DataFrame_limit description params details
#' @return A `LazyFrame`
#' @examples pl$LazyFrame(mtcars)$limit(4)$collect()
LazyFrame_limit = function(n) {
  unwrap(.pr$LazyFrame$limit(self, n), "in $limit():")
}

#' @title Head of a LazyFrame
#' @inherit DataFrame_head description params details
#'
#' @examples pl$LazyFrame(mtcars)$head(4)$collect()
#' @return A new `LazyFrame` object with applied filter.

LazyFrame_head = function(n) {
  unwrap(.pr$LazyFrame$limit(self, n), "in $head():")
}

#' @title Get the first row of a LazyFrame
#' @keywords DataFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$first()$collect()
LazyFrame_first = "use_extendr_wrapper"

#' @title Get the last row of a LazyFrame
#' @description Aggregate the columns in the LazyFrame to their maximum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$last()$collect()
LazyFrame_last = "use_extendr_wrapper"

#' @title Max
#' @description Aggregate the columns in the LazyFrame to their maximum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$max()$collect()
LazyFrame_max = function() {
  unwrap(.pr$LazyFrame$max(self), "in $max():")
}

#' @title Mean
#' @description Aggregate the columns in the LazyFrame to their mean value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$mean()$collect()
LazyFrame_mean = function() {
  unwrap(.pr$LazyFrame$mean(self), "in $mean():")
}

#' @title Median
#' @description Aggregate the columns in the LazyFrame to their median value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$median()$collect()
LazyFrame_median = function() {
  unwrap(.pr$LazyFrame$median(self), "in $median():")
}

#' @title Min
#' @description Aggregate the columns in the LazyFrame to their minimum value.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$min()$collect()
LazyFrame_min = function() {
  unwrap(.pr$LazyFrame$min(self), "in $min():")
}

#' @title Sum
#' @description Aggregate the columns of this LazyFrame to their sum values.
#' @keywords LazyFrame
#' @return A LazyFrame with one row
#' @docType NULL
#' @format NULL
#' @examples pl$LazyFrame(mtcars)$sum()$collect()
LazyFrame_sum = function() {
  unwrap(.pr$LazyFrame$sum(self), "in $sum():")
}

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

#' @title Drop columns of a LazyFrame
#' @keywords LazyFrame
#' @inheritParams DataFrame_drop
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$drop(c("mpg", "hp"))
LazyFrame_drop = function(columns) {
  unwrap(.pr$LazyFrame$drop(self, columns), "in $drop():")
}

#' @title Reverse
#' @description Reverse the LazyFrame (the last row becomes the first one, etc.).
#' @keywords LazyFrame
#' @return LazyFrame
#' @examples pl$LazyFrame(mtcars)$reverse()$collect()
LazyFrame_reverse = "use_extendr_wrapper"

#' @title Slice
#' @description Get a slice of the LazyFrame.
#' @inheritParams DataFrame_slice
#' @examples
#' pl$LazyFrame(mtcars)$slice(2, 4)$collect()
#' pl$LazyFrame(mtcars)$slice(30)$collect()
#' mtcars[2:6, ]
LazyFrame_slice = function(offset, length = NULL) {
  unwrap(.pr$LazyFrame$slice(self, offset, length), "in $slice():")
}

#' @title Tail of a DataFrame
#' @inherit DataFrame_tail description params details
#' @return A LazyFrame
#' @examples pl$LazyFrame(mtcars)$tail(2)$collect()
LazyFrame_tail = function(n) {
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
  pra = do.call(construct_ProtoExprArray, as.list(subset))
  .pr$LazyFrame$drop_nulls(self, pra)
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
LazyFrame_unique = function(subset = NULL, keep = "first", maintain_order = FALSE) {
  unwrap(.pr$LazyFrame$unique(self, subset, keep, maintain_order), "in unique():")
}

#' Group a LazyFrame
#' @description This doesn't modify the data but only stores information about
#' the group structure. This structure can then be used by several functions
#' (`$agg()`, `$filter()`, etc.).
#' @keywords LazyFrame
#' @param ... Any Expr(s) or string(s) naming a column.
#' @param maintain_order Keep the same order as the original `LazyFrame`. Setting
#'  this to `TRUE` makes it more expensive to compute and blocks the possibility
#'  to run on the streaming engine. The default value can be changed with
#' `pl$set_options(maintain_order = TRUE)`.
#' @return LazyGroupBy (a LazyFrame with special groupby methods like `$agg()`)
#' @examples
#' pl$LazyFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$
#'   group_by("foo")$
#'   agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )$
#'   collect()
LazyFrame_group_by = function(..., maintain_order = pl$options$maintain_order) {
  .pr$LazyFrame$group_by(self, unpack_list(..., .context = "in $group_by():"), maintain_order) |>
    unwrap("in $group_by():")
}

#' Join LazyFrames
#'
#' @inherit DataFrame_join description params
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
LazyFrame_join = function(
    other, # : LazyFrame or DataFrame,
    left_on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    right_on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    on = NULL, # : str | pli.RPolarsExpr | Sequence[str | pli.RPolarsExpr] | None = None,
    how = c("inner", "left", "outer", "semi", "anti", "cross"),
    suffix = "_right",
    allow_parallel = TRUE,
    force_parallel = FALSE) {
  uw = \(res) unwrap(res, "in $join():")

  if (inherits(other, "RPolarsDataFrame")) {
    other = other$lazy()
  }

  if (!is.null(on)) {
    rexprs_right = rexprs_left = as.list(on)
  } else if ((!is.null(left_on) && !is.null(right_on))) {
    rexprs_left = as.list(left_on)
    rexprs_right = as.list(right_on)
  } else if (how != "cross") {
    Err_plain("must specify `on` OR (  `left_on` AND `right_on` ) ") |> uw()
  } else {
    rexprs_left = as.list(self$columns)
    rexprs_right = as.list(other$columns)
  }

  .pr$LazyFrame$join(
    self, other, rexprs_left, rexprs_right,
    how, suffix, allow_parallel, force_parallel
  ) |>
    uw()
}


#' Sort a LazyFrame
#' @description Sort by one or more Expressions.
#' @param by Column(s) to sort by. Can be character vector of column names,
#' a list of Expr(s) or a list with a mix of Expr(s) and column names.
#' @param ... More columns to sort by as above but provided one Expr per argument.
#' @param descending Boolean. Sort in descending order (default is `FALSE`). This must be
#' either of length 1 or a logical vector of the same length as the number of
#' Expr(s) specified in `by` and `...`.
#' @param nulls_last Boolean. Place `NULL`s at the end? Default is `FALSE`.
#' @inheritParams LazyFrame_group_by
#' @inheritParams DataFrame_unique
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
    by, # : IntoExpr | List[IntoExpr],
    ..., # unnamed Into expr
    descending = FALSE, #  bool | vector[bool] = False,
    nulls_last = FALSE,
    maintain_order = FALSE) {
  .pr$LazyFrame$sort_by_exprs(
    self, unpack_list(by, .context = "in $sort():"), err_on_named_args(...),
    descending, nulls_last, maintain_order
  ) |>
    unwrap("in $sort():")
}


#' Perform joins on nearest keys
#'
#' This is similar to a left-join except that we match on nearest key rather
#' than equal keys.
#'
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
#' "Date", "Datetime", "Duration" or "Time" you can use the following values:
#'
#'     - 1ns   (1 nanosecond)
#'     - 1us   (1 microsecond)
#'     - 1ms   (1 millisecond)
#'     - 1s    (1 second)
#'     - 1m    (1 minute)
#'     - 1h    (1 hour)
#'     - 1d    (1 day)
#'     - 1w    (1 week)
#'     - 1mo   (1 calendar month) // currently not available, as interval is not fixed
#'     - 1y    (1 calendar year)  // currently not available, as interval is not fixed
#'     - 1i    (1 index count)
#'
#' Or combine them: "3d12h4m25s" # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' There may be a circumstance where R types are not sufficient to express a
#' numeric tolerance. In that case, you can use the expression syntax like
#' `tolerance = pl$lit(42)$cast(pl$Uint64)`
#'
#' @details
#' Both tables (DataFrames or LazyFrames) must be sorted by the asof_join key.
#'
#' @keywords LazyFrame
#' @return A LazyFrame
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
    strategy = "backward",
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
#' @param id_vars Columns to use as identifier variables.
#' @param value_vars Values to use as identifier variables. If `value_vars` is
#' empty all columns that are not in `id_vars` will be used.
#' @param variable_name Name to give to the new column containing the names of
#' the melted columns. Defaults to "variable".
#' @param value_name Name to give to the new column containing the values of
#' the melted columns. Defaults to "value"
#' @param ... Not used.
#' @param streamable Allow this node to run in the streaming engine. If this
#' runs in streaming, the output of the melt operation will not have a stable
#' ordering.
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
#' lf$melt(id_vars = "a", value_vars = c("b", "c"))$collect()
LazyFrame_melt = function(
    id_vars = NULL,
    value_vars = NULL,
    variable_name = NULL,
    value_name = NULL,
    ...,
    streamable = TRUE) {
  .pr$LazyFrame$melt(
    self, id_vars %||% character(), value_vars %||% character(),
    value_name, variable_name, streamable
  ) |> unwrap("in $melt( ): ")
}

#' @title Rename columns of a DataFrame
#' @keywords LazyFrame
#' @inheritParams DataFrame_rename
#' @return LazyFrame
#' @examples
#' pl$LazyFrame(mtcars)$
#'   rename(miles_per_gallon = "mpg", horsepower = "hp")$
#'   collect()
LazyFrame_rename = function(...) {
  mapping = list2(...)
  if (length(mapping) == 0) {
    return(self)
  }
  if (is.list(mapping[[1L]])) {
    mapping = mapping[[1L]]
  }
  existing = unname(unlist(mapping))
  new = names(mapping)
  unwrap(.pr$LazyFrame$rename(self, existing, new), "in $rename():")
}

#' @rdname LazyFrame_dtypes

LazyFrame_schema = method_as_property(function() {
  .pr$LazyFrame$schema(self) |>
    unwrap("in $schema():")
})

#' Get the column names of a LazyFrame
#' @keywords LazyFrame
#' @return A vector of column names
#' @examples
#' pl$LazyFrame(mtcars)$columns
LazyFrame_columns = method_as_property(function() {
  self$schema |>
    names() |>
    result() |>
    unwrap("in $columns()")
})

#' @title Number of columns of a LazyFrame
#' @description Get the number of columns (width) of a LazyFrame
#' @keywords LazyFrame
#' @return The number of columns of a DataFrame
#' @examples
#' pl$LazyFrame(mtcars)$width
#'
LazyFrame_width = method_as_property(function() {
  length(self$schema)
})

#' Data types information
#' @name LazyFrame_dtypes
#' @inherit DataFrame_dtypes description return
#' @keywords LazyFrame
#' @examples
#' pl$LazyFrame(iris)$dtypes
#'
#' pl$LazyFrame(iris)$schema
LazyFrame_dtypes = method_as_property(function() {
  self$schema |>
    unlist() |>
    unname() |>
    result() |>
    unwrap("in $dtypes()")
})


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
    streaming = FALSE,
    no_optimization = FALSE,
    inherit_optimization = FALSE) {
  if (isTRUE(no_optimization)) {
    predicate_pushdown = FALSE
    projection_pushdown = FALSE
    slice_pushdown = FALSE
    comm_subplan_elim = FALSE
    comm_subexpr_elim = FALSE
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
#' Only columns of DataType `List` or `String` can be exploded.
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
#' # it is also possible to explode a character column to have one letter per row
#' df$explode("letters")
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
#' @description This makes a very cheap deep copy/clone of an existing `LazyFrame`.
#' @return A LazyFrame
#' @examples
#' df1 = pl$LazyFrame(iris)
#' df2 = df1$clone()
#' df3 = df1
#'
#' # the clone and the original don't have the same address...
#' pl$mem_address(df1) != pl$mem_address(df2)
#'
#' # ... but simply assigning df1 to df3 change the address anyway
#' pl$mem_address(df1) == pl$mem_address(df3)
LazyFrame_clone = function() {
  .pr$LazyFrame$clone_in_rust(self)
}


#' Unnest the Struct columns of a LazyFrame
#'
#' @inheritParams DataFrame_unnest
#' @return A LazyFrame where all "struct" columns are unnested. Non-struct
#' columns are not modified.
#' @examples
#' lf = pl$LazyFrame(
#'   a = 1:5,
#'   b = c("one", "two", "three", "four", "five"),
#'   c = 6:10
#' )$
#'   select(
#'   pl$col("b")$to_struct(),
#'   pl$col("a", "c")$to_struct()$alias("a_and_c")
#' )
#' lf$collect()
#'
#' # by default, all struct columns are unnested
#' lf$unnest()$collect()
#'
#' # we can specify specific columns to unnest
#' lf$unnest("a_and_c")$collect()
LazyFrame_unnest = function(names = NULL) {
  if (is.null(names)) {
    names = names(which(dtypes_are_struct(.pr$LazyFrame$schema(self)$ok)))
  }
  unwrap(.pr$LazyFrame$unnest(self, names), "in $unnest():")
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
#' @param by Also group by this column/these columns.
#'
#' @return A [LazyGroupBy][LazyGroupBy_class] object
#'
#' @examples
#' df = pl$LazyFrame(
#'   dt = c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-08"),
#'   a = c(3, 7, 5, 9, 2, 1)
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
#' )
#'
#' df$collect()
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   pl$col("a"),
#'   pl$sum("a")$alias("sum_a"),
#'   pl$min("a")$alias("min_a"),
#'   pl$max("a")$alias("max_a")
#' )$collect()
LazyFrame_rolling = function(index_column, period, offset = NULL, closed = "right", by = NULL, check_sorted = TRUE) {
  if (is.null(offset)) {
    offset = paste0("-", period)
  }
  .pr$LazyFrame$rolling(
    self, index_column, period, offset, closed,
    wrap_elist_result(by, str_to_lit = FALSE), check_sorted
  ) |>
    unwrap("in $rolling():")
}
