#' Polars Expressions
#'
#' Expressions are all the functions and methods that are applicable to a Polars
#' DataFrame or LazyFrame. They can be split into the following categories
#' (following the [Py-Polars classification](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/)):
#'  * Aggregate
#'  * Binary
#'  * Categorical
#'  * Computation
#'  * Functions
#'  * List
#'  * Meta
#'  * Name
#'  * String
#'  * Struct
#'  * Temporal
#'
#' @name Expr_class
#' @rdname Expr_class
#'
#' @return not applicable
NULL


#' S3 method to print an Expr
#'
#' @param x Expr
#' @param ... Not used.
#'
#' @return No value returned, it prints in the console.
#' @export
#' @noRd
#'
#' @examples
#' print(pl$col("some_column")$sum())
print.RPolarsExpr = function(x, ...) {
  cat("polars Expr: ")
  x$print()
  invisible(x)
}

#' @noRd
Expr_print = function() {
  .pr$Expr$print(self)
  invisible(self)
}

#' Auto complete $-access into a polars object
#'
#' Called by the interactive R session internally
#'
#' @param x Name of an `Expr` object
#' @param pattern String used to auto-complete
#' @inherit .DollarNames.RPolarsDataFrame return
#' @export
#' @noRd
.DollarNames.RPolarsExpr = function(x, pattern = "") {
  paste0(ls(RPolarsExpr, pattern = pattern), "()")
}

#' S3 method to convert an Expr to a list
#'
#' @param x Expr
#' @param ... Not used.
#'
#' @return One Expr wrapped in a list
#' @export
#' @noRd
as.list.RPolarsExpr = function(x, ...) {
  list(x)
}

#' wrap as literal
#' @description use robj_to!(Expr) on rust side or rarely wrap_e on R-side
#' This function is only kept for reference
#' @param e an Expr(polars) or any R expression
#' @details
#' used internally to ensure an object is an expression
#' @noRd
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
#' @noRd
#' @return Expr
#' @examples pl$col("foo") < 5
wrap_e_result = function(e, str_to_lit = TRUE, argname = NULL) {
  # disable call info
  old_option = pl$options$do_not_repeat_call
  pl$set_options(do_not_repeat_call = TRUE)

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

  # restore this option but only if it was originally FALSE
  if (isFALSE(old_option)) {
    pl$set_options(do_not_repeat_call = FALSE)
  }

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
#' @return Expr
#' @examples .pr$env$wrap_elist_result(list(pl$lit(42), 42, 1:3))
wrap_elist_result = function(elist, str_to_lit = TRUE) {
  element_i = 0L
  result(
    {
      if (!is.list(elist) && length(elist) == 1L) elist = list(elist)
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


#' Add two expressions
#'
#' The RHS can either be an Expr or an object that can be converted to a literal
#' (e.g an integer).
#'
#' @param other Literal or object that can be converted to a literal
#' @return Expr
#' @examples
#' pl$lit(5) + 10
#' pl$lit(5) + pl$lit(10)
#' pl$lit(5)$add(pl$lit(10))
#' +pl$lit(5) # unary use resolves to same as pl$lit(5)
Expr_add = function(other) {
  .pr$Expr$add(self, other) |> unwrap("in $add()")
}

#' @export
#' @rdname Expr_add
#' @param e1 Expr only
#' @param e2 Expr or anything that can be converted to a literal
"+.RPolarsExpr" = function(e1, e2) {
  if (missing(e2)) {
    return(e1)
  }
  result(wrap_e(e1)$add(e2)) |> unwrap("using the '+'-operator")
}

#' Divide two expressions
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(5) / 10
#' pl$lit(5) / pl$lit(10)
#' pl$lit(5)$div(pl$lit(10))
Expr_div = function(other) {
  .pr$Expr$div(self, other) |> unwrap("in $div()")
}

#' @export
#' @rdname Expr_div
#' @inheritParams Expr_add
"/.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$div(e2)) |> unwrap("using the '/'-operator")

#' Floor divide two expressions
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(5) %/% 10
#' pl$lit(5) %/% pl$lit(10)
#' pl$lit(5)$floor_div(pl$lit(10))
Expr_floor_div = function(other) {
  .pr$Expr$floor_div(self, other) |> unwrap("in $floor_div()")
}

#' @export
#' @rdname Expr_floor_div
#' @inheritParams Expr_add
"%/%.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$floor_div(e2)) |> unwrap("using the '%/%'-operator")

#' Modulo two expressions
#'
#' @inherit Expr_add description params return
#'
#' @details Currently, the modulo operator behaves differently than in R,
#' and not guaranteed `x == (x %% y) + y * (x %/% y)`.
#' @examples
#' pl$select(pl$lit(-1:12) %% 3)$to_series()$to_vector()
#'
#' # The example is **NOT** equivalent to the followings:
#' -1:12 %% 3
#' pl$select(-1:12 %% 3)$to_series()$to_vector()
#'
#' # Not guaranteed `x == (x %% y) + y * (x %/% y)`
#' x = pl$lit(-1:12)
#' y = pl$lit(3)
#' pl$select(x == (x %% y) + y * (x %/% y))
Expr_mod = function(other) {
  .pr$Expr$rem(self, other) |> unwrap("in $mod()")
}

#' @export
#' @rdname Expr_mod
#' @inheritParams Expr_add
"%%.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$mod(e2)) |> unwrap("using the '%%'-operator")

#' Substract two expressions
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(5) - 10
#' pl$lit(5) - pl$lit(10)
#' pl$lit(5)$sub(pl$lit(10))
#' -pl$lit(5)
Expr_sub = function(other) {
  .pr$Expr$sub(self, other) |> unwrap("in $sub()")
}

#' @export
#' @rdname Expr_sub
#' @inheritParams Expr_add
"-.RPolarsExpr" = function(e1, e2) {
  result(
    if (missing(e2)) wrap_e(0L)$sub(e1) else wrap_e(e1)$sub(e2)
  ) |> unwrap("using the '-'-operator")
}

#' Multiply two expressions
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(5) * 10
#' pl$lit(5) * pl$lit(10)
#' pl$lit(5)$mul(pl$lit(10))
Expr_mul = Expr_mul = function(other) {
  .pr$Expr$mul(self, other) |> unwrap("in $mul()")
}

#' @export
#' @rdname Expr_mul
#' @inheritParams Expr_add
"*.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$mul(e2)) |> unwrap("using the '*'-operator")


#' Negate a boolean expression
#'
#' @inherit Expr_add description return
#' @docType NULL
#' @format NULL
#' @examples
#' # two syntaxes same result
#' pl$lit(TRUE)$not()
#' !pl$lit(TRUE)
Expr_not = use_extendr_wrapper
#' @export
#' @rdname Expr_not
#' @param x Expr
"!.RPolarsExpr" = function(x) x$not()

#' Check strictly lower inequality
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(5) < 10
#' pl$lit(5) < pl$lit(10)
#' pl$lit(5)$lt(pl$lit(10))
Expr_lt = function(other) {
  .pr$Expr$lt(self, other) |> unwrap("in $lt()")
}
#' @export
#' @inheritParams Expr_add
#' @rdname Expr_lt
"<.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$lt(e2)) |> unwrap("using the '<'-operator")

#' Check strictly greater inequality
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(2) > 1
#' pl$lit(2) > pl$lit(1)
#' pl$lit(2)$gt(pl$lit(1))
Expr_gt = function(other) {
  .pr$Expr$gt(self, other) |> unwrap("in $gt()")
}
#' @export
#' @inheritParams Expr_add
#' @rdname Expr_gt
">.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$gt(e2)) |> unwrap("using the '>'-operator")

#' Check equality
#'
#' @inherit Expr_add description params return
#'
#' @seealso [Expr_eq_missing]
#' @examples
#' pl$lit(2) == 2
#' pl$lit(2) == pl$lit(2)
#' pl$lit(2)$eq(pl$lit(2))
Expr_eq = function(other) {
  .pr$Expr$eq(self, other) |> unwrap("in $eq()")
}

#' @export
#' @inheritParams Expr_add
#' @rdname Expr_eq
"==.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$eq(e2)) |> unwrap("using the '=='-operator")

#' Check equality without `null` propagation
#'
#' @inherit Expr_add description params return
#'
#' @seealso [Expr_eq]
#' @examples
#' df = pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   eq = pl$col("x")$eq("y"),
#'   eq_missing = pl$col("x")$eq_missing("y")
#' )
Expr_eq_missing = function(other) {
  .pr$Expr$eq_missing(self, other) |> unwrap("in $eq_missing()")
}

#' Check inequality
#'
#' @inherit Expr_add description params return
#'
#' @seealso [Expr_neq_missing]
#' @examples
#' pl$lit(1) != 2
#' pl$lit(1) != pl$lit(2)
#' pl$lit(1)$neq(pl$lit(2))
Expr_neq = function(other) {
  .pr$Expr$neq(self, other) |> unwrap("in $neq()")
}

#' @export
#' @inheritParams Expr_add
#' @rdname Expr_neq
"!=.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$neq(e2)) |> unwrap("using the '!='-operator")

#' Check inequality without `null` propagation
#'
#' @inherit Expr_add description params return
#'
#' @seealso [Expr_neq]
#' @examples
#' df = pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   neq = pl$col("x")$neq("y"),
#'   neq_missing = pl$col("x")$neq_missing("y")
#' )
Expr_neq_missing = function(other) {
  .pr$Expr$neq_missing(self, other) |> unwrap("in $neq_missing()")
}

#' Check lower or equal inequality
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(2) <= 2
#' pl$lit(2) <= pl$lit(2)
#' pl$lit(2)$lt_eq(pl$lit(2))
Expr_lt_eq = function(other) {
  .pr$Expr$lt_eq(self, other) |> unwrap("in $lt_eq()")
}
#' @export
#' @inheritParams Expr_add
#' @rdname Expr_lt_eq
"<=.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$lt_eq(e2)) |> unwrap("using the '<='-operator")


#' Check greater or equal inequality
#'
#' @inherit Expr_add description params return
#'
#' @examples
#' pl$lit(2) >= 2
#' pl$lit(2) >= pl$lit(2)
#' pl$lit(2)$gt_eq(pl$lit(2))
Expr_gt_eq = function(other) {
  .pr$Expr$gt_eq(self, other) |> unwrap("in $gt_eq()")
}
#' @export
#' @inheritParams Expr_add
#' @rdname Expr_gt_eq
">=.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$gt_eq(e2)) |> unwrap("using the '>='-operator")



#' Aggregate groups
#'
#' Get the group indexes of the group by operation. Should be used in aggregation
#' context only.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' df = pl$DataFrame(list(
#'   group = c("one", "one", "one", "two", "two", "two"),
#'   value = c(94, 95, 96, 97, 97, 99)
#' ))
#' df$group_by("group", maintain_order = TRUE)$agg(pl$col("value")$agg_groups())
Expr_agg_groups = use_extendr_wrapper


#' Rename Expr output
#'
#' Rename the output of an expression.
#'
#' @param name New name of output
#' @return Expr
#' @docType NULL
#' @format NULL
#' @usage Expr_alias(name)
#' @examples pl$col("bob")$alias("alice")
Expr_alias = use_extendr_wrapper

#' Apply logical AND on a column
#'
#' Check if all boolean values in a Boolean column are `TRUE`. This method is an
#' expression - not to be confused with `pl$all()` which is a function to select
#' all columns.
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
#'   # the first $all() selects all columns, the second one applies the AND
#'   # logical on the values
#'   pl$all()$all()
#' )
Expr_all = function(drop_nulls = TRUE) {
  .pr$Expr$all(self, drop_nulls) |>
    unwrap("in $all()")
}

#' Apply logical OR on a column
#'
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

#' Count elements
#'
#' Count the number of elements in this expression. Note that `NULL` values are
#' also counted. `$len()` is an alias.
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
#'   pl$all()$count()
#' )
Expr_count = use_extendr_wrapper

#' @rdname Expr_count
Expr_len = use_extendr_wrapper

#' Drop missing values
#'
#' @seealso
#' `drop_nans()`
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, 2, NaN, NA)))$select(pl$col("x")$drop_nulls())
Expr_drop_nulls = use_extendr_wrapper

#' Drop NaN
#'
#' @details
#' Note that `NaN` values are not `null` values. Null values correspond to NA
#' in R.
#'
#' @seealso
#' `drop_nulls()`
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, 2, NaN, NA)))$select(pl$col("x")$drop_nans())
Expr_drop_nans = use_extendr_wrapper

#' Check if elements are NULL
#'
#' Returns a boolean Series indicating which values are null.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$is_null())
Expr_is_null = use_extendr_wrapper

