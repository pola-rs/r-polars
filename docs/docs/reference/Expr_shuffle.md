# Shuffle

## Format

Method

```r
Expr_shuffle(seed = NULL)
```

## Arguments

- `seed`: numeric value of 0 to 2^52 Seed for the random number generator. If set to Null (default), a random seed value intergish value between 0 and 10000 is picked

## Returns

Expr

Shuffle the contents of this expr.

## Examples

```r
pl$DataFrame(a = 1:3)$select(pl$col("a")$shuffle(seed=1))
```