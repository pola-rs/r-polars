% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/series__series.R
\name{Series_pow}
\alias{Series_pow}
\title{Power Series}
\usage{
Series_pow(exponent)
}
\arguments{
\item{exponent}{\link[=Series_class]{Series} like object of numeric.
Converted to \link[=Series_class]{Series} by \code{\link[=as_polars_series]{as_polars_series()}} in this method.}
}
\value{
\link[=Series_class]{Series}
}
\description{
Method equivalent of power operator \code{series ^ other}.
}
\examples{
s = as_polars_series(1:4, name = "foo")

s$pow(3L)
}
\seealso{
\itemize{
\item \link[=S3_arithmetic]{Arithmetic operators}
}
}
