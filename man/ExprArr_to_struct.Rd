% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__array.R
\name{ExprArr_to_struct}
\alias{ExprArr_to_struct}
\title{Convert array to struct}
\usage{
ExprArr_to_struct(fields = NULL)
}
\arguments{
\item{fields}{If the name and number of the desired fields is known in
advance, a list of field names can be given, which will be assigned by
index. Otherwise, to dynamically assign field names, a custom R function
that takes an R double and outputs a string value can be used. If
\code{NULL} (default), fields will be \code{field_0}, \code{field_1} ... \code{field_n}.}
}
\value{
Expr
}
\description{
Convert array to struct
}
\examples{
df = pl$DataFrame(
  values = list(1:3, c(2L, NA_integer_, 5L)),
  schema = list(values = pl$Array(pl$Int32, 3))
)
df$with_columns(
  struct = pl$col("values")$arr$to_struct()
)

# pass a custom function that will name all fields by adding a prefix
df2 = df$with_columns(
  pl$col("values")$arr$to_struct(
    fields = \(idx) paste0("col_", idx)
  )
)
df2

df2$unnest()
}
