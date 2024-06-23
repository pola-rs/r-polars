% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_contains}
\alias{ExprStr_contains}
\title{Check if string contains a substring that matches a pattern}
\usage{
ExprStr_contains(pattern, ..., literal = FALSE, strict = TRUE)
}
\arguments{
\item{pattern}{A character or something can be coerced to a string \link[=Expr_class]{Expr}
of a valid regex pattern, compatible with the \href{https://docs.rs/regex/latest/regex/}{regex crate}.}

\item{...}{Ignored.}

\item{literal}{Logical. If \code{TRUE} (default), treat \code{pattern} as a literal string,
not as a regular expression.}

\item{strict}{Logical. If \code{TRUE} (default), raise an error if the underlying pattern is
not a valid regex, otherwise mask out with a null value.}
}
\value{
\link[=Expr_class]{Expr} of Boolean data type
}
\description{
Check if string contains a substring that matches a pattern
}
\details{
To modify regular expression behaviour (such as case-sensitivity)
with flags, use the inline \code{(?iLmsuxU)} syntax. See the regex crate’s section
on \href{https://docs.rs/regex/latest/regex/#grouping-and-flags}{grouping and flags}
for additional information about the use of inline expression modifiers.
}
\examples{
# The inline `(?i)` syntax example
pl$DataFrame(s = c("AAA", "aAa", "aaa"))$with_columns(
  default_match = pl$col("s")$str$contains("AA"),
  insensitive_match = pl$col("s")$str$contains("(?i)AA")
)

df = pl$DataFrame(txt = c("Crab", "cat and dog", "rab$bit", NA))
df$with_columns(
  regex = pl$col("txt")$str$contains("cat|bit"),
  literal = pl$col("txt")$str$contains("rab$", literal = TRUE)
)
}
\seealso{
\itemize{
\item \code{\link[=ExprStr_starts_with]{$str$start_with()}}: Check if string values
start with a substring.
\item \code{\link[=ExprStr_ends_with]{$str$ends_with()}}: Check if string values end
with a substring.
\item \code{\link[=ExprStr_find]{$str$find()}}: Return the index position of the first
substring matching a pattern.
}
}