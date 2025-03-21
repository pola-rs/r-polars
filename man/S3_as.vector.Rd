% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/s3-methods.R
\name{as.vector.RPolarsSeries}
\alias{as.vector.RPolarsSeries}
\title{Convert to a vector}
\usage{
\method{as.vector}{RPolarsSeries}(x, mode)
}
\arguments{
\item{x}{A Polars Series}

\item{mode}{Not used.}
}
\description{
Convert to a vector
}
\section{Conversion to R data types considerations}{

When converting Polars objects, such as \link[=DataFrame_class]{DataFrames}
to R objects, for example via the \code{\link[=as.data.frame.RPolarsDataFrame]{as.data.frame()}} generic function,
each type in the Polars object is converted to an R type.
In some cases, an error may occur because the conversion is not appropriate.
In particular, there is a high possibility of an error when converting
a \link[=DataType_Datetime]{Datetime} type without a time zone.
A \link[=DataType_Datetime]{Datetime} type without a time zone in Polars is converted
to the \link{POSIXct} type in R, which takes into account the time zone in which
the R session is running (which can be checked with the \code{\link[=Sys.timezone]{Sys.timezone()}}
function). In this case, if ambiguous times are included, a conversion error
will occur. In such cases, change the session time zone using
\code{\link[base:Sys.setenv]{Sys.setenv(TZ = "UTC")}} and then perform the conversion, or use the
\code{\link[=ExprDT_replace_time_zone]{$dt$replace_time_zone()}} method on the Datetime type column to
explicitly specify the time zone before conversion.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{# Due to daylight savings, clocks were turned forward 1 hour on Sunday, March 8, 2020, 2:00:00 am
# so this particular date-time doesn't exist
non_existent_time = as_polars_series("2020-03-08 02:00:00")$str$strptime(pl$Datetime(), "\%F \%T")

withr::with_timezone(
  "America/New_York",
  \{
    tryCatch(
      # This causes an error due to the time zone (the `TZ` env var is affected).
      as.vector(non_existent_time),
      error = function(e) e
    )
  \}
)
#> <error: in $to_vector(): in to_r: ComputeError(ErrString("datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.")) When calling: devtools::document()>

withr::with_timezone(
  "America/New_York",
  \{
    # This is safe.
    as.vector(non_existent_time$dt$replace_time_zone("UTC"))
  \}
)
#> [1] "2020-03-08 02:00:00 UTC"
}\if{html}{\out{</div>}}
}

