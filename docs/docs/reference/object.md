data

# Any polars class object is made of this

## Format

An object of class `character` of length 1.

```r
object
```

One SEXP of Rtype: "externalptr" + a class attribute

## Details

 * `object$method()` calls are facilitated by a `$.ClassName`- s3method see 'R/after-wrappers.R'
 * Code completion is facilitted by `.DollarNames.ClassName`-s3method see e.g. 'R/dataframe__frame.R'
 * Implementation of property-methods as DataFrame_columns() and syntax checking is an extension to `$.ClassName`
   
   See function macro_add_syntax_check_to_class().

## Examples

```r
#all a polars object is made of:
some_polars_object = pl$DataFrame(iris)
str(some_polars_object) #External Pointer tagged with a class attribute.
```