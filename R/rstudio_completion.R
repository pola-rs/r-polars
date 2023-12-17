
.dev = new.env(parent = emptyenv())

if(interactive()) .dev = polars:::.dev

.dev$eval_lhs_string = function(string, envir) {
  lhs = NULL
  tryCatch(
    {
      base::setTimeLimit(elapsed = 3)
      lhs = eval(parse(text = string),envir = envir)
      TRUE
    },
    error = function(e) {
      message("could no auto complete syntax because:")
      if(inherits(e, "RPolarsError")) {
        message(e$rcall(string))
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

.dev$is_polars_related_type = function(x) {
  inherits(
    x,
    c(
      "RPolarsLazyFrame", "RPolarsSeries", "RPolarsLazyGroupBy", "RPolarsDataType",
      "RPolarsExpr", "RPolarsDataFrame", "RPolarsWhen", "RPolarsThen",
      "RPolarsChainedWhen", "RPolarsChainedThen", "RPolarsSQLContext",
      "method_environment"
    )
  )
}

.dev$helpHandler = function (type = "completion", topic, source, ...) {
  #browser()
  print("hello helper")
  print(type)
  print(topic)
  if (type == "completion") {
      list(
        title = topic, signature = NULL, returns = "lots of stuff",
        description = "description", details = "details", sections = "sections"
      )
  }
  else if (type == "parameter") {
       "here to help <3 parameter"
  }
  else if (type == "url") {
      "here to help <3 url"
  }
}

activate_pl_autocomplete <- function() {
  rs = as.environment("tools:rstudio")
  local({

    .rs.getCompletionsFunction_orig <- .rs.getCompletionsFunction
    .rs.getCompletionsFunction <- function(
      token, string, functionCall, numCommas, envir = parent.frame(),
      object = .rs.resolveObjectFromFunctionCall(functionCall, envir)) {
      if(isFALSE(object)) {
        lhs = polars:::.dev$eval_lhs_string(string, envir)
        object = lhs
        string = ""
      }

      .rs.getCompletionsFunction_orig(
        token, string, functionCall, numCommas, envir = envir, object = object
      )
    }

    if(exists(".rs.getCompletionsDollar_orig",))
      stop("cannot stack multiple rules with this impl")
    .rs.getCompletionsDollar_orig <- .rs.getCompletionsDollar
    .rs.getCompletionsDollar <- function(token, string, functionCall, envir, isAt) {
      lhs = polars:::.dev$eval_lhs_string(string, envir)
      string = "lhs"
      if(TRUE ){#!  polars:::.dev$is_polars_related_type(lhs)) {
        return(.rs.getCompletionsDollar_orig(token, string, functionCall, envir=(\() parent.frame())(), isAt))
      }
      # results = gsub("\\(|\\)","",.DollarNames(lhs,token))
      # types = sapply(
      #   results,
      #   function(x) .rs.getCompletionType(eval(substitute(`$`(lhs,x), list(x=x))))
      # )
      # .rs.makeCompletions(
      #   token = token, results = results, excludeOtherCompletions = TRUE, packages = "polars",
      #   quote = FALSE, helpHandler = FALSE,
      #   context = .rs.acContextTypes$DOLLAR, suggestOnAccept ="foobar",
      #   type = types, meta = "more info",
      # )
    } # end new dollar f
  }, envir = rs) #end local
}

# # # #
# polars:::activate_pl_autocomplete()
# # # #
## # #
#library(polars)
# # # #
# # # #
#pl$col("a")$alias("blop")$li


