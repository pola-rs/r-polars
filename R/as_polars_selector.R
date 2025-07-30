as_polars_selector <- function(x, ...) {
  UseMethod("as_polars_selector")
}

#' @export
as_polars_selector.polars_selector <- function(x, ...) {
  x
}

#' @export
as_polars_selector.polars_expr <- function(x, ...) {
  x$meta$as_selector()
}

#' @export
as_polars_selector.character <- function(x, ..., strict = TRUE) {
  # Accept chr vec rather than single string
  cs__by_name(!!!x, require_all = strict)
}
