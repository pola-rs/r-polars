% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_exp}
\alias{Expr_exp}
\title{Compute the exponential of the elements}
\usage{
Expr_exp()
}
\value{
Expr
}
\description{
Compute the exponential of the elements
}
\examples{
pl$DataFrame(a = -1:3)$with_columns(a_exp = pl$col("a")$exp())
}
