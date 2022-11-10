#' @title Polars Expr
#'
#' @description Polars pl$Expr
#' @rdname Expr
#' @name Expr
#' @keywords Expr
#'
#' @aliases Expr
#'
#' @examples
#' 2+2
#' #Expr has the following methods/constructors
#' ls(minipolars:::Expr)
#'
#' pl$col("this_column")$sum()$over("that_column")
42


#' Print expr
#'
#' @param x Expr
#' @keywords Expr
#'
#' @return self
#' @export
#'
#' @examples
#' pl$col("some_column")$sum()$over("some_other_column")
print.Expr = function(x) {
  cat("polars Expr: ")
  x$print()
  invisible(x)
}

#' internal method print Expr
#' @name Expr$print()
#' @keywords Expr
#' @examples pl$DataFrame(iris)
Expr_print = function() {
  .pr$Expr$print(self)
  invisible(self)
}

#' @export
#' @title auto complete $-access into object
#' @description called by the interactive R session internally
#' @keywords Expr
.DollarNames.Expr = function(x, pattern = "") {
  paste0(ls(minipolars:::Expr, pattern = pattern ),"()")
}

#' wrap as literal
#' @param e an Expr(polars) or any R expression
#' @details tiny wrapper to allow skipping calling lit on rhs of binary operator
#' @keywords Expr
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e = function(e, str_to_lit = TRUE) {
  if(inherits(e,"Expr")) return(e)
  if(str_to_lit || is.numeric(e)) {
    pl$lit(e)
  } else {
    pl$col(e)
  }
}




#' Add
#' @description Addition
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #three syntaxes same result
#' pl$lit(5) + 10
#' pl$lit(5) + pl$lit(10)
#' pl$lit(5)$add(pl$lit(10))
Expr_add = "use_extendr_wrapper"
#' @export
#' @rdname Expr_add
"+.Expr" <- function(e1,e2) e1$add(wrap_e(e2))

#' Div
#' @description Divide
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #three syntaxes same result
#' pl$lit(5) / 10
#' pl$lit(5) / pl$lit(10)
#' pl$lit(5)$div(pl$lit(10))
Expr_div = "use_extendr_wrapper"
#' @export
#' @rdname Expr_div
"/.Expr" <- function(e1,e2) e1$div(wrap_e(e2))

#' Sub
#' @description Substract
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #three syntaxes same result
#' pl$lit(5) - 10
#' pl$lit(5) - pl$lit(10)
#' pl$lit(5)$sub(pl$lit(10))
Expr_sub = "use_extendr_wrapper"
#' @export
#' @rdname Expr_sub
"-.Expr" <- function(e1,e2) e1$sub(wrap_e(e2))

#' Mul *
#' @description Multiplication
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #three syntaxes same result
#' pl$lit(5) * 10
#' pl$lit(5) * pl$lit(10)
#' pl$lit(5)$mul(pl$lit(10))
Expr_mul = "use_extendr_wrapper"
#' @export
#' @rdname Expr_mul
"*.Expr" <- function(e1,e2) e1$mul(wrap_e(e2))


#' Not !
#' @description not method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #two syntaxes same result
#' pl$lit(TRUE)$is_not()
#' !pl$lit(TRUE)
Expr_is_not = "use_extendr_wrapper"
#' @export
#' @rdname Expr_is_not
"!.Expr" <- function(e1,e2) e1$is_not()

#' Less Than <
#' @description lt method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(5) < 10
#' pl$lit(5) < pl$lit(10)
#' pl$lit(5)$lt(pl$lit(10))
Expr_lt = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_lt
"<.Expr" <- function(e1,e2) e1$lt(wrap_e(e2))

#' GreaterThan <
#' @description gt method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) > 1
#' pl$lit(2) > pl$lit(1)
#' pl$lit(2)$gt(pl$lit(1))
Expr_gt = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_gt
">.Expr" <- function(e1,e2) e1$gt(wrap_e(e2))

#' Equal ==
#' @description eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) == 2
#' pl$lit(2) ==  pl$lit(2)
#' pl$lit(2)$eq(pl$lit(2))
Expr_eq = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_eq
"==.Expr" <- function(e1,e2) e1$eq(wrap_e(e2))


#' Not Equal !=
#' @description neq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(1) != 2
#' pl$lit(1) !=  pl$lit(2)
#' pl$lit(1)$neq(pl$lit(2))
Expr_neq = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_neq
"!=.Expr" <- function(e1,e2) e1$neq(wrap_e(e2))

#' Less Than Or Equal <=
#' @description lt_eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) <= 2
#' pl$lit(2) <=  pl$lit(2)
#' pl$lit(2)$lt_eq(pl$lit(2))
Expr_lt_eq = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_lt_eq
"<=.Expr" <- function(e1,e2) e1$lt_eq(wrap_e(e2))


#' Greater Than Or Equal <=
#' @description gt_eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) >= 2
#' pl$lit(2) >=  pl$lit(2)
#' pl$lit(2)$gt_eq(pl$lit(2))
Expr_gt_eq = "use_extendr_wrapper"
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @rdname Expr_gt_eq
">=.Expr" <- function(e1,e2) e1$gt_eq(wrap_e(e2))



#' aggregate groups
#' @keywords Expr
#' @description
#' Get the group indexes of the group by operation.
#' Should be used in aggregation context only.
#' @return Exprs
#' @export
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("one","one","one","two","two","two"),
#'   value =  c(94, 95, 96, 97, 97, 99)
#' ))
#' df$groupby("group", maintain_order=TRUE)$agg(pl$col("value")$agg_groups())
Expr_agg_groups = "use_extendr_wrapper"


#' Rename Expr output
#' @keywords Expr
#' @description
#' Rename the output of an expression.
#' @param name string new name of output
#' @return Expr
#' @examples pl$col("bob")$alias("alice")
Expr_alias = "use_extendr_wrapper"

#' All (is true)
#' @keywords Expr
#' @description
#'Check if all boolean values in a Boolean column are `TRUE`.
# This method is an expression - not to be confused with
#:`pl$all` which is a function to select all columns.
#'
#' @return Boolean literal
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$all())
Expr_all = "use_extendr_wrapper"

#' Any (is true)
#' @keywords Expr
#' @description
#' Check if any boolean value in a Boolean column is `TRUE`.
#' @return Boolean literal
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$any())
Expr_any = "use_extendr_wrapper"




#' Count values (len is a alias)
#' @keywords Expr
#' @name Expr_count
#' @description
#' Count the number of values in this expression.
#' Similar to R length()
#' @return Expr
#' @aliases count
#' @examples
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$count())
Expr_count = "use_extendr_wrapper"

#' Count values (len is a alias)
#' @keywords Expr
#' @rdname Expr_count
#' @return Expr
#' @aliases count len
#' @examples
#' #same as
#' pl$DataFrame(list(all=c(T,T),any=c(T,F),none=c(F,F)))$select(pl$all()$len())
Expr_len = "use_extendr_wrapper"



#' Drop null(s)
#' @keywords Expr
#' @description
#' Drop null values.
#' Similar to R syntax x[!(is.na(x) & !is.nan(x))]
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#'  pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nulls())
Expr_drop_nulls = "use_extendr_wrapper"

#' Drop NaN(s)
#' @keywords Expr
#' @description
#' Drop floating point NaN values.
#' Similar to R syntax x[!is.nan(x)]
#' @details
#'
#'  Note that NaN values are not null values! (null corrosponds to R NA, not R NULL)
#'  To drop null values, use method `drop_nulls`.
#'
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#'
#' @return Expr
#' @examples
#'  pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nans())
Expr_drop_nans = "use_extendr_wrapper"





#' is_null
#' @keywords Expr
#' @description
#' Returns a boolean Series indicating which values are null.
#' Similar to R syntax is.na(x)
#' null polars about the same as R NA
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_null())
Expr_is_null = "use_extendr_wrapper"

#' is_not_null
#' @keywords Expr
#' @description
#' Returns a boolean Series indicating which values are not null.
#' Similar to R syntax !is.na(x)
#' null polars about the same as R NA
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_not_null())
Expr_is_not_null = "use_extendr_wrapper"







