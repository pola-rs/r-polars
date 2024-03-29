% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions__lazy.R
\name{pl_var}
\alias{pl_var}
\title{Get the variance.}
\usage{
pl_var(..., ddof = 1)
}
\arguments{
\item{...}{Characters indicating the column names, passed to \code{\link[=pl_col]{pl$col()}}.
See \code{\link[=pl_col]{?pl_col}} for details.}

\item{ddof}{An integer representing "Delta Degrees of Freedom":
the divisor used in the calculation is \code{N - ddof},
where \code{N} represents the number of elements. By default ddof is \code{1}.}
}
\value{
\link[=Expr_class]{Expr}
}
\description{
This function is syntactic sugar for \code{pl$col(...)$var(ddof)}.
}
\examples{
df = pl$DataFrame(
  a = c(1, 8, 3),
  b = c(4, 5, 2),
  c = c("foo", "bar", "foo")
)

df$select(pl$var("a"))

df$select(pl$var("a", "b"))
}
\seealso{
\itemize{
\item \code{\link[=Expr_var]{<Expr>$var()}}
}
}
