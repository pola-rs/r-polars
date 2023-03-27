
auto_complete_linebuffer = function() {
  #load this function into custom.completer setting to activate
  rc.options("custom.completer" = function(x) {

    ##activating custom deactivates anything else
    #however you can run utils auto completer also like this
    #rstudio auto completetion is not entirely the same as utils
    f = rc.getOption("custom.completer")
    rc.options("custom.completer" = NULL)
    #function running  base auto complete.
    #It will dump suggestion into mutable .CompletionEnv$comps
    utils:::.completeToken()
    rc.options("custom.completer" = f)

    #get line buffer
    CE = utils:::.CompletionEnv
    lb = CE$linebuffer

    ###your custom part###
    #generate a new completion or multiple...
    last_char = substr(lb,nchar(lb),nchar(lb))
    if(last_char == "$" && nchar(lb)>1L) {
      x = eval(parse(text=substr(lb,1,nchar(lb)-1)))
      if(inherits(x, rpolars:::pl_class_names)) {
        your_comps = .DollarNames(x)
                #append your suggestions to the vanilla suggestions/completions
        CE$comps = c(your_comps,CE$comps)
      }
    }



    #no return used
    NULL
  })
}


