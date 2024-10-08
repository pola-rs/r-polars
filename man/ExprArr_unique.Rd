% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_unique}
\alias{ExprArr_unique}
\title{Get unique values in an array}
\usage{
ExprArr_unique(maintain_order = FALSE)
}
\arguments{
\item{maintain_order}{If \code{TRUE}, the unique values are returned in order of
appearance.}
}
\value{
Expr
}
\description{
Get unique values in an array
}
\examples{
df = pl$DataFrame(
  values = list(c(1, 1, 2), c(4, 4, 4), c(NA_real_, 6, 7)),
  schema = list(values = pl$Array(pl$Float64, 3))
)
df$with_columns(unique = pl$col("values")$arr$unique())
}
