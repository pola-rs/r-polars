% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__meta.R
\name{ExprMeta_undo_aliases}
\alias{ExprMeta_undo_aliases}
\title{Undo any renaming operation}
\usage{
ExprMeta_undo_aliases()
}
\value{
Expr with aliases undone
}
\description{
This removes any renaming operation like \code{\link[=Expr_alias]{$alias()}} or
\code{\link[=ExprName_keep]{$name$keep()}}. Polars uses the "leftmost rule" to determine
naming, meaning that the first element of the expression will be used to
name the output.
}
\examples{
e = (pl$col("alice") + pl$col("eve"))$alias("bob")
e$meta$output_name()
e$meta$undo_aliases()$meta$output_name()
}