#' construct proto Expr array from args
#'
#' @param ...  any Expr or string
#'
#' @importFrom rlang is_string list2
#'
#' @keywords Expr
#'
#' @return ProtoExprArray object
#'
#' @examples minipolars:::construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
construct_ProtoExprArray = function(...) {


  pra = minipolars:::ProtoExprArray$new()
  args = rlang::list2(...)
  arg_names = names(args)


  # if args not named load in Expr and string
  if(is.null(arg_names)) {
    for (i in args) {
      if (is_string(i)) {
        pra$push_back_str(i) #rust method
        next
      }
      if (inherits(i,"Expr")) {
        pra$push_back_rexpr(i) #rust method
        next
      }
      abort(paste("cannot handle object:", capture.output(str(i))))
    }

  #if args named, convert string to col and alias any column by name if a name
  } else {

    if(!minipolars:::minipolars_optenv$named_exprs) {
      abort("not allowed naming expressions, use `pl$set_minipolars_options(named_exprs = TRUE)` to enable column naming by expression")
    }

    for (i in seq_along(args)) {
      arg = args[[i]]
      name = arg_names[i]
      if (is_string(arg)) {
        arg = pl$col(arg)
      }
      if (inherits(arg,"Expr")) {
        if(nchar(name)>=1L) {
          arg = arg$alias(name)
        }
        pra$push_back_rexpr(arg) #rust method
        next
      }
      abort(paste("cannot handle object:", capture.output(str(arg))))
    }
  }


  pra
}





##TODO allow list to be formed from recursive R lists
##TODO Contribute polars, seems polars now prefer word f or function in map/apply/rolling/apply
# over lambda. However lambda is still in examples.
##TODO Better explain aggregate list
#' Expr_map
#' @keywords Expr
#'
#' @param f a function mapping a series
#' @param output_type NULL or one of pl$dtypes$..., the output datatype, NULL is the same as input.
#' @param agg_list Aggregate list. Map from vector to group in groupby context. Likely not so useful.
#'
#' @rdname Expr_map
#' @return Expr
#' @aliases Expr_map
#' @details user function return should be a series or any Robj convertable into a Series. In PyPolars likely return must be Series.
#' User functions do fully support `browser()`, helpful to investigate.
#' @name Expr_map
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) {
#'   paste("cheese",as.character(x$to_r_vector()))
#' }, pl$dtypes$Utf8))
Expr_map = function(f, output_type = NULL, agg_list = FALSE) {
  .pr$Expr$map(self, f, output_type, agg_list)
}



#' Expr_apply
#' @keywords Expr
#'
#' @description
#'Apply a custom/user-defined function (UDF) in a GroupBy or Projection context.
#'Depending on the context it has the following behavior:
#' -Selection
#' @param f r function see details depending on context
#' @param return_type NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
#'
#' @details
#'
#' Apply a user function in a groupby or projection(select) context
#'
#'
#' Depending on context the following behaviour:
#'
#' * Projection/Selection:
#'  Expects an `f` to operate on R scalar values.
#'  Polars will convert each element into an R value and pass it to the function
#'  The output of the user function will be converted back into a polars type.
#'  Return type must match. See param return type.
#'  Apply in selection context should be avoided as a `lapply()` has half the overhead.
#'
#' * Groupby
#'   Expects a user function `f` to take a `Series` and return a `Series` or Robj convertable to `Series`, eg. R vector.
#'   GroupBy context much faster if number groups are quite fewer than number of rows, as the iteration
#'   is only across the groups.
#'   The r user function could e.g. do vectorized operations and stay quite performant.
#'   use `s$to_r()` to convert input Series to an r vector or list. use `s$to_r_vector` and
#'   `s$to_r_list()` to force conversion to vector or list.
#'
#'
#'  Implementing logic using an R function is almost always _significantly_
#'   slower and more memory intensive than implementing the same logic using
#'   the native expression API because:
#'     - The native expression engine runs in Rust; functions run in R.
#'     - Use of R functions forces the DataFrame to be materialized in memory.
#'     - Polars-native expressions can be parallelised (R functions cannot*).
#'     - Polars-native expressions can be logically optimised (R functions cannot).
#'   Wherever possible you should strongly prefer the native expression API
#'   to achieve the best performance.
#'
#' @return Expr
#' @aliases Expr_apply
#' @examples
#' #apply over groups - normal usage
#' # s is a series of all values for one column within group, here Species
#' e_all =pl$all() #perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")
#' e_sum  = e_all$apply(\(s)  sum(s$to_r()))$suffix("_sum")
#' e_head = e_all$apply(\(s) head(s$to_r(),2))$suffix("_head")
#' pl$DataFrame(iris)$groupby("Species")$agg(e_sum,e_head)
#'
#'
#' #apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time on a 2015 MacBook Pro)
#' #x is an R scalar
#' e_all =pl$col(pl$dtypes$Float64) #perform on all Float64 columns, using pl$all requires user function can handle any input type
#' e_add10  = e_all$apply(\(x)  {x+10})$suffix("_sum")
#' #quite silly index into alphabet(letters) by ceil of float value
#' #must set return_type as not the same as input
#' e_letter = e_all$apply(\(x) letters[ceiling(x)], return_type = pl$dtypes$Utf8)$suffix("_letter")
#' pl$DataFrame(iris)$select(e_add10,e_letter)
#'
#'
#' ##timing "slow" apply in select /with_columns context, this makes apply
#' n = 1000000L
#' set.seed(1)
#' df = pl$DataFrame(list(
#'   a = 1:n,
#'   b = sample(letters,n,replace=TRUE)
#'  ))
#'
#' print("apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro")
#' system.time({
#'   rdf = df$with_columns(
#'     pl$col("a")$apply(\(x) {
#'      x*2L
#'    })$alias("bob")
#'  )
#' })
#'
#' print("R lapply 1 million values take ~1sec on 2015 MacBook Pro")
#' system.time({
#'  lapply(df$get_column("a")$to_r(),\(x) x*2L )
#' })
#' print("using polars syntax takes ~1ms")
#' system.time({
#'  (df$get_column("a") * 2L)
#' })
#'
#'
#' print("using R vector syntax takes ~4ms")
#' r_vec = df$get_column("a")$to_r()
#' system.time({
#'  r_vec * 2L
#' })
Expr_apply = function(f, return_type = NULL, strict_return_type = TRUE, allow_fail_eval = FALSE) {

  #use series apply
  wrap_f = function(s) {
    s$apply(f, return_type, strict_return_type, allow_fail_eval)
  }

  #return epression from the functions above, activate agg_list (grouped mapping)
  .pr$Expr$map(self, lambda = wrap_f, output_type = return_type, agg_list = TRUE)
}


#' polars literal
#' @keywords Expr
#'
#' @param x an R Scalar, or R vector (via Series) into Expr
#' @rdname Expr
#' @return Expr, literal of that value
#' @aliases lit
#' @name Expr_lit
#' @examples
#' #scalars to literal, explit `pl$lit(42)` implicit `+ 2`
#' pl$col("some_column") / pl$lit(42) + 2
#'
#' #vector to literal explicitly via Series and back again
#' pl$DataFrame(list())$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]] #R vector to expression and back again
#'
#' #vectors to literal implicitly
#' (pl$lit(2) + 1:4 ) / 4:1
Expr_lit = function(x) {
  if (inherits(x,"Expr")) return(x)  # already Expr, pass through
  if (length(x) > 1L) x = wrap_s(x) #wrap first as Series if not a scalar
  unwrap(.pr$Expr$lit(x)) # create literal Expr
}

#' polars suffix
#' @keywords Expr
#'
#' @param suffix string suffix to be added to a name
#' @rdname Expr
#' @return Expr
#' @aliases suffix
#' @name Expr_suffix
#' @examples pl$col("some")$suffix("_column")
Expr_suffix = function(suffix) {
  .pr$Expr$suffix(self, suffix)
}

#' polars prefix
#' @keywords Expr
#'
#' @param prefix string suffix to be added to a name
#' @rdname Expr
#' @return Expr
#' @aliases prefix
#' @name Expr_prefix
#' @examples pl$col("some")$suffix("_column")
Expr_prefix = function(prefix) {
  .pr$Expr$prefix(self, prefix)
}

#' polars reverse
#' @keywords Expr
#' @rdname Expr
#' @return Expr
#' @aliases reverse
#' @name Expr_reverse
#' @examples pl$DataFrame(list(a=1:5))$select(pl$col("a")$reverse())
Expr_reverse = function() {
  .pr$Expr$reverse(self)
}



#' And
#' @name Expr_and
#' @description combine to boolean exprresions with AND
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @examples
#' pl$lit(TRUE) & TRUE
#' pl$lit(TRUE)$and(pl$lit(TRUE))
Expr_and = "use_extendr_wrapper"
#' @export
"&.Expr" <- function(e1,e2) e1$and(wrap_e(e2))


#' Or
#' @name Expr_or
#' @description combine to boolean expresions with OR
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @examples
#' pl$lit(TRUE) | FALSE
#' pl$lit(TRUE)$or(pl$lit(TRUE))
Expr_or = "use_extendr_wrapper"
#' @export
"|.Expr" <- function(e1,e2) e1$or(wrap_e(e2))


#' Xor
#' @name Expr_xor
#' @description combine to boolean expresions with XOR
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @examples
#' pl$lit(TRUE)$xor(pl$lit(FALSE))
Expr_xor = "use_extendr_wrapper"



#' To physical representation
#' @description expression request underlying physical base representation
#' @keywords Expr
#' @return Expr
#' @aliases to_physical
#' @name Expr_to_physical
#' @examples
#' pl$DataFrame(
#'   list(vals = c("a", "x", NA, "a"))
#' )$with_columns(
#'   pl$col("vals")$cast(pl$Categorical),
#'   pl$col("vals")
#'     $cast(pl$Categorical)
#'     $to_physical()
#'     $alias("vals_physical")
#' )
Expr_to_physical = "use_extendr_wrapper"


#' Cast between DataType(s)
#' @keywords Expr
#' @param dtype DataType to cast to.
#' @param strict bool if true an error will be thrown if cast failed at resolve time.
#' @return Expr
#' @aliases cast
#' @name Expr_cast
#' @aliases cast
#' @examples
#' df = pl$DataFrame(list(a = 1:3, b = 1:3))
#' df$with_columns(
#'   pl$col("a")$cast(pl$dtypes$Float64, TRUE),
#'   pl$col("a")$cast(pl$dtypes$Int32, TRUE)
#' )
Expr_cast = function(dtype, strict = TRUE) {
  .pr$Expr$cast(self, dtype, strict)
}




#' Reverse exponentiation `%**%`(in R `** == ^`)
#' @description Raise a base to the power of the expression as exponent.
#' @keywords Expr
#' @param base real or Expr, the value of the base, self is the exponent
#' @return Expr
#' @name Expr_rpow
#' @details  do not use `**`, R secretly parses that just as if it was a `^`
#' @aliases rpow %**%
#' @examples
#' pl$DataFrame(list(a = -1:3))$select(
#'   pl$lit(2)$rpow(pl$col("a"))
#')$get_column("a")$to_r() ==  (-1:3)^2
#'
#' pl$DataFrame(list(a = -1:3))$select(
#'   pl$lit(2) %**% (pl$col("a"))
#' )$get_column("a")$to_r() ==  (-1:3)^2
Expr_rpow = function(base) {
  if(!inherits(base,"Expr")) base = pl$lit(base)
  expr = .pr$Expr$pow(base,self)

}
#' @export
"%**%" = function(lhs,rhs) rhs^lhs #some default method of what reverse exponentiation is (as python ** operator)
#' @export
"%**%.Expr" <- function(e1,e2) e1$rpow(e2)


#' Square root
#' @description  Compute the square root of the elements.
#' @keywords Expr
#' @return Expr
#' @aliases sqrt
#' @name Expr_sqrt
#' @examples
#' pl$DataFrame(list(a = -1:3))$select(pl$col("a")$sqrt())
Expr_sqrt = function() {
  self$pow(0.5)
}


#' Natural Log
#' @description  Compute the base x logarithm of the input array, element-wise.
#' @keywords Expr
#' @return Expr
#' @aliases log
#' @name Expr_log
#' @examples
#' pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())
Expr_log  = function(base = base::exp(1)) {
  .pr$Expr$log(self, base)
}

#' 10-base log
#' @description Compute the base 10 logarithm of the input array, element-wise.
#' @keywords Expr
#' @return Expr
#' @aliases log10
#' @name Expr_log10
#' @format a method
#' @examples
#' pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())
Expr_log10  = "use_extendr_wrapper"


#' Compute the exponential, element-wise.
#' @keywords Expr
#' @return Expr
#' @aliases exp
#' @name Expr_exp
#' @format a method
#' @examples
#' log10123 = suppressWarnings(log(-1:3))
#' all.equal(
#'   pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$as_data_frame()$a,
#'   exp(1)^log10123
#' )
Expr_exp  = "use_extendr_wrapper"


#' Exclude certain columns from a wildcard/regex selection.
#' @description You may also use regexes in the exclude list. They must start with `^` and end with `$`.
#' @param columns given param type:
#'  - string: exclude name of column or exclude regex starting with ^and ending with$
#'  - character vector: exclude all these column names, no regex allowed
#'  - DataType: Exclude any of this DataType
#'  - List(DataType): Excldue any of these DataType(s)
#'
#' @keywords Expr
#' @return Expr
#' @aliases exclude
#' @name Expr_exclude
#' @examples
#'
#'  #make DataFrame
#'  df = pl$DataFrame(iris)
#'
#'  #by name(s)
#'  df$select(pl$all()$exclude("Species"))
#'
#'  #by type
#'  df$select(pl$all()$exclude(pl$Categorical))
#'  df$select(pl$all()$exclude(list(pl$Categorical,pl$Float64)))
#'
#'  #by regex
#'  df$select(pl$all()$exclude("^Sepal.*$"))
#'
#'
Expr_exclude  = function(columns) {

  #handle lists
  if(is.list(columns)) {
    columns = pcase(
      all(sapply(columns,inherits,"DataType")), unwrap(.pr$DataTypeVector$from_rlist(columns)),
      all(sapply(columns,is_string)), unlist(columns),
      or_else = unwrap(list(err=  paste0("only lists of pure DataType or String")))
    )
  }

  #dispatch exclude call on types
  pcase(
    is.character(columns), .pr$Expr$exclude(self, columns),
    inherits(columns, "DataTypeVector"), .pr$Expr$exclude_dtype(self,columns),
    inherits(columns, "DataType"), .pr$Expr$exclude_dtype(self,unwrap(.pr$DataTypeVector$from_rlist(list(columns)))),
    or_else = unwrap(list(err=  paste0("this type is not supported for Expr_exclude: ", columns)))
  )

}


#TODO contribute pypolars keep_name example does not showcase an example where the name changes
#' Keep the original root name of the expression.
#'
#' @keywords Expr
#' @return Expr
#' @aliases keep_name
#' @name Expr_keep_name
#' @format a method
#' @examples
#' pl$DataFrame(list(alice=1:3))$select(pl$col("alice")$alias("bob")$keep_name())
Expr_keep_name = "use_extendr_wrapper"



#TODO contribute polars, map_alias unwrap user function errors instead of passing them back
#' Map alias of expression with an R function
#' @description Rename the output of an expression by mapping a function over the root name.
#' @keywords Expr
#' @return Expr
#' @aliases map_alias
#' @name Expr_map_alias
#' @examples
#' pl$DataFrame(list(alice=1:3))$select(pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob")))
Expr_map_alias = function(fun) {
  if (!exists(".warn_map_alias",envir = minipolars:::runtime_state)) {
    assign(".warn_map_alias",1L,envir = minipolars:::runtime_state)
    # it does not seem map alias is executed multi-threaded but rather immediately during building lazy query
    # if ever crashing, any lazy method like select, filter, with_columns must use something like handle_thread_r_requests()
    # then handle_thread_r_requests should be rewritten to handle any type.
    message("map_alias function is experimentally without some thread-safeguards, please report any crashes") #TODO resolve
  }
  if(!is.function(fun)) unwrap(list(err="alias_map fun must be a function"), class="not_fun")
  if(length(formals(fun))==0) unwrap(list(err="alias_map fun must take at least one parameter"), class="not_one_arg")
  .pr$Expr$map_alias(self,fun)
}



#' Are elements finite
#' @description Returns a boolean output indicating which values are finite.
#'
#' @keywords Expr
#' @return Expr
#' @aliases is_finite
#' @name Expr_is_finite
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_finite())
Expr_is_finite = "use_extendr_wrapper"


