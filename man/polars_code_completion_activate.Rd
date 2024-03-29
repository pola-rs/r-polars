% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/autocompletion.R
\name{polars_code_completion_activate}
\alias{polars_code_completion_activate}
\alias{polars_code_completion_deactivate}
\title{Polars code completion}
\usage{
polars_code_completion_activate(
  mode = c("auto", "rstudio", "native"),
  verbose = TRUE
)

polars_code_completion_deactivate()
}
\arguments{
\item{mode}{One of \code{"auto"}, \code{"rstudio"}, or \code{"native"}. Automatic mode picks
\code{"rstudio"} if \code{.Platform$GUI} is \code{"RStudio"}. \code{"native"} registers a custom
line buffer completer with \code{utils:::rc.getOption("custom.completer")}.
\code{"rstudio"} modifies RStudio code internal \code{.DollarNames} and function args
completion, as the IDE does not behave well with
\code{utils:::rc.getOption("custom.completer")}.}

\item{verbose}{Print message of what mode is started.}
}
\description{
Polars code completion
}
\details{
Polars code completion has one implementation for a native terminal via
\code{utils:::rc.getOption("custom.completer")} and one for Rstudio by intercepting
Rstudio internal functions \code{.rs.getCompletionsFunction} &
\code{.rs.getCompletionsDollar} in the loaded session environment \code{tools:rstudio}.
Therefore, any error or slowness in the completion is likely to come from
r-polars implementation.

Either completers will evaluate the full line-buffer to decide what methods
are available. Pressing tab will literally evaluate left-hand-side with any
following side. This works swiftly for the polars lazy API, but it can take
some time for the eager API depending on the size of the data and of the
query.
}
\examples{
if (interactive()) {
  # activate completion
  polars_code_completion_activate()

  # method / property completion for chained expressions
  # add a $ and press tab to see methods of LazyFrame
  pl$LazyFrame(iris)

  # Arg + column-name completion
  # press tab inside group_by() to see args and/or column names.
  pl$LazyFrame(iris)$group_by()

  # deactivate like this or restart R session
  polars_code_completion_deactivate()
}
}
