# `class`

Inner workings of the LazyFrame-class

## Description

The `LazyFrame` -class is simply two environments of respectively
the public and private methods/function calls to the polars rust side. The instanciated
`LazyFrame` -object is an `externalptr` to a lowlevel rust polars LazyFrame  object. The pointer address
is the only statefullness of the LazyFrame object on the R side. Any other state resides on the
rust side. The S3 method `.DollarNames.LazyFrame` exposes all public $foobar() -methods which are callable onto the object.
Most methods return another `LazyFrame` -class instance or similar which allows for method chaining.
This class system in lack of a better name could be called "environment classes" and is the same class
system extendr provides, except here there is both a public and private set of methods. For implementation
reasons, the private methods are external and must be called from polars:::.pr.$LazyFrame$methodname(), also
all private methods must take any self as an argument, thus they are pure functions. Having the private methods
as pure functions solved/simplified self-referential complications.

`DataFrame` and `LazyFrame` can both be said to be a `Frame` . To convert use `DataFrame_object$lazy() -> LazyFrame_object` and
`LazyFrame_object$collect() -> DataFrame_object` . This is quite similar to the lazy-collect syntax of the dplyrpackage to
interact with database connections such as SQL variants. Most SQL databases would be able to perform the same otimizations
as polars such Predicate Pushdown and Projection. However polars can intertact and optimize queries with both SQL DBs
and other data sources such parquet files simultanously. (#TODO implement r-polars SQL ;)

## Details

Check out the source code in R/LazyFrame\_\_lazy.R how public methods are derived from private methods.
Check out  extendr-wrappers.R to see the extendr-auto-generated methods. These are moved to .pr and converted
into pure external functions in after-wrappers.R. In zzz.R (named zzz to be last file sourced) the extendr-methods
are removed and replaced by any function prefixed `LazyFrame_` .

## Examples

```r
#see all exported methods
ls(polars:::LazyFrame)

#see all private methods (not intended for regular use)
ls(polars:::.pr$LazyFrame)


## Practical example ##
# First writing R iris dataset to disk, to illustrte a difference
temp_filepath = tempfile()
write.csv(iris, temp_filepath,row.names = FALSE)

# Following example illustrates 2 ways to obtain a LazyFrame

# The-Okay-way: convert an in-memory DataFrame to LazyFrame

#eager in-mem R data.frame
Rdf = read.csv(temp_filepath)

#eager in-mem polars DataFrame
Pdf = pl$DataFrame(Rdf)

#lazy frame starting from in-mem DataFrame
Ldf_okay = Pdf$lazy()

#The-Best-Way:  LazyFrame created directly from a data source is best...
Ldf_best = pl$lazy_csv_reader(temp_filepath)

# ... as if to e.g. filter the LazyFrame, that filtering also caleld predicate will be
# pushed down in the executation stack to the csv_reader, and thereby only bringing into
# memory the rows matching to filter.
# apply filter:
filter_expr = pl$col("Species") == "setosa" #get only rows where Species is setosa
Ldf_okay = Ldf_okay$filter(filter_expr) #overwrite LazyFrame with new
Ldf_best = Ldf_best$filter(filter_expr)

# the non optimized plans are similar, on entire in-mem csv, apply filter
Ldf_okay$describe_plan()
Ldf_best$describe_plan()

# NOTE For Ldf_okay, the full time to load csv alrady paid when creating Rdf and Pdf

#The optimized plan are quite different, Ldf_best will read csv and perform filter simultanously
Ldf_okay$describe_optimized_plan()
Ldf_best$describe_optimized_plan()


#To acquire result in-mem use $colelct()
Pdf_okay = Ldf_okay$collect()
Pdf_best = Ldf_best$collect()


#verify tables would be the same
all.equal(
Pdf_okay$as_data_frame(),
Pdf_best$as_data_frame()
)

#a user might write it as a one-liner like so:
Pdf_best2 = pl$lazy_csv_reader(temp_filepath)$filter(pl$col("Species") == "setosa")
```


