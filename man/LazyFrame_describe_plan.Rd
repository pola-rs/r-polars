% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_describe_optimized_plan}
\alias{LazyFrame_describe_optimized_plan}
\alias{LazyFrame_describe_plan}
\title{Print the optimized or non-optimized plans of \code{LazyFrame}}
\usage{
LazyFrame_describe_optimized_plan()

LazyFrame_describe_plan()
}
\value{
This only prints the plan in the console, it doesn't return any value.
}
\description{
\verb{$describe_plan()} shows the query in the format that \code{polars}
understands. \verb{$describe_optimized_plan()} shows the optimized query plan that
\code{polars} will execute when \verb{$collect()} is called. It is possible that both
plans are identical if \code{polars} doesn't find any way to optimize the query.
}
\examples{
lazy_frame = pl$LazyFrame(iris)

# Prepare your query
lazy_query = lazy_frame$sort("Species")$filter(pl$col("Species") != "setosa")

# This is the query as `polars` understands it
lazy_query$describe_plan()

# This is the query after `polars` optimizes it: instead of sorting first and
# then filtering, it is faster to filter first and then sort the rest.
lazy_query$describe_optimized_plan()
}
