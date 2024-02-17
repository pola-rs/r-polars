#' Polars code completion
#'
#' @param activate Activate or deactivate the RStudio code completion
#' @param mode One of `"auto"`, `"rstudio"`, or `"native"`. Automatic mode picks
#' `"rstudio"` if `.Platform$GUI` is `"RStudio"`. `"native"` registers a custom
#' line buffer completer with `utils:::rc.getOption("custom.completer")`.
#' `"rstudio"` modifies RStudio code internal `.DollarNames` and function args
#' completion, as the IDE does not behave well with
#' `utils:::rc.getOption("custom.completer")`.
#' @param verbose Print message of what mode is started.
#'
#' @details
#' Polars code completion has one implementation for an native terminal via
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
#'
#' @examples
#' \dontrun{
#' # activate completion
#' pl$code_completion()
#'
#  # method / property completion for chained expressions
#  # add a $ and press tab to see methods of LazyFrame
#' pl$LazyFrame(iris)
#'
#' # Arg + column-name completion
#' # press tab inside group_by() to see args and/or column names.
#' pl$LazyFrame(iris)$group_by()
#'
#' # deactivate like this or restart R session
#' pl$code_completion(activate = FALSE)
#' }
pl_code_completion = function(
    activate = TRUE,
    mode = c("auto", "rstudio", "native"),
    verbose = TRUE) {
  mode = match.arg(mode[1], c("auto", "rstudio", "native"))
  if (mode == "auto") {
    if (is_rstudio()) {
      mode = "rstudio"
    } else {
      mode = "native"
    }
  }

  if (mode == "rstudio") {
    if (activate) {
      .rs_complete$activate()
    } else {
      .rs_complete$deactivate()
    }
  } else if (mode == "native") {
    native_completion(activate = activate)
  }

  if (verbose && activate) {
    message("Using code completion in '", mode, "' mode.")
  }

  invisible(NULL)
}


native_completion = function(activate = TRUE) {
  # load this function into custom.completer setting to activate
  if (!activate) {
    utils::rc.options("custom.completer" = NULL)
  } else {
    utils::rc.options("custom.completer" = function(x) {
      ## activating custom deactivates anything else
      # however you can run utils auto completer also like this
      # rstudio auto completion is not entirely the same as utils
      f = utils::rc.getOption("custom.completer")
      utils::rc.options("custom.completer" = NULL)

      # This is used in tests where we don't actually type anything but rather we
      # directly call utils:::.completeToken(). Therefore, the "start" element
      # (= the number of characters written when autocompletion is triggered)
      # is missing.
      .CompletionEnv = utils::getFromNamespace(".CompletionEnv", "utils")
      if (is.null(.CompletionEnv$start)) {
        .CompletionEnv$start = 0
      }

      # function running  base auto complete.
      # It will dump suggestion into mutable .CompletionEnv$comps
      .completeToken = utils::getFromNamespace(".completeToken", "utils")
      .completeToken()

      utils::rc.options("custom.completer" = f)

      # get line buffer
      .CompletionEnv = utils::getFromNamespace(".CompletionEnv", "utils")
      CE = .CompletionEnv
      CE_frozen = as.list(CE)
      lb = CE$linebuffer

      # skip custom completion if token completion already yielded suggestions.
      if (length(CE$comps) >= 1L) {
        return(NULL)
      }

      ### your custom part###
      # generate a new completion or multiple...
      lb_wo_token = sub(paste0("\\Q", CE_frozen$token, "\\E", "$"), replacement = "", lb)
      first_token_char = substr(CE_frozen$token, 1L, 1L)
      if (first_token_char == "$" && nchar(lb_wo_token) > 1L) {
        # eval last expression prior to token
        res = result(eval(tail(parse(text = lb_wo_token), 1)))

        if (is_err(res)) {
          message(
            "\nfailed to code complete because...\n",
            as.character(res$err),
            "\n"
          )
          return(NULL)
        } else {
          x = res$ok
        }
        if (inherits(x, c(pl_class_names, "method_environment", "pl_polars_env"))) {
          token = substr(CE_frozen$token, 2, .Machine$integer.max)
          your_comps = paste0("$", .DollarNames(x, token))
          # append your suggestions to the vanilla suggestions/completions
          CE$comps = c(your_comps, CE$comps)
        }
      }

      # no return used
      NULL
    })
  }

  invisible(NULL)
}
