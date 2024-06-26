% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_set_optimization_toggle}
\alias{LazyFrame_set_optimization_toggle}
\title{Configure optimization toggles}
\usage{
LazyFrame_set_optimization_toggle(
  type_coercion = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  streaming = FALSE,
  eager = FALSE
)
}
\arguments{
\item{type_coercion}{Logical. Coerce types such that operations succeed and
run on minimal required memory.}

\item{predicate_pushdown}{Logical. Applies filters as early as possible at
scan level.}

\item{projection_pushdown}{Logical. Select only the columns that are needed
at the scan level.}

\item{simplify_expression}{Logical. Various optimizations, such as constant
folding and replacing expensive operations with faster alternatives.}

\item{slice_pushdown}{Logical. Only load the required slice from the scan
level. Don't materialize sliced outputs (e.g. \code{join$head(10)}).}

\item{comm_subplan_elim}{Logical. Will try to cache branching subplans that
occur on self-joins or unions.}

\item{comm_subexpr_elim}{Logical. Common subexpressions will be cached and
reused.}

\item{cluster_with_columns}{Combine sequential independent calls to
\code{\link[=DataFrame_with_columns]{with_columns()}}.}

\item{streaming}{Logical. Run parts of the query in a streaming fashion
(this is in an alpha state).}

\item{eager}{Logical. Run the query eagerly.}
}
\value{
LazyFrame with specified optimization toggles
}
\description{
Configure the optimization toggles for the lazy query
}
\examples{
pl$LazyFrame(mtcars)$set_optimization_toggle(type_coercion = FALSE)
}
\keyword{LazyFrame}
