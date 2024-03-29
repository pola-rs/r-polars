% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions__whenthen.R
\name{Expr_when_then_otherwise}
\alias{Expr_when_then_otherwise}
\alias{pl_when}
\alias{when}
\alias{then}
\alias{otherwise}
\alias{When}
\alias{Then}
\alias{ChainedWhen}
\alias{ChainedThen}
\alias{RPolarsWhen}
\alias{RPolarsThen}
\alias{RPolarsChainedWhen}
\alias{RPolarsChainedThen}
\alias{When_then}
\alias{Then_when}
\alias{Then_otherwise}
\alias{ChainedWhen_then}
\alias{ChainedThen_when}
\alias{ChainedThen_otherwise}
\title{Make a when-then-otherwise expression}
\usage{
pl_when(...)

When_then(statement)

Then_when(...)

Then_otherwise(statement)

ChainedWhen_then(statement)

ChainedThen_when(...)

ChainedThen_otherwise(statement)
}
\arguments{
\item{...}{\link[=Expr_class]{Expr} or something coercible to an Expr that returns a
boolian each row.}

\item{statement}{\link[=Expr_class]{Expr} or something coercible to
an \link[=Expr_class]{Expr} value to insert in \verb{$then()} or \verb{$otherwise()}.
A character vector is parsed as column names.}
}
\value{
\itemize{
\item \code{pl$when()} returns a \code{When} object
\item \verb{<When>$then()} returns a \code{Then} object
\item \verb{<Then>$when()} returns a \code{ChainedWhen} object
\item \verb{<ChainedWhen>$then()} returns a \code{ChainedThen} object
\item \verb{$otherwise()} returns an \link[=Expr_class]{Expr} object.
}
}
\description{
\code{when-then-otherwise} is similar to R \code{\link[=ifelse]{ifelse()}}. Always initiated by a
\verb{pl$when(<condition>)$then(<value if condition>)}, and optionally followed
by chaining one or more \verb{$when(<condition>)$then(<value if condition>)}
statements.
}
\details{
Chained when-then operations should be read like \verb{if, else if, else if, ...} in R,
not as \verb{if, if, if, ...}, i.e. the first condition that evaluates to \code{true} will
be picked.

If none of the conditions are \code{true}, an optional
\verb{$otherwise(<value if all statements are false>)} can be appended at the end.
If not appended, and none of the conditions are \code{true}, \code{null} will be returned.

\code{RPolarsThen} objects and \code{RPolarsChainedThen} objects (returned by \verb{$then()})
stores the same methods as \link[=Expr_class]{Expr}.
}
\examples{
df = pl$DataFrame(foo = c(1, 3, 4), bar = c(3, 4, 0))

# Add a column with the value 1, where column "foo" > 2 and the value -1
# where it isn’t.
df$with_columns(
  val = pl$when(pl$col("foo") > 2)$then(1)$otherwise(-1)
)

# With multiple when-then chained:
df$with_columns(
  val = pl$when(pl$col("foo") > 2)
  $then(1)
  $when(pl$col("bar") > 2)
  $then(4)
  $otherwise(-1)
)

# The `$otherwise` at the end is optional.
# If left out, any rows where none of the `$when()` expressions are evaluated to `true`,
# are set to `null`
df$with_columns(
  val = pl$when(pl$col("foo") > 2)$then(1)
)

# Pass multiple predicates, each of which must be met:
df$with_columns(
  val = pl$when(
    pl$col("bar") > 0,
    pl$col("foo") \%\% 2 != 0
  )
  $then(99)
  $otherwise(-1)
)

# In `$then()`, a character vector is parsed as column names
df$with_columns(baz = pl$when(pl$col("foo") \%\% 2 == 1)$then("bar"))

# So use `pl$lit()` to insert a string
df$with_columns(baz = pl$when(pl$col("foo") \%\% 2 == 1)$then(pl$lit("bar")))
}
