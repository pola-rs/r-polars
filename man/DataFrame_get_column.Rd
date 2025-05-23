% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{DataFrame_get_column}
\alias{DataFrame_get_column}
\title{Get column (as one Series)}
\usage{
DataFrame_get_column(name)
}
\arguments{
\item{name}{Name of the column to extract.}
}
\value{
Series
}
\description{
Extract a DataFrame column as a Polars series.
}
\examples{
df = as_polars_df(iris[1:2, ])
df$get_column("Species")
}
\keyword{DataFrame}
