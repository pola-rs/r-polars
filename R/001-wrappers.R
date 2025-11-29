# Override the default `.savvy_wrap_*` functions for avoiding assignment many members to the env.
# See <https://github.com/pola-rs/r-polars/issues/1439> for details.
# TODO: generate this file automatically

PlRExprMethods <- new.env(parent = emptyenv())

`.savvy_wrap_PlRExpr` <- function(ptr) {
  e <- new.env(parent = emptyenv())
  e$.ptr <- ptr

  class(e) <- c("polars::PlRExpr", "PlRExpr", "savvy_polars__sealed")
  e
}

#' @export
`$.polars::PlRExpr` <- function(x, name) {
  method_names <- names(PlRExprMethods)
  ptr <- env_get(x, ".ptr")

  if (identical(name, ".ptr")) {
    ptr
  } else if (name %in% method_names) {
    PlRExprMethods[[name]](ptr)
  } else {
    NextMethod()
  }
}
