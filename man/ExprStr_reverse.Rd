% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_reverse}
\alias{ExprStr_reverse}
\title{Returns string values in reversed order}
\usage{
ExprStr_reverse()
}
\value{
Expr
}
\description{
Returns string values in reversed order
}
\examples{
df = pl$DataFrame(text = c("foo", "bar", NA))
df$with_columns(reversed = pl$col("text")$str$reverse())
}