#' Check if elements are not NULL
#'
#' Returns a boolean Series indicating which values are not null. Syntactic sugar
#' for `$is_null()$not()`.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(x = c(1, NA, 3)))$select(pl$col("x")$is_not_null())
Expr_is_not_null = use_extendr_wrapper


# TODO move this function in to rust with input list of args
# TODO deprecate context feature
#' construct proto Expr array from args
#' @noRd
#' @param ...  any Expr or string
#'
#'
#'
#' @return RPolarsProtoExprArray object
#'
#' @examples .pr$env$construct_ProtoExprArray(pl$col("Species"), "Sepal.Width")
construct_ProtoExprArray = function(...) {
  pra = RPolarsProtoExprArray$new()
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

#' Map an expression with an R function
#'
#' @param f a function to map with
#' @param output_type `NULL` or a type available in `names(pl$dtypes)`. If `NULL`
#' (default), the output datatype will match the input datatype. This is used
#' to inform schema of the actual return type of the R function. Setting this wrong
#' could theoretically have some downstream implications to the query.
#' @param agg_list Aggregate list. Map from vector to group in group_by context.
#' @param in_background Boolean. Whether to execute the map in a background R
#' process. Combined with setting e.g. `pl$set_options(rpool_cap = 4)` it can speed
#' up some slow R functions as they can run in parallel R sessions. The
#' communication speed between processes is quite slower than between threads.
#' This will likely only give a speed-up in a "low IO - high CPU" use case.
#' If there are multiple `$map(in_background = TRUE)` calls in the query, they
#' will be run in parallel.
#'
#' @return Expr
#' @details
#' It is sometimes necessary to apply a specific R function on one or several
#' columns. However, note that using R code in `$map()` is slower than native
#' polars. The user function must take one polars `Series` as input and the return
#' should be a `Series` or any Robj convertible into a `Series` (e.g. vectors).
#' Map fully supports `browser()`.
#'
#' If `in_background = FALSE` the function can access any global variable of the
#' R session. However, note that several calls to `$map()` will sequentially
#' share the same main R session, so the global environment might change between
#' the start of the query and the moment a `map()` call is evaluated. Any native
#' polars computations can still be executed meanwhile. If `in_background = TRUE`,
#' the map will run in one or more other R sessions and will not have access
#' to global variables. Use `pl$set_options(rpool_cap = 4)` and `pl$options$rpool_cap`
#' to see and view number of parallel R sessions.
#'
#' @examples
#' pl$DataFrame(iris)$
#'   select(
#'   pl$col("Sepal.Length")$map_batches(\(x) {
#'     paste("cheese", as.character(x$to_vector()))
#'   }, pl$dtypes$String)
#' )
#'
#' # R parallel process example, use Sys.sleep() to imitate some CPU expensive
#' # computation.
#'
#' # map a,b,c,d sequentially
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map_batches(\(s) {
#'     Sys.sleep(.1)
#'     s * 2
#'   })
#' )$collect() |> system.time()
#'
#' # map in parallel 1: Overhead to start up extra R processes / sessions
#' pl$set_options(rpool_cap = 0) # drop any previous processes, just to show start-up overhead
#' pl$set_options(rpool_cap = 4) # set back to 4, the default
#' pl$options$rpool_cap
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map_batches(\(s) {
#'     Sys.sleep(.1)
#'     s * 2
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
#'
#' # map in parallel 2: Reuse R processes in "polars global_rpool".
#' pl$options$rpool_cap
#' pl$LazyFrame(a = 1, b = 2, c = 3, d = 4)$select(
#'   pl$all()$map_batches(\(s) {
#'     Sys.sleep(.1)
#'     s * 2
#'   }, in_background = TRUE)
#' )$collect() |> system.time()
Expr_map_batches = function(f, output_type = NULL, agg_list = FALSE, in_background = FALSE) {
  if (isTRUE(in_background)) {
    out = .pr$Expr$map_batches_in_background(self, f, output_type, agg_list)
  } else {
    out = .pr$Expr$map_batches(self, f, output_type, agg_list)
  }

  out |>
    unwrap("in $map_batches():")
}

Expr_map = function(f, output_type = NULL, agg_list = FALSE, in_background = FALSE) {
  warning("$map() is deprecated and will be removed in 0.13.0. Use $map_batches() instead.", call. = FALSE)
  if (isTRUE(in_background)) {
    out = .pr$Expr$map_batches_in_background(self, f, output_type, agg_list)
  } else {
    out = .pr$Expr$map_batches(self, f, output_type, agg_list)
  }

  out |>
    unwrap("in $map():")
}

#' Map a custom/user-defined function (UDF) to each element of a column
#'
#' The UDF is applied to each element of a column. See Details for more information
#' on specificities related to the context.
#'
#' @param f Function to map
#' @param return_type DataType of the output Series. If `NULL`, the dtype will
#' be `pl$Unknown`.
#' @param strict_return_type If `TRUE` (default), error if not correct datatype
#' returned from R. If `FALSE`, the output will be converted to a polars null
#' value.
#' @param allow_fail_eval If `FALSE` (default), raise an error if the function
#' fails. If `TRUE`, the result will be converted to a polars null value.
#' @param in_background Whether to run the function in a background R process,
#' default is `FALSE`. Combined with setting e.g. `pl$set_options(rpool_cap = 4)`,
#' this can speed up some slow R functions as they can run in parallel R sessions.
#' The communication speed between processes is quite slower than between threads.
#' This will likely only give a speed-up in a "low IO - high CPU" usecase. A
#' single map will not be paralleled, only in case of multiple `$map_elements()`
#' in the query can these run in parallel.
#'
#' @details
#'
#' Note that, in a GroupBy context, the column will have been pre-aggregated and
#' so each element will itself be a Series. Therefore, depending on the context,
#' requirements for function differ:
#' * in `$select()` or `$with_columns()` (selection context), the function must
#'   operate on R scalar values. Polars will convert each element into an R value
#'   and pass it to the function. The output of the user function will be converted
#'   back into a polars type (the return type must match, see argument `return_type`).
#'   Using `$map_elements()` in this context should be avoided as a `lapply()`
#'   has half the overhead.
#' * in `$agg()` (GroupBy context), the function must take a `Series` and return
#'   a `Series` or an R object convertible to `Series`, e.g. a vector. In this
#'   context, it is much faster if there are the number of groups is much lower
#'   than the number of rows, as the iteration is only across the groups. The R
#'   user function could e.g. convert the `Series` to a vector with `$to_r()` and
#'   perform some vectorized operations.
#'
#' Note that it is preferred to express your function in polars syntax, which
#' will almost always be _significantly_ faster and more memory efficient because:
#' * the native expression engine runs in Rust; functions run in R.
#' * use of R functions forces the DataFrame to be materialized in memory.
#' * Polars-native expressions can be parallelized (R functions cannot).
#' * Polars-native expressions can be logically optimized (R functions cannot).
#'
#' Wherever possible you should strongly prefer the native expression API to
#' achieve the best performance and avoid using `$map_elements()`.
#'
#' @return Expr
#' @examples
#' # apply over groups: here, the input must be a Series
#' # prepare two expressions, one to compute the sum of each variable, one to
#' # get the first two values of each variable and store them in a list
#' e_sum = pl$all()$map_elements(\(s) sum(s$to_r()))$name$suffix("_sum")
#' e_head = pl$all()$map_elements(\(s) head(s$to_r(), 2))$name$suffix("_head")
#' pl$DataFrame(iris)$group_by("Species")$agg(e_sum, e_head)
#'
#' # apply a function on each value (should be avoided): here the input is an R
#' # scalar
#' # select only Float64 columns
#' my_selection = pl$col(pl$dtypes$Float64)
#'
#' # prepare two expressions, the first one only adds 10 to each element, the
#' # second returns the letter whose index matches the element
#' e_add10 = my_selection$map_elements(\(x)  {
#'   x + 10
#' })$name$suffix("_sum")
#'
#' e_letter = my_selection$map_elements(\(x) {
#'   letters[ceiling(x)]
#' }, return_type = pl$dtypes$String)$name$suffix("_letter")
#' pl$DataFrame(iris)$select(e_add10, e_letter)
#'
#'
#' # Small benchmark --------------------------------
#'
#' # Using `$map_elements()` is much slower than a more polars-native approach.
#' # First we multiply each element of a Series of 1M elements by 2.
#' n = 1000000L
#' set.seed(1)
#' df = pl$DataFrame(list(
#'   a = 1:n,
#'   b = sample(letters, n, replace = TRUE)
#' ))
#'
#' system.time({
#'   df$with_columns(
#'     bob = pl$col("a")$map_elements(\(x) {
#'       x * 2L
#'     })
#'   )
#' })
#'
#' # Comparing this to the standard polars syntax:
#' system.time({
#'   df$with_columns(
#'     bob = pl$col("a") * 2L
#'   )
#' })
#'
#'
#' # Running in parallel --------------------------------
#'
#' # here, we use Sys.sleep() to imitate some CPU expensive computation.
#'
#' # use apply over each Species-group in each column equal to 12 sequential
#' # runs ~1.2 sec.
#' system.time({
#'   pl$LazyFrame(iris)$group_by("Species")$agg(
#'     pl$all()$map_elements(\(s) {
#'       Sys.sleep(.1)
#'       s$sum()
#'     })
#'   )$collect()
#' })
#'
#' # first run in parallel: there is some overhead to start up extra R processes
#' # drop any previous processes, just to show start-up overhead here
#' pl$set_options(rpool_cap = 0)
#' # set back to 4, the default
#' pl$set_options(rpool_cap = 4)
#' pl$options$rpool_cap
#'
#' system.time({
#'   pl$LazyFrame(iris)$group_by("Species")$agg(
#'     pl$all()$map_elements(\(s) {
#'       Sys.sleep(.1)
#'       s$sum()
#'     }, in_background = TRUE)
#'   )$collect()
#' })
#'
#' # second run in parallel: this reuses R processes in "polars global_rpool".
#' pl$options$rpool_cap
#' system.time({
#'   pl$LazyFrame(iris)$group_by("Species")$agg(
#'     pl$all()$map_elements(\(s) {
#'       Sys.sleep(.1)
#'       s$sum()
#'     }, in_background = TRUE)
#'   )$collect()
#' })
Expr_map_elements = function(f, return_type = NULL, strict_return_type = TRUE, allow_fail_eval = FALSE, in_background = FALSE) {
  if (in_background) {
    return(.pr$Expr$map_elements_in_background(self, f, return_type))
  }

  # use series apply
  wrap_f = function(s) {
    s$map_elements(f, return_type, strict_return_type, allow_fail_eval)
  }

  # return expression from the functions above, activate agg_list (grouped mapping)
  .pr$Expr$map_batches(self, lambda = wrap_f, output_type = return_type, agg_list = TRUE) |>
    unwrap("in $map_elements():")
}

Expr_apply = function(f, return_type = NULL, strict_return_type = TRUE,
                      allow_fail_eval = FALSE, in_background = FALSE) {
  warning("$apply() is deprecated and will be removed in 0.13.0. Use $map_elements() instead.", call. = FALSE)
  if (in_background) {
    return(.pr$Expr$map_elements_in_background(self, f, return_type))
  }

  # use series apply
  wrap_f = function(s) {
    s$map_elements(f, return_type, strict_return_type, allow_fail_eval)
  }

  # return expression from the functions above, activate agg_list (grouped mapping)
  .pr$Expr$map_batches(self, lambda = wrap_f, output_type = return_type, agg_list = TRUE) |>
    unwrap("in $apply():")
}

#' Create a literal value
#'
#' @param x A vector of any length
#'
#' @return Expr
#'
#' @details
#' `pl$lit(NULL)` translates into a polars `null`.
#'
#' @examples
#' # scalars to literal, explicit `pl$lit(42)` implicit `+ 2`
#' pl$col("some_column") / pl$lit(42) + 2
#'
#' # vector to literal explicitly via Series and back again
#' # R vector to expression and back again
#' pl$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]]
#'
#' # r vector to literal and back r vector
#' pl$lit(1:4)$to_r()
#'
#' # r vector to literal to dataframe
#' pl$select(pl$lit(1:4))
#'
#' # r vector to literal to Series
#' pl$lit(1:4)$to_series()
#'
#' # vectors to literal implicitly
#' (pl$lit(2) + 1:4) / 4:1
Expr_lit = function(x) {
  .Call(wrap__RPolarsExpr__lit, x) |>
    unwrap("in $lit()")
}

#' Reverse a variable
#' @return Expr
#' @name Expr_reverse
#' @examples
#' pl$DataFrame(list(a = 1:5))$select(pl$col("a")$reverse())
Expr_reverse = function() {
  .pr$Expr$reverse(self)
}



#' Apply logical AND on two expressions
#'
#' Combine two boolean expressions with AND.
#' @inherit Expr_add params return
#' @docType NULL
#' @format NULL
#' @examples
#' pl$lit(TRUE) & TRUE
#' pl$lit(TRUE)$and(pl$lit(TRUE))
Expr_and = function(other) {
  .pr$Expr$and(self, other) |> unwrap("in $and()")
}
#' @export
"&.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$and(e2)) |> unwrap("using the '&'-operator")


#' Apply logical OR on two expressions
#'
#' Combine two boolean expressions with OR.
#'
#' @inherit Expr_add params return
#' @docType NULL
#' @format NULL
#' @examples
#' pl$lit(TRUE) | FALSE
#' pl$lit(TRUE)$or(pl$lit(TRUE))
Expr_or = function(other) {
  .pr$Expr$or(self, other) |> unwrap("in $or()")
}
#' @export
"|.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$or(e2)) |> unwrap("using the '|'-operator")


#' Apply logical XOR on two expressions
#'
#' Combine two boolean expressions with XOR.
#' @inherit Expr_add params return
#' @docType NULL
#' @format NULL
#' @examples
#' pl$lit(TRUE)$xor(pl$lit(FALSE))
Expr_xor = function(other) {
  .pr$Expr$xor(self, other) |> unwrap("in $xor()")
}

#' Cast an Expr to its physical representation
#'
#' The following DataTypes will be converted:
#' * Date -> Int32
#' * Datetime -> Int64
#' * Time -> Int64
#' * Duration -> Int64
#' * Categorical -> UInt32
#' * List(inner) -> List(physical of inner)
#' Other data types will be left unchanged.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases to_physical
#' @name Expr_to_physical
#' @examples
#' pl$DataFrame(
#'   list(vals = c("a", "x", NA, "a", "b"))
#' )$with_columns(
#'   pl$col("vals")$cast(pl$Categorical),
#'   pl$col("vals")
#'   $cast(pl$Categorical)
#'   $to_physical()
#'   $alias("vals_physical")
#' )
Expr_to_physical = use_extendr_wrapper


#' Cast between DataType
#'
#' @param dtype DataType to cast to.
#' @param strict If `TRUE` (default), an error will be thrown if cast failed at
#' resolve time.
#' @return Expr
#' @examples
#' df = pl$DataFrame(a = 1:3, b = c(1, 2, 3))
#' df$with_columns(
#'   pl$col("a")$cast(pl$dtypes$Float64),
#'   pl$col("b")$cast(pl$dtypes$Int32)
#' )
#'
#' # strict FALSE, inserts null for any cast failure
#' pl$lit(c(100, 200, 300))$cast(pl$dtypes$UInt8, strict = FALSE)$to_series()
#'
#' # strict TRUE, raise any failure as an error when query is executed.
#' tryCatch(
#'   {
#'     pl$lit("a")$cast(pl$dtypes$Float64, strict = TRUE)$to_series()
#'   },
#'   error = function(e) e
#' )
Expr_cast = function(dtype, strict = TRUE) {
  .pr$Expr$cast(self, dtype, strict)
}

#' Compute the square root of the elements
#'
#' @return Expr
#' @examples
#' pl$DataFrame(a = -1:3)$with_columns(a_sqrt = pl$col("a")$sqrt())
Expr_sqrt = function() {
  self$pow(0.5)
}

#' Compute the exponential of the elements
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = -1:3)$with_columns(a_exp = pl$col("a")$exp())
Expr_exp = use_extendr_wrapper


#' Exclude certain columns from selection
#'
#' @param columns Given param type:
#'  - string: single column name or regex starting with `^` and ending with `$`
#'  - character vector: exclude all these column names, no regex allowed
#'  - DataType: Exclude any of this DataType
#'  - List(DataType): Exclude any of these DataType(s)
#'
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
  if (is.list(columns)) {
    columns = pcase(
      all(sapply(columns, inherits, "RPolarsDataType")), unwrap(.pr$DataTypeVector$from_rlist(columns)),
      all(sapply(columns, is_string)), unlist(columns),
      or_else = pstop(err = paste0("only lists of pure RPolarsDataType or String"))
    )
  }

  pcase(
    is.character(columns), .pr$Expr$exclude(self, columns),
    inherits(columns, "RPolarsDataTypeVector"), .pr$Expr$exclude_dtype(self, columns),
    inherits(columns, "RPolarsDataType"), .pr$Expr$exclude_dtype(self, unwrap(.pr$DataTypeVector$from_rlist(list(columns)))),
    or_else = pstop(err = paste0("this type is not supported for Expr_exclude: ", columns))
  )
}

#' Check if elements are finite
#'
#' Returns a boolean Series indicating which values are finite.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$
#'   with_columns(finite = pl$col("alice")$is_finite())
Expr_is_finite = use_extendr_wrapper


#' Check if elements are infinite
#'
#' Returns a boolean Series indicating which values are infinite.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_infinite
#' @name Expr_is_infinite
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$
#'   with_columns(infinite = pl$col("alice")$is_infinite())
Expr_is_infinite = use_extendr_wrapper


#' Check if elements are NaN
#'
#' Returns a boolean Series indicating which values are NaN.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_nan
#' @name Expr_is_nan
#'
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$
#'   with_columns(nan = pl$col("alice")$is_nan())
Expr_is_nan = use_extendr_wrapper


#' Check if elements are not NaN
#'
#' Returns a boolean Series indicating which values are not NaN. Syntactic sugar
#' for `$is_nan()$not()`.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @aliases is_not_nan
#' @name Expr_is_not_nan
#' @format NULL
#' @examples
#' pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$
#'   with_columns(not_nan = pl$col("alice")$is_not_nan())
Expr_is_not_nan = use_extendr_wrapper

#' Get a slice of an Expr
#'
#' Performing a slice of length 1 on a subset of columns will recycle this value
#' in those columns but will not change the number of rows in the data. See
#' examples.
#'
#' @param offset Numeric or expression, zero-indexed. Indicates where to start
#' the slice. A negative value is one-indexed and starts from the end.
#' @param length Maximum number of elements contained in the slice. Default is
#' full data.
#'
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
#'
#' # recycling
#' pl$DataFrame(mtcars)$with_columns(pl$col("mpg")$slice(0, 1))
Expr_slice = function(offset, length = NULL) {
  .pr$Expr$slice(self, wrap_e(offset), wrap_e(length))
}


#' Append expressions
#'
#' This is done by adding the chunks of `other` to this `output`.
#'
#' @param other Expr or something coercible to an Expr.
#' @param upcast Cast both Expr to a common supertype if they have one.
#'
#' @return Expr
#' @name Expr_append
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
#'
#' Create a single chunk of memory for this Series.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' See rechunk() explained here \code{\link[polars]{docs_translations}}.
#' @examples
#' # get chunked lengths with/without rechunk
#' series_list = pl$DataFrame(list(a = 1:3, b = 4:6))$select(
#'   pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
#'   pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
#' )$get_columns()
#' lapply(series_list, \(x) x$chunk_lengths())
Expr_rechunk = use_extendr_wrapper

#' Cumulative sum
#'
#' Get an array with the cumulative sum computed at every element.
#'
#' @param reverse If `TRUE`, start with the total sum of elements and substract
#' each row one by one.
#' @return Expr
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   pl$col("a")$cum_sum()$alias("cum_sum"),
#'   pl$col("a")$cum_sum(reverse = TRUE)$alias("cum_sum_reversed")
#' )
Expr_cum_sum = function(reverse = FALSE) {
  .pr$Expr$cum_sum(self, reverse) |>
    unwrap("in cum_sum():")
}


#' Cumulative product
#'
#' Get an array with the cumulative product computed at every element.
#'
#' @param reverse If `TRUE`, start with the total product of elements and divide
#' each row one by one.
#' @inherit Expr_cum_sum return details
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   pl$col("a")$cum_prod()$alias("cum_prod"),
#'   pl$col("a")$cum_prod(reverse = TRUE)$alias("cum_prod_reversed")
#' )
Expr_cum_prod = function(reverse = FALSE) {
  .pr$Expr$cum_prod(self, reverse) |>
    unwrap("in cum_prod():")
}

#' Cumulative minimum
#'
#' Get an array with the cumulative min computed at every element.
#'
#' @param reverse If `TRUE`, start from the last value.
#' @inherit Expr_cum_sum return details
#' @examples
#' pl$DataFrame(a = c(1:4, 2L))$with_columns(
#'   pl$col("a")$cum_min()$alias("cum_min"),
#'   pl$col("a")$cum_min(reverse = TRUE)$alias("cum_min_reversed")
#' )
Expr_cum_min = function(reverse = FALSE) {
  .pr$Expr$cum_min(self, reverse) |>
    unwrap("in cum_min():")
}

#' Cumulative maximum
#'
#' Get an array with the cumulative max computed at every element.
#'
#' @param reverse If `TRUE`, start from the last value.
#' @inherit Expr_cum_sum return details
#' @examples
#' pl$DataFrame(a = c(1:4, 2L))$with_columns(
#'   pl$col("a")$cum_max()$alias("cummux"),
#'   pl$col("a")$cum_max(reverse = TRUE)$alias("cum_max_reversed")
#' )
Expr_cum_max = function(reverse = FALSE) {
  .pr$Expr$cum_max(self, reverse) |>
    unwrap("in cum_max():")
}

#' Cumulative count
#'
#' Get an array with the cumulative count (zero-indexed) computed at every element.
#'
#' @param reverse If `TRUE`, reverse the count.
#' @return Expr
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#'
#' `$cum_count()` does not seem to count within lists.
#'
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   pl$col("a")$cum_count()$alias("cum_count"),
#'   pl$col("a")$cum_count(reverse = TRUE)$alias("cum_count_reversed")
#' )
Expr_cum_count = function(reverse = FALSE) {
  .pr$Expr$cum_count(self, reverse) |>
    unwrap("in cum_count():")
}


#' Floor
#'
#' Rounds down to the nearest integer value. Only works on floating point Series.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf))$with_columns(
#'   floor = pl$col("a")$floor()
#' )
Expr_floor = use_extendr_wrapper

#' Ceiling
#'
#' Rounds up to the nearest integer value. Only works on floating point Series.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf))$with_columns(
#'   ceiling = pl$col("a")$ceil()
#' )
Expr_ceil = use_extendr_wrapper

#' Round
#'
#' Round underlying floating point data by `decimals` digits.
#' @param decimals Number of decimals to round by.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(0.33, 0.5, 1.02, 1.5, NaN, NA, Inf, -Inf))$with_columns(
#'   round = pl$col("a")$round(1)
#' )
Expr_round = function(decimals) {
  unwrap(.pr$Expr$round(self, decimals))
}


# TODO contribute polars, dot product unwraps if datatypes, pass Result instead

#' Dot product
#'
#' Compute the dot/inner product between two Expressions.
#'
#' @inherit Expr_add params return
#' @examples
#' pl$DataFrame(
#'   a = 1:4, b = c(1, 2, 3, 4)
#' )$with_columns(
#'   pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
#'   pl$col("a")$dot(pl$col("a"))$alias("a dot a")
#' )
Expr_dot = function(other) {
  .pr$Expr$dot(self, wrap_e(other))
}


#' Mode
#'
#' Compute the most occurring value(s). Can return multiple values if there are
#' ties.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' df = pl$DataFrame(a = 1:6, b = c(1L, 1L, 3L, 3L, 5L, 6L), c = c(1L, 1L, 2L, 2L, 3L, 3L))
#' df$select(pl$col("a")$mode())
#' df$select(pl$col("b")$mode())
#' df$select(pl$col("c")$mode())
Expr_mode = use_extendr_wrapper


#' Sort an Expr
#'
#' Sort this column. If used in a groupby context, the groups are sorted.
#'
#' @param descending Sort in descending order. When sorting by multiple columns,
#' can be specified per column by passing a vector of booleans.
#' @param nulls_last If `TRUE`, place nulls values last.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(6, 1, 0, NA, Inf, NaN))$
#'   with_columns(sorted = pl$col("a")$sort())
Expr_sort = function(descending = FALSE, nulls_last = FALSE) {
  .pr$Expr$sort(self, descending, nulls_last)
}


# TODO contribute polars, add arguments for Null/NaN/inf last/first, top_k unwraps k> len column

#' Top k values
#'
#' Return the `k` largest elements. This has time complexity: \eqn{ O(n + k
#' \\log{}n - \frac{k}{2}) }
#'
#' @param k Number of top values to get
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(6, 1, 0, NA, Inf, NaN))$select(pl$col("a")$top_k(5))
Expr_top_k = function(k) {
  if (!is.numeric(k) || k < 0) stop("k must be numeric and positive, prefereably integerish")
  .pr$Expr$top_k(self, k) |>
    unwrap("in $top_k():")
}

# TODO contribute polars, add arguments for Null/NaN/inf last/first, bottom_k unwraps k> len column

#' Bottom k values
#'
#' Return the `k` smallest elements. This has time complexity: \eqn{ O(n + k
#' \\log{}n - \frac{k}{2}) }
#'
#' @inherit Expr_top_k params return
#' @examples
#' pl$DataFrame(a = c(6, 1, 0, NA, Inf, NaN))$select(pl$col("a")$bottom_k(5))
Expr_bottom_k = function(k) {
  if (!is.numeric(k) || k < 0) stop("k must be numeric and positive, prefereably integerish")
  .pr$Expr$bottom_k(self, k) |>
    unwrap("in $bottom_k():")
}

#' Index of a sort
#'
#' Get the index values that would sort this column.
#'
#' @inherit Expr_sort params return
#' @examples
#' pl$DataFrame(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' )$with_columns(arg_sorted = pl$col("a")$arg_sort())
Expr_arg_sort = function(descending = FALSE, nulls_last = FALSE) {
  .pr$Expr$arg_sort(self, descending, nulls_last)
}

#' @inherit Expr_arg_sort title params examples
#' @description argsort is a alias for arg_sort
Expr_argsort = Expr_arg_sort

#' Index of min value
#'
#' Get the index of the minimal value.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' )$with_columns(arg_min = pl$col("a")$arg_min())
Expr_arg_min = use_extendr_wrapper

#' Index of max value
#'
#' Get the index of the maximal value.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' )$with_columns(arg_max = pl$col("a")$arg_max())
Expr_arg_max = use_extendr_wrapper


# TODO contribute pypolars search_sorted behavior is under-documented, does multiple elements work?

#' Where to inject element(s) to maintain sorting
#'
#' Find the index in self where the element should be inserted so that it doesn't
#' break sortedness.
#' @param element Expr or scalar value.
#' @return Expr
#' @details
#' This function looks up where to insert element to keep self column sorted.
#' It is assumed the self column is already sorted in ascending order (otherwise
#' this leads to wrong results).
#' @examples
#' df = pl$DataFrame(a = c(1, 3, 4, 4, 6))
#' df
#'
#' # in which row should 5 be inserted in order to not break the sort?
#' # (value is 0-indexed)
#' df$select(pl$col("a")$search_sorted(5))
Expr_search_sorted = function(element) {
  .pr$Expr$search_sorted(self, wrap_e(element))
}

#' Sort Expr by order of others
#'
#' Sort this column by the ordering of another column, or multiple other columns.
#' If used in a groupby context, the groups are sorted.
#'
#' @param by One expression or a list of expressions and/or strings (interpreted
#'  as column names).
#' @inheritParams Expr_sort
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   group = c("a", "a", "a", "b", "b", "b"),
#'   value1 = c(98, 1, 3, 2, 99, 100),
#'   value2 = c("d", "f", "b", "e", "c", "a")
#' )
#'
#' # by one column/expression
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by("value1")
#' )
#'
#' # by two columns/expressions
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by(
#'     list("value2", pl$col("value1")),
#'     descending = c(TRUE, FALSE)
#'   )
#' )
#'
#' # by some expression
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by(pl$col("value1")$sort(descending = TRUE))
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
# pl.RPolarsDataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(5294967296.0)) #return Null
# pl.RPolarsDataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(-3)) #return Null
# pl.RPolarsDataFrame({"a":[0,1,2,3,4],"b":[4,3,2,1,0]}).select(pl.col("a").take(7)) #return Error

#' Gather values by index
#'
#' @param indices R scalar/vector or Series, or Expr that leads to a Series of
#' dtype Int64. (0-indexed)
#' @return Expr
#' @examples
#' df = pl$DataFrame(a = 1:10)
#'
#' df$select(pl$col("a")$gather(c(0, 2, 4, -1)))
Expr_gather = function(indices) {
  .pr$Expr$gather(self, pl$lit(indices)) |>
    unwrap("in $gather():")
}

#' Shift values
#'
#' @param periods Number of periods to shift, may be negative.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(1, 2, 4, 5, 8))$
#'   with_columns(
#'   pl$col("a")$shift(-2)$alias("shift-2"),
#'   pl$col("a")$shift(2)$alias("shift+2")
#' )
Expr_shift = function(periods = 1) {
  .pr$Expr$shift(self, periods) |>
    unwrap("in $shift():")
}

#' Shift and fill values
#'
#' Shift the values by a given period and fill the resulting null values.
#'
#' @inheritParams Expr_shift
#' @param fill_value Fill null values with the result of this expression.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(1, 2, 4, 5, 8))$
#'   with_columns(
#'   pl$col("a")$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
#'   pl$col("a")$shift_and_fill(2, fill_value = pl$col("a") / 2)$alias("shift+2")
#' )
Expr_shift_and_fill = function(periods, fill_value) {
  .pr$Expr$shift_and_fill(self, periods, pl$lit(fill_value)) |>
    unwrap("in $shift_and_fill():")
}

#' Fill null values with a value or strategy
#'
#' @param value Expr or something coercible in an Expr
#' @param strategy Possible choice are `NULL` (default, requires a non-null
#' `value`), `"forward"`, `"backward"`, `"min"`, `"max"`, `"mean"`, `"zero"`,
#' `"one"`.
#' @param limit Number of consecutive null values to fill when using the
#' `"forward"` or `"backward"` strategy.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(NA, 1, NA, 2, NA))$
#'   with_columns(
#'   value = pl$col("a")$fill_null(999),
#'   backward = pl$col("a")$fill_null(strategy = "backward"),
#'   mean = pl$col("a")$fill_null(strategy = "mean")
#' )
Expr_fill_null = function(value = NULL, strategy = NULL, limit = NULL) {
  pcase(
    # the wrong stuff
    is.null(value) && is.null(strategy), stop("must specify either value or strategy"),
    !is.null(value) && !is.null(strategy), stop("cannot specify both value and strategy"),
    !is.null(strategy) && !strategy %in% c("forward", "backward") && !is.null(limit), stop(
      "can only specify 'limit' when strategy is set to 'backward' or 'forward'"
    ),

    # the two use cases
    !is.null(value), unwrap(.pr$Expr$fill_null(self, value)),
    is.null(value), unwrap(.pr$Expr$fill_null_with_strategy(self, strategy, limit)),

    # catch failed any match
    or_else = stop("Internal: failed to handle user inputs")
  )
}


#' Fill null values backward
#'
#' Fill missing values with the next to be seen values. Syntactic sugar for
#' `$fill_null(strategy = "backward")`.
#'
#' @inheritParams Expr_fill_null
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(NA, 1, NA, 2, NA))$
#'   with_columns(
#'   backward = pl$col("a")$backward_fill()
#' )
Expr_backward_fill = function(limit = NULL) {
  .pr$Expr$backward_fill(self, limit)
}

#' Fill null values forward
#'
#' Fill missing values with the last seen values. Syntactic sugar for
#' `$fill_null(strategy = "forward")`.
#'
#' @inheritParams Expr_fill_null
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(NA, 1, NA, 2, NA))$
#'   with_columns(
#'   backward = pl$col("a")$forward_fill()
#' )
Expr_forward_fill = function(limit = NULL) {
  .pr$Expr$forward_fill(self, limit)
}


#' Fill NaN
#'
#' @param expr Expr or something coercible in an Expr
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(NaN, 1, NaN, 2, NA))$
#'   with_columns(
#'   literal = pl$col("a")$fill_nan(999),
#'   # implicit coercion to string
#'   string = pl$col("a")$fill_nan("invalid")
#' )
Expr_fill_nan = function(expr = NULL) {
  .pr$Expr$fill_nan(self, wrap_e(expr))
}


