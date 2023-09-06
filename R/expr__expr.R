#' @title Polars Expressions
#'
#' @name Expr_class
#' @return not applicable
#' @description Expressions are all the functions and methods that are applicable
#' to a Polars DataFrame. They can be split into the following categories (following
#' the [Py-Polars classification](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/)):
#'  * Aggregate
#'  * Binary
#'  * Categorical
#'  * Computation
#'  * Functions
#'  * List
#'  * Meta
#'  * String
#'  * Struct
#'  * Temporal
#'
NULL


#' Print expr
#'
#' @param x Expr
#' @param ... not used
#' @keywords Expr
#'
#' @return self
#' @export
#' @keywords internal
#'
#' @examples
#' pl$col("some_column")$sum()$over("some_other_column")
print.Expr = function(x, ...) {
  cat("polars Expr: ")
  x$print()
  invisible(x)
}

#' internal method print Expr
#' @name Expr_print
#' @keywords Expr
#' @examples
#' pl$col("some_column")$sum()$over("some_other_column")$print()
#' @return invisible self
#' @examples pl$DataFrame(iris)
Expr_print = function() {
  .pr$Expr$print(self)
  invisible(self)
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x Expr
#' @param pattern code-stump as string to auto-complete
#' @inherit .DollarNames.DataFrame return
#' @export
#' @keywords internal
.DollarNames.Expr = function(x, pattern = "") {
  paste0(ls(Expr, pattern = pattern), "()")
}

#' @title as.list Expr
#' @description wraps an Expr in a list
#' @param x Expr
#' @param ... not used
#' @return One Expr wrapped in a list
#' @export
#' @keywords Expr
as.list.Expr = function(x, ...) {
  list(x)
}

#' DEPRECATED wrap as literal
#' @description use robj_to!(Expr) on rust side or rarely wrap_e on R-side
#' This function is only kept for reference
#' @param e an Expr(polars) or any R expression
#' @details
#' used internally to ensure an object is an expression
#' @keywords internal
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e_legacy = function(e, str_to_lit = TRUE) {
  if (inherits(e, "Expr")) {
    return(e)
  }
  # terminate WhenThen's to yield an Expr
  if (inherits(e, c("Then", "ChainedThen"))) {
    return(e$otherwise(pl$lit(NULL)))
  }
  if (inherits(e, c("When", "ChainedWhen"))) {
    return(stopf("Cannot use a When-statement as Expr without a $then()"))
  }
  if (str_to_lit || is.numeric(e) || is.list(e) || is_bool(e)) {
    return(pl$lit(e))
  } else {
    pl$col(e)
  }
}

#' wrap as literal
#' @description use robj_to!(Expr) on rust side or rarely wrap_e on R-side
#' This function is only kept for reference
#' @param e an Expr(polars) or any R expression
#' @details
#' used internally to ensure an object is an expression
#' @keywords internal
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e = function(e, str_to_lit = TRUE) {
  internal_wrap_e(e, str_to_lit) |> unwrap()
}


## TODO refactor to \(e, str_to_lit = TRUE, argname = NULL) wrap_e(e) |> result()

#' wrap as Expression capture ok/err as result
#' @param e an Expr(polars) or any R expression
#' @param str_to_lit bool should string become a column name or not, then a literal string
#' @param argname if error, blame argument of this name
#' @details
#' used internally to ensure an object is an expression and to catch any error
#' @keywords internal
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e_result = function(e, str_to_lit = TRUE, argname = NULL) {
  # disable call info
  old_option = pl$set_polars_options(do_not_repeat_call = TRUE)

  # wrap_e and catch nay error in a result
  expr_result = result(
    wrap_e(e, str_to_lit),
    paste(
      {
        if (!is.null(argname)) paste0("argument [", argname, "]") else NULL
      },
      "not convertible into Expr because:\n"
    )
  )

  # restore options
  do.call(pl$set_polars_options, old_option)

  expr_result
}

#' internal wrap_elist_result
#' @noRd
#' @description make sure all elements of a list is wrapped as Expr
#' DEPRECATED:  prefer robj_to!(VecPlExpr) on rust side
#' Capture any conversion error in the result
#' @param elist a list Expr or any R object `Into<Expr>` (passable to pl$lit)
#' @details
#' Used internally to ensure an object is a list of expression
#' The output is wrapped in a result, which can contain an ok or
#' err value.
#' @keywords internal
#' @return Expr
#' @examples .pr$env$wrap_elist_result(list(pl$lit(42), 42, 1:3))
wrap_elist_result = function(elist, str_to_lit = TRUE) {
  element_i = 0L
  result(
    {
      if (!is.list(elist) && length(elist) == 1L) elist <- list(elist)
      lapply(elist, \(e) {
        element_i <<- element_i + 1L
        wrap_e(e, str_to_lit)
      })
    },
    msg = if (element_i >= 1L) {
      paste0("element [[", element_i, "]] of sequence not convertible into an Expr, error in:\n")
    } else {
      paste0(str_string(elist), " was not convertible into a list of Expr, error in:\n")
    }
  )
}


#' Add
#' @description Addition
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' # three syntaxes same result
#' pl$lit(5) + 10
#' pl$lit(5) + pl$lit(10)
#' pl$lit(5)$add(pl$lit(10))
#' +pl$lit(5) # unary use resolves to same as pl$lit(5)
Expr_add = function(other) {
  .pr$Expr$add(self, other) |> unwrap("in $add()")
}
#' @export
#' @rdname Expr_add
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
"+.Expr" = function(e1, e2) {
  if (missing(e2)) {
    return(e1)
  }
  result(wrap_e(e1)$add(e2)) |> unwrap("using the '+'-operator")
}

#' Div
#' @description Divide
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' # three syntaxes same result
#' pl$lit(5) / 10
#' pl$lit(5) / pl$lit(10)
#' pl$lit(5)$div(pl$lit(10))
Expr_div = function(other) {
  .pr$Expr$div(self, other) |> unwrap("in $div()")
}
#' @export
#' @rdname Expr_div
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
"/.Expr" = function(e1, e2) result(wrap_e(e1)$div(e2)) |> unwrap("using the '/'-operator")

#' Sub
#' @description Substract
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' # three syntaxes same result
#' pl$lit(5) - 10
#' pl$lit(5) - pl$lit(10)
#' pl$lit(5)$sub(pl$lit(10))
#' -pl$lit(5)
Expr_sub = function(other) {
  .pr$Expr$sub(self, other) |> unwrap("in $sub()")
}
#' @export
#' @rdname Expr_sub
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
"-.Expr" = function(e1, e2) {
  result(
    if (missing(e2)) wrap_e(0L)$sub(e1) else wrap_e(e1)$sub(e2)
  ) |> unwrap("using the '-'-operator")
}

#' Mul *
#' @description Multiplication
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' # three syntaxes same result
#' pl$lit(5) * 10
#' pl$lit(5) * pl$lit(10)
#' pl$lit(5)$mul(pl$lit(10))
Expr_mul = Expr_mul = function(other) {
  .pr$Expr$mul(self, other) |> unwrap("in $mul()")
}

#' @export
#' @rdname Expr_mul
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
"*.Expr" = function(e1, e2) result(wrap_e(e1)$mul(e2)) |> unwrap("using the '*'-operator")


#' Not !
#' @description not method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @usage Expr_is_not(other)
#' @docType NULL
#' @format NULL
#' @examples
#' # two syntaxes same result
#' pl$lit(TRUE)$is_not()
#' !pl$lit(TRUE)
Expr_is_not = "use_extendr_wrapper"
#' @export
#' @rdname Expr_is_not
#' @param x Expr
"!.Expr" = function(x) x$is_not()

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
Expr_lt = function(other) {
  .pr$Expr$lt(self, other) |> unwrap("in $lt()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_lt
"<.Expr" = function(e1, e2) result(wrap_e(e1)$lt(e2)) |> unwrap("using the '<'-operator")

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
Expr_gt = function(other) {
  .pr$Expr$gt(self, other) |> unwrap("in $gt()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_gt
">.Expr" = function(e1, e2) result(wrap_e(e1)$gt(e2)) |> unwrap("using the '>'-operator")

#' Equal ==
#' @description eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) == 2
#' pl$lit(2) == pl$lit(2)
#' pl$lit(2)$eq(pl$lit(2))
Expr_eq = function(other) {
  .pr$Expr$eq(self, other) |> unwrap("in $eq()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_eq
"==.Expr" = function(e1, e2) result(wrap_e(e1)$eq(e2)) |> unwrap("using the '=='-operator")


#' Not Equal !=
#' @description neq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(1) != 2
#' pl$lit(1) != pl$lit(2)
#' pl$lit(1)$neq(pl$lit(2))
Expr_neq = function(other) {
  .pr$Expr$neq(self, other) |> unwrap("in $neq()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_neq
"!=.Expr" = function(e1, e2) result(wrap_e(e1)$neq(e2)) |> unwrap("using the '!='-operator")

#' Less Than Or Equal <=
#' @description lt_eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) <= 2
#' pl$lit(2) <= pl$lit(2)
#' pl$lit(2)$lt_eq(pl$lit(2))
Expr_lt_eq = function(other) {
  .pr$Expr$lt_eq(self, other) |> unwrap("in $lt_eq()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_lt_eq
"<=.Expr" = function(e1, e2) result(wrap_e(e1)$lt_eq(e2)) |> unwrap("using the '<='-operator")


#' Greater Than Or Equal <=
#' @description gt_eq method and operator
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Exprs
#' @examples
#' #' #three syntaxes same result
#' pl$lit(2) >= 2
#' pl$lit(2) >= pl$lit(2)
#' pl$lit(2)$gt_eq(pl$lit(2))
Expr_gt_eq = function(other) {
  .pr$Expr$gt_eq(self, other) |> unwrap("in $gt_eq()")
}
#' @export
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @param e1 lhs Expr
#' @param e2 rhs Expr or anything which can become a literal Expression
#' @rdname Expr_gt_eq
">=.Expr" = function(e1, e2) result(wrap_e(e1)$gt_eq(e2)) |> unwrap("using the '>='-operator")



#' aggregate groups
#' @keywords Expr
#' @description
#' Get the group indexes of the group by operation.
#' Should be used in aggregation context only.
#' @return Exprs
#' @docType NULL
#' @format NULL
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("one", "one", "one", "two", "two", "two"),
#'   value = c(94, 95, 96, 97, 97, 99)
#' ))
#' df$groupby("group", maintain_order = TRUE)$agg(pl$col("value")$agg_groups())
Expr_agg_groups = "use_extendr_wrapper"


#' Rename Expr output
#' @keywords Expr
#' @description
#' Rename the output of an expression.
#' @param name string new name of output
#' @return Expr
#' @docType NULL
#' @format NULL
#' @usage Expr_alias(name)
#' @examples pl$col("bob")$alias("alice")
Expr_alias = "use_extendr_wrapper"

#' All, is true
#' @keywords Expr
#' @description
#' Check if all boolean values in a Boolean column are `TRUE`.
#' This method is an expression - not to be confused with
#' `pl$all` which is a function to select all columns.
#' @aliases Expr_all
#' @param drop_nulls Boolean. Default TRUE, as name says.
#' @return Boolean literal
#' @docType NULL
#' @format NULL
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#' @examples
#' pl$DataFrame(
#'   all = c(TRUE, TRUE),
#'   any = c(TRUE, FALSE),
#'   none = c(FALSE, FALSE)
#' )$select(
#'   pl$all()$all()
#' )
Expr_all = function(drop_nulls = TRUE) {
  .pr$Expr$all(self, drop_nulls) |>
    unwrap("in $all()")
}

#' Any (is true)
#' @keywords Expr
#' @description
#' Check if any boolean value in a Boolean column is `TRUE`.
#' @param drop_nulls Boolean. Default TRUE, as name says.
#' @return Boolean literal
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   all = c(TRUE, TRUE),
#'   any = c(TRUE, FALSE),
#'   none = c(FALSE, FALSE)
#' )$select(
#'   pl$all()$any()
#' )
Expr_any = function(drop_nulls = TRUE) {
  .pr$Expr$any(self, drop_nulls) |>
    unwrap("in $all()")
}



#' Count values (len is a alias)
#' @keywords Expr
#' @name Expr_count
#' @description
#' Count the number of values in this expression.
#' Similar to R length()
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   all = c(TRUE, TRUE),
#'   any = c(TRUE, FALSE),
#'   none = c(FALSE, FALSE)
#' )$select(
#'   pl$all()$count()
#' )
Expr_count = "use_extendr_wrapper"

#' Count values (len is a alias)
#' @keywords Expr
#' @rdname Expr_count
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   all = c(TRUE, TRUE),
#'   any = c(TRUE, FALSE),
#'   none = c(FALSE, FALSE)
#' )$select(
#'   pl$all()$len(),
#'   pl$col("all")$first()$len()$alias("all_first")
#' )
Expr_len = "use_extendr_wrapper"



#' Drop null(s)
#' @keywords Expr
#' @description
#' Drop null values.
#' Similar to R syntax `x[!(is.na(x) & !is.nan(x))]`
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, 2, NaN, NA)))$select(pl$col("x")$drop_nulls())
Expr_drop_nulls = "use_extendr_wrapper"

#' Drop NaN(s)
#' @keywords Expr
#' @description
#' Drop floating point NaN values.
#' Similar to R syntax `x[!is.nan(x)]`
#' @details
#'
#'  Note that NaN values are not null values! (null corresponds to R NA, not R NULL)
#'  To drop null values, use method `drop_nulls`.
#'
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, 2, NaN, NA)))$select(pl$col("x")$drop_nans())
Expr_drop_nans = "use_extendr_wrapper"





#' is_null
#' @keywords Expr
#' @description
#' Returns a boolean Series indicating which values are null.
#' Similar to R syntax is.na(x)
#' null polars about the same as R NA
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$is_null())
Expr_is_null = "use_extendr_wrapper"

#' is_not_null
#' @keywords Expr
#' @description
#' Returns a boolean Series indicating which values are not null.
#' Similar to R syntax !is.na(x)
#' null polars about the same as R NA
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$is_not_null())
Expr_is_not_null = "use_extendr_wrapper"






# TODO move this function in to rust with input list of args
# TODO deprecate context feature
#' construct proto Expr array from args
#' @noRd
#' @param ...  any Expr or string
#'
#'
#' @keywords internal
#'
#' @return ProtoExprArray object
#'
#' @examples .pr$env$construct_ProtoExprArray(pl$col("Species"), "Sepal.Width")
construct_ProtoExprArray = function(...) {
  pra = ProtoExprArray$new()
  args = list2(...)

  # deal with list of expressions
  is_list = which(vapply(args, is.list, FUN.VALUE = logical(1L)))
  for (i in seq_along(is_list)) {
    tmp = unlist(args[[is_list[i]]], recursive = FALSE)
    args[[is_list[i]]] = NULL
    args = append(tmp, args)
  }
  args = Filter(Negate(is.null), args)

  arg_names = names(args)


  # if args not named load in Expr and string
  if (is.null(arg_names)) {
    if (length(args) == 1 && is.list(args)) {
      args = unlist(args)
    }
    for (i in args) {
      # if (is_string(i)) {
      #   pra$push_back_str(i)
      #   next
      # }
      pra$push_back_rexpr(wrap_e(i, str_to_lit = FALSE))
    }

    # if args named, convert string to col and alias any column by name if a name
  } else {
    for (i in seq_along(args)) {
      arg = args[[i]]
      name = arg_names[i]

      expr = wrap_e(arg, str_to_lit = FALSE)


      if (nchar(name) >= 1L) {
        expr = expr$alias(name)
      }
      pra$push_back_rexpr(expr) # rust method
    }
  }



  pra
}





## TODO allow list to be formed from recursive R lists
## TODO Contribute polars, seems polars now prefer word f or function in map/apply/rolling/apply
# over lambda. However lambda is still in examples.
## TODO Better explain aggregate list
#' Map an expression with an R function.
#' @keywords Expr
#'
#' @param f a function to map with
#' @param output_type NULL or one of pl$dtypes$..., the output datatype, NULL is the same as input.
#' This is used to inform schema of the actual return type of the R function. Setting this wrong
#' could theoretically have some downstream implications to the query.
#' @param agg_list Aggregate list. Map from vector to group in groupby context.
#' @param in_background Boolean. Whether to execute the map in a background R process. Combined wit
#' setting e.g. `pl$set_global_rpool_cap(4)` it can speed up some slow R functions as they can run
#' in parallel R sessions. The communication speed between processes is quite slower than between
#' threads. Will likely only give a speed-up in a "low IO - high CPU" usecase. A single map will not
#' be paralleled, only in case of multiple `$map`(s) in the query these can be run in parallel.
#'
#' @return Expr
#' @details Sometime some specific R function is just necessary to perform a column transformation.
#' Using R maps is slower than native polars. User function must take one polars `Series` as input
#' and the return should be a `Series` or any Robj convertible into a `Series` (e.g. vectors).
#' Map fully supports `browser()`. If `in_background = FALSE` the function can access any global
#' variable of the R session. But all R maps in the query sequentially share the same main R
#' session. Any native polars computations can still be executed meanwhile. In
#' `in_background = TRUE` the map will run in one or more other R sessions and will not have access
#' to global variables. Use `pl$set_global_rpool_cap(4)` and `pl$get_global_rpool_cap()` to see and
#' view number of parallel R sessions.
#' @name Expr_map
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) {
#'   paste("cheese", as.character(x$to_vector()))
#' }, pl$dtypes$Utf8))
#'
#' # R parallel process example, use Sys.sleep() to imitate some CPU expensive computation.
#'
#' # map a,b,c,d sequentially
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map(\(s) {
#'     Sys.sleep(.5)
#'     s * 2
#'   })
#' )$collect() |> system.time()
#'
#' # map in parallel 1: Overhead to start up extra R processes / sessions
#' pl$set_global_rpool_cap(0) # drop any previous processes, just to show start-up overhead
#' pl$set_global_rpool_cap(4) # set back to 4, the default
#' pl$get_global_rpool_cap()
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map(\(s) {
#'     Sys.sleep(.5)
#'     s * 2
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
#'
#' # map in parallel 2: Reuse R processes in "polars global_rpool".
#' pl$get_global_rpool_cap()
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map(\(s) {
#'     Sys.sleep(.5)
#'     s * 2
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
#'
Expr_map = function(f, output_type = NULL, agg_list = FALSE, in_background = FALSE) {
  map_fn = ifelse(in_background, .pr$Expr$map_in_background, .pr$Expr$map)
  map_fn(self, f, output_type, agg_list)
}

#' Expr_apply
#' @keywords Expr
#'
#' @description
#' Apply a custom/user-defined function (UDF) in a GroupBy or Projection context.
#' Depending on the context it has the following behavior:
#' -Selection
#'
#' @param f r function see details depending on context
#' @param return_type NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
#' @param strict_return_type bool (default TRUE), error if not correct datatype returned from R,
#' if FALSE will convert to a Polars Null and carry on.
#' @param allow_fail_eval  bool (default FALSE), if TRUE will not raise user function error
#' but convert result to a polars Null and carry on.
#' @param in_background Boolean. Whether to execute the map in a background R process. Combined wit
#' setting e.g. `pl$set_global_rpool_cap(4)` it can speed up some slow R functions as they can run
#' in parallel R sessions. The communication speed between processes is quite slower than between
#' threads. Will likely only give a speed-up in a "low IO - high CPU" usecase. A single map will not
#' be paralleled, only in case of multiple `$map`(s) in the query these can be run in parallel.
#'
#' @details
#'
#' Apply a user function in a groupby or projection(select) context
#'
#'
#' Depending on context the following behavior:
#'
#' * Projection/Selection:
#'  Expects an `f` to operate on R scalar values.
#'  Polars will convert each element into an R value and pass it to the function
#'  The output of the user function will be converted back into a polars type.
#'  Return type must match. See param return type.
#'  Apply in selection context should be avoided as a `lapply()` has half the overhead.
#'
#' * Groupby
#'   Expects a user function `f` to take a `Series` and return a `Series` or Robj convertible to
#'   `Series`, eg. R vector. GroupBy context much faster if number groups are quite fewer than
#'   number of rows, as the iteration is only across the groups.
#'   The r user function could e.g. do vectorized operations and stay quite performant.
#'   use `s$to_r()` to convert input Series to an r vector or list. use `s$to_vector` and
#'   `s$to_r_list()` to force conversion to vector or list.
#'
#'  Implementing logic using an R function is almost always _significantly_
#'   slower and more memory intensive than implementing the same logic using
#'   the native expression API because:
#'     - The native expression engine runs in Rust; functions run in R.
#'     - Use of R functions forces the DataFrame to be materialized in memory.
#'     - Polars-native expressions can be parallelized (R functions cannot*).
#'     - Polars-native expressions can be logically optimized (R functions cannot).
#'   Wherever possible you should strongly prefer the native expression API
#'   to achieve the best performance.
#'
#' @return Expr
#' @aliases Expr_apply
#' @examples
#' # apply over groups - normal usage
#' # s is a series of all values for one column within group, here Species
#' e_all = pl$all() # perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")
#' e_sum = e_all$apply(\(s)  sum(s$to_r()))$suffix("_sum")
#' e_head = e_all$apply(\(s) head(s$to_r(), 2))$suffix("_head")
#' pl$DataFrame(iris)$groupby("Species")$agg(e_sum, e_head)
#'
#'
#' # apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time
#' # on a 2015 MacBook Pro) x is an R scalar
#'
#' # perform on all Float64 columns, using pl$all requires user function can handle any input type
#' e_all = pl$col(pl$dtypes$Float64)
#' e_add10 = e_all$apply(\(x)  {
#'   x + 10
#' })$suffix("_sum")
#' # quite silly index into alphabet(letters) by ceil of float value
#' # must set return_type as not the same as input
#' e_letter = e_all$apply(\(x) letters[ceiling(x)], return_type = pl$dtypes$Utf8)$suffix("_letter")
#' pl$DataFrame(iris)$select(e_add10, e_letter)
#'
#'
#' ## timing "slow" apply in select /with_columns context, this makes apply
#' n = 1000000L
#' set.seed(1)
#' df = pl$DataFrame(list(
#'   a = 1:n,
#'   b = sample(letters, n, replace = TRUE)
#' ))
#'
#' print("apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro")
#' system.time({
#'   rdf = df$with_columns(
#'     pl$col("a")$apply(\(x) {
#'       x * 2L
#'     })$alias("bob")
#'   )
#' })
#'
#' print("R lapply 1 million values take ~1sec on 2015 MacBook Pro")
#' system.time({
#'   lapply(df$get_column("a")$to_r(), \(x) x * 2L)
#' })
#' print("using polars syntax takes ~1ms")
#' system.time({
#'   (df$get_column("a") * 2L)
#' })
#'
#'
#' print("using R vector syntax takes ~4ms")
#' r_vec = df$get_column("a")$to_r()
#' system.time({
#'   r_vec * 2L
#' })
#'
#' #' #R parallel process example, use Sys.sleep() to imitate some CPU expensive computation.
#'
#' # use apply over each Species-group in each column equal to 12 sequential runs ~1.2 sec.
#' pl$LazyFrame(iris)$groupby("Species")$agg(
#'   pl$all()$apply(\(s) {
#'     Sys.sleep(.1)
#'     s$sum()
#'   })
#' )$collect() |> system.time()
#'
#' # map in parallel 1: Overhead to start up extra R processes / sessions
#' pl$set_global_rpool_cap(0) # drop any previous processes, just to show start-up overhead here
#' pl$set_global_rpool_cap(4) # set back to 4, the default
#' pl$get_global_rpool_cap()
#' pl$LazyFrame(iris)$groupby("Species")$agg(
#'   pl$all()$apply(\(s) {
#'     Sys.sleep(.1)
#'     s$sum()
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
#'
#' # map in parallel 2: Reuse R processes in "polars global_rpool".
#' pl$get_global_rpool_cap()
#' pl$LazyFrame(iris)$groupby("Species")$agg(
#'   pl$all()$apply(\(s) {
#'     Sys.sleep(.1)
#'     s$sum()
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
#'
Expr_apply = function(f, return_type = NULL, strict_return_type = TRUE, allow_fail_eval = FALSE, in_background = FALSE) {
  if (in_background) {
    return(.pr$Expr$apply_in_background(self, f, return_type))
  }

  # use series apply
  wrap_f = function(s) {
    s$apply(f, return_type, strict_return_type, allow_fail_eval)
  }

  # return expression from the functions above, activate agg_list (grouped mapping)
  .pr$Expr$map(self, lambda = wrap_f, output_type = return_type, agg_list = TRUE)
}


#' polars literal
#' @keywords Expr
#'
#' @param x an R Scalar, or R vector/list (via Series) into Expr
#' @rdname Expr
#' @return Expr, literal of that value
#' @aliases lit
#' @name Expr_lit
#' @details pl$lit(NULL) translates into a typeless polars Null
#' @examples
#' # scalars to literal, explit `pl$lit(42)` implicit `+ 2`
#' pl$col("some_column") / pl$lit(42) + 2
#'
#' # vector to literal explicitly via Series and back again
#' # R vector to expression and back again
#' pl$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]]
#'
#' # r vecot to literal and back r vector
#' pl$lit(1:4)$to_r()
#'
#' # r vector to literal to dataframe
#' pl$select(pl$lit(1:4))
#'
#' # r vector to literal to Series
#' pl$lit(1:4)$lit_to_s()
#'
#' # vectors to literal implicitly
#' (pl$lit(2) + 1:4) / 4:1
Expr_lit = function(x) {
  .Call(wrap__Expr__lit, x) |> # use .call reduces eval from 22us to 15us, not a bottle-next anyways
    unwrap("in $lit()")
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
#' @examples pl$DataFrame(list(a = 1:5))$select(pl$col("a")$reverse())
Expr_reverse = function() {
  .pr$Expr$reverse(self)
}



#' And
#' @name Expr_and
#' @description combine to boolean expressions with AND
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @docType NULL
#' @format NULL
#' @usage Expr_and(other)
#' @examples
#' pl$lit(TRUE) & TRUE
#' pl$lit(TRUE)$and(pl$lit(TRUE))
Expr_and = function(other) {
  .pr$Expr$and(self, other) |> unwrap("in $and()")
}
#' @export
"&.Expr" = function(e1, e2) result(wrap_e(e1)$and(e2)) |> unwrap("using the '&'-operator")


#' Or
#' @name Expr_or
#' @description combine to boolean expressions with OR
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @docType NULL
#' @format NULL
#' @param other Expr or into Expr
#' @usage Expr_or(other)
#' @examples
#' pl$lit(TRUE) | FALSE
#' pl$lit(TRUE)$or(pl$lit(TRUE))
Expr_or = function(other) {
  .pr$Expr$or(self, other) |> unwrap("in $or()")
}
#' @export
"|.Expr" = function(e1, e2) result(wrap_e(e1)$or(e2)) |> unwrap("using the '|'-operator")


#' Xor
#' @name Expr_xor
#' @description combine to boolean expressions with XOR
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @docType NULL
#' @format NULL
#' @usage Expr_xor(other)
#' @examples
#' pl$lit(TRUE)$xor(pl$lit(FALSE))
Expr_xor = function(other) {
  .pr$Expr$xor(self, other) |> unwrap("in $xor()")
}



#' To physical representation
#' @description expression request underlying physical base representation
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases to_physical
#' @name Expr_to_physical
#' @examples
#' pl$DataFrame(
#'   list(vals = c("a", "x", NA, "a"))
#' )$with_columns(
#'   pl$col("vals")$cast(pl$Categorical),
#'   pl$col("vals")
#'   $cast(pl$Categorical)
#'   $to_physical()
#'   $alias("vals_physical")
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
#' df = pl$DataFrame(a = 1:3, b = c(1, 2, 3))
#' df$print()$with_columns(
#'   pl$col("a")$cast(pl$dtypes$Float64),
#'   pl$col("b")$cast(pl$dtypes$Int32)
#' )
#'
#' # strict FALSE, inserts null for any cast failure
#' pl$lit(c(100, 200, 300))$cast(pl$dtypes$UInt8, strict = FALSE)$lit_to_s()
#'
#'
#' # strict TRUE, raise any failure as an error when query is executed.
#' tryCatch(
#'   {
#'     pl$lit("a")$cast(pl$dtypes$Float64, strict = TRUE)$lit_to_s()
#'   },
#'   error = as.character
#' )
Expr_cast = function(dtype, strict = TRUE) {
  .pr$Expr$cast(self, dtype, strict)
}



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





#' Compute the exponential, element-wise.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases exp
#' @name Expr_exp
#' @format NULL
#' @examples
#' log10123 = suppressWarnings(log(-1:3))
#' all.equal(
#'   pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$to_data_frame()$a,
#'   exp(1)^log10123
#' )
Expr_exp = "use_extendr_wrapper"


#' Exclude certain columns from a wildcard/regex selection.
#' @description You may also use regexes in the exclude list. They must start with `^` and end with `$`.
#' @param columns given param type:
#'  - string: exclude name of column or exclude regex starting with ^and ending with$
#'  - character vector: exclude all these column names, no regex allowed
#'  - DataType: Exclude any of this DataType
#'  - List(DataType): Exclude any of these DataType(s)
#'
#' @keywords Expr
#' @return Expr
#' @aliases exclude
#' @name Expr_exclude
#' @examples
#'
#' # make DataFrame
#' df = pl$DataFrame(iris)
#'
#' # by name(s)
#' df$select(pl$all()$exclude("Species"))
#'
#' # by type
#' df$select(pl$all()$exclude(pl$Categorical))
#' df$select(pl$all()$exclude(list(pl$Categorical, pl$Float64)))
#'
#' # by regex
#' df$select(pl$all()$exclude("^Sepal.*$"))
#'
Expr_exclude = function(columns) {
  # handle lists
  if (is.list(columns)) {
    columns = pcase(
      all(sapply(columns, inherits, "RPolarsDataType")), unwrap(.pr$DataTypeVector$from_rlist(columns)),
      all(sapply(columns, is_string)), unlist(columns),
      or_else = pstop(err = paste0("only lists of pure RPolarsDataType or String"))
    )
  }

  # dispatch exclude call on types
  pcase(
    is.character(columns), .pr$Expr$exclude(self, columns),
    inherits(columns, "DataTypeVector"), .pr$Expr$exclude_dtype(self, columns),
    inherits(columns, "RPolarsDataType"), .pr$Expr$exclude_dtype(self, unwrap(.pr$DataTypeVector$from_rlist(list(columns)))),
    or_else = pstop(err = paste0("this type is not supported for Expr_exclude: ", columns))
  )
}


# TODO contribute pypolars keep_name example does not showcase an example where the name changes
#' Keep the original root name of the expression.
#'
#' @keywords Expr
#' @return Expr
#' @aliases keep_name
#' @name Expr_keep_name
#' @docType NULL
#' @format NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(pl$col("alice")$alias("bob")$keep_name())
Expr_keep_name = "use_extendr_wrapper"



# TODO contribute polars, map_alias unwrap user function errors instead of passing them back
#' Map alias of expression with an R function
#'
#' @param fun an R function which takes a string as input and return a string
#'
#' @description Rename the output of an expression by mapping a function over the root name.
#' @keywords Expr
#' @return Expr
#' @aliases map_alias
#' @name Expr_map_alias
#' @examples
#' pl$DataFrame(list(alice = 1:3))$select(
#'   pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x, "_and_bob"))
#' )
Expr_map_alias = function(fun) {
  if (
    !polars_optenv$no_messages &&
      !exists(".warn_map_alias", envir = runtime_state)
  ) {
    assign(".warn_map_alias", 1L, envir = runtime_state)
    # it does not seem map alias is executed multi-threaded but rather immediately during building lazy query
    # if ever crashing, any lazy method like select, filter, with_columns must use something like filter_with_r_func_support()
    message("map_alias function is experimentally without some thread-safeguards, please report any crashes") # TODO resolve
  }
  if (!is.function(fun)) pstop(err = "alias_map fun must be a function")
  if (length(formals(fun)) == 0) pstop(err = "alias_map fun must take at least one parameter")
  .pr$Expr$map_alias(self, fun)
}



#' Are elements finite
#' @description Returns a boolean output indicating which values are finite.
#'
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_finite
#' @name Expr_is_finite
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$select(pl$col("alice")$is_finite())
Expr_is_finite = "use_extendr_wrapper"


#' Are elements infinite
#' @description Returns a boolean output indicating which values are infinite.
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_infinite
#' @name Expr_is_infinite
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$select(pl$col("alice")$is_infinite())
Expr_is_infinite = "use_extendr_wrapper"





#' Are elements NaN's
#' @description Returns a boolean Series indicating which values are NaN.
#' @details  Floating point NaN's are a different flag from Null(polars) which is the same as
#'  NA_real_(R).
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_nan
#' @name Expr_is_nan
#'
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$select(pl$col("alice")$is_nan())
Expr_is_nan = "use_extendr_wrapper"


#' Are elements not NaN's
#' @description Returns a boolean Series indicating which values are not NaN.
#' @details  Floating point NaN's are a different flag from Null(polars) which is the same as
#'  NA_real_(R).
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_not_nan
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @name Expr_is_not_nan
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$select(pl$col("alice")$is_not_nan())
Expr_is_not_nan = "use_extendr_wrapper"



#' Get a slice of this expression.
#'
#' @param offset numeric or expression, zero-indexed where to start slice
#' negative value indicate starting (one-indexed) from back
#' @param length how many elements should slice contain, default NULL is max length
#'
#' @keywords Expr
#' @return Expr
#' @aliases slice
#' @name Expr_slice
#' @format NULL
#' @examples
#'
#' # as head
#' pl$DataFrame(list(a = 0:100))$select(
#'   pl$all()$slice(0, 6)
#' )
#'
#' # as tail
#' pl$DataFrame(list(a = 0:100))$select(
#'   pl$all()$slice(-6, 6)
#' )
#'
#' pl$DataFrame(list(a = 0:100))$select(
#'   pl$all()$slice(80)
#' )
Expr_slice = function(offset, length = NULL) {
  .pr$Expr$slice(self, wrap_e(offset), wrap_e(length))
}


#' Append expressions
#' @description This is done by adding the chunks of `other` to this `output`.
#'
#' @param other Expr, into Expr
#' @param upcast bool upcast to, if any supertype of two non equal datatypes.
#'
#' @keywords Expr
#' @return Expr
#' @aliases Expr_append
#' @name Expr_append
#' @format NULL
#' @examples
#' # append bottom to to row
#' df = pl$DataFrame(list(a = 1:3, b = c(NA_real_, 4, 5)))
#' df$select(pl$all()$head(1)$append(pl$all()$tail(1)))
#'
#' # implicit upcast, when default = TRUE
#' pl$DataFrame(list())$select(pl$lit(42)$append(42L))
#' pl$DataFrame(list())$select(pl$lit(42)$append(FALSE))
#' pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE))
Expr_append = function(other, upcast = TRUE) {
  .pr$Expr$append(self, wrap_e(other), upcast)
}


#' Rechunk memory layout
#' @description Create a single chunk of memory for this Series.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases rechunk
#' @name Expr_rechunk
#' @format NULL
#' @details
#' See rechunk() explained here \code{\link[polars]{docs_translations}}
#' @examples
#' # get chunked lengths with/without rechunk
#' series_list = pl$DataFrame(list(a = 1:3, b = 4:6))$select(
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
#' @aliases Expr_cumsum
#' @name Expr_cumsum
#' @details
#' Dtypes in {Int8, UInt8, Int16, UInt16} are cast to
#' Int64 before summing to prevent overflow issues.
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 1:4))$select(
#'   pl$col("a")$cumsum()$alias("cumsum"),
#'   pl$col("a")$cumsum(reverse = TRUE)$alias("cumsum_reversed")
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
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 1:4))$select(
#'   pl$col("a")$cumprod()$alias("cumprod"),
#'   pl$col("a")$cumprod(reverse = TRUE)$alias("cumprod_reversed")
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
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 1:4))$select(
#'   pl$col("a")$cummin()$alias("cummin"),
#'   pl$col("a")$cummin(reverse = TRUE)$alias("cummin_reversed")
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
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 1:4))$select(
#'   pl$col("a")$cummax()$alias("cummux"),
#'   pl$col("a")$cummax(reverse = TRUE)$alias("cummax_reversed")
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
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 1:4))$select(
#'   pl$col("a")$cumcount()$alias("cumcount"),
#'   pl$col("a")$cumcount(reverse = TRUE)$alias("cumcount_reversed")
#' )
Expr_cumcount = function(reverse = FALSE) {
  .pr$Expr$cumcount(self, reverse)
}


#' Floor
#' @description Rounds down to the nearest integer value.
#' Only works on floating point Series.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases Expr_floor
#' @name Expr_floor
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf)
#' ))$select(
#'   pl$col("a")$floor()
#' )
Expr_floor = "use_extendr_wrapper"

#' Ceiling
#' @description Rounds up to the nearest integer value.
#' Only works on floating point Series.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases Expr_ceil
#' @name Expr_ceil
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf)
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
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf)
#' ))$select(
#'   pl$col("a")$round(0)
#' )
Expr_round = function(decimals) {
  unwrap(.pr$Expr$round(self, decimals))
}


# TODO contribute polars, dot product unwraps if datatypes, pass Result instead
#' Dot product
#' @description Compute the dot/inner product between two Expressions.
#' @keywords Expr
#' @param other Expr to compute dot product with.
#' @return Expr
#' @aliases dot
#' @name Expr_dot
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   a = 1:4, b = c(1, 2, 3, 4), c = "bob"
#' )$select(
#'   pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
#'   pl$col("a")$dot(pl$col("a"))$alias("a dot a")
#' )
Expr_dot = function(other) {
  .pr$Expr$dot(self, wrap_e(other))
}


#' Mode
#' @description Compute the most occurring value(s). Can return multiple Values.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases mode
#' @name Expr_mode
#' @format NULL
#' @examples
#' df = pl$DataFrame(list(a = 1:6, b = c(1L, 1L, 3L, 3L, 5L, 6L), c = c(1L, 1L, 2L, 2L, 3L, 3L)))
#' df$select(pl$col("a")$mode())
#' df$select(pl$col("b")$mode())
#' df$select(pl$col("c")$mode())
Expr_mode = "use_extendr_wrapper"


#' Expr_sort
#' @description Sort this column. In projection/ selection context the whole column is sorted.
#' If used in a groupby context, the groups are sorted.
#' @keywords Expr
#' @param descending Sort in descending order. When sorting by multiple columns,
#' can be specified per column by passing a sequence of booleans.
#' @param nulls_last bool, default FALSE, place Nulls last
#' @return Expr
#' @aliases sort
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @name Expr_sort
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$sort())
Expr_sort = function(descending = FALSE, nulls_last = FALSE) { # param reverse named descending on rust side
  .pr$Expr$sort(self, descending, nulls_last)
}


# TODO contribute polars, add arguments for Null/NaN/inf last/first, top_k unwraps k> len column
#' Top k values
#' @description  Return the `k` largest elements.
#' @details  This has time complexity: \eqn{ O(n + k \\log{}n - \frac{k}{2}) }
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @keywords Expr
#' @param k numeric k top values to get
#' @return Expr
#' @aliases top_k
#' @name Expr_top_k
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$top_k(5))
Expr_top_k = function(k) {
  if (!is.numeric(k) || k < 0) stopf("k must be numeric and positive, prefereably integerish")
  .pr$Expr$top_k(self, k)
}

