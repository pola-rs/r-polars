#' @title Inner workings of the LazyFrame-class
#'
#' @name LazyFrame_class
#' @description The `LazyFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the polars rust side. The instanciated
#' `LazyFrame`-object is an `externalptr` to a lowlevel rust polars LazyFrame  object. The pointer address
#' is the only statefullness of the LazyFrame object on the R side. Any other state resides on the
#' rust side. The S3 method `.DollarNames.LazyFrame` exposes all public `$foobar()`-methods which are callable onto the object.
#' Most methods return another `LazyFrame`-class instance or similar which allows for method chaining.
#' This class system in lack of a better name could be called "environment classes" and is the same class
#' system extendr provides, except here there is both a public and private set of methods. For implementation
#' reasons, the private methods are external and must be called from polars:::.pr.$LazyFrame$methodname(), also
#' all private methods must take any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' `DataFrame` and `LazyFrame` can both be said to be a `Frame`. To convert use `DataFrame_object$lazy() -> LazyFrame_object` and
#' `LazyFrame_object$collect() -> DataFrame_object`. This is quite similar to the lazy-collect syntax of the dplyrpackage to
#' interact with database connections such as SQL variants. Most SQL databases would be able to perform the same otimizations
#' as polars such Predicate Pushdown and Projection. However polars can intertact and optimize queries with both SQL DBs
#' and other data sources such parquet files simultanously. (#TODO implement r-polars SQL ;)
#'
#' @details Check out the source code in R/LazyFrame__lazy.R how public methods are derived from private methods.
#' Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted
#' into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods
#' are removed and replaced by any function prefixed `LazyFrame_`.
#'
#' @keywords LazyFrame
#' @examples
#' #see all exported methods
#' ls(polars:::LazyFrame)
#'
#' #see all private methods (not intended for regular use)
#' ls(polars:::.pr$LazyFrame)
#'
#'
#' ## Practical example ##
#' # First writing R iris dataset to disk, to illustrte a difference
#' temp_filepath = tempfile()
#' write.csv(iris, temp_filepath,row.names = FALSE)
#'
#' # Following example illustrates 2 ways to obtain a LazyFrame
#'
#' # The-Okay-way: convert an in-memory DataFrame to LazyFrame
#'
#' #eager in-mem R data.frame
#' Rdf = read.csv(temp_filepath)
#'
#' #eager in-mem polars DataFrame
#' Pdf = pl$DataFrame(Rdf)
#'
#' #lazy frame starting from in-mem DataFrame
#' Ldf_okay = Pdf$lazy()
#'
#' #The-Best-Way:  LazyFrame created directly from a data source is best...
#' Ldf_best = pl$lazy_csv_reader(temp_filepath)
#'
#' # ... as if to e.g. filter the LazyFrame, that filtering also caleld predicate will be
#' # pushed down in the executation stack to the csv_reader, and thereby only bringing into
#' # memory the rows matching to filter.
#' # apply filter:
#' filter_expr = pl$col("Species") == "setosa" #get only rows where Species is setosa
#' Ldf_okay = Ldf_okay$filter(filter_expr) #overwrite LazyFrame with new
#' Ldf_best = Ldf_best$filter(filter_expr)
#'
#' # the non optimized plans are similar, on entire in-mem csv, apply filter
#' Ldf_okay$describe_plan()
#' Ldf_best$describe_plan()
#'
#' # NOTE For Ldf_okay, the full time to load csv alrady paid when creating Rdf and Pdf
#'
#' #The optimized plan are quite different, Ldf_best will read csv and perform filter simultanously
#' Ldf_okay$describe_optimized_plan()
#' Ldf_best$describe_optimized_plan()
#'
#'
#' #To acquire result in-mem use $colelct()
#' Pdf_okay = Ldf_okay$collect()
#' Pdf_best = Ldf_best$collect()
#'
#'
#' #verify tables would be the same
#' all.equal(
#'   Pdf_okay$to_data_frame(),
#'   Pdf_best$to_data_frame()
#' )
#'
#' #a user might write it as a one-liner like so:
#' Pdf_best2 = pl$lazy_csv_reader(temp_filepath)$filter(pl$col("Species") == "setosa")
LazyFrame


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x LazyFrame
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.LazyFrame = function(x, pattern = "") {
  paste0(ls(LazyFrame, pattern = pattern ),"()")
}

