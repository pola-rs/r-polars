% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__datetime.R
\name{ExprDT_epoch}
\alias{ExprDT_epoch}
\alias{(Expr)$dt$epoch}
\title{Epoch}
\usage{
ExprDT_epoch(tu = c("us", "ns", "ms", "s", "d"))
}
\arguments{
\item{tu}{string option either 'ns', 'us', 'ms', 's' or  'd'}
}
\value{
Expr of epoch as UInt32
}
\description{
Get the time passed since the Unix EPOCH in the give time unit.
}
\details{
ns and perhaps us will exceed integerish limit if returning to
R as flaot64/double.
}
\examples{
as_polars_series(as.Date("2022-1-1"))$dt$epoch("ns")
as_polars_series(as.Date("2022-1-1"))$dt$epoch("ms")
as_polars_series(as.Date("2022-1-1"))$dt$epoch("s")
as_polars_series(as.Date("2022-1-1"))$dt$epoch("d")
}
\keyword{ExprDT}
