% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__datetime.R
\name{ExprDT_replace_time_zone}
\alias{ExprDT_replace_time_zone}
\alias{(Expr)$dt$replace_time_zone}
\title{replace_time_zone}
\format{
function
}
\arguments{
\item{tz}{Null or string time zone from base::OlsonNames()}
}
\value{
Expr of i64
}
\description{
Cast time zone for a Series of type Datetime.
Different from \code{convert_time_zone}, this will also modify the underlying timestamp.
Use to correct a wrong time zone annotation. This will change the corresponding global timepoint.
}
\examples{
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
)
df = df$with_columns(
  pl$col("date")
    $dt$replace_time_zone("Europe/Amsterdam")
    $dt$convert_time_zone("Europe/London")
    $alias("london_timezone")
)

df2 = df$with_columns(
  pl$col("london_timezone")
    $dt$replace_time_zone("Europe/Amsterdam")
    $alias("cast London_to_Amsterdam"),
  pl$col("london_timezone")
    $dt$convert_time_zone("Europe/Amsterdam")
    $alias("with London_to_Amsterdam"),
  pl$col("london_timezone")
    $dt$convert_time_zone("Europe/Amsterdam")
    $dt$replace_time_zone(NULL)
    $alias("strip tz from with-'Europe/Amsterdam'")
)
df2
}
\keyword{ExprDT}
