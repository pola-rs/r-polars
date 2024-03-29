% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_null_count}
\alias{Expr_null_count}
\title{Count missing values}
\usage{
Expr_null_count()
}
\value{
Expr
}
\description{
Count missing values
}
\examples{
pl$DataFrame(x = c(NA, "a", NA, "b"))$
  with_columns(n_missing = pl$col("x")$null_count())
}
