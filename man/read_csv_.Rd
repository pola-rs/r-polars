% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/csv.R
\name{read_csv_}
\alias{read_csv_}
\title{high level csv_reader, will download if path is url}
\usage{
read_csv_(path, lazy = FALSE, reuse_downloaded = TRUE, ...)
}
\arguments{
\item{path}{file or url}

\item{lazy}{bool default FALSE, read csv lazy}

\item{reuse_downloaded}{bool default TRUE, cache url downloaded files in session an reuse}

\item{...}{arguments forwarded to csv_reader or lazy_csv_reader}
}
\value{
polars_DataFrame or polars_lazy_DataFrame
}
\description{
high level csv_reader, will download if path is url
}
\examples{
df = pl$read_csv("https://j.mp/iriscsv")
}