#' Get standard deviation
#'
#' @param ddof Degrees of freedom, must be an integer between 0 and 255
#' @return Expr
#'
#' @examples
#' pl$select(pl$lit(1:5)$std())
Expr_std = function(ddof = 1) {
  .pr$Expr$std(self, ddof) |>
    unwrap("in $std():")
}

#' Get variance
#'
#' @inherit Expr_std params return
#'
#' @examples
#' pl$select(pl$lit(1:5)$var())
Expr_var = function(ddof = 1) {
  .pr$Expr$var(self, ddof) |>
    unwrap("in $var():")
}

#' Get maximum value
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1, NA, 3))$
#'   with_columns(max = pl$col("x")$max())
Expr_max = use_extendr_wrapper

#' Get minimum value
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1, NA, 3))$
#'   with_columns(min = pl$col("x")$min())
Expr_min = use_extendr_wrapper



# TODO Contribute polars, nan_max and nan_min poison on NaN. But no method poison on `Null`
# In R both NA and NaN poisons, but NA has priority which is meaningful, as NA is even less information
# then NaN.

#' Get maximum value with NaN
#'
#' Get maximum value, but returns `NaN` if there are any.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1, NA, 3, NaN, Inf))$
#'   with_columns(nan_max = pl$col("x")$nan_max())
Expr_nan_max = use_extendr_wrapper

