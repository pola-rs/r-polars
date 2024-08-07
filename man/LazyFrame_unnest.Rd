% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_unnest}
\alias{LazyFrame_unnest}
\title{Unnest the Struct columns of a LazyFrame}
\usage{
LazyFrame_unnest(...)
}
\arguments{
\item{...}{Names of the struct columns to unnest. This doesn't accept Expr.
If nothing is provided, then all columns of datatype \link[=DataType_Struct]{Struct}
are unnested.}
}
\value{
A LazyFrame where some or all columns of datatype Struct are unnested.
}
\description{
Unnest the Struct columns of a LazyFrame
}
\examples{
lf = pl$LazyFrame(
  a = 1:5,
  b = c("one", "two", "three", "four", "five"),
  c = 6:10
)$
  select(
  pl$struct("b"),
  pl$struct(c("a", "c"))$alias("a_and_c")
)
lf$collect()

# by default, all struct columns are unnested
lf$unnest()$collect()

# we can specify specific columns to unnest
lf$unnest("a_and_c")$collect()
}
