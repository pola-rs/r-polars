% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/series__series.R
\name{pl_Series}
\alias{pl_Series}
\alias{Series}
\title{Create new Series}
\usage{
pl_Series(
  name = NULL,
  values = NULL,
  dtype = NULL,
  ...,
  strict = TRUE,
  nan_to_null = FALSE
)
}
\arguments{
\item{name}{A character to use as the name of the Series, or \code{NULL} (default).
Passed to the \code{name} argument in \link[=as_polars_series]{as_polars_series()}.}

\item{values}{Object to convert into a polars Series.
Passed to the \code{x} argument in \link[=as_polars_series]{as_polars_series()}.}

\item{dtype}{One of \link[=pl_dtypes]{polars data type} or \code{NULL}.
If not \code{NULL}, that data type is used to \link[=Expr_cast]{cast} the Series created from the vector
to a specific data type internally.}

\item{...}{Ignored.}

\item{strict}{A logical. If \code{TRUE} (default), throw an error if any value does not exactly match
the given data type by the \code{dtype} argument. If \code{FALSE}, values that do not match the data type
are cast to that data type or, if casting is not possible, set to \code{null} instead.
Passed to the \code{strict} argument of the \code{\link[=Expr_cast]{$cast()}} method internally.}

\item{nan_to_null}{If \code{TRUE}, \code{NaN} values contained in the Series are replaced to \code{null}.
Using the \code{\link[=Expr_fill_nan]{$fill_nan()}} method internally.}
}
\value{
\link[=Series_class]{Series}
}
\description{
This function is a simple way to convert R vectors to
\link[=Series_class]{the Series class object}.
Internally, this function is a simple wrapper of \code{\link[=as_polars_series]{as_polars_series()}}.
}
\details{
Python Polars has a feature that automatically interprets something like \verb{polars.Series([1])}
as \verb{polars.Series(values=[1])} if you specify Array like objects as the first argument.
This feature is not available in R Polars, so something like \code{pl$Series(1)} will raise an error.
You should use \code{pl$Series(values = 1)} or \code{\link[=as_polars_series]{as_polars_series(1)}} instead.
}
\examples{
# Constructing a Series by specifying name and values positionally:
s = pl$Series("a", 1:3)
s

# Notice that the dtype is automatically inferred as a polars Int32:
s$dtype

# Constructing a Series with a specific dtype:
s2 = pl$Series(values = 1:3, name = "a", dtype = pl$Float32)
s2
}
\seealso{
\itemize{
\item \code{\link[=as_polars_series]{as_polars_series()}}
}
}