#' Are elements infinite
#' @description Returns a boolean output indicating which values are infinite.
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @keywords Expr
#' @return Expr
#' @aliases is_infinite
#' @name Expr_is_infinite
#' @format a method
#' @examples
#' pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_infinite())
Expr_is_infinite = "use_extendr_wrapper"





#' Are elements NaN's
#' @description Returns a boolean Series indicating which values are NaN.
#' @details  Floating point NaN's are a different flag from Null(polars) which is the same as
#'  NA_real_(R).
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @keywords Expr
#' @return Expr
#' @aliases is_nan
#' @name Expr_is_nan
#'
#' @format a method
#' @examples
#' pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_nan())
Expr_is_nan = "use_extendr_wrapper"


#' Are elements not NaN's
#' @description Returns a boolean Series indicating which values are not NaN.
#' @details  Floating point NaN's are a different flag from Null(polars) which is the same as
#'  NA_real_(R).
#' @keywords Expr
#' @return Expr
#' @aliases is_not_nan
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @name Expr_is_not_nan
#' @format a method
#' @examples
#' pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_not_nan())
Expr_is_not_nan = "use_extendr_wrapper"



#' Get a slice of this expression.
#'
#' @param offset numeric or expression, zero-indexed where to start slice
#' negative value indicate starting (one-indexed) from back
#' @param length how many elements should slice contain
#'
#' @keywords Expr
#' @return Expr
#' @aliases slice
#' @name Expr_slice
#' @format a method
#' @examples
#'
#' #as head
#' pl$DataFrame(list(a=0:100))$select(
#'   pl$all()$slice(0,6)
#' )
#'
#' #as tail
#' pl$DataFrame(list(a=0:100))$select(
#'   pl$all()$slice(-6,6)
#' )
Expr_slice = function(offset, length) {
  .pr$Expr$slice(self, wrap_e(offset),wrap_e(length))
}


