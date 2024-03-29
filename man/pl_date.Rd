% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions__lazy.R
\name{pl_date}
\alias{pl_date}
\title{Create a Date expression}
\usage{
pl_date(year, month, day)
}
\arguments{
\item{year}{An Expr or something coercible to an Expr, that must return an
integer. Strings are parsed as column names. Floats are cast to integers.}

\item{month}{An Expr or something coercible to an Expr, that must return an
integer between 1 and 12. Strings are parsed as column names. Floats are
cast to integers.}

\item{day}{An Expr or something coercible to an Expr, that must return an
integer between 1 and 31. Strings are parsed as column names. Floats are
cast to integers.}
}
\value{
An Expr of type Date
}
\description{
Create a Date expression
}
\examples{
df = pl$DataFrame(year = 2019:2021, month = 9:11, day = 10:12)

df$with_columns(
  date_from_cols = pl$date("year", "month", "day"),
  date_from_lit = pl$date(2020, 3, 5),
  date_from_mix = pl$date("year", 3, 5)
)

# floats are coerced to integers
df$with_columns(
  date_floats = pl$date(2018.8, 5.3, 1)
)

# if date can't be constructed, it returns null
df$with_columns(
  date_floats = pl$date(pl$lit("abc"), -2, 1)
)
}
\seealso{
\itemize{
\item \code{\link[=pl_datetime]{pl$datetime()}}
\item \code{\link[=pl_time]{pl$time()}}
}
}
