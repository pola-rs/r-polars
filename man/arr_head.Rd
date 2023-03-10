% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__list.R
\name{arr_head}
\alias{arr_head}
\alias{arr.head}
\title{Heads of sublists}
\format{
function
}
\arguments{
\item{n}{Numeric or Expr, number of values to return for each sublist.}
}
\value{
Expr
}
\description{
head the first \code{n} values of every sublist.
}
\examples{
df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
df$select(pl$col("a")$arr$head(2))
}
\keyword{ExprArr}
