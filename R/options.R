# R runtime options
## all polars sessions options saved to here

polars_optenv = new.env(parent = emptyenv())
polars_optreq = list()

# WRITE ALL DEFINED OPTIONS AND THEIR REQUIREMENTS
# Requirements will be used to validate inputs passed in pl$set_options()

polars_optenv$strictly_immutable = TRUE
polars_optreq$strictly_immutable = list(must_be_bool = is_bool)

polars_optenv$no_messages = FALSE
polars_optreq$no_messages = list(must_be_bool = is_bool)

polars_optenv$do_not_repeat_call = FALSE
polars_optreq$do_not_repeat_call = list(must_be_bool = is_bool)

polars_optenv$maintain_order = FALSE
polars_optreq$maintain_order = list(must_be_bool = is_bool)

polars_optenv$debug_polars = FALSE
polars_optreq$debug_polars = list(must_be_bool = is_bool)

# rpool_avail, rpool_cap, and rpool_cap_max are updated with their real values
# in .onLoad() because we can't run `unwrap()` while the package is loading.
#
# rpool_avail and rpool_cap_max are only informative, they can't be changed by
# the user so they don't have any requirements

polars_optreq$rpool_cap = list(
  must_be_scalar = \(x) length(x) == 1,
  # allow 2 instead of 2L, but doesn't allow 2.5
  must_be_integer = \(x) {
    all(!is.na(x) & is.numeric(x) & x == round(x))
  },
  must_be_smaller_than_max = \(x) {
    max_cap = polars_optenv$rpool_cap_max
    all(x <= max_cap)
  }
)


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
#' @param rpool_cap The maximum number of R sessions that can be used to process
#' R code in the background. See Details.
#'
#' @rdname polars_options
#' @name set_options
#'
#' @docType NULL
#'
#' @details
#' `pl$options$rpool_avail` indicates the number of R sessions are already
#' spawned in pool. `pl$options$rpool_cap` indicates the maximum number of new R
#' sessions that can be spawned. Anytime a polars thread worker needs a background
#' R session specifically to run R code embedded in a query via
#' `$map(..., in_background = TRUE)` or `$apply(..., in_background = TRUE)`, it
#' will obtain any R session idling in rpool, or spawn a new R session (process)
#' and add it to the rpool if `rpool_cap` is not already reached. If `rpool_cap`
#' is already reached, the thread worker will sleep until an R session is idling.
#'
#' Background R sessions communicate via polars arrow IPC (series/vectors) or R
#' serialize + shared memory buffers via the rust crate `ipc-channel`.
#' Multi-process communication has overhead because all data must be
#' serialized/de-serialized and sent via buffers. Using multiple R sessions
#' will likely only give a speed-up in a `low io - high cpu` scenario. Native
#' polars query syntax runs in threads and have no overhead.
#'
#' @return
#' `pl$options` returns a named list with the value (`TRUE` or `FALSE`) of
#' each option.
#'
#' `pl$set_options()` silently modifies the options values.
#'
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
    no_messages = FALSE,
    rpool_cap = NULL) {
  # only modify arguments that were explicitly written in the function call
  # (otherwise calling set_options() twice in a row would reset the args
  # modified in the first call)
  args_modified = names(as.list(sys.call()[-1]))

  for (i in seq_along(args_modified)) {
    value = get(args_modified[i])

    # each argument has its own input requirements
    validation = c()
    for (fun in seq_along(polars_optreq[[args_modified[i]]])) {
      validation[fun] = do.call(
        polars_optreq[[args_modified[i]]][[fun]],
        list(value)
      )
    }
    names(validation) = names(polars_optreq[[args_modified[i]]])
    if (!all(validation)) {
      failures = names(which(!validation))
      failures = translate_failures(failures)
      stop(
        paste0(
          "Incorrect input for argument `", args_modified[i], "`. Failures:\n",
          paste("    *", failures, "\n", collapse = "")
        )
      )
    }

    assign(args_modified[i], value, envir = polars_optenv)

    if (args_modified[i] == "rpool_cap") {
      set_global_rpool_cap(value) |>
        unwrap() |>
        invisible()
    }
  }
}

#' @rdname polars_options
#' @name reset_options

pl$reset_options = function() {
  assign("strictly_immutable", TRUE, envir = polars_optenv)
  assign("maintain_order", FALSE, envir = polars_optenv)
  assign("do_not_repeat_call", FALSE, envir = polars_optenv)
  assign("debug_polars", FALSE, envir = polars_optenv)
  assign("no_messages", FALSE, envir = polars_optenv)
  assign("rpool_cap", polars_optenv$rpool_cap_max, envir = polars_optenv)
}


translate_failures = \(x) {
  lookups = c(
    "must_be_scalar" = "Input must be of length one.",
    "must_be_integer" = "Input must be an integer.",
    "must_be_smaller_than_max" = paste0(
      "Input must be smaller than the maximum capacity. Use \n",
      "`pl$options$rpool_cap_max` to know the maximum capacity."
    ),
    "must_be_bool" = "Input must be TRUE or FALSE"
  )
  trans = lookups[x]
  trans[is.na(trans)] = x[is.na(trans)]
  unname(trans)
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
