#' Get and reset polars options
#'
#' @description `polars_options()` returns a list of options for polars. Options
#' can be set with [`options()`]. Note that **options must be prefixed with
#' "polars."**, e.g to modify the option `strictly_immutable` you need to pass
#' `options(polars.strictly_immutable =)`. See below for a description of all
#' options.
#'
#' `polars_options_reset()` brings all polars options back to their default
#' value.
#'
#' @details The following options are available (in alphabetical order, with the
#'   default value in parenthesis):
#'
#' * `debug_polars` (`FALSE`): Print additional information to debug Polars.
#' * `do_not_repeat_call` (`FALSE`): Do not print the call causing the error in
#'   error messages. The default is to show them.
#' * `int64_conversion` (`"double"`): How should Int64 values be handled when
#'   converting a polars object to R?
#'    * `"double"` converts the integer values to double.
#'    * `"bit64"` uses `bit64::as.integer64()` to do the conversion (requires
#'   the package `bit64` to be attached).
#'    * `"string"` converts Int64 values to character.
#' * `limit_max_threads` ([`!polars_info()$features$disable_limit_max_threads`][polars_info]):
#'   See [`?pl_threadpool_size`][pl_threadpool_size] for details.
#'   This option should be set before the package is loaded.
#' * `maintain_order` (`FALSE`): Default for all `maintain_order` options
#'   (present in `$group_by()` or `$unique()` for example).
#' * `no_messages` (`FALSE`): Hide messages.
#' * `rpool_cap`: The maximum number of R sessions that can be used to process
#'   R code in the background. See the section "About pool options" below.
#' * `strictly_immutable` (`TRUE`): Keep polars strictly immutable. Polars/arrow
#'   is in general pro "immutable objects". Immutability is also classic in R.
#'   To mimic the Python-polars API, set this to `FALSE.`
#'
#' @section About pool options:
#'
#'   `polars_options()$rpool_active` indicates the number of R sessions already
#'   spawned in pool. `polars_options()$rpool_cap` indicates the maximum number
#'   of new R sessions that can be spawned. Anytime a polars thread worker needs
#'   a background R session specifically to run R code embedded in a query via
#'   [`$map_batches(..., in_background = TRUE)`][Expr_map_batches] or
#'   [`$map_elements(..., in_background = TRUE)`][Expr_map_elements], it will
#'   obtain any R session idling in rpool, or spawn a new R session (process)
#'   and add it to the rpool if `rpool_cap` is not already reached. If
#'   `rpool_cap` is already reached, the thread worker will sleep until an R
#'   session is idling.
#'
#'   Background R sessions communicate via polars arrow IPC (series/vectors) or
#'   R serialize + shared memory buffers via the rust crate `ipc-channel`.
#'   Multi-process communication has overhead because all data must be
#'   serialized/de-serialized and sent via buffers. Using multiple R sessions
#'   will likely only give a speed-up in a `low io - high cpu` scenario. Native
#'   polars query syntax runs in threads and have no overhead.
#'
#' @return
#' `polars_options()` returns a named list where the names are option names and
#' values are option values.
#'
#' `polars_options_reset()` doesn't return anything.
#'
#' @export
#' @examples
#' options(polars.maintain_order = TRUE, polars.strictly_immutable = FALSE)
#' polars_options()
#'
#' # option checks are run when calling polars_options(), not when setting
#' # options
#' options(polars.maintain_order = 42, polars.int64_conversion = "foobar")
#' tryCatch(
#'   polars_options(),
#'   error = function(e) print(e)
#' )
#'
#' # reset options to their default value
#' polars_options_reset()
polars_options = function() {
  # rpool_cap is a special case because setting its value has to be done through
  # set_global_rpool_cap(). This means that we need to check that its value is
  # correct before all the others since there's no check for this on the Rust
  # side.
  rpool_cap = getOption("polars.rpool_cap")
  if (!is.null(rpool_cap)) {
    check = is_scalar_numeric(rpool_cap) && rpool_cap >= 0
    if (!check) {
      stop("Option `rpool_cap` must be a positive integer of length 1.")
    }
    set_global_rpool_cap(rpool_cap)
  }

  out = list(
    debug_polars = getOption("polars.debug_polars"),
    df_knitr_print = getOption("polars.df_knitr_print"),
    do_not_repeat_call = getOption("polars.do_not_repeat_call"),
    int64_conversion = getOption("polars.int64_conversion"),
    limit_max_threads = getOption("polars.limit_max_threads") %||%
      !cargo_rpolars_feature_info()[["disable_limit_max_threads"]],
    maintain_order = getOption("polars.maintain_order"),
    no_messages = getOption("polars.no_messages"),
    rpool_active = unwrap(get_global_rpool_cap())$active,
    rpool_cap = unwrap(get_global_rpool_cap())$capacity,
    strictly_immutable = getOption("polars.strictly_immutable")
  )
  validate_polars_options(out)
  structure(out, class = "polars_options")
}