#' print LazyFrame s3 method
#' @keywords LazyFrame
#' @param x DataFrame
#' @param ... not used
#' @keywords LazyFrame
#'
#' @return self
#' @export
#'
#' @examples print(pl$DataFrame(iris)$lazy())
print.LazyFrame = function(x, ...) {
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
#' @export
#'
#' @usage LazyFrame_print(x)
#' @examples  pl$DataFrame(iris)$lazy()$print()
LazyFrame_print = "use_extendr_wrapper"

#TODO write missing examples in this file

#' @title Print the optmized plan of LazyFrame
#' @description select on a LazyFrame
#' @keywords LazyFrame
#'
LazyFrame_describe_optimized_plan  = function() {
  unwrap(.pr$LazyFrame$describe_optimized_plan(self))
  invisible(NULL)
}

#' @title Print the non-optimized plan plan of LazyFrame
#' @description select on a LazyFrame
#' @keywords LazyFrame
LazyFrame_describe_plan  = "use_extendr_wrapper"

#' @title Lazy_select
#' @description select on a LazyFrame
#' @keywords LazyFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_select = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$select(self,pra)
}

#' @title Lazy with columns
#' @description add or replace columns of LazyFrame
#' @keywords LazyFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `LazyFrame` object with added/modified columns.
LazyFrame_with_columns = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$with_columns(self,pra)
}

#' @title Lazy with column
#' @description add or replace columns of LazyFrame
#' @keywords LazyFrame
#' @param expr one Expr or string naming a column
#' @usage LazyFrame_with_column(expr)
#' @return A new `LazyFrame` object with add/modified column.
LazyFrame_with_column = "use_extendr_wrapper"

#' @title Apply filter to LazyFrame
#' @description Filter rows with an Expression definining a boolean column
#' @keywords LazyFrame
#' @param expr one Expr or string naming a column
#' @return A new `LazyFrame` object with add/modified column.
#' @usage LazyFrame_filter(expr)
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
LazyFrame_filter = "use_extendr_wrapper"

#' @title New DataFrame from LazyFrame_object$collect()
#' @description collect DataFrame by lazy query
#' @keywords LazyFrame DataFrame_new
#' @return collected `DataFrame`
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
LazyFrame_collect = function() {
  unwrap(.pr$LazyFrame$collect(self))
}

#' @title New DataFrame from LazyFrame_object$collect()
#' @description collect DataFrame by lazy query
#' @keywords LazyFrame DataFrame_new
#' @return collected `DataFrame`
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
LazyFrame_collect_background = function() {
  .pr$LazyFrame$collect_background(self)
}

#' @title Limits
#' @description take limit of n rows of query
#' @keywords LazyFrame
#' @param n positive numeric or integer number not larger than 2^32
#'
#' @details any number will converted to u32. Negative raises error
#'
#' @examples pl$DataFrame(mtcars)$lazy()$limit(4)$collect()
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_limit = function(n) {
  if(!is.numeric(n)) stopf("limit: n must be numeric")
  unwrap(.pr$LazyFrame$limit(self,n))
}

#' @title First
#' @description Get the first row of the DataFrame.
#' @keywords DataFrame
#' @return A new `DataFrame` object with applied filter.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$first()$collect()
LazyFrame_first = "use_extendr_wrapper"

#' @title Last
#' @description Aggregate the columns in the DataFrame to their maximum value.
#' @keywords LazyFrame
#' @return A new `LazyFrame` object with applied aggregation.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$last()$collect()
LazyFrame_last = "use_extendr_wrapper"

#' @title Max
#' @description Aggregate the columns in the DataFrame to their maximum value.
#' @keywords LazyFrame
#' @return A new `LazyFrame` object with applied aggregation.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$max()$collect()
LazyFrame_max = "use_extendr_wrapper"