# TODO contribute polars, add arguments for Null/NaN/inf last/first, bottom_k unwraps k> len column
#' Bottom k values
#' @description  Return the `k` smallest elements.
#' @details  This has time complexity: \eqn{ O(n + k \\log{}n - \frac{k}{2}) }
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @keywords Expr
#' @param k numeric k bottom values to get
#' @return Expr
#' @aliases bottom_k
#' @name Expr_bottom_k
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$bottom_k(5))
Expr_bottom_k = function(k) {
  if (!is.numeric(k) || k < 0) stopf("k must be numeric and positive, prefereably integerish")
  .pr$Expr$bottom_k(self, k)
}


#' Index of a sort
#' @description Get the index values that would sort this column.
#' If 'reverse=True` the smallest elements will be given.
#' @keywords Expr
#' @param descending Sort in descending order. When sorting by multiple columns,
#' can be specified per column by passing a sequence of booleans.
#' @param nulls_last bool, default FALSE, place Nulls last
#' @return Expr
#' @aliases arg_sort
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @name Expr_arg_sort
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_sort())
Expr_arg_sort = function(descending = FALSE, nulls_last = FALSE) { # param reverse named descending on rust side
  .pr$Expr$arg_sort(self, descending, nulls_last)
}


#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @name Expr_arg_min
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_min())
Expr_arg_min = "use_extendr_wrapper"

