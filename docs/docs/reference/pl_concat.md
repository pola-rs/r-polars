# `concat`

Concat polars objects

## Description

Concat polars objects

## Arguments

| Argument | Description                                                                          | 
| -------- | ------------------------------------------------------------------------------------ |
| `l`         | list of DataFrame, or Series, LazyFrame or Expr                                      | 
| `rechunk`         | perform a rechunk at last                                                            | 
| `how`         | choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagnoal" diagonally | 
| `parallel`         | BOOL default TRUE, only used for LazyFrames                                          | 

## Value

DataFrame, or Series, LazyFrame or Expr

## Examples

```r
#vertical
l_ver = lapply(1:10, function(i) {
l_internal = list(
a = 1:5,
b = letters[1:5]
)
pl$DataFrame(l_internal)
})
pl$concat(l_ver, how="vertical")


#horizontal
l_hor = lapply(1:10, function(i) {
l_internal = list(
1:5,
letters[1:5]
)
names(l_internal) = paste0(c("a","b"),i)
pl$DataFrame(l_internal)
})
pl$concat(l_hor, how = "horizontal")
#diagonal
pl$concat(l_hor, how = "diagonal")
```


