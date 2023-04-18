data

# Product

## Format

An object of class `character` of length 1.

```r
Expr_product
```

## Returns

Expr

Compute the product of an expression.

## Details

does not support integer32 currently, .cast() to f64 or i64 first.

## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$product()==6) #is true
```