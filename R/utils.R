

#' simulate a package
#'
#' simulate loading a namespace or attaching a package. designed to make reprexes easy. The input function's closer env is set to
#' the namespace and no fancy feature such as registering S3 methods is supported
#'
#' @source https://stackoverflow.com/a/67994010/4026830
#'
#' @param name string, name of fake package
#' @param exported named list of exported functions
#' @param unexported named list of unexported functions
#' @param attach whether to attach the fake package
#' @importFrom  namespace makeNamespace
#'
#' @noRd
fake_package <- function(name, exported = NULL, unexported = NULL, attach = TRUE) {
  # fetch and eval call to create `makeNamespace`
  #eval(body(loadNamespace)[[c(8, 4, 4)]])

  #cler old ns
  ns_registered = namespace::getRegisteredNamespace(name)
  if(!is.null(ns_registered))  rm(list=name,envir =namespace:::.getNameSpaceRegistry())

  # create an empty namespace
  ns <- namespace::makeNamespace(name)

  # makethis namespace the closure env of our input functions
  exported <- lapply(exported, `environment<-`, ns)
  unexported <- lapply(unexported, `environment<-`, ns)
  # place these in the namespace
  list2env(exported, ns)
  list2env(unexported, ns)
  # export relevant functions
  namespaceExport(ns, names(exported))
  if(attach) {
    # copy exported funs to "package:pkg" envir of the search path
    attach(exported, name = paste0("package:", name))
  }
  invisible()
}



check_no_missing_args = function(
  fun, args, warn =TRUE
) {

  expected_args = names(formals(fun))
  missing_args = expected_args[!expected_args %in% names(args)]
  if(length(missing_args)) {
    if(warn) warning(paste(
      "Internally following arguments are not exposed:",
      paste(missing_args,collapse=", ")
    ))
    return(FALSE)
  }
  return(TRUE)
}

#' more strict than expect_identical
expect_strictly_identical = function(object,expected,...) {
  testthat::expect(identical(object,expected),
                   failure_message  = paste(
                     "not identical\n object:",testthat::capture_output(str(object)),
                     "\n expected:",testthat::capture_output(str(expected))),
                   ...
  )
}

#' rust-like unwrapping of result. Useful to keep error handling on the R side.
#'
#' @param result a list here either element ok or err is NULL
#' @param class class of thrown error
#' @param call context of error
#' @param ... not used
#'
#' @return the ok-element of list , or a error will be thrown
#' @export
#'
#' @examples unwrap(list(ok="foo",err=NULL))
unwrap = function(result, class="rust result error",call=sys.call(1L),...) {

  #if not a result
  if(!is.list(result)) {
    abort("internal error: cannot unwrap non result",.internal = TRUE)
  }

  #if result is ok
  if(!is.null(result$ok) && is.null(result$err)) {
    return(result$ok)
  }

  #if result is error
  if( is.null(result$ok) && !is.null(result$err)) {
    return(abort(
      result$err,
      class = class,
      call=NULL,
      footer=paste(
        "when calling:\n",
        paste(capture.output(print(call)),collapse="\n"))
      ))
  }

  #if not ok XOR error, then roll over
  abort("internal error: result object corrupted",.internal = TRUE)
}



#' Simple match/switch handler
#'
#' @param ... odd arugments are bool statements, a next even is returned if prior bool statement is the first true
#' @param or_else return this if no bool statements were true
#'
#' @return any return given first true bool statement otherwise value of or_else
#' @export
#'
#' @examples
#' n=5
#'choose(
#'  n<5,"nope",
#'  n>6,"yeah",
#'  or_else = abort(paste("failed to have a case for n=",n))
#')
choose = function(...,or_else = NULL) {
  #get unevaluated args except header-function-name and or_else
  l = head(tail(as.list(sys.call()),-1),-1)
  #evaluate the odd args, if TRUE, evaluate and return the next even arg
  for ( i in seq_len(length(l)/2)) {
    if(isTRUE(eval(l[[i*2-1]],envir = parent.frame()))) {
      return(eval(l[[i*2]],envir = parent.frame()))
    }
  }
  or_else
}



