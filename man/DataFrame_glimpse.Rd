% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{DataFrame_glimpse}
\alias{DataFrame_glimpse}
\title{Glimpse values in a DataFrame}
\usage{
DataFrame_glimpse(..., return_as_string = FALSE)
}
\arguments{
\item{...}{not used}

\item{return_as_string}{Logical (default \code{FALSE}). If \code{TRUE}, return the
output as a string.}
}
\value{
DataFrame
}
\description{
Glimpse values in a DataFrame
}
\examples{
pl$DataFrame(iris)$glimpse()
}
\keyword{DataFrame}
