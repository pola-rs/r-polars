# R runtime options
## all polars sessions options saved to here
polars_optenv = new.env(parent = emptyenv())
polars_optreq = list() # all requirement functions put in here

# WRITE ALL DEFINED OPTIONS BELOW HERE



#' @rdname polars_options
#' @name strictly_immutable
#' @aliases strictly_immutable
#' @param strictly_immutable bool, default = TRUE, keep polars strictly immutable.
#' Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions.
#' All settable property elements of classes are mutable.
#' Why?, I guess python just do not have strong stance on immutability.
#' R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs?
#' However, if to mimic pypolars as much as possible, set this to FALSE.
#'
polars_optenv$strictly_immutable = TRUE # set default value
polars_optreq$strictly_immutable = list( # set requirement functions of default value
  is_bool = function(x) {
    is.logical(x) && length(x) == 1 && !is.na(x)
  }
)

#' @rdname polars_options
#' @name no_messages
#' @aliases no_messages
#' @details who likes polars package messages? use this option to turn them off.
#' @param no_messages bool, default = FALSE,
#' turn of messages
polars_optenv$no_messages = FALSE # set default value
polars_optreq$no_messages = list( # set requirement functions of default value
  is_bool = function(x) {
    is.logical(x) && length(x) == 1 && !is.na(x)
  }
)

#' @rdname polars_options
#' @name do_not_repeat_call
#' @details do not print the call causing the error in error messages
#' @param do_not_repeat_call bool, default = FALSE,
#' turn of messages
polars_optenv$do_not_repeat_call = FALSE # set default value
polars_optreq$do_not_repeat_call = list( # set requirement functions of default value
  is_bool = function(x) {
    is.logical(x) && length(x) == 1 && !is.na(x)
  }
)


#' @rdname polars_options
#' @name default_maintain_order
#' @details sets maintain_order = TRUE as default
#' implicated methods/functions are currently: DataFrame_GroupBy + LazyFrameGroupby.
#' @param default_maintain_orderr bool, default = FALSE
polars_optenv$default_maintain_order = FALSE # set default value
polars_optreq$default_maintain_order = list( # set requirement functions of default value
  is_bool = function(x) {
    is.logical(x) && length(x) == 1 && !is.na(x)
  }
)

#' @rdname polars_options
#' @name debug_polars
#' @details prints any call to public or private polars method
#' @param debug_polars bool, default = FALSE,
#' turn of messages
polars_optenv$debug_polars = FALSE # set default value
polars_optreq$debug_polars = list( # set requirement functions of default value
  is_bool = function(x) {
    is.logical(x) && length(x) == 1 && !is.na(x)
  }
)


## END OF DEFINED OPTIONS


#' polars options
#' @description  get, set, reset polars options
#' @rdname polars_options
#' @name get_polars_options
#' @aliases  polars_options
#'
#'
#' @return current settings as list
#' @details modifying list takes no effect, pass it to pl$set_polars_options
#' get/set/reset interact with internal env `polars:::polars_optenv`
#'
#'
#' @examples pl$get_polars_options()
pl$get_polars_options = function() {
  as.list(polars_optenv)
}

get_polars_opt = function(name) {
  if (!name %in% ls(polars_optenv)) {
    stopf("in pl$options : tried to access non option %s", name)
  }
  polars_optenv[[name]]
}

#' @details Every option can be accessed via `pl$options$<name>()` or changed
#' with `pl$options$<name>(<value>)`
#' @rdname polars_options
#' @name pl_options
#' @examples
#' # polars options read via `pl$options$<name>()`
#' pl$options$strictly_immutable()
#' pl$options$default_maintain_order()
#'
#' # write via `pl$options$<name>(<value>)`, invalided values/types are rejected
#' pl$options$default_maintain_order(TRUE)
#' tryCatch(
#'   {
#'     pl$options$default_maintain_order(42)
#'   },
#'   error = function(err) cat(as.character(err))
#' )
pl$options = lapply(names(polars_optenv), \(name) {
  \(value) {
    # Get or set option
    if (missing(value)) {
      get_polars_opt(name)
    } else {
      larg = list()
      larg[[name]] = value
      do.call(pl$set_polars_options, larg)
    }
  }
})
names(pl$options) = names(polars_optenv)
class(pl$options) = c("polars_option_list", "list")


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x string name of an option
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.DataFrame return
#' @keywords internal
.DollarNames.polars_option_list = function(x, pattern = "") {
  with(x, ls(pattern = pattern))
}
#' @export
`print.polars_option_list` = function(x, ...) {
  print("pl$options (polars_options, list-like with value validation):")
  print(pl$get_polars_options())
}

