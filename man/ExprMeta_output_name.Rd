% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__meta.R
\name{ExprMeta_output_name}
\alias{ExprMeta_output_name}
\alias{expr_meta_output_names}
\title{Output Name}
\value{
R charvec of output names.
}
\description{
Get the column name that this expression would produce.
It might not always be possible to determine the output name
as it might depend on the schema of the context. In that case
this will raise an error.
}
\examples{
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
}
\keyword{ExprMeta}