#' @title Mean
#' @description Aggregate the columns in the DataFrame to their mean value.
#' @keywords LazyFrame
#' @return A new `LazyFrame` object with applied aggregation.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$mean()$collect()
LazyFrame_mean = "use_extendr_wrapper"

#' @title Median
#' @description Aggregate the columns in the DataFrame to their median value.
#' @keywords LazyFrame
#' @return A new `LazyFrame` object with applied aggregation.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$median()$collect()
LazyFrame_median = "use_extendr_wrapper"

#' @title Min
#' @description Aggregate the columns in the DataFrame to their minimum value.
#' @keywords LazyFrame
#' @return A new `LazyFrame` object with applied aggregation.
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$min()$collect()
LazyFrame_min = "use_extendr_wrapper"

#' @title Sum
#' @description Aggregate the columns of this DataFrame to their sum values.
#' @keywords LazyFrame
#' @return LazyFrame
#' @docType NULL
#' @format function
#' @examples pl$DataFrame(mtcars)$lazy()$sum()$collect()
LazyFrame_sum = "use_extendr_wrapper"

#' @title Var
#' @description Aggregate the columns of this LazyFrame to their variance values.
#' @keywords LazyFrame
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `LazyFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$lazy()$var()$collect()
LazyFrame_var = function(ddof = 1) {
  unwrap(.pr$LazyFrame$var(self, ddof))
}

#' @title Std
#' @description Aggregate the columns of this LazyFrame to their standard deviation values.
#' @keywords LazyFrame
#' @param ddof integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.
#' @return A new `LazyFrame` object with applied aggregation.
#' @examples pl$DataFrame(mtcars)$lazy()$std()$collect()
LazyFrame_std = function(ddof = 1) {
  unwrap(.pr$LazyFrame$std(self, ddof))
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to their quantile value.
#' @keywords LazyFrame
#' @param quantile numeric Quantile between 0.0 and 1.0.
#' @param interpolation string Interpolation method: "nearest", "higher", "lower", "midpoint", or "linear".
#' @return LazyFrame
#' @examples pl$DataFrame(mtcars)$lazy()$quantile(.4)$collect()
LazyFrame_quantile = function(quantile, interpolation = "nearest") {
  unwrap(.pr$LazyFrame$quantile(self, wrap_e_result(quantile), interpolation))
}

#' @title Fill NaN
#' @description Fill floating point NaN values by an Expression evaluation.
#' @keywords LazyFrame
#' @param fill_value Value to fill NaN with.
#' @return LazyFrame
#' @examples
#' df = pl$DataFrame(
#'         a = c(1.5, 2, NaN, 4),
#'         b = c(1.5, NaN, NaN, 4)
#' )$lazy()
#' df$fill_nan(99)$collect()
LazyFrame_fill_nan = function(fill_value) {
  unwrap(.pr$LazyFrame$fill_nan(self, wrap_e_result(fill_value)))
}

#' @title Fill null
#' @description Fill null values using the specified value or strategy.
#' @keywords LazyFrame
#' @param fill_value Value to fill `NA` with.
#' @return LazyFrame
#' @examples
#' df = pl$DataFrame(
#'         a = c(1.5, 2, NA, 4),
#'         b = c(1.5, NA, NA, 4)
#' )$lazy()
#' df$fill_null(99)$collect()
LazyFrame_fill_null = function(fill_value) {
  unwrap(.pr$LazyFrame$fill_null(self, wrap_e_result(fill_value)))
}

#' @title Shift
#' @description Shift the values by a given period.
#' @keywords LazyFrame
#' @param periods integer Number of periods to shift (may be negative).
#' @return LazyFrame
#' @examples pl$DataFrame(mtcars)$lazy()$shift(2)$collect()
LazyFrame_shift = function(periods = 1) {
  unwrap(.pr$LazyFrame$shift(self, periods))
}

#' @title Shift and fill
#' @description Shift the values by a given period and fill the resulting null values.
#' @keywords LazyFrame
#' @param fill_value fill None values with the result of this expression.
#' @param periods integer Number of periods to shift (may be negative).
#' @return LazyFrame
#' @examples pl$DataFrame(mtcars)$lazy()$shift_and_fill(0., 2.)$collect()$as_data_frame()
LazyFrame_shift_and_fill = function(fill_value, periods = 1) {
  unwrap(.pr$LazyFrame$shift_and_fill(self, wrap_e(fill_value), periods))
}

#' @title Drop
#' @description Remove columns from the dataframe.
#' @keywords LazyFrame
#' @param columns character vector Name of the column(s) that should be removed from the dataframe.
#' @return LazyFrame
#' @examples pl$DataFrame(mtcars)$lazy()$drop(c("mpg", "hp"))
LazyFrame_drop = function(columns) {
  unwrap(.pr$LazyFrame$drop(self, columns))
}

#' @title Reverse
#' @description Reverse the DataFrame.
#' @keywords LazyFrame
#' @return LazyFrame
#' @examples pl$DataFrame(mtcars)$lazy()$reverse()$collect()
LazyFrame_reverse = "use_extendr_wrapper"

#' @title Slice
#' @description Get a slice of this DataFrame.
#' @keywords DataFrame
#' @return DataFrame
#' @param offset integer
#' @param length integer or NULL
#' @examples
#' pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()
#' pl$DataFrame(mtcars)$lazy()$slice(30)$collect()
#' mtcars[2:6,]
LazyFrame_slice = function(offset, length = NULL) {
  unwrap(.pr$LazyFrame$slice(self, offset, length))
}

#' @title Tail
#' @description take last n rows of query
#' @keywords LazyFrame
#' @param n positive numeric or integer number not larger than 2^32
#'
#' @details any number will converted to u32. Negative raises error
#'
#' @examples pl$DataFrame(mtcars)$lazy()$tail(2)$collect()
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_tail = function(n) {
  unwrap(.pr$LazyFrame$tail(self,n))
}

#' @title Lazy_drop_nulls
#' @description Drop all rows that contain null values.
#' @keywords LazyFrame
#' @param subset string or vector of strings. Column name(s) for which null values are considered. If set to NULL (default), use all columns.
#'
#' @return LazyFrame
#' @examples
#' tmp = mtcars
#' tmp[1:3, "mpg"] = NA
#' tmp[4, "hp"] = NA
#' pl$DataFrame(tmp)$lazy()$drop_nulls()$collect()$height
#' pl$DataFrame(tmp)$lazy()$drop_nulls("mpg")$collect()$height
#' pl$DataFrame(tmp)$lazy()$drop_nulls(c("mpg", "hp"))$collect()$height
LazyFrame_drop_nulls = function(subset = NULL) {
  pra = do.call(construct_ProtoExprArray, as.list(subset))
  .pr$LazyFrame$drop_nulls(self, pra)
}

#' @title Lazy_unique
#' @description Drop duplicate rows from this dataframe.
#' @keywords LazyFrame
#' @param subset string or vector of strings. Column name(s) to consider when identifying duplicates. If set to NULL (default), use all columns.
#' @param keep string. Which of the duplicate rows to keep:
#' * "first": Keep first unique row.
#' * "last": Keep last unique row.
#' * "none": Don’t keep duplicate rows.
#'
#' @return LazyFrame
#' @examples
#' df = pl$DataFrame(
#'   x = as.numeric(c(1, 1:5)),
#'   y = as.numeric(c(1, 1:5)),
#'   z = as.numeric(c(1, 1, 1:4)))
#' df$lazy()$unique()$collect()$height
#' df$lazy()$unique(subset = c("x", "z"), keep = "last")$collect()$height
LazyFrame_unique = function(subset = NULL, keep = "first") {
  if (is.null(subset)) subset = vector("character")
  unwrap(.pr$LazyFrame$unique(self, subset, keep),  "in unique():")
}

#' @title Lazy_groupby
#' @description apply groupby on LazyFrame, return LazyGroupBy
#' @keywords LazyFrame
#' groupby on LazyFrame.
#'
#' @param ... any single Expr or string naming a column
#' @param maintain_order bool should an aggregate of groupby retain order of groups or FALSE = random, slightly faster?
#'
#' @return A new `LazyGroupBy` object with applied groups.
LazyFrame_groupby = function(..., maintain_order = FALSE) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$groupby(self,pra,maintain_order)
}

#' @title LazyFrame join
#' @description join a LazyFrame
#' @keywords LazyFrame
#' @param other LazyFrame
#' @param on named columns as char vector of named columns, or list of expressions and/or strings.
#' @param left_on names of columns in self LazyFrame, order should match. Type, see on param.
#' @param right_on names of columns in other LazyFrame, order should match. Type, see on param.
#' @param how a string selecting one of the following methods: inner, left, outer, semi, anti, cross
#' @param suffix name to added right table
#' @param allow_parallel bool
#' @param force_parallel bool
#'
#' @return A new `LazyFrame` object with applied join.
LazyFrame_join = function(
  other,#: LazyFrame or DataFrame,
  left_on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  right_on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  how = c("inner", 'left', 'outer', 'semi', 'anti', 'cross'),
  suffix = "_right",
  allow_parallel = TRUE,
  force_parallel  = FALSE
  ) {

  if (inherits(other, "LazyFrame")) {
    #nothing
  } else if (inherits(other, "DataFrame")){
    other = other$lazy()
  } else {
    stopf(paste("Expected a `LazyFrame` as join table, got ", class(other)))
  }

  how_opts = c('inner', 'left', 'outer', 'semi', 'anti', 'cross')
  how = match.arg(how[1L],how_opts)

  if(how == "cross") {
    stopf("not implemented how == cross")
  }

  if(!is.null(on)) {
    rexprs = do.call(construct_ProtoExprArray,as.list(on))
    rexprs_left  = rexprs
    rexprs_right = rexprs
  } else if ((!is.null(left_on) && !is.null(right_on))) {
    rexprs_left  = do.call(construct_ProtoExprArray, as.list(left_on))
    rexprs_right = do.call(construct_ProtoExprArray, as.list(right_on))
  } else {
    stopf("must specify `on` OR (  `left_on` AND `right_on` ) ")
  }

  .pr$LazyFrame$join(
    self, other, rexprs_left, rexprs_right,
    how, suffix, allow_parallel, force_parallel
  )

}




#' LazyFrame Sort
#' @description sort a LazyFrame by on or more Expr
#'
#' @param by Column(s) to sort by. Column name strings, character vector of
#' column names, or Iterable Into<Expr> (e.g. one Expr, or list mixed Expr and
#' column name strings).
#' @param ... more columns to sort by as above but provided one Expr per argument.
#' @param descending Sort descending? Default = FALSE logical vector of length 1 or same length
#' as number of Expr's from above by + ....
#' @param nulls_last Bool default FALSE, place all nulls_last?
#' @details by and ... args allow to either provide e.g. a list of Expr or something which can
#' be converted into an Expr e.g. `$sort(list(e1,e2,e3))`,
#' or provide each Expr as an individual argument `$sort(e1,e2,e3)`´ ... or both.
#'
#'
#' @return LazyFrame
#' @keywords  DataFrame
#' @examples
#' df = mtcars
#' df$mpg[1] = NA
#' df = pl$DataFrame(df)
#' df$lazy()$sort("mpg")$collect()
#' df$lazy()$sort("mpg", nulls_last = TRUE)$collect()
#' df$lazy()$sort("cyl", "mpg")$collect()
#' df$lazy()$sort(c("cyl", "mpg"))$collect()
#' df$lazy()$sort(c("cyl", "mpg"), descending = TRUE)$collect()
#' df$lazy()$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE))$collect()
#' df$lazy()$sort(pl$col("cyl"), pl$col("mpg"))$collect()
LazyFrame_sort = function(
  by, # : IntoExpr | List[IntoExpr],
  ..., # unnamed Into expr
  descending = FALSE, #  bool | vector[bool] = False,
  nulls_last =FALSE
) {

  largs = list2(...)
  nargs = names(largs)

  #match on args to check for ...
  pcase(
    # all the bad stuff
    !is.null(nargs) && length(nargs) && any(nchar(nargs)), Err("arg [...] cannot be named"),
    missing(by), Err("arg [by] is missing"),

    #iterate over by + ... to wrap into Expr. Capture ok/err in results
    or_else = Ok(c(
        lapply(by, wrap_e_result, str_to_lit = FALSE),
        lapply(largs, wrap_e_result, str_to_lit = FALSE)
      ))
  ) |>


  #and_then skips step, if input is an Error otherwise call rust wrapper
  and_then(\(by_combined) { #by_combined has Rtyp" List<Result<Expr,String>>
    .pr$LazyFrame$sort_by_exprs(self, by_combined, descending, nulls_last)
  }) |>


  #add same context to any Error
  unwrap("in sort():")

}


#' join_asof
#'
#' @param other LazyFrame
#' @param ...  not used, blocks use of further positional arguments
#' @param left_on column name or Expr,  join column of left table
#' @param right_on column name or Expr, join column of right (other) table
#' @param on column name or Expr, sets both left_on and right_on
#' @param by_left Default NULL (no grouping) or character vector of columns to group by in left
#' table.
#' @param by_right Default NULL (no grouping) or character vector of columns to group by in right
#' table.
#' @param by Default NULL, optional set/override by_left and by_right simultaneously
#' @param strategy Default "backward". Strategy for where to find match. "Backward" searches in a
#' descending direction and "Forward" searches in Ascending direction.
#' @param suffix append suffix to right (other) columns, if duplicated names
#' @param tolerance
#' Numeric tolerance. By setting this the join will only be done if the near
#' keys are within this distance. If an asof join is done on columns of dtype
#' "Date", "Datetime", "Duration" or "Time" you use the following string
#' language:
#'
#'     - 1ns   (1 nanosecond)
#'     - 1us   (1 microsecond)
#'     - 1ms   (1 millisecond)
#'     - 1s    (1 second)
#'     - 1m    (1 minute)
#'     - 1h    (1 hour)
#'     - 1d    (1 day)
#'     - 1w    (1 week)
#'     - 1mo   (1 calendar month)
#'     - 1y    (1 calendar year)
#'     - 1i    (1 index count)
#'
#' Or combine them: "3d12h4m25s" # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' There may be a circumstance where R types are not sufficient to express a numeric tolerance.
#' For that case expression syntax is also enabled like e.g.
#' `tolerance = pl$lit(42)$cast(pl$Uint64)`
#'
#' @param allow_parallel Default TRUE, Allow the physical plan to optionally evaluate the
#' computation of both DataFrames up to the join in parallel.
#' @param force_parallel Default FALSE, Force the physical plan to evaluate the computation of both
#' DataFrames up to the join in parallel.
#'
#' @name LazyFrame_join_asof
#' @description Perform an asof join.
#' @details
#' This is similar to a left-join except that we match on nearest key rather than equal keys.
#'
#' Both DataFrames must be sorted by the asof_join key.
#'
#' For each row in the left DataFrame:
#'
#'   - A "backward" search selects the last row in the right DataFrame whose
#'     'on' key is less than or equal to the left's key.
#'
#'   - A "forward" search selects the first row in the right DataFrame whose
#'     'on' key is greater than or equal to the left's key.
#'
#' The default is "backward".
#' @keywords LazyFrame
#' @return joined LazyFrame
#' @examples #
LazyFrame_join_asof = function(
  other, #LazyFrame
  ..., #
  left_on = NULL,         # , : str | None | Expr = None,
  right_on = NULL,        # , : str | None | Expr = None,
  on= NULL,               # ,: str | None | Expr = None,
  by_left = NULL,         #, : str | Sequence[str] | None = None,
  by_right = NULL,        #,: str | Sequence[str] | None = None,
  by = NULL,              #,: str | Sequence[str] | None = None,
  strategy = "backward",        #: AsofJoinStrategy = "backward",
  suffix = "_right",
  tolerance = NULL,       #: str | int | float | None = None,
  allow_parallel = TRUE,  #: bool = True,
  force_parallel = FALSE  #: bool = False,
){

  if(!is.null(by)) by_left = by_right = by
  if(!is.null(on)) left_on = right_on = on
  tolerance_str = if(is.character(tolerance)) tolerance else NULL
  tolerance_num = if(!is.character(tolerance)) NULL else tolerance

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



