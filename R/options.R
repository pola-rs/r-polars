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

# polars_optenv$rpool_cap # active binding for getting value, not for
polars_optreq$rpool_cap = list() # rust-side options already check args

polars_optenv$int64_conversion = "double"
polars_optreq$int64_conversion = list(
  acceptable_choices = function(x) !is.null(x) && x %in% c("bit64", "double", "string"),
  bit64_is_attached = function(x) if (x == "bit64") x %in% .packages() else TRUE
)

## END OF DEFINED OPTIONS


#' Set polars options
#'
#' Get and set polars options. See sections "Value" and "Examples" below for
#' more details.
#'
#' `pl$options$rpool_active` indicates the number of R sessions already
#' spawned in pool. `pl$options$rpool_cap` indicates the maximum number of new R
#' sessions that can be spawned. Anytime a polars thread worker needs a background
#' R session specifically to run R code embedded in a query via
#' `$map_batches(..., in_background = TRUE)` or `$map_elements(..., in_background = TRUE)`, it
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
#' @param ... Ignored.
#' @param strictly_immutable Keep polars strictly immutable. Polars/arrow is in
#' general pro "immutable objects". Immutability is also classic in R. To mimic
#' the Python-polars API, set this to `FALSE.`
#' @param maintain_order Default for all `maintain_order` options (present in
#' `$group_by()` or `$unique()` for example).
#' @param do_not_repeat_call Do not print the call causing the error in error
#' messages. The default (`FALSE`) is to show them.
#' @param debug_polars Print additional information to debug Polars.
#' @param no_messages Hide messages.
#' @param rpool_cap The maximum number of R sessions that can be used to process
#' R code in the background. See Details.
#' @param int64_conversion  How should Int64 values be handled when converting a
#' polars object to R?
#'
#' * `"double"` (default) converts the integer values to double.
#' * `"bit64"` uses `bit64::as.integer64()` to do the conversion (requires
#'   the package `bit64` to be attached).
#' * `"string"` converts Int64 values to character.
#'
#' @rdname pl_options
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
pl_set_options = function(
    ...,
    strictly_immutable = TRUE,
    maintain_order = FALSE,
    do_not_repeat_call = FALSE,
    debug_polars = FALSE,
    no_messages = FALSE,
    rpool_cap = 4,
    int64_conversion = c("bit64", "double", "string")) {
  # only modify arguments that were explicitly written in the function call
  # (otherwise calling set_options() twice in a row would reset the args
  # modified in the first call)
  args_modified = names(as.list(sys.call()[-1]))

  if (is.null(args_modified) || any(nchar(args_modified) == 0L)) {
    Err_plain("all args must be named") |>
      unwrap("in pl$set_options")
  }

  for (i in seq_along(args_modified)) {
    value = result(get(args_modified[i])) |>
      map_err(\(rp_err) {
        rp_err$
          hint("arg-name does not match any defined args of `?set_options`")$
          bad_arg(args_modified[i])
      }) |>
      unwrap("in pl$set_options")

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
      err = .pr$Err$new()
      {
        for (fail in failures) err = err$plain(fail)
      }
      err$
        bad_robj(value)$
        bad_arg(args_modified[i]) |>
        Err() |>
        unwrap("in pl$set_options")
    }

    assign(args_modified[i], value, envir = polars_optenv) |>
      result() |>
      map_err(\(err) err$bad_arg(args_modified[i])) |>
      unwrap("in pl$set_options") |>
      invisible()
  }
}

#' @rdname pl_options
pl_reset_options = function() {
  assign("strictly_immutable", TRUE, envir = polars_optenv)
  assign("maintain_order", FALSE, envir = polars_optenv)
  assign("do_not_repeat_call", FALSE, envir = polars_optenv)
  assign("debug_polars", FALSE, envir = polars_optenv)
  assign("no_messages", FALSE, envir = polars_optenv)
  assign("rpool_cap", 4, envir = polars_optenv)
  assign("int64_conversion ", "double", envir = polars_optenv)
}


translate_failures = \(x) {
  lookups = c(
    "must_be_scalar" = "Input must be of length one.",
    "must_be_integer" = "Input must be an integer.",
    "must_be_bool" = "Input must be TRUE or FALSE.",
    "acceptable_choices" = "`int64_conversion ` must be one of \"float\", \"string\", \"bit64\".",
    "bit64_is_attached" = "Package `bit64` must be attached to use `int64_conversion = \"bit64\"`."
  )
  trans = lookups[x]
  trans[is.na(trans)] = x[is.na(trans)]
  unname(trans)
}


#' internal keeping of state at runtime
#' @name polars_runtime_flags
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

