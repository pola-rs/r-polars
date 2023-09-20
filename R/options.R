# R runtime options
## all polars sessions options saved to here

polars_optenv = new.env(parent = emptyenv())

# WRITE ALL DEFINED OPTIONS BELOW HERE

polars_optenv$strictly_immutable = TRUE
polars_optenv$no_messages = FALSE
polars_optenv$do_not_repeat_call = FALSE
polars_optenv$maintain_order = FALSE
polars_optenv$debug_polars = FALSE

## END OF DEFINED OPTIONS


#' Set polars options
#'
#' Get and set polars options. See sections "Value" and "Examples" below for
#' more details.
#'
#' @param strictly_immutable Keep polars strictly immutable. Polars/arrow is in
#' general pro "immutable objects". Immutability is also classic in R. To mimic
#' the Python-polars API, set this to `FALSE.`
#' @param maintain_order Default for all `maintain_order` options (present in
#' `$groupby()` or `$unique()` for example).
#' @param do_not_repeat_call Do not print the call causing the error in error
#' messages. The default (`FALSE`) is to show them.
#' @param debug_polars Print additional information to debug Polars.
#' @param no_messages Hide messages.
#'
#' @rdname polars_options
#' @name set_options
#'
#' @docType NULL
#'
#' @return
#' `pl$options` returns a named list with the value (`TRUE` or `FALSE`) of
#' each option.
#' `pl$set_options()` silently modifies the options values.
#' `pl$reset_options()` silently resets the options to their default values.
#'
#' @examples
#' pl$set_options(maintain_order = TRUE, strictly_immutable = FALSE)
#' pl$options
#'
#' # these options only accept booleans (TRUE or FALSE)
#' tryCatch(
#'   pl$set_options(strictly_immutable = 42),
#'   error = function(e) print(e)
#' )
#'
#' # reset options to their default value
#' pl$reset_options()

pl$set_options = function(
    strictly_immutable = TRUE,
    maintain_order = FALSE,
    do_not_repeat_call = FALSE,
    debug_polars = FALSE,
    no_messages = FALSE
  ) {

  # only modify arguments that were explicitly written in the function call
  # (otherwise calling set_options() twice in a row would reset the args
  # modified in the first call)
  args_modified = names(as.list(sys.call()[-1]))
  for (i in seq_along(args_modified)) {
    value = get(args_modified[i])
    if (length(value) > 1) {
      stop(paste0("`", args_modified[i], "` must be of length 1."))
    }
    if (!is.logical(value)) {
      stop(paste0("`", args_modified[i], "` only accepts `TRUE` or `FALSE`."))
    }
    assign(args_modified[i], value, envir = polars_optenv)
  }
}


#' @rdname polars_options
#' @name options

# NOTE: we have put 'pl$options' in an active binding so that it is updated with
# the last values of `polars_optenv` everytime it's called. The thing is that when
# we pass pl$options$maintain_order as the default argument of a function (for
# example groupby()), then it is never actually evaluated (while if we specify
# maintain_order = TRUE/FALSE explicitly when we call the function, it does get
# evaluated and hence updated).
#
# THEREFORE, we still need to use polars_optenv to set up the default options in
# function calls.

makeActiveBinding(
  "options",
  function() {
    out <- lapply(names(polars_optenv), \(name) {
      get(name, envir = polars_optenv)
    })
    names(out) = names(polars_optenv)
    out
  },
  env = pl
)

#' @rdname polars_options
#' @name reset_options

pl$reset_options = function() {
  assign("strictly_immutable", TRUE, envir = polars_optenv)
  assign("maintain_order", FALSE, envir = polars_optenv)
  assign("do_not_repeat_call", FALSE, envir = polars_optenv)
  assign("debug_polars", FALSE, envir = polars_optenv)
  assign("no_messages", FALSE, envir = polars_optenv)
}



#' internal keeping of state at runtime
#' @name polars_runtime_flags
#' @keywords internal
#' @return not applicable
#' @noRd
#' @description This environment is used internally for the package to remember
#' what has been going on. Currently only used to throw one-time warnings()
runtime_state = new.env(parent = emptyenv())


