#' @title Inner workings of the Series-class
#'
#' @name Series_class
#' @description The `Series`-class is simply two environments of respectively
#' the public and private methods/function calls to the minipolars rust side. The instanciated
#' `Series`-object is an `externalptr` to a lowlevel rust polars Series  object. The pointer address
#' is the only statefullness of the Series object on the R side. Any other state resides on the
#' rust side. The S3 method `.DollarNames.Series` exposes all public `$foobar()`-methods which are callable onto the object.
#' Most methods return another `Series`-class instance or similar which allows for method chaining.
#' This class system in lack of a better name could be called "environment classes" and is the same class
#' system extendr provides, except here there is both a public and private set of methods. For implementation
#' reasons, the private methods are external and must be called from minipolars:::.pr.$Series$methodname(), also
#' all private methods must take any self as an argument, thus they are pure functions. Having the private methods
#' as pure functions solved/simplified self-referential complications.
#'
#' @details Check out the source code in R/Series_frame.R how public methods are derived from private methods.
#' Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted
#' into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods
#' are removed and replaced by any function prefixed `Series_`.
#'
#' @keywords Series
#' @examples
#' #see all exported methods
#' ls(minipolars:::Series)
#'
#' #see all private methods (not intended for regular use)
#' ls(minipolars:::.pr$Series)
#'
#'
#' #make an object
#' s = pl$Series(1:3)
#'
#' #use a public method/property
#' s$shape
#'
#'
#' #use a private method (mutable append not allowed in public api)
#' s_copy = s
#' .pr$Series$append_mut(s, pl$Series(5:1))
#' identical(s_copy$to_r(), s$to_r()) # s_copy was modified when s was modified
Series




#' Print Series
#'
#' @param x Series
#'
#' @return selfie
#' @export
#'
print.Series = function(x) {
  cat("polars Series: ")
  x$print()
  invisible(x)
}

#' internal method print Series
#'
#' @return self
#'
#' @examples pl$Series(iris)
Series_print = function() {
  .pr$Series$print(self)
  invisible(self)
}

#' @export
#' @title auto complete $-access into object
#' @description called by the interactive R session internally
#' @keywords Series
.DollarNames.Series = function(x, pattern = "") {
  paste0(ls(minipolars:::Series, pattern = pattern ),"()")
}




#' Create new Series
#' @name Series
#' @description found in api as pl$Series named Series_constructor internally
#'
#' @param x any vector
#' @param name string
#' @rdname Series
#' @keywords Series_new
#' @return Series
#' @importFrom  rlang is_string
#' @aliases Series
#'
#' @examples {
#' pl$Series(1:4)
#' }
pl$Series = function(x, name=NULL){
  if(inherits(x,"Series")) return(x)
  if(is.double(x) || is.integer(x) || is.character(x) || is.logical(x) || is.factor(x)) {
    if(is.null(name)) name = ""
    if(!is_string(name)) abort("name must be NULL or a string")
    return(.pr$Series$new(x,name))
  }
  abort("x must be a double, interger, char, or logical vector")
}



#' @export
c.Series = \(x,...) {
  l = list(...)
  x = x$clone() #clone to retain an immutable api, append_mut is not mutable

  #append each element of i being either Series or R vector
  for(i in seq_along(l)) {
    other = l[[i]]

    #wrap in Series
    if(!inherits(other,"Series")) {
      other = pl$Series(other)
    }
    unwrap(.pr$Series$append_mut(x,other))
  }

  x
}







#' wrap as literal
#'
#' @param e an Expr(polars) or any R expression
#' @details tiny wrapper to allow skipping calling lit on rhs of binary operator
#'
#' @return Expr
#'
#' @examples pl$col("foo") < 5
wrap_s = function(x) {
  if(inherits(x,"Series")) x else pl$Series(x)
}


# ##make list of methods, which should be modified from Series as input
# # to any type which can be converted into a series, see use of Series_ops in zzz.R
# Series_ops = list()
# Series_ops_add = function(name, more_args=NULL) {
#   if(!is.null(more_args)) {
#     attr(name,"more_args") = more_args
#   }
#   Series_ops <<- c(Series_ops,list(name))
# }





#' add Series
#' @name Series_add
#' @description Series arithmetics
#' @return Series
#' @aliases add
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$add(11:13)
#' pl$Series(1:3)$add(pl$Series(11:13))
#' pl$Series(1:3)$add(1L)
#' 1L + pl$Series(1:3)
#' pl$Series(1:3) + 1L
Series_add = function(other) {
  .pr$Series$add(self, wrap_s(other))
}
#' @export
#' @rdname Series_add
"+.Series" <- function(s1,s2) wrap_s(s1)$add(s2)

