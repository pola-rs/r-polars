% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_gather_every}
\alias{Expr_gather_every}
\title{Gather every nth element}
\usage{
Expr_gather_every(n, offset = 0)
}
\arguments{
\item{n}{Positive integer.}

\item{offset}{Starting index.}
}
\value{
Expr
}
\description{
Gather every nth value in the Series and return as a new Series.
}
\examples{
pl$DataFrame(a = 0:24)$select(pl$col("a")$gather_every(6))
}
