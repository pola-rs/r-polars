% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datatype.R
\name{DataType_is_enum}
\alias{DataType_is_enum}
\title{Check whether the data type is an Enum type}
\usage{
DataType_is_enum()
}
\value{
A logical value
}
\description{
Check whether the data type is an Enum type
}
\examples{
pl$Enum(c("a", "b"))$is_enum()
pl$Categorical()$is_enum()
}
