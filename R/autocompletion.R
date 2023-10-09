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
#' pl$lit(42)$lit_to_s() # add a $ and press tab 1-3 times
#' pl$extra_auto_completion(activate = FALSE) # deactivate
pl$extra_auto_completion = function(activate = TRUE) {
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
      lb = CE$linebuffer

      # skip custom completion if token completion already yielded suggestions.
      if (length(CE$comps) >= 1) {
        return(NULL)
      }


      ### your custom part###
      # generate a new completion or multiple...
      last_char = substr(lb, nchar(lb), nchar(lb))
      if (last_char == "$" && nchar(lb) > 1L) {
        x = eval(parse(text = substr(lb, 1, nchar(lb) - 1)))
        if (inherits(x, c(pl_class_names, "method_environment"))) {
          your_comps = .DollarNames(x)
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