#' Append expressions
#' @description This is done by adding the chunks of `other` to this `output`.
#' @keywords Expr
#' @return Expr
#' @aliases append
#' @name Expr_append
#' @format a method
#' @examples
#' #append bottom to to row
#' df = pl$DataFrame(list(a = 1:3, b = c(NA_real_,4,5)))
#' df$select(pl$all()$head(1)$append(pl$all()$tail(1)))
#'
#' #implicit upcast, when default = TRUE
#' pl$DataFrame(list())$select(pl$lit(42)$append(42L))
#' pl$DataFrame(list())$select(pl$lit(42)$append(FALSE))
#' pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE))
Expr_append = function(other, upcast=TRUE) {
  .pr$Expr$append(self, wrap_e(other), upcast)
}


#' Rechunk memory layout
#' @description Create a single chunk of memory for this Series.
#' @keywords Expr
#' @return Expr
#' @aliases rechunk
#' @name Expr_rechunk
#' @format a method
#' @details
#' See rechunk() explained here \code{\link[minipolars]{docs_translations}}
#' @examples
#' #get chunked lengths with/without rechunk
#' series_list = pl$DataFrame(list(a=1:3,b=4:6))$select(
#'   pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
#'   pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
#' )$get_columns()
#' lapply(series_list, \(x) x$chunk_lengths())
Expr_rechunk = "use_extendr_wrapper"

#' Cumulative sum
#' @description  Get an array with the cumulative sum computed at every element.
#' @keywords Expr
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Expr
#' @aliases cumsum
#' @name Expr_cumsum
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4))$select(
#'   pl$col("a")$cumsum()$alias("cumsum"),
#'   pl$col("a")$cumsum(reverse=TRUE)$alias("cumsum_reversed")
#' )
Expr_cumsum = function(reverse = FALSE) {
  .pr$Expr$cumsum(self, reverse)
}


#' Cumulative product
#' @description Get an array with the cumulative product computed at every element.
#' @keywords Expr
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Expr
#' @aliases cumprod
#' @name Expr_cumprod
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#'
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4))$select(
#'   pl$col("a")$cumprod()$alias("cumprod"),
#'   pl$col("a")$cumprod(reverse=TRUE)$alias("cumprod_reversed")
#' )
Expr_cumprod = function(reverse = FALSE) {
  .pr$Expr$cumprod(self, reverse)
}

#' Cumulative minimum
#' @description  Get an array with the cumulative min computed at every element.
#' @keywords Expr
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Expr
#' @aliases cummin
#' @name Expr_cummin
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4))$select(
#'   pl$col("a")$cummin()$alias("cummin"),
#'   pl$col("a")$cummin(reverse=TRUE)$alias("cummin_reversed")
#' )
Expr_cummin = function(reverse = FALSE) {
  .pr$Expr$cummin(self, reverse)
}

#' Cumulative maximum
#' @description Get an array with the cumulative max computed at every element.
#' @keywords Expr
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Expr
#' @aliases cummin
#' @name Expr_cummin
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4))$select(
#'   pl$col("a")$cummax()$alias("cummux"),
#'   pl$col("a")$cummax(reverse=TRUE)$alias("cummax_reversed")
#' )
Expr_cummax = function(reverse = FALSE) {
  .pr$Expr$cummax(self, reverse)
}

#' Cumulative count
#' @description Get an array with the cumulative count computed at every element.
#'  Counting from 0 to len
#' @keywords Expr
#' @param reverse bool, default FALSE, if true roll over vector from back to forth
#' @return Expr
#' @aliases cumcount
#' @name Expr_cumcount
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#'
#' cumcount does not seem to count within lists.
#'
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4))$select(
#'   pl$col("a")$cumcount()$alias("cumcount"),
#'   pl$col("a")$cumcount(reverse=TRUE)$alias("cumcount_reversed")
#' )
Expr_cumcount = function(reverse = FALSE) {
  .pr$Expr$cumcount(self, reverse)
}


#' Floor
#' @description Rounds down to the nearest integer value.
#' Only works on floating point Series.
#' @keywords Expr
#' @return Expr
#' @aliases floor
#' @name Expr_floor
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
#' ))$select(
#'   pl$col("a")$floor()
#' )
Expr_floor = "use_extendr_wrapper"

#' Ceiling
#' @description Rounds up to the nearest integer value.
#' Only works on floating point Series.
#' @keywords Expr
#' @return Expr
#' @aliases ceil
#' @name Expr_ceil
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
#' ))$select(
#'   pl$col("a")$ceil()
#' )
Expr_ceil = "use_extendr_wrapper"

#' round
#' @description Round underlying floating point data by `decimals` digits.
#' @keywords Expr
#' @param decimals  integer Number of decimals to round by.
#' @return Expr
#' @aliases round
#' @name Expr_round
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
#' ))$select(
#'   pl$col("a")$round(0)
#' )
Expr_round = function(decimals) {
  unwrap(.pr$Expr$round(self, decimals))
}


#TODO contribute polars, dot product unwraps if datatypes, pass Result instead
#' Dot product
#' @description Compute the dot/inner product between two Expressions.
#' @keywords Expr
#' @param other Expr to compute dot product with.
#' @return Expr
#' @aliases dot
#' @name Expr_dot
#' @format a method
#' @examples
#' pl$DataFrame(list(a=1:4,b=c(1,2,3,4),c="bob"),)$select(
#'   pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
#'   pl$col("a")$dot(pl$col("a"))$alias("a dot a")
#' )
Expr_dot = function(other) {
  .pr$Expr$dot(self,wrap_e(other))
}


#' Mode
#' @description Compute the most occurring value(s). Can return multiple Values.
#' @keywords Expr
#' @return Expr
#' @aliases mode
#' @name Expr_mode
#' @format a method
#' @examples
#' df =pl$DataFrame(list(a=1:6,b = c(1L,1L,3L,3L,5L,6L), c = c(1L,1L,2L,2L,3L,3L)))
#' df$select(pl$col("a")$mode())
#' df$select(pl$col("b")$mode())
#' df$select(pl$col("c")$mode())
Expr_mode = "use_extendr_wrapper"


#' Expr_sort
#' @description Sort this column. In projection/ selection context the whole column is sorted.
#' If used in a groupby context, the groups are sorted.
#' @keywords Expr
#' @param reverse bool default FALSE, reverses sort
#' @param nulls_last bool, default FALSE, place Nulls last
#' @return Expr
#' @aliases sort
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @name Expr_sort
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$sort())
Expr_sort = function(reverse = FALSE, nulls_last = FALSE) { #param reverse named descending on rust side
  .pr$Expr$sort(self, reverse, nulls_last)
}


#TODO contribute polars, add arguments for Null/NaN/inf last/first, top_k unwraps k> len column
#' Top k values
#' @description  Return the `k` largest elements.
#' If 'reverse=True` the smallest elements will be given.
#' @details  This has time complexity: \eqn{ O(n + k \\log{}n - \frac{k}{2}) }
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @keywords Expr
#' @param k numeric k top values to get
#' @param reverse bool if true then k smallest values
#' @return Expr
#' @aliases top_k
#' @name Expr_top_k
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$top_k(5))
Expr_top_k = function(k , reverse = FALSE) {
  if(!is.numeric(k) || k<0) abort("k must be numeric and positive, prefereably integerish")
  .pr$Expr$top_k(self,k , reverse)
}



#' Index of a sort
#' @description Get the index values that would sort this column.
#' If 'reverse=True` the smallest elements will be given.
#' @keywords Expr
#' @param reverse bool default FALSE, reverses sort
#' @param nulls_last bool, default FALSE, place Nulls last
#' @return Expr
#' @aliases arg_sort
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @name Expr_arg_sort
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_sort())
Expr_arg_sort = function(reverse = FALSE, nulls_last = FALSE) { #param reverse named descending on rust side
  .pr$Expr$arg_sort(self, reverse, nulls_last)
}


#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @aliases arg_min
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @name Expr_arg_min
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_min())
Expr_arg_min = "use_extendr_wrapper"

#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @aliases arg_max
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @name Expr_arg_max
#' @format a method
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_max())
Expr_arg_max = "use_extendr_wrapper"



#' Wrap column in list
#' @description  Aggregate to list.
#' @keywords Expr
#' @return Expr
#' @aliases list
#' @name Expr_list
#' @format a method
Expr_list = "use_extendr_wrapper"



