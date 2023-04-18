# Verify user selected method/attribute exists

```r
verify_method_call(
  Class_env,
  Method_name,
  call = sys.call(1L),
  class_name = NULL
)
```

## Arguments

- `Class_env`: env_class object (the classes created by extendr-wrappers.R)
- `Method_name`: name of method requested by user
- `call`: context to throw user error, just use default
- `class_name`: NULLs

## Returns

invisible(NULL)

internal function to check method call of env_classes