wrap <- function(x, ..., call = parent.frame()) {
  try_fetch(
    x,
    error = function(cnd) {
      abort("Evaluation failed.", call = call, parent = cnd)
    }
  )

  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  abort("Unimplemented class!")
}