#' sub Series
#' @name Series_sub
#' @description Series arithmetics
#' @return Series
#' @aliases sub
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$sub(11:13)
#' pl$Series(1:3)$sub(pl$Series(11:13))
#' pl$Series(1:3)$sub(1L)
#' 1L - pl$Series(1:3)
#' pl$Series(1:3) - 1L
Series_sub = function(other) {
  .pr$Series$sub(self, wrap_s(other))
}
#' @export
#' @rdname Series_sub
"-.Series" <- function(s1,s2) wrap_s(s1)$sub(s2)

#' div Series
#' @name Series_div
#' @description Series arithmetics
#' @return Series
#' @aliases div
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$div(11:13)
#' pl$Series(1:3)$div(pl$Series(11:13))
#' pl$Series(1:3)$div(1L)
#' 2L / pl$Series(1:3)
#' pl$Series(1:3) / 2L
Series_div = function(other) {
  .pr$Series$div(self, wrap_s(other))
}
#' @export
#' @rdname Series_div
"/.Series" <- function(s1,s2) wrap_s(s1)$div(s2)

#' mul Series
#' @name Series_mul
#' @description Series arithmetics
#' @return Series
#' @aliases mul
#' @keywords  Series
#' @examples
#' pl$Series(1:3)$mul(11:13)
#' pl$Series(1:3)$mul(pl$Series(11:13))
#' pl$Series(1:3)$mul(1L)
#' 2L * pl$Series(1:3)
#' pl$Series(1:3) * 2L
Series_mul = function(other) {
  .pr$Series$mul(self, wrap_s(other))
}
#' @export
#' @rdname Series_mul
"*.Series" <- function(s1,s2) wrap_s(s1)$mul(s2)

#' rem Series
#' @name Series_rem
#' @description Series arithmetics, remainder
#' @return Series
#' @aliases rem
#' @keywords  Series
#' @examples
#' pl$Series(1:4)$rem(2L)
#' pl$Series(1:3)$rem(pl$Series(11:13))
#' pl$Series(1:3)$rem(1L)
Series_rem = function(other) {
  .pr$Series$rem(self, wrap_s(other))
}


#TODO contribute polars pl$Series(1) == pl$Series(c(NA_integer_)) yields FALSE, != yields TRUE, and =< => yields Null
#' Compare Series
#' @name Series_compare
#' @description compare two Series
#' @param other A Series or something a Series can be created from
#' @param op the chosen operator a String either: 'equal', 'not_equal', 'lt', 'gt', 'lt_eq' or 'gt_eq'
#' @return Series
#' @aliases compare
#' @keywords  Series
#' @examples
#' pl$Series(1:5) == pl$Series(c(1:3,NA_integer_,10L))
Series_compare = function(other, op) {
  other_s = wrap_s(other)
  if(self$len() != other_s$len()) abort("Failed to compare two Series because of differing lengths.")
  .pr$Series$compare(self, wrap_s(other), op)
}
#' @export
#' @rdname Series_compare
"==.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"equal"))
#' @export
#' @rdname Series_compare
"!=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"not_equal"))
#' @export
#' @rdname Series_compare
"<.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"lt"))
#' @export
#' @rdname Series_compare
">.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"gt"))
#' @export
#' @rdname Series_compare
"<=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"lt_eq"))
#' @export
#' @rdname Series_compare
">=.Series"  <- function(s1,s2) unwrap(wrap_s(s1)$compare(s2,"gt_eq"))


#' Shape of series
#'
#' @return dimension vector of Series
#'
#' @examples identical(pl$Series(1:2)$shape, 2:1)
Series_shape = function() {
  .pr$Series$shape(self)
}
class(Series_shape) = c("property","function")

Series_udf_handler = function(f,rs) {
  fps = pl$Series(f(rs))
  fps
  # rs_ptr_adr = xptr::xptr_address(fps)
  # rs_ptr_adr
}



#modified Series bindings


