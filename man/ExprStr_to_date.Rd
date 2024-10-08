% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_to_date}
\alias{ExprStr_to_date}
\title{Convert a String column into a Date column}
\usage{
ExprStr_to_date(format = NULL, ..., strict = TRUE, exact = TRUE, cache = TRUE)
}
\arguments{
\item{format}{Format to use for conversion. Refer to
\href{https://docs.rs/chrono/latest/chrono/format/strftime/index.html}{the chrono crate documentation}
for the full specification. Example: \code{"\%Y-\%m-\%d \%H:\%M:\%S"}.
If \code{NULL} (default), the format is inferred from the data.
Notice that time zone \verb{\%Z} is not supported and will just ignore timezones.
Numeric time zones like \verb{\%z} or \verb{\%:z} are supported.}

\item{...}{Not used.}

\item{strict}{If \code{TRUE} (default), raise an error if a single string cannot
be parsed. If \code{FALSE}, produce a polars \code{null}.}

\item{exact}{If \code{TRUE} (default), require an exact format match. If \code{FALSE},
allow the format to match anywhere in the target string.
Conversion to the Time type is always exact.
Note that using \code{exact = FALSE} introduces a performance penalty -
cleaning your data beforehand will almost certainly be more performant.}

\item{cache}{Use a cache of unique, converted dates to apply the datetime
conversion.}
}
\value{
\link[=Expr_class]{Expr} of Date type
}
\description{
Convert a String column into a Date column
}
\examples{
s = as_polars_series(c("2020/01/01", "2020/02/01", "2020/03/01"))

s$str$to_date()

# by default, this errors if some values cannot be converted
s = as_polars_series(c("2020/01/01", "2020 02 01", "2020-03-01"))
try(s$str$to_date())
s$str$to_date(strict = FALSE)
}
\seealso{
\itemize{
\item \code{\link[=ExprStr_strptime]{<Expr>$str$strptime()}}
}
}