#' Get minimum value with NaN
#'
#' Get minimum value, but returns `NaN` if there are any.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1, NA, 3, NaN, Inf))$
#'   with_columns(nan_min = pl$col("x")$nan_min())
Expr_nan_min = use_extendr_wrapper

#' Get sum value
#'
#' @details
#' The dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1L, NA, 2L))$
#'   with_columns(sum = pl$col("x")$sum())
Expr_sum = use_extendr_wrapper

#' Get mean value
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1L, NA, 2L))$
#'   with_columns(mean = pl$col("x")$mean())
Expr_mean = use_extendr_wrapper

#' Get median value
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(1L, NA, 2L))$
#'   with_columns(median = pl$col("x")$median())
Expr_median = use_extendr_wrapper

#' Product
#'
#' Compute the product of an expression.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(2L, NA, 2L))$
#'   with_columns(product = pl$col("x")$product())
Expr_product = use_extendr_wrapper

#' Count number of unique values
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(iris[, 4:5])$with_columns(count = pl$col("Species")$n_unique())
Expr_n_unique = use_extendr_wrapper

#' Approx count unique values
#'
#' This is done using the HyperLogLog++ algorithm for cardinality estimation.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(iris[, 4:5])$
#'   with_columns(count = pl$col("Species")$approx_n_unique())
Expr_approx_n_unique = use_extendr_wrapper

#' Count missing values
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = c(NA, "a", NA, "b"))$
#'   with_columns(n_missing = pl$col("x")$null_count())
Expr_null_count = use_extendr_wrapper

#' Index of first unique values
#'
#' This finds the position of first occurrence of each unique value.
#' @aliases arg_unique
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$select(pl$lit(c(1:2, 1:3))$arg_unique())
Expr_arg_unique = use_extendr_wrapper

#' Get unique values
#'
#' @param maintain_order If `TRUE`, the unique values are returned in order of
#' appearance.
#' @return Expr
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$unique())
Expr_unique = function(maintain_order = FALSE) {
  if (!is_bool(maintain_order)) stop("param maintain_order must be a bool")
  if (maintain_order) {
    .pr$Expr$unique_stable(self)
  } else {
    .pr$Expr$unique(self)
  }
}

#' Get the first value.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = 3:1)$with_columns(first = pl$col("x")$first())
Expr_first = use_extendr_wrapper

#' Get the last value
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(x = 3:1)$with_columns(last = pl$col("x")$last())
Expr_last = use_extendr_wrapper

#' Apply window function over a subgroup
#'
#' This applies an expression on groups and returns the same number of rows as
#' the input (contrarily to `$group_by()` + `$agg()`).
#'
#' @param ... Character vector indicating the columns to group by.
#'
#' @return Expr
#' @examples
#' pl$DataFrame(
#'   val = 1:5,
#'   a = c("+", "+", "-", "-", "+"),
#'   b = c("+", "-", "+", "-", "+")
#' )$with_columns(
#'   count = pl$col("val")$count()$over("a", "b")
#' )
#'
#' over_vars = c("a", "b")
#' pl$DataFrame(
#'   val = 1:5,
#'   a = c("+", "+", "-", "-", "+"),
#'   b = c("+", "-", "+", "-", "+")
#' )$with_columns(
#'   count = pl$col("val")$count()$over(over_vars)
#' )
Expr_over = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$Expr$over(self, pra)
}

#' Check whether each value is unique
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#'
#' @examples
#' pl$DataFrame(head(mtcars[, 1:2]))$
#'   with_columns(is_unique = pl$col("mpg")$is_unique())
Expr_is_unique = use_extendr_wrapper

