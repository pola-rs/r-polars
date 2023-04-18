data

# Shift values

## Format

a method

```r
Expr_shift(periods)
```

## Arguments

- `periods`: numeric number of periods to shift, may be negative.

## Returns

Expr

Shift values

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$select(
  pl$lit(0:3)$shift(-2)$alias("shift-2"),
  pl$lit(0:3)$shift(2)$alias("shift+2")
)
```