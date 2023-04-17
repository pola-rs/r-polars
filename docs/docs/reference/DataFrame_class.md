# `class`

Inner workings of the DataFrame-class

## Description

The `DataFrame` -class is simply two environments of respectively
the public and private methods/function calls to the polars rust side. The instanciated
`DataFrame` -object is an `externalptr` to a lowlevel rust polars DataFrame  object.
The pointer address is the only statefullness of the DataFrame object on the R side.
Any other state resides on the rust side. The S3 method `.DollarNames.DataFrame`
exposes all public $foobar() -methods which are callable onto the object. Most methods return
another `DataFrame` -class instance or similar which allows for method chaining.
This class system in lack of a better name could be called "environment classes"
and is the same class system extendr provides, except here there is
both a public and private set of methods. For implementation reasons, the private methods are
external and must be called from polars:::.pr.$DataFrame$methodname(), also all private methods
must take any self as an argument, thus they are pure functions. Having the private methods
as pure functions solved/simplified self-referential complications.

## Details

Check out the source code in R/dataframe\_frame.R how public methods are derived from
private methods. Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These
are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named
zzz to be last file sourced) the extendr-methods are removed and replaced by any function
prefixed `DataFrame_` .

## Examples

```r
#see all exported methods
ls(polars:::DataFrame)

#see all private methods (not intended for regular use)
ls(polars:::.pr$DataFrame)


#make an object
df = pl$DataFrame(iris)

#use a public method/property
df$shape
df2 = df
#use a private method, which has mutability
result = polars:::.pr$DataFrame$set_column_from_robj(df,150:1,"some_ints")

#column exists in both dataframes-objects now, as they are just pointers to the same object
# there are no public methods with mutability
df$columns
df2$columns

# set_column_from_robj-method is fallible and returned a result which could be ok or an err.
# No public method or function will ever return a result.
# The `result` is very close to the same as output from functions decorated with purrr::safely.
# To use results on R side, these must be unwrapped first such that
# potentially errors can be thrown. unwrap(result) is a way to
# bridge rust not throwing errors with R. Extendr default behaviour is to use panic!(s) which
# would case some unneccesary confusing and  some very verbose error messages on the inner
# workings of rust. unwrap(result) #in this case no error, just a NULL because this mutable
# method does not return any ok-value.

#try unwrapping an error from polars due to unmatching column lengths
err_result = polars:::.pr$DataFrame$set_column_from_robj(df,1:10000,"wrong_length")
tryCatch(unwrap(err_result,call=NULL),error=\(e) cat(as.character(e)))
```


