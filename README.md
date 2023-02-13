
#


Use awesome [polars](https://www.pola.rs/) DataFrame library from R!

### *r-polars is not completely translated yet - aim to finish March 2023*

See what is currently translated in [latest documentation](https://rpolars.github.io/reference/index.html):



# Install latest binary rpolars package directly from github release

No dependencies other than R (≥ 4.1.0)
 - Macbbook x86_64
 `install.packages(repos=NULL, "https://github.com/pola-rs/r-polars/releases/latest/download/rpolars__x86_64-apple-darwin17.0.tgz")`
 
 - Macbook arm64 (Requires Xcode. Makevars script downloads 200MB cross-compiled object file, while your machine links and builds the final R package)
 `remotes::install_github("https://github.com/pola-rs/r-polars",ref = "long_arms64", force =TRUE)`
  
 - Linux x86_64
 `install.packages(repos=NULL, "https://github.com/pola-rs/r-polars/releases/latest/download/rpolars__x86_64-pc-linux-gnu.gz")`
 
 - Windows
 `install.packages(repos=NULL, "https://github.com/pola-rs/r-polars/releases/latest/download/rpolars.zip")`
 
 - Other targets?  Start a new issue.
 - Install a specific version? Find the version specific url, via [releases section](https://github.com/pola-rs/r-polars/releases).


# Install rpolars via [rpolars.r-universe.dev](https://rpolars.r-universe.dev/rpolars#install)
We are very happy to be hosted on R-universe. Thankyou so much to Jeroen Ooms for excellent support.
```r
# Enable repository from rpolars
options(repos = c(
  rpolars = 'https://rpolars.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))
# Download and install rpolars in R
install.packages('rpolars')
```
R-universe provides binaries for windows and macos x86_64 and source builds for other platforms.


See further down how to install rust to build from source.
 
# Documentation:
  [Latest docs found here](https://rpolars.github.io/reference/index.html)

# Contribute
 I'd freaking love any contributions <3 Just reach out if any questions.
### Simple contribution example to implement the cosine expression:

 - Look up the [polars.Expr.cos method in py-polars documentation](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/api/polars.Expr.cos.html).
 - Press the `[source]` button to see the [python impl](https://github.com/pola-rs/polars/blob/master/py-polars/polars/internals/expr/expr.py#L5057-L5079)
 - Find the cos [py-polars rust implementation](https://github.com/pola-rs/polars/blob/a1afbc4b78f5850314351f7e85ded95fd68b6453/py-polars/src/lazy/dsl.rs#L418) (likely just a simple call to the rust-polars api)
 - Adapt the rust part and place it [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/src/rust/src/rdataframe/rexpr.rs#L754).
 - Adapt the python part into R and place it [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/expr__expr.R#L3138). Add roxygen docs + examples above.
 - Notice `Expr_cos = "use_extendr_wrapper"`, it means we're this time just using unmodfied the [extendr auto-generated wrapper](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/extendr-wrappers.R#L253)
 - Write a test [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/tests/testthat/test-expr.R#L1921).
 - Run renv::restore() and resolve all R packages
 - Run extendr::document() to recompile, see new method can be used e.g. like `pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$cos())`
 - Run devtools::test()
 - If you fork rpolars and make a PR, your code will be built and tested on all platforms according to github-actions workflow.


## news:

 - update 1st February: All DateTime expressions included from v0.4.3.

 - update 28th December: r-polars is now hosted at https://github.com/pola-rs/r-polars. Happy to be
 here. You might encounter a bunch of links to the old repository the first weeks. I plan to work on r-polars full time the next 3 months, because why not :) Any contributions 
 are much appreciated. 

 - update 24th November: minipolars is getting bigger and is changing name to rpolars and is hosted on [github.com/rpolars/rpolars](https://github.com/rpolars/rpolars/). Translation, testing and documenting progress is unfortunately not fast enough to finish in 2022. Goal postponed to March 2023. rlang is dropped as install dependency. No dependencies should make it very easy to install and manage versions long term.

 - update 10th November 2022: Full support for Windows, see installation section. After digging through gnu ld linker documentation and R source code idiosyncrasies, rpolars, can now be build for windows (nighly-gnu). In the end adding this super simple [linker export definition file](https://github.com/sorhawell/rpolars/blob/main/src/rpolars-win.def) prevented the linker from trying to export all +160_000 internal variables into a 16bit symbol table maxing out at 65000 variables. Many thanks for 24-hour support from extendr-team <3.

 - update 4th November 2022: [Latest documentation shows half (125) of all expression functions are now ported](https://sorhawell.github.io/reference/index.html#expr). Automatic binary release for Mac and Linux. Windows still pending. It is now very easy to install rpolars from binary. See install section.

 - update: 5th October 2022 Currently ~20% of features have been translated. To make polars call R multi-threaded was a really hard nut to crack as R has no Global-interpreter-lock feature. My solution is to have a main thread in charge of R calls, and any abitrary polars child threads can request to have R user functions executed. Implemented with flume mpsc channels. No serious obstacles left known to me. Just a a lot of writing. Priliminary perfomance benchmarking promise rpolars is going to perform just as fast pypolars.


## What is polars

[Polars](http://pola.rs) is the
[fastest](https://h2oai.github.io/db-benchmark/) data table query
library. The syntax is related to Spark, but column oriented and not row
oriented. All R libraries are also column oriented so this should feel
familiar. Unlike Spark, polars is natively multithreaded instead of
multinode(d). This make polars simple to install and use as any other R
package. Like Spark and SQL-variants polars optimizes queries for memory
consuption and speed so you don’t have to. Expect 5-10 speedup compared
to dplyr on simple transformations from &gt;500Mb data. When chaining
many operations the speedup due to optimization can be even higher.
Polars is built on the apache-arrow memory model.

This port relies on extendr <https://github.com/extendr> which is the R
equivalent to pyo3+maturin. Extendr is very convenient for calling rust
from R and the reverse.

## Build manually from source for use (M1 arch also supported):

 Setup system dependencies:
 - install 'rustup', the cross-platform rust installer
 - `rustup toolchain install nightly` #install nightly
 - `rustup default nightly` #choose nightly
 - on Windows rtools42 must be in path, on mac Xcode is required.
 - install cmake and add to PATH
 
 Build rpolars package for use:
 `remotes::install_github("pola-rs/r-polars")`
 
## Build rpolars package for development:

 Clone:
 - `git clone git@github.com:pola-rs/r-polars.git`
 - `cd r-polars`
 
 Optional step A: Manage suggested packages with renv
 - `source("./renv/activate.R")` # renv is deactivated by default
 - `renv::restore()` #  to install and set up R packages
 
 Typical workflow for development. (requires suggested R packages)
 - Make some changes to R or rust code.
 - `rextendr::document()` # to compile rust code + update wrappers and docs + quick build package
 - `devtools::test()` to run all unit tests.
 - submit PR to rpolars (notice `./renv.lock` sets R packages on build server)
 
 Optional step C: build final package (requires no R package dependencies)
 - `R CMD INSTALL --no-multiarch --with-keep.source rpolars
 
 

# rpolars_teaser
================
Søren Welling
11/24/2022


## Hello world

``` r
#loading the package rpolars only exposes a few functions 
library(rpolars)

#all constructors are accessed via pl

#Here we go, Hello world written with polars expressions
pl$col("hello")$sum()$over("world","from")$alias("polars")
```

    ## polars Expr: col("hello").sum().over([col("world"), col("from")]).alias("polars")

## Typical usage

Where `dplyr` has `%>%`-piping and \``data.table` has `[,]`-indexing,
method chaining `object$m1()$m2()` is the bread and butter syntax of
polars. For now the best learning material to understand the syntax and
the power of polars is the [official user guide for
python](https://pola-rs.github.io/polars-book/user-guide/). As
rpolars syntax is the same ( except `$` instead of `.`) the guide
should be quite useful. The following example shows a typical
‘DataFrame’ method together with chained expressions.

``` r
#create DataFrame from iris
df = pl$DataFrame(iris)

#make selection (similar to dplyr mutute() and data.table [,.()] ) and use expressions or strings.
df = df$select(
  pl$col("Sepal.Width")$sum()$over("Species")$alias("sw_sum_over_species"),
  pl$col("Sepal.Length")$sum()$over("Species")$alias("sl_sum_over_species"),
  "Petal.Width"
)

#polars expressions are column instructions

#1 take the column named Sepal.Width
#2 sum it...
#3 over(by) the column  Species
#4 rename/alias to sw_sum_over_species


#convert back to data.frame
head(df$as_data_frame())
```

    ##   sw_sum_over_species sl_sum_over_species Petal.Width
    ## 1               171.4               250.3         0.2
    ## 2               171.4               250.3         0.2
    ## 3               171.4               250.3         0.2
    ## 4               171.4               250.3         0.2
    ## 5               171.4               250.3         0.2
    ## 6               171.4               250.3         0.4

## `DataFrame` from `series` and R vectors

``` r
#a single column outside a DataFrame is called a series
pl$Series((1:5) * 5,"my_series")
```

    ## polars Series: shape: (5,)
    ## Series: 'my_series' [f64]
    ## [
    ##  5.0
    ##  10.0
    ##  15.0
    ##  20.0
    ##  25.0
    ## ]

``` r
#Create DataFrame from a mix of series and/or plain R vectors.
pl$DataFrame(
  newname = pl$Series(c(1,2,3,4,5),name = "b"), #overwrite name b with 'newname'
  pl$Series((1:5) * 5,"a"),
  pl$Series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) ,#named provide
  c(5,4,3,2,0)
)
```

    ## polars DataFrame: shape: (5, 6)
    ## ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
    ## │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
    ## │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
    ## │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
    ## ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
    ## │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
    ## ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
    ## └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# Data types

``` r
#polars is strongly typed. Data-types can be created like this:
pl$dtypes$Float64
```

    ## polars DataType: Float64

``` r
# currently translated dtypes
pl$dtypes
```

```
$Boolean
polars DataType: Boolean

$Float32
polars DataType: Float32

$Float64
polars DataType: Float64

$Int32
polars DataType: Int32

$Int64
polars DataType: Int64

$UInt32
polars DataType: UInt32

$UInt64
polars DataType: UInt64

$Utf8
polars DataType: Utf8

$Categorical
polars DataType: Categorical(
    None,
)
```

# Read csv and the `LazyFrame`

``` r
  #using iris.csv as example
  write.csv(iris, "iris.csv",row.names = FALSE)

  #read csv into a LazyFrame and compute sum of Sepal.Width over Species
  lpf = pl$lazy_csv_reader("iris.csv")$select(
    pl$col("Sepal.Width")$sum()$over("Species")
  )
  
  #a lazy frame is only a tree of instructions
  print(lpf) #same as lpf$describe_plan()
```

    ## [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"
    ##    SELECT [col("Sepal.Width").sum().over([col("Species")])] FROM
    ##     CSV SCAN iris.csv; PROJECT */5 COLUMNS; SELECTION: None

``` r
  #read plan from bottom to top, says:  "read entire csv, then compute sum x over y"
  
  #what polars actually will do is the optimized plan
  
  lpf$describe_optimized_plan()
```

    ##    SELECT [col("Sepal.Width").sum().over([col("Species")])] FROM
    ##     CSV SCAN iris.csv; PROJECT 2/5 COLUMNS; SELECTION: None

    ## NULL

``` r
  #optimized plan says:  "read only column x and y from csv, compute sum x over y"
  
  #Only reading some columns or in other cases some row in to memory can save speed downstream operations. This is called peojection. 
  
  
  #to execute plan, simply call $collect() and get a DataFrame as result
  
  lpf$collect()
```

    ## polars DataFrame: shape: (150, 1)
    ## ┌─────────────┐
    ## │ Sepal.Width │
    ## │ ---         │
    ## │ f64         │
    ## ╞═════════════╡
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 171.4       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ ...         │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## ├╌╌╌╌╌╌╌╌╌╌╌╌╌┤
    ## │ 148.7       │
    ## └─────────────┘

## Execute R functions within a polars query

It is possible to mix R code with polars by passing R
functions to polars. R functions are slower. Use native polar
functions/expressions where possible.

``` r
    pl$DataFrame(iris)$select(
      pl$col("Sepal.Length")$map(\(s) { #map with a R function
        x = s$to_r_vector() #convert from Series to a native R vector
        x[x>=5] = 10
        x[1:10] # if return is R vector, it will automatically be converted to Series again
      })
    )$as_data_frame()
```

    ##    Sepal.Length
    ## 1          10.0
    ## 2           4.9
    ## 3           4.7
    ## 4           4.6
    ## 5          10.0
    ## 6          10.0
    ## 7           4.6
    ## 8          10.0
    ## 9           4.4
    ## 10          4.9

