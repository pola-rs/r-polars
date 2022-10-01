#' @title Polars DataFrame
#' @rdname DataFrame
#' @name DataFrame
#' @param data object inheriting data.frame or list of equal length vectors and/or Series.
#' @description `DataFrame`-object is an `externalptr` to rust polars DataFrame with $methods() exposed.
#' Most methods return another `DataFrame`-class instance or similar which allows for method chaining.
#' @examples
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
DataFrame

#' @export
.DollarNames.DataFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::DataFrame),"()")
}

#' s3 method print DataFrame
#'
#' @param x DataFrame
#' @rdname DataFrame
#' @name print()
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
print.DataFrame = function(x) {
  cat("polars DataFrame: ")
  x$print()
  invisible(x)
}

#' internal method print DataFrame
#'
#' @param x DataFrame
#' @rdname DataFrame
#' @name print()
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
DataFrame_print = function(x) {
  .pr$DataFrame$print(self)
}

##"Class methods"

#' Validate data input for Dataframe_constructor
#'
#' @param robj any R object to test
#'
#' @description The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.
#'
#' @return bool
#' @export
#'
#' @examples is_DataFrame_data_input(iris)
#' is_DataFrame_data_input(list(1:5,pl$Series(1:5),letters[1:5]))
is_DataFrame_data_input = function(x) {
  inherits(x,"data.frame") ||
    (
      is.list(x) ||
        all(sapply(data,function(x) is.vector(x) ||
                     inherits(x,"Series")
        ))
    )

}


##"properties"


#' @name DataFrame_shape
#' @description Get shape of DataFrame
#' @rdname DataFrame
#' @return two length numeric vector of shape
#' @aliases shape
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$shape()
#'
DataFrame_shape = function() {
  .pr$DataFrame$shape(self)
}

#' @name DataFrame_height
#' @description Get height(nrow) of DataFrame
#' @rdname DataFrame
#' @return height as numeric
#' @aliases height, nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$height()
#'
DataFrame_height = function() {
  .pr$DataFrame$shape(self)[1]
}


#' @name DataFrame_width
#' @description Get width(ncol) of DataFrame
#' @rdname DataFrame
#' @return width as numeric
#' @aliases width, nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$width()
#'
DataFrame_width = function() {
  .pr$DataFrame$shape(self)[2]
}

#' @name DataFrame_lazy
#' @description DataFrame to LazyFrame
#' @rdname DataFrame
#' @return LazyFrame
#' @aliases lazy
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$lazy()
#'
DataFrame_lazy = function() {
  .pr$DataFrame$lazy(self)
}

#' @name DataFrame_clone
#' @description clone DataFrame
#' @rdname DataFrame
#' @return DataFrame
#' @aliases clone
#' @keywords  DataFrame
#' @examples
#' df1 = pl$DataFrame(iris);
#' df2 =  df1$clone();
#' df3 = df1
#' xptr::xptr_address(df1) != xptr::xptr_address(df2)
#' xptr::xptr_address(df1) == xptr::xptr_address(df3)
#'
DataFrame_clone = function() {
  .pr$DataFrame$clone_see_me_macro(self)
}

#' @name DataFrame_get_columns
#' @description get columns as list of series
#' @rdname DataFrame
#' @return list of series
#' @aliases get_columns
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_columns()
DataFrame_get_columns = function() {
  .pr$DataFrame$get_columns(self)
}

#' @name DataFrame_get_column
#' @description get one column by name as series
#' @rdname DataFrame
#' @return Series
#' @aliases get_column
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self, name))
}

#' @name to_list
#' @description DataFrame to R list of vectors
#' @rdname DataFrame
#' @return R list of vectors
#' @aliases to_list
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$to_list()
#'
DataFrame_to_list = function() {
  unwrap(.pr$DataFrame$to_list())
}



#' create new DataFrame
#'
#' @param data a data.frame or list of mixed vectors and Series of equal length.
#'
#' @return DataFrame
#' @importFrom xptr xptr_address
#' @importFrom rlang abort
#'
#' @examples
#' minipolars:::new_pf(iris)
#' #with namespace
#' pl$DataFrame(iris)
#' pl$DataFrame(list(some_column_name = c(1,2,3,4,5)))
DataFrame_constructor = function(data) {

  #TODO remove whenDataFrameis removed from lib
  if(inherits(data,"DataFrame")) return(data)

  #input guard
  if(!is_DataFrame_data_input(data)) {
    abort("input must inherit data.frame or be a list of vectors and/or  Series")
  }

  if (inherits(data,"data.frame")) {
    data = as.data.frame(data)
  }

  #closure to generate new names
  make_column_name_gen = function() {
    col_counter = 0
    column_name_gen = function(x) {
      col_counter <<- col_counter +1
      paste0("newcolumn_",col_counter)
    }
  }
  name_generator = make_column_name_gen()

  ##step1 handle column names
  #keys are tentative new column names
  #fetch keys from names, if missing set as NA
  keys = names(data)
  if(length(keys)==0) keys = rep(NA_character_, length(data))

  ##step2
  #if missing key use pl$Series name or generate new
  keys = mapply(data,keys, FUN = function(column,key) {

    if(is.na(key) || nchar(key)==0) {
      if(inherits(column, "Series")) {
        key = column$name()
      } else {
        key = name_generator()
      }
    }
    return(key)
  })

  ##step 3
  #check for conflicting names, to avoid silent overwrite
  if(any(duplicated(keys))) {
    abort(
      paste(
        "conflicting column names not allowed:",
        paste(unique(keys[duplicated(keys)]),collapse=", ")
      )
    )
  }

  ##step 4
  #buildDataFrameone column at the time
  self = .pr$DataFrame$new_with_capacity(length(data))
  mapply(data,keys, FUN = function(column, key) {
    if(inherits(column, "Series")) {
      column$rename_mut(key)

      unwrap(.pr$DataFrame$set_column_from_series(self,column))
    } else {
      unwrap(.pr$DataFrame$set_column_from_robj(self,column,key))
    }
    return(NULL)
  })

  return(self)
}



