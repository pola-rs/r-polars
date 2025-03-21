% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_with_columns}
\alias{LazyFrame_with_columns}
\title{Select and modify columns of a LazyFrame}
\usage{
LazyFrame_with_columns(...)
}
\arguments{
\item{...}{Any expressions or string column name, or same wrapped in a list.
If first and only element is a list, it is unwrapped as a list of args.}
}
\value{
A LazyFrame
}
\description{
Add columns or modify existing ones with expressions. This is
the equivalent of \code{dplyr::mutate()} as it keeps unmentioned columns (unlike
\verb{$select()}).
}
\examples{
as_polars_lf(iris)$with_columns(
  pl$col("Sepal.Length")$abs()$alias("abs_SL"),
  (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
)

# same query
l_expr = list(
  pl$col("Sepal.Length")$abs()$alias("abs_SL"),
  (pl$col("Sepal.Length") + 2)$alias("add_2_SL")
)
as_polars_lf(iris)$with_columns(l_expr)

as_polars_lf(iris)$with_columns(
  pl$col("Sepal.Length")$abs(), # not named expr will keep name "Sepal.Length"
  SW_add_2 = (pl$col("Sepal.Width") + 2)
)
}
