#' @title Inner workings of the DataFrame-class
#'
#' @name DataFrame_class
#' @description The `DataFrame`-class is simply two environments of respectively
#' the public and private methods/function calls to the rpolars rust side. The instanciated
#' `DataFrame`-object is an `externalptr` to a lowlevel rust polars DataFrame  object. The pointer
#' address is the only statefullness of the DataFrame object on the R side. Any other state resides
#' on the rust side. The S3 method `.DollarNames.DataFrame` exposes all public `$foobar()`-methods
#' which are callable onto the object. Most methods return another `DataFrame`-class instance or
#' similar which allows for method chaining. This class system in lack of a better name could be
#' called "environment classes" and is the same class system extendr provides, except here there is
#' both a public and private set of methods. For implementation reasons, the private methods are
#' external and must be called from rpolars:::.pr.$DataFrame$methodname(), also all private methods
#' must take any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' @details Check out the source code in R/dataframe_frame.R how public methods are derived from
#' private methods. Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These
#' are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named
#' zzz to be last file sourced) the extendr-methods are removed and replaced by any function
#' prefixed `DataFrame_`.
#'
#' @keywords DataFrame
#' @examples
#' #see all exported methods
#' ls(rpolars:::DataFrame)
#'
#' #see all private methods (not intended for regular use)
#' ls(rpolars:::.pr$DataFrame)
#'
#'
#' #make an object
#' df = pl$DataFrame(iris)
#'
#' #use a public method/property
#' df$shape
#' df2 = df
#' #use a private method, which has mutability
#' result = rpolars:::.pr$DataFrame$set_column_from_robj(df,150:1,"some_ints")
#'
#' #column exists in both dataframes-objects now, as they are just pointers to the same object
#' # there are no public methods with mutability
#' df$columns
#' df2$columns
#'
#' # set_column_from_robj-method is fallible and returned a result which could be ok or an err.
#' # No public method or function will ever return a result.
#' # The `result` is very close to the same as output from functions decorated with purrr::safely.
#' # To use results on R side, these must be unwrapped first such that
#' # potentially errors can be thrown. unwrap(result) is a way to
#' # bridge rust not throwing errors with R. Extendr default behaviour is to use panic!(s) which
#' # would case some unneccesary confusing and  some very verbose error messages on the inner
#' # workings of rust. unwrap(result) #in this case no error, just a NULL because this mutable method
#' # do not return any ok-value
#'
#' #try unwrapping an error from polars due to unmatching column lengths
#' err_result = rpolars:::.pr$DataFrame$set_column_from_robj(df,1:10000,"wrong_length")
#' tryCatch(unwrap(err_result,call=NULL),error=\(e) cat(as.character(e)))
DataFrame





#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x DataFrame
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.DataFrame = function(x, pattern = "") {
  get_method_usages(DataFrame,pattern = pattern)
}


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x VecDataFrame
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.VecDataFrame = function(x, pattern = "") {
  get_method_usages(VecDataFrame,pattern = pattern)
}




