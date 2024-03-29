% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_tail}
\alias{Expr_tail}
\title{Get the last n elements}
\usage{
Expr_tail(n = 10)
}
\arguments{
\item{n}{Number of elements to take.}
}
\value{
Expr
}
\description{
Get the last n elements
}
\examples{
pl$DataFrame(x = 1:11)$select(pl$col("x")$tail(3))
}
