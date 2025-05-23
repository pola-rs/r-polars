% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{DataFrame_drop_in_place}
\alias{DataFrame_drop_in_place}
\title{Drop in place}
\usage{
DataFrame_drop_in_place(name)
}
\arguments{
\item{name}{string Name of the column to drop.}
}
\value{
Series
}
\description{
Drop a single column in-place and return the dropped column.
}
\examples{
dat = as_polars_df(iris)
x = dat$drop_in_place("Species")
x
dat$columns
}
\keyword{DataFrame}