#' Get r vector/list
#' @description return R list (if polars Series is list)  or vector (any other polars Series type)
#' @name Series_to_r
#' @rdname Series_to_r
#' @return R list or vector
#' @keywords Series
#' @aliases to_r
#' @details
#' Fun fact: Nested polars Series list must have same inner type, e.g. List(List(Int32))
#' Thus every leaf(non list type) will be placed on the same depth of the tree, and be the same type.
#'
#' @examples
#'
#' #make polars Series_Utf8
#' series_vec = pl$Series(letters[1:3])
#'
#' #Series_non_list
#' series_vec$to_r() #as vector because Series DataType is not list (is Utf8)
#' series_vec$to_r_list() #implicit call as.list(), convert to list
#' series_vec$to_r_vector() #implicit call unlist(), same as to_r() as already vector
#'
#'
#' #make nested Series_list of Series_list of Series_Int32
#' #using Expr syntax because currently more complete translated
#' series_list = pl$DataFrame(list(a=c(1:5,NA_integer_)))$select(
#'   pl$col("a")$list()$list()$append(
#'     (
#'       pl$col("a")$head(2)$list()$append(
#'         pl$col("a")$tail(1)$list()
#'       )
#'     )$list()
#'   )
#' )$get_column("a") # get series from DataFrame
#'
#' #Series_list
#' series_list$to_r() #as list because Series DataType is list
#' series_list$to_r_list() #implicit call as.list(), same as to_r() as already list
#' series_list$to_r_vector() #implicit call unlist(), append into a vector
Series_to_r = \() {
  unwrap(.pr$Series$to_r(self))
}
#TODO replace list example with Series only syntax

#' @rdname Series_to_r
#' @name Series_to_r_vector
#' @description return R vector (implicit unlist)
#' @return R vector
#' @aliases to_r_vector
#' @keywords Series
#' @examples  #
Series_to_r_vector = \() {
  unlist(unwrap(.pr$Series$to_r(self)))
}

#' @rdname Series_to_r
#' @name Series_to_r_list
#' @description return R list (implicit as.list)
#' @return R list
#' @aliases to_r_list
#' @keywords Series
#' @examples  #
Series_to_r_list = \() {
  as.list(unwrap(.pr$Series$to_r(self)))
}


Series_abs         = \() unwrap(.pr$Series$abs(self))
Series_value_counts =\(sorted=TRUE, multithreaded=FALSE) {
  unwrap(.pr$Series$value_counts(self, multithreaded, sorted))
}
Series_repeat = \(name, val, n, dtype=NULL) {

  # choose dtype given val
  if(is.null(dtype)) {
    dtype = pcase(
      is.integer(val),   pl$dtypes$Int32,
      is.double(val),    pl$dtypes$Float64,
      is.character(val), pl$dtypes$Utf8,
      is.logical(val),   pl$dtypes$Boolean,
      or_else = abort(paste("must specify dtype for val: ",str(val)))
    )
  }

  #any conversion of val given dtype
  val = pcase(
    # spoof int64 by setting val to float64, correct until 2^52 or so, that's how we (R)oll
    dtype == pl$dtypes$Int64, (\() as.double(val))(),
    or_else = val
  )


  .pr$Series$repeat_(name,val,n,dtype)
}



Series_apply   = \(
  fun, datatype=NULL, strict_return_type = TRUE, allow_fail_eval = FALSE
) {

  if(!is.function(fun)) abort("fun arg must be a function")

  internal_datatype = (\(){
    if(is.null(datatype)) return(datatype) #same as lambda input
    if(inherits(datatype,"DataType")) return(datatype)
    if(is.character(datatype)) return(pl$dtypes$Utf8)
    if(is.logical(datatype)) return(pl$dtypes$Boolean)
    if(is.integer(datatype)) return(pl$dtypes$Int32)
    if(is.double(datatype)) return(pl$dtypes$Float64)
    abort(paste("failed to interpret datatype arg:",datatype()))
  })()

  unwrap(.pr$Series$apply(
    self, fun, datatype, strict_return_type, allow_fail_eval
  ))

}


#' Series_is_unique
#'
#'
#' @return Series
#' @examples
#' pl$Series(c(1:2,2L))$is_unique()
#'
Series_is_unique = function() {
  unwrap(.pr$Series$is_unique(self))
}


#' Series_all
#'
#'
#' @return bool
#' @examples
#' pl$Series(1:10)$is_unique()$all()
#'
Series_all = function() {
  unwrap(.pr$Series$all(self))
}

#' Series_len
#' @description Length of this Series.
#'
#'
#' @return numeric
#' @examples
#' pl$Series(1:10)$len()
#'
Series_len = function() {
  .pr$Series$len(self)
}

#' Series_floor
#' @description Floor of this Series
#'
#' @return numeric
#' @examples
#' pl$Series(c(.5,1.999))$floor()
#'
Series_floor = function() {
  unwrap(.pr$Series$floor(self))
}

