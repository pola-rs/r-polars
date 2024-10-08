% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions__eager.R
\name{pl_date_range}
\alias{pl_date_range}
\title{Generate a date range}
\usage{
pl_date_range(start, end, interval = "1d", ..., closed = "both")
}
\arguments{
\item{start}{Lower bound of the date range. Something that can be coerced to
a Date or a \link[=DataType_Datetime]{Datetime} expression. See examples for details.}

\item{end}{Upper bound of the date range. Something that can be coerced to a
Date or a \link[=DataType_Datetime]{Datetime} expression. See examples for details.}

\item{interval}{Interval of the range periods, specified as a \link{difftime} object
or using the Polars duration string language.
See the \verb{Polars duration string language} section for details.}

\item{...}{Ignored.}

\item{closed}{Define which sides of the range are closed (inclusive).
One of the followings: \code{"both"} (default), \code{"left"}, \code{"right"}, \code{"none"}.}
}
\value{
An \link[=Expr_class]{Expr} of data type Date or \link[=DataType_Datetime]{Datetime}
}
\description{
If both \code{start} and \code{end} are passed as the Date types (not Datetime), and
the \code{interval} granularity is no finer than \code{"1d"}, the returned range is
also of type Date. All other permutations return a Datetime.
}
\section{Polars duration string language}{

Polars duration string language is a simple representation of
durations. It is used in many Polars functions that accept durations.

It has the following format:
\itemize{
\item 1ns (1 nanosecond)
\item 1us (1 microsecond)
\item 1ms (1 millisecond)
\item 1s (1 second)
\item 1m (1 minute)
\item 1h (1 hour)
\item 1d (1 calendar day)
\item 1w (1 calendar week)
\item 1mo (1 calendar month)
\item 1q (1 calendar quarter)
\item 1y (1 calendar year)
}

Or combine them: \code{"3d12h4m25s"} # 3 days, 12 hours, 4 minutes, and 25 seconds

By "calendar day", we mean the corresponding time on the next day
(which may not be 24 hours, due to daylight savings).
Similarly for "calendar week", "calendar month", "calendar quarter", and "calendar year".
}

\examples{
# Using Polars duration string to specify the interval:
pl$date_range(as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo") |>
  as_polars_series("date")

# Using `difftime` object to specify the interval:
pl$date_range(
  as.Date("1985-01-01"),
  as.Date("1985-01-10"),
  as.difftime(2, units = "days")
) |>
  as_polars_series("date")
}
\seealso{
\code{\link[=pl_date_ranges]{pl$date_ranges()}} to create a simple Series of data
type list(Date) based on column values.
}
