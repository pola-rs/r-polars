% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_count_matches}
\alias{ExprStr_count_matches}
\title{Count all successive non-overlapping regex matches}
\usage{
ExprStr_count_matches(pattern, literal = FALSE)
}
\arguments{
\item{pattern}{A valid regex pattern}

\item{literal}{Treat pattern as a literal string.}
}
\value{
UInt32 array. Contains null if original value is null or regex capture nothing.
}
\description{
Count all successive non-overlapping regex matches
}
\examples{
df = pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
  pl$col("foo")$str$count_matches(r"{(\d)}")$alias("count digits")
)

# we can use Polars expressions as pattern so that it's not necessarily the
# same for all rows
df2 = pl$DataFrame(foo = c("hello", "hi there"), pat = c("ell", "e"))
df2$with_columns(
  pl$col("foo")$str$count_matches(pl$col("pat"))$alias("reg_count")
)
}
\keyword{ExprStr}
