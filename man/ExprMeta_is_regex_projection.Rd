% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__meta.R
\name{ExprMeta_is_regex_projection}
\alias{ExprMeta_is_regex_projection}
\title{Indicate if an expression uses a regex projection}
\usage{
ExprMeta_is_regex_projection()
}
\value{
Boolean
}
\description{
Indicate if an expression uses a regex projection
}
\examples{
pl$col("^Sepal.*$")$meta$is_regex_projection()
pl$col("Sepal.Length")$meta$is_regex_projection()
}
