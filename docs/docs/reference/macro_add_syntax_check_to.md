# add syntax verification to class

```r
macro_add_syntax_check_to_class(Class_name)
```

## Arguments

- `Class_name`: string name of env class

## Returns

dollarsign method with syntax verification

add syntax verification to class

## Details

this function overrides dollarclass method of a extendr env_class to run first verify_method_call() to check for syntax error and return more user friendly error if issues

All R functions coined 'macro'-functions use eval(parse()) but only at package build time to solve some tricky self-referential problem. If possible to deprecate a macro in a clean way , go ahead.

see zzz.R for usage examples

## See Also

verify_method_call