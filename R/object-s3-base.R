#' @export
print.polars_object <- function(x, ...) {
  cat(sprintf("<%s>\n", class(x)[[1L]]))
  invisible(x)
}

#' @export
`$.polars_object` <- function(x, name) {
  if (!exists(name, envir = x)) {
    abort(
      sprintf("$ - syntax error: `%s` is not a member of this polars object", name)
    )
  }

  NextMethod()
}

#' @export
`[.polars_object` <- function(x, i, ...) {
  abort("[ - syntax error: Extracting elements of this polars object with `[` is not supported.")
}

#' @export
`$<-.polars_object` <- function(x, name, value) {
  abort(
    sprintf(
      "$<- - syntax error: Assigning to the member `%s` of this polars object is not supported.",
      name
    )
  )
}

#' @export
`[[<-.polars_object` <- function(x, i, value) {
  abort("[[<- - syntax error: Modifying elements of this polars object with `[[` is not supported")
}

#' @export
`[<-.polars_object` <- function(x, i, value) {
  abort("[<- - syntax error: Modifying elements of this polars object with `[` is not supported.")
}
