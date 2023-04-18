# Set_sorted

```r
Expr_set_sorted(reverse = FALSE)
```

## Arguments

- `reverse`: bool if TRUE Descending else Ascending

## Returns

Expr

Flags the expression as 'sorted'.

## Examples

```r
#correct use flag something correctly as ascendingly sorted
s = pl$select(pl$lit(1:4)$set_sorted()$alias("a"))$get_column("a")
s$flags # see flags

#incorrect use, flag somthing as not sorted ascendingly
s2 = pl$select(pl$lit(c(1,3,2,4))$set_sorted()$alias("a"))$get_column("a")
s2$sort() #sorting skipped, although not actually sorted
```