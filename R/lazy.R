#TODO document LazyFrame class as DataFrame has been

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






