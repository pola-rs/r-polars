% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__expr.R
\name{Expr_mode}
\alias{Expr_mode}
\title{Mode}
\usage{
Expr_mode()
}
\value{
Expr
}
\description{
Compute the most occurring value(s). Can return multiple values if there are
ties.
}
\examples{
df = pl$DataFrame(a = 1:6, b = c(1L, 1L, 3L, 3L, 5L, 6L), c = c(1L, 1L, 2L, 2L, 3L, 3L))
df$select(pl$col("a")$mode())
df$select(pl$col("b")$mode())
df$select(pl$col("c")$mode())
}
