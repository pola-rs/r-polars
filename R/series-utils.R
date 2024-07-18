expr_wrap_function_factory <- function(fn, self) {
  `_s` <- self$`_s`
  self <- pl$col(`_s`$name())
  environment(fn) <- environment()

  new_fn <- function() {
    wrap({
      expr <- do.call(fn, as.list(match.call()[-1]), envir = parent.frame())
      wrap(`_s`)$to_frame()$select(expr)$to_series()
    })
  }

  formals(new_fn) <- formals(fn)

  new_fn
}
