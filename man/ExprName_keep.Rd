% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__name.R
\name{ExprName_keep}
\alias{ExprName_keep}
\title{Keep the original root name of the expression.}
\usage{
ExprName_keep()
}
\value{
Expr
}
\description{
Keep the original root name of the expression.
}
\examples{
pl$DataFrame(list(alice = 1:3))$select(pl$col("alice")$alias("bob")$name$keep())
}
