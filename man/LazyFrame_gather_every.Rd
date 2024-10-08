% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_gather_every}
\alias{LazyFrame_gather_every}
\title{Take every nth row in the LazyFrame}
\usage{
LazyFrame_gather_every(n, offset = 0)
}
\arguments{
\item{n}{Gather every \code{n}-th row.}

\item{offset}{Starting index.}
}
\value{
A LazyFrame
}
\description{
Take every nth row in the LazyFrame
}
\examples{
lf = pl$LazyFrame(a = 1:4, b = 5:8)
lf$gather_every(2)$collect()

lf$gather_every(2, offset = 1)$collect()
}
