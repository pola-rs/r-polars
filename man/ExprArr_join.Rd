% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_join}
\alias{ExprArr_join}
\title{Join elements of an array}
\usage{
ExprArr_join(separator, ignore_nulls = FALSE)
}
\arguments{
\item{separator}{String to separate the items with. Can be an Expr. Strings
are \emph{not} parsed as columns.}

\item{ignore_nulls}{If \code{FALSE} (default), null values are propagated: if the
row contains any null values, the output is null.}
}
\value{
Expr
}
\description{
Join all string items in a sub-array and place a separator between them. This
only works on columns of type \code{list[str]}.
}
\examples{
df = pl$DataFrame(
  values = list(c("a", "b", "c"), c("x", "y", "z"), c("e", NA, NA)),
  separator = c("-", "+", "/"),
  schema = list(values = pl$Array(pl$String, 3))
)
df$with_columns(
  join_with_expr = pl$col("values")$arr$join(pl$col("separator")),
  join_with_lit = pl$col("values")$arr$join(" "),
  join_ignore_null = pl$col("values")$arr$join(" ", ignore_nulls = TRUE)
)
}
