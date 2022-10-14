#' @title Inner workings of the LazyFrame-class
#'
#' @name LazyFrame_class
#' @description The `LazyFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the minipolars rust side. The instanciated
#' `DataFrame`-object is an `externalptr` to a lowlevel rust polars DataFrame  object. The pointer address
#' is the only statefullness of the DataFrame object on the R side. Any other state resides on the
#' rust side. The S3 method `.DollarNames.DataFrame` exposes all public `$foobar()`-methods which are callable onto the object.
#' Most methods return another `DataFrame`-class instance or similar which allows for method chaining.
#' This class system in lack of a better name could be called "environment classes" and is the same class
#' system extendr provides, except here there is both a public and private set of methods. For implementation
#' reasons, the private methods are external and must be called from minipolars:::.pr.$DataFrame$methodname(), also
#' all private methods must take self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' @details Check out the source code in R/dataframe_frame.R how public methods are derived from private methods.
#' Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted
#' into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods
#' are removed and replaced by any function prefixed `DataFrame_`.
#'
#' @keywords DataFrame
#' @examples
#' #see all exported methods
#' ls(minipolars:::DataFrame)
#'
#' #see all private methods (not intended for regular use)
#' ls(minipolars:::.pr$DataFrame)
#'
#'
#' #make an object
#' df = pl$DataFrame(iris)
#'
#' #use a public method/property
#' df$shape
#' df2 = df
#' #use a private method, which has mutability
#' result = minipolars:::.pr$DataFrame$set_column_from_robj(df,150:1,"some_ints")
#'
#' #column exists in both dataframes-objects now, as they are just pointers to the same object
#' # there are no public methods with mutability
#' df$columns()
#' df2$columns()
#'
#' # set_column_from_robj-method is fallible and returned a result which could be ok or an err.
#' # This is the same idea as output from functions decorated with purrr::safely.
#' # To use results on R side, these must be unwrapped first such
#' # potentially errors can be thrown. unwrap(result) is a way to
#' # bridge rust not throwing errors with R. Extendr default behaviour is to use panic!(s) which
#' # would case some unneccesary confusing and verbose error messages on the inner workings of rust.
#' unwrap(result) #in this case no error, just a NULL because this mutable method do not return anything
#'
#' #try unwrapping an error from polars due to unmatching column lengths
#' err_result = minipolars:::.pr$DataFrame$set_column_from_robj(df,1:10000,"wrong_length")
#' tryCatch(unwrap(err_result,call=NULL),error=\(e) cat(as.character(e)))
LazyFrame


#' @export
#' @title auto complete $-access into object
#' @description called by the interactive R session internally
#' @keywords LazyFrame
#' @examples
#' e = pl$lit("any polars object")$
#' e$ #place cursor after $ this line and press tab
#'
#' #manually call like this (should never be needed)
#' .DollarNames.Expr
.DollarNames.LazyFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::LazyFrame, pattern = pattern ),"()")
}

#' print LazyFrame s3 method
#' @keywords LazyFrame
#' @param x DataFrame
#' @keywords LazyFrame
#'
#' @return self
#' @export
#'
#' @examples print(pl$DataFrame(iris)$lazy())
print.LazyFrame = function(x) {
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
#' @examples  pl$DataFrame(iris)$lazy()$print()
LazyFrame_print = "use_extendr_wrapper"

#TODO write missing examples in this file

#' @title Print the optmized plan of LazyFrame
#' @description select on a LazyFrame
#' @keywords LazyFrame
#'
LazyFrame_describe_optimized_plan  = function() {
  unwrap(.pr$LazyFrame$describe_optimized_plan(self))
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
#' @return A new `LazyFrame` object with add/modified column.
LazyFrame_with_column = "use_extendr_wrapper"

#' @title Apply filter to LazyFrame
#' @description Filter rows with an Expression definining a boolean column
#' @keywords LazyFrame
#' @param expr one Expr or string naming a column
#' @return A new `LazyFrame` object with add/modified column.
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
LazyFrame_filter = "use_extendr_wrapper"

#' @title LazyFrame collect
#' @description collect DataFrame by lazy query
#' @keywords LazyFrame
#' @return collected `DataFrame`
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
LazyFrame_collect = function() {
  unwrap(.pr$LazyFrame$collect(self))
}

#' @title Limits
#' @description take limit of n rows of query
#' @keywords LazyFrame
#' @param n positive numeric or integer number not larger than 2^32
#' @importFrom  rlang is_scalar_integerish
#'
#' @details any number will converted to u32. Negative raises error
#'
#' @return A new `LazyFrame` object with applied filter.
LazyFrame_limit = function(n) {
  if(!is_scalar_integerish(n) || n>2^32-1 || n<0) {
    unwrap(list(err=paste("in LazyFrame$limit(n): n must be integerish within the bounds [0; 2^32-1]. n was:",n)))
  }
  .pr$LazyFrame$limit(self,n)
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
    abort(paste("Expected a `LazyFrame` as join table, got ", class(other)))
  }

  how_opts = c('inner', 'left', 'outer', 'semi', 'anti', 'cross')
  how = match.arg(how[1],how_opts)

  if(how == "cross") {
    abort("not implemented how == cross")
  }

  if(!is.null(on)) {
    rexprs = do.call(construct_ProtoExprArray,as.list(on))
    rexprs_left  = rexprs
    rexprs_right = rexprs
  } else if ((!is.null(left_on) && !is.null(right_on))) {
    rexprs_left  = do.call(construct_ProtoExprArray, as.list(left_on))
    rexprs_right = do.call(construct_ProtoExprArray, as.list(right_on))
  } else {
    abort("must specify `on` OR (  `left_on` AND `right_on` ) ")
  }

  .pr$LazyFrame$join(
    self, other, rexprs_left, rexprs_right,
    how, suffix, allow_parallel, force_parallel
  )

}






