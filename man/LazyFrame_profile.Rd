% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lazyframe__lazy.R
\name{LazyFrame_profile}
\alias{LazyFrame_profile}
\title{Collect and profile a lazy query.}
\usage{
LazyFrame_profile(
  type_coercion = TRUE,
  predicate_pushdown = TRUE,
  projection_pushdown = TRUE,
  simplify_expression = TRUE,
  slice_pushdown = TRUE,
  comm_subplan_elim = TRUE,
  comm_subexpr_elim = TRUE,
  cluster_with_columns = TRUE,
  streaming = FALSE,
  no_optimization = FALSE,
  collect_in_background = FALSE,
  show_plot = FALSE,
  truncate_nodes = 0
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

\item{no_optimization}{Logical. Sets the following parameters to \code{FALSE}:
\code{predicate_pushdown}, \code{projection_pushdown}, \code{slice_pushdown},
\code{comm_subplan_elim}, \code{comm_subexpr_elim}, \code{cluster_with_columns}.}

\item{collect_in_background}{Logical. Detach this query from R session.
Computation will start in background. Get a handle which later can be converted
into the resulting DataFrame. Useful in interactive mode to not lock R session.}

\item{show_plot}{Show a Gantt chart of the profiling result}

\item{truncate_nodes}{Truncate the label lengths in the Gantt chart to this
number of characters. If \code{0} (default), do not truncate.}
}
\value{
List of two \code{DataFrame}s: one with the collected result, the other
with the timings of each step. If \code{show_graph = TRUE}, then the plot is
also stored in the list.
}
\description{
This will run the query and return a list containing the
materialized DataFrame and a DataFrame that contains profiling information
of each node that is executed.
}
\details{
The units of the timings are microseconds.
}
\examples{
## Simplest use case
pl$LazyFrame()$select(pl$lit(2) + 2)$profile()

## Use $profile() to compare two queries

# -1-  map each Species-group with native polars, takes ~120us only
as_polars_lf(iris)$
  sort("Sepal.Length")$
  group_by("Species", maintain_order = TRUE)$
  agg(pl$col(pl$Float64)$first() + 5)$
  profile()

# -2-  map each Species-group of each numeric column with an R function, takes ~7000us (slow!)

# some R function, prints `.` for each time called by polars
r_func = \(s) {
  cat(".")
  s$to_r()[1] + 5
}

as_polars_lf(iris)$
  sort("Sepal.Length")$
  group_by("Species", maintain_order = TRUE)$
  agg(pl$col(pl$Float64)$map_elements(r_func))$
  profile()
}
\seealso{
\itemize{
\item \code{\link[=LazyFrame_collect]{$collect()}} - regular collect.
\item \code{\link[=LazyFrame_fetch]{$fetch()}} - fast limited query check
\item \code{\link[=LazyFrame_collect_in_background]{$collect_in_background()}} - non-blocking
collect returns a future handle. Can also just be used via
\verb{$collect(collect_in_background = TRUE)}.
\item \code{\link[=LazyFrame_sink_parquet]{$sink_parquet()}} streams query to a parquet file.
\item \code{\link[=LazyFrame_sink_ipc]{$sink_ipc()}} streams query to a arrow file.
}
}
\keyword{LazyFrame}
