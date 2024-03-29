% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__datetime.R
\name{ExprDT_month}
\alias{ExprDT_month}
\alias{(Expr)$dtmonth}
\title{Month}
\usage{
ExprDT_month()
}
\value{
Expr of month as UInt32
}
\description{
Extract month from underlying Date representation.
Applies to Date and Datetime columns.
Returns the month number starting from 1.
The return value ranges from 1 to 12.
}
\examples{
df = pl$DataFrame(
  date = pl$date_range(
    as.Date("2020-12-25"),
    as.Date("2021-1-05"),
    interval = "1d",
    time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$month()$alias("month")
)
}
\keyword{ExprDT}
