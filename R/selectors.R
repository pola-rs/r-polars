#' Polars column selector function namespace
#'
#' `cs` is an [environment class][environment-class] object
#' that stores all selector functions of the R Polars API
#' which mimics the Python Polars API.
#' It is intended to work the same way in Python as if you had imported
#' Python Polars Selectors with `import polars.selectors as cs`.
#' @examples
#' cs
#'
#' # How many members are in the `cs` environment?
#' length(cs)
#' @export
cs <- new.env(parent = emptyenv())

# The env for storing selector methods
polars_selector__methods <- new.env(parent = emptyenv())

wrap_to_selector <- function(x, name, parameters = NULL) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`
  self$`_attrs` <- list(name = name, parameters = parameters)
  self$`_print_override` <- NULL

  lapply(names(polars_selector__methods), function(name) {
    fn <- polars_selector__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(setdiff(names(polars_expr__methods), names(self)), function(name) {
    fn <- polars_expr__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(names(polars_namespaces_expr), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_expr[[namespace]](self), self)
  })

  class(self) <- c("polars_selector", "polars_expr", "polars_object")
  self
}

selector__invert <- function() {
  inverted <- cs$all()$sub(self)
  # TODO: we want to print something like `!cs$all()` when call `!cs$all()`
  inverted$`_print_override` <- deparse1(sys.call(sys.nframe() - 1))

  inverted
}

selector__sub <- function(other) {
  if (is_polars_selector(other)) {
    wrap_to_selector(
      self$meta$`_as_selector`()$meta$`_selector_sub`(other),
      name = "sub",
      parameters = list(
        self = self,
        other = other
      )
    )
  } else {
    self$as_expr()$sub(other)
  }
}

selector__as_expr <- function() {
  self$`_rexpr` |>
    wrap()
}

cs__all <- function() {
  pl$all() |>
    wrap_to_selector("all")
}

# TODO: check dots no name
cs__by_name <- function(..., .require_all = TRUE) {
  all_names <- list2(...) |>
    unlist()

  if (!isTRUE(is.character(all_names))) {
    abort("`...` must be characters in `cs$by_name()`")
  }

  selector_params <- list(
    "*names" = all_names
  )
  match_cols <- all_names

  if (isFALSE(.require_all)) {
    match_cols <- paste0(all_names, collapse = "|") |>
      (\(x) (paste0("^(", x, ")$")))()
    selector_params$require_all <- .require_all
  }

  wrap_to_selector(
    pl$col(match_cols),
    name = "by_name",
    parameters = selector_params
  )
}
