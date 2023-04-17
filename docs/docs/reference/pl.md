# `pl`

The complete polars public API.


## Description

`pl` -object is a environment of all public functions and class constructors.
 Public functions are not exported as a normal package as it would be huge namespace
 collision with base:: and other functions. All object-methods are accessed with object$method()
 via the new class functions.
 
 Having all functions in an namespace is similar to the rust- and python- polars api.


## Format

An object of class `environment` of length 57.


## Usage

```r
pl
```


## Details

If someone do not particularly like the letter combination `pl` , they are free to
 bind the environment to another variable name as `simon_says = pl` or even do `attach(pl)`


## Examples

```r
#how to use polars via `pl`
pl$col("colname")$sum() / pl$lit(42L)  #expression ~ chain-method / literal-expression

#pl inventory
polars:::print_env(pl,"polars public functions")

#all accessible classes and their public methods
polars:::print_env(
polars:::pl_pub_class_env,
"polars public class methods, access via object$method()"
)
```


