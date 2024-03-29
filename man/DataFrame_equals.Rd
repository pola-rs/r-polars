% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{DataFrame_equals}
\alias{DataFrame_equals}
\title{Compare two DataFrames}
\usage{
DataFrame_equals(other)
}
\arguments{
\item{other}{DataFrame to compare with.}
}
\value{
A logical value
}
\description{
Check if two DataFrames are equal.
}
\examples{
dat1 = pl$DataFrame(iris)
dat2 = pl$DataFrame(iris)
dat3 = pl$DataFrame(mtcars)
dat1$equals(dat2)
dat1$equals(dat3)
}
\keyword{DataFrame}
