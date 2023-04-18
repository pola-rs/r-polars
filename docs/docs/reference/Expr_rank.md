# Rank

```r
Expr_rank(method = "average", reverse = FALSE)
```

## Arguments

- `method`: string option 'average', 'min', 'max', 'dense', 'ordinal', 'random'
    
    #' The method used to assign ranks to tied elements. The following methods are available (default is 'average'):
    
     * 'average' : The average of the ranks that would have been assigned to all the tied values is assigned to each value.
     * 'min' : The minimum of the ranks that would have been assigned to all the tied values is assigned to each value. (This is also referred to as "competition" ranking.)
     * 'max' : The maximum of the ranks that would have been assigned to all the tied values is assigned to each value.
     * 'dense' : Like 'min', but the rank of the next highest element is assigned the rank immediately after those assigned to the tied elements.
     * 'ordinal' : All values are given a distinct rank, corresponding to the order that the values occur in the Series.
     * 'random' : Like 'ordinal', but the rank for ties is not dependent on the order that the values occur in the Series.
- `reverse`: bool, reverse the operation

## Returns

Expr

Assign ranks to data, dealing with ties appropriately.

## Examples

```r
#  The 'average' method:
df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
df$select(pl$col("a")$rank())

#  The 'ordinal' method:
df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
df$select(pl$col("a")$rank("ordinal"))
```