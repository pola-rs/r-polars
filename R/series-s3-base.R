#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$as_str() |>
    writeLines()
  invisible(x)
}

#' @export
`[.polars_namespace_series_struct` <- `[.polars_namespace_expr_struct`

# TODO: support the mode argument
#' @export
as.vector.polars_series <- function(x, mode = "any") {
  x$to_r_vector(ensure_vector = TRUE) |>
    as.vector(mode = mode)
}

# TODO: as.character.polars_series

#' @export
length.polars_series <- function(x) x$len()
