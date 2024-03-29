% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/expr__string.R
\name{ExprStr_zfill}
\alias{ExprStr_zfill}
\alias{expr_str_zfill}
\title{Fills the string with zeroes.}
\usage{
ExprStr_zfill(alignment)
}
\arguments{
\item{alignment}{Fill the value up to this length. This can be an Expr or
something coercible to an Expr. Strings are parsed as column names.}
}
\value{
Expr
}
\description{
Add zeroes to a string until it reaches \code{n} characters. If the
number of characters is already greater than \code{n}, the string is not modified.
}
\details{
Return a copy of the string left filled with ASCII '0' digits to make a string
of length width.

A leading sign prefix ('+'/'-') is handled by inserting the padding after the
sign character rather than before. The original string is returned if width is
less than or equal to \code{len(s)}.
}
\examples{
some_floats_expr = pl$lit(c(0, 10, -5, 5))

# cast to String and ljust alignment = 5, and view as R char vector
some_floats_expr$cast(pl$String)$str$zfill(5)$to_r()

# cast to int and the to utf8 and then ljust alignment = 5, and view as R
# char vector
some_floats_expr$cast(pl$Int64)$cast(pl$String)$str$zfill(5)$to_r()
}
\keyword{ExprStr}