#TODO contribute pypolars search_sorted behavior is under-documented, does multiple elements work?
#' Where to inject element(s) to maintain sorting
#'
#' @description  Find indices in self where elements should be inserted into to maintain order.
#' @keywords Expr
#' @param element a R value into literal or an expression of an element
#' @return Expr
#' @aliases search_sorted
#' @name Expr_search_sorted
#' @details This function look up where to insert element if to keep self column sorted.
#' It is assumed the self column is already sorted ascending, otherwise wrongs answers.
#' This function is a bit under documented in py-polars.
#' @format a method
#' @examples
#' pl$DataFrame(list(a=0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))
Expr_search_sorted = function(element) {
  .pr$Expr$search_sorted(self, wrap_e(element))
}



#' sort column by order of others
#' @description Sort this column by the ordering of another column, or multiple other columns.
#' @param by one expression or list expressions and/or strings(interpreted as column names)
#' @param reverse single bool to boolean vector, any is_TRUE will give reverse sorting of that column
#' @return Expr
#' @keywords Expr
#' @aliases sort_by
#' @name Expr_sort_by
#' @details
#' In projection/ selection context the whole column is sorted.
#' If used in a groupby context, the groups are sorted.
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("a","a","a","b","b","b"),
#'   value1 = c(98,1,3,2,99,100),
#'   value2 = c("d","f","b","e","c","a")
#' ))
#'
#' # by one column/expression
#' df$select(
#'   pl$col("group")$sort_by("value1")
#' )
#'
#' # by two columns/expressions
#' df$select(
#'   pl$col("group")$sort_by(list("value2",pl$col("value1")), reverse =c(T,F))
#' )
#'
#'
#' # by some expression
#' df$select(
#'   pl$col("group")$sort_by(pl$col("value1")$sort(reverse=TRUE))
#' )
#'
#' #quite similar usecase as R function `order()`
#' l = list(
#'   ab = c(rep("a",6),rep("b",6)),
#'   v4 = rep(1:4, 3),
#'   v3 = rep(1:3, 4),
#'   v2 = rep(1:2,6),
#'   v1 = 1:12
#' )
#' df = pl$DataFrame(l)
#'
#'
#' #examples of order versus sort_by
#' all.equal(
#'   df$select(
#'     pl$col("ab")$sort_by("v4")$alias("ab4"),
#'     pl$col("ab")$sort_by("v3")$alias("ab3"),
#'     pl$col("ab")$sort_by("v2")$alias("ab2"),
#'     pl$col("ab")$sort_by("v1")$alias("ab1"),
#'     pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=c(F,T))$alias("ab13FT"),
#'     pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=T)$alias("ab13T")
#'   )$to_list(),
#'   list(
#'     ab4 = l$ab[order(l$v4)],
#'     ab3 = l$ab[order(l$v3)],
#'     ab2 = l$ab[order(l$v2)],
#'     ab1 = l$ab[order(l$v1)],
#'     ab13FT= l$ab[order(l$v3,rev(l$v1))],
#'     ab13T = l$ab[order(l$v3,l$v1,decreasing= T)]
#'   )
#' )
Expr_sort_by = function(by, reverse = FALSE) {
  pra = construct_protoArrayExpr(by)
  unwrap(.pr$Expr$sort_by(self, pra, reverse))
}


#TODO coontribute pyPolars, if exceeding u32 return Null, if exceeding column return Error
#either it should be error or Null.
#pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(5294967296.0)) #return Null
#pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(-3)) #return Null
#pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(7)) #return Error
#' Take values by index.
#' @param indeces R scalar/vector or Series, or Expr that leads to a UInt32 dtyped Series.
#' @return Expr
#' @keywords Expr
#' @aliases take
#' @name Expr_take
#' @details
#' similar to R indexing syntax e.g. `letters[c(1,3,5)]`, however as an expression, not as eager computation
#' exceeding
#'
#' @format a method
#' @examples
#' pl$empty_select( pl$lit(0:10)$take(c(1,8,0,7)))
Expr_take = function(indices) {
  .pr$Expr$take(self, pl$lit(indices))
}



#' Shift values
#' @param periods numeric number of periods to shift, may be negative.
#' @return Expr
#' @keywords Expr
#' @aliases shift
#' @name Expr_shift
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$empty_select(
#'   pl$lit(0:3)$shift(-2)$alias("shift-2"),
#'   pl$lit(0:3)$shift(2)$alias("shift+2")
#' )
Expr_shift = "use_extendr_wrapper"

#' Shift and fill values
#' @description Shift the values by a given period and fill the resulting null values.
#'
#' @param periods numeric number of periods to shift, may be negative.
#' @param fill_value Fill None values with the result of this expression.
#' @return Expr
#' @keywords Expr
#' @aliases shift_and_fill
#' @name Expr_shift_and_fill
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$empty_select(
#'   pl$lit(0:3),
#'   pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
#'   pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
#' )
Expr_shift_and_fill = function(periods, fill_value) {
  .pr$Expr$shift_and_fill(self, periods, pl$lit(fill_value))
}


#' Fill Nulls with a value or strategy.
#' @description Shift the values by value or as strategy.
#'
#' @param value Expr or `Into<Expr>` to fill Null values with
#' @param strategy default NULL else 'forward', 'backward', 'min', 'max', 'mean', 'zero', 'one'
#' @param limit Number of consecutive null values to fill when using the 'forward' or 'backward' strategy.
#' @return Expr
#' @keywords Expr
#' @aliases fill_null
#' @name Expr_fill_null
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#'
#' @examples
#' pl$empty_select(
#'   pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
#'   pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
#' )
Expr_fill_null = function(value = NULL, strategy = NULL, limit = NULL) {
  pcase(
    # the wrong stuff
     is.null(value) && is.null(strategy),   abort("must specify either value or strategy"),
    !is.null(value) && !is.null(strategy),  abort("cannot specify both value and strategy"),
    !is.null(strategy) && !strategy %in% c("forward","backward") && !is.null(limit), abort(
      "can only specify 'limit' when strategy is set to 'backward' or 'forward'"
    ),

    # the two use cases
    !is.null(value), .pr$Expr$fill_null(self, pl$lit(value)),
     is.null(value), unwrap(.pr$Expr$fill_null_with_strategy(self , strategy, limit)),

    # catch failed any match
    or_else = abort("failed to handle user inputs", .internal = TRUE)
  )
}


#' Fill Nulls Backward
#' @description Fill missing values with the next to be seen values.
#'
#' @param limit Expr or `Into<Expr>`  The number of consecutive null values to backward fill.
#' @return Expr
#' @keywords Expr
#' @aliases backward_fill
#' @name Expr_backward_fill
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#'
#' @examples
#' l = list(a=c(1L,rep(NA_integer_,3L),10))
#' pl$DataFrame(l)$select(
#'   pl$col("a")$backward_fill()$alias("bf_null"),
#'   pl$col("a")$backward_fill(limit = 0)$alias("bf_l0"),
#'   pl$col("a")$backward_fill(limit = 1)$alias("bf_l1")
#' )$to_list()
Expr_backward_fill = function(limit = NULL) {
  .pr$Expr$backward_fill(self, limit)
}

#' Fill Nulls Forward
#' @description Fill missing values with last seen values.
#'
#' @param limit Expr or `Into<Expr>`  The number of consecutive null values to forward fill.
#' @return Expr
#' @keywords Expr
#' @aliases forward_fill
#' @name Expr_forward_fill
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#'
#' @examples
#' l = list(a=c(1L,rep(NA_integer_,3L),10))
#' pl$DataFrame(l)$select(
#'   pl$col("a")$forward_fill()$alias("ff_null"),
#'   pl$col("a")$forward_fill(limit = 0)$alias("ff_l0"),
#'   pl$col("a")$forward_fill(limit = 1)$alias("ff_l1")
#' )$to_list()
Expr_forward_fill = function(limit = NULL) {
  .pr$Expr$forward_fill(self, limit)
}


#' Fill Nulls Forward
#' @description Fill missing values with last seen values.
#'
#' @param Expr or `Into<Expr>`  the value to replace NaN with. Default NULL is NA/Null.
#' @return Expr
#' @keywords Expr
#' @aliases fill_nan
#' @name Expr_fill_nan
#' @format a method
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#'
#' @examples
#' l = list(a=c(1,NaN,NaN,3))
#' pl$DataFrame(l)$select(
#'   pl$col("a")$fill_nan()$alias("fill_default"),
#'   pl$col("a")$fill_nan(pl$lit(NA))$alias("fill_NA"), #same as default
#'   pl$col("a")$fill_nan(2)$alias("fill_float2"),
#'   pl$col("a")$fill_nan("hej")$alias("fill_str") #implicit cast to Utf8
#' )$to_list()
Expr_fill_nan = function(expr = NULL) {
  .pr$Expr$fill_nan(self, wrap_e(expr))
}


#' Get Standard Deviation
#'
#' @param ddof integer in range [0;255] degrees of freedom
#' @return Expr (f64 scalar)
#' @keywords Expr
#' @aliases std
#' @name Expr_std
#' @format a method
#'
#' @examples
#' pl$empty_select(pl$lit(1:5)$std())
Expr_std = function(ddof = 1) {
  .pr$Expr$std(self, ddof)
}

#' Get Variance
#'
#' @param ddof integer in range [0;255] degrees of freedom
#' @return Expr (f64 scalar)
#' @keywords Expr
#' @aliases var
#' @name Expr_var
#' @format a method
#'
#' @examples
#' pl$empty_select(pl$lit(1:5)$var())
Expr_var = function(ddof = 1) {
  .pr$Expr$var(self, ddof)
}


#' max
#' @keywords Expr
#' @description
#' Get maximum value.
#'
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}s
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$max() == 3) #is true
Expr_max = "use_extendr_wrapper"

