

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
                     "not identical\n object:",capture_output(str(object)),
                     "\n expected:",capture_output(str(expected))),
                   ...
  )
}

