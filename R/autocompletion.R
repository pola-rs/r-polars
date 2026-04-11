#' Polars code completion
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' This only works in RStudio.
#'
#' @inheritParams rlang::args_dots_empty
#' @param verbose Inform whether code completion is active or not.
#'
#' @details
#' This intercepts Rstudio internal functions `.rs.getCompletionsFunction` &
#' `.rs.getCompletionsDollar` in the loaded session environment `tools:rstudio`.
#'
#' Pressing tab will literally evaluate the left-hand-side in order to compute
#' possible suggestions. Therefore, it may be slow on large data or large queries.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # Activate completion
#'   polars_code_completion_activate()
#'
#'   # Add a "$" and press tab to see functions for LazyFrame
#'   pl$LazyFrame(x = 1)
#'
#'   # Add a "$" after pl$col("x") and press tab to see functions for expressions
#'   pl$LazyFrame(x = 1)$select(pl$col("x"))
#'
#'   # Add a "$" in count_matches() and press tab to see possible arguments
#'   pl$LazyFrame(x = 1)$select(pl$col("x")$str$count_matches())
#'
#'   # Deactivate (restarting the R session also deactivates code completion)
#'   polars_code_completion_deactivate()
#' }
polars_code_completion_activate <- function(..., verbose = TRUE) {
  check_dots_empty0(...)
  check_bool(verbose)

  if (inside_rstudio()) {
    if (verbose) {
      inform("Activated Polars code completion.")
    }
    .rs_complete$activate()
  } else {
    if (verbose) {
      inform("Polars code completion is only available in RStudio.")
    }
  }

  invisible(NULL)
}

#' @export
#' @rdname polars_code_completion_activate
polars_code_completion_deactivate <- function(..., verbose = TRUE) {
  check_dots_empty0(...)
  check_bool(verbose)

  if (inside_rstudio()) {
    if (.rs_complete$is_activated() && verbose) {
      inform("Deactivated Polars code completion.")
    }
    .rs_complete$deactivate()
  }
  # If we're not inside RStudio, then code completion couldn't be activated in
  # the first place, so there's no point showing a message when we deactivate
  # it.

  invisible(NULL)
}

# storing autocompletion functions in an environment,
# allows modification at run-time, without rebuilding package.
# This is useful as rstudio to do fast trial&error experimentation.
.rs_complete <- new.env(parent = emptyenv())

# Function to parse eval left-hand-side string. This used to set a time limit
# but it was never respected in practice. Even R.utils::withTimeout() doesn't
# work here, likely because it needs to check user interrupts. Since a lot
# of time is spent in Rust without those checks, this was effectively erroring
# on timeout only after the operation was complete, which is useless.
.rs_complete$eval_lhs_string <- function(string, envir) {
  tryCatch(
    eval(parse(text = string), envir = envir),
    error = function(e) NULL
  )
}

.rs_complete$is_polars_related_type <- function(x) {
  inherits(
    x,
    c(
      "polars_data_frame",
      "polars_lazy_frame",
      "polars_group_by",
      "polars_lazy_group_by",
      "polars_series",
      "polars_datatype",
      "polars_rolling_group_by",
      "polars_dynamic_group_by",
      "polars_expr",
      "polars_namespace_expr",
      "polars_then",
      "polars_chained_then",
      "polars_sql_context"
    )
  )
}

# decide if some function/method recursively has the polars namespace as parent
# environment.
.rs_complete$is_polars_function <- function(x) {
  is_closure(x) && env_inherits(environment(x), ns_env("polars"))
}

.rs_complete$is_activated <- function() {
  rs <- as.environment("tools:rstudio")
  !is.null(rs$.rs.getCompletionsFunction.backup.polars)
}

