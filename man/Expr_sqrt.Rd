% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_sqrt}
\alias{Expr_sqrt}
\title{Compute the square root of the elements}
\usage{
Expr_sqrt()
}
\value{
Expr
}
\description{
Compute the square root of the elements
}
\examples{
pl$DataFrame(a = -1:3)$with_columns(a_sqrt = pl$col("a")$sqrt())
}
