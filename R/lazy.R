
#' @export
.DollarNames.LazyFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::LazyFrame),"()")
}

#' print GroupBy
#'
#' @param x polar_frame
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$groupby("Species")
print.LazyFrame= function(x) {
  print("polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)")
  x$print()
  invisible(x)
}



#' @title Lazy_select
#' @description select on a lazy DataFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_describe_optimized_plan  = function(...) {
  unwrap(.pr$LazyFrame$describe_optimized_plan(self,pra))
}

#' @title Lazy_select
#' @description select on a lazy DataFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_select = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$select(self,pra)
}

#' @title Lazy_with_columns
#' @description add or replace columns of lazy DataFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_with_columns = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$with_columns(self,pra)
}

#' @title Lazy_with_columns
#' @description add or replace columns of lazy DataFrame
#'
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_collect = function() {
  unwrap(.pr$LazyFrame$collect(self))
}

#' @title Lazy_limit
#' @description take limit of n rows of query
#'
#' @param n positive numeric or integer number not larger than 2^32
#' @importFrom  rlang is_scalar_integerish
#'
#' @details any number will converted to u32. Negative raises error
#'
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_limit = function(n) {
  if(!is_scalar_integerish(n) || n>2^32-1 || n<0) {
    unwrap(list(err=paste("in LazyFrame$limit(n): n must be integerish within the bounds [0; 2^32-1]. n was:",n)))
  }
  .pr$LazyFrame$limit(self,n)
}


#' @title Lazy_groupby
#' @description
#' groupby on lazy_polar_frame.
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_groupby = function(..., maintain_order = FALSE) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$groupby(self,pra,maintain_order)
}


#' @param other LazyFrame
#' @param on named columns as char vector of named columns, or list of expressions and/or strings.
#' @param left_on names of columns in self LazyFrame, order should match. Type, see on param.
#' @param right_on names of columns in other LazyFrame, order should match. Type, see on param.
#' @param how a string selecting one of the following methods: inner, left, outer, semi, anti, cross
#' @param suffix name to added right table
#' @param allow_parallel bool
#' @param force_parallel bool
#'
#' @title LazyFrame join
#' @description join a lazy DataFrame
#'
#' @return A new `lazy_polar_frame` object with applied join.
Lazy_join = function(
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


## ----- LazyGroupBy


#' print LazyGroupBy
#'
#' @param x LazyGroupBy
#'
#' @return self
#' @export
#'
print.LazyGroupBy = function(x) {
  cat("polars LazyGroupBy: \n")
  x$print()
}

#' @title LazyGroupBy_agg
#' @description
#' aggregate a polar_lazy_groupby
#' @param ... any Expr or string
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_agg = agg = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyGroupBy$agg(self,pra)
}

#' @title LazyGroupBy_apply
#' @description
#' one day this will apply
#' @param f lambda function to apply
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_apply = function(f) {
  abort("this function is not yet implemented")
}

#' @title LazyGroupBy_head
#' @description
#' get n rows of head of group
#' @param n integer number of rows to get
#' @importFrom rlang is_integerish
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_head = function(n=1L) {
  if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
  .pr$LazyGroupBy$head(n)
}


#' @title LazyGroupBy_tail
#' @description
#' get n tail rows of group
#' @param n integer number of rows to get
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_tail = function(n = 1L) {
  if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
  .pr$LazyGroupBy$tail(n)
}


#' @title LazyGroupBy_print
#' @description
#' prints opague groupby, not much to show
#' @return NULL
LazyGroupBy_print = function() {
  .pr$LazyGroupBy$print(self)
  invisible(self)
}




