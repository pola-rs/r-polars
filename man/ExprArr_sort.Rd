% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_sort}
\alias{ExprArr_sort}
\title{Sort values in an array}
\usage{
ExprArr_sort(descending = FALSE, nulls_last = FALSE)
}
\arguments{
\item{descending}{A logical. If \code{TRUE}, sort in descending order.}

\item{nulls_last}{A logical. If \code{TRUE}, place \code{null} values last insead of first.}
}
\description{
Sort values in an array
}
\examples{
df = pl$DataFrame(
  values = list(c(2, 1), c(3, 4), c(NA_real_, 6)),
  schema = list(values = pl$Array(pl$Float64, 2))
)
df$with_columns(sort = pl$col("values")$arr$sort(nulls_last = TRUE))
}
