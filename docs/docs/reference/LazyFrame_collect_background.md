# `collect_background`

New DataFrame from LazyFrame\_object$collect()

## Description

collect DataFrame by lazy query

## Usage

```r
LazyFrame_collect_background()
```

## Value

collected `DataFrame`

## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```


