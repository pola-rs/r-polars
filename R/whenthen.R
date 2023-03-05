

pl$when = function(predicate) { #-> When
  wrap_e_result(predicate, str_to_lit = TRUE, argname= "predicate") |>
    map(\(ok) .pr$When$when(ok)) |>
    unwrap(context = "in pl$when():")
}
#TODO contribute polars, suggest all When function has str_to_lit FALSE

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
    map(\(ok) .pr$WhenThen$otherwise(self, ok)) |>
    unwrap(context = "in WhenThen$otherwise():")
}

#' WhenThenThen_when
#' @name WhenThenThen_when
#' @aliases WhenThenThen_when
#' @description WhenThenThen_when
#' @keywords WhenThen
#' @param predicate Expr
#' @return Expr: Series of dtype Utf8.
#'
#' @examples
#' #TODO
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
    map(\(ok) .pr$WhenThenThen$otherwise(self, ok)) |>
    unwrap(context = "in WhenThenThen$otherwise():")
}

WhenThenThen_peak_inside = function() {
  expr = self$otherwise(pl$lit("[[this otherwise is not yet defined]]"))
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
#' @keywords WhenThen
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
#' @keywords WhenThen
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


