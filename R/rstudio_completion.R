

# storing autocompletion functions in an environment,
# allows experimentaion at run-time, without rebuilding package
.dev = new.env(parent = emptyenv())

# expose .dev in interactive development
if (interactive()) .dev = polars:::.dev



# function to parse eval left-hand-side string
# timelimit: will stop eval attempt and throw error
.dev$eval_lhs_string = function(string, envir, timelimit = 3) {
  lhs = NULL
  tryCatch(
    {
      base::setTimeLimit(elapsed = timelimit)
      lhs = eval(parse(text = string), envir = envir)
      TRUE
    },
    error = function(e) {
      message("could no auto complete syntax because:")
      if (inherits(e, "RPolarsErr_error")) {
        message(polars:::result(stop(e))$err$rcall(string))
      } else if (
        inherits(e, "simpleError") &&
          identical(e$message, "reached elapsed time limit")
      ) {
        message(paste0("completion timelimit (3s) exceeded. Use only for small eager or lazy."))
      } else {
        message(e)
      }
    }
  )
  base::setTimeLimit(elapsed = Inf)
  lhs
}

# types/classes where completion behavior should change
.dev$is_polars_related_type = function(x) {
  inherits(
    x,
    c(
      "RPolarsLazyFrame", "RPolarsSeries", "RPolarsLazyGroupBy", "RPolarsDataType",
      "RPolarsExpr", "RPolarsDataFrame", "RPolarsWhen", "RPolarsThen",
      "RPolarsChainedWhen", "RPolarsChainedThen", "RPolarsSQLContext",
      "method_environment", "RPolarsGroupBy"
    )
  )
}

.dev$has_columns = function(x) {
  inherits(
    x,
    c(
      "RPolarsLazyFrame",  "RPolarsLazyGroupBy",
      "RPolarsDataFrame", "RPolarsGroupBy"
    )
  )
}

# decide if some function/method belongs to polars
.dev$is_polars_function = function(x, limit_search = 256) {
  pl_env = asNamespace("polars")
  if(!is.function(x)) return(FALSE)
  f_env = environment(x)
  for(i in seq_len(limit_search)) {
    if(identical(pl_env, f_env)) return(TRUE)
    if(identical(emptyenv(), f_env)) return(FALSE)
    f_env = parent.env(f_env)
  }
  return(FALSE)
}

# TODO this function will hopefully one day find and compile helpsection
# for any selected method
.dev$helpHandler = function(type = "completion", topic, source, ...) {

  print("hello helper")
  print(type)
  print(topic)
  if (type == "completion") {
    list(
      title = topic, signature = NULL, returns = "lots of stuff",
      description = "description", details = "details", sections = "sections"
    )
  } else if (type == "parameter") {
    "here to help <3 parameter"
  } else if (type == "url") {
    "here to help <3 url"
  }
}




#' activate_polars_rstudio_completion
#' @name activate_polars_rstudio_completion
#' @returnNULL
#'
#' @examples
#' .dev$activate_polars_rstudio_completion()
.dev$activate_polars_rstudio_completion = function() {

  #find rstudio tools
  tryCatch(
    {rs = as.environment("tools:rstudio")},
    error = function(err) stop("failed to find tools:rstudio, is this really the Rstudio IDE?")
  )

  # check if mod already has been done
  if (!is.null(rs$.rs.getCompletionsDollar_orig)) {
    stop("cannot stack multiple rules with this impl")
  }


  # do the following mod to  the Rstudio tool environment...
  local(
    envir = rs,
    {
      ## 1 - add completion to function arguments
      .rs.getCompletionsFunction_orig = .rs.getCompletionsFunction # save original function here
      .rs.getCompletionsFunction = function(
        token, string, functionCall, numCommas, envir = parent.frame(),
        object = .rs.resolveObjectFromFunctionCall(functionCall, envir)
      ) {

        # if Rstudio failed to immediately resolve the object, do a full evaluation of the entire
        # lhs line/section which creates the calling function
        col_results = NULL
        if (isFALSE(object)) {
          lhs = polars:::.dev$eval_lhs_string(string, envir)
          if(is.null(lhs)) return(.rs.emptyCompletions())
          if(polars:::.dev$is_polars_function(lhs)) {
            #browser()
            object = lhs
            object_self = environment(lhs)$self


            if(polars:::.dev$has_columns(object_self)) {
              #browser()
              col_results = .rs.makeCompletions(
                token = token,
                results =  paste0("pl$col('",object_self$columns, "')"),
                excludeOtherCompletions = FALSE,
                quote = FALSE, helpHandler = FALSE,
                context = .rs.acContextTypes$FUNCTION,
                type = .rs.acCompletionTypes$KEYWORD,
              )
            }
            string = ""
          }
        }

        # pass on to normal Rstudio completion
        results = .rs.getCompletionsFunction_orig(
          token, string, functionCall, numCommas,
          envir = envir, object = object
        )
        results$excludeOtherArgumentCompletions  = FALSE

        .rs.appendCompletions(results, col_results)
      }

      ## 2 - completion for dollar lists
      .rs.getCompletionsDollar_orig = .rs.getCompletionsDollar
      .rs.getCompletionsDollar = function(token, string, functionCall, envir, isAt) {
        #browser()
        #perform evaluation of lhs
        lhs = polars:::.dev$eval_lhs_string(string, envir)
        if(is.null(lhs)) return(.rs.emptyCompletions())
        if (!polars:::.dev$is_polars_related_type(lhs)) {
          results = .rs.getCompletionsDollar_orig(
            token, string, functionCall, envir = envir, isAt
          )
          return(results)
        }

        string =  paste(class(lhs),collapse = " ")    # show class of inferred polars object

        results = gsub("\\(|\\)", "", .DollarNames(lhs, token))
        types = sapply(
          results,
          function(x) {
             if(endsWith(x,"<-")) return(.rs.acCompletionTypes$KEYWORD)
            .rs.getCompletionType(eval(substitute(`$`(lhs, x), list(x = x))))
          }
        )
        .rs.makeCompletions(
          token = token, results = results, excludeOtherCompletions = TRUE, packages = "polars",
          quote = FALSE, helpHandler = FALSE,
          context = .rs.acContextTypes$DOLLAR,
          type = types,
        )
      } # end new dollar f
    }
  ) # end local
}

.dev$deactivate_polars_rstudio_completion = function() {
   #find rstudio tools
  tryCatch(
    {rs = as.environment("tools:rstudio")},
    error = function(err) stop("failed to find tools:rstudio, is this really the Rstudio IDE?")
  )

  if(!is.null( rs$.rs.getCompletionsFunction_orig)) {
    rs$.rs.getCompletionsFunction = rs$.rs.getCompletionsFunction_orig
    rs$.rs.getCompletionsFunction_orig = NULL
  }

  if(!is.null(rs$.rs.getCompletionsDollar_orig)) {
    rs$.rs.getCompletionsDollar = rs$.rs.getCompletionsDollar_orig
    rs$.rs.getCompletionsDollar_orig = NULL
  }

}

