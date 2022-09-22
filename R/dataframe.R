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




#' @title Polars DataFrame
#' @name  DataFrame
#' @rdname DataFrame
#' @param data object inheriting data.frame or list of equal length vectors and/or Series.
#' @description `DataFrame`-object is an `externalptr` to rust polars DataFrame with $methods() exposed.
#' Most methods return another `DataFrame`-class instance or similar which allows for method chaining.
#' [Commonmark web site](http://commonmark.org/help)
# #
#'
#' @examples
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
42

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



#' @name lazy
#' @rdname DataFrame
#' @examples
#' #use of lazy method
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
42


#' @name select
#' @rdname DataFrame
#' @aliases select
#' @param ... any expressions or strings
DataFrame_select = function(...) {
  exprs = construct_ProtoExprArray(...)
  unwrap(.pr$DataFrame$select(self,exprs))
}


#' @name filter
#' @rdname DataFrame
#' @aliases filter
#' @param bool_expr Polars expression which will evaluate to a bool pl$Series
DataFrame_filter = function(bool_expr) {
  .pr$DataFrame$lazy(self)$filter(bool_expr)$collect()
}


DataFrame_groupby = function(..., maintain_order = FALSE) {
  attr(self,"private")$groupby_input =  construct_ProtoExprArray(...)
  attr(self,"private")$maintain_order = maintain_order
  class(self) = "GroupBy"
  self
}

DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self,name))
}



DataFrame_as_data_frame = function(...) {
  as.data.frame(
    x = .pr$DataFrame$as_rlist_of_vectors(self),
    col.names = .pr$DataFrame$colnames(self),
    ...
  )
}
