# Sample

## Format

Method

```r
Expr_sample(
  frac = NULL,
  with_replacement = TRUE,
  shuffle = FALSE,
  seed = NULL,
  n = NULL
)
```

## Arguments

- `frac`: Fraction of items to return. Cannot be used with `n`.
- `with_replacement`: Allow values to be sampled more than once.
- `shuffle`: Shuffle the order of sampled data points. (implicitly TRUE if, with_replacement = TRUE)
- `seed`: Seed for the random number generator. If set to None (default), a random seed is used.
- `n`: Number of items to return. Cannot be used with `frac`.

## Returns

Expr

#' Sample from this expression.

## Examples

```r
df = pl$DataFrame(a=1:3)
df$select(pl$col("a")$sample(frac=1,with_replacement=TRUE,seed=1L))

df$select(pl$col("a")$sample(frac=2,with_replacement=TRUE,seed=1L))

df$select(pl$col("a")$sample(n=2,with_replacement=FALSE,seed=1L))
```