% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_melt}
\alias{LazyFrame_melt}
\title{Unpivot a Frame from wide to long format}
\usage{
LazyFrame_melt(
  id_vars = NULL,
  value_vars = NULL,
  variable_name = NULL,
  value_name = NULL,
  ...,
  streamable = TRUE
)
}
\arguments{
\item{id_vars}{Columns to use as identifier variables.}

\item{value_vars}{Values to use as identifier variables. If \code{value_vars} is
empty all columns that are not in \code{id_vars} will be used.}

\item{variable_name}{Name to give to the new column containing the names of
the melted columns. Defaults to "variable".}

\item{value_name}{Name to give to the new column containing the values of
the melted columns. Defaults to "value"}

\item{...}{Not used.}

\item{streamable}{Allow this node to run in the streaming engine. If this
runs in streaming, the output of the melt operation will not have a stable
ordering.}
}
\value{
A LazyFrame
}
\description{
Unpivot a Frame from wide to long format
}
\details{
Optionally leaves identifiers set.

This function is useful to massage a Frame into a format where one or more
columns are identifier variables (id_vars), while all other columns, considered
measured variables (value_vars), are "unpivoted" to the row axis, leaving just
two non-identifier columns, 'variable' and 'value'.
}
\examples{
lf = pl$LazyFrame(
  a = c("x", "y", "z"),
  b = c(1, 3, 5),
  c = c(2, 4, 6)
)
lf$melt(id_vars = "a", value_vars = c("b", "c"))$collect()
}
\keyword{LazyFrame}
