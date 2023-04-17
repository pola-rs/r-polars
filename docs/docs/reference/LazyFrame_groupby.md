# `groupby`

Lazy\_groupby

## Description

apply groupby on LazyFrame, return LazyGroupBy

## Usage

```r
LazyFrame_groupby(..., maintain_order = FALSE)
```

## Arguments

| Argument | Description                                                                                    | 
| -------- | ---------------------------------------------------------------------------------------------- |
| `...`         | any single Expr or string naming a column                                                      | 
| `maintain_order`         | bool should an aggregate of groupby retain order of groups or FALSE = random, slightly faster? | 

## Value

A new `LazyGroupBy` object with applied groups.


