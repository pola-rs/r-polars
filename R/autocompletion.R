#' Polars code completion
#' @include rstudio_completion.R
#' @name polars_code_completion
#' @param activate bool, TRUE activates, FALSE deactivates
#' @param mode choice either. "auto" picks "rstudio" if  "tools:rstudio" is found in search().
#' "rstudio" modifies rstudio code internal .DollarNames and function args completion.
#' "nativeR" registers a custom line buffer completer with
#' `utils:::rc.getOption("custom.completer")`.
#'
#' Rstudio IDE does not behave well with `utils:::rc.getOption("custom.completer")` and therefore
#' has its own custom completion.
#'
#' @param verbose print message of what mode is started.
#' @details
#'
#' Polars code completion has one implementation for an nativeR terminal via
#' `utils:::rc.getOption("custom.completer")` and one for Rstudio by intercepting Rstudio internal
#' functions `.rs.getCompletionsFunction` & `.rs.getCompletionsDollar` in the loaded session
#' environment `tools:rstudio`. Any blame for sluggishness or errors should be directed to r-polars.
#'
#' Either completers will evaluate the full line-buffer to decide what methods are available.
#' Pressing tab will literally evaluate left-hand-side with any following side. This
#' works swiftly for the polars lazy API. For the eager API any table transformation is literally
#' envoked. For large DataFrame and Series this could be slow.#'
#'
#' @return NULL
#'
#' @examples
#'
#' # activate completion
#' pl$polars_code_completions()
#'
#  # method / property completion for chained expressions
#' pl$DataFrame(iris)$lazy() # add a $ and press tab to see methods of LazyFrame
#'
#' # Arg + column-name completion. Rstudio only for now
#' pl$DataFrame(iris)$lazy()$group_by() # press tab inside group_by() to see args and/or column
#' names.
#'
#' # deactivate like this or restart R session
#' pl$polars_code_completions(activate = FALSE)
pl$polars_code_completion = function(
    activate = TRUE,
    mode = c("auto","rstudio", "nativeR"),
    verbose = TRUE
  ) {

  # settle on mode
  mode = match.arg(mode[1],  c("auto","rstudio", "nativeR"))
  is_rstudio = "tools:rstudio" %in% search()
  if(mode == "auto") {
    if(is_rstudio) {
      mode = "rstudio"
      if(activate) {
        .dev$activate_polars_rstudio_completion()
      } else {
        .dev$deactivate_polars_rstudio_completion()
      }
    } else {
      mode = "nativeR"
      nativeR_completion(activate = activate)
    }
  }

  if(verbose && activate) message(
      "modify ",mode," code completions for better polars experience.",
      "Deactivate with pl$polars_code_completions(FALSE) or restart session.",
      "These code completions are experimental."
  )

  invisible(NULL)
}



#' Extra polars auto completion
#' @param activate bool default TRUE, enable chained auto-completion
#' @name extra_auto_completion
#' @return invisible NULL
#' @noRd
#'
#' @details polars always supports auto completion via .DollarNames.
#' However chained methods like x$a()$b()$? are not supported vi .DollarNames.
#'
#' This feature experimental and not perfect. Any feedback is appreciated.
#' Currently does not play that nice with Rstudio, as Rstudio backtick quotes any custom
#' suggestions.
#'
#' @examples
#' # auto completion via .DollarNames method
#' e = pl$lit(42) # to autocomplete pl$lit(42) save to variable
#' # then write `e$`  and press tab to see available methods
#'
#' # polars has experimental auto completion for chain of methods if all on the same line
#' pl$extra_auto_completion() # first activate feature (this will 'annoy' the Rstudio auto-completer)
#' pl$lit(42)$to_series() # add a $ and press tab 1-3 times
#' pl$extra_auto_completion(activate = FALSE) # deactivate
pl$extra_auto_completion = pl$extra_auto_completion = function(activate =TRUE) {
  warning("pl$extra_auto_completion is deprecated, use pl$polars_code_completion()")
  pl$polars_code_completions(activate = activate, mode = "nativeR")
}



nativeR_completion = function(activate = TRUE) {
  # load this function into custom.completer setting to activate
  if (!activate) {
    rc.options("custom.completer" = NULL)
  } else {
    rc.options("custom.completer" = function(x) {
      ## activating custom deactivates anything else
      # however you can run utils auto completer also like this
      # rstudio auto completion is not entirely the same as utils
      f = rc.getOption("custom.completer")
      rc.options("custom.completer" = NULL)
      # function running  base auto complete.
      # It will dump suggestion into mutable .CompletionEnv$comps
      .completeToken = utils::getFromNamespace(".completeToken", "utils")
      .completeToken()

      rc.options("custom.completer" = f)

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
      lb_wo_token = sub(paste0("\\Q",CE_frozen$token,"\\E","$"), replacement = "",lb)
      first_token_char = substr(CE_frozen$token,1L, 1L)
      # if(!exists(".no_browse")) {
      #   browser()
      #   assign(".no_browse",value = 1,envir = .GlobalEnv)
      # }
      if (first_token_char == "$" && nchar(lb_wo_token) > 1L) {

        #eval last expression prior to token
        res = result(eval(tail(parse(text = lb_wo_token), 1)))

        if(is_err(res)) {
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
          token = substr(CE_frozen$token,2,.Machine$integer.max)
          your_comps = paste0("$",.DollarNames(x, token))
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
