% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__list.R
\name{ExprList_all}
\alias{ExprList_all}
\title{Evaluate whether all boolean values in a list are true}
\usage{
ExprList_all()
}
\value{
Expr
}
\description{
Evaluate whether all boolean values in a list are true
}
\examples{
df = pl$DataFrame(
  list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
)
df$with_columns(all = pl$col("a")$list$all())
}
