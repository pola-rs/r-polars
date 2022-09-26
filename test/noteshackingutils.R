#NOTES FOR HACKING AUTOCOMPLETION

unlockBinding(".DollarNames",env=environment(utils:::.DollarNames))


local({
  .DollarNames = function (x, pattern) {
    print("sup")
    UseMethod(".DollarNames")
  }
  },envir=environment(utils:::.DollarNames)
)



unlockBinding("parse_usage",env=environment(pkgdown:::parse_usage))

local(
  {parse_usage = function (x) {

    #print("nope")

    y = usage_code(x)
    print(y)
    if(length(y)==0) return(list())
    list(
      list(
        type = "data",
        name = y
      )
    )
    list(list())
  }},
  envir=environment(pkgdown:::parse_usage)
)






utils:::.DollarNames

x = utils:::.completeToken
unlockBinding(".completeToken",env=environment(utils:::.DollarNames))
local({.completeToken <- get("comtok",.GlobalEnv)},parent.env(utils:::.CompletionEnv))
rc.settings(func = TRUE)
source("./R/comtok.R")

rc.options("custom.completer" = NULL)
rc.options("custom.completer" = function(x) {
  print("start")

  ##run base auto completer
  f = rc.getOption("custom.completer")
  rc.options("custom.completer" = NULL)
  utils:::.completeToken()
  rc.options("custom.completer" = f)




  .CompletionEnv = utils:::.CompletionEnv

  if(!length(.CompletionEnv$comps)) {
    #browser()
    #try more ...
    text = .CompletionEnv$linebuffer
    text2 =substr(.CompletionEnv$linebuffer,1,.CompletionEnv$start)

    cat("text: ",text," - ",text2,"\n")


    ops  = utils:::specialOpLocs(text)
    print(ops)
    comps = utils:::specialOpCompletionsHelper(names(ops),"",text2)
    if (length(comps) == 0L) comps <- ""
    comps = paste0("$",comps)
    str(comps)
    .CompletionEnv$comps= comps

    rc.options("custom.completer" = NULL)

  }



  rcs2 <<- rc.status()


  print("done")
  NULL
})
rcstat
library(minipolars)
s = pl$Series(1:4)

rcs2 = rc.status()
identical(rcs$comps, rcs2$comps)

all_equal(rcs1,rcs)
x1 = rcstat
x2 = rcstat


all.equal(x1,x2)

#   tryToEval <- function(s) {
#     tryCatch(eval(str2expression(s), envir = .GlobalEnv),
#              error = function(e) e)
#   }
#
#
#   object = tryToEval("s$abs()")
#
#   .utils:::dollarNames(object, pattern = sprintf("^%s",
#                                          makeRegexpSafe(suffix)))
#
# s$abs()$
#
# `rc.options`
#
# rc.options(costum.completer =NULL)
#
#
#
# rc.status()
#
# s
# utils:::specialOpCompletionsHelper("$","s","abs")


#load this function into custom.completer setting to activate
rc.options("custom.completer" = function(x) {

  #perhaps debug it, it will kill your rsession sometimes
  #browser()

  ###default completion###

  ##activating custom deactivates anything else
  #however you can run utils auto completer also like this
  #rstudio auto completation is not entirely the same as utils
  f = rc.getOption("custom.completer")
  rc.options("custom.completer" = NULL)
  #function running  base auto complete.
  #It will dump suggestion into mutable .CompletionEnv$comps
  utils:::.completeToken() #inspect this function to learn more about completion
  rc.options("custom.completer" = f)

  ###your custom part###

  ##pull this environment holding all input/output needed
  .CompletionEnv = utils:::.CompletionEnv

  #perhaps read the 'token'. Also 'linebuffer', 'start' & 'end' are also useful
  token = .CompletionEnv$token

  #generate a new completion or multiple...
  your_comps = paste0(token,c("$with_tomato_sauce","$with_apple_sauce"))

  #append your suggestions to the vanilla suggestions/completions
  .CompletionEnv$comps = c(your_comps,.CompletionEnv$comps)

  print(.CompletionEnv$comps)

  #no return used
  NULL
})
