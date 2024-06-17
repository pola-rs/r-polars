wrap <- function(x, ...) {
  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) {
  stop("Unimplemented class!")
}

# A function to collect functions to be assigned as methods
# Methods will be assigned to the environment inside the wrap function
assign_functions_to_env <- function(env, fn_name_pattern, ..., search_env = parent.frame()) {
  fn_names <- ls(search_env, pattern = fn_name_pattern)
  new_names <- sub(fn_name_pattern, "", fn_names)

  lapply(seq_along(fn_names), function(i) {
    fn <- get(fn_names[i], envir = search_env)
    assign(new_names[i], fn, envir = env)
  })
}