#' Activate_polars_rstudio_completion
#'
#' @return NULL
#' @details
#' Modifies rstudio auto-completion functions by wrapping them.
#'
#' Any other package can also wrap these or other completion functions.
#' Multiple wrappers can also co-exists, just keep the signature the same.
#'
#' @noRd
.rs_complete$activate <- function() {
  rs <- as.environment("tools:rstudio")

  # custom completion already activated
  if (!is.null(rs$.rs.getCompletionsFunction.backup.polars)) {
    return(invisible())
  }

  local(envir = rs, {
    # 1 - autocompletion for function arguments (inside call).
    # For instance, "pl$col('x')$str$count_matches(<TAB>)" should show the
    # two args of str$count_matches().

    # save original function here
    .rs.getCompletionsFunction.backup.polars <- .rs.getCompletionsFunction
    .rs.getCompletionsFunction <- function(
      token,
      string,
      functionCall,
      numCommas,
      envir = parent.frame(),
      object = .rs.resolveObjectFromFunctionCall(functionCall, envir)
    ) {
      # if Rstudio failed to immediately resolve the object, do a full
      # evaluation of the entire lhs line/section which creates the calling
      # function
      col_results <- NULL
      if (isFALSE(object)) {
        lhs <- polars:::.rs_complete$eval_lhs_string(string, envir)
        if (is.null(lhs)) {
          return(.rs.emptyCompletions())
        }
        if (polars:::.rs_complete$is_polars_function(lhs)) {
          args <- names(formals(lhs))
          args <- args[args != "..."]

          if (length(args) > 0) {
            col_results <- .rs.makeCompletions(
              token = token,
              results = paste0(args, " = "),
              excludeOtherCompletions = FALSE,
              quote = FALSE,
              helpHandler = FALSE,
              context = .rs.acContextTypes$FUNCTION,
              type = .rs.acCompletionTypes$KEYWORD
            )
          }
          string <- ""
        }
      }

      # pass on to normal Rstudio completion
      results <- .rs.getCompletionsFunction.backup.polars(
        token,
        string,
        functionCall = functionCall,
        numCommas,
        envir = envir
      )
      results$excludeOtherArgumentCompletions <- FALSE
      .rs.appendCompletions(results, col_results)
    }

    # 2 - completion for dollar lists. This is where we get completion for
    # "pl$DataFrame(x = 1)$<TAB>" or "pl$col('x')$<TAB>".
    # Two conditions to have suggestions:
    #   - there must be a "$", e.g. "pl$col('x')<TAB>" wouldn't trigger
    #   - the code before the last "$" must be valid, e.g. "pl$col('x')$cast()$<TAB>"
    #     wouldn't trigger because "pl$col('x')$cast()" throws an error.

    .rs.getCompletionsDollar.backup.polars <- .rs.getCompletionsDollar
    .rs.getCompletionsDollar <- function(token, string, functionCall, envir, isAt) {
      lhs <- polars:::.rs_complete$eval_lhs_string(string, envir)
      if (is.null(lhs)) {
        return(.rs.emptyCompletions())
      }
      if (!polars:::.rs_complete$is_polars_related_type(lhs)) {
        results <- .rs.getCompletionsDollar.backup.polars(
          token,
          string,
          functionCall,
          envir = envir,
          isAt
        )
        return(results)
      }

      string <- ""

      # get method, attribute names and drop ()
      results <- gsub("\\(|\\)", "", .DollarNames(lhs, token))
      results <- sort(results)

      # single "" means no found results, return with empty result set
      if (identical(results, "")) {
        return(.rs.emptyCompletions())
      }

      # decide if type attribute getter, or setter (<-) or regular method
      # used for icons in drop-down-list
      types <- sapply(
        results,
        function(x) {
          if (endsWith(x, "<-")) {
            return(.rs.acCompletionTypes$KEYWORD)
          }
          fallback_type <- .rs.acCompletionTypes$UNKNOWN %||%
            .rs.acCompletionTypes$VALUE %||%
            .rs.acCompletionTypes$FUNCTION

          # Those cases trigger the "Potentially expensive operation" warning
          # if evaluated on LazyFrame.
          if (x %in% c("columns", "width")) {
            return(fallback_type)
          }
          tryCatch(
            .rs.getCompletionType(eval(substitute(`$`(lhs, x), list(x = x)))),
            error = function(e) fallback_type
          )
        }
      )

      .rs.makeCompletions(
        token = token,
        results = results,
        excludeOtherCompletions = TRUE,
        packages = "polars",
        quote = FALSE,
        helpHandler = FALSE,
        context = .rs.acContextTypes$DOLLAR,
        type = types,
        meta = "",
        cacheable = FALSE
      )
    }
  })
}

.rs_complete$deactivate <- function() {
  rs <- as.environment("tools:rstudio")

  if (!is.null(rs$.rs.getCompletionsFunction.backup.polars)) {
    rs$.rs.getCompletionsFunction <- rs$.rs.getCompletionsFunction.backup.polars
    rs$.rs.getCompletionsFunction.backup.polars <- NULL
  }

  if (!is.null(rs$.rs.getCompletionsDollar.backup.polars)) {
    rs$.rs.getCompletionsDollar <- rs$.rs.getCompletionsDollar.backup.polars
    rs$.rs.getCompletionsDollar.backup.polars <- NULL
  }
}

inside_rstudio <- function() {
  identical(.Platform$GUI, "RStudio")
}
