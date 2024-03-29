% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_pow}
\alias{Expr_pow}
\title{Exponentiation two expressions}
\usage{
Expr_pow(exponent)
}
\arguments{
\item{exponent}{Numeric literal or expression value.}
}
\value{
\link[=Expr_class]{Expr}
}
\description{
Method equivalent of exponentiation operator \code{expr ^ exponent}.
}
\examples{
df = pl$DataFrame(x = c(1, 2, 4, 8))

df$with_columns(
  cube = pl$col("x")$pow(3),
  `x^xlog2` = pl$col("x")$pow(pl$col("x")$log(2))
)
}
\seealso{
\itemize{
\item \link[=S3_arithmetic]{Arithmetic operators}
}
}
