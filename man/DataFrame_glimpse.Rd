% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{DataFrame_glimpse}
\alias{DataFrame_glimpse}
\title{Show a dense preview of the DataFrame}
\usage{
DataFrame_glimpse(
  ...,
  max_items_per_column = 10,
  max_colname_length = 50,
  return_as_string = FALSE
)
}
\arguments{
\item{...}{Ignored.}

\item{max_items_per_column}{Maximum number of items to show per column.}

\item{max_colname_length}{Maximum length of the displayed column names. Values
that exceed this value are truncated with a trailing ellipsis.}

\item{return_as_string}{Logical (default \code{FALSE}). If \code{TRUE}, return the
output as a string.}
}
\value{
DataFrame
}
\description{
The formatting shows one line per column so that wide DataFrames display
cleanly. Each line shows the column name, the data type, and the first few
values.
}
\examples{
as_polars_df(iris)$glimpse()
}
