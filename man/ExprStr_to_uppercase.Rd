% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_to_uppercase}
\alias{ExprStr_to_uppercase}
\title{Convert a string to uppercase}
\usage{
ExprStr_to_uppercase()
}
\value{
Expr of String uppercase chars
}
\description{
Transform to uppercase variant.
}
\examples{
pl$lit(c("A", "b", "c", "1", NA))$str$to_uppercase()$to_series()
}
\keyword{ExprStr}
