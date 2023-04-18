# Map alias of expression with an R function

```r
Expr_map_alias(fun)
```

## Arguments

- `fun`: an R function which takes a string as input and return a string

## Returns

Expr

Rename the output of an expression by mapping a function over the root name.

## Examples

```r
pl$DataFrame(list(alice=1:3))$select(
  pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob"))
)
```