#' Index of min value
#' @description  Get the index of the minimal value.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases Expr_arg_max
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @name Expr_arg_max
#' @format NULL
#' @examples
#' pl$DataFrame(list(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' ))$select(pl$col("a")$arg_max())
Expr_arg_max = "use_extendr_wrapper"





# TODO contribute pypolars search_sorted behavior is under-documented, does multiple elements work?
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
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))
Expr_search_sorted = function(element) {
  .pr$Expr$search_sorted(self, wrap_e(element))
}



#' sort column by order of others
#' @description Sort this column by the ordering of another column, or multiple other columns.
#' @param by one expression or list expressions and/or strings(interpreted as column names)
#' @param descending Sort in descending order. When sorting by multiple columns,
#' can be specified per column by passing a sequence of booleans.
#' @return Expr
#' @keywords Expr
#' @aliases sort_by
#' @name Expr_sort_by
#' @details
#' In projection/ selection context the whole column is sorted.
#' If used in a groupby context, the groups are sorted.
#'
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @format NULL
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("a", "a", "a", "b", "b", "b"),
#'   value1 = c(98, 1, 3, 2, 99, 100),
#'   value2 = c("d", "f", "b", "e", "c", "a")
#' ))
#'
#' # by one column/expression
#' df$select(
#'   pl$col("group")$sort_by("value1")
#' )
#'
#' # by two columns/expressions
#' df$select(
#'   pl$col("group")$sort_by(list("value2", pl$col("value1")), descending = c(TRUE, FALSE))
#' )
#'
#'
#' # by some expression
#' df$select(
#'   pl$col("group")$sort_by(pl$col("value1")$sort(descending = TRUE))
#' )
#'
#' # quite similar usecase as R function `order()`
#' l = list(
#'   ab = c(rep("a", 6), rep("b", 6)),
#'   v4 = rep(1:4, 3),
#'   v3 = rep(1:3, 4),
#'   v2 = rep(1:2, 6),
#'   v1 = 1:12
#' )
#' df = pl$DataFrame(l)
#'
#'
#' # examples of order versus sort_by
#' all.equal(
#'   df$select(
#'     pl$col("ab")$sort_by("v4")$alias("ab4"),
#'     pl$col("ab")$sort_by("v3")$alias("ab3"),
#'     pl$col("ab")$sort_by("v2")$alias("ab2"),
#'     pl$col("ab")$sort_by("v1")$alias("ab1"),
#'     pl$col("ab")$sort_by(list("v3", pl$col("v1")), descending = c(FALSE, TRUE))$alias("ab13FT"),
#'     pl$col("ab")$sort_by(list("v3", pl$col("v1")), descending = TRUE)$alias("ab13T")
#'   )$to_list(),
#'   list(
#'     ab4 = l$ab[order(l$v4)],
#'     ab3 = l$ab[order(l$v3)],
#'     ab2 = l$ab[order(l$v2)],
#'     ab1 = l$ab[order(l$v1)],
#'     ab13FT = l$ab[order(l$v3, rev(l$v1))],
#'     ab13T = l$ab[order(l$v3, l$v1, decreasing = TRUE)]
#'   )
#' )
Expr_sort_by = function(by, descending = FALSE) {
  .pr$Expr$sort_by(
    self,
    wrap_elist_result(by, str_to_lit = FALSE),
    result(descending)
  ) |> unwrap("in $sort_by:")
}


