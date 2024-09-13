# The env for storing all expr bin methods
polars_expr_bin_methods <- new.env(parent = emptyenv())

namespace_expr_bin <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_bin_methods), function(name) {
    fn <- polars_expr_bin_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_namespace_expr", "polars_object")
  self
}

expr_bin_contains <- function(literal) {
  as_polars_expr(literal, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_contains() |>
    wrap()
}

expr_bin_ends_with <- function(suffix) {
  as_polars_expr(suffix, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_ends_with() |>
    wrap()
}

expr_bin_starts_with <- function(prefix) {
  as_polars_expr(prefix, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_starts_with() |>
    wrap()
}

expr_bin_decode <- function(encoding, ..., strict = TRUE) {
  wrap({
    check_string(encoding)
    check_dots_empty0(...)

    if (encoding == "hex") {
      self$`_rexpr`$bin_hex_decode(strict)
    } else if (encoding == "base64") {
      self$`_rexpr`$bin_base64_decode(strict)
    } else {
      abort(
        sprintf(
          "`encoding` must be one of ('hex', 'base64'), got '%s'",
          encoding
        )
      )
    }
  })
}

expr_bin_encode <- function(encoding) {
  wrap({
    check_string(encoding)

    if (encoding == "hex") {
      self$`_rexpr`$bin_hex_encode()
    } else if (encoding == "base64") {
      self$`_rexpr`$bin_base64_encode()
    } else {
      abort(
        sprintf(
          "`encoding` must be one of ('hex', 'base64'), got '%s'",
          encoding
        )
      )
    }
  })
}
