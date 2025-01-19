expr_wrap_function_factory <- function(fn, self, namespace = NULL) {
  `_s` <- self$`_s`
  environment(fn) <- environment()

  # Override `self` with the column expression or namespace
  if (is.null(namespace)) {
    self <- pl$col(`_s`$name())
  } else {
    self <- pl$col(`_s`$name())[[namespace]]
  }

  new_fn <- function() {
    wrap({
      expr <- do.call(fn, as.list(match.call()[-1]), envir = parent.frame())
      wrap(`_s`)$to_frame()$select(expr)$to_series()
    })
  }

  formals(new_fn) <- formals(fn)

  new_fn
}
