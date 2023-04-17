# `get_method_usages`

Generate autocompletion suggestions for object


## Description

Generate autocompletion suggestions for object


## Usage

```r
get_method_usages(env, pattern = "")
```


## Arguments

Argument      |Description
------------- |----------------
`env`     |     environment to extract usages from
`pattern`     |     string passed to ls(pattern) to subset methods by pattern


## Details

used internally for auto completion in .DollarNames methods


## Value

method usages


## Examples

```r
polars:::get_method_usages(polars:::DataFrame, pattern="col")
```


