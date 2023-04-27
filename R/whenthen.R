
#' when-then-otherwise Expr
#' @name when_then_otherwise
#' @description Start a “when, then, otherwise” expression.
#' @keywords Expr
#' @param predicate Into Expr into a boolean mask to branch by
#' @param expr Into Expr value to insert in when() or otherwise()
#' @return Expr
#' @aliases when then otherwise
#' @details
#'
#' For the impl nerds: pl$when returns a whenthen object and whenthen returns whenthenthen, except
#' for otherwise(), which will terminate and return an Expr.
#' Otherwise may fail to return an Expr if e.g. two consecutive `when(x)$when(y)`
#'
#' @examples
#'   df = pl$DataFrame(mtcars)
#'   wtt =
#'     pl$when(pl$col("cyl")<=4)$then("<=4cyl")$
#'     when(pl$col("cyl")<=6)$then("<=6cyl")$
#'     otherwise(">6cyl")$alias("cyl_groups")
#'   print(wtt)
#'   df$with_columns(wtt)
pl$when = function(predicate) { #-> When
  wrap_e_result(predicate, str_to_lit = TRUE, argname= "predicate") |>
    map(\(ok) .pr$When$when(ok)) |>
    unwrap(context = "in pl$when():")
}


When_then = function(expr) { #-> WhenThen
  wrap_e_result(expr, argname= "expr") |>
    map(\(ok) .pr$When$then(self, ok)) |>
    unwrap(context = "in when$then():")
}


WhenThen_when = function(predicate) { #-> WhenThenThen
  wrap_e_result(predicate, argname= "predicate") |>
    map(\(ok) .pr$WhenThen$when(self, ok)) |>
    unwrap(context = "in WhenThen$when():")
}


WhenThen_otherwise = function(expr) { #-> Expr
  wrap_e_result(expr, argname= "expr") |>
    #wrap in result because otherwise can panic, see comment test-whenthen
    and_then(\(ok) result(.pr$WhenThen$otherwise(self, ok))) |>
    unwrap(context = "in WhenThen$otherwise():")
}


WhenThenThen_when = function(predicate) { #-> WhenThenThen
  wrap_e_result(predicate, argname= "predicate") |>
    map(\(ok) .pr$WhenThenThen$when(self, ok)) |>
    unwrap(context = "in WhenThenThen$when():")
}


WhenThenThen_then = function(expr) { #-> WhenThenThen
  wrap_e_result(expr, argname= "expr") |>
    map(\(ok) .pr$WhenThenThen$then(self, ok)) |>
    unwrap(context = "in WhenThenThen$then():")
}


WhenThenThen_otherwise = function(expr) { #-> Expr
  wrap_e_result(expr, argname= "expr") |>
    #wrap in result because otherwise can panic, see comment test-whenthen
    and_then(\(ok) result(.pr$WhenThenThen$otherwise(self, ok))) |>
    unwrap(context = "in WhenThenThen$otherwise():")
}

WhenThenThen_peak_inside = function() {
  expr = result(self$otherwise(pl$lit("[[this otherwise is not yet defined]]"))) |>
    map_err(\(err) paste("failed to peak whenthenthen syntax because it is wrong")) |>
    unwrap("in WhenThenThen_peak_inside")
  cat(paste("Polars WhenThenThen insides:\n",paste(capture.output(print(expr)),collapse="\n")))
}




#' print When
#' @param x When object
#' @param ... not used
#' @keywords WhenThen
#'
#' @return self
#' @export
#' @examples
#' print(pl$when(pl$col("a")>2))
print.When = function(x, ...) {
  cat("polars ")
  .pr$When$print(x)
  invisible(x)
}

#' print When
#' @param x When object
#' @param ... not used
#' @keywords WhenThen internal
#' @return self
#' @export
#' @examples
#' print(pl$when(pl$col("a")>2)$then(pl$lit("more than two")))
print.WhenThen = function(x, ...) {
  cat("polars ")
  .pr$WhenThen$print(x)
  invisible(x)
}

#' print When
#' @param x When object
#' @param ... not used
#' @keywords WhenThen internal
#' @return self
#' @export
#' @examples
#' #
#' print(pl$when(pl$col("a")>2)$then(pl$lit("more than two"))$when(pl$col("b")<5))
print.WhenThenThen = function(x, ...) {
  cat("polars ")
  .pr$WhenThenThen$print(x)
  invisible(x)
}



#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x When
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.When = function(x, pattern = "") {
  paste0(ls(When, pattern = pattern ),"()")
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x WhenThen
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.WhenThen = function(x, pattern = "") {
  paste0(ls(WhenThen, pattern = pattern ),"()")
}

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x WhenThenThen
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.WhenThenThen = function(x, pattern = "") {
  paste0(ls(WhenThenThen, pattern = pattern ),"()")
}


