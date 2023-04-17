# `element`

an element in 'eval'-expr


## Description

Alias for an element in evaluated in an `eval` expression.


## Value

Expr


## Examples

```r
pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r()
```


