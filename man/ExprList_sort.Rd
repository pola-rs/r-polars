% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__list.R
\name{ExprList_sort}
\alias{ExprList_sort}
\title{Sort values in a list}
\usage{
ExprList_sort(descending = FALSE)
}
\arguments{
\item{descending}{Sort values in descending order}
}
\value{
Expr
}
\description{
Sort values in a list
}
\examples{
df = pl$DataFrame(values = list(c(NA, 2, 1, 3), c(Inf, 2, 3, NaN), NA_real_))
df$with_columns(sort = pl$col("values")$list$sort())
}
