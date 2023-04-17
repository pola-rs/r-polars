# `Expr_inspect`

Inspect evaluated Series


## Description

Print the value that this expression evaluates to and pass on the value.
 The printing will happen when the expression evaluates, not when it is formed.


## Usage

```r
Expr_inspect(fmt = "{}")
```


## Arguments

Argument      |Description
------------- |----------------
`fmt`     |     format string, should contain one set of `{}` where object will be printed This formatting mimics python "string".format() use in pypolars. The string can contain any thing but should have exactly one set of curly bracket list() .


## Value

Expr


## Examples

```r
pl$select(pl$lit(1:5)$inspect(
"before dropping half the column it was:{}and not it is dropped")$head(2)
)
```


