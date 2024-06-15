#' @export
as_polars_series <- function(x, name = NULL, ...) {
  UseMethod("as_polars_series")
}

#' @export
as_polars_series.default <- function(x, name = NULL, ...) {
  classes <- class(x)
  stop("Unsupported class: ", paste(classes, collapse = ", "))
}

#' @export
as_polars_series.polars_series <- function(x, name = NULL, ...) {
  x$rename(name %||% x$name)
}

#' @export
as_polars_series.double <- function(x, name = NULL, ...) {
  PlRSeries$new_f64(name %||% "", x) |>
    wrap()
}

#' @export
as_polars_series.integer <- function(x, name = NULL, ...) {
  PlRSeries$new_i32(name %||% "", x) |>
    wrap()
}

#' @export
as_polars_series.character <- function(x, name = NULL, ...) {
  PlRSeries$new_str(name %||% "", x) |>
    wrap()
}

#' @export
as_polars_series.logical <- function(x, name = NULL, ...) {
  PlRSeries$new_bool(name %||% "", x) |>
    wrap()
}

#' @export
as_polars_series.NULL <- function(x, name = NULL, ...) {
  PlRSeries$new_empty(name %||% "") |>
    wrap()
}

#' @export
as_polars_series.list <- function(x, name = NULL, ...) {
  series_list <- lapply(x, \(child) {
    if (is.null(child)) {
      NULL
    } else {
      as_polars_series(child)$`_s`
    }
  })

  PlRSeries$new_series_list(name %||% "", series_list) |>
    wrap()
}

#' @export
as_polars_series.AsIs <- function(x, name = NULL, ...) {
  class(x) <- setdiff(class(x), "AsIs")
  as_polars_series(x, name = name)
}
