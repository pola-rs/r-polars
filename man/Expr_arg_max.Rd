% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_arg_max}
\alias{Expr_arg_max}
\title{Index of max value}
\usage{
Expr_arg_max()
}
\value{
Expr
}
\description{
Get the index of the maximal value.
}
\examples{
pl$DataFrame(
  a = c(6, 1, 0, NA, Inf, NaN)
)$with_columns(arg_max = pl$col("a")$arg_max())
}