#' min
#' @keywords Expr
#' @description
#' Get minimum value.
#'
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$min()== 1 ) #is true
Expr_min = "use_extendr_wrapper"



#TODO Contribute polars, nan_max and nan_min poison on NaN. But no method poison on `Null`
#In R both NA and NaN poisons, but NA has priority which is meaningful, as NA is even less information
#then NaN.

#' max
#' @keywords Expr
#' @description Get maximum value, but propagate/poison encountered `NaN` values.
#' Get maximum value.
#' @aliases nan_min
#' @return Expr
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}s
#' @examples
#' pl$DataFrame(list(x=c(1,NaN,Inf,3)))$select(pl$col("x")$nan_max()$is_nan()) #is true
Expr_nan_max = "use_extendr_wrapper"

#' min propagate NaN
#'
#' @keywords Expr
#' @description Get minimum value, but propagate/poison encountered `NaN` values.
#' @return Expr
#' @aliases nan_min
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[minipolars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x=c(1,NaN,-Inf,3)))$select(pl$col("x")$nan_min()$is_nan()) #is true
Expr_nan_min = "use_extendr_wrapper"



#' sum
#' @keywords Expr
#' @description
#' Get sum value
#'
#' @details
#'  Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1L,NA,2L)))$select(pl$col("x")$sum())#is i32 3 (Int32 not casted)
Expr_sum = "use_extendr_wrapper"



#' mean
#' @keywords Expr
#' @description
#' Get mean value.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$mean()==2) #is true
Expr_mean = "use_extendr_wrapper"

#' median
#' @keywords Expr
#' @description
#' Get median value.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,NA,2)))$select(pl$col("x")$median()==1.5) #is true
Expr_median = "use_extendr_wrapper"

##TODO contribute polars: product does not support in rust i32

#' Product
#' @keywords Expr
#' @description Compute the product of an expression.
#' @aliases  Product
#' @return Expr
#' @details does not support integer32 currently, .cast() to f64 or i64 first.
#' @examples
#' pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$product()==6) #is true
Expr_product = "use_extendr_wrapper"


#' Count number of unique values
#' @keywords Expr
#' @description
#' Count number of unique values.
#' Similar to R length(unique(x))
#' @aliases n_unique
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
Expr_n_unique = "use_extendr_wrapper"



#' Count `Nulls`
#' @keywords Expr
#' @aliases null_count
#' @return Expr
#' @examples
#' pl$empty_select(pl$lit(c(NA,"a",NA,"b"))$null_count())
Expr_null_count = "use_extendr_wrapper"

#' Index of First Unique Value.
#' @keywords Expr
#' @aliases arg_unique
#' @return Expr
#' @examples
#' pl$empty_select(pl$lit(c(1:2,1:3))$arg_unique())
Expr_arg_unique = "use_extendr_wrapper"


#' get unqie values
#' @keywords Expr
#' @description
#'  Get unique values of this expression.
#' Similar to R unique()
#' @param maintain_order bool, if TRUE guranteed same order, if FALSE maybe
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$unique())
Expr_unique = function(maintain_order = FALSE) {
  if(!is_bool(maintain_order)) abort("param maintain_order must be a bool")
  if(maintain_order) {
    .pr$Expr$unique_stable(self)
  } else {
    .pr$Expr$unique(self)
  }
}

#' First
#' @keywords Expr
#' @description
#' Get the first value.
#' Similar to R head(x,1)
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$first())
Expr_first= "use_extendr_wrapper"

#' Last
#' @keywords Expr
#' @description
#' Get the lastvalue.
#' Similar to R syntax tail(x,1)
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$last())
Expr_last = "use_extendr_wrapper"



#' over
#' @keywords Expr
#' @description
#'Apply window function over a subgroup.
#'This is similar to a groupby + aggregation + self join.
#'Or similar to `window functions in Postgres
#'<https://www.postgresql.org/docs/current/tutorial-window.html>`_.
#' @param ... of strings or columns to group by
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(val=1:5,a=c("+","+","-","-","+"),b=c("+","-","+","-","+")))$select(pl$col("val")$count()$over("a","b"))
Expr_over = function(...) {

  #combine arguments in proto expression array
  pra = construct_protoArrayExpr(list2(...))

  #pass to over
  .pr$Expr$over(self,pra)

}


#' Get mask of unique values
#'
#' @return Expr (boolean)
#' @keywords Expr
#' @aliases is_unique
#' @name Expr_is_unique
#' @format a method
#'
#' @examples
#' v = c(1,1,2,2,3,NA,NaN,Inf)
#' all.equal(
#'   pl$empty_select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated"),
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first  = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_unique = "use_extendr_wrapper"

#' Get a mask of the first unique value.
#'
#' @return Expr (boolean)
#' @keywords Expr
#' @aliases is_unique
#' @name Expr_is_first
#' @format a method
#'
#' @examples
#' v = c(1,1,2,2,3,NA,NaN,Inf)
#' all.equal(
#'   pl$empty_select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated"),
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first  = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_first = "use_extendr_wrapper"


#' Get mask of duplicated values.
#'
#' @return Expr (boolean)
#' @keywords Expr
#' @aliases is_duplicated
#' @name Expr_is_duplicated
#' @format a method
#' @details  is_duplicated is the opposite of `is_unique()`
#'  Looking for R like `duplicated()`?, use  `some_expr$is_first()$is_not()`
#'
#' @examples
#' v = c(1,1,2,2,3,NA,NaN,Inf)
#' all.equal(
#'   pl$empty_select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated"),
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first  = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_duplicated = "use_extendr_wrapper"


#TODO contribute polars, example of where NA/Null is omitted and the smallest value
#' Get quantile value.
#'
#' @param quantile numeric 0.0 to 1.0
#' @param inerpolation string value from choices "nearest", "higher",
#' "lower", "midpoint", "linear"
#' @return Expr
#' @keywords Expr
#' @aliases quantile
#' @name Expr_quantile
#' @format a method
#'
#' @details `Nulls` are ignored and `NaNs` are ranked as the largest value.
#' For linear interpolation `NaN` poisons `Inf`, that poisons any other value.
#'
#' @examples
#' pl$empty_select(pl$lit(-5:5)$quantile(.5))
Expr_quantile = function(quantile, interpolation = "nearest") {
  unwrap(.pr$Expr$quantile(self, quantile, interpolation))
}



#' Filter a single column.
#' @description
#' Mostly useful in an aggregation context. If you want to filter on a DataFrame
#' level, use `LazyFrame.filter`.
#'
#' @param predicate Expr or something `Into<Expr>`. Should be a boolean expression.
#' @return Expr
#' @keywords Expr
#' @aliases filter
#' @format a method
#'
#' @examples
#' df = pl$DataFrame(list(
#'   group_col =  c("g1", "g1", "g2"),
#'   b = c(1, 2, 3)
#' ))
#'
#' df$groupby("group_col")$agg(
#'   pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
#'   pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte"),
#' )
Expr_filter = function(predicate) {
  .pr$Expr$filter(self, wrap_e(predicate))
}

#' Where: Filter a single column.
#' @rdname Expr_filter
#' @description
#' where() is an alias for pl$filter
#'
#' @aliases where
Expr_where = Expr_filter






#' Explode a list or utf8 Series.
#' @description
#' This means that every item is expanded to a new row.
#'
#' @return Expr
#' @keywords Expr
#' @aliases explode
#' @format a method
#'
#' @details
#' explode/flatten does not support categorical
#'
#' @examples
#' pl$DataFrame(list(a=letters))$select(pl$col("a")$explode()$take(0:5))
#'
#' listed_group_df =  pl$DataFrame(iris[c(1:3,51:53),])$groupby("Species")$agg(pl$all())
#' print(listed_group_df)
#' vectors_df = listed_group_df$select(
#'   pl$col(c("Sepal.Width","Sepal.Length"))$explode()
#' )
#' print(vectors_df)
Expr_explode = "use_extendr_wrapper"

#' @description
#' ( flatten is an alias for explode )
#' @keywords Expr
#' @aliases flatten
#' @format a method
#' @name Expr_flatten
#' @rdname Expr_explode
Expr_flatten = "use_extendr_wrapper"


