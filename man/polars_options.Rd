% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polars_options.R
\name{polars_options}
\alias{polars_options}
\alias{polars_options_reset}
\title{Get and reset polars options}
\usage{
polars_options()

polars_options_reset()
}
\value{
\code{polars_options()} returns a named list where the names are option names and
values are option values.

\code{polars_options_reset()} doesn't return anything.
}
\description{
\code{polars_options()} returns a list of options for polars. Options
can be set with \code{\link[=options]{options()}}. Note that \strong{options must be prefixed with
"polars."}, e.g to modify the option \code{strictly_immutable} you need to pass
\code{options(polars.strictly_immutable =)}. See below for a description of all
options.

\code{polars_options_reset()} brings all polars options back to their default
value.
}
\details{
The following options are available (in alphabetical order, with the
default value in parenthesis):
\itemize{
\item \code{debug_polars} (\code{FALSE}): Print additional information to debug Polars.
\item \code{do_not_repeat_call} (\code{FALSE}): Do not print the call causing the error in
error messages. The default is to show them.
\item \code{int64_conversion} (\code{"double"}): How should Int64 values be handled when
converting a polars object to R?
\itemize{
\item \code{"double"} converts the integer values to double.
\item \code{"bit64"} uses \code{bit64::as.integer64()} to do the conversion (requires
the package \code{bit64} to be attached).
\item \code{"string"} converts Int64 values to character.
}
\item \code{limit_max_threads} (\code{\link[=polars_info]{!polars_info()$features$disable_limit_max_threads}}):
See \code{\link[=pl_thread_pool_size]{?pl_thread_pool_size}} for details.
This option should be set before the package is loaded.
\item \code{maintain_order} (\code{FALSE}): Default for the \code{maintain_order} argument in
\code{\link[=LazyFrame_group_by]{<LazyFrame>$group_by()}} and
\code{\link[=DataFrame_group_by]{<DataFrame>$group_by()}}.
\item \code{no_messages} (\code{FALSE}): Hide messages.
\item \code{rpool_cap}: The maximum number of R sessions that can be used to process
R code in the background. See the section "About pool options" below.
\item \code{strictly_immutable} (\code{TRUE}): Keep polars strictly immutable. Polars/arrow
is in general pro "immutable objects". Immutability is also classic in R.
To mimic the Python-polars API, set this to \code{FALSE.}
}
}
\section{About pool options}{


\code{polars_options()$rpool_active} indicates the number of R sessions already
spawned in pool. \code{polars_options()$rpool_cap} indicates the maximum number
of new R sessions that can be spawned. Anytime a polars thread worker needs
a background R session specifically to run R code embedded in a query via
\code{\link[=Expr_map_batches]{$map_batches(..., in_background = TRUE)}} or
\code{\link[=Expr_map_elements]{$map_elements(..., in_background = TRUE)}}, it will
obtain any R session idling in rpool, or spawn a new R session (process)
and add it to the rpool if \code{rpool_cap} is not already reached. If
\code{rpool_cap} is already reached, the thread worker will sleep until an R
session is idling.

Background R sessions communicate via polars arrow IPC (series/vectors) or
R serialize + shared memory buffers via the rust crate \code{ipc-channel}.
Multi-process communication has overhead because all data must be
serialized/de-serialized and sent via buffers. Using multiple R sessions
will likely only give a speed-up in a \verb{low io - high cpu} scenario. Native
polars query syntax runs in threads and have no overhead.
}

\examples{
options(polars.maintain_order = TRUE, polars.strictly_immutable = FALSE)
polars_options()

# option checks are run when calling polars_options(), not when setting
# options
options(polars.maintain_order = 42, polars.int64_conversion = "foobar")
tryCatch(
  polars_options(),
  error = function(e) print(e)
)

# reset options to their default value
polars_options_reset()
}
