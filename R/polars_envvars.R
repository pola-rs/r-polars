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
#'
#' * `do_not_repeat_call` (`FALSE`): Do not print the call causing the error in
#'   error messages. The default is to show them.
#'
#' * `int64_conversion` (`"double"`): How should Int64 values be handled when
#'   converting a polars object to R?
#'
#'    * `"double"` converts the integer values to double.
#'    * `"bit64"` uses `bit64::as.integer64()` to do the conversion (requires
#'   the package `bit64` to be attached).
#'    * `"string"` converts Int64 values to character.
#'
#' * `maintain_order` (`FALSE`): Default for all `maintain_order` options
#'   (present in `$group_by()` or `$unique()` for example).
#'
#' * `no_messages` (`FALSE`): Hide messages.
#'
#' * `rpool_cap`: The maximum number of R sessions that can be used to process
#'   R code in the background. See the section "About pool options" below.
#'
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
polars_envvars = function() {
  # removed from py-polars list: POLARS_VERBOSE
  envvars = rbind(
    c("POLARS_ACTIVATE_DECIMAL", ""),
    c("POLARS_AUTO_STRUCTIFY", ""),
    c("POLARS_FMT_MAX_COLS", ""),
    c("POLARS_FMT_MAX_ROWS", ""),
    c("POLARS_FMT_NUM_DECIMAL", ""),
    c("POLARS_FMT_NUM_GROUP_SEPARATOR", ""),
    c("POLARS_FMT_NUM_LEN", ""),
    c("POLARS_FMT_STR_LEN", ""),
    c("POLARS_FMT_TABLE_CELL_ALIGNMENT", ""),
    c("POLARS_FMT_TABLE_CELL_LIST_LEN", ""),
    c("POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT", ""),
    c("POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW", ""),
    c("POLARS_FMT_TABLE_FORMATTING", "UTF8_FULL_CONDENSED"),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES", ""),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_NAMES", ""),
    c("POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR", ""),
    c("POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION", ""),
    c("POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE", ""),
    c("POLARS_FMT_TABLE_ROUNDED_CORNERS", ""),
    c("POLARS_STREAMING_CHUNK_SIZE", ""),
    c("POLARS_TABLE_WIDTH", "")
  ) |> as.data.frame()
  out = vector("list", length(envvars))
  for (i in 1:nrow(envvars)) {
    e = envvars[[1]][i]
    out[[e]] = Sys.getenv(e, unset = envvars[[2]][i])
  }
  structure(out, class = "polars_envvars")
}

#' @noRd
#' @export
print.polars_envvars = function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157
  print_key_values = function(title, vals, ...) {
    df = data.frame(vals, ...)
    names(df) = ""

    cat(title, ":\n========", sep = "")
    print(df)
    cat("\nSee `?polars::polars_envvars` for the definition of all envvars.")
  }

  print_key_values("Environment variables", unlist(x))
}
