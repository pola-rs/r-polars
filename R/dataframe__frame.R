#' @title Inner workings of the DataFrame-class
#'
#' @name DataFrame_class
#' @description The `DataFrame`-class is simply two environments of respectively
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
DataFrame

#' @export
.DollarNames.DataFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::DataFrame),"()")
}

#' @export
.DollarNames.VecDataFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::VecDataFrame),"()")
}




#' create new DataFrame
#' @name DataFrame
#'
#' @param data a data.frame or list of mixed vectors and Series of equal length.
#' @param make_names_unique default TRUE, any duplicated names will be prefixed a running number
#'
#' @return DataFrame
#' @importFrom xptr xptr_address
#' @importFrom rlang abort
#' @usage DataFrame(data)
#' @keywords DataFrame
#'
#' @examples
#' pl$DataFrame(iris)
#' pl$DataFrame(list(a= c(1,2,3,4,5), b=1:5, c = letters[1:5]))
pl$DataFrame = function(data, make_names_unique= TRUE) {

  if(inherits(data,"DataFrame")) return(data)

  #input guard
  if(!is_DataFrame_data_input(data)) {
    abort("input must inherit data.frame or be a list of vectors and/or  Series")
  }

  if (inherits(data,"data.frame")) {
    data = as.data.frame(data)
  }



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
        key = "new_column"
      }
    }
    return(key)
  })

  ##step 3
  #check for conflicting names, to avoid silent overwrite
  if(any(duplicated(keys))) {
    if(make_names_unique) {
      keys = make.unique(keys, sep = "_")
    } else {
      abort(
        paste(
          "conflicting column names not allowed:",
          paste(unique(keys[duplicated(keys)]),collapse=", ")
        )
      )
    }
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


#' s3 method print DataFrame
#'
#' @param x DataFrame
#'
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
#'
#' @name print()
#'
#' @return self
#'
#' @examples pl$DataFrame(iris)
DataFrame_print = function() {
  .pr$DataFrame$print(self)
  invisible(self)
}

##"Class methods"

#' Validate data input for create Dataframe with pl$DataFrame
#'
#' @param robj any R object to test
#'
#' @description The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.
#'
#' @return bool
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


#"properties"

##internal bookkeeping of methods which should behave as properties
DataFrame.property_setters = new.env(parent = emptyenv())

#' generic setter method
#' @description set value of properties of DataFrames
#'
#' @return value
#' @keywords DataFrame
#' @export
#' @examples pl$DataFrame(iris)$columns
"$<-.DataFrame" = function(self, name, value) {
  func = DataFrame.property_setters[[name]]
  if(is.null(func)) unwrap(list(err= paste("no setter method for",name)))
  if (minipolars_optenv$strictly_immutable) self = self$clone()
  func(self,value)
  self
}



#' columns, names columns
#' @description get column names as DataFrames
#' @rdname columns
#'
#' @return char vec of column names
#' @keywords DataFrame
#' @usage DataFrame_columns
#'
#' @examples
#' df = pl$DataFrame(iris)$columns
#' df$columns
#' df$columns = letters[1:5]
#' df$columns
DataFrame_columns = method_as_property(function() {
  .pr$DataFrame$columns(self)
})
DataFrame.property_setters$columns = function(self, names) unwrap(.pr$DataFrame$set_column_names_mut(self,names))





#' Shape of  DataFrame
#' @name DataFrame_shape
#' @description Get shape/dimensions of DataFrame
#'
#' @return two length numeric vector of c(nrows,ncols)
#' @aliases shape
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris)$shape
#'
DataFrame_shape = method_as_property(function() {
  .pr$DataFrame$shape(self)
})



#' Height of DataFrame
#' @name DataFrame_height
#' @description Get height(nrow) of DataFrame
#'
#' @return height as numeric
#' @aliases height nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$height
#'
DataFrame_height = method_as_property(function() {
  .pr$DataFrame$shape(self)[1]
})



#' Width of DataFrame
#' @name DataFrame_width
#' @description Get width(ncol) of DataFrame
#'
#' @return width as numeric scalar
#' @aliases width, nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$width
#'
DataFrame_width = method_as_property(function() {
    .pr$DataFrame$shape(self)[2]
})




#' DataFrame dtypes
#' @name DataFrame_dtypes
#' @description Get dtypes of columns in DataFrame.
#' Dtypes can also be found in column headers when printing the DataFrame.
#'
#' @return width as numeric scalar
#' @aliases width, nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$dtypes
#'
DataFrame_dtypes = method_as_property(function() {
  .pr$DataFrame$dtypes(self)
})