#' Check whether each value is the first occurrence
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#'
#' @examples
#' pl$DataFrame(head(mtcars[, 1:2]))$
#'   with_columns(is_ufirst = pl$col("mpg")$is_first_distinct())
Expr_is_first_distinct = use_extendr_wrapper

#' Check whether each value is the last occurrence
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#'
#' @examples
#' pl$DataFrame(head(mtcars[, 1:2]))$
#'   with_columns(is_ulast = pl$col("mpg")$is_last_distinct())
Expr_is_last_distinct = use_extendr_wrapper


#' Check whether each value is duplicated
#'
#' This is syntactic sugar for `$is_unique()$not()`.
#' @return Expr
#' @docType NULL
#' @format NULL
#'
#' @examples
#' pl$DataFrame(head(mtcars[, 1:2]))$
#'   with_columns(is_duplicated = pl$col("mpg")$is_duplicated())
Expr_is_duplicated = use_extendr_wrapper


# TODO contribute polars, example of where NA/Null is omitted and the smallest value

#' Get quantile value.
#'
#' @param quantile Either a numeric value or an Expr whose value must be
#' between 0 and 1.
#' @param interpolation One of `"nearest"`, `"higher"`, `"lower"`,
#' `"midpoint"`, or `"linear"`.
#'
#' @return Expr
#'
#' @details
#' Null values are ignored and `NaN`s are ranked as the largest value.
#' For linear interpolation `NaN` poisons `Inf`, that poisons any other value.
#'
#' @examples
#' pl$select(pl$lit(-5:5)$quantile(.5))
Expr_quantile = function(quantile, interpolation = "nearest") {
  unwrap(.pr$Expr$quantile(self, wrap_e(quantile), interpolation))
}

#' Filter a single column.
#'
#' Mostly useful in an aggregation context. If you want to filter on a
#' DataFrame level, use `DataFrame$filter()` (or `LazyFrame$filter()`).
#'
#' @param predicate An Expr or something coercible to an Expr. Must return a
#' boolean.
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
#'   group_col = c("g1", "g1", "g2"),
#'   b = c(1, 2, 3)
#' )
#' df
#'
#' df$group_by("group_col")$agg(
#'   lt = pl$col("b")$filter(pl$col("b") < 2),
#'   gte = pl$col("b")$filter(pl$col("b") >= 2)
#' )
Expr_filter = function(predicate) {
  .pr$Expr$filter(self, wrap_e(predicate))
}


#' Explode a list or String Series
#'
#' This means that every item is expanded to a new row.
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#'
#' @details
#' Categorical values are not supported.
#'
#' @examples
#' df = pl$DataFrame(x = c("abc", "ab"), y = c(list(1:3), list(3:5)))
#' df
#'
#' df$select(pl$col("y")$explode())
Expr_explode = use_extendr_wrapper

#' @inherit Expr_explode title return
#'
#' @description
#' This is an alias for `<Expr>$explode()`.
#'
#' @examples
#' df = pl$DataFrame(x = c("abc", "ab"), y = c(list(1:3), list(3:5)))
#' df
#'
#' df$select(pl$col("y")$flatten())
Expr_flatten = use_extendr_wrapper


#' Gather every nth element
#'
#' Gather every nth value in the Series and return as a new Series.
#' @param n Positive integer.
#' @param offset Starting index.
#'
#' @return Expr
#'
#' @examples
#' pl$DataFrame(a = 0:24)$select(pl$col("a")$gather_every(6))
Expr_gather_every = function(n, offset = 0) {
  unwrap(.pr$Expr$gather_every(self, n, offset))
}

#' Get the first n elements
#'
#' @param n Number of elements to take.
#' @return Expr
#' @examples
#' pl$DataFrame(x = 1:11)$select(pl$col("x")$head(3))
Expr_head = function(n = 10) {
  unwrap(.pr$Expr$head(self, n = n), "in $head():")
}

#' Get the last n elements
#'
#' @inheritParams Expr_head
#' @return Expr
#'
#' @examples
#' pl$DataFrame(x = 1:11)$select(pl$col("x")$tail(3))
Expr_tail = function(n = 10) {
  unwrap(.pr$Expr$tail(self, n = n), "in $tail():")
}


#' @inherit Expr_head title params return
#'
#' @description
#' This is an alias for `<Expr>$head()`.
#'
#' @examples
#' pl$DataFrame(x = 1:11)$select(pl$col("x")$limit(3))
Expr_limit = function(n = 10) {
  if (!is.numeric(n)) stop("limit: n must be numeric")
  unwrap(.pr$Expr$head(self, n = n))
}



#' Exponentiation
#'
#' Raise expression to the power of exponent.
#'
#' @param exponent Exponent value.
#' @return Expr
#' @examples
#' # use via `pow`-method and the `^`-operator
#' pl$DataFrame(a = -1:3, b = 2:6)$with_columns(
#'   x = pl$col("a")$pow(2),
#'   y = pl$col("a")^3
#' )
Expr_pow = function(exponent) {
  .pr$Expr$pow(self, exponent) |> unwrap("in $pow()")
}
#' @export
"^.RPolarsExpr" = function(e1, e2) result(wrap_e(e1)$pow(e2)) |> unwrap("using '^'-operator")


#' Check whether a value is in a vector
#'
#' Notice that to check whether a factor value is in a vector of strings, you
#' need to use the string cache, either with `pl$enable_string_cache()` or
#' with `pl$with_string_cache()`. See examples.
#'
#' @inheritParams Expr_add
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(1:4, NA_integer_))$with_columns(
#'   in_1_3 = pl$col("a")$is_in(c(1, 3)),
#'   in_NA = pl$col("a")$is_in(pl$lit(NA_real_))
#' )
#'
#' # this fails because we can't compare factors to strings
#' # pl$DataFrame(a = factor(letters[1:5]))$with_columns(
#' #   in_abc = pl$col("a")$is_in(c("a", "b", "c"))
#' # )
#'
#' # need to use the string cache for this
#' pl$with_string_cache({
#'   pl$DataFrame(a = factor(letters[1:5]))$with_columns(
#'     in_abc = pl$col("a")$is_in(c("a", "b", "c"))
#'   )
#' })
Expr_is_in = function(other) {
  .pr$Expr$is_in(self, other) |> unwrap("in $is_in():")
}

#' Repeat values
#'
#' Repeat the elements in this Series as specified in the given expression.
#' The repeated elements are expanded into a `List`.
#' @param by Expr that determines how often the values will be repeated. The
#' column will be coerced to UInt32.
#' @return Expr
#' @examples
#' df = pl$DataFrame(a = c("w", "x", "y", "z"), n = c(-1, 0, 1, 2))
#' df$with_columns(repeated = pl$col("a")$repeat_by("n"))
Expr_repeat_by = function(by) {
  if (is.numeric(by) && any(by < 0)) stop("In repeat_by: any value less than zero is not allowed")
  .pr$Expr$repeat_by(self, wrap_e(by, FALSE))
}

#' Check whether a value is between two values
#'
#' This is syntactic sugar for `x > start & x < end` (or `x >= start & x <=
#' end`).
#' @param start Lower bound, an Expr that is either numeric or datetime.
#' @param end Upper bound, an Expr that is either numeric or datetime.
#' @param include_bounds If `FALSE` (default), exclude start and end. This can
#' also be a vector of two booleans indicating whether to include the start
#' and/or the end.
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(num = 1:5, y = c(0, 2, 3, 3, 3))
#' df$with_columns(
#'   bet_2_4_no_bounds = pl$col("num")$is_between(2, 4),
#'   bet_2_4_with_bounds = pl$col("num")$is_between(2, 4, TRUE),
#'   bet_2_4_upper_bound = pl$col("num")$is_between(2, 4, c(FALSE, TRUE)),
#'   between_y_4 = pl$col("num")$is_between(pl$col("y"), 6)
#' )
Expr_is_between = function(start, end, include_bounds = FALSE) {
  if (
    !length(include_bounds) %in% 1:2 ||
      !is.logical(include_bounds) ||
      any(is.na(include_bounds))
  ) {
    stop("in is_between: inlcude_bounds must be boolean of length 1 or 2, with no NAs")
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

#' Hash elements
#'
#' The hash value is of type `UInt64`.
#' @param seed Random seed parameter. Defaults to 0. Doesn't have any effect
#' for now.
#' @param seed_1,seed_2,seed_3 Random seed parameter. Defaults to arg seed.
#' The column will be coerced to UInt32.
#'
#' @return Expr
#' @aliases hash
#' @examples
#' df = pl$DataFrame(iris[1:3, c(1, 2)])
#' df$with_columns(pl$all()$hash(1234)$name$suffix("_hash"))
Expr_hash = function(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL) {
  k0 = seed
  k1 = seed_1 %||% seed
  k2 = seed_2 %||% seed
  k3 = seed_3 %||% seed
  unwrap(.pr$Expr$hash(self, k0, k1, k2, k3), "in $hash()")
}

#' Reinterpret bits
#'
#' Reinterpret the underlying bits as a signed/unsigned integer. This
#' operation is only allowed for Int64. For lower bits integers, you can
#' safely use the cast operation.
#' @param signed If `TRUE` (default), reinterpret into Int64. Otherwise, it
#' will be reinterpreted in UInt64.
#' @return Expr
#' @examples
#' df = pl$DataFrame(x = 1:5, schema = list(x = pl$Int64))
#' df$select(pl$all()$reinterpret())
Expr_reinterpret = function(signed = TRUE) {
  if (!is_bool(signed)) stop("in reinterpret() : arg signed must be a bool")
  .pr$Expr$reinterpret(self, signed)
}


#' Inspect evaluated Series
#'
#' Print the value that this expression evaluates to and pass on the value.
#' The printing will happen when the expression evaluates, not when it is formed.
#'
#' @param fmt format string, should contain one set of `{}` where object will be
#' printed. This formatting mimics python "string".format() use in py-polars.
#' @return Expr
#' @examples
#' pl$select(pl$lit(1:5)$inspect(
#'   "Here's what the Series looked like before keeping the first two values: {}"
#' )$head(2))
Expr_inspect = function(fmt = "{}") {
  # check fmt and create something to print before and after printing Series.
  if (!is_string(fmt)) stop("Inspect: arg fmt is not a string (length=1)")
  strs = strsplit(fmt, split = "\\{\\}")[[1L]]
  if (identical(strs, "")) strs = c("", "")
  if (length(strs) == 1 && grepl("\\{\\}$", fmt)) strs = c(strs, "")
  if (length(strs) != 2L || length(gregexpr("\\{\\}", fmt)[[1L]]) != 1L) {
    result(stop(paste0(
      "Inspect: failed to parse arg fmt [", fmt, "] ",
      " a string containing the two consecutive chars `{}` once. \n",
      "a valid string is e.g. `hello{}world`"
    ))) |> unwrap("in $inspect()")
  }

  # function to print the evaluated Series
  f_inspect = function(s) { # required signature f(Series) -> Series
    cat(strs[1L])
    s$print()
    cat(strs[2L], "\n", sep = "")
    s
  }

  # add a map to expression printing the evaluated series
  .pr$Expr$map_batches(self = self, lambda = f_inspect, output_type = NULL, agg_list = TRUE) |>
    unwrap("in $inspect()")
}

#' Interpolate null values
#'
#' Fill nulls with linear interpolation using non-missing values. Can also be
#' used to regrid data to a new grid - see examples below.
#'
#' @param method String, either `"linear"` (default) or `"nearest"`.
#' @return Expr
#' @examples
#' pl$DataFrame(x = c(1, NA, 4, NA, 100, NaN, 150))$
#'   with_columns(
#'   interp_lin = pl$col("x")$interpolate(),
#'   interp_near = pl$col("x")$interpolate("nearest")
#' )
#'
#' # x, y interpolation over a grid
#' df_original_grid = pl$DataFrame(
#'   grid_points = c(1, 3, 10),
#'   values = c(2.0, 6.0, 20.0)
#' )
#' df_original_grid
#' df_new_grid = pl$DataFrame(grid_points = (1:10) * 1.0)
#' df_new_grid
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
    if (is.null(min_periods)) min_periods = as.numeric(window_size)
    window_size = paste0(as.character(floor(window_size)), "i")
  }
  if (is.null(min_periods)) min_periods = 1
  list(window_size = window_size, min_periods = min_periods)
}


## TODO impl datatime in rolling expr
## TODO contribute polars rolling _min _max _sum _mean do no behave as the aggregation counterparts
## as NULLs are not omitted. Maybe the best resolution is to implement skipnull option in all function
## and check if it wont mess up optimzation (maybe it is tested for).


#' Rolling minimum
#'
#' Compute the rolling (= moving) min over the values in this array. A window of
#' length `window_size` will traverse the array. The values that fill this window
#' will (optionally) be multiplied with the weights given by the `weight` vector.
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
#' @param weights An optional slice with the same length as the window that will
#' be multiplied elementwise with the values in the window.
#' @param min_periods The number of values in the window that should be non-null
#' before computing a result. If `NULL`, it will be set equal to window size.
#' @param center Set the labels at the center of the window
#' @param by If the `window_size` is temporal for instance `"5h"` or `"3s"`, you
#' must set the column that will be used to determine the windows. This column
#' must be of DataType Date or DateTime.
#' @param closed String, one of `"left"`, `"right"`, `"both"`, `"none"`. Defines
#' whether the temporal window interval is closed or not.
#' @param warn_if_unsorted Warn if data is not known to be sorted by `by` column (if passed).
#' Experimental.
#'
#' @details
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using `$rolling()` this method can cache the window size
#' computation.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_min = pl$col("a")$rolling_min(window_size = 2))
Expr_rolling_min = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_min(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_min():")
}

#' Rolling maximum
#'
#' Compute the rolling (= moving) max over the values in this array. A window of
#' length `window_size` will traverse the array. The values that fill this window
#' will (optionally) be multiplied with the weights given by the `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_max = pl$col("a")$rolling_max(window_size = 2))
Expr_rolling_max = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_max(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_max()")
}

#' Rolling mean
#'
#' Compute the rolling (= moving) mean over the values in this array. A window of
#' length `window_size` will traverse the array. The values that fill this window
#' will (optionally) be multiplied with the weights given by the `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_mean = pl$col("a")$rolling_mean(window_size = 2))
Expr_rolling_mean = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_mean(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_mean():")
}

#' Rolling sum
#'
#' Compute the rolling (= moving) sum over the values in this array. A window of
#' length `window_size` will traverse the array. The values that fill this window
#' will (optionally) be multiplied with the weights given by the `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_sum = pl$col("a")$rolling_sum(window_size = 2))
Expr_rolling_sum = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_sum(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_sum():")
}


#' Rolling standard deviation
#'
#' Compute the rolling (= moving) standard deviation over the values in this
#' array. A window of length `window_size` will traverse the array. The values
#' that fill this window will (optionally) be multiplied with the weights given
#' by the `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_std = pl$col("a")$rolling_std(window_size = 2))
Expr_rolling_std = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_std(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_std(): ")
}

#' Rolling variance
#'
#' Compute the rolling (= moving) variance over the values in this array. A
#' window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_var = pl$col("a")$rolling_var(window_size = 2))
Expr_rolling_var = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_var(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_var():")
}

#' Rolling median
#'
#' Compute the rolling (= moving) median over the values in this array. A window
#' of length `window_size` will traverse the array. The values that fill this
#' window will (optionally) be multiplied with the weights given by the `weight`
#' vector.
#'
#' @inherit Expr_rolling_min params details return
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_median = pl$col("a")$rolling_median(window_size = 2))
Expr_rolling_median = function(
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_median(
    self, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |> unwrap("in $rolling_median():")
}


## TODO contribute polars arg center only allows center + right alignment, also implement left

#' Rolling quantile
#'
#' Compute the rolling (= moving) quantile over the values in this array. A
#' window of length `window_size` will traverse the array. The values that fill
#' this window will (optionally) be multiplied with the weights given by the
#' `weight` vector.
#'
#' @inherit Expr_rolling_min params details return
#' @param quantile Quantile between 0 and 1.
#' @param interpolation String, one of `"nearest"`, `"higher"`, `"lower"`,
#' `"midpoint"`, `"linear"`.
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_quant = pl$col("a")$rolling_quantile(0.3, window_size = 2))
Expr_rolling_quantile = function(
    quantile,
    interpolation = "nearest",
    window_size,
    weights = NULL,
    min_periods = NULL,
    center = FALSE,
    by = NULL,
    closed = c("left", "right", "both", "none"),
    warn_if_unsorted = TRUE) {
  wargs = prepare_rolling_window_args(window_size, min_periods)
  .pr$Expr$rolling_quantile(
    self, quantile, interpolation, wargs$window_size, weights,
    wargs$min_periods, center, by, closed[1L], warn_if_unsorted
  ) |>
    unwrap("in $rolling_quantile():")
}


