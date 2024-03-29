% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_is_finite}
\alias{Expr_is_finite}
\title{Check if elements are finite}
\usage{
Expr_is_finite()
}
\value{
Expr
}
\description{
Returns a boolean Series indicating which values are finite.
}
\examples{
pl$DataFrame(list(alice = c(0, NaN, NA, Inf, -Inf)))$
  with_columns(finite = pl$col("alice")$is_finite())
}
