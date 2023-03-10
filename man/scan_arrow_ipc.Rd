% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ipc.R
\name{scan_arrow_ipc}
\alias{scan_arrow_ipc}
\title{Import data in Apache Arrow IPC format}
\usage{
scan_arrow_ipc(
  path,
  n_rows = NULL,
  cache = TRUE,
  rechunk = TRUE,
  row_count_name = NULL,
  row_count_offset = 0L,
  memmap = TRUE
)
}
\arguments{
\item{path}{string, path}

\item{n_rows}{integer, limit rows to scan}

\item{cache}{bool, use cache}

\item{rechunk}{bool, rechunk reorganize memory layout, potentially make future operations faster, however perform reallocation now.}

\item{row_count_name}{NULL or string, if a string add a rowcount column named by this string}

\item{row_count_offset}{integer, the rowcount column can be offst by this value}

\item{memmap}{bool, mapped memory}
}
\value{
LazyFrame
}
\description{
Import data in Apache Arrow IPC format
}
\details{
Create new LazyFrame from Apache Arrow IPC file or stream
}
\keyword{LazyFrame_new}
