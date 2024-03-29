% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_by.R
\name{GroupBy_shift}
\alias{GroupBy_shift}
\title{Shift}
\usage{
GroupBy_shift(periods = 1)
}
\arguments{
\item{periods}{integer Number of periods to shift (may be negative).}
}
\value{
GroupBy
}
\description{
Shift the values by a given period.
}
\examples{
pl$DataFrame(mtcars)$group_by("cyl")$shift(2)
}
\keyword{GroupBy}
