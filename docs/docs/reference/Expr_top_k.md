# Top k values

## Format

a method

```r
Expr_top_k(k, reverse = FALSE)
```

## Arguments

- `k`: numeric k top values to get
- `reverse`: bool if true then k smallest values

## Returns

Expr

Return the `k` largest elements. If 'reverse=True` the smallest elements will be given.

## Details

This has time complexity: ` O(n + k \\log{}n - \frac{k}{2}) `

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$top_k(5))
```