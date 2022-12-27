# Copied from data.table by Matt Dowle et al
# from R/translation.R

catf = function(fmt, ..., sep=" ", domain="rpolars") {
  cat(gettextf(fmt, ..., domain=domain), sep=sep)
}

stopf = function(fmt, ..., domain="rpolars") {
  stop(gettextf(fmt, ..., domain=domain), domain=NA, call. = FALSE)
}
#
# warningf = function(fmt, ..., immediate.=FALSE, noBreaks.=FALSE, domain="rpolars") {
#   warning(gettextf(fmt, ..., domain=domain), domain=NA, call.=FALSE, immediate.=immediate., noBreaks.=noBreaks.)
# }
#
# messagef = function(fmt, ..., appendLF=TRUE, domain="rpolars") {
#   message(gettextf(fmt, ..., domain=domain), domain=NA, appendLF=appendLF)
# }
#
# packageStartupMessagef = function(fmt, ..., appendLF=TRUE, domain="rpolars") {
#   packageStartupMessage(gettextf(fmt, ..., domain=domain), domain=NA, appendLF=appendLF)
# }
