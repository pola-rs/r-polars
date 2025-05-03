# The env storing pl$api functions
pl__api <- new.env(parent = emptyenv())

# TODO: check reserved namespaces
# TODO: check existing namespaces
#' Registering custom functionality with a polars Series
#'
#' @param name Name under which the functionality will be accessed.
#' @param ns_fn A function returns a new [environment] with the custom functionality.
#' See examples for details.
#' @return `NULL` invisibly.
#' @examples
#' # s: polars series
#' math_shortcuts <- function(s) {
#'   # Create a new environment to store the methods
#'   self <- new.env(parent = emptyenv())
#'
#'   # Store the series
#'   self$`_s` <- s
#'
#'   # Add methods
#'   self$square <- function() self$`_s` * self$`_s`
#'   self$cube <- function() self$`_s` * self$`_s` * self$`_s`
#'
#'   # Set the class
#'   class(self) <- c("polars_namespace_series", "polars_object")
#'
#'   # Return the environment
#'   self
#' }
#'
#' pl$api$register_series_namespace("math", math_shortcuts)
#'
#' s <- as_polars_series(c(1.5, 31, 42, 64.5))
#' s$math$square()$rename("s^2")
#'
#' s <- as_polars_series(1:5)
#' s$math$cube()$rename("s^3")
# nolint start: object_length_linter
pl_api_register_series_namespace <- function(name, ns_fn) {
  wrap({
    check_string(name)
    check_function(ns_fn)

    assign(name, ns_fn, envir = polars_namespaces_series)
  })
  invisible(NULL)
}
# nolint end
