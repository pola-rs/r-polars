#' Create an external pointer object.
#' @param address a string of pointer address
#' @param tag an optional tag
#' @param protected an objected to be protected from gc within the lifetime of the external pointer
#' @return an \code{externalptr} object
#' @details This function is copied from the xptr-package authored by Randy Lai.
#' The package xptr has been a great tool for prototyping and some function(s) we could not
#' do without.
#' @export
new_xptr <- function(address = "", tag = NULL, protected = NULL) {
    .Call("new_xptr", address, tag, protected)
}
