wrap <- function(x, ..., call = parent.frame()) {
  try_fetch(
    x,
    error = function(cnd) {
      err_call <- error_call(call)[[1]]
      msg_body <- if (is.call(err_call)) {
        paste0("Evaluation failed in `$", err_call[[length(err_call)]], "()`.")
      } else {
        "Evaluation failed."
      }
      abort(
        msg_body,
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
