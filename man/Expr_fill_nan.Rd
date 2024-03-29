% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_fill_nan}
\alias{Expr_fill_nan}
\title{Fill NaN}
\usage{
Expr_fill_nan(expr = NULL)
}
\arguments{
\item{expr}{Expr or something coercible in an Expr}
}
\value{
Expr
}
\description{
Fill NaN
}
\examples{
pl$DataFrame(a = c(NaN, 1, NaN, 2, NA))$
  with_columns(
  literal = pl$col("a")$fill_nan(999),
  # implicit coercion to string
  string = pl$col("a")$fill_nan("invalid")
)
}