# TODO coontribute pyPolars, if exceeding u32 return Null, if exceeding column return Error
# either it should be error or Null.
# pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(5294967296.0)) #return Null
# pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(-3)) #return Null
# pl.DataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(7)) #return Error
#' Take values by index.
#' @param indices R scalar/vector or Series, or Expr that leads to a UInt32 dtyped Series.
#' @return Expr
#' @keywords Expr
#' @aliases take
#' @name Expr_take
#' @details
#' similar to R indexing syntax e.g. `letters[c(1,3,5)]`, however as an expression, not as eager computation
#' exceeding
#'
#' @format NULL
#' @examples
#' pl$select(pl$lit(0:10)$take(c(1, 8, 0, 7)))
Expr_take = function(indices) {
  .pr$Expr$take(self, pl$lit(indices))
}



#' Shift values
#' @param periods numeric number of periods to shift, may be negative.
#' @return Expr
#' @keywords Expr
#' @aliases shift
#' @name Expr_shift
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @usage Expr_shift(periods)
#' @examples
#' pl$select(
#'   pl$lit(0:3)$shift(-2)$alias("shift-2"),
#'   pl$lit(0:3)$shift(2)$alias("shift+2")
#' )
Expr_shift = function(periods = 1) {
  .pr$Expr$shift(self, periods)
}

#' Shift and fill values
#' @description Shift the values by a given period and fill the resulting null values.
#'
#' @param periods numeric number of periods to shift, may be negative.
#' @param fill_value Fill None values with the result of this expression.
#' @return Expr
#' @keywords Expr
#' @aliases shift_and_fill
#' @name Expr_shift_and_fill
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$select(
#'   pl$lit(0:3),
#'   pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
#'   pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42) / 2)$alias("shift+2")
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
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#'
#' @examples
#' pl$select(
#'   pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
#'   pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42) / 2)$alias("shift+2")
#' )
Expr_fill_null = function(value = NULL, strategy = NULL, limit = NULL) {
  pcase(
    # the wrong stuff
    is.null(value) && is.null(strategy), stopf("must specify either value or strategy"),
    !is.null(value) && !is.null(strategy), stopf("cannot specify both value and strategy"),
    !is.null(strategy) && !strategy %in% c("forward", "backward") && !is.null(limit), stopf(
      "can only specify 'limit' when strategy is set to 'backward' or 'forward'"
    ),

    # the two use cases
    !is.null(value), .pr$Expr$fill_null(self, pl$lit(value)),
    is.null(value), unwrap(.pr$Expr$fill_null_with_strategy(self, strategy, limit)),

    # catch failed any match
    or_else = stopf("Internal: failed to handle user inputs")
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
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#'
#' @examples
#' l = list(a = c(1L, rep(NA_integer_, 3L), 10))
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
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#'
#' @examples
#' l = list(a = c(1L, rep(NA_integer_, 3L), 10))
#' pl$DataFrame(l)$select(
#'   pl$col("a")$forward_fill()$alias("ff_null"),
#'   pl$col("a")$forward_fill(limit = 0)$alias("ff_l0"),
#'   pl$col("a")$forward_fill(limit = 1)$alias("ff_l1")
#' )$to_list()
Expr_forward_fill = function(limit = NULL) {
  .pr$Expr$forward_fill(self, limit)
}


#' Fill Nulls Forward
#'
#' @param expr Expr or into Expr, value to fill NaNs with
#'
#' @description Fill missing values with last seen values.
#'
#' @return Expr
#' @keywords Expr
#' @aliases fill_nan
#' @name Expr_fill_nan
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' l = list(a = c(1, NaN, NaN, 3))
#' pl$DataFrame(l)$select(
#'   pl$col("a")$fill_nan()$alias("fill_default"),
#'   pl$col("a")$fill_nan(pl$lit(NA))$alias("fill_NA"), # same as default
#'   pl$col("a")$fill_nan(2)$alias("fill_float2"),
#'   pl$col("a")$fill_nan("hej")$alias("fill_str") # implicit cast to Utf8
#' )$to_list()
Expr_fill_nan = function(expr = NULL) {
  .pr$Expr$fill_nan(self, wrap_e(expr))
}


#' Get Standard Deviation
#'
#' @param ddof integer in range `[0;255]` degrees of freedom
#' @return Expr (f64 scalar)
#' @keywords Expr
#' @name Expr_std
#' @format NULL
#'
#' @examples
#' pl$select(pl$lit(1:5)$std())
Expr_std = function(ddof = 1) {
  unwrap(.pr$Expr$std(self, ddof))
}

#' Get Variance
#'
#' @param ddof integer in range `[0;255]` degrees of freedom
#' @return Expr (f64 scalar)
#' @keywords Expr
#' @name Expr_var
#' @format NULL
#'
#' @examples
#' pl$select(pl$lit(1:5)$var())
Expr_var = function(ddof = 1) {
  unwrap(.pr$Expr$var(self, ddof))
}


#' max
#' @keywords Expr
#' @description
#' Get maximum value.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$max() == 3) # is true
Expr_max = "use_extendr_wrapper"

#' min
#' @keywords Expr
#' @description
#' Get minimum value.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$min() == 1) # is true
Expr_min = "use_extendr_wrapper"



# TODO Contribute polars, nan_max and nan_min poison on NaN. But no method poison on `Null`
# In R both NA and NaN poisons, but NA has priority which is meaningful, as NA is even less information
# then NaN.

#' max
#' @keywords Expr
#' @description Get maximum value, but propagate/poison encountered `NaN` values.
#' Get maximum value.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NaN, Inf, 3)))$select(pl$col("x")$nan_max()$is_nan()) # is true
Expr_nan_max = "use_extendr_wrapper"

#' min propagate NaN
#'
#' @keywords Expr
#' @description Get minimum value, but propagate/poison encountered `NaN` values.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See Inf,NaN,NULL,Null/NA translations here \code{\link[polars]{docs_translations}}
#' @examples
#' pl$DataFrame(list(x = c(1, NaN, -Inf, 3)))$select(pl$col("x")$nan_min()$is_nan()) # is true
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
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1L, NA, 2L)))$select(pl$col("x")$sum()) # is i32 3 (Int32 not casted)
Expr_sum = "use_extendr_wrapper"



