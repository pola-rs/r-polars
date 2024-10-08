% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__list.R
\name{ExprList_mean}
\alias{ExprList_mean}
\title{Compute the mean value of a list}
\usage{
ExprList_mean()
}
\value{
Expr
}
\description{
Compute the mean value of a list
}
\examples{
df = pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_))
df$with_columns(mean = pl$col("values")$list$mean())
}
