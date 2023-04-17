# `Expr_alias`

Rename Expr output


## Description

Rename the output of an expression.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_alias(name)
```


## Arguments

Argument      |Description
------------- |----------------
`name`     |     string new name of output


## Value

Expr


## Examples

```r
pl$col("bob")$alias("alice")
```