#' Take every n'th element
#' @description
#' Take every nth value in the Series and return as a new Series.
#' @param n positive integerish value
#'
#' @return Expr
#' @keywords Expr
#' @aliases take_every
#' @format a method
#'
#' @examples
#' pl$DataFrame(list(a=0:24))$select(pl$col("a")$take_every(6))
Expr_take_every = function(n) {
  unwrap(.pr$Expr$take_every(self, n))
}


#' Head
#' @keywords Expr
#' @description
#' Get the head n elements.
#' Similar to R head(x)
#' @param n numeric number of elements to select from head
#' @return Expr
#' @aliases head
#' @examples
#' #get 3 first elements
#' pl$DataFrame(list(x=1:11))$select(pl$col("x")$head(3))
Expr_head = function(n=10) {
  if(!is.numeric(n)) abort("n must be numeric")
  unwrap(.pr$Expr$head(self,n=n))
}

#' Tail
#' @keywords Expr
#' @description
#' Get the tail n elements.
#' Similar to R tail(x)
#' @param n numeric number of elements to select from tail
#' @return Expr
#' @aliases tail
#' @examples
#' #get 3 last elements
#' pl$DataFrame(list(x=1:11))$select(pl$col("x")$tail(3))
Expr_tail = function(n=10) {
  if(!is.numeric(n)) abort("n must be numeric")
  unwrap(.pr$Expr$tail(self,n=n))
}


#' Limit
#' @keywords Expr
#' @description
#' Alias for Head
#' Get the head n elements.
#' Similar to R head(x)
#' @param n numeric number of elements to select from head
#' @return Expr
#' @aliases limit
#' @examples
#' #get 3 first elements
#' pl$DataFrame(list(x=1:11))$select(pl$col("x")$limit(3))
Expr_limit = function(n=10) {
  if(!is.numeric(n)) abort("n must be numeric")
  unwrap(.pr$Expr$head(self,n=n))
}



#' Exponentiation `^` or `**`
#' @description Raise expression to the power of exponent.
#' @keywords Expr
#' @param base real value of base
#' @return Expr
#' @name Expr_pow
#' @aliases pow
#' @examples
#' pl$DataFrame(list(a = -1:3))$select(pl$lit(2)$pow(pl$col("a")))$get_column("literal")$to_r()== 2^(-1:3)
#' pl$DataFrame(list(a = -1:3))$select(pl$lit(2) ^ (pl$col("a")))$get_column("literal")$to_r()== 2^(-1:3)
Expr_pow = function(exponent) {
  if(!inherits(exponent,"Expr")) exponent = pl$lit(exponent)
  .pr$Expr$pow(self,exponent)
}
#' @export
"^.Expr" <- function(e1,e2) e1$pow(e2)


#' is_in
#' @name Expr_is_in
#' @description combine to boolean expresions with similar to `%in%`
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @aliases is_in
#' @examples
#'
#' #R Na_integer -> polars Null(Int32) is in polars Null(Int32)
#' pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_real_)))$as_data_frame()[[1L]]
#'
#'
#'
Expr_is_in= "use_extendr_wrapper"

##TODO contribute polars, do not panic on by pointing to non positive values
#' Repeat by
#' @keywords Expr
#' @description
#' Repeat the elements in this Series as specified in the given expression.
#' The repeated elements are expanded into a `List`.
#' @param by Expr Numeric column that determines how often the values will be repeated.
#' The column will be coerced to UInt32. Give this dtype to make the coercion a
#' no-op.
#' @return Expr
#' @aliases repeat_by
#' @examples
#' df = pl$DataFrame(list(a = c("x","y","z"), n = c(0:2)))
#' df$select(pl$col("a")$repeat_by("n"))
Expr_repeat_by = function(by) {
  if(is.numeric(by) && any(by<0)) abort("In repeat_by: any value less than zero is not allowed")
  .pr$Expr$repeat_by(self, wrap_e(by, FALSE))
}



#' is in between
#' @keywords Expr
#' @description
#' Check if this expression is between start and end.
#' @param start Lower bound as primitive or datetime
#' @param end Lower bound as primitive or datetime
#' @param include_bounds bool vector or scalar:
#' FALSE:           Exclude both start and end (default).
#' TRUE:            Include both start and end.
#' c(FALSE, FALSE):  Exclude start and exclude end.
#' c(TRUE, TRUE):    Include start and include end.
#' c(FALSE, TRUE):   Exclude start and include end.
#' c(TRUE, FALSE):   Include start and exclude end.
#' @details alias the column to 'in_between'
#' This function is equivalent to a combination of < <= >= and the &-and operator.
#' @return Expr
#' @aliases is_between
#' @examples
#' df = pl$DataFrame(list(num = 1:5))
#' df$select(pl$col("num")$is_between(2,4))
#' df$select(pl$col("num")$is_between(2,4,TRUE))
#' df$select(pl$col("num")$is_between(2,4,c(F,T)))
#' df$select(pl$col("num")$is_between(c(0,2,3,3,3),6)) #start end can be a vector/expr with same length as column
Expr_is_between = function(start, end, include_bounds = FALSE) {

  # check
  if(
    !length(include_bounds) %in% 1:2 ||
    !is.logical(include_bounds) ||
    any(is.na(include_bounds))
  ) {
    abort("in is_between: inlcude_bounds must be boolean of length 1 or 2, with no NAs")
  }

  # prepare args
  start_e =  wrap_e(start)
  end_e = wrap_e(end)
  with_start = include_bounds[1L]
  with_end = if(length(include_bounds)==1) include_bounds else include_bounds[2]


  # build and return boolean expression
  within_start_e = if(with_start) self >= start_e else self > start_e
  within_end_e   = if(with_end  ) self <= end_e   else self < end_e
  (within_start_e & within_end_e)$alias("is_between")
}



#' hash
#' @keywords Expr
#' @description
#' Hash the elements in the selection.
#' The hash value is of type `UInt64`.
#' @param seed Random seed parameter. Defaults to 0.
#' @param seed_1 Random seed parameter. Defaults to arg seed.
#' @param seed_2 Random seed parameter. Defaults to arg seed.
#' @param seed_3 Random seed parameter. Defaults to arg seed.
#' The column will be coerced to UInt32. Give this dtype to make the coercion a
#' no-op.
#' @return Expr
#' @importFrom rlang "%||%"
#' @aliases hash
#' @examples
#' df = pl$DataFrame(iris)
#' df$select(pl$all()$head(2)$hash(1234)$cast(pl$Utf8))$to_list()
Expr_hash = function(seed = 0, seed_1=NULL,seed_2=NULL, seed_3=NULL) {
  k0 = seed
  k1 = seed_1 %||% seed
  k2 = seed_2 %||% seed
  k3 = seed_3 %||% seed
  unwrap(.pr$Expr$hash(self, k0, k1, k2, k3))
}


#' reinterpret bits
#' @keywords Expr
#' @description
#' Reinterpret the underlying bits as a signed/unsigned integer.
#' This operation is only allowed for 64bit integers. For lower bits integers,
#' you can safely use that cast operation.
#' @param signed bool reinterpret into Int64 else Uint64
#' @return Expr
#' @aliases reinterpret
#' @examples
#' df = pl$DataFrame(iris)
#' df$select(pl$all()$head(2)$hash(1,2,3,4)$reinterpret())$as_data_frame()
Expr_reinterpret = function(signed = TRUE) {
  if(!is_bool(signed)) abort("in reinterpret() : arg signed must be a bool")
  .pr$Expr$reinterpret(self,signed)
}


#' Inspect evaluated Series
#' @keywords Expr
#' @description
#' Print the value that this expression evaluates to and pass on the value.
#' The printing will happen when the expression evaluates, not when it is formed.
#' @param fmt format string, should contain one set of `{}` where object will be printed
#' This formatting mimics python "string".format() use in pypolars. The string can
#' contain any thing but should have exactly one set of curly bracket {}.
#' @return Expr
#' @aliases inspect
#' @examples
#' pl$empty_select(pl$lit(1:5)$inspect("before dropping half the column it was:{}and not it is dropped")$head(2))
Expr_inspect = function(fmt = "{}") {

  #check fmt and create something to print before and after printing Series.
  if(!is_string(fmt)) abort("Inspect: arg fmt is not a string (length=1)")
  strs = strsplit(fmt, split = "\\{\\}")[[1L]]
  if(identical(strs,"")) strs = c("","")
  if(length(strs)!=2L || length(gregexpr("\\{\\}",fmt)[[1L]])!=1L) abort(paste0(
    "Inspect: failed to parse arg fmt [",fmt,"] ",
    " a string containing the two consecutive chars `{}` once. \n",
    "a valid string is e.g. `hello{}world`"
    )
  )

  #function to print the evaluated Series
  f_inspect = function(s) { #required signature f(Series) -> Series
    cat(strs[1L])
    s$print()
    cat(strs[2L],"\n",sep="")
    s
  }

  #add a map to expression printing the evaluated series
  .pr$Expr$map(self = self, lambda = f_inspect, output_type = NULL, agg_list = TRUE)
}