#' mean
#' @keywords Expr
#' @description
#' Get mean value.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$mean() == 2) # is true
Expr_mean = "use_extendr_wrapper"

#' median
#' @keywords Expr
#' @description
#' Get median value.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 2)))$select(pl$col("x")$median() == 1.5) # is true
Expr_median = "use_extendr_wrapper"

## TODO contribute polars: product does not support in rust i32

#' Product
#' @keywords Expr
#' @description Compute the product of an expression.
#' @aliases  Product
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details does not support integer32 currently, .cast() to f64 or i64 first.
#' @examples
#' pl$DataFrame(list(x = c(1, 2, 3)))$select(pl$col("x")$product() == 6) # is true
Expr_product = "use_extendr_wrapper"


#' Count number of unique values
#' @keywords Expr
#' @description
#' Count number of unique values.
#' Similar to R length(unique(x))
#' @aliases n_unique
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
Expr_n_unique = "use_extendr_wrapper"

#'  Approx count unique values
#' @keywords Expr
#' @description
#' This is done using the HyperLogLog++ algorithm for cardinality estimation.
#' @aliases approx_n_unique
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$approx_n_unique())
Expr_approx_n_unique = "use_extendr_wrapper"

#' Count `Nulls`
#' @keywords Expr
#' @aliases null_count
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$select(pl$lit(c(NA, "a", NA, "b"))$null_count())
Expr_null_count = "use_extendr_wrapper"

#' Index of First Unique Value.
#' @keywords Expr
#' @aliases arg_unique
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$select(pl$lit(c(1:2, 1:3))$arg_unique())
Expr_arg_unique = "use_extendr_wrapper"


#' get unique values
#' @keywords Expr
#' @description
#'  Get unique values of this expression.
#' Similar to R unique()
#' @param maintain_order bool, if TRUE guaranteed same order, if FALSE maybe
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$unique())
Expr_unique = function(maintain_order = FALSE) {
  if (!is_bool(maintain_order)) stopf("param maintain_order must be a bool")
  if (maintain_order) {
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
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, 2, 3)))$select(pl$col("x")$first())
Expr_first = "use_extendr_wrapper"

#' Last
#' @keywords Expr
#' @description
#' Get the lastvalue.
#' Similar to R syntax tail(x,1)
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, 2, 3)))$select(pl$col("x")$last())
Expr_last = "use_extendr_wrapper"



#' over
#' @keywords Expr
#' @description
#' Apply window function over a subgroup.
#' This is similar to a groupby + aggregation + self join.
#' Or similar to `window functions in Postgres
#' <https://www.postgresql.org/docs/current/tutorial-window.html>`_.
#' @param ... of strings or columns to group by
#'
#' @return Expr
#' @examples
#' pl$DataFrame(
#'   val = 1:5,
#'   a = c("+", "+", "-", "-", "+"),
#'   b = c("+", "-", "+", "-", "+")
#' )$select(
#'   pl$col("val")$count()$over("a", "b")
#' )
#'
#' over_vars = c("a", "b")
#' pl$DataFrame(
#'   val = 1:5,
#'   a = c("+", "+", "-", "-", "+"),
#'   b = c("+", "-", "+", "-", "+")
#' )$select(
#'   pl$col("val")$count()$over(over_vars)
#' )
Expr_over = function(...) {
  # combine arguments in proto expression array
  pra = construct_ProtoExprArray(...)

  # pass to over
  .pr$Expr$over(self, pra)
}


#' Get mask of unique values
#'
#' @return Expr (boolean)
#' @docType NULL
#' @format NULL
#' @keywords Expr
#' @name Expr_is_unique
#' @format NULL
#'
#' @examples
#' v = c(1, 1, 2, 2, 3, NA, NaN, Inf)
#' all.equal(
#'   pl$select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_unique = "use_extendr_wrapper"

#' Get a mask of the first unique value.
#'
#' @return Expr (boolean)
#' @docType NULL
#' @format NULL
#' @keywords Expr
#' @name Expr_is_first
#' @format NULL
#'
#' @examples
#' v = c(1, 1, 2, 2, 3, NA, NaN, Inf)
#' all.equal(
#'   pl$select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_first = "use_extendr_wrapper"


#' Get mask of duplicated values.
#'
#' @return Expr (boolean)
#' @docType NULL
#' @format NULL
#' @keywords Expr
#' @aliases is_duplicated
#' @name Expr_is_duplicated
#' @format NULL
#' @details  is_duplicated is the opposite of `is_unique()`
#'  Looking for R like `duplicated()`?, use  `some_expr$is_first()$is_not()`
#'
#' @examples
#' v = c(1, 1, 2, 2, 3, NA, NaN, Inf)
#' all.equal(
#'   pl$select(
#'     pl$lit(v)$is_unique()$alias("is_unique"),
#'     pl$lit(v)$is_first()$alias("is_first"),
#'     pl$lit(v)$is_duplicated()$alias("is_duplicated"),
#'     pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
#'   )$to_list(),
#'   list(
#'     is_unique = !v %in% v[duplicated(v)],
#'     is_first = !duplicated(v),
#'     is_duplicated = v %in% v[duplicated(v)],
#'     R_duplicated = duplicated(v)
#'   )
#' )
Expr_is_duplicated = "use_extendr_wrapper"


# TODO contribute polars, example of where NA/Null is omitted and the smallest value
#' Get quantile value.
#'
#' @param quantile numeric/Expression 0.0 to 1.0
#' @param interpolation string value from choices "nearest", "higher",
#' "lower", "midpoint", "linear"
#' @return Expr
#' @keywords Expr
#' @aliases quantile
#' @name Expr_quantile
#' @format NULL
#'
#' @details `Nulls` are ignored and `NaNs` are ranked as the largest value.
#' For linear interpolation `NaN` poisons `Inf`, that poisons any other value.
#'
#' @examples
#' pl$select(pl$lit(-5:5)$quantile(.5))
Expr_quantile = function(quantile, interpolation = "nearest") {
  unwrap(.pr$Expr$quantile(self, wrap_e(quantile), interpolation))
}



#' Filter a single column.
#' @description
#' Mostly useful in an aggregation context. If you want to filter on a DataFrame
#' level, use `LazyFrame.filter`.
#'
#' @param predicate Expr or something `Into<Expr>`. Should be a boolean expression.
#' @return Expr
#' @keywords Expr
#' @aliases Expr_filter
#' @format NULL
#'
#' @examples
#' df = pl$DataFrame(list(
#'   group_col = c("g1", "g1", "g2"),
#'   b = c(1, 2, 3)
#' ))
#'
#' df$groupby("group_col")$agg(
#'   pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
#'   pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte")
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
#' @docType NULL
#' @format NULL
#' @keywords Expr
#' @aliases explode
#' @format NULL
#'
#' @details
#' explode/flatten does not support categorical
#'
#' @examples
#' pl$DataFrame(list(a = letters))$select(pl$col("a")$explode()$take(0:5))
#'
#' listed_group_df = pl$DataFrame(iris[c(1:3, 51:53), ])$groupby("Species")$agg(pl$all())
#' print(listed_group_df)
#' vectors_df = listed_group_df$select(
#'   pl$col(c("Sepal.Width", "Sepal.Length"))$explode()
#' )
#' print(vectors_df)
Expr_explode = "use_extendr_wrapper"

