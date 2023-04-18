# mul Series

```r
Series_mul(other)

## S3 method for class 'Series'
s1 * s2
```

## Arguments

- `other`: Series or into Series
- `s1`: lhs Series
- `s2`: rhs Series or any into Series

## Returns

Series

Series arithmetics

## Examples

```r
pl$Series(1:3)$mul(11:13)
pl$Series(1:3)$mul(pl$Series(11:13))
pl$Series(1:3)$mul(1L)
2L * pl$Series(1:3)
pl$Series(1:3) * 2L
```