#' Series_ceil
#' @description Ceil of this Series
#'
#' @return bool
#' @examples
#' pl$Series(c(.5,1.999))$ceil()
#'
Series_ceil = function() {
  unwrap(.pr$Series$ceil(self))
}

#' Append two Series
#' @description Append Series with other Series. Imutable.
#'
#' @return numeric vector
#'
#' @examples
#' chunked_series = c(pl$Series(1:3),pl$Series(1:10))
#' chunked_series$chunk_lengths()
Series_chunk_lengths = function() {
  .pr$Series$chunk_lengths(self)
}

#' append (default immutable)
#' @description append two Series, see details for mutability
#' @param other Series to append
#' @param immutable bool should append be immutable, default TRUE as mutable operations should
#' be avoided in plain R API's.
#'
#' @details if immutable = FLASE, the Series object will not behave as immutable. This mean
#' appending to this Series will affect any variable pointing to this memory location. This will break
#' normal scoping rules of R. Polars-clones are cheap. Mutable operations are likely never needed in
#' any sense.
#'
#' @return Series
#' @examples
#'
#' #default immutable behaviour, s_imut and s_imut_copy stay the same
#' s_imut = pl$Series(1:3)
#' s_imut_copy = s_imut
#' s_new = s_imut$append(pl$Series(1:3))
#' identical(s_imut$to_r_vector(),s_imut_copy$to_r_vector())
#'
#' #pypolars-like mutable behaviour,s_mut_copy become the same as s_new
#' s_mut = pl$Series(1:3)
#' s_mut_copy = s_mut
#' s_new = s_mut$append(pl$Series(1:3),immutable= FALSE)
#' identical(s_new$to_r_vector(),s_mut_copy$to_r_vector())
Series_append = function(other, immutable = TRUE) {
  if(!isFALSE(immutable)) {
    c(self,other)
  } else {
    if(minipolars_optenv$strictly_immutable) {
      abort(paste(
        "append(other , immutable=FALSE) breaks immutability, to enable mutable features run:\n",
        "`pl$set_minipolars_options(strictly_immutable = F)`"
      ))
    }
    unwrap(.pr$Series$append_mut(self,other))
    self
  }
}

#' To list
#' @description Append Series with other Series. Imutable.
#'
#' @return numeric vector
#'
#' @examples
#' chunked_series = c(pl$Series(1:3),pl$Series(1:10))
#' chunked_series$chunk_lengths()
Series_chunk_lengths = function() {
  .pr$Series$chunk_lengths(self)
}

#' Alias
#' @description Change name of Series
#'
#' @param name a String as the new name
#' @return Series
#'
#' @examples
#' pl$Series(1:3,name = "alice")$alias("bob")
Series_alias = function(name) {
  .pr$Series$alias(self, name)
}

#' Property: Name
#' @description Get name of Series
#'
#' @return String the name
#'
#' @examples
#' pl$Series(1:3,name = "alice")$name
Series_name = method_as_property(function() {
  .pr$Series$name(self)
})

#' Reduce Boolean Series with ANY
#'
#' @return bool
#'
#' @examples
#' pl$Series(c(TRUE,FALSE,NA))$any()
Series_any = "use_extendr_wrapper"

#' Reduce Boolean Series with ALL
#'
#' @return bool
#'
#' @examples
#' pl$Series(c(TRUE,TRUE,NA))$all()
Series_all = function() {
  unwrap(.pr$Series$all(self))
}

#' idx to max value
#'
#' @return bool
#'
#' @examples
#' pl$Series(c(5,1))$arg_max()
Series_arg_max = "use_extendr_wrapper"

#' idx to min value
#'
#' @return bool
#'
#' @examples
#' pl$Series(c(5,1))$arg_min()
Series_arg_min = "use_extendr_wrapper"


#' Clone a Series
#' @name Series_clone
#' @description Rarely useful as Series are nearly 100% immutable
#' Any modification of a Series should lead to a clone anyways.
#'
#' @return Series
#' @aliases clone
#' @keywords  Series
#' @examples
#' s1 = pl$Series(1:3);
#' s2 =  s1$clone();
#' s3 = s1
#' xptr::xptr_address(s1) != xptr::xptr_address(s2)
#' xptr::xptr_address(s1) == xptr::xptr_address(s3)
#'
Series_clone = function() {
  .pr$Series$clone(self)
}

#' Cumulative sum
#' @description  Get an array with the cumulative sum computed at every element.
#' @keywords Series
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Series
#' @aliases cumsum
#' @name Series_cumsum
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#' @examples
#' pl$Series(c(1:2,NA,3,NaN,4,Inf))$cumsum()
#' pl$Series(c(1:2,NA,3,Inf,4,-Inf,5))$cumsum()
Series_cumsum = function(reverse = FALSE) {
  .pr$Series$cumsum(self, reverse)
}