#' @description
#' ( flatten is an alias for explode )
#' @keywords Expr
#' @aliases flatten
#' @docType NULL
#' @format NULL
#' @format NULL
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
#' @format NULL
#'
#' @examples
#' pl$DataFrame(list(a = 0:24))$select(pl$col("a")$take_every(6))
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
#' # get 3 first elements
#' pl$DataFrame(list(x = 1:11))$select(pl$col("x")$head(3))
Expr_head = function(n = 10) {
  unwrap(.pr$Expr$head(self, n = n), "in $head():")
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
#' # get 3 last elements
#' pl$DataFrame(list(x = 1:11))$select(pl$col("x")$tail(3))
Expr_tail = function(n = 10) {
  unwrap(.pr$Expr$tail(self, n = n), "in $tail():")
}


#' Limit
#' @keywords Expr
#' @description
#' Alias for Head
#' Get the head n elements.
#' Similar to R head(x)
#' @param n numeric number of elements to select from head
#' @return Expr
#' @examples
#' # get 3 first elements
#' pl$DataFrame(list(x = 1:11))$select(pl$col("x")$limit(3))
Expr_limit = function(n = 10) {
  if (!is.numeric(n)) stopf("limit: n must be numeric")
  unwrap(.pr$Expr$head(self, n = n))
}



#' Exponentiation
#' @description Raise expression to the power of exponent.
#' @keywords Expr
#' @param exponent exponent
#' @details The R interpreter will replace the `**` with `^`, such that `**` means `^` (except in
#' strings e.g. "**"). Read further at `?"**"`. In py-polars python `^` is the XOR operator and
#' `**` is the exponentiation operator.
#' @return Expr
#' @name Expr_pow
#' @aliases pow
#' @examples
#' # use via `pow`-method and the `^`-operator
#' pl$DataFrame(a = -1:3)$select(
#'   pl$lit(2)$pow(pl$col("a"))$alias("with $pow()"),
#'   2^pl$lit(-2:2), # brief use
#'   pl$lit(2)$alias("left hand side name")^pl$lit(-3:1)$alias("right hand side name dropped")
#' )
#'
#' # exotic case where '**' will not work, but "^" will
#' safe_chr = \(...) tryCatch(..., error = as.character)
#' get("^")(2, pl$lit(2)) |> safe_chr()
#' get("**")(2, pl$lit(2)) |> safe_chr()
#' get("**")(2, 2) |> safe_chr()
Expr_pow = function(exponent) {
  .pr$Expr$pow(self, exponent) |> unwrap("in $pow()")
}
#' @export
"^.Expr" = function(e1, e2) result(wrap_e(e1)$pow(e2)) |> unwrap("using '^'-operator")


#' is_in
#' @name Expr_is_in
#' @description combine to boolean expressions with similar to `%in%`
#' @keywords Expr Expr_operators
#' @param other literal or Robj which can become a literal
#' @return Expr
#' @docType NULL
#' @format NULL
#' @usage Expr_is_in(other)
#' @examples
#'
#' # R Na_integer -> polars Null(Int32) is in polars Null(Int32)
#' pl$DataFrame(list(a = c(1:4, NA_integer_)))$select(
#'   pl$col("a")$is_in(pl$lit(NA_real_))
#' )$to_data_frame()[[1L]]
#'
Expr_is_in = function(other) {
  .pr$Expr$is_in(self, other) |> unwrap("in $is_in()")
}

## TODO contribute polars, do not panic on by pointing to non positive values
#' Repeat by
#' @keywords Expr
#' @description
#' Repeat the elements in this Series as specified in the given expression.
#' The repeated elements are expanded into a `List`.
#' @param by Expr Numeric column that determines how often the values will be repeated.
#' The column will be coerced to UInt32. Give this dtype to make the coercion a
#' no-op.
#' @return Expr
#' @examples
#' df = pl$DataFrame(list(a = c("x", "y", "z"), n = c(0:2)))
#' df$select(pl$col("a")$repeat_by("n"))
Expr_repeat_by = function(by) {
  if (is.numeric(by) && any(by < 0)) stopf("In repeat_by: any value less than zero is not allowed")
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
#' @examples
#' df = pl$DataFrame(list(num = 1:5))
#' df$select(pl$col("num")$is_between(2, 4))
#' df$select(pl$col("num")$is_between(2, 4, TRUE))
#' df$select(pl$col("num")$is_between(2, 4, c(FALSE, TRUE)))
#' # start end can be a vector/expr with same length as column
#' df$select(pl$col("num")$is_between(c(0, 2, 3, 3, 3), 6))
Expr_is_between = function(start, end, include_bounds = FALSE) {
  # check
  if (
    !length(include_bounds) %in% 1:2 ||
      !is.logical(include_bounds) ||
      any(is.na(include_bounds))
  ) {
    stopf("in is_between: inlcude_bounds must be boolean of length 1 or 2, with no NAs")
  }

  # prepare args
  start_e = wrap_e(start)
  end_e = wrap_e(end)
  with_start = include_bounds[1L]
  with_end = if (length(include_bounds) == 1) include_bounds else include_bounds[2]


  # build and return boolean expression
  within_start_e = if (with_start) self >= start_e else self > start_e
  within_end_e = if (with_end) self <= end_e else self < end_e
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
#'
#' @details WARNING in this version of r-polars seed / seed_x takes no effect.
#' Possibly a bug in upstream rust-polars project.
#'
#' @return Expr
#' @aliases hash
#' @examples
#' df = pl$DataFrame(iris)
#' df$select(pl$all()$head(2)$hash(1234)$cast(pl$Utf8))$to_list()
Expr_hash = function(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL) {
  k0 = seed
  k1 = seed_1 %||% seed
  k2 = seed_2 %||% seed
  k3 = seed_3 %||% seed
  unwrap(.pr$Expr$hash(self, k0, k1, k2, k3), "in $hash()")
}


#' reinterpret bits
#' @keywords Expr
#' @description
#' Reinterpret the underlying bits as a signed/unsigned integer.
#' This operation is only allowed for 64bit integers. For lower bits integers,
#' you can safely use that cast operation.
#' @param signed bool reinterpret into Int64 else UInt64
#' @return Expr
#' @aliases reinterpret
#' @examples
#' df = pl$DataFrame(iris)
#' df$select(pl$all()$head(2)$hash(1, 2, 3, 4)$reinterpret())$to_data_frame()
Expr_reinterpret = function(signed = TRUE) {
  if (!is_bool(signed)) stopf("in reinterpret() : arg signed must be a bool")
  .pr$Expr$reinterpret(self, signed)
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
#' pl$select(pl$lit(1:5)$inspect(
#'   "before dropping half the column it was:{}and not it is dropped"
#' )$head(2))
Expr_inspect = function(fmt = "{}") {
  # check fmt and create something to print before and after printing Series.
  if (!is_string(fmt)) stopf("Inspect: arg fmt is not a string (length=1)")
  strs = strsplit(fmt, split = "\\{\\}")[[1L]]
  if (identical(strs, "")) strs <- c("", "")
  if (length(strs) != 2L || length(gregexpr("\\{\\}", fmt)[[1L]]) != 1L) {
    stopf(paste0(
      "Inspect: failed to parse arg fmt [", fmt, "] ",
      " a string containing the two consecutive chars `{}` once. \n",
      "a valid string is e.g. `hello{}world`"
    ))
  }

  # function to print the evaluated Series
  f_inspect = function(s) { # required signature f(Series) -> Series
    cat(strs[1L])
    s$print()
    cat(strs[2L], "\n", sep = "")
    s
  }

  # add a map to expression printing the evaluated series
  .pr$Expr$map(self = self, lambda = f_inspect, output_type = NULL, agg_list = TRUE)
}



#' Interpolate `Nulls`
#' @keywords Expr
#' @param method string 'linear' or 'nearest', default "linear"
#' @description
#' Fill nulls with linear interpolation over missing values.
#' Can also be used to regrid data to a new grid - see examples below.
#' @return Expr
#' @aliases interpolate
#' @examples
#' pl$select(pl$lit(c(1, NA, 4, NA, 100, NaN, 150))$interpolate())
#'
#' # x, y interpolation over a grid
#' df_original_grid = pl$DataFrame(list(
#'   grid_points = c(1, 3, 10),
#'   values = c(2.0, 6.0, 20.0)
#' ))
#' df_new_grid = pl$DataFrame(list(grid_points = (1:10) * 1.0))
#'
#' # Interpolate from this to the new grid
#' df_new_grid$join(
#'   df_original_grid,
#'   on = "grid_points", how = "left"
#' )$with_columns(pl$col("values")$interpolate())
Expr_interpolate = function(method = "linear") {
  unwrap(.pr$Expr$interpolate(self, method))
}


prepare_rolling_window_args = function(
    window_size, # : int | str,
    min_periods = NULL # : int | None = None,
    ) { # ->tuple[str, int]:
  if (is.numeric(window_size)) {
    if (is.null(min_periods)) min_periods <- as.numeric(window_size)
    window_size = paste0(as.character(floor(window_size)), "i")
  }
  if (is.null(min_periods)) min_periods <- 1
  list(window_size = window_size, min_periods = min_periods)
}


## TODO impl datatime in rolling expr
## TODO contribute polars rolling _min _max _sum _mean do no behave as the aggregation counterparts
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
#' - 1ns   (1 nanosecond)
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
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_min
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_min(window_size = 2))
Expr_rolling_min = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_max
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_max(window_size = 2))
Expr_rolling_max = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' @details
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_mean
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_mean(window_size = 2))
Expr_rolling_mean = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' @details
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_sum
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_sum(window_size = 2))
Expr_rolling_sum = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_std
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_std(window_size = 2))
Expr_rolling_std = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_var
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_var(window_size = 2))
Expr_rolling_var = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' - 1ns   (1 nanosecond)
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
#' This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_median
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(pl$col("a")$rolling_median(window_size = 2))
Expr_rolling_median = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
    ) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  unwrap(.pr$Expr$rolling_median(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed
  ))
}


## TODO contribute polars arg center only allows center + right alignment, also implement left
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
#'
#'
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' Notes:
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `groupby_rolling` this method can cache the window size
#' computation.
#' @return Expr
#' @aliases Expr_rolling_quantile
#' @examples
#' pl$DataFrame(list(a = 1:6))$select(
#'   pl$col("a")$rolling_quantile(window_size = 2, quantile = .5)
#' )
Expr_rolling_quantile = function(
    quantile,
    interpolation = "nearest",
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE, # :bool,
    by = NULL, # : Nullable<String>,
    closed = "left" # ;: Nullable<String>,
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
#' Extra comments copied from rust-polars_0.25.1
#' Compute the sample skewness of a data set.
#'
#' For normally distributed data, the skewness should be about zero. For
#' uni-modal continuous distributions, a skewness value greater than zero means
#' that there is more weight in the right tail of the distribution. The
#' function `skewtest` can be used to determine if the skewness value
#' is close enough to zero, statistically speaking.
#' see: https://github.com/scipy/scipy/blob/47bb6febaa10658c72962b9615d5d5aa2513fa3a/scipy/stats/stats.py#L1024
#'
#' @examples
#' pl$DataFrame(list(a = iris$Sepal.Length))$select(pl$col("a")$rolling_skew(window_size = 4)$head(10))
Expr_rolling_skew = function(window_size, bias = TRUE) {
  unwrap(.pr$Expr$rolling_skew(self, window_size, bias))
}


#' Abs
#' @description Compute absolute values
#' @keywords Expr
#' @return Exprs abs
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = -1:1))$select(pl$col("a"), pl$col("a")$abs()$alias("abs"))
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
#' @param descending Rank in descending order.
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
Expr_rank = function(method = "average", descending = FALSE) {
  unwrap(.pr$Expr$rank(self, method, descending))
}



#' Diff
#' @description  Calculate the n-th discrete difference.
#' @param n  Integerish Number of slots to shift.
#' @param null_behavior option default 'ignore', else 'drop'
#' @return  Expr
#' @aliases diff
#' @keywords Expr
#' @examples
#' pl$DataFrame(list(a = c(20L, 10L, 30L, 40L)))$select(
#'   pl$col("a")$diff()$alias("diff_default"),
#'   pl$col("a")$diff(2, "ignore")$alias("diff_2_ignore")
#' )
Expr_diff = function(n = 1, null_behavior = "ignore") {
  unwrap(.pr$Expr$diff(self, n, null_behavior))
}




#' Pct change
#' @description
#' Computes percentage change between values.
#' Percentage change (as fraction) between current element and most-recent
#' non-null element at least ``n`` period(s) before the current element.
#' Computes the change from the previous row by default.
#' @param n  periods to shift for forming percent change.
#' @return  Expr
#' @aliases pct_change
#' @keywords Expr
#' @examples
#' df = pl$DataFrame(list(a = c(10L, 11L, 12L, NA_integer_, 12L)))
#' df$with_columns(pl$col("a")$pct_change()$alias("pct_change"))
Expr_pct_change = function(n = 1) {
  unwrap(.pr$Expr$pct_change(self, n))
}



#' Skewness
#' @description
#' Compute the sample skewness of a data set.
#' @param bias If False, then the calculations are corrected for statistical bias.
#' @return  Expr
#' @aliases skew
#' @keywords Expr
#' @details
#' For normally distributed data, the skewness should be about zero. For
#' unimodal continuous distributions, a skewness value greater than zero means
#' that there is more weight in the right tail of the distribution. The
#' function `skewtest` can be used to determine if the skewness value
#' is close enough to zero, statistically speaking.
#'
#' See scipy.stats for more information.
#'
#' Notes
#' -----
#'   The sample skewness is computed as the Fisher-Pearson coefficient
#' of skewness, i.e.
#'
#' \eqn{ g_1=\frac{m_3}{m_2^{3/2}}}
#'
#' where
#'
#' \eqn{ m_i=\frac{1}{N}\sum_{n=1}^N(x[n]-\bar{x})^i}
#'
#' is the biased sample :math:`i\texttt{th}` central moment, and \eqn{\bar{x}} is
#' the sample mean.  If ``bias`` is False, the calculations are
#' corrected for bias and the value computed is the adjusted
#' Fisher-Pearson standardized moment coefficient, i.e.
#'
#' \eqn{ G_1 = \frac{k_3}{k_2^{3/2}} = \frac{\sqrt{N(N-1)}}{N-2}\frac{m_3}{m_2^{3/2}}}
#' @references https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.skew.html?highlight=skew#scipy.stats.skew
#' @examples
#' df = pl$DataFrame(list(a = c(1:3, 2:1)))
#' df$select(pl$col("a")$skew())
Expr_skew = function(bias = TRUE) {
  .pr$Expr$skew(self, bias)
}


#' Kurtosis
#' @description
#' Compute the kurtosis (Fisher or Pearson) of a dataset.
#'
#' @param fisher bool se details
#' @param bias bool, If FALSE, then the calculations are corrected for statistical bias.
#'
#' @return  Expr
#' @aliases kurtosis
#' @keywords Expr
#' @details
#' Kurtosis is the fourth central moment divided by the square of the
#' variance. If Fisher's definition is used, then 3.0 is subtracted from
#'         the result to give 0.0 for a normal distribution.
#'         If bias is False then the kurtosis is calculated using k statistics to
#'         eliminate bias coming from biased moment estimators
#'         See scipy.stats for more information
#'
#' #' See scipy.stats for more information.
#'
#' @references https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.kurtosis.html?highlight=kurtosis
#'
#' @examples
#' df = pl$DataFrame(list(a = c(1:3, 2:1)))
#' df$select(pl$col("a")$kurtosis())
Expr_kurtosis = function(fisher = TRUE, bias = TRUE) {
  .pr$Expr$kurtosis(self, fisher, bias)
}



#' Clip
#' @description
#' Clip (limit) the values in an array to a `min` and `max` boundary.
#' @param min Minimum Value, ints and floats or any literal expression of ints and floats
#' @param max Maximum Value, ints and floats or any literal expression of ints and floats
#' @return  Expr
#' @aliases clip
#' @keywords Expr
#' @details
#' Only works for numerical types.
#' If you want to clip other dtypes, consider writing a "when, then, otherwise"
#' expression. See :func:`when` for more information.
#'
#' @examples
#' df = pl$DataFrame(foo = c(-50L, 5L, NA_integer_, 50L))
#' df$with_columns(pl$col("foo")$clip(1L, 10L)$alias("foo_clipped"))
Expr_clip = function(min, max) {
  unwrap(.pr$Expr$clip(self, wrap_e(min), wrap_e(max)))
}

#' Clip min
#' @rdname Expr_clip
#' @aliases clip_min
#' @keywords Expr
#' @examples
#' df$with_columns(pl$col("foo")$clip_min(1L)$alias("foo_clipped"))
Expr_clip_min = function(min) {
  unwrap(.pr$Expr$clip_min(self, wrap_e(min)))
}

#' Clip max
#' @rdname Expr_clip
#' @aliases clip_max
#' @keywords Expr
#' @examples
#' df$with_columns(pl$col("foo")$clip_max(10L)$alias("foo_clipped"))
Expr_clip_max = function(max) {
  unwrap(.pr$Expr$clip_max(self, wrap_e(max)))
}


