

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
pl$col("a")$alias("blop")$sum()$abs()$all()$



add_dollarRule(f)

local({
  .rs.getCompletionsDollar <- function (token, string, functionCall, envir, isAt)
{

    lhs = NULL
    tryCatch(
      {
        lhs = eval(parse(text = string),envir = envir)
        TRUE
      },
      error = function(e) {
        if(inherits(e, "RPolarsError")) {
          message("could no auto complete polars syntax because following previous error")
          print(e$rcall(string))
        }
      }
    )

    if(!is.null(lhs) && inherits(lhs,  c(
    "RPolarsLazyFrame", "RPolarsSeries", "RPolarsLazyGroupBy", "RPolarsDataType",
    "RPolarsExpr", "RPolarsDataFrame", "RPolarsWhen", "RPolarsThen",
    "RPolarsChainedWhen", "RPolarsChainedThen", "RPolarsSQLContext"
    ))) {
      #browser()
      print(str(lhs))
      context = if (isAt) .rs.acContextTypes$AT else .rs.acContextTypes$DOLLAR
      return(
      .rs.makeCompletions(
        token = token, results = .DollarNames(lhs,token), excludeOtherCompletions = TRUE,
        quote = FALSE, helpHandler = "im here to help <3", context = context,
        type = .rs.acCompletionTypes$KEYWORD
      )
      )

    }

    if (.rs.isDataTableExtractCall(string, envir = envir))
        return(.rs.emptyCompletions(excludeOtherCompletions = TRUE))
    object <- .rs.getAnywhere(string, envir)
    if (is.null(object))
        return(.rs.emptyCompletions(excludeOtherCompletions = TRUE))
    allNames <- character()
    names <- character()
    type <- numeric()
    helpHandler <- NULL
    if (isAt) {
        if (isS4(object)) {
            tryCatch({
                allNames <- .slotNames(object)
                names <- .rs.selectFuzzyMatches(allNames, token)
                if (length(names) > 200)
                  type <- .rs.acCompletionTypes$UNKNOWN
                else {
                  type <- numeric(length(names))
                  for (i in seq_along(names)) {
                    type[[i]] <- suppressWarnings(tryCatch(.rs.getCompletionType(eval(call("@",
                      quote(object), names[[i]]))), error = function(e) .rs.acCompletionTypes$UNKNOWN))
                  }
                }
            }, error = function(e) NULL)
        }
    }
    else {
        dollarNamesMethod <- .rs.getDollarNamesMethod(object,
            TRUE, envir = envir)
        if (is.function(dollarNamesMethod)) {
            allNames <- dollarNamesMethod(object, "")
            types <- ifelse(grepl("[()]\\s*$", allNames), .rs.acCompletionTypes$FUNCTION,
                .rs.acCompletionTypes$UNKNOWN)
            allNames <- gsub("[()]*\\s*$", "", allNames)
            attr(allNames, "types") <- as.integer(types)
            helpHandler <- attr(allNames, "helpHandler", exact = TRUE)
        }
        else if (inherits(object, "refObjectGenerator")) {
            allNames <- Reduce(union, list(objects(object@generator@.xData,
                all.names = TRUE), objects(object$def@refMethods,
                all.names = TRUE), c("new", "help", "methods",
                "fields", "lock", "accessors")))
        }
        else if (inherits(object, "refClass")) {
            suppressWarnings(tryCatch({
                refClassDef <- object$.refClassDef
                allNames <- c(ls(refClassDef@fieldPrototypes,
                  all.names = TRUE), ls(refClassDef@refMethods,
                  all.names = TRUE))
                baseMethods <- c("callSuper", "copy", "export",
                  "field", "getClass", "getRefClass", "import",
                  "initFields", "show", "trace", "untrace", "usingMethods")
                allNames <- c(setdiff(allNames, baseMethods),
                  baseMethods)
            }, error = function(e) NULL))
        }
        else if (isS4(object) && length(names(object))) {
            allNames <- .rs.getNames(object)
        }
        else if (is.environment(object)) {
            allNames <- .rs.getNames(object)
        }
        else {
            if (is.atomic(object))
                return(.rs.emptyCompletions(excludeOtherCompletions = TRUE))
            if (!isS4(object)) {
                allNames <- .rs.getNames(object)
            }
        }
        names <- .rs.selectFuzzyMatches(allNames, token)
        types <- attr(names, "types")
        if (is.integer(types) && length(types) == length(names))
            type <- types
        else if (inherits(object, "data.frame"))
            type <- .rs.acCompletionTypes$COLUMN
        else if (length(names) > 200)
            type <- .rs.acCompletionTypes$UNKNOWN
        else {
            type <- numeric(length(names))
            for (i in seq_along(names)) {
                type[[i]] <- suppressWarnings(tryCatch(if (is.environment(object) &&
                  bindingIsActive(names[[i]], object))
                  .rs.acCompletionTypes$UNKNOWN
                else .rs.getCompletionType(eval(call("$", quote(object),
                  names[[i]]))), error = function(e) .rs.acCompletionTypes$UNKNOWN))
            }
        }
    }
    .rs.makeCompletions(token = token, results = names, packages = string,
        quote = FALSE, type = type, excludeOtherCompletions = TRUE,
        helpHandler = helpHandler, context = if (isAt)
            .rs.acContextTypes$AT
        else .rs.acContextTypes$DOLLAR)
}



  },
rs)



