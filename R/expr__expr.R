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
#' @examples pl$col("some_column")$sum()$over("some_other_column")
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
wrap_e = function(e) {
  if(inherits(e,"Expr")) e else Expr$lit(e)
}


#' Abs
#' @description Compute absolute values
#' @keywords Expr
#' @return Exprs abs
#' @examples
#' pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
Expr_abs = "use_extendr_wrapper"


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

#' Count number of unique values
#' @keywords Expr
#' @description
#' Count number of unique values.
#' Similar to R length(unique(x))
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
Expr_n_unique = "use_extendr_wrapper"

#' Drop null(s)
#' @keywords Expr
#' @description
#' Drop null values.
#' Similar to R syntax x[!(is.na(x) & !is.nan(x))]
#' @return Expr
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
#' @return Expr
#' @examples
#'  pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nans())
Expr_drop_nans = "use_extendr_wrapper"

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



#' Head
#' @keywords Expr
#' @description
#' Get the head n elements.
#' Similar to R head(x)
#' @param n numeric number of elements to select from head
#' @return Expr
#' @examples
#' #get 3 first elements
#' pl$DataFrame(list(x=1:11))$select(pl$col("x")$head(3))
Expr_head = function(n=10) {
  if(!is.numeric(n)) abort("n must be numeric")
  .pr$Expr$head(self,n=n)
}

#' Tail
#' @keywords Expr
#' @description
#' Get the tail n elements.
#' Similar to R tail(x)
#' @param n numeric number of elements to select from tail
#' @return Expr
#' @examples
#' #get 3 last elements
#' pl$DataFrame(list(x=1:11))$select(pl$col("x")$tail(3))
Expr_tail = function(n=10) {
  if(!is.numeric(n)) abort("n must be numeric")
  .pr$Expr$tail(self,n=n)
}


#' is_null
#' @keywords Expr
#' @description
#' Returns a boolean Series indicating which values are null.
#' Similar to R syntax is.na(x)
#' null polars about the same as R NA
#' @return Expr
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
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_not_null())
Expr_is_not_null = "use_extendr_wrapper"


#' max
#' @keywords Expr
#' @description
#' Get maximum value.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$max() == 3) #is true
Expr_max = "use_extendr_wrapper"

#' min
#' @keywords Expr
#' @description
#' Get minimum value.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$min()== 1 ) #is true
Expr_min = "use_extendr_wrapper"

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
  pra = construct_protoArrayExpr(list(...))

  #pass to over
  .pr$Expr$over(self,pra)

}





