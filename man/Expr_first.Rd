% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_first}
\alias{Expr_first}
\title{Get the first value.}
\usage{
Expr_first()
}
\value{
Expr
}
\description{
Get the first value.
}
\examples{
pl$DataFrame(x = 3:1)$with_columns(first = pl$col("x")$first())
}
