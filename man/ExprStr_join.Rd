% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_join}
\alias{ExprStr_join}
\title{Vertically concatenate the string values in the column to a single string value.}
\usage{
ExprStr_join(delimiter = "", ..., ignore_nulls = TRUE)
}
\arguments{
\item{delimiter}{The delimiter to insert between consecutive string values.}

\item{...}{Ignored.}

\item{ignore_nulls}{Ignore null values (default). If \code{FALSE}, null values will be
propagated: if the column contains any null values, the output is null.}
}
\value{
Expr of String concatenated
}
\description{
Vertically concatenate the string values in the column to a single string value.
}
\examples{
# concatenate a Series of strings to a single string
df = pl$DataFrame(foo = c(1, NA, 2))

df$select(pl$col("foo")$str$join("-"))

df$select(pl$col("foo")$str$join("-", ignore_nulls = FALSE))
}
