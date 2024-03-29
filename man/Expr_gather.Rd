% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_gather}
\alias{Expr_gather}
\title{Gather values by index}
\usage{
Expr_gather(indices)
}
\arguments{
\item{indices}{R vector or Series, or Expr that leads to a Series of
dtype Int64. (0-indexed)}
}
\value{
Expr
}
\description{
Gather values by index
}
\examples{
df = pl$DataFrame(a = 1:10)

df$select(pl$col("a")$gather(c(0, 2, 4, -1)))
}