#' Rolling skew
#'
#' Compute the rolling (= moving) skewness over the values in this array. A
#' window of length `window_size` will traverse the array.
#'
#' @inherit Expr_rolling_min params return
#' @param bias If `FALSE`, the calculations are corrected for statistical bias.

#' @details
#' For normally distributed data, the skewness should be about zero. For
#' uni-modal continuous distributions, a skewness value greater than zero means
#' that there is more weight in the right tail of the distribution.
#'
#' @examples
#' pl$DataFrame(a = c(1, 3, 2, 4, 5, 6))$
#'   with_columns(roll_skew = pl$col("a")$rolling_skew(window_size = 2))
Expr_rolling_skew = function(window_size, bias = TRUE) {
  unwrap(.pr$Expr$rolling_skew(self, window_size, bias))
}

#' Compute the absolute values
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = -1:1)$
#'   with_columns(abs = pl$col("a")$abs())
Expr_abs = use_extendr_wrapper

#' Rank elements
#'
#' Assign ranks to data, dealing with ties appropriately.
#'
#' @param method String, one of `"average"` (default), `"min"`, `"max"`,
#' `"dense"`, `"ordinal"`, `"random"`. The method used to assign ranks to tied
#' elements:
#' - `"average"`: The average of the ranks that would have been assigned to
#'   all the tied values is assigned to each value.
#' - `"min"`: The minimum of the ranks that would have been assigned to all
#'   the tied values is assigned to each value. (This is also referred to
#'   as "competition" ranking.)
#' - `"max"` : The maximum of the ranks that would have been assigned to all
#'   the tied values is assigned to each value.
#' - `"dense"`: Like 'min', but the rank of the next highest element is assigned
#'   the rank immediately after those assigned to the tied elements.
#' - `"ordinal"` : All values are given a distinct rank, corresponding to the
#'   order that the values occur in the Series.
#' - `"random"` : Like 'ordinal', but the rank for ties is not dependent on the
#'   order that the values occur in the Series.
#' @param descending Rank in descending order.
#' @return  Expr
#' @examples
#' #  The 'average' method:
#' pl$DataFrame(a = c(3, 6, 1, 1, 6))$
#'   with_columns(rank = pl$col("a")$rank())
#'
#' #  The 'ordinal' method:
#' pl$DataFrame(a = c(3, 6, 1, 1, 6))$
#'   with_columns(rank = pl$col("a")$rank("ordinal"))
Expr_rank = function(method = "average", descending = FALSE) {
  unwrap(.pr$Expr$rank(self, method, descending))
}


#' Difference
#'
#' Calculate the n-th discrete difference.
#'
#' @param n Number of slots to shift.
#' @param null_behavior String, either `"ignore"` (default), else `"drop"`.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(20L, 10L, 30L, 40L))$with_columns(
#'   diff_default = pl$col("a")$diff(),
#'   diff_2_ignore = pl$col("a")$diff(2, "ignore")
#' )
Expr_diff = function(n = 1, null_behavior = c("ignore", "drop")) {
  .pr$Expr$diff(self, n, null_behavior) |>
    unwrap("in $diff():")
}

#' Percentage change
#'
#' Computes percentage change (as fraction) between current element and most-
#' recent non-null element at least `n` period(s) before the current element.
#' Computes the change from the previous row by default.
#'
#' @param n Periods to shift for computing percent change.
#' @return Expr
#' @examples
#' pl$DataFrame(a = c(10L, 11L, 12L, NA_integer_, 12L))$
#'   with_columns(pct_change = pl$col("a")$pct_change())
Expr_pct_change = function(n = 1) {
  unwrap(.pr$Expr$pct_change(self, n))
}

#' Skewness
#'
#' Compute the sample skewness of a data set.
#' @param bias If `FALSE`, then the calculations are corrected for statistical
#' bias.
#' @return Expr
#' @inherit Expr_rolling_skew details
#' @examples
#' df = pl$DataFrame(list(a = c(1:3, 2:1)))
#' df$select(pl$col("a")$skew())
Expr_skew = function(bias = TRUE) {
  .pr$Expr$skew(self, bias)
}

#' Kurtosis
#'
#' Compute the kurtosis (Fisher or Pearson) of a dataset.
#'
#' @param fisher If `TRUE` (default), Fisher’s definition is used (normal,
#' centered at 0). Otherwise, Pearson’s definition is used (normal, centered at
#' 3).
#' @inheritParams Expr_rolling_skew
#'
#' @return Expr
#' @details
#' Kurtosis is the fourth central moment divided by the square of the variance.
#' If Fisher's definition is used, then 3 is subtracted from the result to
#' give 0 for a normal distribution.
#'
#' If bias is `FALSE`, then the kurtosis is calculated using `k` statistics to
#' eliminate bias coming from biased moment estimators.
#'
#' @examples
#' pl$DataFrame(a = c(1:3, 2:1))$
#'   with_columns(kurt = pl$col("a")$kurtosis())
Expr_kurtosis = function(fisher = TRUE, bias = TRUE) {
  .pr$Expr$kurtosis(self, fisher, bias)
}

#' Clip elements
#'
#' Clip (limit) the values in an array to a `min` and `max` boundary. This only
#' works for numerical types.
#' @param min Minimum value, Expr returning a numeric.
#' @param max Maximum value, Expr returning a numeric.
#' @return Expr
#'
#' @examples
#' pl$DataFrame(foo = c(-50L, 5L, NA_integer_, 50L))$
#'   with_columns(clipped = pl$col("foo")$clip(1, 10))
Expr_clip = function(min, max) {
  unwrap(.pr$Expr$clip(self, wrap_e(min), wrap_e(max)))
}

#' Clip elements below minimum value
#'
#' Replace all values below a minimum value by this minimum value.
#' @inheritParams Expr_clip
#'
#' @examples
#' pl$DataFrame(foo = c(-50L, 5L, NA_integer_, 50L))$
#'   with_columns(clipped = pl$col("foo")$clip_min(1))
Expr_clip_min = function(min) {
  unwrap(.pr$Expr$clip_min(self, wrap_e(min)))
}

#' Clip elements above maximum value
#'
#' Replace all values above a maximum value by this maximum value.
#' @inheritParams Expr_clip
#'
#' @examples
#' pl$DataFrame(foo = c(-50L, 5L, NA_integer_, 50L))$
#'   with_columns(clipped = pl$col("foo")$clip_max(10))
Expr_clip_max = function(max) {
  unwrap(.pr$Expr$clip_max(self, wrap_e(max)))
}

#' Find the upper bound of a DataType
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   x = c(1, 2, 3), y = -2:0,
#'   schema = list(x = pl$Float64, y = pl$Int32)
#' )$
#'   select(pl$all()$upper_bound())
Expr_upper_bound = use_extendr_wrapper

#' Find the lower bound of a DataType
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(
#'   x = 1:3, y = 1:3,
#'   schema = list(x = pl$UInt32, y = pl$Int32)
#' )$
#'   select(pl$all()$lower_bound())
Expr_lower_bound = use_extendr_wrapper

#' Get the sign of elements
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(.9, -3, -0, 0, 4, NA_real_))$
#'   with_columns(sign = pl$col("a")$sign())
Expr_sign = use_extendr_wrapper

#' Compute sine
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$
#'   with_columns(sine = pl$col("a")$sin())
Expr_sin = use_extendr_wrapper

#' Compute cosine
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$
#'   with_columns(cosine = pl$col("a")$cos())
Expr_cos = use_extendr_wrapper

#' Compute tangent
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA_real_))$
#'   with_columns(tangent = pl$col("a")$tan())
Expr_tan = use_extendr_wrapper

#' Compute inverse sine
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, sin(0.5), 0, 1, NA_real_))$
#'   with_columns(arcsin = pl$col("a")$arcsin())
Expr_arcsin = use_extendr_wrapper

#' Compute inverse cosine
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, cos(0.5), 0, 1, NA_real_))$
#'   with_columns(arccos = pl$col("a")$arccos())
Expr_arccos = use_extendr_wrapper

#' Compute inverse tangent
#'
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, tan(0.5), 0, 1, NA_real_))$
#'   with_columns(arctan = pl$col("a")$arctan())
Expr_arctan = use_extendr_wrapper

#' Compute hyperbolic sine
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, asinh(0.5), 0, 1, NA_real_))$
#'   with_columns(sinh = pl$col("a")$sinh())
Expr_sinh = use_extendr_wrapper

#' Compute hyperbolic cosine
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, acosh(0.5), 0, 1, NA_real_))$
#'   with_columns(cosh = pl$col("a")$cosh())
Expr_cosh = use_extendr_wrapper

