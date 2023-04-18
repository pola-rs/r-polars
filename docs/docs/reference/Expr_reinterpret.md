# reinterpret bits

```r
Expr_reinterpret(signed = TRUE)
```

## Arguments

- `signed`: bool reinterpret into Int64 else UInt64

## Returns

Expr

Reinterpret the underlying bits as a signed/unsigned integer. This operation is only allowed for 64bit integers. For lower bits integers, you can safely use that cast operation.

## Examples

```r
df = pl$DataFrame(iris)
df$select(pl$all()$head(2)$hash(1,2,3,4)$reinterpret())$as_data_frame()
```