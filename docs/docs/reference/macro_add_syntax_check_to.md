# `macro_add_syntax_check_to`

add syntax verification to class


## Description

add syntax verification to class


## Usage

```r
macro_add_syntax_check_to_class(Class_name)
```


## Arguments

Argument      |Description
------------- |----------------
`Class_name`     |     string name of env class


## Details

this function overrides dollarclass method of a extendr env_class
 to run first verify_method_call() to check for syntax error and return
 more user friendly error if issues
 
 All R functions coined 'macro'-functions use eval(parse()) but only at package build time
 to solve some tricky self-referential problem. If possible to deprecate a macro in a clean way
 , go ahead.
 
 see zzz.R for usage examples


## Value

dollarsign method with syntax verification


## Seealso

verify_method_call


