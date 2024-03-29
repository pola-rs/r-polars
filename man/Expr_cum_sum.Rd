% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_cum_sum}
\alias{Expr_cum_sum}
\title{Cumulative sum}
\usage{
Expr_cum_sum(reverse = FALSE)
}
\arguments{
\item{reverse}{If \code{TRUE}, start with the total sum of elements and substract
each row one by one.}
}
\value{
Expr
}
\description{
Get an array with the cumulative sum computed at every element.
}
\details{
The Dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
prevent overflow issues.
}
\examples{
pl$DataFrame(a = 1:4)$with_columns(
  pl$col("a")$cum_sum()$alias("cum_sum"),
  pl$col("a")$cum_sum(reverse = TRUE)$alias("cum_sum_reversed")
)
}
