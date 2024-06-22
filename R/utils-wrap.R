wrap <- function(x, ..., call = parent.frame()) {
  try_fetch(
    x,
    error = function(cnd) {
      err_call <- rlang::error_call(call)[[1]]
      abort(
        paste0("Evaluation failed in `$", err_call[[length(err_call)]], "()`."),
        call = call,
        parent = cnd
      )
    }
  )

  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  abort("Unimplemented class!")
}
