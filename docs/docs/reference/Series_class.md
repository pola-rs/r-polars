# Inner workings of the Series-class

The `Series`-class is simply two environments of respectively the public and private methods/function calls to the polars rust side. The instanciated `Series`-object is an `externalptr` to a lowlevel rust polars Series object. The pointer address is the only statefullness of the Series object on the R side. Any other state resides on the rust side. The S3 method `.DollarNames.Series` exposes all public `$foobar()`-methods which are callable onto the object. Most methods return another `Series`-class instance or similar which allows for method chaining. This class system in lack of a better name could be called "environment classes" and is the same class system extendr provides, except here there is both a public and private set of methods. For implementation reasons, the private methods are external and must be called from polars:::.pr.$Series$methodname(), also all private methods must take any self as an argument, thus they are pure functions. Having the private methods as pure functions solved/simplified self-referential complications.

## Details

Check out the source code in R/Series_frame.R how public methods are derived from private methods. Check out extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods are removed and replaced by any function prefixed `Series_`.

## Examples

```r
#see all exported methods
ls(polars:::Series)

#see all private methods (not intended for regular use)
ls(polars:::.pr$Series)


#make an object
s = pl$Series(1:3)

#use a public method/property
s$shape


#use a private method (mutable append not allowed in public api)
s_copy = s
.pr$Series$append_mut(s, pl$Series(5:1))
identical(s_copy$to_r(), s$to_r()) # s_copy was modified when s was modified
```