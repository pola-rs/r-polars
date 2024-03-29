% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datatype.R
\name{DataType_Struct}
\alias{DataType_Struct}
\title{Create Struct DataType}
\usage{
DataType_Struct(...)
}
\arguments{
\item{...}{RPolarsDataType objects}
}
\value{
a list DataType with an inner DataType
}
\description{
Struct DataType Constructor
}
\examples{
# create a Struct-DataType
pl$Struct(pl$Boolean)
pl$Struct(foo = pl$Int32, bar = pl$Float64)

# Find any DataType via pl$dtypes
print(pl$dtypes)

# check if an element is any kind of Struct()
test = pl$Struct(pl$UInt64)
pl$same_outer_dt(test, pl$Struct())

# `test` is a type of Struct, but it doesn't mean it is equal to an empty Struct
test == pl$Struct()
}
