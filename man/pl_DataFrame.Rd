% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataframe__frame.R
\name{pl_DataFrame}
\alias{pl_DataFrame}
\title{Create a new polars DataFrame}
\usage{
pl_DataFrame(..., make_names_unique = TRUE, schema = NULL)
}
\arguments{
\item{...}{One of the following:
\itemize{
\item a list of mixed vectors and Series of equal length
\item mixed vectors and/or Series of equal length
\item a positional argument of a \link{data.frame} or a \link[=DataFrame_class]{DataFrame}
(not recommended use). In this case, the object will be passed to \code{\link[=as_polars_df]{as_polars_df()}}.
}

Columns will be named as of named arguments or alternatively by names of
Series or given a placeholder name.}

\item{make_names_unique}{If \code{TRUE} (default), any duplicated names will be
prefixed a running number.}

\item{schema}{A named list that will be used to convert a variable to a
specific DataType. See Examples.}
}
\value{
\link[=DataFrame_class]{DataFrame}
}
\description{
Create a new polars DataFrame
}
\examples{
pl$DataFrame(
  a = c(1, 2, 3, 4, 5),
  b = 1:5,
  c = letters[1:5],
  d = list(1:1, 1:2, 1:3, 1:4, 1:5)
) # directly from vectors

# from a list of vectors
pl$DataFrame(list(
  a = c(1, 2, 3, 4, 5),
  b = 1:5,
  c = letters[1:5],
  d = list(1L, 1:2, 1:3, 1:4, 1:5)
))

# from a data.frame
pl$DataFrame(mtcars)

# custom schema
pl$DataFrame(iris, schema = list(Sepal.Length = pl$Float32, Species = pl$String))
}
\seealso{
\itemize{
\item \code{\link[=as_polars_df]{as_polars_df()}}
}
}
