% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_fill_nan}
\alias{LazyFrame_fill_nan}
\title{Fill \code{NaN}}
\usage{
LazyFrame_fill_nan(fill_value)
}
\arguments{
\item{fill_value}{Value to fill \code{NaN} with.}
}
\value{
LazyFrame
}
\description{
Fill \code{NaN} values by an Expression evaluation.
}
\examples{
df = pl$LazyFrame(
  a = c(1.5, 2, NaN, 4),
  b = c(1.5, NaN, NaN, 4)
)
df$fill_nan(99)$collect()
}
\keyword{LazyFrame}
