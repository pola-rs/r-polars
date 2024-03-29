% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_xor}
\alias{Expr_xor}
\title{Apply logical XOR on two expressions}
\usage{
Expr_xor(other)
}
\arguments{
\item{other}{numeric or string value; accepts expression input.}
}
\value{
\link[=Expr_class]{Expr}
}
\description{
Combine two boolean expressions with XOR.
}
\examples{
pl$lit(TRUE)$xor(pl$lit(FALSE))
}
