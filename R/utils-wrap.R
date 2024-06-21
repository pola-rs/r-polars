wrap <- function(x, ...) {
  try_fetch(x, error = function(cnd) abort("Evaluation failed.", parent = cnd))

  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  stop("Unimplemented class!")
}
