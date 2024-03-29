% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rbackground.R
\name{RThreadHandle_join}
\alias{RThreadHandle_join}
\title{Join a RThreadHandle}
\usage{
RThreadHandle_join()
}
\value{
return value from background thread
}
\description{
Join a RThreadHandle
}
\details{
method \verb{<RThreadHandle>$join()}: will block until job is done and then return some value
or raise an error from the thread.
Calling \verb{<RThreadHandle>$join()} a second time will raise an error because handle is already
exhausted.
}
\seealso{
\link{RThreadHandle_class}
}
\keyword{RThreadHandle}
