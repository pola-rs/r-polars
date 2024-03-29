% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__meta.R
\name{ExprMeta_output_name}
\alias{ExprMeta_output_name}
\title{Get the column name that this expression would produce}
\usage{
ExprMeta_output_name(..., raise_if_undetermined = TRUE)
}
\arguments{
\item{...}{Ignored.}

\item{raise_if_undetermined}{If \code{TRUE} (default), raise an error if the
output name cannot be determined. Otherwise, return \code{NA}.}
}
\value{
A character vector
}
\description{
It may not always be possible to determine the output name as
that can depend on the schema of the context; in that case this will
raise an error if \code{raise_if_undetermined} is \code{TRUE} (the default), or
return \code{NA} otherwise.
}
\examples{
e = pl$col("foo") * pl$col("bar")
e$meta$output_name()

e_filter = pl$col("foo")$filter(pl$col("bar") == 13)
e_filter$meta$output_name()

e_sum_over = pl$sum("foo")$over("groups")
e_sum_over$meta$output_name()

e_sum_slice = pl$sum("foo")$slice(pl$len() - 10, pl$col("bar"))
e_sum_slice$meta$output_name()

pl$len()$meta$output_name()

pl$col("*")$meta$output_name(raise_if_undetermined = FALSE)
}