#' Compute hyperbolic tangent
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, atanh(0.5), 0, 1, NA_real_))$
#'   with_columns(tanh = pl$col("a")$tanh())
Expr_tanh = use_extendr_wrapper

#' Compute inverse hyperbolic sine
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, sinh(0.5), 0, 1, NA_real_))$
#'   with_columns(arcsinh = pl$col("a")$arcsinh())
Expr_arcsinh = use_extendr_wrapper

#' Compute inverse hyperbolic cosine
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, cosh(0.5), 0, 1, NA_real_))$
#'   with_columns(arccosh = pl$col("a")$arccosh())
Expr_arccosh = use_extendr_wrapper

#' Compute inverse hyperbolic tangent
#'
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(-1, tanh(0.5), 0, 1, NA_real_))$
#'   with_columns(arctanh = pl$col("a")$arctanh())
Expr_arctanh = use_extendr_wrapper

#' Reshape
#'
#' Reshape an Expr to a flat Series or a Series of Lists.
#' @param dims Numeric vec of the dimension sizes. If a -1 is used in any of the
#' dimensions, that dimension is inferred.
#' @return Expr
#' @examples
#' pl$select(pl$lit(1:12)$reshape(c(3, 4)))
#' pl$select(pl$lit(1:12)$reshape(c(3, -1)))
Expr_reshape = function(dims) {
  if (!is.numeric(dims)) pstop(err = "reshape: arg dims must be numeric")
  if (!length(dims) %in% 1:2) pstop(err = "reshape: arg dims must be of length 1 or 2")
  unwrap(.pr$Expr$reshape(self, as.numeric(dims)))
}

#' Shuffle values
#'
#' @param seed numeric value of 0 to 2^52 Seed for the random number generator.
#' If `NULL` (default), a random seed value between 0 and 10000 is picked.
#' @return Expr
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(shuff = pl$col("a")$shuffle(seed = 1))
Expr_shuffle = function(seed = NULL) {
  .pr$Expr$shuffle(self, seed) |> unwrap("in $shuffle()")
}

#' Take a sample
#'
#' @param frac Fraction of items to return (can be higher than 1). Cannot be
#' used with `n`.
#' @param with_replacement If `TRUE` (default), allow values to be sampled more
#' than once.
#' @param shuffle Shuffle the order of sampled data points (implicitly `TRUE` if
#' `with_replacement = TRUE`).
#' @inheritParams Expr_shuffle
#' @param n Number of items to return. Cannot be used with `frac`.
#' @return Expr
#' @examples
#' df = pl$DataFrame(a = 1:4)
#' df$select(pl$col("a")$sample(frac = 1, with_replacement = TRUE, seed = 1L))
#' df$select(pl$col("a")$sample(frac = 2, with_replacement = TRUE, seed = 1L))
#' df$select(pl$col("a")$sample(n = 2, with_replacement = FALSE, seed = 1L))
Expr_sample = function(
    frac = NULL, with_replacement = TRUE, shuffle = FALSE,
    seed = NULL, n = NULL) {
  pcase(
    !is.null(n) && !is.null(frac), {
      Err(.pr$Err$new()$plain("either arg `n` or `frac` must be NULL"))
    },
    !is.null(n), .pr$Expr$sample_n(self, n, with_replacement, shuffle, seed),
    or_else = {
      .pr$Expr$sample_frac(self, frac %||% 1.0, with_replacement, shuffle, seed)
    }
  ) |>
    unwrap("in $sample()")
}

#' Internal function for emw_x expressions
#' @param com numeric or NULL
#' @param span numeric or NULL
#' @param half_life numeric or NULL
#' @param alpha numeric or NULL
#' @return numeric
#' @noRd
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

  stop("Internal: it seems a input scenario was not handled properly")
}

#' Exponentially-weighted moving average
#'
#' @param com Specify decay in terms of center of mass, \eqn{\gamma}, with
#' \eqn{
#'   \alpha = \frac{1}{1 + \gamma} \; \forall \; \gamma \geq 0
#'   }
#' @param span Specify decay in terms of span,  \eqn{\theta}, with
#' \eqn{\alpha = \frac{2}{\theta + 1} \; \forall \; \theta \geq 1 }
#' @param half_life Specify decay in terms of half-life, :math:`\lambda`, with
#' \eqn{ \alpha = 1 - \exp \left\{ \frac{ -\ln(2) }{ \lambda } \right\} }
#' \eqn{ \forall \; \lambda > 0}
#' @param alpha Specify smoothing factor alpha directly, \eqn{0 < \alpha \leq 1}.
#' @param adjust Divide by decaying adjustment factor in beginning periods to
#' account for imbalance in relative weightings:
#' - When ``adjust=TRUE`` the EW function is calculatedusing weights
#'   \eqn{w_i = (1 - \alpha)^i  }
#' - When ``adjust=FALSE`` the EW function is calculated recursively by
#'   \eqn{
#'     y_0 = x_0 \\
#'     y_t = (1 - \alpha)y_{t - 1} + \alpha x_t
#'   }
#' @param min_periods Minimum number of observations in window required to have
#' a value (otherwise result is null).
#' @param ignore_nulls Ignore missing values when calculating weights:
#'  - When `TRUE` (default), weights are based on relative positions. For example,
#'    the weights of \eqn{x_0} and  \eqn{x_2} used in calculating the final
#'    weighted average of `[` \eqn{x_0}, None,  \eqn{x_2}`]` are
#'    \eqn{1-\alpha} and  \eqn{1} if `adjust=TRUE`, and  \eqn{1-\alpha} and
#'    \eqn{\alpha} if `adjust=FALSE`.
#'  - When `FALSE`, weights are based on absolute positions. For example, the
#'    weights of :math:`x_0` and :math:`x_2` used in calculating the final
#'    weighted average of `[` \eqn{x_0}, None,  \eqn{x_2}\\`]` are
#'    \eqn{1-\alpha)^2} and  \eqn{1} if ``adjust=TRUE``, and \eqn{(1-\alpha)^2}
#'    and  \eqn{\alpha} if `adjust=FALSE`.
#' @return Expr
#' @examples
#' pl$DataFrame(a = 1:3)$
#'   with_columns(ewm_mean = pl$col("a")$ewm_mean(com = 1))
Expr_ewm_mean = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  .pr$Expr$ewm_mean(self, alpha, adjust, min_periods, ignore_nulls) |>
    unwrap("in $ewm_mean()")
}

#' Exponentially-weighted moving standard deviation
#'
#' @inheritParams Expr_ewm_mean
#' @inheritParams Expr_rolling_skew
#' @return Expr
#' @examples
#' pl$DataFrame(a = 1:3)$
#'   with_columns(ewm_std = pl$col("a")$ewm_std(com = 1))
Expr_ewm_std = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, bias = FALSE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  .pr$Expr$ewm_std(self, alpha, adjust, bias, min_periods, ignore_nulls) |>
    unwrap("in $ewm_std()")
}

#' Exponentially-weighted moving variance
#'
#' @inheritParams Expr_ewm_mean
#' @inheritParams Expr_rolling_skew
#' @return Expr
#' @examples
#' pl$DataFrame(a = 1:3)$
#'   with_columns(ewm_var = pl$col("a")$ewm_var(com = 1))
Expr_ewm_var = function(
    com = NULL, span = NULL, half_life = NULL, alpha = NULL,
    adjust = TRUE, bias = FALSE, min_periods = 1L, ignore_nulls = TRUE) {
  alpha = prepare_alpha(com, span, half_life, alpha)
  .pr$Expr$ewm_var(self, alpha, adjust, bias, min_periods, ignore_nulls) |>
    unwrap("in $ewm_var()")
}

#' Extend Series with a constant
#'
#' Extend the Series with given number of values.
#' @param value The value to extend the Series with. This value may be `NULL` to
#' fill with nulls.
#' @param n The number of values to extend.
#' @return Expr
#' @examples
#' pl$select(pl$lit(1:4)$extend_constant(10.1, 2))
#' pl$select(pl$lit(1:4)$extend_constant(NULL, 2))
Expr_extend_constant = function(value, n) {
  .pr$Expr$extend_constant(self, wrap_e(value), n) |>
    unwrap("in $extend_constant()")
}

#' Repeat a Series
#'
#' This expression takes input and repeats it n times and append chunk.
#' @param n The number of times to repeat, must be non-negative and finite.
#' @param rechunk If `TRUE` (default), memory layout will be rewritten.
#'
#' @return Expr
#' @details
#' If the input has length 1, this uses a special faster implementation that
#' doesn't require rechunking (so `rechunk = TRUE` has no effect).
#'
#' @examples
#' pl$select(pl$lit("alice")$rep(n = 3))
#' pl$select(pl$lit(1:3)$rep(n = 2))
Expr_rep = function(n, rechunk = TRUE) {
  .pr$Expr$rep(self, n, rechunk) |>
    unwrap("in $rep()")
}

#' Extend a Series by repeating values
#'
#' @param expr Expr or something coercible to an Expr.
#' @inheritParams Expr_rep
#' @param upcast If `TRUE` (default), non identical types will be cast to common
#' supertype if there is any. If `FALSE` or no common super type, having
#' different types will throw an error.
#' @return Expr
#' @examples
#' pl$select(pl$lit(c(1, 2, 3))$rep_extend(1:3, n = 5))
Expr_rep_extend = function(expr, n, rechunk = TRUE, upcast = TRUE) {
  other = wrap_e(expr)$rep(n, rechunk = FALSE)
  new = .pr$Expr$append(self, other, upcast)
  if (rechunk) new$rechunk() else new
}

#' Convert an Expr to R output
#'
#' This is mostly useful to debug an expression. It evaluates the Expr in an
#' empty DataFrame and return the first Series to R.
#' @param df If `NULL` (default), it evaluates the Expr in an empty DataFrame.
#' Otherwise, provide a DataFrame that the Expr should be evaluated in.
#' @param i Numeric column to extract. Default is zero (which gives the first
#' column).
#' @return R object
#' @examples
#' pl$lit(1:3)$to_r()
Expr_to_r = function(df = NULL, i = 0) {
  if (is.null(df)) {
    pl$select(self)$to_series(i)$to_r()
  } else {
    if (!inherits(df, c("RPolarsDataFrame"))) {
      stop("Expr_to_r: input is not NULL or a DataFrame/Lazyframe")
    }
    df$select(self)$to_series(i)$to_r()
  }
}

#' Convert an Expr to R output
#'
#' This is mostly useful to debug an expression. It evaluates the Expr in an
#' empty DataFrame and return the first Series to R. This is an alias for
#' `$to_r()`.
#' @param expr An Expr to evaluate.
#' @param df If `NULL` (default), it evaluates the Expr in an empty DataFrame.
#' Otherwise, provide a DataFrame that the Expr should be evaluated in.
#' @param i Numeric column to extract. Default is zero (which gives the first
#' column).
#' @return R object
#' @examples
#' pl$expr_to_r(pl$lit(1:3))
pl_expr_to_r = function(expr, df = NULL, i = 0) {
  wrap_e(expr)$to_r(df, i)
}

#' Value counts
#' @description
#' Count all unique values and create a struct mapping value to count.
#' @return Expr
#' @param sort Ensure the output is sorted from most values to least.
#' @param parallel Better to turn this off in the aggregation context, as it can
#' lead to contention.
#' @format NULL
#' @examples
#' df = pl$DataFrame(iris)$select(pl$col("Species")$value_counts())
#' df
#' df$unnest()$to_data_frame() # recommended to unnest structs before converting to R
Expr_value_counts = function(sort = FALSE, parallel = FALSE) {
  .pr$Expr$value_counts(self, sort, parallel)
}

#' Count unique values
#'
#' Return a count of the unique values in the order of appearance. This method
#' differs from `$value_counts()` in that it does not return the values, only
#' the counts and it might be faster.
#' @return  Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(iris)$select(pl$col("Species")$unique_counts())
Expr_unique_counts = use_extendr_wrapper

#' Compute the logarithm of elements
#'
#' @param base Numeric base value for logarithm, default is `exp(1)`.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(1, 2, 3, exp(1)))$
#'   with_columns(log = pl$col("a")$log())
Expr_log = function(base = base::exp(1)) {
  .pr$Expr$log(self, base)
}

#' Compute the base-10 logarithm of elements
#' @return Expr
#' @docType NULL
#' @format NULL
#' @examples
#' pl$DataFrame(a = c(1, 2, 3, exp(1)))$
#'   with_columns(log10 = pl$col("a")$log10())
Expr_log10 = use_extendr_wrapper

