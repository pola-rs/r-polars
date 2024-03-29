% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_arg_unique}
\alias{Expr_arg_unique}
\alias{arg_unique}
\title{Index of first unique values}
\usage{
Expr_arg_unique()
}
\value{
Expr
}
\description{
This finds the position of first occurrence of each unique value.
}
\examples{
pl$select(pl$lit(c(1:2, 1:3))$arg_unique())
}
