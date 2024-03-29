% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_by.R
\name{GroupBy_class}
\alias{GroupBy_class}
\alias{RPolarsGroupBy}
\title{Operations on Polars grouped DataFrame}
\description{
The GroupBy class in R, is just another interface on top of the
\link[=DataFrame_class]{DataFrame} in rust polars.
Groupby does not use the rust api for
\code{\link[=DataFrame_group_by]{<DataFrame>$group_by()}} + \code{\link[=GroupBy_agg]{$agg()}}
because the groupby-struct is a reference to a DataFrame and that reference
will share lifetime with its parent DataFrame.
}
\details{
There is no way to expose lifetime limited objects via extendr currently
(might be quirky anyhow with R GC).
Instead the inputs for the \code{group_by} are just stored on R side, until also \code{agg} is called.
Which will end up in a self-owned DataFrame object and all is fine. groupby aggs are performed
via the rust polars LazyGroupBy methods, see DataFrame.groupby_agg method.
}
\section{Active bindings}{

\subsection{columns}{

\verb{$columns} returns a character vector with the column names.
}
}

\examples{
as_polars_df(mtcars)$group_by("cyl")$agg(
  pl$col("mpg")$sum()
)
}
