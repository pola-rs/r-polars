#' Polars code completion
#'
#' @param activate Activate or deactivate the RStudio code completion
#' @param mode One of `"auto"`, `"rstudio"`, or `"native"`. Automatic mode picks
#' `"rstudio"` if  `"tools:rstudio"` is found in `search()`. `"rstudio"` modifies
#' rstudio code internal `.DollarNames` and function args completion. `"native"`
#' registers a custom line buffer completer with
#' `utils:::rc.getOption("custom.completer")`. Rstudio IDE does not behave well
#' with `utils:::rc.getOption("custom.completer")` and therefore has its own
#' custom completion.
#'
#' @param verbose Print message of what mode is started.
#' @details
#'
#' Polars code completion has one implementation for an native terminal via
#' `utils:::rc.getOption("custom.completer")` and one for Rstudio by intercepting
#' Rstudio internal functions `.rs.getCompletionsFunction` &
#' `.rs.getCompletionsDollar` in the loaded session environment `tools:rstudio`.
#' Any blame for sluggishness or errors should be directed to r-polars.
#'
#' Either completers will evaluate the full line-buffer to decide what methods
#' are available. Pressing tab will literally evaluate left-hand-side with any
#' following side. This works swiftly for the polars lazy API. For the eager API
#' any table transformation is literally envoked. For large DataFrame and Series
#' this could be slow.
#'
#' @return NULL
#'
#' @examples
#'
#' # activate completion
#' pl$code_completion()
#'
#  # method / property completion for chained expressions
#' pl$DataFrame(iris)$lazy() # add a $ and press tab to see methods of LazyFrame
#'
#' # Arg + column-name completion. Rstudio only for now
#' pl$DataFrame(iris)$lazy()$group_by() # press tab inside group_by() to see args and/or column
#' names.
#'
#' # deactivate like this or restart R session
#' pl$code_completion(activate = FALSE)
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
      # if(!exists(".no_browse")) {
      #   browser()
      #   assign(".no_browse",value = 1,envir = .GlobalEnv)
      # }
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