#' Upper bound
#' @name Expr_upper_lower_bound
#' @description
#' Calculate the upper/lower bound.
#' Returns a unit Series with the highest value possible for the dtype of this
#' expression.
#' @details
#' Notice lower bound i32 exported to R is NA_integer_ for now
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases upper_bound
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(i32 = 1L, f64 = 1)$select(pl$all()$upper_bound())
Expr_upper_bound = "use_extendr_wrapper"


#' Lower bound
#' @rdname Expr_upper_lower_bound
#' @aliases lower_bound
#' @format NULL
#' @keywords Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(i32 = 1L, f64 = 1)$select(pl$all()$lower_bound())
Expr_lower_bound = "use_extendr_wrapper"



#' Sign
#' @description
#' Compute the element-wise indication of the sign.
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases sign
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(.9, -0, 0, 4, NA_real_))$select(pl$col("a")$sign())
Expr_sign = "use_extendr_wrapper"


#' Sin
#' @description
#' Compute the element-wise value for the sine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases sin
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$select(pl$col("a")$sin())
Expr_sin = "use_extendr_wrapper"


#' Cos
#' @description
#' Compute the element-wise value for the cosine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases cos
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$select(pl$col("a")$cos())
Expr_cos = "use_extendr_wrapper"


#' Tan
#' @description
#' Compute the element-wise value for the tangent.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases Tan
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$select(pl$col("a")$tan())
Expr_tan = "use_extendr_wrapper"

#' Arcsin
#' @description
#' Compute the element-wise value for the inverse sine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arcsin
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, sin(0.5), 0, 1, NA_real_))$select(pl$col("a")$arcsin())
Expr_arcsin = "use_extendr_wrapper"

#' Arccos
#' @description
#' Compute the element-wise value for the inverse cosine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arccos
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, cos(0.5), 0, 1, NA_real_))$select(pl$col("a")$arccos())
Expr_arccos = "use_extendr_wrapper"


#' Arctan
#' @description
#' Compute the element-wise value for the inverse tangent.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arctan
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, tan(0.5), 0, 1, NA_real_))$select(pl$col("a")$arctan())
Expr_arctan = "use_extendr_wrapper"



#' Sinh
#' @description
#' Compute the element-wise value for the hyperbolic sine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases sinh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, asinh(0.5), 0, 1, NA_real_))$select(pl$col("a")$sinh())
Expr_sinh = "use_extendr_wrapper"

#' Cosh
#' @description
#' Compute the element-wise value for the hyperbolic cosine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases cosh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, acosh(1.5), 0, 1, NA_real_))$select(pl$col("a")$cosh())
Expr_cosh = "use_extendr_wrapper"

#' Tanh
#' @description
#' Compute the element-wise value for the hyperbolic tangent.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases tanh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, atanh(0.5), 0, 1, NA_real_))$select(pl$col("a")$tanh())
Expr_tanh = "use_extendr_wrapper"

#' Arcsinh
#' @description
#' Compute the element-wise value for the inverse hyperbolic sine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arcsinh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, sinh(0.5), 0, 1, NA_real_))$select(pl$col("a")$arcsinh())
Expr_arcsinh = "use_extendr_wrapper"

#' Arccosh
#' @description
#' Compute the element-wise value for the inverse hyperbolic cosine.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arccosh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, cosh(0.5), 0, 1, NA_real_))$select(pl$col("a")$arccosh())
Expr_arccosh = "use_extendr_wrapper"

#' Arctanh
#' @description
#' Compute the element-wise value for the inverse hyperbolic tangent.
#' @details Evaluated Series has dtype Float64
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases arctanh
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = c(-1, tanh(0.5), 0, 1, NA_real_))$select(pl$col("a")$arctanh())
Expr_arctanh = "use_extendr_wrapper"


#' Reshape
#' @description
#' Reshape this Expr to a flat Series or a Series of Lists.
#' @param dims
#' numeric vec of the dimension sizes. If a -1 is used in any of the dimensions, that
#' dimension is inferred.
#' @return  Expr
#' @aliases reshape
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$select(pl$lit(1:12)$reshape(c(3, 4)))
#' pl$select(pl$lit(1:12)$reshape(c(3, -1)))
Expr_reshape = function(dims) {
  if (!is.numeric(dims)) pstop(err = "reshape: arg dims must be numeric")
  if (!length(dims) %in% 1:2) pstop(err = "reshape: arg dims must be of length 1 or 2")
  unwrap(.pr$Expr$reshape(self, as.numeric(dims)))
}


#' Shuffle
#' @description
#' Shuffle the contents of this expr.
#' @param seed numeric value of 0 to 2^52
#' Seed for the random number generator. If set to Null (default), a random
#' seed value integerish value between 0 and 10000 is picked
#' @param fixed_seed
#' Boolean. If True, The seed will not be incremented between draws. This can make output
#' predictable because draw ordering can change due to threads being scheduled in a different order.
#' Should be used together with seed
#' @return  Expr
#' @aliases shuffle
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = 1:3)$select(pl$col("a")$shuffle(seed = 1))
Expr_shuffle = function(seed = NULL, fixed_seed = FALSE) {
  .pr$Expr$shuffle(self, seed, fixed_seed) |> unwrap("in $shuffle()")
}


#' Sample
#' @description
#' #' Sample from this expression.
#' @param frac
#' Fraction of items to return. Cannot be used with `n`.
#' @param  with_replacement
#' Allow values to be sampled more than once.
#' @param shuffle
#' Shuffle the order of sampled data points. (implicitly TRUE if, with_replacement = TRUE)
#' @param  seed
#' Seed for the random number generator. If set to None (default), a random
#' seed is used.
#' @param fixed_seed
#' Boolean. If True, The seed will not be incremented between draws. This can make output
#' predictable because draw ordering can change due to threads being scheduled in a different order.
#' Should be used together with seed
#' @param n
#' Number of items to return. Cannot be used with `frac`.
#' @return  Expr
#' @aliases sample
#' @format NULL
#' @keywords Expr
#' @examples
#' df = pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$sample(frac = 1, with_replacement = TRUE, seed = 1L))
#' df$select(pl$col("a")$sample(frac = 2, with_replacement = TRUE, seed = 1L))
#' df$select(pl$col("a")$sample(n = 2, with_replacement = FALSE, seed = 1L))
Expr_sample = function(
    frac = NULL, with_replacement = TRUE, shuffle = FALSE,
    seed = NULL, fixed_seed = FALSE, n = NULL) {
  pcase(
    !is.null(n) && !is.null(frac), {
      Err(.pr$RPolarsErr$new()$plain("either arg `n` or `frac` must be NULL"))
    },
    !is.null(n), .pr$Expr$sample_n(self, n, with_replacement, shuffle, seed, fixed_seed),
    or_else = {
      .pr$Expr$sample_frac(self, frac %||% 1.0, with_replacement, shuffle, seed, fixed_seed)
    }
  ) |>
    unwrap("in $sample()")
}



#' prepare alpha
#' @description  internal function for emw_x expressions
#' @param com numeric or NULL
#' @param span numeric or NULL
#' @param half_life numeric or NULL
#' @param alpha numeric or NULL
#' @keywords internal
#' @return numeric
prepare_alpha = function(
    com = NULL,
    span = NULL,
    half_life = NULL,
    alpha = NULL) { #-> double:

  if (sum(!sapply(list(com, span, half_life, alpha), is.null)) > 1) {
    pstop(err = "Parameters 'com', 'span', 'half_life', and 'alpha' are mutually exclusive")
  }

  if (!is.null(com)) {
    if (!is.numeric(com) || com < 0) {
      pstop(err = "com must be a non-negative numeric")
    }
    return(1 / (1 + com))
  }

  if (!is.null(span)) {
    if (!is.numeric(span) || span < 1) {
      pstop(err = "span must be numeric > 1.0")
    }
    return(2 / (span + 1))
  }

  if (!is.null(half_life)) {
    if (!is.numeric(half_life) || half_life < 0) {
      pstop(err = "half_life must be a non-negative numeric")
    }
    return(1.0 - exp(-log(2.0) / half_life))
  }

  if (!is.null(alpha)) {
    if (!is.numeric(alpha) || alpha < 0 || alpha >= 1) {
      pstop(err = "alpha must be numeric ]0;1] ")
    }
    return(alpha)
  } else {
    pstop(err = "One of 'com', 'span', 'half_life', or 'alpha' must be set")
  }

  stopf("Internal: it seems a input scenario was not handled properly")
}




#' Exponentially-weighted moving average/std/var.
#' @name Expr_ewm_mean_std_var
#' @param com
#' Specify decay in terms of center of mass, \eqn{\gamma}, with
#' \eqn{
#'   \alpha = \frac{1}{1 + \gamma} \; \forall \; \gamma \geq 0
#'   }
#' @param span
#' Specify decay in terms of span,  \eqn{\theta}, with
#' \eqn{\alpha = \frac{2}{\theta + 1} \; \forall \; \theta \geq 1 }
#' @param half_life
#' Specify decay in terms of half-life, :math:`\lambda`, with
#' \eqn{ \alpha = 1 - \exp \left\{ \frac{ -\ln(2) }{ \lambda } \right\} }
#' \eqn{ \forall \; \lambda > 0}
#' @param alpha
#' Specify smoothing factor alpha directly, \eqn{0 < \alpha \leq 1}.
#' @param adjust
#' Divide by decaying adjustment factor in beginning periods to account for
#' imbalance in relative weightings
#' - When ``adjust=TRUE`` the EW function is calculated
#' using weights \eqn{w_i = (1 - \alpha)^i  }
#' - When ``adjust=FALSE`` the EW function is calculated
#' recursively by
#' \eqn{
#'   y_0 = x_0 \\
#'   y_t = (1 - \alpha)y_{t - 1} + \alpha x_t
#' }
#' @param min_periods
#' Minimum number of observations in window required to have a value
#' (otherwise result is null).
#'
#' @param ignore_nulls  ignore_nulls
#' Ignore missing values when calculating weights.
#'  - When ``ignore_nulls=FALSE`` (default), weights are based on absolute
#'    positions.
#'    For example, the weights of :math:`x_0` and :math:`x_2` used in
#'    calculating the final weighted average of
#'    `[` \eqn{x_0}, None,  \eqn{x_2}\\`]` are
#'      \eqn{1-\alpha)^2} and  \eqn{1} if ``adjust=TRUE``, and
#'      \eqn{(1-\alpha)^2} and  \eqn{\alpha} if `adjust=FALSE`.
#'  - When ``ignore_nulls=TRUE``, weights are based
#'    on relative positions. For example, the weights of
#'     \eqn{x_0} and  \eqn{x_2} used in calculating the final weighted
#'    average of `[` \eqn{x_0}, None,  \eqn{x_2}`]` are
#'     \eqn{1-\alpha} and  \eqn{1} if `adjust=TRUE`,
#'    and  \eqn{1-\alpha} and  \eqn{\alpha} if `adjust=FALSE`.
#' @return Expr
#' @aliases ewm_mean
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_mean(com = 1))
#'
Expr_ewm_mean = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  unwrap(.pr$Expr$ewm_mean(self, alpha, adjust, min_periods, ignore_nulls))
}


#' Ewm_std
#' @rdname Expr_ewm_mean_std_var
#' @param bias  When bias=FALSE`, apply a correction to make the estimate statistically unbiased.
#' @aliases ewm_std
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com = 1))
Expr_ewm_std = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, bias = FALSE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  unwrap(.pr$Expr$ewm_std(self, alpha, adjust, bias, min_periods, ignore_nulls))
}

#' Ewm_var
#' @rdname Expr_ewm_mean_std_var
#' @aliases ewm_var
#' @keywords Expr
#' @examples
#' pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com = 1))
Expr_ewm_var = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, bias = FALSE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  unwrap(.pr$Expr$ewm_var(self, alpha, adjust, bias, min_periods, ignore_nulls))
}