#' Interpolate `Nulls`
#' @keywords Expr
#' @description
#' Fill nulls with linear interpolation over missing values.
#' Can also be used to regrid data to a new grid - see examples below.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$empty_select(pl$lit(c(1,NA,4,NA,100,NaN,150))$interpolate())
#'
#' #x, y interpolation over a grid
#' df_original_grid = pl$DataFrame(list(
#'   grid_points = c(1, 3, 10),
#'   values = c(2.0, 6.0, 20.0)
#' ))
#' df_new_grid = pl$DataFrame(list(grid_points = (1:10)*1.0))
#'
#' # Interpolate from this to the new grid
#' df_new_grid$join(
#'   df_original_grid, on="grid_points", how="left"
#' )$with_columns(pl$col("values")$interpolate())
Expr_interpolate = "use_extendr_wrapper"



#' @importFrom rlang is_scalar_integerish
prepare_rolling_window_args = function(
  window_size,#: int | str,
  min_periods = NULL#: int | None = None,
) { # ->tuple[str, int]:
  if (is_scalar_integerish(window_size)) {
    if (is.null(min_periods)) min_periods = as.numeric(window_size)
    window_size = paste0(as.character(window_size),"i")
  }
  if (is.null(min_periods)) min_periods = 1
  list(window_size = window_size, min_periods = min_periods)
}


##TODO impl datatime in rolling expr
##TODO contribute polars rolling _min _max _sum _mean do no behave as the aggregation counterparts
## as NULLs are not omitted. Maybe the best resolution is to implement skipnull option in all function
## and check if it wont mess up optimzation (maybe it is tested for).


#' Rolling Min
#' @keywords Expr
#' @description
#' Apply a rolling min (moving min) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_min(window_size = 2))
Expr_rolling_min = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_min(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}

#' Rolling max
#' @keywords Expr
#' @description
#' Apply a rolling max (moving max) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_max(window_size = 2))
Expr_rolling_max = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_max(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}

#' Rolling mean
#' @keywords Expr
#' @description
#' Apply a rolling mean (moving mean) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_mean(window_size = 2))
Expr_rolling_mean = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_mean(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}



#' Rolling sum
#' @keywords Expr
#' @description
#' Apply a rolling sum (moving sum) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_sum(window_size = 2))
Expr_rolling_sum = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_sum(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}


#' Rolling std
#' @keywords Expr
#' @description
#' Apply a rolling std (moving std) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_std(window_size = 2))
Expr_rolling_std = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_std(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}

#' Rolling var
#' @keywords Expr
#' @description
#' Apply a rolling var (moving var) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_var(window_size = 2))
Expr_rolling_var = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_var(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}

#' Rolling median
#' @keywords Expr
#' @description
#' Apply a rolling median (moving median) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_median(window_size = 2))
Expr_rolling_median = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_median(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}


##TODO contribute polars arg center only allows center + right alignment, also implement left
#' Rolling quantile
#' @keywords Expr
#' @description
#' Apply a rolling quantile (moving quantile) over the values in this array.
#' A window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector. The resulting values will be aggregated to their sum.
#'
#' @param quantile Quantile between 0.0 and 1.0.
#' @param  interpolation choice c('nearest', 'higher', 'lower', 'midpoint', 'linear')
#'
#' @param window_size
#' The length of the window. Can be a fixed integer size, or a dynamic temporal
#' size indicated by the following string language:
#'   - 1ns   (1 nanosecond)
#' - 1us   (1 microsecond)
#' - 1ms   (1 millisecond)
#' - 1s    (1 second)
#' - 1m    (1 minute)
#' - 1h    (1 hour)
#' - 1d    (1 day)
#' - 1w    (1 week)
#' - 1mo   (1 calendar month)
#' - 1y    (1 calendar year)
#' - 1i    (1 index count)
#' If the dynamic string language is used, the `by` and `closed` arguments must
#' also be set.
#' @param weights
#' An optional slice with the same length as the window that will be multiplied
#' elementwise with the values in the window.
#' @param min_periods
#' The number of values in the window that should be non-null before computing
#' a result. If None, it will be set equal to window size.
#' @param center
#' Set the labels at the center of the window
#' @param by
#' If the `window_size` is temporal for instance `"5h"` or `"3s`, you must
#' set the column that will be used to determine the windows. This column must
#' be of dtype `{Date, Datetime}`
#' @param closed : {'left', 'right', 'both', 'none'}
#' Define whether the temporal window interval is closed or not.
#'
#'
#' @details
#' #Warnings
#' --------
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes
#' -----
#'   If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$DataFrame(list(a=1:6))$select(
#'   pl$col("a")$rolling_quantile(window_size = 2, quantile = .5)
#' )
Expr_rolling_quantile = function(
    quantile,
    interpolation = "nearest",
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,#:bool,
    by = NULL,#: Nullable<String>,
    closed = "left" #;: Nullable<String>,
) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_quantile(
    self, quantile, interpolation, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}


#' Rolling skew
#'
#' @param window_size integerish, Size of the rolling window
#' @param bias bool default = TRUE,  If False, then the calculations are corrected for statistical bias.
#'
#' @keywords Expr
#' @description
#' Compute a rolling skew.
#' @return Expr
#' @aliases rolling_skew
#' @details
#'
#'  Extra comments copied from rust-polars_0.25.1
#'   Compute the sample skewness of a data set.
#'
#'  For normally distributed data, the skewness should be about zero. For
#'  uni-modal continuous distributions, a skewness value greater than zero means
#'  that there is more weight in the right tail of the distribution. The
#'  function `skewtest` can be used to determine if the skewness value
#'  is close enough to zero, statistically speaking.
#'
#'  see: https://github.com/scipy/scipy/blob/47bb6febaa10658c72962b9615d5d5aa2513fa3a/scipy/stats/stats.py#L1024
#'
#' @examples
#' pl$DataFrame(list(a=iris$Sepal.Length))$select(pl$col("a")$rolling_skew(window_size = 4 )$head(10))
Expr_rolling_skew = function(window_size, bias = TRUE) {
  unwrap(.pr$Expr$rolling_skew(self, window_size, bias))
}


#' Abs
#' @description Compute absolute values
#' @keywords Expr
#' @return Exprs abs
#' @examples
#' pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
Expr_abs = "use_extendr_wrapper"


#' Arg Sort
#' @description argsort is a alias for arg_sort
#' @rdname Expr_arg_sort
#' @aliases argsort
#' @keywords Expr
Expr_argsort = Expr_arg_sort



#' Rank
#' @description  Assign ranks to data, dealing with ties appropriately.
#' @param method string option 'average', 'min', 'max', 'dense', 'ordinal', 'random'
#'
#' #' The method used to assign ranks to tied elements.
#' The following methods are available (default is 'average'):
#'   - 'average' : The average of the ranks that would have been assigned to
#' all the tied values is assigned to each value.
#' - 'min' : The minimum of the ranks that would have been assigned to all
#' the tied values is assigned to each value. (This is also referred to
#'                                             as "competition" ranking.)
#' - 'max' : The maximum of the ranks that would have been assigned to all
#' the tied values is assigned to each value.
#' - 'dense' : Like 'min', but the rank of the next highest element is
#' assigned the rank immediately after those assigned to the tied
#' elements.
#' - 'ordinal' : All values are given a distinct rank, corresponding to
#' the order that the values occur in the Series.
#' - 'random' : Like 'ordinal', but the rank for ties is not dependent
#' on the order that the values occur in the Series.
#'
#' @param reverse bool, reverse the operation
#' @return  Expr
#' @aliases rank
#' @keywords Expr
#' @examples
#' #  The 'average' method:
#' df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
#' df$select(pl$col("a")$rank())
#'
#' #  The 'ordinal' method:
#' df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
#' df$select(pl$col("a")$rank("ordinal"))
Expr_rank = function(method = "average", reverse = FALSE) {
  unwrap(.pr$Expr$rank(self, method, reverse))
}



#' Diff
#' @description  Calculate the n-th discrete difference.
#' @param n  Integerish Number of slots to shift.
#' @param null_behavior option default 'ignore', else 'drop'
#' @return  Expr
#' @aliases diff
#' @keywords Expr
#' @examples
#' pl$DataFrame(list( a=c(20L,10L,30L,40L)))$select(
#'   pl$col("a")$diff()$alias("diff_default"),
#'   pl$col("a")$diff(2,"ignore")$alias("diff_2_ignore")
#' )
Expr_diff = function(n = 1, null_behavior = "ignore") {
  unwrap(.pr$Expr$diff(self, n, null_behavior))
}