#' DataFrame dtypes
#' @name DataFrame_dtypes
#' @description Get dtypes of columns in DataFrame.
#' Dtypes can also be found in column headers when printing the DataFrame.
#'
#' @return width as numeric scalar
#' @aliases width, nrow
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$schema
#'
DataFrame_schema = method_as_property(function() {
  .pr$DataFrame$schema(self)
})



#
DataFrameCompareToOtherDF = function(self, other, op) {

  abort("not done yet")
#    """Compare a DataFrame with another DataFrame."""
  if (!identical(self$columns,other$columns)) abort("DataFrame columns do not match")
  if (!identical(self$shape, other$shape)) abort("DataFrame dimensions do not match")

  suffix = "__POLARS_CMP_OTHER"
  other_renamed = other$select(pl$all()$suffix(suffix))
  #combined = concat([self, other_renamed], how="horizontal")

  # if op == "eq":
  #   expr = [pli.col(n) == pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "neq":
  #   expr = [pli.col(n) != pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "gt":
  #   expr = [pli.col(n) > pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "lt":
  #   expr = [pli.col(n) < pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "gt_eq":
  #   expr = [pli.col(n) >= pli.col(f"{n}{suffix}") for n in self.columns]
  # elif op == "lt_eq":
  #   expr = [pli.col(n) <= pli.col(f"{n}{suffix}") for n in self.columns]
  # else:
  #   raise ValueError(f"got unexpected comparison operator: {op}")
  #
  # return combined.select(expr)

}



#' DataFrame to LazyFrame
#' @name DataFrame_lazy
#' @description Start a new lazy query from a DataFrame
#'
#' @return a LazyFrame
#' @aliases lazy
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$lazy()
#'
DataFrame_lazy = function() {
  .pr$DataFrame$lazy(self)
}

#' Clone a DataFrame
#' @name DataFrame_clone
#' @description Rarely useful as DataFrame is nearly 100% immutable
#' Any modification of a DataFrame would lead to a clone anyways.
#'
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

#' Extract columns
#' @name DataFrame_get_columns
#' @description get columns as list of series
#'
#' @return list of series
#' @aliases get_columns
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_columns()
DataFrame_get_columns = function() {
  .pr$DataFrame$get_columns(self)
}

#' Get Column
#' @name DataFrame_get_column
#' @description get one column by name as series
#'
#' @return Series
#' @aliases get_column
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self, name))
}






#' @name DataFrame_lazy
#'
#' @examples
#' #use of lazy method
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
42


#' perform select on DataFrame
#' @name DataFrame_select
#' @description  related to dplyr `mutate()`` and data.table `.()`.
#'
#' @param ... expresssions or strings defining columns to select(keep) in context the DataFrame
#'
#' @aliases select
#' @keywords  DataFrame
DataFrame_select = function(...) {
  exprs = construct_ProtoExprArray(...)
  unwrap(.pr$DataFrame$select(self,exprs))
}

#' with columns
#' @name DataFrame_with_columns
#' @aliases with_columns
#' @param ... any expressions or strings
#' @keywords  DataFrame
#' @return DataFrame
DataFrame_with_columns = function(...) {
  self$lazy()$with_columns(...)$collect()
}

#' Limit a DataFrame
#' @name DataFrame_limit
#' @description take limit of n rows of query
#'
#' @aliases limit
#' @param n positive numeric or integer number not larger than 2^32
#' @importFrom  rlang is_scalar_integerish
#'
#' @details any number will converted to u32. Negative raises error
#' @keywords  DataFrame
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




#' return polars DataFrame as R data.frame
#'
#' @param ... any args pased to as.data.frame()
#'
#' @return data.frame
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

#' as.data.frame.DataFrame S3 method
#'
#' @param x DataFrame
#' @param ... any params passed to as.data.frame
#'
#' @return data.frame
#' @export
#'
#' @examples as.data.frame(pl$DataFrame(iris[1:3,]))
as.data.frame.DataFrame = function(x, ...) {
  x$as_data_frame(...)
}

#' return polars DataFrame as R lit of vectors
#' @name to_list
#'
#'
#' @return R list of vectors
#' @export
#' @keywords DataFrame
#' @examples pl$DataFrame(iris)$to_list()
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
#' @keywords DataFrame
#' @examples
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
