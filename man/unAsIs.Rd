% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{unAsIs}
\alias{unAsIs}
\title{Reverts wrapping in I}
\usage{
unAsIs(X)
}
\arguments{
\item{X}{any Robj wrapped in `I()``}
}
\value{
X without any AsIs subclass
}
\description{
Reverts wrapping in I
}
\details{
https://stackoverflow.com/questions/12865218/getting-rid-of-asis-class-attribute
}
\keyword{internal}