#' Create new DataFrame
#' @name DataFrame
#'
#' @param ...
#'  - one data.frame or something that inherits data.frame or DataFrame
#'  - one list of mixed vectors and Series of equal length
#'  - mixed vectors and/or Series of equal length
#'
#' Columns will be named as of named arguments or alternatively by names of Series or given a
#' placeholder name.
#'
#' @param make_names_unique default TRUE, any duplicated names will be prefixed a running number
#'
#' @return DataFrame
#' @keywords DataFrame_new
#'
#' @examples
#' pl$DataFrame(
#'   a = list(c(1,2,3,4,5)), #NB if first column should be a list, wrap it in a Series
#'   b = 1:5,
#'   c = letters[1:5],
#'   d = list(1:1,1:2,1:3,1:4,1:5)
#' ) #directly from vectors
#'
#' #from a list of vectors or data.frame
#' pl$DataFrame(list(
#'   a= c(1,2,3,4,5),
#'   b=1:5,
#'   c = letters[1:5],
#'   d = list(1L,1:2,1:3,1:4,1:5)
#' ))
#'
pl$DataFrame = function(..., make_names_unique= TRUE) {

  largs = list2(...)

  #no args crete empty DataFrame
  if(length(largs)==0L) return(.pr$DataFrame$new())

  #pass through if already a DataFrame
  if(inherits(largs[[1L]],"DataFrame")) return(largs[[1L]])

  #if input is one list of expression unpack this one
  Data = if(length(largs)==1L && is.list(largs[[1]])) {
    largs = largs[[1L]]
  }

  #input guard
  if(!is_DataFrame_data_input(largs)) {
    stopf("input must inherit data.frame or be a list of vectors and/or  Series")
  }

  if (inherits(largs,"data.frame")) {
    largs = as.data.frame(largs)
  }


  ##step 00 get max length to allow cycle 1-length inputs
  largs_lengths = sapply(largs,length)
  largs_lengths_max = if(is.integer(largs_lengths)) max(largs_lengths) else NULL

  ##step1 handle column names
  #keys are tentative new column names
  #fetch keys from names, if missing set as NA
  keys = names(largs)
  if(length(keys)==0) keys = rep(NA_character_, length(largs))

  ##step2
  #if missing key use pl$Series name or generate new
  keys = mapply(largs,keys, FUN = function(column,key) {

    if(is.na(key) || nchar(key)==0) {
      if(inherits(column, "Series")) {
        key = column$name
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
      stopf(
        paste(
          "conflicting column names not allowed:",
          paste(unique(keys[duplicated(keys)]),collapse=", ")
        )
      )
    }
  }

  ##step 4
  #buildDataFrame one column at the time
  self = .pr$DataFrame$new_with_capacity(length(largs))
  mapply(largs,keys, FUN = function(column, key) {
    if(inherits(column, "Series")) {
      .pr$Series$rename_mut(column, key)

      unwrap(.pr$DataFrame$set_column_from_series(self,column))
    } else {
      if(length(column)==1L && isTRUE(largs_lengths_max > 1L)) column = rep(column,largs_lengths_max)
      column = convert_to_fewer_types(column) #type conversions on R side
      unwrap(.pr$DataFrame$set_column_from_robj(self,column,key))
    }
    return(NULL)
  })

  return(self)
}


#' s3 method print DataFrame
#'
#' @param x DataFrame
#' @param ... not used
#'
#' @name print()
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
print.DataFrame = function(x, ...) {
  cat("polars DataFrame: ")
  x$print()
  invisible(x)
}

#' internal method print DataFrame
#'
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
#' @param x any R object to test if suitable as input to DataFrame
#'
#' @description The Dataframe constructors accepts data.frame inheritors or list of vectors and/or Series.
#'
#' @return bool
#'
#' @examples rpolars:::is_DataFrame_data_input(iris)
#' rpolars:::is_DataFrame_data_input(list(1:5,pl$Series(1:5),letters[1:5]))
is_DataFrame_data_input = function(x) {
  inherits(x,"data.frame") ||
    is.list(x) ||
    all(sapply(x,function(x) is.vector(x) || inherits(x,"Series")))
}


#"properties"

##internal bookkeeping of methods which should behave as properties
DataFrame.property_setters = new.env(parent = emptyenv())

#' generic setter method
#'
#' @param self DataFrame
#' @param name name method/property to set
#' @param value value to insert
#'
#' @description set value of properties of DataFrames
#'
#' @return value
#' @keywords DataFrame
#' @details settable rpolars object properties may appear to be R objects, but they are not.
#' See `[[method_name]]` example
#'
#' @export
#' @examples
#' #For internal use
#' #is only activated for following methods of DataFrame
#' ls(rpolars:::DataFrame.property_setters)
#'
#' #specific use case for one object property 'columns' (names)
#' df = pl$DataFrame(iris)
#'
#' #get values
#' df$columns
#'
#' #set + get values
#' df$columns = letters[1:5] #<- is fine too
#' df$columns
#'
#' # Rstudio is not using the standard R code completion tool
#' # and it will backtick any special characters. It is possible
#' # to completely customize the R / Rstudio code completion except
#' # it will trigger Rstudio to backtick any completion! Also R does
#' # not support package isolated customization.
#'
#'
#' #Concrete example if tabbing on 'df$' the raw R suggestion is df$columns<-
#' #however Rstudio backticks it into df$`columns<-`
#' #to make life simple, this is valid rpolars syntax also, and can be used in fast scripting
#' df$`columns<-` = letters[5:1]
#'
#' #for stable code prefer e.g.  df$columns = letters[5:1]
#'
#' #to see inside code of a property use the [[]] syntax instead
#' df[["columns"]] # to see property code, .pr is the internal rpolars api into rust polars
#' rpolars:::DataFrame.property_setters$columns #and even more obscure to see setter code
#'
#'
"$<-.DataFrame" = function(self, name, value) {

  name = sub("<-$","",name)

  #stop if method is not a setter
  if(!inherits(self[[name]],"setter")) {
    pstop(err= paste("no setter method for",name))
  }

  # if(is.null(func)) pstop(err= paste("no setter method for",name)))
  if (rpolars_optenv$strictly_immutable) self = self$clone()
  func = DataFrame.property_setters[[name]]
  func(self,value)
  self
}



#' get/set columns (the names columns)
#' @description get/set column names of DataFrame object
#' @name DataFrame_columns
#' @rdname DataFrame_columns
#'
#' @return char vec of column names
#' @keywords DataFrame
#'
#' @examples
#' df = pl$DataFrame(iris)
#'
#' #get values
#' df$columns
#'
#' #set + get values
#' df$columns = letters[1:5] #<- is fine too
#' df$columns
DataFrame_columns = method_as_property(function() {
  .pr$DataFrame$columns(self)
},setter = TRUE)
#define setter function
DataFrame.property_setters$columns =
  function(self, names) unwrap(.pr$DataFrame$set_column_names_mut(self,names))





#' Shape of  DataFrame
#' @name DataFrame_shape
#' @description Get shape/dimensions of DataFrame
#'
#' @return two length numeric vector of c(nrows,ncols)
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
  .pr$DataFrame$shape(self)[1L]
})



