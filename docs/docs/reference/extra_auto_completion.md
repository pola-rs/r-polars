# `extra_auto_completion`

Extra polars auto completion


## Description

Extra polars auto completion


## Arguments

Argument      |Description
------------- |----------------
`activate`     |     bool default TRUE, enable chained auto-completion


## Details

polars always supports auto completetion via .DollarNames.
 However chained methods like x$a()$b()$? are not supported vi .DollarNames.
 
 This feature experimental and not perfect. Any feedback is appreciated.
 Currently does not play that nice with Rstudio, as Rstudio backtick quotes any custom
 suggestions.


## Examples

```r
#auto completion via .DollarNames method
e = pl$lit(42) # to autocomplete pl$lit(42) save to variable
# then write `e$`  and press tab to see available methods

# polars has experimental auto completetion for chain of methods if all on the same line
pl$extra_auto_completion() #first activate feature (this will 'annoy' the Rstudio auto-completer)
pl$lit(42)$lit_to_s() # add a $ and press tab 1-3 times
pl$extra_auto_completion(activate = FALSE) #deactivate
```