#' Extend_constant
#' @description
#' Extend the Series with given number of values.
#' @param value The value to extend the Series with.
#' This value may be None to fill with nulls.
#' @param n The number of values to extend.
#' @return  Expr
#' @aliases extend_constant
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$select(
#'   pl$lit(c("5", "Bob_is_not_a_number"))
#'   $cast(pl$dtypes$UInt64, strict = FALSE)
#'   $extend_constant(10.1, 2)
#' )
#'
#' pl$select(
#'   pl$lit(c("5", "Bob_is_not_a_number"))
#'   $cast(pl$dtypes$Utf8, strict = FALSE)
#'   $extend_constant("chuchu", 2)
#' )
Expr_extend_constant = function(value, n) {
  unwrap(.pr$Expr$extend_constant(self, wrap_e(value), n))
}


#' expression: repeat series
#' @description
#' This expression takes input and repeats it n times and append chunk
#' @param n  Numeric the number of times to repeat, must be non-negative and finite
#' @param rechunk bool default = TRUE, if true memory layout will be rewritten
#'
#' @return  Expr
#' @aliases Expr_rep
#' @format NULL
#' @details
#' if self$len() == 1 , has a special faster implementation,  Here rechunk is not
#' necessary, and takes no effect.
#'
#' if self$len() > 1 , then the expression instructs the series to append onto
#' itself n time and rewrite memory
#'
#' @keywords Expr
#' @examples
#'
#' pl$select(
#'   pl$lit("alice")$rep(n = 3)
#' )
#'
#' pl$select(
#'   pl$lit(1:3)$rep(n = 2)
#' )
#'
Expr_rep = function(n, rechunk = TRUE) {
  unwrap(.pr$Expr$rep(self, n, rechunk))
}


#' extend series with repeated series
#' @description
#' Extend a series with a repeated series or value.
#' @param expr Expr or into Expr
#' @param n  Numeric the number of times to repeat, must be non-negative and finite
#' @param rechunk bool default = TRUE, if true memory layout will be rewritten
#' @param upcast bool default = TRUE, passed to self$append(), if TRUE non identical types
#' will be casted to common super type if any. If FALSE or no common super type
#' throw error.
#' @return  Expr
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$select(pl$lit(c(1, 2, 3))$rep_extend(1:3, n = 5))
Expr_rep_extend = function(expr, n, rechunk = TRUE, upcast = TRUE) {
  other = wrap_e(expr)$rep(n, rechunk = FALSE)
  new = .pr$Expr$append(self, other, upcast)
  if (rechunk) new$rechunk() else new
}


#' to_r: for debuging an expression
#' @description
#' debug an expression by evaluating in empty DataFrame and return first series to R
#' @param df otherwise a DataFrame to evaluate in, default NULL is an empty DataFrame
#' @param i numeric column to extract zero index default first, expression could generate multiple
#' columns
#' @return  R object
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$lit(1:3)$to_r()
#' pl$expr_to_r(pl$lit(1:3))
#' pl$expr_to_r(1:3)
Expr_to_r = function(df = NULL, i = 0) {
  if (is.null(df)) {
    pl$select(self)$to_series(i)$to_r()
  } else {
    if (!inherits(df, c("DataFrame"))) {
      stopf("Expr_to_r: input is not NULL or a DataFrame/Lazyframe")
    }
    df$select(self)$to_series(i)$to_r()
  }
}


#' @name pl_expr_to_r
#' @rdname Expr_to_r
pl$expr_to_r = function(expr, df = NULL, i = 0) {
  wrap_e(expr)$to_r(df, i)
}


#' Value counts
#' @description
#' Count all unique values and create a struct mapping value to count.
#' @return Expr
#' @param multithreaded
#' Better to turn this off in the aggregation context, as it can lead to contention.
#' @param sort
#' Ensure the output is sorted from most values to least.
#' @format NULL
#' @keywords Expr
#' @examples
#' df = pl$DataFrame(iris)$select(pl$col("Species")$value_counts())
#' df
#' df$unnest()$to_data_frame() # recommended to unnest structs before converting to R
Expr_value_counts = function(multithreaded = FALSE, sort = FALSE) {
  .pr$Expr$value_counts(self, multithreaded, sort)
}

#' Value counts
#' @description
#' Return a count of the unique values in the order of appearance.
#' This method differs from `value_counts` in that it does not return the
#' values, only the counts and might be faster
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @aliases unique_counts
#' @format NULL
#' @keywords Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$unique_counts())
Expr_unique_counts = "use_extendr_wrapper"

#' Natural Log
#'
#' @param base numeric base value for log, default base::exp(1)
#'
#' @description  Compute the base x logarithm of the input array, element-wise.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases log
#' @name Expr_log
#' @examples
#' pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())
Expr_log = function(base = base::exp(1)) {
  .pr$Expr$log(self, base)
}

#' 10-base log
#' @description Compute the base 10 logarithm of the input array, element-wise.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases log10
#' @name Expr_log10
#' @format NULL
#' @examples
#' pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())
Expr_log10 = "use_extendr_wrapper"




#' Entropy
#' @description  Computes the entropy.
#' Uses the formula `-sum(pk * log(pk))` where `pk` are discrete probabilities.
#' Return Null if input is not values
#' @param base  Given exponential base, defaults to `e`
#' @param normalize Normalize pk if it doesn't sum to 1.
#' @keywords Expr
#' @return Expr
#' @aliases entropy
#' @examples
#' pl$select(pl$lit(c("a", "b", "b", "c", "c", "c"))$unique_counts()$entropy(base = 2))
Expr_entropy = function(base = base::exp(1), normalize = TRUE) {
  .pr$Expr$entropy(self, base, normalize)
}

#' Cumulative eval
#' @description  Run an expression over a sliding window that increases `1` slot every iteration.
#' @param expr Expression to evaluate
#' @param min_periods Number of valid values there should be in the window before the expression
#' is evaluated. valid values = `length - null_count`
#' @param parallel Run in parallel. Don't do this in a groupby or another operation that
#' already has much parallelization.
#' @details
#'
#' Warnings
#'
#'   This functionality is experimental and may change without it being considered a
#' breaking change.
#' This can be really slow as it can have `O(n^2)` complexity. Don't use this
#'         for operations that visit all elements.
#' @keywords Expr
#' @return Expr
#' @aliases cumulative_eval
#' @examples
#' pl$lit(1:5)$cumulative_eval(pl$element()$first() - pl$element()$last()**2)$to_r()
Expr_cumulative_eval = function(expr, min_periods = 1L, parallel = FALSE) {
  unwrap(.pr$Expr$cumulative_eval(self, expr, min_periods, parallel))
}



#' Set_sorted
#' @description  Flags the expression as 'sorted'.
#* Enables downstream code to user fast paths for sorted arrays.
#' @param descending Sort the columns in descending order.
#' @keywords Expr
#' @return Expr
#' @aliases set_sorted
#' @examples
#' # correct use flag something correctly as ascendingly sorted
#' s = pl$select(pl$lit(1:4)$set_sorted()$alias("a"))$get_column("a")
#' s$flags # see flags
#'
#' # incorrect use, flag somthing as not sorted ascendingly
#' s2 = pl$select(pl$lit(c(1, 3, 2, 4))$set_sorted()$alias("a"))$get_column("a")
#' s2$sort() # sorting skipped, although not actually sorted
Expr_set_sorted = function(descending = FALSE) {
  self$map(\(s) {
    .pr$Series$set_sorted_mut(s, descending) # use private to bypass mut protection
    s
  })
}


#' Wrap column in list
#' @description  Aggregate values into a list.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases list
#' @name Expr_list
#' @details use to_struct to wrap a DataFrame. Notice implode() is sometimes referred to
#' as list() .
#' @format NULL
#' @examples
#' df = pl$DataFrame(
#'   a = 1:3,
#'   b = 4:6
#' )
#' df$select(pl$all()$implode())
Expr_implode = "use_extendr_wrapper"

## TODO REMOVE AT A BREAKING CHANGE
Expr_list = function() {
  if (is.null(runtime_state$warned_deprecate_list)) {
    runtime_state$warned_deprecate_list = TRUE
    warning("polars pl$list and <Expr>$list are deprecated, use $implode instead.")
  }
  self$implode()
}



#' Shrink numeric columns to the minimal required datatype.
#' @description
#' Shrink to the dtype needed to fit the extrema of this `[Series]`.
#' This can be used to reduce memory pressure.
#' @keywords Expr
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases shrink_dtype
#' @examples
#' pl$DataFrame(
#'   a = c(1L, 2L, 3L),
#'   b = c(1L, 2L, bitwShiftL(2L, 29)),
#'   c = c(-1L, 2L, bitwShiftL(1L, 15)),
#'   d = c(-112L, 2L, 112L),
#'   e = c(-112L, 2L, 129L),
#'   f = c("a", "b", "c"),
#'   g = c(0.1, 1.32, 0.12),
#'   h = c(TRUE, NA, FALSE)
#' )$with_columns(pl$col("b")$cast(pl$Int64) * 32L)$select(pl$all()$shrink_dtype())
Expr_shrink_dtype = "use_extendr_wrapper"



#' arr: list related methods DEPRECATED
#' @description
#' DEPRECATED FROM 0.9.0 USE `<Expr>$list$...` instead. Subnamespace is simple renamed.
#' @keywords Expr
#' @return Expr
#' @aliases arr_ns
#' @seealso \code{\link[=Expr_list]{<Expr>$list$...}}
Expr_arr = method_as_property(function() {
  if (!isTRUE(runtime_state$warned_deprecate_sns_arr)) {
    warning(
      "in <Expr>$list$: `<Expr>$list$...` is deprecated and removed from polars 0.9.0 . ",
      "Use `<Expr>$list$` instead. It is only a renaming to match py-polars renaming.",
      call. = FALSE
    )
    runtime_state$warned_deprecate_sns_arr = TRUE
  }
  expr_arr_make_sub_ns(self)
})

#' list: list related methods
#' @description
#' Create an object namespace of all list related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases list_ns
#' @examples
#' df_with_list = pl$DataFrame(
#'   group = c(1, 1, 2, 2, 3),
#'   value = c(1:5)
#' )$groupby(
#'   "group",
#'   maintain_order = TRUE
#' )$agg(
#'   pl$col("value") * 3L
#' )
#' df_with_list$with_columns(
#'   pl$col("value")$list$lengths()$alias("group_size")
#' )
Expr_list = method_as_property(function() {
  expr_arr_make_sub_ns(self)
})


#' str: string related methods
#' @description
#' Create an object namespace of all string related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases str_ns
#' @examples
#'
#' # missing
#'
Expr_str = method_as_property(function() {
  expr_str_make_sub_ns(self)
})


#' bin: binary related methods
#' @description
#' Create an object namespace of all binary related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases bin_ns
#' @examples
#'
#' # missing
#'
Expr_bin = method_as_property(function() {
  expr_bin_make_sub_ns(self)
})

#' dt: datetime related methods
#' @description
#' Create an object namespace of all datetime related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases dt_ns
#' @examples
#'
#' # missing
#'
Expr_dt = method_as_property(function() {
  expr_dt_make_sub_ns(self)
})

#' meta: related methods
#' @description
#' Create an object namespace of all meta related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases meta_ns
#' @examples
#'
#' # missing
#'
Expr_meta = method_as_property(function() {
  expr_meta_make_sub_ns(self)
})

#' cat: related methods
#' @description
#' Create an object namespace of all cat related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases cat_ns
#' @examples
#'
#' # missing
#'
Expr_cat = method_as_property(function() {
  expr_cat_make_sub_ns(self)
})

#' struct: related methods
#' @description
#' Create an object namespace of all struct related methods.
#' See the individual method pages for full details
#' @keywords Expr
#' @return Expr
#' @aliases struct_ns
#' @examples
#'
#' # missing
#'
Expr_struct = method_as_property(function() {
  expr_struct_make_sub_ns(self)
})

#' to_struct
#' @description pass expr to pl$struct
#' @keywords Expr
#' @return Expr
#' @aliases expr_to_struct
#' @keywords Expr
#' @examples
#' e = pl$all()$to_struct()$alias("my_struct")
#' print(e)
#' pl$DataFrame(iris)$select(e)
Expr_to_struct = function() {
  pl$struct(self)
}


#' Literal to Series
#' @description
#' collect an expression based on literals into a Series
#' @keywords Expr
#' @return Series
#' @aliases lit_to_s
#' @examples
#' (
#'   pl$Series(list(1:1, 1:2, 1:3, 1:4))
#'   $print()
#'   $to_lit()
#'   $list$lengths()
#'   $sum()
#'   $cast(pl$dtypes$Int8)
#'   $lit_to_s()
#' )
Expr_lit_to_s = function() {
  pl$select(self)$to_series(0)
}

#' Literal to DataFrame
#' @description
#' collect an expression based on literals into a DataFrame
#' @keywords Expr
#' @return Series
#' @aliases lit_to_df
#' @examples
#' (
#'   pl$Series(list(1:1, 1:2, 1:3, 1:4))
#'   $print()
#'   $to_lit()
#'   $list$lengths()
#'   $sum()
#'   $cast(pl$dtypes$Int8)
#'   $lit_to_df()
#' )
Expr_lit_to_df = function() {
  pl$select(self)
}