#' @name DataFrame_lazy
#' @rdname DataFrame
#' @examples
#' #use of lazy method
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
42


#' @name DataFrame_select
#' @rdname DataFrame
#' @aliases select
#' @param ... any expressions or strings
#' @keywords  DataFrame
DataFrame_select = function(...) {
  exprs = construct_ProtoExprArray(...)
  unwrap(.pr$DataFrame$select(self,exprs))
}

#' @name DataFrame_with_columns
#' @rdname DataFrame
#' @aliases with_columns
#' @param ... any expressions or strings
#' @keywords  DataFrame
#' @return DataFrame
DataFrame_with_columns = function(...) {
  self$lazy()$with_columns(...)$collect()
}

#' @name DataFrame_limit
#' @description take limit of n rows of query
#' @rdname DataFrame
#' @aliases limit
#' @param n positive numeric or integer number not larger than 2^32
#' @importFrom  rlang is_scalar_integerish
#'
#' @details any number will converted to u32. Negative raises error
#' @keywords  DataFrame
#' @usage select(...)
#' @return DataFrame
DataFrame_limit = function(n) {
  self$lazy()$limit(n)$collect()
}


#' filter DataFrame
#' @aliases filter
#' @description DataFrame$filter(bool_expr)
#'
#' @param bool_expr Polars expression which will evaluate to a bool pl$Series
#' @keywords DataFrame
#' @return filtered DataFrame
#' @examples pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
#' @name filter()
DataFrame_filter = function(bool_expr) {
  .pr$DataFrame$lazy(self)$filter(bool_expr)$collect()
}

#' groupby DataFrame
#' @aliases groupby
#' @description DataFrame$groupby(..., maintain_order = FALSE)
#'
#' @param ... any expression
#' @param  maintain_order bool
#' @keywords DataFrame
#' @return GroupBy (subclass of DataFrame)
#'
DataFrame_groupby = function(..., maintain_order = FALSE) {
  attr(self,"private")$groupby_input =  construct_ProtoExprArray(...)
  attr(self,"private")$maintain_order = maintain_order
  class(self) = "GroupBy"
  self
}

#' get column as Series from DataFrame
#'
#' @param name name of column to get as series
#'
#' @return a Series
#' @export
#' @keywords DataFrame
#'
#' @examples pl$DataFrame(iris)$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self,name))
}

#' column names
#' @description get column names as DataFrames
#'
#' @return char vec of column names
#' @export
#' @keywords DataFrame
#'
#' @examples pl$DataFrame(iris)$columns()
DataFrame_columns = function() {
  .pr$DataFrame$columns(self)
}



#' return polars DataFrame as R data.frame
#'
#' @param ... any args pased to as.data.frame()
#'
#' @return data.frame
#' @export
#' @keywords DataFrame
#' @usage as_data_frame()
#' @examples pl$DataFrame(iris)$as_data_frame()
DataFrame_as_data_frame = function(...) {
  as.data.frame(
    x = unwrap(.pr$DataFrame$to_list(self)),
    col.names = .pr$DataFrame$columns(self),
    ...
  )
}

#' return polars DataFrame as R lit of vectors
#' @name to_list
#' @rdname DataFrame
#'
#' @return R list of vectors
#' @export
#' @keywords DataFrame
#' @examples pl$DataFrame(iris)$as_data_frame()
DataFrame_to_list = function() {
  unwrap(.pr$DataFrame$to_list(self))
}



#' join DataFrame with other DataFrame
#'
#'
#' @param other DataFrame
#' @param on named columns as char vector of named columns, or list of expressions and/or strings.
#' @param left_on names of columns in self LazyFrame, order should match. Type, see on param.
#' @param right_on names of columns in other LazyFrame, order should match. Type, see on param.
#' @param how a string selecting one of the following methods: inner, left, outer, semi, anti, cross
#' @param suffix name to added right table
#' @param allow_parallel bool
#' @param force_parallel bool
#' @return DataFrame
#' @export
#' @keywords DataFrame
#' @examples
#'
#' print(df1 <- pl$DataFrame(list(key=1:3,payload=c('f','i',NA))))
#' print(df2 <- pl$DataFrame(list(key=c(3L,4L,5L,NA_integer_))))
#' df1$join(other = df2,on = 'key')
DataFrame_join = function(
  other,#: LazyFrame or DataFrame,
  left_on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  right_on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  on = NULL,#: str | pli.Expr | Sequence[str | pli.Expr] | None = None,
  how = c("inner", 'left', 'outer', 'semi', 'anti', 'cross'),
  suffix = "_right",
  allow_parallel = TRUE,
  force_parallel  = FALSE
) {

  .pr$DataFrame$lazy(self)$join(
    other = other$lazy(), left_on = left_on, right_on = right_on,
    on=on,how=how, suffix=suffix, allow_parallel = allow_parallel,
    force_parallel = force_parallel
  )$collect()

}
