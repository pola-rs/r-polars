#' @export
`+.polars_series` <- function(e1, e2) {
  if (missing(e2)) {
    e1
  } else {
    as_polars_series(e1)$add(e2)
  }
}

#' @export
`-.polars_series` <- function(e1, e2) {
  if (missing(e2)) {
    as_polars_series(0L)$sub(e1)
  } else {
    as_polars_series(e1)$sub(e2)
  }
}

#' @export
`/.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$true_div(e2)
}

#' @export
`*.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$mul(e2)
}

#' @export
`%%.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$mod(e2)
}

#' @export
`<.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$lt(e2)
}

#' @export
`>.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$gt(e2)
}

#' @export
`<=.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$le(e2)
}

#' @export
`>=.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$ge(e2)
}

#' @export
`==.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$eq(e2)
}

#' @export
`!=.polars_series` <- function(e1, e2) {
  as_polars_series(e1)$ne(e2)
}