#' Get data type of Series
#' @keywords Series
#' @aliases Series
#' @return DataType
#' @aliases dtype
#' @name Series_dtype
#' @examples
#' pl$Series(1:4)$dtype
#' pl$Series(c(1,2))$dtype
#' pl$Series(letters)$dtype
Series_dtype = method_as_property(function() {
  .pr$Series$dtype(self)
})

#' Get data type of Series
#' @keywords Series
#' @aliases Series
#' @return DataType
#' @aliases dtype
#' @name Series_dtype
#' @examples
#' pl$Series(1:4)$sort()$flags()
Series_flags = method_as_property(function() {
  list(
    "SORTED_ASC" =  .pr$Series$is_sorted_flag(self),
    "SORTED_DESC" =  .pr$Series$is_sorted_reverse_flag(self)

  )
})


#TODO contribute polars, Series.sort() has an * arg input which is unused
#TODO contribute polars, Series.sort() is missing nulls_last option, that Expr_sort has
#' Sort this Series
#' @keywords Series
#' @aliases Series
#' @param reverse bool reverse(descending) sort
#' @param in_place bool sort mutable in-place, breaks immutability
#' If true will throw an error unless this option has been set:
#' `pl$set_minipolars_options(strictly_immutable = F)`
#'
#' @return Series
#'
#' @examples
#' pl$Series(c(1,NA,NaN,Inf,-Inf))$sort()
Series_sort = function(reverse = FALSE, in_place = FALSE) {
  if(in_place && minipolars_optenv$strictly_immutable) {
    abort(paste(
      "in_place sort breaks immutability, to enable mutable features run:\n",
      "`pl$set_minipolars_options(strictly_immutable = F)`"
    ))
  } else {
    self = self$clone()
  }
  .pr$Series$sort_mut(self,reverse)
}


#' Series to DataFrame
#' @name Series_to_frames
#' @return Series
#' @keywords Series
#' @aliases Series
#' @format method
#'
#' @examples
#' pl$Series(1:4,"bob")$to_frame()
Series_to_frame = "use_extendr_wrapper"


#' Are Series's equal?
#'
#' @param other Series to compare with
#' @param null_equal bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by strict.
#' @param strict bool if TRUE, do not allow similar DataType comparison. Overrides null_equal.
#'
#' @description  Check if series is equal with another Series.
#' @name Series_series_equal
#' @return bool
#' @keywords Series
#' @aliases series_equal
#' @format method
#'
#' @examples
#' pl$Series(1:4,"bob")$series_equal(pl$Series(1:4))
Series_series_equal = function(other, null_equal = FALSE, strict = FALSE) {
  .pr$Series$series_equal(self, other, null_equal, strict)
}
#TODO add Series_cast and show examples of strict and null_equals



#' Rename a series
#'
#' @param name string the new name
#' @param in_place bool rename in-place, breaks immutability
#' If true will throw an error unless this option has been set:
#' `pl$set_minipolars_options(strictly_immutable = F)`
#'
#' @name Series_rename
#' @return bool
#' @keywords Series
#' @aliases series_rename
#' @format method
#'
#' @examples
#' pl$Series(1:4,"bob")$rename("alice")
Series_rename = function(name, in_place = FALSE) {
  if (identical(self$name,name)) return(self) #no change needed
  if(in_place && minipolars_optenv$strictly_immutable) {
    abort(paste(
      "in_place breaks \"objects are immutable\" which is expected in R.",
      "To enable mutable features run: `pl$set_minipolars_options(strictly_immutable = F)`"
    ))
  } else {
    self = self$clone() #clone to break mutable behavior
  }
  .pr$Series$rename_mut(self, name)
  self
}


#' duplicate and concatenate a series
#'
#' @param n number of times to repeat
#' @param rechunk bool default true, reallocate object in memory.
#' If FALSE the Series will take up less space, If TRUE calculations might be faster.
#' @name Series_rep
#' @return bool
#' @keywords Series
#' @aliases series_rep
#' @format method
#' @details  This function in not implemented in pypolars
#'
#' @examples
#' pl$Series(1:2,"bob")$rep(3)
Series_rep = function(n, rechunk = TRUE) {
  if(!is.numeric(n)) abort("n must be numeric")
  if(!is_bool(rechunk)) abort("rechunk must be a bool")
  unwrap(.pr$Series$rep(self, n, rechunk))
}