#' #' @export
#' `as.list.polars_option_list` = function(x, ...) {
#'   pl$get_polars_options()
#' }
#' #' @export
#' `as.vector.polars_option_list` = function(x, ...) {
#'   as.vector(pl$get_polars_options())
#' }




#' @param ... any options to modify
#'
#' @param return_replaced_options return previous state of modified options
#' Convenient for temporarily swapping of options during testing. The immediate
#' return value is invisible.
#'
#' @rdname polars_options
#' @name set_polars_options
#' @return current settings as list
#' @details setting an options may be rejected if not passing opt_requirements
#' @examples
#' pl$set_polars_options(strictly_immutable = FALSE)
#' pl$get_polars_options()
#'
#'
#' # setting strictly_immutable = 42 will be rejected as
#' tryCatch(
#'   pl$set_polars_options(strictly_immutable = 42),
#'   error = function(e) print(e)
#' )
#'
pl$set_polars_options = function(
    ...,
    return_replaced_options = TRUE) {
  # check opts
  opts = list2(...)
  if (is.null(names(opts)) || !all(nzchar(names(opts)))) stopf("all options passed must be named")
  unknown_opts = setdiff(names(opts), names(polars_optenv))
  if (length(unknown_opts)) {
    stopf(paste("unknown option(s) was passed:", paste(unknown_opts, collapse = ", ")))
  }

  # update options
  replaced_opts_list = list()
  for (i in names(opts)) {
    opt_requirements = polars_optreq[[i]]
    stopifnot(
      !is.null(opt_requirements),
      is.list(opt_requirements),
      all(sapply(opt_requirements, is.function)),
      all(nzchar(names(opt_requirements)))
    )

    for (j in names(opt_requirements)) {
      opt_check = opt_requirements[[j]]
      opt_value = opts[[i]]
      opt_result = opt_check(opt_value)
      if (!isTRUE(opt_result)) {
        stopf(paste(
          "option:", i, " must satisfy requirement named", j,
          "with function\n", paste(capture.output(print(opt_check)), collapse = "\n")
        ))
      }
    }

    replaced_opts_list[[i]] = polars_optenv[[i]]
    polars_optenv[[i]] = opts[[i]]
  }

  if (return_replaced_options) {
    return(invisible(replaced_opts_list))
  }

  # return current option set invisible
  invisible(pl$get_polars_options())
}



polars_opts_defaults = as.list(polars_optenv)
#' @rdname polars_options
#' @name reset_polars_options
#' @examples
#' # reset options like this
#' pl$reset_polars_options()
pl$reset_polars_options = function() {
  rm(list = ls(envir = polars_optenv), envir = polars_optenv)
  for (i in names(polars_opts_defaults)) {
    polars_optenv[[i]] = polars_opts_defaults[[i]]
  }
  invisible(NULL)
}


#' @rdname polars_options
#' @name reset_polars_options
#' @return list named by options of requirement function input must satisfy
#' @examples
#' # use get_polars_opt_requirements() to requirements
#' pl$get_polars_opt_requirements()
pl$get_polars_opt_requirements = function() {
  polars_optreq
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

#' enable disable global string cache
#' @name enable_string_cache
#' @description e.g. join to Categorical series is only allowed if using global string cache.
#' Local categorical encodings may differ and is not meaningful to combine as is.
#' @param toggle Boolean. TRUE enable
#' @return no return
#' @examples
#' pl$enable_string_cache(TRUE)
pl$enable_string_cache = function(toggle) {
  polars:::enable_string_cache(toggle) |> unwrap("in pl$enable_string_cache()")
}



#' get/set global R session pool cap
#' @name global_rpool_cap
#' @param n integer, the capacity limit R sessions to process R code.
#' @return for `pl$get_global_rpool_cap()` a list(available = ? , capacity = ?)
#' where available is how many R session already spawned in pool. Capacity is the limit of
#' how many new R sessions to spawn. Anytime a polars thread worker needs a background R session
#' specifically to run R code embedded in a query via `$map(..., in_background = TRUE)` or
#' `$apply(..., in_background = TRUE)` it will obtain any R session idling in rpool, otherwise spawn
#' a new R session (process) and add it to pool if not `capacity` has been reached. If capacity has
#' been reached already the thread worker will sleep until an R session is idling.
#'
#' Background R sessions communicate via polars arrow IPC (series/vectors) or R serialize +
#' shared memory buffers via the rust crate `ipc-channel`. Multi-process communication has overhead
#' because all data must be serialized/de-serialized and sent via buffers. Using multiple R sessions
#' will likely only give a speed-up in a `low io - high cpu` scenario. Native polars query syntax
#' runs in threads and have no overhead.
#'
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
