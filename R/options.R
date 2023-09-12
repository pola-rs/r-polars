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

#' @details Every option can be accessed via `pl$options$<name>()` or changed
#' with `pl$options$<name>(<value>)`
#' @rdname polars_options
#' @name pl_options
#' @examples
#' # polars options read via `pl$options$<name>()`
#' pl$options$strictly_immutable()
#' pl$options$maintain_order()
#'
#' # write via `pl$options$<name>(<value>)`, invalided values/types are rejected
#' pl$options$maintain_order(TRUE)
#' tryCatch(
#'   {
#'     pl$options$maintain_order(42)
#'   },
#'   error = function(err) cat(as.character(err))
#' )
pl$options = lapply(names(polars_optenv), \(name) {
  get(name, envir = polars_optenv)
})
names(pl$options) = names(polars_optenv)


#' Set polars options
#'
#' @param strictly_immutable Keep polars strictly immutable. Polars/arrow is in
#' general pro "immutable objects". Immutability is also classic in R. To mimic
#' the Python-polars API, set this to `FALSE.`
#' @param maintain_order Set `maintain_order = TRUE` as default.
#' @param do_not_repeat_call Do not print the call causing the error in error
#' messages. The default (`FALSE`) is to show them.
#' @param debug_polars Print additional information to debug Polars.
#' @param no_messages Hide messages.
#'
#' @rdname polars_options
#' @name set_options
#' @return current settings as list
#' @details setting an options may be rejected if not passing opt_requirements
#' @examples
#' pl$set_options(strictly_immutable = FALSE)
#' pl$options
#'
#'
#' # setting strictly_immutable = 42 will be rejected as
#' tryCatch(
#'   pl$set_options(strictly_immutable = 42),
#'   error = function(e) print(e)
#' )
#'
pl$set_options = function(
    strictly_immutable = TRUE,
    maintain_order = FALSE,
    do_not_repeat_call = FALSE,
    debug_polars = FALSE,
    no_messages = FALSE
  ) {

  args <- list(
    strictly_immutable = strictly_immutable,
    maintain_order = maintain_order,
    do_not_repeat_call = do_not_repeat_call,
    debug_polars = debug_polars,
    no_messages = no_messages
  )
  # only modify arguments that were explicitly written in the function call
  # (otherwise calling set_options() twice in a row would reset the args
  # modified in the first call)
  args_modified = names(as.list(sys.call()[-1]))
  for (i in seq_along(args_modified)) {
    assign(args_modified[i], args[[args_modified[i]]], envir = polars_optenv)
  }

  unlockBinding("options", env = pl)
  assign("options", as.list(polars_optenv), envir = pl)
}

pl$get_polars_options = function() {
  as.list(polars_optenv)
}

#' @rdname polars_options
#' @name reset_options
#' @examples
#' # reset options like this
#' pl$reset_options()
pl$reset_options = function() {
  assign("strictly_immutable", TRUE, envir = polars_optenv)
  assign("maintain_order", FALSE, envir = polars_optenv)
  assign("do_not_repeat_call", FALSE, envir = polars_optenv)
  assign("debug_polars", FALSE, envir = polars_optenv)
  assign("no_messages", FALSE, envir = polars_optenv)
  unlockBinding("options", env = pl)
  assign("options", as.list(polars_optenv), envir = pl)
}



#' internal keeping of state at runtime
#' @name polars_runtime_flags
#' @keywords internal
#' @return not applicable
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
