# `verify_method_call`

Verify user selected method/attribute exists


## Description

internal function to check method call of env_classes


## Usage

```r
verify_method_call(
  Class_env,
  Method_name,
  call = sys.call(1L),
  class_name = NULL
)
```


## Arguments

Argument      |Description
------------- |----------------
`Class_env`     |     env_class object (the classes created by extendr-wrappers.R)
`Method_name`     |     name of method requested by user
`call`     |     context to throw user error, just use default
`class_name`     |     NULLs


## Value

invisible(NULL)