#' construct proto Expr array from args
#'
#' @param ...  any Expr or string
#'
#' @importFrom rlang is_string
#'
#' @keywords Expr
#'
#' @return ProtoExprArray object
#'
#' @examples construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
construct_ProtoExprArray = function(...) {


  pra = minipolars:::ProtoExprArray$new()
  args = list(...)
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
      abort("not allowed naming expressions, use `set_minipolars_options(named_exprs = TRUE)` to enable column naming by expression")
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







#' Expr_map
#' @keywords Expr
#'
#' @param lambda r function mapping a series
#' @param output_type NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
#'
#' @rdname Expr_map
#' @return Expr
#' @aliases Expr_map
#' @details in minipolars lambda return should be a series or any R vector convertable into a Series. In PyPolars likely return must be Series.
#' @name Expr_map
#' @examples pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) paste("cheese",as.character(x$to_r_vector())),pl$dtypes$Utf8))
Expr_map = function(lambda, output_type=NULL) {
  .pr$Expr$map(self,lambda,output_type, agg_list = FALSE)
}

#' Expr_apply
#' @keywords Expr
#'
#' @description
#'Apply a custom/user-defined function (UDF) in a GroupBy or Projection context.
#'Depending on the context it has the following behavior:
#' -Selection
#'
#'
#' @details
#' Copied from pypolars (revise)
#'Expects f to be of type Callable[[Any], Any]. Applies a python function over each individual value in the column.
#'
#'GroupBy
#'
#'Expects f to be of type Callable[[Series], Series]. Applies a python function over each group.
#'
#'Implementing logic using a Python function is almost always _significantly_ slower and more memory intensive than implementing the same logic using the native expression API because:
#'
#'  The native expression engine runs in Rust; UDFs run in Python.
#'
#'Use of Python UDFs forces the DataFrame to be materialized in memory.
#'
#'Polars-native expressions can be parallelised (UDFs cannot).
#'
#'Polars-native expressions can be logically optimised (UDFs cannot).
#'
#'Wherever possible you should strongly prefer the native expression API to achieve the best performance. @description
#'Apply a custom/user-defined function (UDF) in a GroupBy or Projection context.
#'
#'Depending on the context it has the following behavior:

#'  Selection
#' Expects f to be of type Callable[[Any], Any]. Applies a python function over each individual value in the column.
#'GroupBy
#'
#'Expects f to be of type Callable[[Series], Series]. Applies a python function over each group.
#'
#'Implementing logic using a Python function is almost always _significantly_ slower and more memory intensive than implementing the same logic using the native expression API because:
#'
#'The native expression engine runs in Rust; UDFs run in Python.
#'Use of Python UDFs forces the DataFrame to be materialized in memory.
#'Polars-native expressions can be parallelised (UDFs cannot).
#'Polars-native expressions can be logically optimised (UDFs cannot).
#'Wherever possible you should strongly prefer the native expression API to achieve the best performance.
#' @param f r function mapping a series
#' @param return_type NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
#'
#' @return Expr
#' @aliases Expr_apply
#' @name Expr_apply
#' @examples
#' #apply over groups - normal usage
#' # s is a series of all values for one column within group, here Species
#'e_all =pl$all() #perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")
#'e_sum  = e_all$apply(\(s)  sum(s$to_r()))$suffix("_sum")
#'e_head = e_all$apply(\(s) head(s$to_r(),2))$suffix("_head")
#'pl$DataFrame(iris)$groupby("Species")$agg(e_sum,e_head)
#'
#'
#' #apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time on a 2015 MacBook Pro)
#' #x is an R scalar
#'e_all =pl$col(pl$dtypes$Float64) #perform on all Float64 columns, using pl$all requires user function can handle any input type
#'e_add10  = e_all$apply(\(x)  {x+10})$suffix("_sum")
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
#'system.time({
#'   rdf = df$with_columns(
#'     pl$col("a")$apply(\(x) {
#'      x*2L
#'    })$alias("bob")
#'  )
#'})
#'
#'print("R lapply 1 million values take ~1sec on 2015 MacBook Pro")
#'system.time({
#'  lapply(df$get_column("a")$to_r(),\(x) x*2L )
#'})
#'print("using polars syntax takes ~1ms")
#'system.time({
#'  (df$get_column("a") * 2L)
#'})
#'
#'
#'print("using R vector syntax takes ~4ms")
#'r_vec = df$get_column("a")$to_r()
#'system.time({
#'  r_vec * 2L
#'})
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
#' @param x any R expression yielding an integer, float or bool
#' @rdname Expr
#' @return Expr, literal of that value
#' @aliases lit
#' @name lit
#' @examples pl$col("some_column") / pl$lit(42)
Expr_lit = function(x) {
  unwrap(.pr$Expr$lit(x))
}

#' polars suffix
#' @keywords Expr
#'
#' @param suffix string suffix to be added to a name
#' @rdname Expr
#' @return Expr
#' @aliases suffix
#' @name suffix
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
#' @name prefix
#' @examples pl$col("some")$suffix("_column")
Expr_prefix = function(prefix) {
  .pr$Expr$prefix(self, prefix)
}

#' polars reverse
#' @keywords Expr
#' @rdname Expr
#' @return Expr
#' @aliases reverse
#' @name prefix
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
#' @rdname Expr_and
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
#' @rdname Expr_or
"|.Expr" <- function(e1,e2) e1$or(wrap_e(e2))


#' Xor
#' @name Expr_xor
#' @description combine to boolean expresions with XOR
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @examples
#' pl$lit(TRUE)$xor(pl$lit(FALES))
Expr_xor = "use_extendr_wrapper"

#' is_in
#' @name Expr_is_in
#' @description combine to boolean expresions with similar to `%in%`
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @examples
#'
#' #R Na_integer -> polars Null(Int32) is in polars Null(Int32)
#' pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_real_)))$as_data_frame()[[1]]
#'
#'
#'
Expr_is_in= "use_extendr_wrapper"



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
#' @examples
#' pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_finite())
Expr_is_finite = "use_extendr_wrapper"


#' Are elements infinite
#' @description Returns a boolean output indicating which values are infinite.
#'
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
#' @keywords Expr
#' @return Expr
#' @aliases is_nan
#' @name Expr_is_nan
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
Expr_round = "use_extendr_wrapper"


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
#' @name Expr_sort
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN),
#' ))$select(pl$col("a")$sort())
Expr_sort = function(reverse = FALSE, nulls_last = FALSE) { #param reverse named descending on rust side
  .pr$Expr$sort(self, reverse, nulls_last)
}


#TODO contribute polars, add arguments for Null/NaN/inf last/first, top_k unwraps k> len column
#' Top k values
#' @description  Return the `k` largest elements.
#' If 'reverse=True` the smallest elements will be given.
#' @details  This has time complexity: \eqn{ O(n + k \\log{}n - \frac{k}{2}) }
#' @keywords Expr
#' @param k numeric k top values to get
#' @param reverse bool if true then k smallest values
#' @return Expr
#' @aliases top_k
#' @name Expr_top_k
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN),
#' ))$select(pl$top_k(5))
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
#' @name Expr_arg_sort
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN),
#' ))$select(pl$arg_sort())
Expr_arg_sort = function(reverse = FALSE, nulls_last = FALSE) { #param reverse named descending on rust side
  .pr$Expr$arg_sort(self, reverse, nulls_last)
}


#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @aliases arg_min
#' @name Expr_arg_min
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN),
#' ))$select(pl$arg_min())
Expr_arg_min = "use_extendr_wrapper"

#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @aliases arg_max
#' @name Expr_arg_max
#' @format a method
#' @examples
#' df = pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN),
#' ))$select(pl$arg_max())
Expr_arg_max = "use_extendr_wrapper"



#' Wrap column in list
#' @description  Aggregate to list.
#' @keywords Expr
#' @return Expr
#' @aliases list
#' @name Expr_list
#' @format a method
Expr_list = "use_extendr_wrapper"






