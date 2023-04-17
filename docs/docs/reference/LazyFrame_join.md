# `join`

LazyFrame join

## Description

join a LazyFrame

## Usage

```r
LazyFrame_join(
  other,
  left_on = NULL,
  right_on = NULL,
  on = NULL,
  how = c("inner", "left", "outer", "semi", "anti", "cross"),
  suffix = "_right",
  allow_parallel = TRUE,
  force_parallel = FALSE
)
```

## Arguments

| Argument | Description                                                                            | 
| -------- | -------------------------------------------------------------------------------------- |
| `other`         | LazyFrame                                                                              | 
| `left_on`         | names of columns in self LazyFrame, order should match. Type, see on param.            | 
| `right_on`         | names of columns in other LazyFrame, order should match. Type, see on param.           | 
| `on`         | named columns as char vector of named columns, or list of expressions and/or strings.  | 
| `how`         | a string selecting one of the following methods: inner, left, outer, semi, anti, cross | 
| `suffix`         | name to added right table                                                              | 
| `allow_parallel`         | bool                                                                                   | 
| `force_parallel`         | bool                                                                                   | 

## Value

A new `LazyFrame` object with applied join.


