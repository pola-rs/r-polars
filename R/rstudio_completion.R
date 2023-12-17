

activate_pl_autocomplete <- function(f) {
  rs = as.environment("tools:rstudio")
  local({
    if(exists(".rs.getCompletionsDollar_orig",))
      stop("cannot stack multiple rules with this impl")
    .rs.getCompletionsDollar_orig <- .rs.getCompletionsDollar
    .rs.getCompletionsDollar <- function(token, string, functionCall, envir, isAt) {
      #browser()
      lhs = NULL
      tryCatch(
        {
          lhs = eval(parse(text = string),envir = envir)
          TRUE
        },
        error = function(e) {
          message("could no auto complete polars syntax because following previous error")
          if(inherits(e, "RPolarsError")) {
            print(e$rcall(string))
          } else {
            print(e)
          }
        }
      )

      if(
        !is.null(lhs) &&
        inherits(
          lhs,
          c(
            "RPolarsLazyFrame", "RPolarsSeries", "RPolarsLazyGroupBy", "RPolarsDataType",
            "RPolarsExpr", "RPolarsDataFrame", "RPolarsWhen", "RPolarsThen",
            "RPolarsChainedWhen", "RPolarsChainedThen", "RPolarsSQLContext"
          )
        )
      ) {
        #browser()
        print(str(lhs))


        #modified from reticulate:::help_handler
        helpHandler = function (type = "completion", topic, source, ...) {
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


        #browser()
        completions = .rs.makeCompletions(
          token = token, results = gsub("\\(|\\)","",.DollarNames(lhs,token)), excludeOtherCompletions = TRUE,
          quote = FALSE, #helpHandler = l,
          context = .rs.acContextTypes$DOLLAR,
          type = .rs.acCompletionTypes$FUNCTION, meta = "more info",
        )
        return(completions)
      } else {
        .rs.getCompletionsDollar_orig(token, string, functionCall, envir, isAt)
      }
      #browser()

    } # end new dollar f
  }, envir = rs) #end local
}


activate_pl_autocomplete()


library(polars)
pl$col("a")$alias("blop")$sum()$abs()$all()$abs(

