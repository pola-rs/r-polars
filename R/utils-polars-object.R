#' @export
`$.polars_object` <- function(x, name) {
  if (!exists(name, envir = x)) {
    abort(
      sprintf("$ - syntax error: `%s` is not a member of the polars object.", name)
    )
  }

  NextMethod()
}
