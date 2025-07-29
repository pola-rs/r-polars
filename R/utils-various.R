#' @noRd
extend_bool <- function(value, n_match, value_name, match_name) {
  check_logical(value, arg = value_name, call = caller_env())

  if (length(value) == 1L) {
    rep_len(value, n_match)
  } else if (length(value) != n_match) {
    abort(
      # TODO: error message improvement
      sprintf(
        "the length of `%s` (%d) does not match the length of `%s` (%d)",
        value_name,
        length(value),
        match_name,
        n_match
      )
    )
  } else {
    value
  }
}

# Escape a string for use in a Polars (Rust) regex.
re_escape <- function(s) {
  rust_metachars <- r"(\\?()|\[\]{}^$#&~.+*-)"
  gsub(
    sprintf("([%s])", rust_metachars),
    r"(\\\1)",
    s,
    perl = TRUE
  )
}
