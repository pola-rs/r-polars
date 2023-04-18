# wrap_elist_result

```r
wrap_elist_result(elist, str_to_lit = TRUE)
```

## Arguments

- `elist`: a list Expr or any R object Into  (passable to pl$lit)

## Returns

Expr

make sure all elementsof a list is wrapped as Expr Capture any conversion error in the result

## Details

Used internally to ensure an object is a list of expression The output is wrapped in a result, which can contain an ok or err value.

## Examples

```r
polars:::wrap_elist_result(list(pl$lit(42),42,1:3))
```