#' @title Inner workings of the LazyFrame-class
#'
#' @name LazyFrame_class
#' @description The `LazyFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the rpolars rust side. The instanciated
#' `LazyFrame`-object is an `externalptr` to a lowlevel rust polars LazyFrame  object. The pointer address
#' is the only statefullness of the LazyFrame object on the R side. Any other state resides on the
#' rust side. The S3 method `.DollarNames.LazyFrame` exposes all public `$foobar()`-methods which are callable onto the object.
#' Most methods return another `LazyFrame`-class instance or similar which allows for method chaining.
#' This class system in lack of a better name could be called "environment classes" and is the same class
#' system extendr provides, except here there is both a public and private set of methods. For implementation
#' reasons, the private methods are external and must be called from rpolars:::.pr.$LazyFrame$methodname(), also
#' all private methods must take any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' `DataFrame` and `LazyFrame` can both be said to be a `Frame`. To convert use `DataFrame_object$lazy() -> LazyFrame_object` and
#' `LazyFrame_object$collect() -> DataFrame_object`. This is quite similar to the lazy-collect syntax of the dplyrpackage to
#' interact with database connections such as SQL variants. Most SQL databases would be able to perform the same otimizations
#' as polars such Predicate Pushdown and Projection. However polars can intertact and optimize queries with both SQL DBs
#' and other data sources such parquet files simultanously. (#TODO implement rpolars SQL ;)
#'
#' @details Check out the source code in R/LazyFrame__lazy.R how public methods are derived from private methods.
#' Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted
#' into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods
#' are removed and replaced by any function prefixed `LazyFrame_`.
#'
#' @keywords LazyFrame
#' @examples
#' #see all exported methods
#' ls(rpolars:::LazyFrame)
#'
#' #see all private methods (not intended for regular use)
#' ls(rpolars:::.pr$LazyFrame)
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
#'   Pdf_okay$as_data_frame(),
#'   Pdf_best$as_data_frame()
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
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_limit = function(n) {
  if(!is.numeric(n)) stopf("limit: n must be numeric")
  unwrap(.pr$LazyFrame$limit(self,n))
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