#' Enable the global string cache
#'
#' Some functions (e.g joins) can be applied on Categorical series only allowed
#' if using the global string cache is enabled. This function enables
#' the string_cache. In general, you should use `pl$with_string_cache()` instead.
#'
#' @keywords options
#' @return This doesn't return any value.
#' @seealso
#' [`pl$using_string_cache`][pl_using_string_cache]
#' [`pl$disable_string_cache`][pl_disable_string_cache]
#' [`pl$with_string_cache`][pl_with_string_cache]
#' @examples
#' pl$enable_string_cache()
#' pl$using_string_cache()
#' pl$disable_string_cache()
#' pl$using_string_cache()
pl_enable_string_cache = function() {
  enable_string_cache() |>
    unwrap("in pl$enable_string_cache()") |>
    invisible()
}


#' Disable the global string cache
#'
#' Some functions (e.g joins) can be applied on Categorical series only allowed
#' if using the global string cache is enabled. This function disables
#' the string_cache. In general, you should use `pl$with_string_cache()` instead.
#'
#' @keywords options
#' @return This doesn't return any value.
#' @seealso
#' [`pl$using_string_cache`][pl_using_string_cache]
#' [`pl$enable_string_cache`][pl_enable_string_cache]
#' [`pl$with_string_cache`][pl_with_string_cache]
#' @examples
#' pl$enable_string_cache()
#' pl$using_string_cache()
#' pl$disable_string_cache()
#' pl$using_string_cache()
pl_disable_string_cache = function() {
  disable_string_cache() |>
    unwrap("in pl$disable_string_cache()") |>
    invisible()
}



#' Check if the global string cache is enabled
#'
#' This function simply checks if the global string cache is active.
#'
#' @keywords options
#' @return A boolean
#' @seealso
#' [`pl$with_string_cache`][pl_with_string_cache]
#' [`pl$enable_enable_cache`][pl_enable_string_cache]
#' @examples
#' pl$enable_string_cache()
#' pl$using_string_cache()
#' pl$disable_string_cache()
#' pl$using_string_cache()
pl_using_string_cache = function() {
  using_string_cache()
}


#' Evaluate one or several expressions with global string cache
#'
#' This function only temporarily enables the global string cache.
#' @param expr An Expr to evaluate while the string cache is enabled.
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
pl_with_string_cache = function(expr) {
  token = .pr$StringCacheHolder$hold()
  on.exit(token$release()) # if token was not release on exit, would release later on gc()
  eval(expr, envir = parent.frame())
}



#' Get/set global R session pool capacity (DEPRECATED)
#' @description Deprecated. Use pl$options to get, and pl$set_options() to set.
#' @name global_rpool_cap
#' @param n Integer, the capacity limit R sessions to process R code.
#'
#' @details
#' Background R sessions communicate via polars arrow IPC (series/vectors) or R
#' serialize + shared memory buffers via the rust crate `ipc-channel`.
#' Multi-process communication has overhead because all data must be
#' serialized/de-serialized and sent via buffers. Using multiple R sessions
#' will likely only give a speed-up in a `low io - high cpu` scenario. Native
#' polars query syntax runs in threads and have no overhead. Polars has as default
#' double as many thread workers as cores. If any worker are queuing for or using R sessions,
#' other workers can still continue any native polars parts as much as possible.
#'
#' @return
#' `pl$options$rpool_cap` returns the capacity ("limit") of co-running external R sessions /
#' processes. `pl$options$rpool_active` is the number of R sessions are already spawned
#' in the pool. `rpool_cap` is the limit of new R sessions to spawn. Anytime a polars
#' thread worker needs a background R session specifically to run R code embedded
#' in a query via `$map(..., in_background = TRUE)` or
#' `$map_elements(..., in_background = TRUE)`, it will obtain any R session idling in
#' rpool, or spawn a new R session (process) if `capacity`
#' is not already reached. If `capacity` is already reached, the thread worker
#' will sleep and in a R job queue until an R session is idle.
#'
#' @keywords options
#' @examples
#' default = pl$options$rpool_cap |> print()
#' pl$set_options(rpool_cap = 8)
#' pl$options$rpool_cap
#' pl$set_options(rpool_cap = default)
#' pl$options$rpool_cap
pl_get_global_rpool_cap = function() {
  warning(
    "in pl$get_global_rpool_cap(): Deprecated. Use pl$options$rpool_cap instead.",
    .Call = NULL
  )
  get_global_rpool_cap() |> unwrap()
}

#' @rdname global_rpool_cap
#' @name set_global_rpool_cap
pl_set_global_rpool_cap = function(n) {
  warning(
    "in pl$get_global_rpool_cap(): Deprecated. Use pl$set_options(rpool_cap = ?) instead.",
    .Call = NULL
  )
  set_global_rpool_cap(n) |>
    unwrap() |>
    invisible()
}
