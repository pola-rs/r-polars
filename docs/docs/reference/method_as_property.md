# Give a class method property behavior

```r
method_as_property(f, setter = FALSE)
```

## Arguments

- `f`: a function
- `setter`: bool, if true a property method can be modified by user

## Returns

function subclassed into c("property","function") or c("setter","property","function")

Internal function, see use in source