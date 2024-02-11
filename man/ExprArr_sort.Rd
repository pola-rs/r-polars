% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_sort}
\alias{ExprArr_sort}
\alias{arr_sort}
\title{Sort values in an array}
\usage{
ExprArr_sort(descending = FALSE, nulls_last = FALSE)
}
\arguments{
\item{descending}{Sort in descending order. When sorting by multiple columns,
can be specified per column by passing a vector of booleans.}

\item{nulls_last}{If \code{TRUE}, place nulls values last.}
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