#' Width of DataFrame
#' @name DataFrame_width
#' @description Get width(ncol) of DataFrame
#'
#' @return width as numeric scalar
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$width
#'
DataFrame_width = method_as_property(function() {
    .pr$DataFrame$shape(self)[2L]
})




#' DataFrame dtypes
#' @name DataFrame_dtypes
#' @description Get dtypes of columns in DataFrame.
#' Dtypes can also be found in column headers when printing the DataFrame.
#'
#' @return width as numeric scalar
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
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(iris)$schema
#'
DataFrame_schema = method_as_property(function() {
  .pr$DataFrame$schema(self)
})



#
DataFrameCompareToOtherDF = function(self, other, op) {

  stopf("not done yet")
#    """Compare a DataFrame with another DataFrame."""
  if (!identical(self$columns,other$columns)) stopf("DataFrame columns do not match")
  if (!identical(self$shape, other$shape)) stopf("DataFrame dimensions do not match")

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



#' New LazyFrame from DataFrame_object$lazy()
#' @name DataFrame_lazy
#' @description Start a new lazy query from a DataFrame
#'
#' @return a LazyFrame
#' @aliases lazy
#' @keywords  DataFrame LazyFrame_new
#' @examples
#' pl$DataFrame(iris)$lazy()
#'
DataFrame_lazy = "use_extendr_wrapper"

#' Clone a DataFrame
#' @name DataFrame_clone
#' @description Rarely useful as DataFrame is nearly 100% immutable
#' Any modification of a DataFrame would lead to a clone anyways.
#'
#' @return DataFrame
#' @aliases DataFrame_clone
#' @keywords  DataFrame
#' @examples
#' df1 = pl$DataFrame(iris);
#' df2 =  df1$clone();
#' df3 = df1
#' pl$mem_address(df1) != pl$mem_address(df2)
#' pl$mem_address(df1) == pl$mem_address(df3)
#'
DataFrame_clone = function() {
  .pr$DataFrame$clone_see_me_macro(self)
}

#' Get columns (as Series)
#' @name DataFrame_get_columns
#' @description get columns as list of series
#'
#' @return list of series
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_columns()
DataFrame_get_columns = "use_extendr_wrapper"

#' Get Column (as one Series)
#' @name DataFrame_get_column
#' @description get one column by name as series
#'
#' @param name name of column to extract as Series
#'
#' @return Series
#' @aliases DataFrame_get_column
#' @keywords  DataFrame
#' @examples
#' df = pl$DataFrame(iris[1,])
#' df$get_column("Species")
DataFrame_get_column = function(name) {
  unwrap(.pr$DataFrame$get_column(self, name))
}

#' Get Series by idx, if there
#'
#' @param idx numeric default 0, zero-index of what column to return as Series
#'
#' @name DataFrame_to_series
#' @description get one column by idx as series from DataFrame.
#' Unlike get_column this method will not fail if no series found at idx but
#' return a NULL, idx is zero idx.
#'
#' @return Series or NULL
#' @keywords  DataFrame
#' @examples
#' pl$DataFrame(a=1:4)$to_series()
DataFrame_to_series = function(idx=0) {
  if(!is.numeric(idx) || isTRUE(idx<0)) {
    pstop(err = "idx must be non-negative numeric")
  }
  .pr$DataFrame$select_at_idx(self, idx)$ok
}






#' @name DataFrame_lazy
#'
#' @examples
#' #use of lazy method
#' pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
42


#' perform select on DataFrame
#' @name DataFrame_select
#' @description  related to dplyr `mutate()` However discards unmentioned columns as data.table `.()`.
#'
#' @param ... expresssions or strings defining columns to select(keep) in context the DataFrame
#'
#' @aliases select
#' @keywords  DataFrame
#' #' pl$DataFrame(iris)$select(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length")+2)$alias("add_2_SL")
#' )
DataFrame_select = function(...) {
  args = list2(...)
  exprs = do.call(construct_ProtoExprArray,args)
  df = unwrap(.pr$DataFrame$select(self,exprs))

  expr_names = names(args)
  if(!is.null(expr_names)) {
    old_names = df$columns
    new_names = old_names
    has_expr_name = nchar(expr_names)>=1L
    new_names[has_expr_name] = expr_names[has_expr_name]
    df$columns = new_names
  }
  df
}

#' modify/append column(s)
#' @description add or modify columns with expressions
#' @name DataFrame_with_columns
#' @aliases with_columns
#' @param ... any expressions or string column name, or same wrapped in a list
#' @keywords  DataFrame
#' @return DataFrame
#' @details   Like dplyr `mutate()` as it keeps unmentioned columns unlike $select().
#' @examples
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs()$alias("abs_SL"),
#'   (pl$col("Sepal.Length")+2)$alias("add_2_SL")
#' )
#'
#' #rename columns by naming expression is concidered experimental
#' pl$set_rpolars_options(named_exprs = TRUE) #unlock
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width")+2)
#' )
DataFrame_with_columns = function(...) {
  largs = list2(...)

  #unpack a single list
  if(length(largs)==1 && is.list(largs[[1]])) {
    largs = largs[[1]]
  }

  do.call(self$lazy()$with_columns,largs)$collect()
}

#' modify/append one column
#' @rdname DataFrame_with_columns
#' @aliases with_column
#' @param expr a single expression or string
#' @keywords  DataFrame
#' @return DataFrame
#' @details with_column is derived from with_columns but takes only one expression argument
DataFrame_with_column = function(expr) {
  self$with_columns(expr)
}



#' Limit a DataFrame
#' @name DataFrame_limit
#' @description take limit of n rows of query
#' @param n positive numeric or integer number not larger than 2^32
#'
#' @details any number will converted to u32. Negative raises error
#' @keywords  DataFrame
#' @return DataFrame
DataFrame_limit = function(n) {
  self$lazy()$limit(n)$collect()
}


#' filter DataFrame
#' @aliases DataFrame_filter
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
  self_copy = self$clone()
  attr(self_copy,"private")$groupby_input =  construct_ProtoExprArray(...)
  attr(self_copy,"private")$maintain_order = maintain_order
  class(self_copy) = "GroupBy"
  self_copy
}





