# `strictly_immutable`

polars options


## Description

get, set, reset polars options


## Arguments

Argument      |Description
------------- |----------------
`strictly_immutable`     |     bool, default = TRUE, keep polars strictly immutable. Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions. All settable property elements of classes are mutable. Why?, I guess python just do not have strong stance on immutability. R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs? However, if to mimic pypolars as much as possible, set this to FALSE.
`named_exprs`     |     bool, default = FALSE, allow named exprs in e.g. select, with_columns, groupby, join. a named expresion will be extended with $alias(name) wildcards or expression producing multiple are problematic due to name collision the related option in py-polars is currently called 'pl.Config.with_columns_kwargs' and only allow named exprs in with_columns (or potentially any method derived there of)
`no_messages`     |     bool, default = FALSE, turn of messages
`do_not_repeat_call`     |     bool, default = FALSE, turn of messages
`...`     |     any options to modify
`return_replaced_options`     |     return previous state of modified options Convenient for temporarily swapping of options during testing.


## Details

who likes polars package messages? use this option to turn them off.
 
 do not print the call causing the error in error messages
 
 modifing list takes no effect, pass it to pl$set_polars_options
 get/set/resest interact with internal env `polars:::polars_optenv` 
 
 setting an options may be rejected if not passing opt_requirements


## Value

current settings as list
 
 current settings as list
 
 list named by options of requirement function input must satisfy


## Examples

```r
#rename columns by naming expression, experimental requires option named_exprs = TRUE
pl$set_polars_options(named_exprs = TRUE)
pl$DataFrame(iris)$with_columns(
pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
SW_add_2 = (pl$col("Sepal.Width")+2)
)
pl$get_polars_options()
pl$set_polars_options(strictly_immutable = FALSE)
pl$get_polars_options()


#setting strictly_immutable = 42 will be rejected as
tryCatch(
pl$set_polars_options(strictly_immutable = 42),
error= function(e) print(e)
)

#reset options like this
pl$reset_polars_options()
#use get_polars_opt_requirements() to requirements
pl$get_polars_opt_requirements()
```


