# extendr methods into pure functions

```r
extendr_method_to_pure_functions(env)
```

## Arguments

- `env`: environment object output from extendr-wrappers.R classes

## Returns

env of pure function calls to rust

self is a global of extendr wrapper methods this function copies the function into a new environment and modify formals to have a self argument