#' return polars DataFrame as R data.frame
#'
#' @param ... any args pased to as.data.frame()
#'
#' @return data.frame
#' @keywords DataFrame
#' @examples
#' df = pl$DataFrame(iris[1:3,])
#' df$as_data_frame()
DataFrame_as_data_frame = function(...) {

  #do not unnest structs and mark with I to also preserve categoricals as is
  l = lapply(self$to_list(unnest_structs=FALSE), I)

  #similar to as.data.frame, but avoid checks, whcih would edit structs
  df = data.frame(seq_along(l[[1L]]))
  for(i in seq_along(l)) df[[i]] = l[[i]]
  names(df) = .pr$DataFrame$columns(self)

  #remove AsIs (I) subclass from columns
  df[] = lapply(df,unAsIs)
  df
}

# #' @rdname DataFrame_as_data_frame
# #' @description to_data_frame is an alias
# #' @keywords DataFrame
# DataFrame_to_data_frame = DataFrame_as_data_frame

#' @rdname DataFrame_as_data_frame
#' @param x DataFrame
#' @param ... any params passed to as.data.frame
#'
#' @return data.frame
#' @export
as.data.frame.DataFrame = function(x, ...) {
  x$as_data_frame(...)
}

#' return polars DataFrame as R lit of vectors
#'
#' @param unnest_structs bool default true, as calling $unnest() on any struct column
#'
#' @name to_list
#'
#' @details
#' This implementation for simplicity reasons relies on unnesting all structs before
#' exporting to R. unnest_structs = FALSE, the previous struct columns will be re-
#' nested. A struct in a R is a lists of lists, where each row is a list of values.
#' Such a structure is not very typical or efficient in R.
#'
#' @return R list of vectors
#' @keywords DataFrame
#' @examples
#' pl$DataFrame(iris)$to_list()
DataFrame_to_list = function(unnest_structs = TRUE) {
  if(unnest_structs) {
    unwrap(.pr$DataFrame$to_list(self))
  } else {
    restruct_list(unwrap(.pr$DataFrame$to_list_tag_structs(self)))
  }
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

#' to_struct and unnest again
#' @name DataFrame_to_Struct_unnest
#' @param name name of new Series
#' @return @to_struct() returns a Series
#' @aliases to_struct
#' @keywords DataFrame
#' @examples
#' #round-trip conversion from DataFrame with two columns
#' df = pl$DataFrame(a=1:5,b=c("one","two","three","four","five"))
#' s = df$to_struct()
#' s
#' s$to_r() # to r list
#' df_s = s$to_frame() #place series in a new DataFrame
#' df_s$unnest() # back to starting df
DataFrame_to_struct = function(name = "") {
  .pr$DataFrame$to_struct(self, name)
}


##TODO contribute polars add rpolars defaults for to_struct and unnest
#' Unnest a DataFrame struct columns.
#' @rdname DataFrame_to_Struct_unnest
#' @param names names of struct columns to unnest, default NULL unnest any struct column
#' @return $unnest() returns a DataFrame with all column including any that has been unnested
DataFrame_unnest = function(names = NULL) {
  unwrap(.pr$DataFrame$unnest(self, names))
}



