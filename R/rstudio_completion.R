# storing autocompletion functions in an environment,
# allows modification at run-time, without rebuilding package.
# This is useful as rstudio to do fast trial&error experimentation.
.rs_complete = new.env(parent = emptyenv())


# function to parse eval left-hand-side string
# timelimit: will stop eval attempt and throw error
.rs_complete$eval_lhs_string = function(string, envir, timelimit = 3) {
  lhs = NULL
  tryCatch(
    {
      setTimeLimit(elapsed = timelimit)
      lhs = eval(parse(text = string), envir = envir)
      TRUE
    },
    error = function(e) {
      message("Couldn't auto complete syntax because:")
      if (inherits(e, "RPolarsErr_error")) {
        message(result(stop(e))$err$rcall(string))
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
  setTimeLimit(elapsed = Inf)
  lhs
}

# types/classes where completion behavior should change
.rs_complete$is_polars_related_type = function(x) {
  inherits(
    x,
    c(
      "RPolarsLazyFrame", "RPolarsSeries", "RPolarsLazyGroupBy", "RPolarsDataType",
      "RPolarsRollingGroupBy", "RPolarsDynamicGroupBy",
      "RPolarsExpr", "RPolarsDataFrame", "RPolarsWhen", "RPolarsThen",
      "RPolarsChainedWhen", "RPolarsChainedThen", "RPolarsSQLContext",
      "method_environment", "RPolarsGroupBy"
    )
  )
}

# classes that have the method $columns() and implement names()
.rs_complete$has_columns = function(x) {
  inherits(
    x,
    c(
      "RPolarsLazyFrame", "RPolarsLazyGroupBy", "RPolarsRollingGroupBy",
      "RPolarsDataFrame", "RPolarsGroupBy", "RPolarsDynamicGroupBy"
    )
  )
}

# decide if some function/method recursively has the polars namespace as parent
# environment.
.rs_complete$is_polars_function = function(x, limit_search = 256) {
  pl_env = asNamespace("polars")
  if (!is.function(x)) {
    return(FALSE)
  }
  f_env = environment(x)
  for (i in seq_len(limit_search)) {
    if (identical(pl_env, f_env)) {
      return(TRUE)
    }
    if (identical(emptyenv(), f_env)) {
      return(FALSE)
    }
    f_env = parent.env(f_env)
  }
  return(FALSE)
}

# TODO this function will hopefully one day find and compile help section
# for any selected method
.rs_complete$help_handler = function(type = "completion", topic, source, ...) {
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
.rs_complete$activate = function() {
  # find rstudio tools
  rs = as.environment("tools:rstudio")

  # check if mod already has been done
  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    return(invisible())
  }

  # do the following mod to  the Rstudio tool environment...
  local(envir = rs, {
    ## 1 - add completion to function arguments
    ## save original function here
    .rs.getCompletionsFunction_polars_orig = .rs.getCompletionsFunction
    .rs.getCompletionsFunction = function(token,
                                          string,
                                          functionCall,
                                          numCommas,
                                          envir = parent.frame(),
                                          object = .rs.resolveObjectFromFunctionCall(functionCall, envir)) {
      # if Rstudio failed to immediately resolve the object, do a full
      # evaluation of the entire lhs line/section which creates the calling
      # function
      col_results = NULL
      if (isFALSE(object)) {
        lhs = .rs_complete$eval_lhs_string(string, envir)
        if (is.null(lhs)) {
          return(.rs.emptyCompletions())
        }
        if (.rs_complete$is_polars_function(lhs)) {
          object = lhs
          object_self = environment(lhs)$self

          if (.rs_complete$has_columns(object_self)) {
            col_results = .rs.makeCompletions(
              token = token,
              results = paste0("pl$col('", object_self$columns, "')"),
              excludeOtherCompletions = FALSE,
              quote = FALSE,
              helpHandler = FALSE,
              context = .rs.acContextTypes$FUNCTION,
              type = .rs.acCompletionTypes$KEYWORD,
            )
          }
          string = ""
        }
      }

      # pass on to normal Rstudio completion
      results = .rs.getCompletionsFunction_polars_orig(
        token,
        string,
        functionCall = NULL,
        numCommas,
        envir = envir
      )
      results$excludeOtherArgumentCompletions = FALSE
      .rs.appendCompletions(results, col_results)
    }

    ## 2 - completion for dollar lists
    .rs.getCompletionsFunction_polars_orig = .rs.getCompletionsDollar
    .rs.getCompletionsDollar = function(token, string, functionCall, envir, isAt) {
      # perform evaluation of lhs
      lhs = .rs_complete$eval_lhs_string(string, envir)
      if (is.null(lhs)) {
        return(.rs.emptyCompletions())
      }
      if (!.rs_complete$is_polars_related_type(lhs)) {
        results = .rs.getCompletionsFunction_polars_orig(
          token, string, functionCall,
          envir = envir, isAt
        )
        return(results)
      }

      string = ""

      # get method, attribute names and drop ()
      results = gsub("\\(|\\)", "", .DollarNames(lhs, token))

      # single "" means no found results, return with empty result set
      if (identical(results, "")) {
        return(.rs.emptyCompletions())
      }

      # decide if type attribute getter, or setter (<-) or regular method
      # used for icons in drop-down-list
      types = sapply(
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

.rs_complete$deactivate = function() {
  # find rstudio tools
  rs = as.environment("tools:rstudio")

  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    rs$.rs.getCompletionsFunction = rs$.rs.getCompletionsFunction_polars_orig
    rs$.rs.getCompletionsFunction_polars_orig = NULL
  }

  if (!is.null(rs$.rs.getCompletionsFunction_polars_orig)) {
    rs$.rs.getCompletionsDollar = rs$.rs.getCompletionsFunction_polars_orig
    rs$.rs.getCompletionsFunction_polars_orig = NULL
  }
}
