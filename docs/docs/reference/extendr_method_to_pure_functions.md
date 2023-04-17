# `extendr_method_to_pure_functions`

extendr methods into pure functions


## Description

self is a global of extendr wrapper methods
 this function copies the function into a new environment and
 modify formals to have a self argument


## Usage

```r
extendr_method_to_pure_functions(env)
```


## Arguments

Argument      |Description
------------- |----------------
`env`     |     environment object output from extendr-wrappers.R classes


## Value

env of pure function calls to rust


