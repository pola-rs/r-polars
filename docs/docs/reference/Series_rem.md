# rem Series

```r
Series_rem(other)
```

## Arguments

- `other`: Series or into Series

## Returns

Series

Series arithmetics, remainder

## Examples

```r
pl$Series(1:4)$rem(2L)
pl$Series(1:3)$rem(pl$Series(11:13))
pl$Series(1:3)$rem(1L)
```