% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_quantile}
\alias{Expr_quantile}
\title{Get quantile value.}
\usage{
Expr_quantile(quantile, interpolation = "nearest")
}
\arguments{
\item{quantile}{Either a numeric value or an Expr whose value must be
between 0 and 1.}

\item{interpolation}{One of \code{"nearest"}, \code{"higher"}, \code{"lower"},
\code{"midpoint"}, or \code{"linear"}.}
}
\value{
Expr
}
\description{
Get quantile value.
}
\details{
Null values are ignored and \code{NaN}s are ranked as the largest value.
For linear interpolation \code{NaN} poisons \code{Inf}, that poisons any other value.
}
\examples{
pl$DataFrame(x = -5:5)$
  select(pl$col("x")$quantile(0.5))
}
