% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{verify_method_call}
\alias{verify_method_call}
\title{Verify user selected method/attribute exists}
\usage{
verify_method_call(
  Class_env,
  Method_name,
  call = sys.call(1L),
  class_name = NULL
)
}
\arguments{
\item{Class_env}{env_class object (the classes created by extendr-wrappers.R)}

\item{Method_name}{name of method requested by user}

\item{call}{context to throw user error, just use default}

\item{class_name}{NULLs}
}
\value{
invisible(NULL)
}
\description{
internal function to check method call of env_classes
}
\keyword{internal}
