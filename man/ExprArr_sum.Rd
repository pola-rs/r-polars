% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_sum}
\alias{ExprArr_sum}
\title{Sum all elements in an array}
\usage{
ExprArr_sum()
}
\value{
Expr
}
\description{
Sum all elements in an array
}
\examples{
df = pl$DataFrame(
  values = list(c(1, 2), c(3, 4), c(NA_real_, 6)),
  schema = list(values = pl$Array(pl$Float64, 2))
)
df$with_columns(sum = pl$col("values")$arr$sum())
}
