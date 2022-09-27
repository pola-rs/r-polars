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

#' print DataFrame
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
  df = .pr$DataFrame$new_with_capacity(length(data))
  mapply(data,keys, FUN = function(column, key) {
    if(inherits(column, "Series")) {
      column$rename_mut(key)
      df$set_column_from_rseries(column)
    } else {
      df$set_column_from_robj(column,key)
    }
    return(NULL)
  })

  return(df)
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
#' @usage select(...)
DataFrame_select = function(...) {
  exprs = construct_ProtoExprArray(...)
  unwrap(.pr$DataFrame$select(self,exprs))
}

#' @name DataFrame_with_columns
#' @rdname DataFrame
#' @aliases select
#' @param ... any expressions or strings
#' @keywords  DataFrame
#' @usage select(...)
DataFrame_with_columns = function(...) {
  self$lazy()$with_columns(...)$collect()
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
    x = unwrap(.pr$DataFrame$as_rlist_of_vectors(self)),
    col.names = .pr$DataFrame$colnames(self),
    ...
  )
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
#'pl$DataFrame(
#'  list(key=1:3,payload=c("f","i",NA))
#')$join(
#'  other = pl$DataFrame(list(key=c(3L,4L,5L,NA))),
#'  on = "key"
#')
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

  self$lazy()$join(
    other = other$lazy(), left_on = left_on, right_on = right_on,
    on=on,how=how, suffix=suffix, allow_parallel = allow_parallel,
    force_parallel = force_parallel
  )$collect()

}
