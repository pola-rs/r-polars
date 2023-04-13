# Copied from data.table by Matt Dowle et al
# from R/translation.R

catf = function(fmt, ..., sep=" ", domain="polars") {
  cat(gettextf(fmt, ..., domain=domain), sep=sep)
}

stopf = function(fmt, ..., domain="polars") {
  stop(gettextf(fmt, ..., domain=domain), domain=NA, call. = FALSE)
}
#
# warningf = function(fmt, ..., immediate.=FALSE, noBreaks.=FALSE, domain="polars") {
#   warning(gettextf(fmt, ..., domain=domain), domain=NA, call.=FALSE, immediate.=immediate., noBreaks.=noBreaks.)
# }
#
# messagef = function(fmt, ..., appendLF=TRUE, domain="polars") {
#   message(gettextf(fmt, ..., domain=domain), domain=NA, appendLF=appendLF)
# }
#
# packageStartupMessagef = function(fmt, ..., appendLF=TRUE, domain="polars") {
#   packageStartupMessage(gettextf(fmt, ..., domain=domain), domain=NA, appendLF=appendLF)
# }
