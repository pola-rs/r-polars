# Fill Nulls with a value or strategy.

## Format

a method

```r
Expr_fill_null(value = NULL, strategy = NULL, limit = NULL)
```

## Arguments

- `value`: Expr or `Into<Expr>` to fill Null values with
- `strategy`: default NULL else 'forward', 'backward', 'min', 'max', 'mean', 'zero', 'one'
- `limit`: Number of consecutive null values to fill when using the 'forward' or 'backward' strategy.

## Returns

Expr

Shift the values by value or as strategy.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$select(
  pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
  pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
)
```