# Internal bookkeeping of the autocompletion mode ("rstudio" or "native")
.polars_autocompletion <- new.env(parent = emptyenv())

#' Polars code completion
#'
#' @param mode One of `"auto"`, `"rstudio"`, or `"native"`. Automatic mode picks
#' `"rstudio"` if `.Platform$GUI` is `"RStudio"`. `"native"` registers a custom
#' line buffer completer with `utils:::rc.getOption("custom.completer")`.
#' `"rstudio"` modifies RStudio code internal `.DollarNames` and function args
#' completion, as the IDE does not behave well with
#' `utils:::rc.getOption("custom.completer")`.
#' @param verbose Print message of what mode is started.
#'
#' @details
#' Polars code completion has one implementation for a native terminal via
#' `utils:::rc.getOption("custom.completer")` and one for Rstudio by intercepting
#' Rstudio internal functions `.rs.getCompletionsFunction` &
#' `.rs.getCompletionsDollar` in the loaded session environment `tools:rstudio`.
#' Therefore, any error or slowness in the completion is likely to come from
#' r-polars implementation.
#'
#' Either completers will evaluate the full line-buffer to decide what methods
#' are available. Pressing tab will literally evaluate left-hand-side with any
#' following side. This works swiftly for the polars lazy API, but it can take
#' some time for the eager API depending on the size of the data and of the
#' query.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # activate completion
#'   polars_code_completion_activate()
#'
#'   # method / property completion for chained expressions
#'   # add a $ and press tab to see methods of LazyFrame
#'   pl$LazyFrame(iris)
#'
#'   # Arg + column-name completion
#'   # press tab inside group_by() to see args and/or column names.
#'   pl$LazyFrame(iris)$group_by()
#'
#'   # deactivate like this or restart R session
#'   polars_code_completion_deactivate()
#' }
polars_code_completion_activate <- function(
  mode = c("auto", "rstudio", "native"),
  verbose = TRUE
) {
  mode <- match.arg(mode[1], c("auto", "rstudio", "native"))
  if (mode == "auto") {
    if (is_rstudio()) {
      mode <- "rstudio"
    } else {
      mode <- "native"
    }
  }

  .polars_autocompletion$mode <- mode

  if (mode == "rstudio") {
    .rs_complete$activate()
  } else if (mode == "native") {
    native_completion(activate = TRUE)
  }

  if (verbose) {
    message("Using code completion in '", mode, "' mode.")
  }

  invisible(NULL)
}

#' @export
#' @rdname polars_code_completion_activate
polars_code_completion_deactivate <- function() {
  mode <- .polars_autocompletion$mode
  if (is.null(mode)) {
    message("Autocompletion wasn't already enabled")
  }

  if (mode == "rstudio") {
    .rs_complete$deactivate()
  } else if (mode == "native") {
    native_completion(activate = FALSE)
  }

  .polars_autocompletion$mode <- NULL

  invisible(NULL)
}


