% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__meta.R
\name{ExprMeta_tree_format}
\alias{ExprMeta_tree_format}
\title{Format an expression as a tree}
\usage{
ExprMeta_tree_format(return_as_string = FALSE)
}
\arguments{
\item{return_as_string}{Return the tree as a character vector? If \code{FALSE}
(default), the tree is printed in the console.}
}
\value{
If \code{return_as_string} is \code{TRUE}, a character vector describing the tree.

If \code{return_as_string} is \code{FALSE}, prints the tree in the console but doesn't
return any value.
}
\description{
Format an expression as a tree
}
\examples{
my_expr = (pl$col("foo") * pl$col("bar"))$sum()$over(pl$col("ham")) / 2
my_expr$meta$tree_format()
}
