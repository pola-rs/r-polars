% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/series__series.R
\name{Series_arg_max}
\alias{Series_arg_max}
\title{Index of max value}
\usage{
Series_arg_max()
}
\value{
A numeric value
}
\description{
Note that this is 0-indexed.
}
\examples{
as_polars_series(c(5, 1))$arg_max()
}