subtimer_ms = function(cap_name = NULL, cap = 9999) {
  last = runtime_state$last_subtime %||% 0
  this = as.numeric(Sys.time())
  runtime_state$last_subtime = this
  time = min((this - last) * 1000, cap)
  if (!is.null(cap_name) && time == cap) cap_name else time
}


### Other options implemented on rust side (likely due to thread safety)

#' Toggle the global string cache
#'
#' Some functions (e.g joins) can be applied on Categorical series only allowed
#' if using the global string cache is enabled. This function enables or disables
#' the string_cache and override any contexts made by `pl$with_string_cache()`.
#' In general, you should use `pl$with_string_cache()` instead.
#'
#' @name pl_enable_string_cache
#'
#' @keywords options
#' @param toggle Boolean. TRUE enable, FALSE disable.
#' @return enable_string_cache: no return
#' @seealso
#' [`pl$using_string_cache`][pl_using_string_cache]
#' [`pl$with_string_cache`][pl_with_string_cache]
#' @examples
#' pl$enable_string_cache(TRUE)
#' pl$using_string_cache()

pl$enable_string_cache = function(toggle) {
  enable_string_cache(toggle) |>
    unwrap("in pl$enable_string_cache()") |>
    invisible()
}


#' Check if the global string cache is enabled
#'
#' This function simply checks if the global string cache is active.
#'
#' @name pl_using_string_cache
#'
#' @keywords options
#' @return A boolean
#' @seealso
#' [`pl$with_string_cache`][pl_with_string_cache]
#' [`pl$enable_enable_cache`][pl_enable_string_cache]
#' @examples
#' pl$enable_string_cache(TRUE)
#' pl$using_string_cache()
#' pl$enable_string_cache(FALSE)
#' pl$using_string_cache()

pl$using_string_cache = function() {
  using_string_cache()
}


#' Evaluate one or several expressions with global string cache
#'
#' This function only temporarily enables the global string cache.
#'
#' @name pl_with_string_cache
#'
#' @keywords options
#' @return return value of expression
#' @seealso
#' [`pl$using_string_cache`][pl_using_string_cache]
#' [`pl$enable_enable_cache`][pl_enable_string_cache]
#' @examples
#' # activate string cache temporarily when constructing two DataFrame's
#' pl$with_string_cache({
#'   df1 = pl$DataFrame(head(iris, 2))
#'   df2 = pl$DataFrame(tail(iris, 2))
#' })
#' pl$concat(list(df1, df2))

pl$with_string_cache = function(expr) {
  increment_string_cache_counter(TRUE)
  on.exit(increment_string_cache_counter(FALSE))
  eval(expr, envir = parent.frame())
}




#' Get/set global R session pool capacity
#'
#' @name global_rpool_cap
#' @param n Integer, the capacity limit R sessions to process R code.
#'
#' @details
#' Background R sessions communicate via polars arrow IPC (series/vectors) or R
#' serialize + shared memory buffers via the rust crate `ipc-channel`.
#' Multi-process communication has overhead because all data must be
#' serialized/de-serialized and sent via buffers. Using multiple R sessions
#' will likely only give a speed-up in a `low io - high cpu` scenario. Native
#' polars query syntax runs in threads and have no overhead.
#'
#' @return
#' `pl$get_global_rpool_cap()` returns a list with two elements `available`
#' and `capacity`. `available` is the number of R sessions are already spawned
#' in pool. `capacity` is the limit of new R sessions to spawn. Anytime a polars
#' thread worker needs a background R session specifically to run R code embedded
#' in a query via `$map(..., in_background = TRUE)` or
#' `$apply(..., in_background = TRUE)`, it will obtain any R session idling in
#' rpool, or spawn a new R session (process) and add it to pool if `capacity`
#' is not already reached. If `capacity` is already reached, the thread worker
#' will sleep until an R session is idling.
#'
#' @keywords options
#' @examples
#' default = pl$get_global_rpool_cap()
#' print(default)
#' pl$set_global_rpool_cap(8)
#' pl$get_global_rpool_cap()
#' pl$set_global_rpool_cap(default$capacity)
pl$get_global_rpool_cap = function() {
  get_global_rpool_cap() |> unwrap()
}

#' @rdname global_rpool_cap
#' @name set_global_rpool_cap
pl$set_global_rpool_cap = function(n) {
  set_global_rpool_cap(n) |>
    unwrap() |>
    invisible()
}
