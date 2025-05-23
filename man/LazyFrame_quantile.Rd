% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_quantile}
\alias{LazyFrame_quantile}
\title{Quantile}
\usage{
LazyFrame_quantile(quantile, interpolation = "nearest")
}
\arguments{
\item{quantile}{Numeric of length 1 between 0 and 1.}

\item{interpolation}{One of \code{"nearest"}, \code{"higher"}, \code{"lower"},
\code{"midpoint"}, or \code{"linear"}.}
}
\value{
LazyFrame
}
\description{
Aggregate the columns in the DataFrame to a unique quantile
value. Use \verb{$describe()} to specify several quantiles.
}
\examples{
as_polars_lf(mtcars)$quantile(.4)$collect()
}