#' Entropy
#'
#' The entropy is measured with the formula `-sum(pk * log(pk))` where `pk` are
#' discrete probabilities.
#' @param base Given exponential base, defaults to `exp(1)`.
#' @param normalize Normalize `pk` if it doesn't sum to 1.
#' @return Expr
#' @examples
#' pl$DataFrame(x = c(1, 2, 3, 2))$
#'   with_columns(entropy = pl$col("x")$entropy(base = 2))
Expr_entropy = function(base = base::exp(1), normalize = TRUE) {
  .pr$Expr$entropy(self, base, normalize)
}

#' Cumulative evaluation of expressions
#'
#' Run an expression over a sliding window that increases by `1` slot every
#' iteration.
#' @param expr Expression to evaluate.
#' @param min_periods Number of valid (non-null) values there should be in the
#' window before the expression is evaluated.
#' @param parallel Run in parallel. Don't do this in a groupby or another
#' operation that already has much parallelization.
#' @details
#' This can be really slow as it can have `O(n^2)` complexity. Don't use this
#' for operations that visit all elements.
#' @return Expr
#' @examples
#' pl$lit(1:5)$cumulative_eval(
#'   pl$element()$first() - pl$element()$last()^2
#' )$to_r()
Expr_cumulative_eval = function(expr, min_periods = 1L, parallel = FALSE) {
  unwrap(.pr$Expr$cumulative_eval(self, expr, min_periods, parallel))
}

#' Flag an Expr as "sorted"
#'
#' This enables downstream code to use fast paths for sorted arrays. WARNING:
#' this doesn't check whether the data is actually sorted, you have to ensure of
#' that yourself.
#' @param descending Sort the columns in descending order.
#' @return Expr
#' @examples
#' # correct use flag something correctly as ascendingly sorted
#' s = pl$select(pl$lit(1:4)$set_sorted()$alias("a"))$get_column("a")
#' s$flags
#'
#' # incorrect use, flag something as not sorted ascendingly
#' s2 = pl$select(pl$lit(c(1, 3, 2, 4))$set_sorted()$alias("a"))$get_column("a")
#' s2$sort()
#' s2$flags # returns TRUE while it's not actually sorted
Expr_set_sorted = function(descending = FALSE) {
  self$map_batches(\(s) {
    .pr$Series$set_sorted_mut(s, descending) # use private to bypass mut protection
    s
  })
}

#' Wrap column in list
#'
#' Aggregate values into a list.
#' @return Expr
#' @docType NULL
#' @format NULL
#' @details
#' Use `$to_struct()` to wrap a DataFrame.
#' @examples
#' df = pl$DataFrame(
#'   a = 1:3,
#'   b = 4:6
#' )
#' df$select(pl$all()$implode())
Expr_implode = use_extendr_wrapper

#' Shrink numeric columns to the minimal required datatype
#'
#' Shrink to the dtype needed to fit the extrema of this Series. This can be
#' used to reduce memory pressure.
#' @return Expr
#' @docType NULL
#' @examples
#' df = pl$DataFrame(
#'   a = 1:3,
#'   b = c(1, 2, 3)
#' )
#' df
#'
#' df$with_columns(pl$all()$shrink_dtype()$name$suffix("_shrunk"))
Expr_shrink_dtype = use_extendr_wrapper

#' List related methods
#'
#' Create an object namespace of all list related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_list = method_as_property(function() {
  expr_list_make_sub_ns(self)
})

#' String related methods
#'
#' Create an object namespace of all string related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_str = method_as_property(function() {
  expr_str_make_sub_ns(self)
})


#' Binary related methods
#'
#' Create an object namespace of all binary related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_bin = method_as_property(function() {
  expr_bin_make_sub_ns(self)
})

#' Datetime related methods
#'
#' Create an object namespace of all datetime related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_dt = method_as_property(function() {
  expr_dt_make_sub_ns(self)
})

#' Meta related methods
#'
#' Create an object namespace of all meta related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_meta = method_as_property(function() {
  expr_meta_make_sub_ns(self)
})

#' Name related methods
#'
#' Create an object namespace of all name related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_name = method_as_property(function() {
  expr_name_make_sub_ns(self)
})

#' Categorical related methods
#'
#' Create an object namespace of all categorical related methods. See the
#' individual method pages for full details.
#' @return Expr
#' @noRd
Expr_cat = method_as_property(function() {
  expr_cat_make_sub_ns(self)
})

#' Struct related methods
#'
#' Create an object namespace of all struct related methods. See the individual
#' method pages for full details.
#' @return Expr
#' @noRd
Expr_struct = method_as_property(function() {
  expr_struct_make_sub_ns(self)
})

#' Convert an Expr to a Struct
#' @return Expr
#' @examples
#' pl$DataFrame(iris[, 3:5])$with_columns(
#'   my_struct = pl$all()$to_struct()
#' )
Expr_to_struct = function() {
  pl$struct(self)
}

#' Convert Literal to Series
#'
#' Collect an expression based on literals into a Series.
#' @return Series
#' @examples
#' pl$lit(1:5)$to_series()
Expr_to_series = function() {
  pl$select(self)$to_series(0)
}


#' Find local minima
#'
#' A local minimum is the point that marks the transition between a decrease
#' and an increase in a Series. The first and last values of the Series can never
#' be a peak.
#'
#' @return Expr
#' @seealso `$peak_max()`
#'
#' @examples
#' df = pl$DataFrame(x = c(1, 2, 3, 2, 3, 4, 5, 2))
#' df
#'
#' df$with_columns(peak_min = pl$col("x")$peak_min())
Expr_peak_min = function() {
  .pr$Expr$peak_min(self)
}

#' Find local maxima
#'
#' A local maximum is the point that marks the transition between an increase
#' and a decrease in a Series. The first and last values of the Series can never
#' be a peak.
#'
#' @return Expr
#' @seealso `$peak_min()`
#'
#' @examples
#' df = pl$DataFrame(x = c(1, 2, 3, 2, 3, 4, 5, 2))
#' df
#'
#' df$with_columns(peak_max = pl$col("x")$peak_max())
Expr_peak_max = function() {
  .pr$Expr$peak_max(self)
}

#' Create rolling groups based on a time or numeric column
#'
#' @description
#' If you have a time series `<t_0, t_1, ..., t_n>`, then by default the windows
#' created will be:
#' * (t_0 - period, t_0]
#' * (t_1 - period, t_1]
#' * …
#' * (t_n - period, t_n]
#'
#' whereas if you pass a non-default offset, then the windows will be:
#' * (t_0 + offset, t_0 + offset + period]
#' * (t_1 + offset, t_1 + offset + period]
#' * …
#' * (t_n + offset, t_n + offset + period]
#'
#' @param index_column Column used to group based on the time window. Often of
#' type Date/Datetime. This column must be sorted in ascending order. If this
#' column represents an index, it has to be either Int32 or Int64. Note that
#' Int32 gets temporarily cast to Int64, so if performance matters use an Int64
#' column.
#' @param ... Ignored.
#' @param period Length of the window, must be non-negative.
#' @param offset Offset of the window. Default is `-period`.
#' @param closed Define which sides of the temporal interval are closed
#' (inclusive). This can be either `"left"`, `"right"`, `"both"` or `"none"`.
#' @param check_sorted Check whether data is actually sorted. Checking it is
#' expensive so if you are sure the data within the `index_column` is sorted, you
#' can set this to `FALSE` but note that if the data actually is unsorted, it
#' will lead to incorrect output.
#'
#' @details
#' The period and offset arguments are created either from a timedelta, or by
#' using the following string language:
#' * 1ns (1 nanosecond)
#' * 1us (1 microsecond)
#' * 1ms (1 millisecond)
#' * 1s (1 second)
#' * 1m (1 minute)
#' * 1h (1 hour)
#' * 1d (1 calendar day)
#' * 1w (1 calendar week)
#' * 1mo (1 calendar month)
#' * 1q (1 calendar quarter)
#' * 1y (1 calendar year)
#' * 1i (1 index count)
#'
#' Or combine them: "3d12h4m25s" # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' By "calendar day", we mean the corresponding time on the next day (which may
#' not be 24 hours, due to daylight savings). Similarly for "calendar week",
#' "calendar month", "calendar quarter", and "calendar year".
#'
#' In case of a rolling operation on an integer column, the windows are defined
#' by:
#' * "1i" # length 1
#' * "10i" # length 10
#'
#' @return Expr
#'
#' @examples
#' # create a DataFrame with a Datetime column and an f64 column
#' dates = c(
#'   "2020-01-01 13:45:48", "2020-01-01 16:42:13", "2020-01-01 16:45:09",
#'   "2020-01-02 18:12:48", "2020-01-03 19:45:32", "2020-01-08 23:16:43"
#' )
#'
#' df = pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$
#'   with_columns(
#'   pl$col("dt")$str$strptime(pl$Datetime(tu = "us"), format = "%Y-%m-%d %H:%M:%S")$set_sorted()
#' )
#'
#' df$with_columns(
#'   sum_a = pl$sum("a")$rolling(index_column = "dt", period = "2d"),
#'   min_a = pl$min("a")$rolling(index_column = "dt", period = "2d"),
#'   max_a = pl$max("a")$rolling(index_column = "dt", period = "2d")
#' )
#'
#' # we can use "offset" to change the start of the window period. Here, with
#' # offset = "1d", we start the window one day after the value in "dt", and
#' # then we add a 2-day window relative to the window start.
#' df$with_columns(
#'   sum_a_offset1 = pl$sum("a")$rolling(index_column = "dt", period = "2d", offset = "1d")
#' )
Expr_rolling = function(
    index_column,
    ...,
    period, offset = NULL,
    closed = "right", check_sorted = TRUE) {
  if (is.null(offset)) {
    offset = paste0("-", period)
  }
  .pr$Expr$rolling(self, index_column, period, offset, closed, check_sorted) |>
    unwrap("in $rolling():")
}

#' Replace values by different values
#'
#' This allows one to recode values in a column.
#'
#' @param old Can be several things:
#' * a vector indicating the values to recode;
#' * if `new` is missing, this can be a named list e.g `list(old = "new")` where
#'   the names are the old values and the values are the replacements. Note that
#'   if old values are numeric, the names must be wrapped in backticks;
#' * an Expr
#' @param new Either a scalar, a vector of same length as `old` or an Expr. If
#' missing, `old` must be a named list.
#' @param default The default replacement if the value is not in `old`. Can be
#' an Expr. If `NULL` (default), then the value doesn't change.
#' @param return_dtype The data type of the resulting expression. If set to
#' `NULL` (default), the data type is determined automatically based on the
#' other inputs.
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(a = c(1, 2, 2, 3))
#'
#' # "old" and "new" can take either scalars or vectors of same length
#' df$with_columns(replaced = pl$col("a")$replace(2, 100))
#' df$with_columns(replaced = pl$col("a")$replace(c(2, 3), c(100, 200)))
#'
#' # "old" can be a named list where names are values to replace, and values are
#' # the replacements
#' mapping = list(`2` = 100, `3` = 200)
#' df$with_columns(replaced = pl$col("a")$replace(mapping, default = -1))
#'
#' df = pl$DataFrame(a = c("x", "y", "z"))
#' mapping = list(x = 1, y = 2, z = 3)
#' df$with_columns(replaced = pl$col("a")$replace(mapping))
#'
#' # one can specify the data type to return instead of automatically inferring it
#' df$with_columns(replaced = pl$col("a")$replace(mapping, return_dtype = pl$Int8))
#'
#' # "old", "new", and "default" can take Expr
#' df = pl$DataFrame(a = c(1, 2, 2, 3), b = c(1.5, 2.5, 5, 1))
#' df$with_columns(
#'   replaced = pl$col("a")$replace(
#'     old = pl$col("a")$max(),
#'     new = pl$col("b")$sum(),
#'     default = pl$col("b"),
#'   )
#' )
Expr_replace = function(old, new, default = NULL, return_dtype = NULL) {
  if (missing(new) && is.list(old)) {
    new = unlist(old, use.names = FALSE)
    old = names(old)
  }
  .pr$Expr$replace(self, old, new, default, return_dtype) |>
    unwrap("in $replace():")
}

#' Get the lengths of runs of identical values
#'
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(s = c(1, 1, 2, 1, NA, 1, 3, 3))
#' df$select(pl$col("s")$rle())$unnest("s")
Expr_rle = function() {
  .pr$Expr$rle(self) |>
    unwrap("in $rle():")
}

#' Map values to run IDs
#'
#' Similar to $rle(), but it maps each value to an ID corresponding to the run
#' into which it falls. This is especially useful when you want to define groups
#' by runs of identical values rather than the values themselves. Note that
#' the ID is 0-indexed.
#'
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(a = c(1, 2, 1, 1, 1, 4))
#' df$with_columns(a_r = pl$col("a")$rle_id())
Expr_rle_id = function() {
  .pr$Expr$rle_id(self) |>
    unwrap("in $rle_id():")
}
