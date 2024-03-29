% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_upper_bound}
\alias{Expr_upper_bound}
\title{Find the upper bound of a DataType}
\usage{
Expr_upper_bound()
}
\value{
Expr
}
\description{
Find the upper bound of a DataType
}
\examples{
pl$DataFrame(
  x = c(1, 2, 3), y = -2:0,
  schema = list(x = pl$Float64, y = pl$Int32)
)$
  select(pl$all()$upper_bound())
}