native_completion <- function(activate = TRUE) {
  # load this function into custom.completer setting to activate
  if (!activate) {
    utils::rc.options("custom.completer" = NULL)
  } else {
    utils::rc.options("custom.completer" = function(x) {
      ## activating custom deactivates anything else
      # however you can run utils auto completer also like this
      # rstudio auto completion is not entirely the same as utils
      f <- utils::rc.getOption("custom.completer")
      utils::rc.options("custom.completer" = NULL)

      # This is used in tests where we don't actually type anything but rather we
      # directly call utils:::.completeToken(). Therefore, the "start" element
      # (= the number of characters written when autocompletion is triggered)
      # is missing.
      .CompletionEnv <- utils::getFromNamespace(".CompletionEnv", "utils")
      if (is.null(.CompletionEnv$start)) {
        .CompletionEnv$start <- 0
      }

      # function running  base auto complete.
      # It will dump suggestion into mutable .CompletionEnv$comps
      .completeToken <- utils::getFromNamespace(".completeToken", "utils")
      .completeToken()

      utils::rc.options("custom.completer" = f)

      # get line buffer
      .CompletionEnv <- utils::getFromNamespace(".CompletionEnv", "utils")
      CE <- .CompletionEnv
      CE_frozen <- as.list(CE)
      lb <- CE$linebuffer

      # skip custom completion if token completion already yielded suggestions.
      CE$comps <- CE$comps[
        !CE$comps %in%
          paste0("$", c("arr", "bin", "cat", "dt", "list", "meta", "name", "str", "struct"), "$")
      ]
      if (length(CE$comps) >= 1L) {
        return(NULL)
      }

      ### your custom part###
      # generate a new completion or multiple...
      lb_wo_token <- sub("\\$$", "", lb)
      first_token_char <- substr(CE_frozen$token, 1L, 1L)
      if (first_token_char == "$" && nchar(lb_wo_token) > 1L) {
        # eval last expression prior to token
        res <- try(eval(tail(parse(text = lb_wo_token), 1)), silent = TRUE)

        if (inherits(res, "try-error")) {
          message(
            "\nfailed to code complete because...\n",
            as.character(res$err),
            "\n"
          )
          return(NULL)
        }

        if (
          inherits(
            res,
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
        ) {
          token <- substr(CE_frozen$token, 2, .Machine$integer.max)
          if (
            token %in%
              paste0(c("arr", "bin", "cat", "dt", "list", "meta", "name", "str", "struct"), "$")
          ) {
            your_comps <- paste0("$", token, .DollarNames(res, ""))
          } else {
            your_comps <- paste0("$", .DollarNames(res, token))
          }

          your_comps <- sort(your_comps)

          # append your suggestions to the vanilla suggestions/completions
          CE$comps <- c(your_comps, CE$comps)
        }
      }

      # no return used
      NULL
    })
  }

  invisible(NULL)
}


### RStudio completion

# storing autocompletion functions in an environment,
# allows modification at run-time, without rebuilding package.
# This is useful as rstudio to do fast trial&error experimentation.
.rs_complete <- new.env(parent = emptyenv())


# function to parse eval left-hand-side string
# timelimit: will stop eval attempt and throw error
.rs_complete$eval_lhs_string <- function(string, envir, timelimit = 3) {
  lhs <- NULL
  tryCatch(
    {
      setTimeLimit(elapsed = timelimit)
      lhs <- eval(parse(text = string), envir = envir)
      TRUE
    },
    error = function(e) {
      message("Couldn't auto complete syntax because:")
      # if (inherits(e, "RPolarsErr_error")) {
      #   message(result(stop(e))$err$rcall(string))
      # } else if (
      #   inherits(e, "simpleError") &&
      #     identical(e$message, "reached elapsed time limit")
      # ) {
      #   message(paste0("completion timelimit (3s) exceeded. Use only for small eager or lazy."))
      # } else {
      message(e)
      # }
    }
  )
  setTimeLimit(elapsed = Inf)
  lhs
}

# types/classes where completion behavior should change
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

# classes that have the method $columns() and implement names()
.rs_complete$has_columns <- function(x) {
  inherits(
    x,
    c(
      "polars_data_frame",
      "polars_lazy_frame",
      "polars_group_by",
      "polars_lazy_group_by",
      "polars_rolling_group_by",
      "polars_dynamic_group_by"
    )
  )
}

# decide if some function/method recursively has the polars namespace as parent
# environment.
.rs_complete$is_polars_function <- function(x, limit_search = 256) {
  pl_env <- asNamespace("polars")
  if (!is.function(x)) {
    return(FALSE)
  }
  f_env <- environment(x)
  for (i in seq_len(limit_search)) {
    if (identical(pl_env, f_env)) {
      return(TRUE)
    }
    if (identical(emptyenv(), f_env)) {
      return(FALSE)
    }
    f_env <- parent.env(f_env)
  }
  return(FALSE)
}

# TODO this function will hopefully one day find and compile help section
# for any selected method
.rs_complete$help_handler <- function(type = "completion", topic, source, ...) {
  print("hello helper")
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
  # find rstudio tools
  rs <- as.environment("tools:rstudio")

  # custom completion already activated
  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    return(invisible())
  }

  # do the following mod to the Rstudio tool environment...
  local(envir = rs, {
    ## 1 - add completion to function arguments
    ## save original function here
    .rs.getCompletionsFunction_polars_orig <- .rs.getCompletionsFunction
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
          object <- lhs
          object_self <- environment(lhs)$self
          args <- names(formals(object))
          args <- args[args != "..."]

          if (polars:::.rs_complete$has_columns(object_self)) {
            res <- if (length(args) > 0) {
              c(
                paste0(args, " = "),
                paste0("pl$col('", object_self$columns, "')")
              )
            } else {
              paste0("pl$col('", object_self$columns, "')")
            }
            col_results <- .rs.makeCompletions(
              token = token,
              results = res,
              excludeOtherCompletions = FALSE,
              quote = FALSE,
              helpHandler = FALSE,
              context = .rs.acContextTypes$FUNCTION,
              type = .rs.acCompletionTypes$KEYWORD,
            )
          } else if (length(args) > 0) {
            col_results <- .rs.makeCompletions(
              token = token,
              results = paste0(args, " = "),
              excludeOtherCompletions = FALSE,
              quote = FALSE,
              helpHandler = FALSE,
              context = .rs.acContextTypes$FUNCTION,
              type = .rs.acCompletionTypes$KEYWORD,
            )
          }
          string <- ""
        }
      }

      # pass on to normal Rstudio completion
      results <- .rs.getCompletionsFunction_polars_orig(
        token,
        string,
        functionCall = NULL,
        numCommas,
        envir = envir
      )
      results$excludeOtherArgumentCompletions <- FALSE
      .rs.appendCompletions(results, col_results)
    }

    ## 2 - completion for dollar lists
    .rs.getCompletionsFunction_polars_orig <- .rs.getCompletionsDollar
    .rs.getCompletionsDollar <- function(token, string, functionCall, envir, isAt) {
      # perform evaluation of lhs
      lhs <- polars:::.rs_complete$eval_lhs_string(string, envir)
      if (is.null(lhs)) {
        return(.rs.emptyCompletions())
      }
      if (!polars:::.rs_complete$is_polars_related_type(lhs)) {
        results <- .rs.getCompletionsFunction_polars_orig(
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
          .rs.getCompletionType(eval(substitute(`$`(lhs, x), list(x = x))))
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
    } # end new dollar f
  }) # end local
}

.rs_complete$deactivate <- function() {
  # find rstudio tools
  rs <- as.environment("tools:rstudio")

  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    rs$.rs.getCompletionsFunction <- rs$.rs.getCompletionsFunction_polars_orig
    rs$.rs.getCompletionsFunction_polars_orig <- NULL
  }

  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    rs$.rs.getCompletionsDollar <- rs$.rs.getCompletionsFunction_polars_orig
    rs$.rs.getCompletionsFunction_polars_orig <- NULL
  }
}

is_rstudio <- function() {
  identical(.Platform$GUI, "RStudio")
}