#' @rdname polars_options
#' @export
polars_options_reset = function() {
  options(
    list(
      polars.debug_polars = FALSE,
      polars.df_knitr_print = "auto",
      polars.do_not_repeat_call = FALSE,
      polars.int64_conversion = "double",
      polars.limit_max_threads = !cargo_rpolars_feature_info()[["disable_limit_max_threads"]],
      polars.maintain_order = FALSE,
      polars.no_messages = FALSE,
      polars.rpool_active = 0,
      polars.rpool_cap = 4,
      polars.strictly_immutable = TRUE
    )
  )
}

#' @noRd
#' @export
print.polars_options = function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157
  print_key_values = function(title, vals, ...) {
    df = data.frame(vals, ...)
    names(df) = ""

    cat(title, ":\n========", sep = "")
    print(df)
    cat("\nSee `?polars_options` for the definition of all options.")
  }

  print_key_values("Options", unlist(x))
}

validate_polars_options = function(options) {
  results = list()

  ### Perform checks
  for (i in c(
    "strictly_immutable", "no_messages", "do_not_repeat_call",
    "maintain_order", "debug_polars"
  )) {
    results[[i]] = do.call(is_scalar_bool2, list(options[[i]]))
  }

  results[["int64_conversion"]] = c(
    do.call(is_acceptable_choice, list(options[["int64_conversion"]])),
    do.call(bit64_is_attached, list(options[["int64_conversion"]]))
  )

  ### Collect error messages
  errors = lapply(results, function(x) {
    if (is.character(x)) {
      setdiff(x, c("TRUE", "FALSE"))
    } else {
      return()
    }
  })
  errors = Filter(Negate(is.null), errors)

  ### Print errors (if any)
  if (length(errors) > 0) {
    msg = "Some polars options have an unexpected value:\n"
    bullets = paste0("- ", names(errors), ": ", errors, collapse = "\n")
    stop(paste0(msg, bullets, "\n\nMore info at `?polars::polars_options`."), call. = FALSE)
  }
}


### Check functions
is_scalar_bool2 = function(x) {
  res = is_scalar_bool(x)
  if (!res) {
    "input must be TRUE or FALSE."
  } else {
    TRUE
  }
}

is_acceptable_choice = function(x) {
  res = !is.null(x) && x %in% c("bit64", "double", "string")
  if (!res) {
    "input must be one of \"float\", \"string\", \"bit64\"."
  } else {
    TRUE
  }
}

bit64_is_attached = function(x) {
  res = if (!is.null(x) && x == "bit64") x %in% .packages() else TRUE
  if (!res) {
    "package `bit64` must be attached to use `int64_conversion = \"bit64\"`."
  } else {
    TRUE
  }
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
#' @description Deprecated. Use polars_options() to get, and pl$set_options() to set.
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
#' `polars_options()$rpool_cap` returns the capacity ("limit") of co-running external R sessions /
#' processes. `polars_options()$rpool_active` is the number of R sessions are already spawned
#' in the pool. `rpool_cap` is the limit of new R sessions to spawn. Anytime a polars
#' thread worker needs a background R session specifically to run R code embedded
#' in a query via [`$map_batches(..., in_background = TRUE)`][Expr_map_batches]
#' or [`$map_elements(..., in_background = TRUE)`][Expr_map_elements],
#' it will obtain any R session idling in
#' rpool, or spawn a new R session (process) if `capacity`
#' is not already reached. If `capacity` is already reached, the thread worker
#' will sleep and in a R job queue until an R session is idle.
#'
#' @keywords options
#' @examples
#' default = polars_options()$rpool_cap |> print()
#' options(polars.rpool_cap = 8)
#' polars_options()$rpool_cap
#' options(polars.rpool_cap = default)
#' polars_options()$rpool_cap
pl_get_global_rpool_cap = function() {
  warning(
    "in pl$get_global_rpool_cap(): Deprecated. Use polars_options()$rpool_cap instead.",
    .Call = NULL
  )
  get_global_rpool_cap() |> unwrap()
}

#' @rdname global_rpool_cap
#' @name set_global_rpool_cap
pl_set_global_rpool_cap = function(n) {
  warning(
    "in pl$get_global_rpool_cap(): Deprecated. Use options(polars.rpool_cap = ?) instead.",
    .Call = NULL
  )
  set_global_rpool_cap(n) |>
    unwrap() |>
    invisible()
}
