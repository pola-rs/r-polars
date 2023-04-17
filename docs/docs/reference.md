# Reference 

## All

### Description

Not to mix up with `Expr_object$all()` which is a 'reduce Boolean
columns by AND' method.

### Details

last `all()` in example is this Expr method, the first `pl$all()` refers
to "all-columns" and is an expression constructor

### Value

Boolean literal

### Examples

```r
pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
```


---
## And then

### Description

map an ok-value or pass on an err-value

### Usage

    and_then(x, f)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>f</code></td>
<td><p>a closure that takes the ok part as input</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Err-result


---
## Arr arg max

### Description

Retrieve the index of the maximum value in every sublist.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(s = list(1:2,2:1)))
df$select(pl$col("s")$arr$arg_max())
```


---
## Arr arg min

### Description

Retrieve the index of the minimal value in every sublist.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(s = list(1:2,2:1)))
df$select(pl$col("s")$arr$arg_min())
```


---
## Arr concat

### Description

Concat the arrays in a Series dtype List in linear time.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Rlist, Expr or column of same tyoe as self.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(
  a = list("a","x"),
  b = list(c("b","c"),c("y","z"))
)
df$select(pl$col("a")$arr$concat(pl$col("b")))

df$select(pl$col("a")$arr$concat("hello from R"))

df$select(pl$col("a")$arr$concat(list("hello",c("hello","world"))))
```


---
## Arr contains

### Description

Check if sublists contain the given item.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>item</code></td>
<td><p>any into Expr/literal</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr of a boolean mask

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$contains(1L))
```


---
## Arr diff

### Description

Calculate the n-th discrete difference of every sublist.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Number of slots to shift</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>null_behavior</code></td>
<td><p>choice "ignore"(default) "drop"</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$diff())
```


---
## Arr eval

### Description

Run any polars expression against the lists' elements.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>Expr</code></td>
<td><p>Expression to run. Note that you can select an element with
<code>pl$first()</code>, or <code>pl$col()</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>parallel</code></td>
<td><p>bool Run all expression parallel. Don't activate this blindly.
Parallelism is worth it if there is enough work to do per thread. This
likely should not be use in the groupby context, because we already
parallel execution per group</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(a = list(c(1,8,3), b = c(4,5,2)))
df$select(pl$all()$cast(pl$dtypes$Int64))$with_column(
  pl$concat_list(c("a","b"))$arr$eval(pl$element()$rank())$alias("rank")
)
```


---
## Arr first

### Description

Get the first value of the sublists.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$first())
```


---
## Arr get

### Description

Get the value by index in the sublists.

### Usage

    ## S3 method for class 'ExprArrNameSpace'
    x[index]

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>ExprArrNameSpace</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>index</code></td>
<td><p>value to get</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

`⁠[.ExprArrNameSpace⁠` used as e.g. `pl$col("a")$arr[0]` same as
`pl$col("a")$get(0)`

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$get(0))
df$select(pl$col("a")$arr$get(c(2,0,-1)))
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr[0])
df$select(pl$col("a")$arr[c(2,0,-1)])
```


---
## Arr head

### Description

head the first `n` values of every sublist.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Numeric or Expr, number of values to return for each
sublist.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
df$select(pl$col("a")$arr$head(2))
```


---
## Arr join

### Description

Join all string items in a sublist and place a separator between them.
This errors if inner type of list `⁠!= Utf8⁠`.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>separator</code></td>
<td><p>string to separate the items with</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Series of dtype Utf8

### Examples

```r
df = pl$DataFrame(list(s = list(c("a","b","c"), c("x","y"))))
df$select(pl$col("s")$arr$join(" "))
```


---
## Arr last

### Description

Get the last value of the sublists.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$last())
```


---
## Arr lengths

### Description

Get the length of the arrays as UInt32

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c")))
df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))
```


---
## Arr max

### Description

Compute the max value of the lists in the array.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$max())
```


---
## Arr mean

### Description

Compute the mean value of the lists in the array.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$mean())
```


---
## Arr min

### Description

Compute the min value of the lists in the array.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$min())
```


---
## Arr reverse

### Description

Reverse the arrays in the list.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(
  values = list(3:1, c(9L, 1:2))
))
df$select(pl$col("values")$arr$reverse())
```


---
## Arr shift

### Description

Shift values by the given period.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>periods</code></td>
<td><p>Value. Number of places to shift (may be negative).</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$shift())
```


---
## Arr slice

### Description

Slice every sublist.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>offset</code></td>
<td><p>value or Expr. Start index. Negative indexing is
supported.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>length</code></td>
<td><p>value or Expr. Length of the slice. If set to <code>None</code>
(default), the slice is taken to the end of the list.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$slice(2))
```


---
## Arr sort

### Description

Get the value by index in the sublists.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>index</code></td>
<td><p>numeric vector or Expr of length 1 or same length of Series. if
length 1 pick same value from each sublist, if length as Series/column,
pick by individual index across sublists.</p>
<p>So index <code>0</code> would return the first item of every sublist
and index <code>-1</code> would return the last item of every sublist if
an index is out of bounds, it will return a <code>None</code>.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$get(0))
df$select(pl$col("a")$arr$get(c(2,0,-1)))
```


---
## Arr sum

### Description

Sum all the lists in the array.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$sum())
```


---
## Arr tail

### Description

tail the first `n` values of every sublist.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Numeric or Expr, number of values to return for each
sublist.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
df$select(pl$col("a")$arr$tail(2))
```


---
## Arr take

### Description

Get the take value of the sublists.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
idx = pl$Series(list(0:1,1L,1L))
df$select(pl$col("a")$arr$take(99))
```


---
## Arr to struct

### Description

List to Struct

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n_field_strategy</code></td>
<td><p>Strategy to determine the number of fields of the struct. default
= 'first_non_null' else 'max_width'</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>name_generator</code></td>
<td><p>an R function that takes a scalar column number and outputs a
string value. The default NULL is equivalent to the R function <code
style="white-space: pre;">⁠\(idx) paste0("field_",idx)⁠</code></p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>upper_bound</code></td>
<td><p>upper_bound numeric A polars <code>LazyFrame</code> needs to know
the schema at all time. The caller therefore must provide an
<code>upper_bound</code> of struct fields that will be set. If this is
incorrectly downstream operation may fail. For instance an <code
style="white-space: pre;">⁠all().sum()⁠</code> expression will look in the
current schema to determine which columns to select. It is adviced to
set this value in a lazy query.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(1:3, 1:2)))
df2 = df$select(pl$col("a")$arr$to_struct(
  name_generator =  \(idx) paste0("hello_you_",idx))
  )
df2$unnest()

df2$to_list()
```


---
## Arr unique

### Description

Get the unique/distinct values in the list.

### Format

function

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = list(1, 1, 2)))
df$select(pl$col("a")$arr$unique())
```


---
## C.Series

### Description

Immutable combine series

### Usage

    ## S3 method for class 'Series'
    c(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>Series(s) or any object into Series meaning
<code>pl$Series(object)</code> returns a series</p></td>
</tr>
</tbody>
</table>

### Details

append datatypes has to match. Combine does not rechunk. Read more about
R vectors, Series and chunks in `docs_translations`:

### Value

a combined Series

### Examples

```r
s = c(pl$Series(1:5),3:1,NA_integer_)
s$chunk_lengths() #the series contain three unmerged chunks
```


---
## Cash-set-.DataFrame

### Description

set value of properties of DataFrames

### Usage

    ## S3 replacement method for class 'DataFrame'
    self$name <- value

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>self</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>name</code></td>
<td><p>name method/property to set</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>value</code></td>
<td><p>value to insert</p></td>
</tr>
</tbody>
</table>

### Details

settable polars object properties may appear to be R objects, but they
are not. See `⁠[[method_name]]⁠` example

### Value

value

### Examples

```r
#For internal use
#is only activated for following methods of DataFrame
ls(polars:::DataFrame.property_setters)

#specific use case for one object property 'columns' (names)
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns

# Rstudio is not using the standard R code completion tool
# and it will backtick any special characters. It is possible
# to completely customize the R / Rstudio code completion except
# it will trigger Rstudio to backtick any completion! Also R does
# not support package isolated customization.


#Concrete example if tabbing on 'df$' the raw R suggestion is df$columns<-
#however Rstudio backticks it into df$`columns<-`
#to make life simple, this is valid polars syntax also, and can be used in fast scripting
df$`columns<-` = letters[5:1]

#for stable code prefer e.g.  df$columns = letters[5:1]

#to see inside code of a property use the [[]] syntax instead
df[["columns"]] # to see property code, .pr is the internal polars api into rust polars
polars:::DataFrame.property_setters$columns #and even more obscure to see setter code
```


---
## Check no missing args

### Description

lifecycle: DEPRECATE

### Usage

    check_no_missing_args(fun, args, warn = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fun</code></td>
<td><p>target function to check incomming arguments for</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>args</code></td>
<td><p>list of args to check</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>warn</code></td>
<td><p>bool if TRUE throw warning when check fails</p></td>
</tr>
</tbody>
</table>

### Value

true if args are correct


---
## Check tz to result

### Description

Verify correct time zone

### Usage

    check_tz_to_result(tz, allow_null = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tz</code></td>
<td><p>time zone string or NULL</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>allow_null</code></td>
<td><p>bool, if TRUE accept NULL</p></td>
</tr>
</tbody>
</table>

### Value

a result object, with either a valid string or an Err

### Examples

```r
 check_tz_to_result = polars:::check_tz_to_result # expose internal
 #return Ok
 check_tz_to_result("GMT")
 check_tz_to_result(NULL)

 #return Err
 check_tz_to_result("Alice")
 check_tz_to_result(42)
 check_tz_to_result(NULL, allow_null = FALSE)
```


---
## Clone env one level deep

### Description

Clone env on level deep.

### Usage

    clone_env_one_level_deep(env)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>env</code></td>
<td><p>an R environment.</p></td>
</tr>
</tbody>
</table>

### Details

Sometimes used in polars to produce different hashmaps(environments)
containing some of the same, but not all elements.

environments are used for collections of methods and types. This
function can be used to make a parallel collection pointing to some of
the same types. Simply copying an environment, does apparently not spawn
a new hashmap, and therefore the collections stay identical.

### Value

shallow clone of R environment

### Examples

```r
fruit_env = new.env(parent = emptyenv())
fruit_env$banana = TRUE
fruit_env$apple = FALSE

env_1 = new.env(parent = emptyenv())
env_1$fruit_env = fruit_env

env_naive_copy = env_1
env_shallow_clone = polars:::clone_env_one_level_deep(env_1)

#modifying env_!
env_1$minerals = new.env(parent = emptyenv())
env_1$fruit_env$apple = 42L

#naive copy is fully identical to env_1, so copying it not much useful
ls(env_naive_copy)
#shallow copy env does not have minerals
ls(env_shallow_clone)

#however shallow clone does subscribe to changes to fruits as they were there
# at time of cloning
env_shallow_clone$fruit_env$apple
```


---
## Coalesce

### Description

Folds the expressions from left to right, keeping the first non-null
value.

Folds the expressions from left to right, keeping the first non-null
value.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>is a: If one arg:</p>
<ul>
<li><p>Series or Expr, same as <code>column$sum()</code></p></li>
<li><p>string, same as <code>pl$col(column)$sum()</code></p></li>
<li><p>numeric, same as <code>pl$lit(column)$sum()</code></p></li>
<li><p>list of strings(column names) or exprressions to add up as expr1
+ expr2 + expr3 + ...</p></li>
</ul>
<p>If several args, then wrapped in a list and handled as
above.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>exprs</code></td>
<td><p>list of Expr or Series or strings or a mix, or a char
vector</p></td>
</tr>
</tbody>
</table>

### Value

Expr

Expr

### Examples

```r
df = pl$DataFrame(
  a = NA_real_,
  b = c(1:2,NA_real_,NA_real_),
  c = c(1:3,NA_real_)
)
#use coalesce to get first non Null value for each row, otherwise insert 99.9
df$with_column(
  pl$coalesce("a", "b", "c", 99.9)$alias("d")
)

#Create lagged columns and collect them into a list. This mimics a rolling window.
df = pl$DataFrame(A = c(1,2,9,2,13))
df$with_columns(lapply(
  0:2,
  \(i) pl$col("A")$shift(i)$alias(paste0("A_lag_",i))
))$select(
  pl$concat_list(lapply(2:0,\(i) pl$col(paste0("A_lag_",i))))$alias(
  "A_rolling"
 )
)

#concat Expr a Series and an R obejct
pl$concat_list(list(
  pl$lit(1:5),
  pl$Series(5:1),
  rep(0L,5)
))$alias("alice")$lit_to_s()
```


---
## Col

### Description

Return an expression representing a column in a DataFrame.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><ul>
<li><p>a single column by a string</p></li>
<li><p>all columns by using a wildcard <code>"*"</code></p></li>
<li><p>multiple columns as vector of strings</p></li>
<li><p>column by regular expression if the regex starts with
<code>^</code> and ends with <code>$</code> e.g.
pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))</p></li>
<li><p>a single DataType or an R list of DataTypes, select any column of
any such DataType</p></li>
<li><p>Series of utf8 strings abiding to above options</p></li>
</ul></td>
</tr>
</tbody>
</table>

### Value

Column Exprression

### Examples

```r
df = pl$DataFrame(list(foo=1, bar=2L,foobar="3"))

#a single column by a string
df$select(pl$col("foo"))

#all columns by wildcard
df$select(pl$col("*"))
df$select(pl$all())

#multiple columns as vector of strings
df$select(pl$col(c("foo","bar")))

#column by regular expression if the regex starts with `^` and ends with `$`
df$select(pl$col("^foo.*$"))

#a single DataType
df$select(pl$col(pl$dtypes$Float64))

# ... or an R list of DataTypes, select any column of any such DataType
df$select(pl$col(list(pl$dtypes$Float64, pl$dtypes$Utf8)))

# from Series of names
df$select(pl$col(pl$Series(c("bar","foobar"))))
```


---
## Construct DataTypeVector

### Description

lifecycle: Deprecate, move to rust side

### Usage

    construct_DataTypeVector(l)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>l</code></td>
<td><p>list of Expr or string</p></td>
</tr>
</tbody>
</table>

### Value

extptr to rust vector of RPolarsDataType's


---
## Construct ProtoExprArray

### Description

construct proto Expr array from args

### Usage

    construct_ProtoExprArray(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any Expr or string</p></td>
</tr>
</tbody>
</table>

### Value

ProtoExprArray object

### Examples

```r
polars:::construct_ProtoExprArray(pl$col("Species"),"Sepal.Width")
```


---
## DataFrame as data frame

### Description

return polars DataFrame as R data.frame

### Usage

    DataFrame_as_data_frame(...)

    ## S3 method for class 'DataFrame'
    as.data.frame(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any params passed to as.data.frame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
</tbody>
</table>

### Value

data.frame

data.frame

### Examples

```r
df = pl$DataFrame(iris[1:3,])
df$as_data_frame()
```


---
## DataFrame class

### Description

The `DataFrame`-class is simply two environments of respectively the
public and private methods/function calls to the polars rust side. The
instanciated `DataFrame`-object is an `externalptr` to a lowlevel rust
polars DataFrame object. The pointer address is the only statefullness
of the DataFrame object on the R side. Any other state resides on the
rust side. The S3 method `.DollarNames.DataFrame` exposes all public
`⁠$foobar()⁠`-methods which are callable onto the object. Most methods
return another `DataFrame`-class instance or similar which allows for
method chaining. This class system in lack of a better name could be
called "environment classes" and is the same class system extendr
provides, except here there is both a public and private set of methods.
For implementation reasons, the private methods are external and must be
called from polars:::.pr.$DataFrame$methodname(), also all private
methods must take any self as an argument, thus they are pure functions.
Having the private methods as pure functions solved/simplified
self-referential complications.

### Details

Check out the source code in R/dataframe\_frame.R how public methods are
derived from private methods. Check out extendr-wrappers.R to see the
extendr-auto-generated methods. These are moved to .pr and converted
into pure external functions in after-wrappers.R. In zzz.R (named zzz to
be last file sourced) the extendr-methods are removed and replaced by
any function prefixed `DataFrame_`.

### Examples

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


---
## DataFrame clone

### Description

Rarely useful as DataFrame is nearly 100% immutable Any modification of
a DataFrame would lead to a clone anyways.

### Usage

    DataFrame_clone()

### Value

DataFrame

### Examples

```r
df1 = pl$DataFrame(iris);
df2 =  df1$clone();
df3 = df1
pl$mem_address(df1) != pl$mem_address(df2)
pl$mem_address(df1) == pl$mem_address(df3)
```


---
## DataFrame columns

### Description

get/set column names of DataFrame object

get/set column names of DataFrame object

### Usage

    RField_datatype()

    DataFrame_columns()

### Value

char vec of column names

char vec of column names

### Examples

```r
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns
df = pl$DataFrame(iris)

#get values
df$columns

#set + get values
df$columns = letters[1:5] #<- is fine too
df$columns
```


---
## DataFrame dtypes

### Description

Get dtypes of columns in DataFrame. Dtypes can also be found in column
headers when printing the DataFrame.

Get dtypes of columns in DataFrame. Dtypes can also be found in column
headers when printing the DataFrame.

### Usage

    DataFrame_dtypes()

    DataFrame_schema()

### Value

width as numeric scalar

width as numeric scalar

### Examples

```r
pl$DataFrame(iris)$dtypes

pl$DataFrame(iris)$schema
```


---
## DataFrame estimated size

### Description

Return an estimation of the total (heap) allocated size of the
DataFrame.

### Usage

    DataFrame_estimated_size

### Format

function

### Value

Bytes

### Examples

```r
pl$DataFrame(mtcars)$estimated_size()
```


---
## DataFrame first

### Description

Get the first row of the DataFrame.

### Usage

    DataFrame_first()

### Value

A new `DataFrame` object with applied filter.

### Examples

```r
pl$DataFrame(mtcars)$first()
```


---
## DataFrame get column

### Description

get one column by name as series

### Usage

    DataFrame_get_column(name)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>name of column to extract as Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
df = pl$DataFrame(iris[1,])
df$get_column("Species")
```


---
## DataFrame get columns

### Description

get columns as list of series

### Usage

    DataFrame_get_columns

### Format

An object of class `character` of length 1.

### Value

list of series

### Examples

```r
df = pl$DataFrame(iris[1,])
df$get_columns()
```


---
## DataFrame groupby

### Description

DataFrame$groupby(..., maintain\_order = FALSE)

### Usage

    DataFrame_groupby(..., maintain_order = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any expression</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>maintain_order</code></td>
<td><p>bool</p></td>
</tr>
</tbody>
</table>

### Value

GroupBy (subclass of DataFrame)


---
## DataFrame height

### Description

Get height(nrow) of DataFrame

### Usage

    DataFrame_height()

### Value

height as numeric

### Examples

```r
pl$DataFrame(iris)$height
```


---
## DataFrame join

### Description

join DataFrame with other DataFrame

### Usage

    DataFrame_join(
      other,
      left_on = NULL,
      right_on = NULL,
      on = NULL,
      how = c("inner", "left", "outer", "semi", "anti", "cross"),
      suffix = "_right",
      allow_parallel = TRUE,
      force_parallel = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>left_on</code></td>
<td><p>names of columns in self LazyFrame, order should match. Type, see
on param.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>right_on</code></td>
<td><p>names of columns in other LazyFrame, order should match. Type,
see on param.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>on</code></td>
<td><p>named columns as char vector of named columns, or list of
expressions and/or strings.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>how</code></td>
<td><p>a string selecting one of the following methods: inner, left,
outer, semi, anti, cross</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>suffix</code></td>
<td><p>name to added right table</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>allow_parallel</code></td>
<td><p>bool</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>force_parallel</code></td>
<td><p>bool</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame

### Examples

```r
print(df1 <- pl$DataFrame(list(key=1:3,payload=c('f','i',NA))))
print(df2 <- pl$DataFrame(list(key=c(3L,4L,5L,NA_integer_))))
df1$join(other = df2,on = 'key')
```


---
## DataFrame last

### Description

Get the last row of the DataFrame.

### Usage

    DataFrame_last()

### Value

A new `DataFrame` object with applied filter.

### Examples

```r
pl$DataFrame(mtcars)$last()
```


---
## DataFrame lazy

### Description

Start a new lazy query from a DataFrame

### Usage

    DataFrame_lazy

### Format

An object of class `character` of length 1.

### Value

a LazyFrame

### Examples

```r
pl$DataFrame(iris)$lazy()

#use of lazy method
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") >= 7.7)$collect()
```


---
## DataFrame limit

### Description

take limit of n rows of query

### Usage

    DataFrame_limit(n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>positive numeric or integer number not larger than 2^32</p></td>
</tr>
</tbody>
</table>

### Details

any number will converted to u32. Negative raises error

### Value

DataFrame


---
## DataFrame max

### Description

Aggregate the columns in the DataFrame to their maximum value.

### Usage

    DataFrame_max()

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$max()
```


---
## DataFrame mean

### Description

Aggregate the columns in the DataFrame to their mean value.

### Usage

    DataFrame_mean()

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$mean()
```


---
## DataFrame median

### Description

Aggregate the columns in the DataFrame to their median value.

### Usage

    DataFrame_median()

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$median()
```


---
## DataFrame min

### Description

Aggregate the columns in the DataFrame to their minimum value.

### Usage

    DataFrame_min()

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$min()
```


---
## DataFrame null count

### Description

Create a new DataFrame that shows the null counts per column.

### Usage

    DataFrame_null_count

### Format

function

### Value

DataFrame

### Examples

```r
x = mtcars
x[1, 2:3] = NA
pl$DataFrame(x)$null_count()
```


---
## DataFrame print

### Description

internal method print DataFrame

### Usage

    DataFrame_print()

### Value

self

### Examples

```r
pl$DataFrame(iris)
```


---
## DataFrame reverse

### Description

Reverse the DataFrame.

### Usage

    DataFrame_reverse()

### Value

LazyFrame

### Examples

```r
pl$DataFrame(mtcars)$reverse()
```


---
## DataFrame select

### Description

related to dplyr `mutate()` However discards unmentioned columns as
data.table `.()`.

### Usage

    DataFrame_select(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>expresssions or strings defining columns to select(keep) in
context the DataFrame</p></td>
</tr>
</tbody>
</table>


---
## DataFrame shape

### Description

Get shape/dimensions of DataFrame

### Usage

    DataFrame_shape()

### Value

two length numeric vector of c(nrows,ncols)

### Examples

```r
df = pl$DataFrame(iris)$shape
```


---
## DataFrame slice

### Description

Get a slice of this DataFrame.

### Usage

    DataFrame_slice(offset, length = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>offset</code></td>
<td><p>integer</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>length</code></td>
<td><p>integer or NULL</p></td>
</tr>
</tbody>
</table>

### Value

LazyFrame

### Examples

```r
pl$DataFrame(mtcars)$slice(2, 4)
mtcars[2:6,]
```


---
## DataFrame std

### Description

Aggregate the columns of this DataFrame to their standard deviation
values.

### Usage

    DataFrame_std(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer Delta Degrees of Freedom: the divisor used in the
calculation is N - ddof, where N represents the number of elements. By
default ddof is 1.</p></td>
</tr>
</tbody>
</table>

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$std()
```


---
## DataFrame sum

### Description

Aggregate the columns of this DataFrame to their sum values.

### Usage

    DataFrame_sum()

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$sum()
```


---
## DataFrame tail

### Description

Get the last n rows.

### Usage

    DataFrame_tail(n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>positive numeric of integer number not larger than 2^32</p></td>
</tr>
</tbody>
</table>

### Details

any number will converted to u32. Negative raises error

### Value

DataFrame


---
## DataFrame to series

### Description

get one column by idx as series from DataFrame. Unlike get\_column this
method will not fail if no series found at idx but return a NULL, idx is
zero idx.

### Usage

    DataFrame_to_series(idx = 0)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>idx</code></td>
<td><p>numeric default 0, zero-index of what column to return as
Series</p></td>
</tr>
</tbody>
</table>

### Value

Series or NULL

### Examples

```r
pl$DataFrame(a=1:4)$to_series()
```


---
## DataFrame to Struct unnest

### Description

to\_struct and unnest again

Unnest a DataFrame struct columns.

### Usage

    DataFrame_to_struct(name = "")

    DataFrame_unnest(names = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>name of new Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>names</code></td>
<td><p>names of struct columns to unnest, default NULL unnest any struct
column</p></td>
</tr>
</tbody>
</table>

### Value

@to\_struct() returns a Series

$unnest() returns a DataFrame with all column including any that has
been unnested

### Examples

```r
#round-trip conversion from DataFrame with two columns
df = pl$DataFrame(a=1:5,b=c("one","two","three","four","five"))
s = df$to_struct()
s
s$to_r() # to r list
df_s = s$to_frame() #place series in a new DataFrame
df_s$unnest() # back to starting df
```


---
## DataFrame var

### Description

Aggregate the columns of this DataFrame to their variance values.

### Usage

    DataFrame_var(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer Delta Degrees of Freedom: the divisor used in the
calculation is N - ddof, where N represents the number of elements. By
default ddof is 1.</p></td>
</tr>
</tbody>
</table>

### Value

A new `DataFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$var()
```


---
## DataFrame width

### Description

Get width(ncol) of DataFrame

### Usage

    DataFrame_width()

### Value

width as numeric scalar

### Examples

```r
pl$DataFrame(iris)$width
```


---
## DataFrame with columns

### Description

add or modify columns with expressions

### Usage

    DataFrame_with_columns(...)

    DataFrame_with_column(expr)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any expressions or string column name, or same wrapped in a
list</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>expr</code></td>
<td><p>a single expression or string</p></td>
</tr>
</tbody>
</table>

### Details

Like dplyr `mutate()` as it keeps unmentioned columns unlike $select().

with\_column is derived from with\_columns but takes only one expression
argument

### Value

DataFrame

DataFrame

### Examples

```r
pl$DataFrame(iris)$with_columns(
  pl$col("Sepal.Length")$abs()$alias("abs_SL"),
  (pl$col("Sepal.Length")+2)$alias("add_2_SL")
)

#rename columns by naming expression is concidered experimental
pl$set_polars_options(named_exprs = TRUE) #unlock
pl$DataFrame(iris)$with_columns(
  pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
  SW_add_2 = (pl$col("Sepal.Width")+2)
)
```


---
## DataFrame

### Description

Create new DataFrame

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><ul>
<li><p>one data.frame or something that inherits data.frame or
DataFrame</p></li>
<li><p>one list of mixed vectors and Series of equal length</p></li>
<li><p>mixed vectors and/or Series of equal length</p></li>
</ul>
<p>Columns will be named as of named arguments or alternatively by names
of Series or given a placeholder name.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>make_names_unique</code></td>
<td><p>default TRUE, any duplicated names will be prefixed a running
number</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>parallel</code></td>
<td><p>bool default FALSE, experimental multithreaded interpretation of
R vectors into a polars DataFrame. This is experimental as multiple
threads read from R mem simultaneously. So far no issues parallel read
from R has been found.</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame

### Examples

```r
pl$DataFrame(
  a = list(c(1,2,3,4,5)), #NB if first column should be a list, wrap it in a Series
  b = 1:5,
  c = letters[1:5],
  d = list(1:1,1:2,1:3,1:4,1:5)
) #directly from vectors

#from a list of vectors or data.frame
pl$DataFrame(list(
  a= c(1,2,3,4,5),
  b=1:5,
  c = letters[1:5],
  d = list(1L,1:2,1:3,1:4,1:5)
))
```


---
## DataType constructors

### Description

List of all composite DataType constructors

### Usage

    DataType_constructors

### Format

An object of class `list` of length 3.

### Details

This list is mainly used in `zzz.R` `.onLoad` to instantiate singletons
of all flag-like DataTypes.

Non-flag like DataType called composite DataTypes also carries extra
information e.g. Datetime a timeunit and a TimeZone, or List which
recursively carries another DataType inside. Composite DataTypes use
DataType constructors.

Any DataType can be found in pl$dtypes

### Value

DataType

### Examples

```r
#constructors are finally available via pl$... or pl$dtypes$...
pl$List(pl$List(pl$Int64))
```


---
## DataType new

### Description

Create a new flag like DataType

### Usage

    DataType_new(str)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>str</code></td>
<td><p>name of DataType to create</p></td>
</tr>
</tbody>
</table>

### Details

This function is mainly used in `zzz.R` `.onLoad` to instantiate
singletons of all flag-like DataType.

Non-flag like DataType called composite DataTypes also carries extra
information e.g. Datetime a timeunit and a TimeZone, or List which
recursively carries another DataType inside. Composite DataTypes use
DataType constructors.

Any DataType can be found in pl$dtypes

### Value

DataType

### Examples

```r
polars:::DataType_new("Int64")
```


---
## DataType

### Description

`DataType` any polars type (ported so far)

### Examples

```r
print(ls(pl$dtypes))
pl$dtypes$Float64
pl$dtypes$Utf8

pl$List(pl$List(pl$UInt64))

pl$Struct(pl$Field("CityNames", pl$Utf8))

# Some DataType use case, this user function fails because....
## Not run: 
  pl$Series(1:4)$apply(\(x) letters[x])

## End(Not run)
#The function changes type from Integer(Int32)[Integers] to char(Utf8)[Strings]
#specifying the output DataType: Utf8 solves the problem
pl$Series(1:4)$apply(\(x) letters[x],datatype = pl$dtypes$Utf8)
```


---
## Docs translations

### Description

\#Comments for how the R and python world translates into polars:

R and python are both high-level glue languages great for Data Science.
Rust is a pedantic low-level language with similar use cases as C and
C++. Polars is written in ~100k lines of rust and has a rust API.
Py-polars the python API for polars, is implemented as an interface with
the rust API. r-polars is very parallel to py-polars except it
interfaces with R. The performance and behavior are unexpectedly quite
similar as the 'engine' is the exact same rust code and data structures.

### Format

info

### Translation details

#### R and the integerish

R only has a native Int32 type, no Uint32, Int64, UInt64 , ... types.
These days Int32 is getting a bit small, to refer to more rows than ~
2^31-1. There are packages which provide int64, but the most normal
hack' is to just use floats as 'integerish'. There is an unique float64
value for every integer up to about 2^52 which is plenty for all
practical concerns. Some polars methods may accept or return a floats
even though an integer ideally would be more accurate. Most R functions
intermix Int32 (integer) and Float64 (double) seamlessly.

#### Missingness

R has allocated a value in every vector type to signal missingness,
these are collectively called `NAs`. Polars uses a bool bitmask to
signal `NA`-like missing value and it is called `Null` and `Nulls` in
plural. Not to confuse with R `NULL` (see paragraph below). Polars
supports missingness for any possible type as it kept separately in the
bitmask. In python lists the symbol `None` can carry a similar meaning.
R `NA` ~ polars `Null` ~ py-polars `⁠[None]⁠` (in a py list)

#### Sorting and comparisons

From writing alot of tests for all implementations, it appears polars
does not have a fully consistent nor well documented behavior, when it
comes to comparisons and sorting of floats. Though some general thumb
rules do apply: Polars have chosen to define in sorting that `Null` is a
value lower than `-Inf` as in `Expr.arg_min()` However except when
`Null` is ignored `Expr.min()`, there is a `Expr.nan_min()` but no
`Expr.nan_min()`. `NaN` is sometimes a value higher than Inf and
sometimes regarded as a `Null`. Polars conventions `NaN` &gt; `Inf` &gt;
`99` &gt; `-99` &gt; `-Inf` &gt; `Null` `Null == Null` yields often
times false, sometimes true, sometimes `Null`. The documentation or
examples do not reveal this variations. The best to do, when in doubt,
is to do test sort on a small Series/Column of all values.

\#' R `NaN` ~ polars `NaN` ~ python `⁠[float("NaN")]⁠` \#only floats have
`NaN`s

R `Inf` ~ polars `inf` ~ python `⁠[float("inf")]⁠` \#only floats have
`Inf`

#### NULL IS NOT Null is not NULL

The R NULL does not exist inside polars frames and series and so on. It
resembles the Option::None in the hidden rust code. It resembles the
python `None`. In all three langues the `NULL`/`None`/`None` are used in
this context as function argument to signal default behavior or perhaps
a deactivated feature. R `NULL` does NOT translate into the polars
bitmask `Null`, that is `NA`. R `NULL` ~ rust-polars `Option::None` ~
pypolars `None` \#typically used for function arguments

#### LISTS, FRAMES AND DICTS

The following translations are relevant when loading data into polars.
The R list appears similar to python dictionary (hashmap), but is
implemented more similar to the python list (array of pointers). R list
do support string naming elements via a string vector. In polars both
lists (of vectors or series) and data.frames can be used to construct a
polars DataFrame, just a as dictionaries would be used in python. In
terms of loading in/out data the follow tranlation holds: R
`data.frame`/`list` ~ polars `DataFrame` ~ python `dictonary`

#### Series and Vectors

The R vector (Integer, Double, Character, ...) resembles the Series as
both are external from any frame and can be of any length. The
implementation is quite different. E.g. `for`-loop appending to an R
vector is considered quite bad for performance. The vector will be fully
rewritten in memory for every append. The polars Series has chunked
memory allocation, which allows any appened data to be written only.
However fragmented memory is not great for fast computations and polars
objects have a `rechunk`()-method, to reallocate chunks into one.
Rechunk might be called implicitly by polars. In the context of
constructing. Series and extracting data , the following translation
holds: R `vector` ~ polars `Series`/`column` ~ python `list`

#### Expressions

The polars Expr do not have any base R counterpart. Expr are analogous
to how ggplot split plotting instructions from the rendering. Base R
plot immediately pushes any instruction by adding e.g. pixels to a .png
canvas. `ggplot` collects instructions and in the end when executed the
rendering can be performed with optimization across all instructions.
Btw `ggplot` command-syntax is a monoid meaning the order does not
matter, that is not the case for polars Expr. Polars Expr's can be
understood as a DSL (domain specific language) that expresses syntax
trees of instructions. R expressions evaluate to syntax trees also, but
it difficult to optimize the execution order automaticly, without
rewriting the code. A great selling point of Polars is that any query
will be optimized. Expr are very light-weight symbols chained together.


---
## Dot-DollarNames.DataFrame

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'DataFrame'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.Expr

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'Expr'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.GroupBy

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'GroupBy'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>GroupBy</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.LazyFrame

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'LazyFrame'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>LazyFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.PolarsBackgroundHandle

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'PolarsBackgroundHandle'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>LazyFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.Series

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'Series'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.VecDataFrame

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'VecDataFrame'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>VecDataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.When

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'When'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>When</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.WhenThen

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'WhenThen'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>WhenThen</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-DollarNames.WhenThenThen

### Description

called by the interactive R session internally

### Usage

    ## S3 method for class 'WhenThenThen'
    .DollarNames(x, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>WhenThenThen</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>code-stump as string to auto-complete</p></td>
</tr>
</tbody>
</table>


---
## Dot-pr

### Description

`.pr` Original extendr bindings converted into pure functions

### Usage

    .pr

### Format

An object of class `environment` of length 16.

### Examples

```r
#.pr$DataFrame$print() is an external function where self is passed as arg
polars:::.pr$DataFrame$print(self = pl$DataFrame(iris))
polars:::print_env(.pr,".pr the collection of private method calls to rust-polars")
```


---
## Element

### Description

Alias for an element in evaluated in an `eval` expression.

### Value

Expr

### Examples

```r
pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r()
```


---
## Err

### Description

Wrap in Err

### Usage

    Err(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Err-result


---
## Expr abs

### Description

Compute absolute values

### Usage

    Expr_abs

### Format

An object of class `character` of length 1.

### Value

Exprs abs

### Examples

```r
pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
```


---
## Expr add

### Description

Addition

### Usage

    Expr_add(other)

    ## S3 method for class 'Expr'
    e1 + e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Value

Exprs

### Examples

```r
#three syntaxes same result
pl$lit(5) + 10
pl$lit(5) + pl$lit(10)
pl$lit(5)$add(pl$lit(10))
+pl$lit(5) #unary use resolves to same as pl$lit(5)
```


---
## Expr agg groups

### Description

Get the group indexes of the group by operation. Should be used in
aggregation context only.

### Usage

    Expr_agg_groups

### Format

An object of class `character` of length 1.

### Value

Exprs

### Examples

```r
df = pl$DataFrame(list(
  group = c("one","one","one","two","two","two"),
  value =  c(94, 95, 96, 97, 97, 99)
))
df$groupby("group", maintain_order=TRUE)$agg(pl$col("value")$agg_groups())
```


---
## Expr alias

### Description

Rename the output of an expression.

### Usage

    Expr_alias(name)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>string new name of output</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$col("bob")$alias("alice")
```


---
## Expr all

### Description

Check if all boolean values in a Boolean column are `TRUE`. This method
is an expression - not to be confused with `pl$all` which is a function
to select all columns.

### Usage

    Expr_all

### Format

An object of class `character` of length 1.

### Details

last `all()` in example is this Expr method, the first `pl$all()` refers
to "all-columns" and is an expression constructor

### Value

Boolean literal

### Examples

```r
pl$DataFrame(
  all=c(TRUE,TRUE),
  any=c(TRUE,FALSE),
  none=c(FALSE,FALSE)
)$select(
  pl$all()$all()
)
```


---
## Expr and

### Description

combine to boolean exprresions with AND

### Usage

    Expr_and(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$lit(TRUE) & TRUE
pl$lit(TRUE)$and(pl$lit(TRUE))
```


---
## Expr any

### Description

Check if any boolean value in a Boolean column is `TRUE`.

### Usage

    Expr_any

### Format

An object of class `character` of length 1.

### Value

Boolean literal

### Examples

```r
pl$DataFrame(
  all=c(TRUE,TRUE),
  any=c(TRUE,FALSE),
  none=c(FALSE,FALSE)
)$select(
  pl$all()$any()
)
```


---
## Expr append

### Description

This is done by adding the chunks of `other` to this `output`.

### Usage

    Expr_append(other, upcast = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Expr, into Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>upcast</code></td>
<td><p>bool upcast to, if any supertype of two non equal
datatypes.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
#append bottom to to row
df = pl$DataFrame(list(a = 1:3, b = c(NA_real_,4,5)))
df$select(pl$all()$head(1)$append(pl$all()$tail(1)))

#implicit upcast, when default = TRUE
pl$DataFrame(list())$select(pl$lit(42)$append(42L))
pl$DataFrame(list())$select(pl$lit(42)$append(FALSE))
pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE))
```


---
## Expr apply

### Description

Apply a custom/user-defined function (UDF) in a GroupBy or Projection
context. Depending on the context it has the following behavior:
-Selection

### Usage

    Expr_apply(
      f,
      return_type = NULL,
      strict_return_type = TRUE,
      allow_fail_eval = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>f</code></td>
<td><p>r function see details depending on context</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>return_type</code></td>
<td><p>NULL or one of pl$dtypes, the output datatype, NULL is the same
as input.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict_return_type</code></td>
<td><p>bool (default TRUE), error if not correct datatype returned from
R, if FALSE will convert to a Polars Null and carry on.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>allow_fail_eval</code></td>
<td><p>bool (default FALSE), if TRUE will not raise user function error
but convert result to a polars Null and carry on.</p></td>
</tr>
</tbody>
</table>

### Details

Apply a user function in a groupby or projection(select) context

Depending on context the following behaviour:

-   Projection/Selection: Expects an `f` to operate on R scalar values.
    Polars will convert each element into an R value and pass it to the
    function The output of the user function will be converted back into
    a polars type. Return type must match. See param return type. Apply
    in selection context should be avoided as a `lapply()` has half the
    overhead.

-   Groupby Expects a user function `f` to take a `Series` and return a
    `Series` or Robj convertable to `Series`, eg. R vector. GroupBy
    context much faster if number groups are quite fewer than number of
    rows, as the iteration is only across the groups. The r user
    function could e.g. do vectorized operations and stay quite
    performant. use `s$to_r()` to convert input Series to an r vector or
    list. use `s$to_r_vector` and `s$to_r_list()` to force conversion to
    vector or list.

Implementing logic using an R function is almost always *significantly*
slower and more memory intensive than implementing the same logic using
the native expression API because: - The native expression engine runs
in Rust; functions run in R. - Use of R functions forces the DataFrame
to be materialized in memory. - Polars-native expressions can be
parallelised (R functions cannot\*). - Polars-native expressions can be
logically optimised (R functions cannot). Wherever possible you should
strongly prefer the native expression API to achieve the best
performance.

### Value

Expr

### Examples

```r
#apply over groups - normal usage
# s is a series of all values for one column within group, here Species
e_all =pl$all() #perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")
e_sum  = e_all$apply(\(s)  sum(s$to_r()))$suffix("_sum")
e_head = e_all$apply(\(s) head(s$to_r(),2))$suffix("_head")
pl$DataFrame(iris)$groupby("Species")$agg(e_sum,e_head)


# apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time
# on a 2015 MacBook Pro) x is an R scalar

#perform on all Float64 columns, using pl$all requires user function can handle any input type
e_all =pl$col(pl$dtypes$Float64)
e_add10  = e_all$apply(\(x)  {x+10})$suffix("_sum")
#quite silly index into alphabet(letters) by ceil of float value
#must set return_type as not the same as input
e_letter = e_all$apply(\(x) letters[ceiling(x)], return_type = pl$dtypes$Utf8)$suffix("_letter")
pl$DataFrame(iris)$select(e_add10,e_letter)


##timing "slow" apply in select /with_columns context, this makes apply
n = 1000000L
set.seed(1)
df = pl$DataFrame(list(
  a = 1:n,
  b = sample(letters,n,replace=TRUE)
 ))

print("apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro")
system.time({
  rdf = df$with_columns(
pl$col("a")$apply(\(x) {
 x*2L
   })$alias("bob")
 )
})

print("R lapply 1 million values take ~1sec on 2015 MacBook Pro")
system.time({
 lapply(df$get_column("a")$to_r(),\(x) x*2L )
})
print("using polars syntax takes ~1ms")
system.time({
 (df$get_column("a") * 2L)
})


print("using R vector syntax takes ~4ms")
r_vec = df$get_column("a")$to_r()
system.time({
 r_vec * 2L
})
```


---
## Expr arccos

### Description

Compute the element-wise value for the inverse cosine.

### Usage

    Expr_arccos

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,cos(0.5),0,1,NA_real_))$select(pl$col("a")$arccos())
```


---
## Expr arccosh

### Description

Compute the element-wise value for the inverse hyperbolic cosine.

### Usage

    Expr_arccosh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,cosh(0.5),0,1,NA_real_))$select(pl$col("a")$arccosh())
```


---
## Expr arcsin

### Description

Compute the element-wise value for the inverse sine.

### Usage

    Expr_arcsin

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,sin(0.5),0,1,NA_real_))$select(pl$col("a")$arcsin())
```


---
## Expr arcsinh

### Description

Compute the element-wise value for the inverse hyperbolic sine.

### Usage

    Expr_arcsinh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,sinh(0.5),0,1,NA_real_))$select(pl$col("a")$arcsinh())
```


---
## Expr arctan

### Description

Compute the element-wise value for the inverse tangent.

### Usage

    Expr_arctan

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,tan(0.5),0,1,NA_real_))$select(pl$col("a")$arctan())
```


---
## Expr arctanh

### Description

Compute the element-wise value for the inverse hyperbolic tangent.

### Usage

    Expr_arctanh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,tanh(0.5),0,1,NA_real_))$select(pl$col("a")$arctanh())
```


---
## Expr arg max

### Description

Get the index of the minimal value.

### Usage

    Expr_arg_max

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_max())
```


---
## Expr arg min

### Description

Get the index of the minimal value.

### Usage

    Expr_arg_min

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_min())
```


---
## Expr arg sort

### Description

Get the index values that would sort this column. If 'reverse=True' the
smallest elements will be given.

argsort is a alias for arg\_sort

### Usage

    Expr_arg_sort(reverse = FALSE, nulls_last = FALSE)

    Expr_argsort(reverse = FALSE, nulls_last = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool default FALSE, reverses sort</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>nulls_last</code></td>
<td><p>bool, default FALSE, place Nulls last</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_sort())
```


---
## Expr arg unique

### Description

Index of First Unique Value.

### Usage

    Expr_arg_unique

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$select(pl$lit(c(1:2,1:3))$arg_unique())
```


---
## Expr arr

### Description

Create an object namespace of all list related methods. See the
individual method pages for full details

### Usage

    Expr_arr()

### Value

Expr

### Examples

```r
df_with_list = pl$DataFrame(
  group = c(1,1,2,2,3),
  value = c(1:5)
)$groupby(
  "group",maintain_order = TRUE
)$agg(
  pl$col("value") * 3L
)
df_with_list$with_column(
  pl$col("value")$arr$lengths()$alias("group_size")
)
```


---
## Expr backward fill

### Description

Fill missing values with the next to be seen values.

### Usage

    Expr_backward_fill(limit = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>limit</code></td>
<td><p>Expr or <code style="white-space: pre;">⁠Into&lt;Expr&gt;⁠</code>
The number of consecutive null values to backward fill.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
l = list(a=c(1L,rep(NA_integer_,3L),10))
pl$DataFrame(l)$select(
  pl$col("a")$backward_fill()$alias("bf_null"),
  pl$col("a")$backward_fill(limit = 0)$alias("bf_l0"),
  pl$col("a")$backward_fill(limit = 1)$alias("bf_l1")
)$to_list()
```


---
## Expr bin

### Description

Create an object namespace of all binary related methods. See the
individual method pages for full details

### Usage

    Expr_bin()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr cast

### Description

Cast between DataType(s)

### Usage

    Expr_cast(dtype, strict = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>dtype</code></td>
<td><p>DataType to cast to.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>strict</code></td>
<td><p>bool if true an error will be thrown if cast failed at resolve
time.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = 1:3, b = 1:3))
df$with_columns(
  pl$col("a")$cast(pl$dtypes$Float64, TRUE),
  pl$col("a")$cast(pl$dtypes$Int32, TRUE)
)
```


---
## Expr cat

### Description

Create an object namespace of all cat related methods. See the
individual method pages for full details

### Usage

    Expr_cat()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr ceil

### Description

Rounds up to the nearest integer value. Only works on floating point
Series.

### Usage

    Expr_ceil

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
  pl$col("a")$ceil()
)
```


---
## Expr clip

### Description

Clip (limit) the values in an array to a `min` and `max` boundary.

### Usage

    Expr_clip(min, max)

    Expr_clip_min(min)

    Expr_clip_max(max)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>min</code></td>
<td><p>Minimum Value, ints and floats or any literal expression of ints
and floats</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>max</code></td>
<td><p>Maximum Value, ints and floats or any literal expression of ints
and floats</p></td>
</tr>
</tbody>
</table>

### Details

Only works for numerical types. If you want to clip other dtypes,
consider writing a "when, then, otherwise" expression. See :func:`when`
for more information.

### Value

Expr

### Examples

```r
df = pl$DataFrame(foo = c(-50L, 5L, NA_integer_,50L))
df$with_column(pl$col("foo")$clip(1L,10L)$alias("foo_clipped"))
df$with_column(pl$col("foo")$clip_min(1L)$alias("foo_clipped"))
df$with_column(pl$col("foo")$clip_max(10L)$alias("foo_clipped"))
```


---
## Expr cos

### Description

Compute the element-wise value for the cosine.

### Usage

    Expr_cos

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$cos())
```


---
## Expr cosh

### Description

Compute the element-wise value for the hyperbolic cosine.

### Usage

    Expr_cosh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,acosh(1.5),0,1,NA_real_))$select(pl$col("a")$cosh())
```


---
## Expr count

### Description

Count the number of values in this expression. Similar to R length()

### Usage

    Expr_count

    Expr_len

### Format

An object of class `character` of length 1.

An object of class `character` of length 1.

### Value

Expr

Expr

### Examples

```r
pl$DataFrame(
  all=c(TRUE,TRUE),
  any=c(TRUE,FALSE),
  none=c(FALSE,FALSE)
)$select(
  pl$all()$count()
)
pl$DataFrame(
  all=c(TRUE,TRUE),
  any=c(TRUE,FALSE),
  none=c(FALSE,FALSE)
)$select(
  pl$all()$len(),
  pl$col("all")$first()$len()$alias("all_first")
)
```


---
## Expr cumcount

### Description

Get an array with the cumulative count computed at every element.
Counting from 0 to len

### Usage

    Expr_cumcount(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, default FALSE, if true roll over vector from back to
forth</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

cumcount does not seem to count within lists.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cumcount()$alias("cumcount"),
  pl$col("a")$cumcount(reverse=TRUE)$alias("cumcount_reversed")
)
```


---
## Expr cummin

### Description

Get an array with the cumulative min computed at every element.

Get an array with the cumulative max computed at every element.

### Usage

    Expr_cummin(reverse = FALSE)

    Expr_cummax(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, default FALSE, if true roll over vector from back to
forth</p></td>
</tr>
</tbody>
</table>

### Format

a method

a method

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

Expr

### Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cummin()$alias("cummin"),
  pl$col("a")$cummin(reverse=TRUE)$alias("cummin_reversed")
)
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cummax()$alias("cummux"),
  pl$col("a")$cummax(reverse=TRUE)$alias("cummax_reversed")
)
```


---
## Expr cumprod

### Description

Get an array with the cumulative product computed at every element.

### Usage

    Expr_cumprod(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, default FALSE, if true roll over vector from back to
forth</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cumprod()$alias("cumprod"),
  pl$col("a")$cumprod(reverse=TRUE)$alias("cumprod_reversed")
)
```


---
## Expr cumsum

### Description

Get an array with the cumulative sum computed at every element.

### Usage

    Expr_cumsum(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, default FALSE, if true roll over vector from back to
forth</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:4))$select(
  pl$col("a")$cumsum()$alias("cumsum"),
  pl$col("a")$cumsum(reverse=TRUE)$alias("cumsum_reversed")
)
```


---
## Expr cumulative eval

### Description

Run an expression over a sliding window that increases `1` slot every
iteration.

### Usage

    Expr_cumulative_eval(expr, min_periods = 1L, parallel = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>expr</code></td>
<td><p>Expression to evaluate</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>min_periods</code></td>
<td><p>Number of valid values there should be in the window before the
expression is evaluated. valid values =
<code>length - null_count</code></p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>parallel</code></td>
<td><p>Run in parallel. Don't do this in a groupby or another operation
that already has much parallelization.</p></td>
</tr>
</tbody>
</table>

### Details

Warnings

This functionality is experimental and may change without it being
considered a breaking change. This can be really slow as it can have
`O(n^2)` complexity. Don't use this for operations that visit all
elements.

### Value

Expr

### Examples

```r
pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r()
```


---
## Expr diff

### Description

Calculate the n-th discrete difference.

### Usage

    Expr_diff(n = 1, null_behavior = "ignore")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Integerish Number of slots to shift.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>null_behavior</code></td>
<td><p>option default 'ignore', else 'drop'</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(list( a=c(20L,10L,30L,40L)))$select(
  pl$col("a")$diff()$alias("diff_default"),
  pl$col("a")$diff(2,"ignore")$alias("diff_2_ignore")
)
```


---
## Expr div

### Description

Divide

### Usage

    Expr_div(other)

    ## S3 method for class 'Expr'
    e1 / e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Value

Exprs

### Examples

```r
#three syntaxes same result
pl$lit(5) / 10
pl$lit(5) / pl$lit(10)
pl$lit(5)$div(pl$lit(10))
```


---
## Expr dot

### Description

Compute the dot/inner product between two Expressions.

### Usage

    Expr_dot(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Expr to compute dot product with.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(
  a=1:4,b=c(1,2,3,4),c="bob"
)$select(
  pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
  pl$col("a")$dot(pl$col("a"))$alias("a dot a")
)
```


---
## Expr drop nans

### Description

Drop floating point NaN values. Similar to R syntax `x[!is.nan(x)]`

### Usage

    Expr_drop_nans

### Format

An object of class `character` of length 1.

### Details

Note that NaN values are not null values! (null corrosponds to R NA, not
R NULL) To drop null values, use method `drop_nulls`.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
 pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nans())
```


---
## Expr drop nulls

### Description

Drop null values. Similar to R syntax `x[!(is.na(x) & !is.nan(x))]`

### Usage

    Expr_drop_nulls

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
 pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nulls())
```


---
## Expr dt

### Description

Create an object namespace of all datetime related methods. See the
individual method pages for full details

### Usage

    Expr_dt()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr entropy

### Description

Computes the entropy. Uses the formula `-sum(pk * log(pk))` where `pk`
are discrete probabilities. Return Null if input is not values

### Usage

    Expr_entropy(base = base::exp(1), normalize = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>base</code></td>
<td><p>Given exponential base, defaults to <code>e</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>normalize</code></td>
<td><p>Normalize pk if it doesn't sum to 1.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$select(pl$lit(c("a","b","b","c","c","c"))$unique_counts()$entropy(base=2))
```


---
## Expr eq

### Description

eq method and operator

### Usage

    Expr_eq(other)

    ## S3 method for class 'Expr'
    e1 == e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(2) == 2
pl$lit(2) ==  pl$lit(2)
pl$lit(2)$eq(pl$lit(2))
```


---
## Expr ewm mean std var

### Description

Exponentially-weighted moving average/std/var.

Ewm\_std

Ewm\_var

### Usage

    Expr_ewm_mean(
      com = NULL,
      span = NULL,
      half_life = NULL,
      alpha = NULL,
      adjust = TRUE,
      min_periods = 1L,
      ignore_nulls = TRUE
    )

    Expr_ewm_std(
      com = NULL,
      span = NULL,
      half_life = NULL,
      alpha = NULL,
      adjust = TRUE,
      bias = FALSE,
      min_periods = 1L,
      ignore_nulls = TRUE
    )

    Expr_ewm_var(
      com = NULL,
      span = NULL,
      half_life = NULL,
      alpha = NULL,
      adjust = TRUE,
      bias = FALSE,
      min_periods = 1L,
      ignore_nulls = TRUE
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>com</code></td>
<td><p>Specify decay in terms of center of mass, <code
class="reqn">\gamma</code>, with <code
class="reqn"> \alpha = \frac{1}{1 + \gamma} \; \forall \; \gamma \geq 0 </code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>span</code></td>
<td><p>Specify decay in terms of span, <code class="reqn">\theta</code>,
with <code
class="reqn">\alpha = \frac{2}{\theta + 1} \; \forall \; \theta \geq 1 </code></p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>half_life</code></td>
<td><p>Specify decay in terms of half-life, :math:<code
style="white-space: pre;">⁠\lambda⁠</code>, with <code
class="reqn"> \alpha = 1 - \exp \left\{ \frac{ -\ln(2) }{ \lambda } \right\} </code>
<code class="reqn"> \forall \; \lambda &gt; 0</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>alpha</code></td>
<td><p>Specify smoothing factor alpha directly, <code
class="reqn">0 &lt; \alpha \leq 1</code>.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>adjust</code></td>
<td><p>Divide by decaying adjustment factor in beginning periods to
account for imbalance in relative weightings</p>
<ul>
<li><p>When <code>adjust=TRUE</code> the EW function is calculated using
weights <code class="reqn">w_i = (1 - \alpha)^i </code></p></li>
<li><p>When <code>adjust=FALSE</code> the EW function is calculated
recursively by <code
class="reqn"> y_0 = x_0 \\ y_t = (1 - \alpha)y_{t - 1} + \alpha x_t </code></p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>min_periods</code></td>
<td><p>Minimum number of observations in window required to have a value
(otherwise result is null).</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>ignore_nulls</code></td>
<td><p>ignore_nulls Ignore missing values when calculating weights.</p>
<ul>
<li><p>When <code>ignore_nulls=FALSE</code> (default), weights are based
on absolute positions. For example, the weights of
:math:<code>x_0</code> and :math:<code>x_2</code> used in calculating
the final weighted average of <code>[</code> <code
class="reqn">x_0</code>, None, <code class="reqn">x_2</code>\<code
style="white-space: pre;">⁠]⁠</code> are <code
class="reqn">1-\alpha)^2</code> and <code class="reqn">1</code> if
<code>adjust=TRUE</code>, and <code class="reqn">(1-\alpha)^2</code> and
<code class="reqn">\alpha</code> if <code>adjust=FALSE</code>.</p></li>
<li><p>When <code>ignore_nulls=TRUE</code>, weights are based on
relative positions. For example, the weights of <code
class="reqn">x_0</code> and <code class="reqn">x_2</code> used in
calculating the final weighted average of <code>[</code> <code
class="reqn">x_0</code>, None, <code class="reqn">x_2</code><code
style="white-space: pre;">⁠]⁠</code> are <code
class="reqn">1-\alpha</code> and <code class="reqn">1</code> if
<code>adjust=TRUE</code>, and <code class="reqn">1-\alpha</code> and
<code class="reqn">\alpha</code> if <code>adjust=FALSE</code>.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>bias</code></td>
<td><p>When bias=FALSE', apply a correction to make the estimate
statistically unbiased.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_mean(com=1))

pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com=1))
pl$DataFrame(a = 1:3)$select(pl$col("a")$ewm_std(com=1))
```


---
## Expr exclude

### Description

You may also use regexes in the exclude list. They must start with `^`
and end with `$`.

### Usage

    Expr_exclude(columns)

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>columns</code></td>
<td><p>given param type:</p>
<ul>
<li><p>string: exclude name of column or exclude regex starting with
^and ending with$</p></li>
<li><p>character vector: exclude all these column names, no regex
allowed</p></li>
<li><p>DataType: Exclude any of this DataType</p></li>
<li><p>List(DataType): Excldue any of these DataType(s)</p></li>
</ul></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
 #make DataFrame
 df = pl$DataFrame(iris)

 #by name(s)
 df$select(pl$all()$exclude("Species"))

 #by type
 df$select(pl$all()$exclude(pl$Categorical))
 df$select(pl$all()$exclude(list(pl$Categorical,pl$Float64)))

 #by regex
 df$select(pl$all()$exclude("^Sepal.*$"))
```


---
## Expr exp

### Description

Compute the exponential, element-wise.

### Usage

    Expr_exp

### Format

a method

### Value

Expr

### Examples

```r
log10123 = suppressWarnings(log(-1:3))
all.equal(
  pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$as_data_frame()$a,
  exp(1)^log10123
)
```


---
## Expr explode

### Description

This means that every item is expanded to a new row.

( flatten is an alias for explode )

### Usage

    Expr_explode

    Expr_flatten

### Format

a method

a method

### Details

explode/flatten does not support categorical

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=letters))$select(pl$col("a")$explode()$take(0:5))

listed_group_df =  pl$DataFrame(iris[c(1:3,51:53),])$groupby("Species")$agg(pl$all())
print(listed_group_df)
vectors_df = listed_group_df$select(
  pl$col(c("Sepal.Width","Sepal.Length"))$explode()
)
print(vectors_df)
```


---
## Expr extend constant

### Description

Extend the Series with given number of values.

### Usage

    Expr_extend_constant(value, n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>value</code></td>
<td><p>The value to extend the Series with. This value may be None to
fill with nulls.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n</code></td>
<td><p>The number of values to extend.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$UInt64, strict = FALSE)
  $extend_constant(10.1, 2)
)

pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$Utf8, strict = FALSE)
  $extend_constant("chuchu", 2)
)
```


---
## Expr extend expr

### Description

Extend the Series with a expression repeated a number of times

### Usage

    Expr_extend_expr(value, n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>value</code></td>
<td><p>The expr to extend the Series with. This value may be None to
fill with nulls.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n</code></td>
<td><p>The number of values to extend.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$UInt64, strict = FALSE)
  $extend_expr(10.1, 2)
)

pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$Utf8, strict = FALSE)
  $extend_expr("chuchu", 2)
)
```


---
## Expr fill nan

### Description

Fill missing values with last seen values.

### Usage

    Expr_fill_nan(expr = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>expr</code></td>
<td><p>Expr or into Expr, value to fill NaNs with</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
l = list(a=c(1,NaN,NaN,3))
pl$DataFrame(l)$select(
  pl$col("a")$fill_nan()$alias("fill_default"),
  pl$col("a")$fill_nan(pl$lit(NA))$alias("fill_NA"), #same as default
  pl$col("a")$fill_nan(2)$alias("fill_float2"),
  pl$col("a")$fill_nan("hej")$alias("fill_str") #implicit cast to Utf8
)$to_list()
```


---
## Expr fill null

### Description

Shift the values by value or as strategy.

### Usage

    Expr_fill_null(value = NULL, strategy = NULL, limit = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>value</code></td>
<td><p>Expr or <code style="white-space: pre;">⁠Into&lt;Expr&gt;⁠</code>
to fill Null values with</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>strategy</code></td>
<td><p>default NULL else 'forward', 'backward', 'min', 'max', 'mean',
'zero', 'one'</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>limit</code></td>
<td><p>Number of consecutive null values to fill when using the
'forward' or 'backward' strategy.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$select(
  pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
  pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
)
```


---
## Expr filter

### Description

Mostly useful in an aggregation context. If you want to filter on a
DataFrame level, use `LazyFrame.filter`.

where() is an alias for pl$filter

### Usage

    Expr_filter(predicate)

    Expr_where(predicate)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>predicate</code></td>
<td><p>Expr or something <code
style="white-space: pre;">⁠Into&lt;Expr&gt;⁠</code>. Should be a boolean
expression.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(
  group_col =  c("g1", "g1", "g2"),
  b = c(1, 2, 3)
))

df$groupby("group_col")$agg(
  pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
  pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte")
)
```


---
## Expr first

### Description

Get the first value. Similar to R head(x,1)

### Usage

    Expr_first

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$first())
```


---
## Expr floor

### Description

Rounds down to the nearest integer value. Only works on floating point
Series.

### Usage

    Expr_floor

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
  pl$col("a")$floor()
)
```


---
## Expr forward fill

### Description

Fill missing values with last seen values.

### Usage

    Expr_forward_fill(limit = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>limit</code></td>
<td><p>Expr or <code style="white-space: pre;">⁠Into&lt;Expr&gt;⁠</code>
The number of consecutive null values to forward fill.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
l = list(a=c(1L,rep(NA_integer_,3L),10))
pl$DataFrame(l)$select(
  pl$col("a")$forward_fill()$alias("ff_null"),
  pl$col("a")$forward_fill(limit = 0)$alias("ff_l0"),
  pl$col("a")$forward_fill(limit = 1)$alias("ff_l1")
)$to_list()
```


---
## Expr gt eq

### Description

gt\_eq method and operator

### Usage

    Expr_gt_eq(other)

    ## S3 method for class 'Expr'
    e1 >= e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(2) >= 2
pl$lit(2) >=  pl$lit(2)
pl$lit(2)$gt_eq(pl$lit(2))
```


---
## Expr gt

### Description

gt method and operator

### Usage

    Expr_gt(other)

    ## S3 method for class 'Expr'
    e1 > e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(2) > 1
pl$lit(2) > pl$lit(1)
pl$lit(2)$gt(pl$lit(1))
```


---
## Expr hash

### Description

Hash the elements in the selection. The hash value is of type `UInt64`.

### Usage

    Expr_hash(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>seed</code></td>
<td><p>Random seed parameter. Defaults to 0.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>seed_1</code></td>
<td><p>Random seed parameter. Defaults to arg seed.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>seed_2</code></td>
<td><p>Random seed parameter. Defaults to arg seed.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>seed_3</code></td>
<td><p>Random seed parameter. Defaults to arg seed. The column will be
coerced to UInt32. Give this dtype to make the coercion a
no-op.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(iris)
df$select(pl$all()$head(2)$hash(1234)$cast(pl$Utf8))$to_list()
```


---
## Expr head

### Description

Get the head n elements. Similar to R head(x)

### Usage

    Expr_head(n = 10)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>numeric number of elements to select from head</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#get 3 first elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$head(3))
```


---
## Expr inspect

### Description

Print the value that this expression evaluates to and pass on the value.
The printing will happen when the expression evaluates, not when it is
formed.

### Usage

    Expr_inspect(fmt = "{}")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fmt</code></td>
<td><p>format string, should contain one set of <code>{}</code> where
object will be printed This formatting mimics python "string".format()
use in pypolars. The string can contain any thing but should have
exactly one set of curly bracket .</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$select(pl$lit(1:5)$inspect(
  "before dropping half the column it was:{}and not it is dropped")$head(2)
)
```


---
## Expr interpolate

### Description

Fill nulls with linear interpolation over missing values. Can also be
used to regrid data to a new grid - see examples below.

### Usage

    Expr_interpolate(method = "linear")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>method</code></td>
<td><p>string 'linear' or 'nearest', default "linear"</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$select(pl$lit(c(1,NA,4,NA,100,NaN,150))$interpolate())

#x, y interpolation over a grid
df_original_grid = pl$DataFrame(list(
  grid_points = c(1, 3, 10),
  values = c(2.0, 6.0, 20.0)
))
df_new_grid = pl$DataFrame(list(grid_points = (1:10)*1.0))

# Interpolate from this to the new grid
df_new_grid$join(
  df_original_grid, on="grid_points", how="left"
)$with_columns(pl$col("values")$interpolate())
```


---
## Expr is between

### Description

Check if this expression is between start and end.

### Usage

    Expr_is_between(start, end, include_bounds = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>start</code></td>
<td><p>Lower bound as primitive or datetime</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>end</code></td>
<td><p>Lower bound as primitive or datetime</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>include_bounds</code></td>
<td><p>bool vector or scalar: FALSE: Exclude both start and end
(default). TRUE: Include both start and end. c(FALSE, FALSE): Exclude
start and exclude end. c(TRUE, TRUE): Include start and include end.
c(FALSE, TRUE): Exclude start and include end. c(TRUE, FALSE): Include
start and exclude end.</p></td>
</tr>
</tbody>
</table>

### Details

alias the column to 'in\_between' This function is equivalent to a
combination of &lt; &lt;= &gt;= and the &-and operator.

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(num = 1:5))
df$select(pl$col("num")$is_between(2,4))
df$select(pl$col("num")$is_between(2,4,TRUE))
df$select(pl$col("num")$is_between(2,4,c(FALSE, TRUE)))
#start end can be a vector/expr with same length as column
df$select(pl$col("num")$is_between(c(0,2,3,3,3),6))
```


---
## Expr is duplicated

### Description

Get mask of duplicated values.

### Usage

    Expr_is_duplicated

### Format

a method

### Details

is\_duplicated is the opposite of `is_unique()` Looking for R like
`duplicated()`?, use `some_expr$is_first()$is_not()`

### Value

Expr (boolean)

### Examples

```r
v = c(1,1,2,2,3,NA,NaN,Inf)
all.equal(
  pl$select(
pl$lit(v)$is_unique()$alias("is_unique"),
pl$lit(v)$is_first()$alias("is_first"),
pl$lit(v)$is_duplicated()$alias("is_duplicated"),
pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
  )$to_list(),
  list(
is_unique = !v %in% v[duplicated(v)],
is_first  = !duplicated(v),
is_duplicated = v %in% v[duplicated(v)],
R_duplicated = duplicated(v)
  )
)
```


---
## Expr is finite

### Description

Returns a boolean output indicating which values are finite.

### Usage

    Expr_is_finite

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_finite())
```


---
## Expr is first

### Description

Get a mask of the first unique value.

### Usage

    Expr_is_first

### Format

a method

### Value

Expr (boolean)

### Examples

```r
v = c(1,1,2,2,3,NA,NaN,Inf)
all.equal(
  pl$select(
pl$lit(v)$is_unique()$alias("is_unique"),
pl$lit(v)$is_first()$alias("is_first"),
pl$lit(v)$is_duplicated()$alias("is_duplicated"),
pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
  )$to_list(),
  list(
is_unique = !v %in% v[duplicated(v)],
is_first  = !duplicated(v),
is_duplicated = v %in% v[duplicated(v)],
R_duplicated = duplicated(v)
  )
)
```


---
## Expr is in

### Description

combine to boolean expresions with similar to `%in%`

### Usage

    Expr_is_in(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
#R Na_integer -> polars Null(Int32) is in polars Null(Int32)
pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(
  pl$col("a")$is_in(pl$lit(NA_real_))
)$as_data_frame()[[1L]]
```



---
## Expr is infinite

### Description

Returns a boolean output indicating which values are infinite.

### Usage

    Expr_is_infinite

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_infinite())
```


---
## Expr is nan

### Description

Returns a boolean Series indicating which values are NaN.

### Usage

    Expr_is_nan

### Format

a method

### Details

Floating point NaN's are a different flag from Null(polars) which is the
same as NA\_real\_(R). See Inf,NaN,NULL,Null/NA translations here
`docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_nan())
```


---
## Expr is not nan

### Description

Returns a boolean Series indicating which values are not NaN.

### Usage

    Expr_is_not_nan

### Format

a method

### Details

Floating point NaN's are a different flag from Null(polars) which is the
same as NA\_real\_(R).

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_not_nan())
```


---
## Expr is not null

### Description

Returns a boolean Series indicating which values are not null. Similar
to R syntax !is.na(x) null polars about the same as R NA

### Usage

    Expr_is_not_null

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_not_null())
```


---
## Expr is not

### Description

not method and operator

### Usage

    Expr_is_not(other)

    ## S3 method for class 'Expr'
    !x

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Exprs

### Examples

```r
#two syntaxes same result
pl$lit(TRUE)$is_not()
!pl$lit(TRUE)
```


---
## Expr is null

### Description

Returns a boolean Series indicating which values are null. Similar to R
syntax is.na(x) null polars about the same as R NA

### Usage

    Expr_is_null

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_null())
```


---
## Expr is unique

### Description

Get mask of unique values

### Usage

    Expr_is_unique

### Format

a method

### Value

Expr (boolean)

### Examples

```r
v = c(1,1,2,2,3,NA,NaN,Inf)
all.equal(
  pl$select(
pl$lit(v)$is_unique()$alias("is_unique"),
pl$lit(v)$is_first()$alias("is_first"),
pl$lit(v)$is_duplicated()$alias("is_duplicated"),
pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
  )$to_list(),
  list(
is_unique = !v %in% v[duplicated(v)],
is_first  = !duplicated(v),
is_duplicated = v %in% v[duplicated(v)],
R_duplicated = duplicated(v)
  )
)
```


---
## Expr keep name

### Description

Keep the original root name of the expression.

### Usage

    Expr_keep_name

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=1:3))$select(pl$col("alice")$alias("bob")$keep_name())
```


---
## Expr kurtosis

### Description

Compute the kurtosis (Fisher or Pearson) of a dataset.

### Usage

    Expr_kurtosis(fisher = TRUE, bias = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fisher</code></td>
<td><p>bool se details</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>bias</code></td>
<td><p>bool, If FALSE, then the calculations are corrected for
statistical bias.</p></td>
</tr>
</tbody>
</table>

### Details

Kurtosis is the fourth central moment divided by the square of the
variance. If Fisher's definition is used, then 3.0 is subtracted from
the result to give 0.0 for a normal distribution. If bias is False then
the kurtosis is calculated using k statistics to eliminate bias coming
from biased moment estimators See scipy.stats for more information

\#' See scipy.stats for more information.

### Value

Expr

### References

https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.kurtosis.html?highlight=kurtosis

### Examples

```r
df = pl$DataFrame(list( a=c(1:3,2:1)))
df$select(pl$col("a")$kurtosis())
```


---
## Expr last

### Description

Get the lastvalue. Similar to R syntax tail(x,1)

### Usage

    Expr_last

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$last())
```


---
## Expr limit

### Description

Alias for Head Get the head n elements. Similar to R head(x)

### Usage

    Expr_limit(n = 10)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>numeric number of elements to select from head</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#get 3 first elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$limit(3))
```


---
## Expr list

### Description

Aggregate to list.

### Usage

    Expr_list

### Format

a method

### Details

use to\_struct to wrap a DataFrame

### Value

Expr

### Examples

```r
pl$select(pl$lit(1:4)$list(), pl$lit(c("a")))
```


---
## Expr lit to df

### Description

collect an expression based on literals into a DataFrame

### Usage

    Expr_lit_to_df()

### Value

Series

### Examples

```r
(
  pl$Series(list(1:1, 1:2, 1:3, 1:4))
  $print()
  $to_lit()
$arr$lengths()
$sum()
$cast(pl$dtypes$Int8)
  $lit_to_df()
)
```


---
## Expr lit to s

### Description

collect an expression based on literals into a Series

### Usage

    Expr_lit_to_s()

### Value

Series

### Examples

```r
(
  pl$Series(list(1:1, 1:2, 1:3, 1:4))
  $print()
  $to_lit()
$arr$lengths()
$sum()
$cast(pl$dtypes$Int8)
  $lit_to_s()
)
```


---
## Expr log

### Description

Compute the base x logarithm of the input array, element-wise.

### Usage

    Expr_log(base = base::exp(1))

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>base</code></td>
<td><p>numeric base value for log, default base::exp(1)</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())
```


---
## Expr log10

### Description

Compute the base 10 logarithm of the input array, element-wise.

### Usage

    Expr_log10

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())
```


---
## Expr lt eq

### Description

lt\_eq method and operator

### Usage

    Expr_lt_eq(other)

    ## S3 method for class 'Expr'
    e1 <= e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(2) <= 2
pl$lit(2) <=  pl$lit(2)
pl$lit(2)$lt_eq(pl$lit(2))
```


---
## Expr lt

### Description

lt method and operator

### Usage

    Expr_lt(other)

    ## S3 method for class 'Expr'
    e1 < e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(5) < 10
pl$lit(5) < pl$lit(10)
pl$lit(5)$lt(pl$lit(10))
```


---
## Expr map alias

### Description

Rename the output of an expression by mapping a function over the root
name.

### Usage

    Expr_map_alias(fun)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fun</code></td>
<td><p>an R function which takes a string as input and return a
string</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(list(alice=1:3))$select(
  pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob"))
)
```


---
## Expr map

### Description

Expr\_map

### Usage

    Expr_map(f, output_type = NULL, agg_list = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>f</code></td>
<td><p>a function mapping a series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>output_type</code></td>
<td><p>NULL or one of pl$dtypes$..., the output datatype, NULL is the
same as input.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>agg_list</code></td>
<td><p>Aggregate list. Map from vector to group in groupby context.
Likely not so useful.</p></td>
</tr>
</tbody>
</table>

### Details

user function return should be a series or any Robj convertable into a
Series. In PyPolars likely return must be Series. User functions do
fully support `browser()`, helpful to investigate.

### Value

Expr

### Examples

```r
pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(x) {
  paste("cheese",as.character(x$to_r_vector()))
}, pl$dtypes$Utf8))
```


---
## Expr max

### Description

Get maximum value.

### Usage

    Expr_max

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$max() == 3) #is true
```


---
## Expr mean

### Description

Get mean value.

### Usage

    Expr_mean

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$mean()==2) #is true
```


---
## Expr median

### Description

Get median value.

### Usage

    Expr_median

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,2)))$select(pl$col("x")$median()==1.5) #is true
```


---
## Expr meta

### Description

Create an object namespace of all meta related methods. See the
individual method pages for full details

### Usage

    Expr_meta()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr min

### Description

Get minimum value.

### Usage

    Expr_min

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$min()== 1 ) #is true
```


---
## Expr mode

### Description

Compute the most occurring value(s). Can return multiple Values.

### Usage

    Expr_mode

### Format

a method

### Value

Expr

### Examples

```r
df =pl$DataFrame(list(a=1:6,b = c(1L,1L,3L,3L,5L,6L), c = c(1L,1L,2L,2L,3L,3L)))
df$select(pl$col("a")$mode())
df$select(pl$col("b")$mode())
df$select(pl$col("c")$mode())
```


---
## Expr mul

### Description

Multiplication

### Usage

    Expr_mul(other)

    ## S3 method for class 'Expr'
    e1 * e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Value

Exprs

### Examples

```r
#three syntaxes same result
pl$lit(5) * 10
pl$lit(5) * pl$lit(10)
pl$lit(5)$mul(pl$lit(10))
```


---
## Expr n unique

### Description

Count number of unique values. Similar to R length(unique(x))

### Usage

    Expr_n_unique

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$n_unique())
```


---
## Expr nan max

### Description

Get maximum value, but propagate/poison encountered `NaN` values. Get
maximum value.

### Usage

    Expr_nan_max

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NaN,Inf,3)))$select(pl$col("x")$nan_max()$is_nan()) #is true
```


---
## Expr nan min

### Description

Get minimum value, but propagate/poison encountered `NaN` values.

### Usage

    Expr_nan_min

### Format

An object of class `character` of length 1.

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,NaN,-Inf,3)))$select(pl$col("x")$nan_min()$is_nan()) #is true
```


---
## Expr neq

### Description

neq method and operator

### Usage

    Expr_neq(other)

    ## S3 method for class 'Expr'
    e1 != e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Exprs

### Examples

```r
#' #three syntaxes same result
pl$lit(1) != 2
pl$lit(1) !=  pl$lit(2)
pl$lit(1)$neq(pl$lit(2))
```


---
## Expr null count

### Description

Count `Nulls`

### Usage

    Expr_null_count

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$select(pl$lit(c(NA,"a",NA,"b"))$null_count())
```


---
## Expr or

### Description

combine to boolean expresions with OR

### Usage

    Expr_or(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Expr or into Expr</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$lit(TRUE) | FALSE
pl$lit(TRUE)$or(pl$lit(TRUE))
```


---
## Expr over

### Description

Apply window function over a subgroup. This is similar to a groupby +
aggregation + self join. Or similar to
`⁠window functions in Postgres <https://www.postgresql.org/docs/current/tutorial-window.html>⁠`\_.

### Usage

    Expr_over(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>of strings or columns to group by</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(
  val = 1:5,
  a = c("+","+","-","-","+"),
  b = c("+","-","+","-","+")
)$select(
  pl$col("val")$count()$over("a","b")
)
```


---
## Expr pct change

### Description

Computes percentage change between values. Percentage change (as
fraction) between current element and most-recent non-null element at
least `n` period(s) before the current element. Computes the change from
the previous row by default.

### Usage

    Expr_pct_change(n = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>periods to shift for forming percent change.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(list( a=c(10L, 11L, 12L, NA_integer_, 12L)))
df$with_column(pl$col("a")$pct_change()$alias("pct_change"))
```


---
## Expr pow

### Description

Raise expression to the power of exponent.

### Usage

    Expr_pow(exponent)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>exponent</code></td>
<td><p>exponent</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(a= -1:3)$select(
  pl$lit(2)$pow(pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)

pl$DataFrame(a = -1:3)$select(
  pl$lit(2) ^ (pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)
```


---
## Expr product

### Description

Compute the product of an expression.

### Usage

    Expr_product

### Format

An object of class `character` of length 1.

### Details

does not support integer32 currently, .cast() to f64 or i64 first.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$product()==6) #is true
```


---
## Expr quantile

### Description

Get quantile value.

### Usage

    Expr_quantile(quantile, interpolation = "nearest")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>quantile</code></td>
<td><p>numeric/Expression 0.0 to 1.0</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>interpolation</code></td>
<td><p>string value from choices "nearest", "higher", "lower",
"midpoint", "linear"</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

`Nulls` are ignored and `NaNs` are ranked as the largest value. For
linear interpolation `NaN` poisons `Inf`, that poisons any other value.

### Value

Expr

### Examples

```r
pl$select(pl$lit(-5:5)$quantile(.5))
```


---
## Expr rank

### Description

Assign ranks to data, dealing with ties appropriately.

### Usage

    Expr_rank(method = "average", reverse = FALSE)

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>method</code></td>
<td><p>string option 'average', 'min', 'max', 'dense', 'ordinal',
'random'</p>
<p>#' The method used to assign ranks to tied elements. The following
methods are available (default is 'average'):</p>
<ul>
<li><p>'average' : The average of the ranks that would have been
assigned to all the tied values is assigned to each value.</p></li>
<li><p>'min' : The minimum of the ranks that would have been assigned to
all the tied values is assigned to each value. (This is also referred to
as "competition" ranking.)</p></li>
<li><p>'max' : The maximum of the ranks that would have been assigned to
all the tied values is assigned to each value.</p></li>
<li><p>'dense' : Like 'min', but the rank of the next highest element is
assigned the rank immediately after those assigned to the tied
elements.</p></li>
<li><p>'ordinal' : All values are given a distinct rank, corresponding
to the order that the values occur in the Series.</p></li>
<li><p>'random' : Like 'ordinal', but the rank for ties is not dependent
on the order that the values occur in the Series.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, reverse the operation</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#  The 'average' method:
df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
df$select(pl$col("a")$rank())

#  The 'ordinal' method:
df = pl$DataFrame(list(a = c(3, 6, 1, 1, 6)))
df$select(pl$col("a")$rank("ordinal"))
```


---
## Expr rechunk

### Description

Create a single chunk of memory for this Series.

### Usage

    Expr_rechunk

### Format

a method

### Details

See rechunk() explained here `docs_translations`

### Value

Expr

### Examples

```r
#get chunked lengths with/without rechunk
series_list = pl$DataFrame(list(a=1:3,b=4:6))$select(
  pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
  pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
)$get_columns()
lapply(series_list, \(x) x$chunk_lengths())
```


---
## Expr reinterpret

### Description

Reinterpret the underlying bits as a signed/unsigned integer. This
operation is only allowed for 64bit integers. For lower bits integers,
you can safely use that cast operation.

### Usage

    Expr_reinterpret(signed = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>signed</code></td>
<td><p>bool reinterpret into Int64 else UInt64</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(iris)
df$select(pl$all()$head(2)$hash(1,2,3,4)$reinterpret())$as_data_frame()
```


---
## Expr rep extend

### Description

Extend a series with a repeated series or value.

### Usage

    Expr_rep_extend(expr, n, rechunk = TRUE, upcast = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>expr</code></td>
<td><p>Expr or into Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n</code></td>
<td><p>Numeric the number of times to repeat, must be non-negative and
finite</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool default = TRUE, if true memory layout will be
rewritten</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>upcast</code></td>
<td><p>bool default = TRUE, passed to self$append(), if TRUE non
identical types will be casted to common super type if any. If FALSE or
no common super type throw error.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$select(pl$lit(c(1,2,3))$rep_extend(1:3, n = 5))
```


---
## Expr rep

### Description

This expression takes input and repeats it n times and append chunk

### Usage

    Expr_rep(n, rechunk = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Numeric the number of times to repeat, must be non-negative and
finite</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool default = TRUE, if true memory layout will be
rewritten</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Details

if self$len() == 1 , has a special faster implementation, Here rechunk
is not necessary, and takes no effect.

if self$len() &gt; 1 , then the expression instructs the series to
append onto itself n time and rewrite memory

### Value

Expr

### Examples

```r
pl$select(
  pl$lit("alice")$rep(n = 3)
)

pl$select(
  pl$lit(1:3)$rep(n = 2)
)
```


---
## Expr repeat by

### Description

Repeat the elements in this Series as specified in the given expression.
The repeated elements are expanded into a `List`.

### Usage

    Expr_repeat_by(by)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>Expr Numeric column that determines how often the values will be
repeated. The column will be coerced to UInt32. Give this dtype to make
the coercion a no-op.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(a = c("x","y","z"), n = c(0:2)))
df$select(pl$col("a")$repeat_by("n"))
```


---
## Expr reshape

### Description

Reshape this Expr to a flat Series or a Series of Lists.

### Usage

    Expr_reshape(dims)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>dims</code></td>
<td><p>numeric vec of the dimension sizes. If a -1 is used in any of the
dimensions, that dimension is inferred.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$select(pl$lit(1:12)$reshape(c(3,4)))
pl$select(pl$lit(1:12)$reshape(c(3,-1)))
```


---
## Expr rolling max

### Description

Apply a rolling max (moving max) over the values in this array. A window
of length `window_size` will traverse the array. The values that fill
this window will (optionally) be multiplied with the weights given by
the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_max(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_max(window_size = 2))
```


---
## Expr rolling mean

### Description

Apply a rolling mean (moving mean) over the values in this array. A
window of length `window_size` will traverse the array. The values that
fill this window will (optionally) be multiplied with the weights given
by the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_mean(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_mean(window_size = 2))
```


---
## Expr rolling median

### Description

Apply a rolling median (moving median) over the values in this array. A
window of length `window_size` will traverse the array. The values that
fill this window will (optionally) be multiplied with the weights given
by the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_median(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_median(window_size = 2))
```


---
## Expr rolling min

### Description

Apply a rolling min (moving min) over the values in this array. A window
of length `window_size` will traverse the array. The values that fill
this window will (optionally) be multiplied with the weights given by
the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_min(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_min(window_size = 2))
```


---
## Expr rolling quantile

### Description

Apply a rolling quantile (moving quantile) over the values in this
array. A window of length `window_size` will traverse the array. The
values that fill this window will (optionally) be multiplied with the
weights given by the `weight` vector. The resulting values will be
aggregated to their sum.

### Usage

    Expr_rolling_quantile(
      quantile,
      interpolation = "nearest",
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>quantile</code></td>
<td><p>Quantile between 0.0 and 1.0.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>interpolation</code></td>
<td><p>choice c('nearest', 'higher', 'lower', 'midpoint',
'linear')</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(
  pl$col("a")$rolling_quantile(window_size = 2, quantile = .5)
)
```


---
## Expr rolling skew

### Description

Compute a rolling skew.

### Usage

    Expr_rolling_skew(window_size, bias = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>integerish, Size of the rolling window</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>bias</code></td>
<td><p>bool default = TRUE, If False, then the calculations are
corrected for statistical bias.</p></td>
</tr>
</tbody>
</table>

### Details

Extra comments copied from rust-polars\_0.25.1 Compute the sample
skewness of a data set.

For normally distributed data, the skewness should be about zero. For
uni-modal continuous distributions, a skewness value greater than zero
means that there is more weight in the right tail of the distribution.
The function `skewtest` can be used to determine if the skewness value
is close enough to zero, statistically speaking. see:
https://github.com/scipy/scipy/blob/47bb6febaa10658c72962b9615d5d5aa2513fa3a/scipy/stats/stats.py#L1024

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=iris$Sepal.Length))$select(pl$col("a")$rolling_skew(window_size = 4 )$head(10))
```


---
## Expr rolling std

### Description

Apply a rolling std (moving std) over the values in this array. A window
of length `window_size` will traverse the array. The values that fill
this window will (optionally) be multiplied with the weights given by
the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_std(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_std(window_size = 2))
```


---
## Expr rolling sum

### Description

Apply a rolling sum (moving sum) over the values in this array. A window
of length `window_size` will traverse the array. The values that fill
this window will (optionally) be multiplied with the weights given by
the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_sum(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_sum(window_size = 2))
```


---
## Expr rolling var

### Description

Apply a rolling var (moving var) over the values in this array. A window
of length `window_size` will traverse the array. The values that fill
this window will (optionally) be multiplied with the weights given by
the `weight` vector. The resulting values will be aggregated to their
sum.

### Usage

    Expr_rolling_var(
      window_size,
      weights = NULL,
      min_periods = NULL,
      center = FALSE,
      by = NULL,
      closed = "left"
    )

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>window_size</code></td>
<td><p>The length of the window. Can be a fixed integer size, or a
dynamic temporal size indicated by the following string language:</p>
<ul>
<li><p>1ns (1 nanosecond)</p></li>
<li><p>1us (1 microsecond)</p></li>
<li><p>1ms (1 millisecond)</p></li>
<li><p>1s (1 second)</p></li>
<li><p>1m (1 minute)</p></li>
<li><p>1h (1 hour)</p></li>
<li><p>1d (1 day)</p></li>
<li><p>1w (1 week)</p></li>
<li><p>1mo (1 calendar month)</p></li>
<li><p>1y (1 calendar year)</p></li>
<li><p>1i (1 index count) If the dynamic string language is used, the
<code>by</code> and <code>closed</code> arguments must also be
set.</p></li>
</ul></td>
</tr>
<tr class="even" data-valign="top">
<td><code>weights</code></td>
<td><p>An optional slice with the same length as the window that will be
multiplied elementwise with the values in the window.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>min_periods</code></td>
<td><p>The number of values in the window that should be non-null before
computing a result. If None, it will be set equal to window
size.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>center</code></td>
<td><p>Set the labels at the center of the window</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>If the <code>window_size</code> is temporal for instance
<code>"5h"</code> or <code style="white-space: pre;">⁠"3s⁠</code>, you
must set the column that will be used to determine the windows. This
column must be of dtype <code
style="white-space: pre;">⁠{Date, Datetime}⁠</code></p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>closed</code></td>
<td><p>: 'left', 'right', 'both', 'none' Define whether the temporal
window interval is closed or not.</p></td>
</tr>
</tbody>
</table>

### Details

This functionality is experimental and may change without it being
considered a breaking change. Notes: If you want to compute multiple
aggregation statistics over the same dynamic window, consider using
`groupby_rolling` this method can cache the window size computation.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=1:6))$select(pl$col("a")$rolling_var(window_size = 2))
```


---
## Expr round

### Description

Round underlying floating point data by `decimals` digits.

### Usage

    Expr_round(decimals)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>decimals</code></td>
<td><p>integer Number of decimals to round by.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
  pl$col("a")$round(0)
)
```


---
## Expr rpow

### Description

Raise a base to the power of the expression as exponent.

### Usage

    Expr_rpow(base)

    e1 %**% e2

    `%**%.Expr`(e1, e2)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>base</code></td>
<td><p>real or Expr, the value of the base, self is the
exponent</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>value where ** operator is defined</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>value where ** operator is defined</p></td>
</tr>
</tbody>
</table>

### Details

do not use `⁠**⁠`, R secretly parses that just as if it was a `^`

### Value

Expr

### Examples

```r
pl$DataFrame(list(a = -1:3))$select(
  pl$lit(2)$rpow(pl$col("a"))
)$get_column("a")$to_r() ==  (-1:3)^2

pl$DataFrame(list(a = -1:3))$select(
  pl$lit(2) %**% (pl$col("a"))
)$get_column("a")$to_r() ==  (-1:3)^2
```


---
## Expr sample

### Description

\#' Sample from this expression.

### Usage

    Expr_sample(
      frac = NULL,
      with_replacement = TRUE,
      shuffle = FALSE,
      seed = NULL,
      n = NULL
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>frac</code></td>
<td><p>Fraction of items to return. Cannot be used with
<code>n</code>.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>with_replacement</code></td>
<td><p>Allow values to be sampled more than once.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>shuffle</code></td>
<td><p>Shuffle the order of sampled data points. (implicitly TRUE if,
with_replacement = TRUE)</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>seed</code></td>
<td><p>Seed for the random number generator. If set to None (default), a
random seed is used.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>Number of items to return. Cannot be used with
<code>frac</code>.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
df = pl$DataFrame(a=1:3)
df$select(pl$col("a")$sample(frac=1,with_replacement=TRUE,seed=1L))

df$select(pl$col("a")$sample(frac=2,with_replacement=TRUE,seed=1L))

df$select(pl$col("a")$sample(n=2,with_replacement=FALSE,seed=1L))
```


---
## Expr search sorted

### Description

Find indices in self where elements should be inserted into to maintain
order.

### Usage

    Expr_search_sorted(element)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>element</code></td>
<td><p>a R value into literal or an expression of an element</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

This function look up where to insert element if to keep self column
sorted. It is assumed the self column is already sorted ascending,
otherwise wrongs answers. This function is a bit under documented in
py-polars.

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))
```


---
## Expr set sorted

### Description

Flags the expression as 'sorted'.

### Usage

    Expr_set_sorted(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool if TRUE Descending else Ascending</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#correct use flag something correctly as ascendingly sorted
s = pl$select(pl$lit(1:4)$set_sorted()$alias("a"))$get_column("a")
s$flags # see flags

#incorrect use, flag somthing as not sorted ascendingly
s2 = pl$select(pl$lit(c(1,3,2,4))$set_sorted()$alias("a"))$get_column("a")
s2$sort() #sorting skipped, although not actually sorted
```


---
## Expr shift and fill

### Description

Shift the values by a given period and fill the resulting null values.

### Usage

    Expr_shift_and_fill(periods, fill_value)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>periods</code></td>
<td><p>numeric number of periods to shift, may be negative.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>fill_value</code></td>
<td><p>Fill None values with the result of this expression.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$select(
  pl$lit(0:3),
  pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
  pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
)
```


---
## Expr shift

### Description

Shift values

### Usage

    Expr_shift(periods)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>periods</code></td>
<td><p>numeric number of periods to shift, may be negative.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$select(
  pl$lit(0:3)$shift(-2)$alias("shift-2"),
  pl$lit(0:3)$shift(2)$alias("shift+2")
)
```


---
## Expr shrink dtype

### Description

Shrink numeric columns to the minimal required datatype. Shrink to the
dtype needed to fit the extrema of this `⁠[Series]⁠`. This can be used to
reduce memory pressure.

### Usage

    Expr_shrink_dtype

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
 pl$DataFrame(
   a= c(1L, 2L, 3L),
   b= c(1L, 2L, bitwShiftL(2L,29)),
   c= c(-1L, 2L, bitwShiftL(1L,15)),
   d= c(-112L, 2L, 112L),
   e= c(-112L, 2L, 129L),
   f= c("a", "b", "c"),
   g= c(0.1, 1.32, 0.12),
   h= c(TRUE, NA, FALSE)
 )$with_column( pl$col("b")$cast(pl$Int64) *32L
 )$select(pl$all()$shrink_dtype())
```


---
## Expr shuffle

### Description

Shuffle the contents of this expr.

### Usage

    Expr_shuffle(seed = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>seed</code></td>
<td><p>numeric value of 0 to 2^52 Seed for the random number generator.
If set to Null (default), a random seed value intergish value between 0
and 10000 is picked</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
pl$DataFrame(a = 1:3)$select(pl$col("a")$shuffle(seed=1))
```


---
## Expr sign

### Description

Compute the element-wise indication of the sign.

### Usage

    Expr_sign

### Format

Method

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(.9,-0,0,4,NA_real_))$select(pl$col("a")$sign())
```


---
## Expr sin

### Description

Compute the element-wise value for the sine.

### Usage

    Expr_sin

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$sin())
```


---
## Expr sinh

### Description

Compute the element-wise value for the hyperbolic sine.

### Usage

    Expr_sinh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,asinh(0.5),0,1,NA_real_))$select(pl$col("a")$sinh())
```


---
## Expr skew

### Description

Compute the sample skewness of a data set.

### Usage

    Expr_skew(bias = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>bias</code></td>
<td><p>If False, then the calculations are corrected for statistical
bias.</p></td>
</tr>
</tbody>
</table>

### Details

For normally distributed data, the skewness should be about zero. For
unimodal continuous distributions, a skewness value greater than zero
means that there is more weight in the right tail of the distribution.
The function `skewtest` can be used to determine if the skewness value
is close enough to zero, statistically speaking.

See scipy.stats for more information.

#### Notes

The sample skewness is computed as the Fisher-Pearson coefficient of
skewness, i.e.

` g_1=\frac{m_3}{m_2^{3/2}}`

where

` m_i=\frac{1}{N}\sum_{n=1}^N(x[n]-\bar{x})^i`

is the biased sample :math:`⁠i\texttt{th}⁠` central moment, and `\bar{x}`
is the sample mean. If `bias` is False, the calculations are corrected
for bias and the value computed is the adjusted Fisher-Pearson
standardized moment coefficient, i.e.

` G_1 = \frac{k_3}{k_2^{3/2}} = \frac{\sqrt{N(N-1)}}{N-2}\frac{m_3}{m_2^{3/2}}`

### Value

Expr

### References

https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.skew.html?highlight=skew#scipy.stats.skew

### Examples

```r
df = pl$DataFrame(list( a=c(1:3,2:1)))
df$select(pl$col("a")$skew())
```


---
## Expr slice

### Description

Get a slice of this expression.

### Usage

    Expr_slice(offset, length = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>offset</code></td>
<td><p>numeric or expression, zero-indexed where to start slice negative
value indicate starting (one-indexed) from back</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>length</code></td>
<td><p>how many elements should slice contain, default NULL is max
length</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
#as head
pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(0,6)
)

#as tail
pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(-6,6)
)

pl$DataFrame(list(a=0:100))$select(
  pl$all()$slice(80)
)
```


---
## Expr sort by

### Description

Sort this column by the ordering of another column, or multiple other
columns.

### Usage

    Expr_sort_by(by, reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>one expression or list expressions and/or strings(interpreted as
column names)</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>reverse</code></td>
<td><p>single bool to boolean vector, any is_TRUE will give reverse
sorting of that column</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

In projection/ selection context the whole column is sorted. If used in
a groupby context, the groups are sorted.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
df = pl$DataFrame(list(
  group = c("a","a","a","b","b","b"),
  value1 = c(98,1,3,2,99,100),
  value2 = c("d","f","b","e","c","a")
))

# by one column/expression
df$select(
  pl$col("group")$sort_by("value1")
)

# by two columns/expressions
df$select(
  pl$col("group")$sort_by(list("value2",pl$col("value1")), reverse =c(TRUE,FALSE))
)


# by some expression
df$select(
  pl$col("group")$sort_by(pl$col("value1")$sort(reverse=TRUE))
)

#quite similar usecase as R function `order()`
l = list(
  ab = c(rep("a",6),rep("b",6)),
  v4 = rep(1:4, 3),
  v3 = rep(1:3, 4),
  v2 = rep(1:2,6),
  v1 = 1:12
)
df = pl$DataFrame(l)


#examples of order versus sort_by
all.equal(
  df$select(
pl$col("ab")$sort_by("v4")$alias("ab4"),
pl$col("ab")$sort_by("v3")$alias("ab3"),
pl$col("ab")$sort_by("v2")$alias("ab2"),
pl$col("ab")$sort_by("v1")$alias("ab1"),
pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=c(FALSE,TRUE))$alias("ab13FT"),
pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=TRUE)$alias("ab13T")
  )$to_list(),
  list(
ab4 = l$ab[order(l$v4)],
ab3 = l$ab[order(l$v3)],
ab2 = l$ab[order(l$v2)],
ab1 = l$ab[order(l$v1)],
ab13FT= l$ab[order(l$v3,rev(l$v1))],
ab13T = l$ab[order(l$v3,l$v1,decreasing= TRUE)]
  )
)
```


---
## Expr sort

### Description

Sort this column. In projection/ selection context the whole column is
sorted. If used in a groupby context, the groups are sorted.

### Usage

    Expr_sort(reverse = FALSE, nulls_last = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool default FALSE, reverses sort</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>nulls_last</code></td>
<td><p>bool, default FALSE, place Nulls last</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$sort())
```


---
## Expr sqrt

### Description

Compute the square root of the elements.

### Usage

    Expr_sqrt()

### Value

Expr

### Examples

```r
pl$DataFrame(list(a = -1:3))$select(pl$col("a")$sqrt())
```


---
## Expr std

### Description

Get Standard Deviation

### Usage

    Expr_std(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer in range <code style="white-space: pre;">⁠[0;255]⁠</code>
degrees of freedom</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr (f64 scalar)

### Examples

```r
pl$select(pl$lit(1:5)$std())
```


---
## Expr str

### Description

Create an object namespace of all string related methods. See the
individual method pages for full details

### Usage

    Expr_str()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr struct

### Description

Create an object namespace of all struct related methods. See the
individual method pages for full details

### Usage

    Expr_struct()

### Value

Expr

### Examples

```r
#missing
```


---
## Expr sub

### Description

Substract

### Usage

    Expr_sub(other)

    ## S3 method for class 'Expr'
    e1 - e2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>e1</code></td>
<td><p>lhs Expr</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>e2</code></td>
<td><p>rhs Expr or anything which can become a literal
Expression</p></td>
</tr>
</tbody>
</table>

### Value

Exprs

### Examples

```r
#three syntaxes same result
pl$lit(5) - 10
pl$lit(5) - pl$lit(10)
pl$lit(5)$sub(pl$lit(10))
-pl$lit(5)
```


---
## Expr sum

### Description

Get sum value

### Usage

    Expr_sum

### Format

An object of class `character` of length 1.

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

### Value

Expr

### Examples

```r
pl$DataFrame(list(x=c(1L,NA,2L)))$select(pl$col("x")$sum())#is i32 3 (Int32 not casted)
```


---
## Expr tail

### Description

Get the tail n elements. Similar to R tail(x)

### Usage

    Expr_tail(n = 10)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>numeric number of elements to select from tail</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#get 3 last elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$tail(3))
```


---
## Expr take every

### Description

Take every nth value in the Series and return as a new Series.

### Usage

    Expr_take_every(n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>positive integerish value</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr

### Examples

```r
pl$DataFrame(list(a=0:24))$select(pl$col("a")$take_every(6))
```


---
## Expr take

### Description

Take values by index.

### Usage

    Expr_take(indices)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>indices</code></td>
<td><p>R scalar/vector or Series, or Expr that leads to a UInt32 dtyped
Series.</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

similar to R indexing syntax e.g. `letters[c(1,3,5)]`, however as an
expression, not as eager computation exceeding

### Value

Expr

### Examples

```r
pl$select( pl$lit(0:10)$take(c(1,8,0,7)))
```


---
## Expr tan

### Description

Compute the element-wise value for the tangent.

### Usage

    Expr_tan

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$tan())
```


---
## Expr tanh

### Description

Compute the element-wise value for the hyperbolic tangent.

### Usage

    Expr_tanh

### Format

Method

### Details

Evaluated Series has dtype Float64

### Value

Expr

### Examples

```r
pl$DataFrame(a=c(-1,atanh(0.5),0,1,NA_real_))$select(pl$col("a")$tanh())
```


---
## Expr to physical

### Description

expression request underlying physical base representation

### Usage

    Expr_to_physical

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$DataFrame(
  list(vals = c("a", "x", NA, "a"))
)$with_columns(
  pl$col("vals")$cast(pl$Categorical),
  pl$col("vals")
$cast(pl$Categorical)
$to_physical()
$alias("vals_physical")
)
```


---
## Expr to r

### Description

debug an expression by evaluating in empty DataFrame and return first
series to R

### Usage

    Expr_to_r(df = NULL, i = 0)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>df</code></td>
<td><p>otherwise a DataFrame to evaluate in, default NULL is an empty
DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>i</code></td>
<td><p>numeric column to extract zero index default first, expression
could generate multiple columns</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

R object

### Examples

```r
pl$lit(1:3)$to_r()
pl$expr_to_r(pl$lit(1:3))
pl$expr_to_r(1:3)
```


---
## Expr to struct

### Description

pass expr to pl$struct

### Usage

    Expr_to_struct()

### Value

Expr

### Examples

```r
e = pl$all()$to_struct()$alias("my_struct")
print(e)
pl$DataFrame(iris)$select(e)
```


---
## Expr top k

### Description

Return the `k` largest elements. If 'reverse=True' the smallest elements
will be given.

### Usage

    Expr_top_k(k, reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>k</code></td>
<td><p>numeric k top values to get</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool if true then k smallest values</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Details

This has time complexity: ` O(n + k \\log{}n - \frac{k}{2}) `

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

### Value

Expr

### Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$top_k(5))
```


---
## Expr unique counts

### Description

Return a count of the unique values in the order of appearance. This
method differs from `value_counts` in that it does not return the
values, only the counts and might be faster

### Usage

    Expr_unique_counts

### Format

Method

### Value

Expr

### Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$unique_counts())
```


---
## Expr unique

### Description

Get unique values of this expression. Similar to R unique()

### Usage

    Expr_unique(maintain_order = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>maintain_order</code></td>
<td><p>bool, if TRUE guranteed same order, if FALSE maybe</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$unique())
```


---
## Expr upper lower bound

### Description

Calculate the upper/lower bound. Returns a unit Series with the highest
value possible for the dtype of this expression.

### Usage

    Expr_upper_bound

    Expr_lower_bound

### Format

Method

Method

### Details

Notice lower bound i32 exported to R is NA\_integer\_ for now

### Value

Expr

### Examples

```r
pl$DataFrame(i32=1L,f64=1)$select(pl$all()$upper_bound())
pl$DataFrame(i32=1L,f64=1)$select(pl$all()$lower_bound())
```


---
## Expr value counts

### Description

Count all unique values and create a struct mapping value to count.

### Usage

    Expr_value_counts(multithreaded = FALSE, sort = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>multithreaded</code></td>
<td><p>Better to turn this off in the aggregation context, as it can
lead to contention.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>sort</code></td>
<td><p>Ensure the output is sorted from most values to least.</p></td>
</tr>
</tbody>
</table>

### Format

Method

### Value

Expr

### Examples

```r
df = pl$DataFrame(iris)$select(pl$col("Species")$value_counts())
df
df$unnest()$as_data_frame() #recommended to unnest structs before converting to R
```


---
## Expr var

### Description

Get Variance

### Usage

    Expr_var(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer in range <code style="white-space: pre;">⁠[0;255]⁠</code>
degrees of freedom</p></td>
</tr>
</tbody>
</table>

### Format

a method

### Value

Expr (f64 scalar)

### Examples

```r
pl$select(pl$lit(1:5)$var())
```


---
## Expr xor

### Description

combine to boolean expresions with XOR

### Usage

    Expr_xor(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>literal or Robj which can become a literal</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Expr

### Examples

```r
pl$lit(TRUE)$xor(pl$lit(FALSE))
```


---
## Expr-cash-print-open-paren-close-paren

### Description

internal method print Expr

### Usage

    Expr_print()

### Examples

```r
pl$DataFrame(iris)
```


---
## Expr

### Description

Polars pl$Expr

### Usage

    Expr_lit(x)

    Expr_suffix(suffix)

    Expr_prefix(prefix)

    Expr_reverse()

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>an R Scalar, or R vector/list (via Series) into Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>suffix</code></td>
<td><p>string suffix to be added to a name</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>prefix</code></td>
<td><p>string suffix to be added to a name</p></td>
</tr>
</tbody>
</table>

### Details

pl$lit(NULL) translates into a typeless polars Null

### Value

Expr, literal of that value

Expr

Expr

Expr

### Examples

```r
2+2
#Expr has the following methods/constructors
ls(polars:::Expr)

pl$col("this_column")$sum()$over("that_column")
#scalars to literal, explit `pl$lit(42)` implicit `+ 2`
pl$col("some_column") / pl$lit(42) + 2

#vector to literal explicitly via Series and back again
#R vector to expression and back again
pl$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]]

#r vecot to literal and back r vector
pl$lit(1:4)$to_r()

#r vector to literal to dataframe
pl$select(pl$lit(1:4))

#r vector to literal to Series
pl$lit(1:4)$lit_to_s()

#vectors to literal implicitly
(pl$lit(2) + 1:4 ) / 4:1
pl$col("some")$suffix("_column")
pl$col("some")$suffix("_column")
pl$DataFrame(list(a=1:5))$select(pl$col("a")$reverse())
```


---
## ExprBin contains

### Description

R Check if binaries in Series contain a binary substring.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>lit</code></td>
<td><p>The binary substring to look for</p></td>
</tr>
</tbody>
</table>

### Value

Expr returning a Boolean


---
## ExprBin decode

### Description

Decode a value using the provided encoding.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>encoding</code></td>
<td><p>binary choice either 'hex' or 'base64'</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>strict</code></td>
<td><p>Raise an error if the underlying value cannot be decoded,
otherwise mask out with a null value.</p></td>
</tr>
</tbody>
</table>

### Value

binary array with values decoded using provided encoding


---
## ExprBin encode

### Description

Encode a value using the provided encoding.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>encoding</code></td>
<td><p>binary choice either 'hex' or 'base64'</p></td>
</tr>
</tbody>
</table>

### Value

binary array with values encoded using provided encoding


---
## ExprBin ends with

### Description

Check if string values end with a binary substring.

### Value

Expr returning a Boolean


---
## ExprBin starts with

### Description

Check if values starts with a binary substring.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>sub</code></td>
<td><p>Prefix substring.</p></td>
</tr>
</tbody>
</table>


---
## ExprCat set ordering

### Description

Determine how this categorical series should be sorted.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ordering</code></td>
<td><p>string either 'physical' or 'lexical'</p>
<ul>
<li><p>'physical' -&gt; Use the physical representation of the
categories to determine the order (default).</p></li>
<li><p>'lexical' -&gt; Use the string values to determine the
ordering.</p></li>
</ul></td>
</tr>
</tbody>
</table>

### Value

bool: TRUE if equal

### Examples

```r
df = pl$DataFrame(
  cats =  c("z", "z", "k", "a", "b"),
  vals =  c(3, 1, 2, 2, 3)
)$with_columns(
  pl$col("cats")$cast(pl$Categorical)$cat$set_ordering("physical")
)
df$select(pl$all()$sort())
```


---
## ExprDT cast time unit

### Description

Cast the underlying data to another time unit. This may lose precision.
The corresponding global timepoint will stay unchanged +/- precision.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tu</code></td>
<td><p>string option either 'ns', 'us', or 'ms'</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$dt$cast_time_unit()$alias("cast_time_unit_ns"),
  pl$col("date")$dt$cast_time_unit(tu="ms")$alias("cast_time_unit_ms")
)
```


---
## ExprDT combine

### Description

Create a naive Datetime from an existing Date/Datetime expression and a
Time. Each date/datetime in the first half of the interval is mapped to
the start of its bucket. Each date/datetime in the second half of the
interval is mapped to the end of its bucket.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tm</code></td>
<td><p>Expr or numeric or PTime, the number of epoch since or before(if
negative) the Date or tm is an Expr e.g. a column of DataType 'Time' or
something into an Expr.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>tu</code></td>
<td><p>time unit of epochs, default is "us", if tm is a PTime, then tz
passed via PTime.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

The `tu` allows the following time time units the following string
language:

-   1ns \# 1 nanosecond

-   1us \# 1 microsecond

-   1ms \# 1 millisecond

### Value

Date/Datetime expr

### Examples

```r
#Using pl$PTime
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime("02:34:12"))$lit_to_s()
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5, tu="s"))$lit_to_s()
pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5E6 + 123, tu="us"))$lit_to_s()

#pass double and set tu manually
pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")$lit_to_s()

#if needed to convert back to R it is more intuitive to set a specific time zone
expr = pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")
expr$cast(pl$Datetime(tu = "us", tz = "GMT"))$to_r()
```


---
## ExprDT convert time zone

### Description

Set time zone for a Series of type Datetime. Use to change time zone
annotation, but keep the corresponding global timepoint.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tz</code></td>
<td><p>String time zone from base::OlsonNames()</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

corresponds to in R manually modifying the tzone attribute of POSIXt
objects

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-5-1"), interval = "1mo")
)
df$select(
  pl$col("date"),
  pl$col("date")
$dt$replace_time_zone("Europe/Amsterdam")
$dt$convert_time_zone("Europe/London")
$alias("London_with"),
  pl$col("date")
$dt$tz_localize("Europe/London")
$alias("London_localize")
)
```


---
## ExprDT day

### Description

Extract day from underlying Date representation. Applies to Date and
Datetime columns. Returns the day of month starting from 1. The return
value ranges from 1 to 31. (The last day of month differs by months.)

### Format

function

### Value

Expr of day as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$day()$alias("day")
)
```


---
## ExprDT days

### Description

Extract the days from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2020-3-1"), high = as.Date("2020-5-1"), interval = "1mo")
)
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$days()$alias("days_diff")
)
```


---
## ExprDT epoch

### Description

Get the time passed since the Unix EPOCH in the give time unit.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tu</code></td>
<td><p>string option either 'ns', 'us', 'ms', 's' or 'd'</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

ns and perhaps us will exceed integerish limit if returning to R as
flaot64/double.

### Value

Expr of epoch as UInt32

### Examples

```r
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ns")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ms")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("s")$lit_to_s()
pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("d")$lit_to_s()
```


---
## ExprDT hour

### Description

Extract hour from underlying Datetime representation. Applies to
Datetime columns. Returns the hour number from 0 to 23.

### Format

function

### Value

Expr of hour as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$hour()$alias("hour")
)
```


---
## ExprDT hours

### Description

Extract the hours from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2020-1-1"), high = as.Date("2020-1-4"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$hours()$alias("hours_diff")
)
```


---
## ExprDT iso year

### Description

Extract ISO year from underlying Date representation. Applies to Date
and Datetime columns. Returns the year number in the ISO standard. This
may not correspond with the calendar year.

### Format

function

### Value

Expr of iso\_year as Int32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$year()$alias("year"),
  pl$col("date")$dt$iso_year()$alias("iso_year")
)
```


---
## ExprDT microsecond

### Description

Extract microseconds from underlying Datetime representation. Applies to
Datetime columns.

### Format

function

### Value

Expr of microsecond as Int64

### Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
  interval = "2s654321us",
  time_unit = "us" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
  pl$col("date")$dt$microsecond()$alias("microsecond")
)
```


---
## ExprDT microseconds

### Description

Extract the microseconds from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(date = pl$date_range(
low = as.POSIXct("2020-1-1", tz = "GMT"),
high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
interval = "1ms"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$microseconds()$alias("seconds_diff")
)
```


---
## ExprDT millisecond

### Description

Extract milliseconds from underlying Datetime representation. Applies to
Datetime columns.

### Format

function

### Value

Expr of millisecond as Int64

### Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
  interval = "2s654321us",
  time_unit = "us" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
  pl$col("date")$dt$millisecond()$alias("millisecond")
)
```


---
## ExprDT milliseconds

### Description

Extract the milliseconds from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(date = pl$date_range(
low = as.POSIXct("2020-1-1", tz = "GMT"),
high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
interval = "1ms"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$milliseconds()$alias("seconds_diff")
)
```


---
## ExprDT minute

### Description

Extract minutes from underlying Datetime representation. Applies to
Datetime columns. Returns the minute number from 0 to 59.

### Format

function

### Value

Expr of minute as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$minute()$alias("minute")
)
```


---
## ExprDT minutes

### Description

Extract the minutes from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2020-1-1"), high = as.Date("2020-1-4"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$minutes()$alias("minutes_diff")
)
```


---
## ExprDT month

### Description

Extract month from underlying Date representation. Applies to Date and
Datetime columns. Returns the month number starting from 1. The return
value ranges from 1 to 12.

### Format

function

### Value

Expr of month as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$month()$alias("month")
)
```


---
## ExprDT nanosecond

### Description

Extract seconds from underlying Datetime representation. Applies to
Datetime columns. Returns the integer second number from 0 to 59, or a
floating point number from 0 &lt; 60 if `fractional=True` that includes
any milli/micro/nanosecond component.

### Format

function

### Value

Expr of second as Int64

### Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E9+123456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E9,
  interval = "1s987654321ns",
  time_unit = "ns" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
  pl$col("date")$dt$nanosecond()$alias("nanosecond")
)
```


---
## ExprDT nanoseconds

### Description

Extract the nanoseconds from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(date = pl$date_range(
low = as.POSIXct("2020-1-1", tz = "GMT"),
high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
interval = "1ms"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$nanoseconds()$alias("seconds_diff")
)
```


---
## ExprDT offset by

### Description

Offset this date by a relative time offset. This differs from
`pl$col("foo_datetime_tu") + value_tu` in that it can take months and
leap years into account. Note that only a single minus sign is allowed
in the `by` string, as the first character.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>optional string encoding duration see details.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

The `by` are created with the the following string language:

-   1ns \# 1 nanosecond

-   1us \# 1 microsecond

-   1ms \# 1 millisecond

-   1s \# 1 second

-   1m \# 1 minute

-   1h \# 1 hour

-   1d \# 1 day

-   1w \# 1 calendar week

-   1mo \# 1 calendar month

-   1y \# 1 calendar year

-   1i \# 1 index count

These strings can be combined:

-   3d12h4m25s \# 3 days, 12 hours, 4 minutes, and 25 seconds

### Value

Date/Datetime expr

### Examples

```r
df = pl$DataFrame(
  dates = pl$date_range(as.Date("2000-1-1"),as.Date("2005-1-1"), "1y")
)
df$select(
  pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
  pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
)
```


---
## ExprDT ordinal day

### Description

Extract ordinal day from underlying Date representation. Applies to Date
and Datetime columns. Returns the day of year starting from 1. The
return value ranges from 1 to 366. (The last day of year differs by
years.)

### Format

function

### Value

Expr of ordinal\_day as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$ordinal_day()$alias("ordinal_day")
)
```


---
## ExprDT quarter

### Description

Extract quarter from underlying Date representation. Applies to Date and
Datetime columns. Returns the quarter ranging from 1 to 4.

### Format

function

### Value

Expr of quater as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$quarter()$alias("quarter")
)
```


---
## ExprDT replace time zone

### Description

Cast time zone for a Series of type Datetime. Different from
`convert_time_zone`, this will also modify the underlying timestamp. Use
to correct a wrong time zone annotation. This will change the
corresponding global timepoint.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tz</code></td>
<td><p>Null or string time zone from base::OlsonNames()</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
)
df = df$with_columns(
  pl$col("date")
$dt$replace_time_zone("Europe/Amsterdam")
$dt$convert_time_zone("Europe/London")
$alias("london_timezone")
)

df2 = df$with_columns(
  pl$col("london_timezone")
$dt$replace_time_zone("Europe/Amsterdam")
$alias("cast London_to_Amsterdam"),
  pl$col("london_timezone")
$dt$convert_time_zone("Europe/Amsterdam")
$alias("with London_to_Amsterdam"),
  pl$col("london_timezone")
$dt$convert_time_zone("Europe/Amsterdam")
$dt$replace_time_zone(NULL)
$alias("strip tz from with-'Europe/Amsterdam'")
)
df2
```


---
## ExprDT round

### Description

Divide the date/datetime range into buckets. Each date/datetime in the
first half of the interval is mapped to the start of its bucket. Each
date/datetime in the second half of the interval is mapped to the end of
its bucket.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>every</code></td>
<td><p>string encoding duration see details.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>ofset</code></td>
<td><p>optional string encoding duration see details.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

The `every` and `offset` argument are created with the the following
string language:

-   1ns \# 1 nanosecond

-   1us \# 1 microsecond

-   1ms \# 1 millisecond

-   1s \# 1 second

-   1m \# 1 minute

-   1h \# 1 hour

-   1d \# 1 day

-   1w \# 1 calendar week

-   1mo \# 1 calendar month

-   1y \# 1 calendar year These strings can be combined:

    -   3d12h4m25s \# 3 days, 12 hours, 4 minutes, and 25 seconds

This functionality is currently experimental and may change without it
being considered a breaking change.

### Value

Date/Datetime expr

### Examples

```r
t1 = as.POSIXct("3040-01-01",tz = "GMT")
t2 = t1 + as.difftime(25,units = "secs")
s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")

#use a dt namespace function
df = pl$DataFrame(datetime = s)$with_columns(
  pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
  pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
)
df
```


---
## ExprDT second

### Description

Extract seconds from underlying Datetime representation. Applies to
Datetime columns. Returns the integer second number from 0 to 59, or a
floating point number from 0 &lt; 60 if `fractional=True` that includes
any milli/micro/nanosecond component.

### Format

function

### Value

Expr of second as UInt32

### Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
  interval = "2s654321us",
  time_unit = "us" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$dt$second()$alias("second"),
  pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac")
)
```


---
## ExprDT seconds

### Description

Extract the seconds from a Duration type.

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(date = pl$date_range(
low = as.POSIXct("2020-1-1", tz = "GMT"),
high = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
interval = "1m"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$seconds()$alias("seconds_diff")
)
```


---
## ExprDT strftime

### Description

Format Date/Datetime with a formatting rule. See
`⁠chrono strftime/strptime <https://docs.rs/chrono/latest/chrono/format/strftime/index.html>⁠`\_.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fmt</code></td>
<td><p>string format very much like in R passed to chrono</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Date/Datetime expr

### Examples

```r
pl$lit(as.POSIXct("2021-01-02 12:13:14",tz="GMT"))$dt$strftime("this is the year: %Y")$to_r()
```


---
## ExprDT timestamp

### Description

Return a timestamp in the given time unit.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tu</code></td>
<td><p>string option either 'ns', 'us', or 'ms'</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$dt$timestamp()$alias("timestamp_ns"),
  pl$col("date")$dt$timestamp(tu="ms")$alias("timestamp_ms")
)
```


---
## ExprDT truncate

### Description

Divide the date/datetime range into buckets. Each date/datetime is
mapped to the start of its bucket.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>every</code></td>
<td><p>string encoding duration see details.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>ofset</code></td>
<td><p>optional string encoding duration see details.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

The `every` and `offset` argument are created with the the following
string language:

-   1ns \# 1 nanosecond

-   1us \# 1 microsecond

-   1ms \# 1 millisecond

-   1s \# 1 second

-   1m \# 1 minute

-   1h \# 1 hour

-   1d \# 1 day

-   1w \# 1 calendar week

-   1mo \# 1 calendar month

-   1y \# 1 calendar year These strings can be combined:

    -   3d12h4m25s \# 3 days, 12 hours, 4 minutes, and 25 seconds

### Value

Date/Datetime expr

### Examples

```r
t1 = as.POSIXct("3040-01-01",tz = "GMT")
t2 = t1 + as.difftime(25,units = "secs")
s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")

#use a dt namespace function
df = pl$DataFrame(datetime = s)$with_columns(
  pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
  pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
)
df
```


---
## ExprDT tz localize

### Description

Localize tz-naive Datetime Series to tz-aware Datetime Series. This
method takes a naive Datetime Series and makes this time zone aware. It
does not move the time to another time zone.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tz</code></td>
<td><p>string of time zone (no NULL allowed) see allowed timezone in
base::OlsonNames()</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

In R as modifying tzone attribute manually but takes into account
summertime. See unittest "dt$convert\_time\_zone dt$tz\_localize" for a
more detailed comparison to base R.

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
)
df = df$with_columns(
  pl$col("date")
$dt$replace_time_zone("Europe/Amsterdam")
$dt$convert_time_zone("Europe/London")
$alias("london_timezone"),
  pl$col("date")
$dt$tz_localize("Europe/London")
$alias("tz_loc_london")
)

df2 = df$with_columns(
  pl$col("london_timezone")
$dt$replace_time_zone("Europe/Amsterdam")
$alias("cast London_to_Amsterdam"),
  pl$col("london_timezone")
$dt$convert_time_zone("Europe/Amsterdam")
$alias("with London_to_Amsterdam"),
  pl$col("london_timezone")
$dt$convert_time_zone("Europe/Amsterdam")
$dt$replace_time_zone(NULL)
$alias("strip tz from with-'Europe/Amsterdam'")
)
df2
```


---
## ExprDT week

### Description

Extract the week from the underlying Date representation. Applies to
Date and Datetime columns. Returns the ISO week number starting from 1.
The return value ranges from 1 to 53. (The last week of year differs by
years.)

### Format

function

### Value

Expr of week as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$week()$alias("week")
)
```


---
## ExprDT weekday

### Description

Extract the week day from the underlying Date representation. Applies to
Date and Datetime columns. Returns the ISO weekday number where monday =
1 and sunday = 7

### Format

function

### Value

Expr of weekday as UInt32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$weekday()$alias("weekday")
)
```


---
## ExprDT with time unit

### Description

Set time unit of a Series of dtype Datetime or Duration. This does not
modify underlying data, and should be used to fix an incorrect time
unit. The corresponding global timepoint will change.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tu</code></td>
<td><p>string option either 'ns', 'us', or 'ms'</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

Expr of i64

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
)
df$select(
  pl$col("date"),
  pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
  pl$col("date")$dt$with_time_unit(tu="ms")$alias("with_time_unit_ms")
)
```


---
## ExprDT year

### Description

Extract year from underlying Date representation. Applies to Date and
Datetime columns. Returns the year number in the calendar date.

### Format

function

### Value

Expr of Year as Int32

### Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
as.Date("2020-12-25"),
as.Date("2021-1-05"),
interval = "1d",
time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$year()$alias("year"),
  pl$col("date")$dt$iso_year()$alias("iso_year")
)
```


---
## ExprMeta eq

### Description

Are two expressions on a meta level equal

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Expr to compare with</p></td>
</tr>
</tbody>
</table>

### Value

bool: TRUE if equal

### Examples

```r
#three naive expression literals
e1 = pl$lit(40) + 2
e2 = pl$lit(42)
e3 = pl$lit(40) +2

#e1 and e3 are identical expressions
e1$meta$eq(e3)

#e_test is an expression testing whether e1 and e2 evaluates to the same value.
e_test = e1 == e2 # or e_test = e1$eq(e2)

#direct evaluate e_test, possible because only made up of literals
e_test$to_r()

#e1 and e2 are on the meta-level NOT identical expressions
e1$meta$neq(e2)
```


---
## ExprMeta has multiple outputs

### Description

Whether this expression expands into multiple expressions.

### Value

Bool

### Examples

```r
pl$all()$meta$has_multiple_outputs()
pl$col("some_colname")$meta$has_multiple_outputs()
```


---
## ExprMeta is regex projection

### Description

Whether this expression expands to columns that match a regex pattern.

### Value

Bool

### Examples

```r
pl$col("^Sepal.*$")$meta$is_regex_projection()
pl$col("Sepal.Length")$meta$is_regex_projection()
```


---
## ExprMeta neq

### Description

Are two expressions on a meta level NOT equal

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Expr to compare with</p></td>
</tr>
</tbody>
</table>

### Value

bool: TRUE if NOT equal

### Examples

```r
#three naive expression literals
e1 = pl$lit(40) + 2
e2 = pl$lit(42)
e3 = pl$lit(40) +2

#e1 and e3 are identical expressions
e1$meta$eq(e3)

#e_test is an expression testing whether e1 and e2 evaluates to the same value.
e_test = e1 == e2 # or e_test = e1$eq(e2)

#direct evaluate e_test, possible because only made up of literals
e_test$to_r()

#e1 and e2 are on the meta-level NOT identical expressions
e1$meta$neq(e2)
```


---
## ExprMeta output name

### Description

Get the column name that this expression would produce. It might not
always be possible to determine the output name as it might depend on
the schema of the context. In that case this will raise an error.

### Value

R charvec of output names.

### Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


---
## ExprMeta pop

### Description

Pop the latest expression and return the input(s) of the popped
expression.

### Value

R list of Expr(s) usually one, only multiple if top Expr took more Expr
as input.

### Examples

```r
e1 = pl$lit(40) + 2
e2 = pl$lit(42)$sum()

e1
e1$meta$pop()

e2
e2$meta$pop()
```


---
## ExprMeta root names

### Description

Get a vector with the root column name

### Value

R charvec of root names.

### Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


---
## ExprMeta undo aliases

### Description

Undo any renaming operation like `alias` or `keep_name`.

### Value

Expr with aliases undone

### Examples

```r
e = pl$col("alice")$alias("bob")
e$meta$root_names() == "alice"
e$meta$output_name() == "bob"
e$meta$undo_aliases()$meta$output_name() == "alice"
```


---
## ExprStr concat

### Description

Vertically concat the values in the Series to a single string value.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>delimiter</code></td>
<td><p>string The delimiter to insert between consecutive string
values.</p></td>
</tr>
</tbody>
</table>

### Value

Expr of Utf8 concatenated

### Examples

```r
#concatenate a Series of strings to a single string
df = pl$DataFrame(foo = c("1", NA, 2))
df$select(pl$col("foo")$str$concat("-"))

#Series list of strings to Series of concatenated strings
df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2",NA))))
df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())
```


---
## ExprStr contains

### Description

R Check if string contains a substring that matches a regex.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>String or Expr of a string, a valid regex pattern.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>literal</code></td>
<td><p>bool, treat pattern as a literal string. NULL is aliased with
FALSE.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict</code></td>
<td><p>bool, raise an error if the underlying pattern is not a valid
regex expression, otherwise mask out with a null value.</p></td>
</tr>
</tbody>
</table>

### Details

starts\_with : Check if string values start with a substring. ends\_with
: Check if string values end with a substring.

### Value

Expr returning a Boolean

### Examples

```r
df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))
df$select(
  pl$col("a"),
  pl$col("a")$str$contains("cat|bit")$alias("regex"),
  pl$col("a")$str$contains("rab$", literal=TRUE)$alias("literal")
)
```


---
## ExprStr count match

### Description

Count all successive non-overlapping regex matches.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>A valid regex pattern</p></td>
</tr>
</tbody>
</table>

### Value

UInt32 array. Contain null if original value is null or regex capture
nothing.

### Examples

```r
df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
  pl$col("foo")$str$count_match(r"{(\d)}")$alias("count digits")
)
```


---
## ExprStr decode

### Description

Decode a value using the provided encoding.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>encoding</code></td>
<td><p>string choice either 'hex' or 'base64'</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used currently</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict</code></td>
<td><p>Raise an error if the underlying value cannot be decoded,
otherwise mask out with a null value.</p></td>
</tr>
</tbody>
</table>

### Value

Utf8 array with values decoded using provided encoding

### Examples

```r
df = pl$DataFrame( strings = c("foo", "bar", NA))
df$select(pl$col("strings")$str$encode("hex"))
df$with_columns(
  pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
  pl$col("strings")$str$encode("hex")$alias("hex")   #... and must restored with cast
)$with_columns(
  pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
  pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
)
```


---
## ExprStr encode

### Description

Encode a value using the provided encoding.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>encoding</code></td>
<td><p>string choice either 'hex' or 'base64'</p></td>
</tr>
</tbody>
</table>

### Value

Utf8 array with values encoded using provided encoding

### Examples

```r
df = pl$DataFrame( strings = c("foo", "bar", NA))
df$select(pl$col("strings")$str$encode("hex"))
df$with_columns(
  pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
  pl$col("strings")$str$encode("hex")$alias("hex")   #... and must restored with cast
)$with_columns(
  pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
  pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
)
```


---
## ExprStr ends with

### Description

Check if string values end with a substring.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>sub</code></td>
<td><p>Suffix substring or Expr.</p></td>
</tr>
</tbody>
</table>

### Details

contains : Check if string contains a substring that matches a regex.
starts\_with : Check if string values start with a substring.

### Value

Expr returning a Boolean

### Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
  pl$col("fruits"),
  pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
)
```


---
## ExprStr explode

### Description

Returns a column with a separate row for every string character.

### Value

Expr: Series of dtype Utf8.

### Examples

```r
df = pl$DataFrame(a = c("foo", "bar"))
df$select(pl$col("a")$str$explode())
```


---
## ExprStr extract all

### Description

Extracts all matches for the given regex pattern. Extracts each
successive non-overlapping regex match in an individual string as an
array.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>A valid regex pattern</p></td>
</tr>
</tbody>
</table>

### Value

`List[Utf8]` array. Contain null if original value is null or regex
capture nothing.

### Examples

```r
df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
  pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
)
```


---
## ExprStr extract

### Description

Extract the target capture group from provided patterns.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>A valid regex pattern</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>group_index</code></td>
<td><p>Index of the targeted capture group. Group 0 mean the whole
pattern, first group begin at index 1. Default to the first capture
group.</p></td>
</tr>
</tbody>
</table>

### Value

Utf8 array. Contain null if original value is null or regex capture
nothing.

### Examples

```r
df = pl$DataFrame(
  a =  c(
"http://vote.com/ballon_dor?candidate=messi&ref=polars",
"http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
"http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
  )
)
df$select(
  pl$col("a")$str$extract(r"(candidate=(\w+))", 1)
)
```


---
## ExprStr json extract

### Description

Parse string values as JSON.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>dtype</code></td>
<td><p>The dtype to cast the extracted value to. If None, the dtype will
be inferred from the JSON value.</p></td>
</tr>
</tbody>
</table>

### Details

Throw errors if encounter invalid json strings.

### Value

Expr returning a boolean

### Examples

```r
df = pl$DataFrame(
  json_val =  c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
)
dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
df$select(pl$col("json_val")$str$json_extract(dtype))
```


---
## ExprStr json path match

### Description

Extract the first match of json string with provided JSONPath
expression.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>json_path</code></td>
<td><p>A valid JSON path query string.</p></td>
</tr>
</tbody>
</table>

### Details

Throw errors if encounter invalid json strings. All return value will be
casted to Utf8 regardless of the original value. Documentation on
JSONPath standard can be found
`⁠here <https://goessner.net/articles/JsonPath/>⁠`\_.

### Value

Utf8 array. Contain null if original value is null or the json\_path
return nothing.

### Examples

```r
df = pl$DataFrame(
  json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
)
df$select(pl$col("json_val")$str$json_path_match("$.a"))
```


---
## ExprStr lengths

### Description

Get length of the strings as UInt32 (as number of bytes).

### Format

function

### Details

The returned lengths are equal to the number of bytes in the UTF8
string. If you need the length in terms of the number of characters, use
`n_chars` instead.

### Value

Expr of u32 lengths

### Examples

```r
pl$DataFrame(
  s = c("Café", NA, "345", "æøå")
)$select(
  pl$col("s"),
  pl$col("s")$str$lengths()$alias("lengths"),
  pl$col("s")$str$n_chars()$alias("n_chars")
)
```


---
## ExprStr ljust

### Description

Return the string left justified in a string of length `width`.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>width</code></td>
<td><p>Justify left to this length.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>fillchar</code></td>
<td><p>Fill with this ASCII character.</p></td>
</tr>
</tbody>
</table>

### Details

Padding is done using the specified `fillchar`. The original string is
returned if `width` is less than or equal to `len(s)`.

### Value

Expr of Utf8

### Examples

```r
df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
df$select(pl$col("a")$str$ljust(8, "*"))
```


---
## ExprStr lstrip

### Description

Remove leading characters.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>matches</code></td>
<td><p>The set of characters to be removed. All combinations of this set
of characters will be stripped. If set to NULL (default), all whitespace
is removed instead.</p></td>
</tr>
</tbody>
</table>

### Details

will not strip anyt chars beyond the first char not matched. `strip()`
starts from both left and right. Whereas `lstrip()`and `rstrip()` starts
from left and right respectively.

### Value

Expr of Utf8 lowercase chars

### Examples

```r
df = pl$DataFrame(foo = c(" hello", "\tworld"))
df$select(pl$col("foo")$str$strip())
df$select(pl$col("foo")$str$strip(" hel rld"))
df$select(pl$col("foo")$str$lstrip(" hel rld"))
df$select(pl$col("foo")$str$rstrip(" hel\trld"))
df$select(pl$col("foo")$str$rstrip("rldhel\t "))
```


---
## ExprStr n chars

### Description

Get length of the strings as UInt32 (as number of chars).

### Format

function

### Details

If you know that you are working with ASCII text, `lengths` will be
equivalent, and faster (returns length in terms of the number of bytes).

### Value

Expr of u32 n\_chars

### Examples

```r
pl$DataFrame(
  s = c("Café", NA, "345", "æøå")
)$select(
  pl$col("s"),
  pl$col("s")$str$lengths()$alias("lengths"),
  pl$col("s")$str$n_chars()$alias("n_chars")
)
```


---
## ExprStr parse int

### Description

Parse integers with base radix from strings. By default base 2.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>radix</code></td>
<td><p>Positive integer which is the base of the string we are parsing.
Default: 2</p></td>
</tr>
</tbody>
</table>

### Value

Expr: Series of dtype i32.

### Examples

```r
df = pl$DataFrame(bin = c("110", "101", "010"))
df$select(pl$col("bin")$str$parse_int(2))
```


---
## ExprStr replace all

### Description

Replace all matching regex/literal substrings with a new string value.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>Into, regex pattern</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>value</code></td>
<td><p>Into replcacement</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>literal</code></td>
<td><p>bool, treat pattern as a literal string.</p></td>
</tr>
</tbody>
</table>

### Value

Expr of Utf8 Series

### See Also

replace : Replace first matching regex/literal substring.

### Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("abcabc", "123a123"))
df$with_columns(
   pl$col("text")$str$replace_all("a", "-")
)
```


---
## ExprStr replace

### Description

Replace first matching regex/literal substring with a new string value.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>Into, regex pattern</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>value</code></td>
<td><p>Into replcacement</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>literal</code></td>
<td><p>bool, Treat pattern as a literal string.</p></td>
</tr>
</tbody>
</table>

### Value

Expr of Utf8 Series

### See Also

replace\_all : Replace all matching regex/literal substrings.

### Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("123abc", "abc456"))
df$with_columns(
   pl$col("text")$str$replace(r"{abc\b}", "ABC")
)
```


---
## ExprStr rjust

### Description

Return the string left justified in a string of length `width`.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>width</code></td>
<td><p>Justify left to this length.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>fillchar</code></td>
<td><p>Fill with this ASCII character.</p></td>
</tr>
</tbody>
</table>

### Details

Padding is done using the specified `fillchar`. The original string is
returned if `width` is less than or equal to `len(s)`.

### Value

Expr of Utf8

### Examples

```r
df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
df$select(pl$col("a")$str$rjust(8, "*"))
```


---
## ExprStr rstrip

### Description

Remove leading characters.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>matches</code></td>
<td><p>The set of characters to be removed. All combinations of this set
of characters will be stripped. If set to NULL (default), all whitespace
is removed instead.</p></td>
</tr>
</tbody>
</table>

### Details

will not strip anyt chars beyond the first char not matched. `strip()`
starts from both left and right. Whereas `rstrip()`and `rstrip()` starts
from left and right respectively.

### Value

Expr of Utf8 lowercase chars

### Examples

```r
df = pl$DataFrame(foo = c(" hello", "\tworld"))
df$select(pl$col("foo")$str$strip())
df$select(pl$col("foo")$str$strip(" hel rld"))
df$select(pl$col("foo")$str$lstrip(" hel rld"))
df$select(pl$col("foo")$str$rstrip(" hel\trld"))
df$select(pl$col("foo")$str$rstrip("rldhel\t "))
```


---
## ExprStr slice

### Description

Create subslices of the string values of a Utf8 Series.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>pattern</code></td>
<td><p>Into, regex pattern</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>value</code></td>
<td><p>Into replcacement</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>literal</code></td>
<td><p>bool, treat pattern as a literal string.</p></td>
</tr>
</tbody>
</table>

### Value

Expr: Series of dtype Utf8.

### Examples

```r
df = pl$DataFrame(s = c("pear", NA, "papaya", "dragonfruit"))
df$with_columns(
   pl$col("s")$str$slice(-3)$alias("s_sliced")
)
```


---
## ExprStr split exact

### Description

Split the string by a substring using `n` splits. Results in a struct of
`n+1` fields. If it cannot make `n` splits, the remaining field elements
will be null.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>Substring to split by.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n</code></td>
<td><p>Number of splits to make.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>inclusive</code></td>
<td><p>If True, include the split_exact character/string in the
results.</p></td>
</tr>
</tbody>
</table>

### Value

Struct where each of n+1 fields is of Utf8 type

### Examples

```r
df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
df$select( pl$col("s")$str$split_exact(by="_",1))
```


---
## ExprStr split

### Description

Split the string by a substring.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>Substring to split by.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>inclusive</code></td>
<td><p>If True, include the split character/string in the
results.</p></td>
</tr>
</tbody>
</table>

### Value

List of Utf8 type

### Examples

```r
df = pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
df$select( pl$col("s")$str$split(by=" "))
```


---
## ExprStr splitn

### Description

Split the string by a substring, restricted to returning at most `n`
items. If the number of possible splits is less than `n-1`, the
remaining field elements will be null. If the number of possible splits
is `n-1` or greater, the last (nth) substring will contain the remainder
of the string.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>by</code></td>
<td><p>Substring to split by.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n</code></td>
<td><p>Number of splits to make.</p></td>
</tr>
</tbody>
</table>

### Value

Struct where each of n+1 fields is of Utf8 type

### Examples

```r
df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
df$select( pl$col("s")$str$splitn(by="_",0))
df$select( pl$col("s")$str$splitn(by="_",1))
df$select( pl$col("s")$str$splitn(by="_",2))
```


---
## ExprStr starts with

### Description

Check if string values starts with a substring.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>sub</code></td>
<td><p>Prefix substring or Expr.</p></td>
</tr>
</tbody>
</table>

### Details

contains : Check if string contains a substring that matches a regex.
ends\_with : Check if string values end with a substring.

### Value

Expr returning a Boolean

### Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
  pl$col("fruits"),
  pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
)
```


---
## ExprStr strip

### Description

Remove leading and trailing characters.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>matches</code></td>
<td><p>The set of characters to be removed. All combinations of this set
of characters will be stripped. If set to NULL (default), all whitespace
is removed instead.</p></td>
</tr>
</tbody>
</table>

### Details

will not strip anyt chars beyond the first char not matched. `strip()`
starts from both left and right. Whereas `lstrip()`and `rstrip()` starts
from left and right respectively.

### Value

Expr of Utf8 lowercase chars

### Examples

```r
df = pl$DataFrame(foo = c(" hello", "\tworld"))
df$select(pl$col("foo")$str$strip())
df$select(pl$col("foo")$str$strip(" hel rld"))
df$select(pl$col("foo")$str$lstrip(" hel rld"))
df$select(pl$col("foo")$str$rstrip(" hel\trld"))
df$select(pl$col("foo")$str$rstrip("rldhel\t "))
```


---
## ExprStr strptime

### Description

Parse a Series of dtype Utf8 to a Date/Datetime Series.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>datatype</code></td>
<td><p>a temporal data type either pl$Date, pl$Time or
pl$Datetime</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>fmt</code></td>
<td><p>fmt string for parsenig see see details here
https://docs.rs/chrono/latest/chrono/format/strftime/index.html#fn6
Notice time_zone %Z is not supported and will just ignore timezones.
Numeric tz like %z, %:z .... are supported.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict</code></td>
<td><p>bool, if true raise error if a single string cannot be parsed,
else produce a polars <code>null</code>.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>exact</code></td>
<td><p>bool , If True, require an exact format match. If False, allow
the format to match anywhere in the target string.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>cache</code></td>
<td><p>Use a cache of unique, converted dates to apply the datetime
conversion.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>tz_aware</code></td>
<td><p>bool, Parse timezone aware datetimes. This may be automatically
toggled by the ‘fmt’ given.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>utc</code></td>
<td><p>bool Parse timezone aware datetimes as UTC. This may be useful if
you have data with mixed offsets.</p></td>
</tr>
</tbody>
</table>

### Details

Notes When parsing a Datetime the column precision will be inferred from
the format string, if given, eg: “%F %T%.3f” =&gt; Datetime(“ms”). If no
fractional second component is found then the default is “us”.

### Value

Expr of a Data, Datetime or Time Series

### Examples

```r
s = pl$Series(c(
"2021-04-22",
"2022-01-04 00:00:00",
"01/31/22",
"Sun Jul  8 00:34:60 2001"
  ),
  "date"
)
#' #join multiple passes with different fmt
s$to_frame()$with_columns(
pl$col("date")
$str$strptime(pl$Date, "%F", strict=FALSE)
$fill_null(pl$col("date")$str$strptime(pl$Date, "%F %T", strict=FALSE))
$fill_null(pl$col("date")$str$strptime(pl$Date, "%D", strict=FALSE))
$fill_null(pl$col("date")$str$strptime(pl$Date, "%c", strict=FALSE))
)

txt_datetimes = c(
  "2023-01-01 11:22:33 -0100",
  "2023-01-01 11:22:33 +0300",
  "invalid time"
)

pl$lit(txt_datetimes)$str$strptime(
  pl$Datetime("ns"),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE,
  tz_aware = TRUE, utc =TRUE
)$lit_to_s()
```


---
## ExprStr to lowercase

### Description

Transform to lowercase variant.

### Value

Expr of Utf8 lowercase chars

### Examples

```r
pl$lit(c("A","b", "c", "1", NA))$str$to_lowercase()$lit_to_s()
```


---
## ExprStr to uppercase

### Description

Transform to uppercase variant.

### Value

Expr of Utf8 uppercase chars

### Examples

```r
pl$lit(c("A","b", "c", "1", NA))$str$to_uppercase()$lit_to_s()
```


---
## ExprStr zfill

### Description

Fills the string with zeroes.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>alignment</code></td>
<td><p>Fill the value up to this length</p></td>
</tr>
</tbody>
</table>

### Details

Return a copy of the string left filled with ASCII '0' digits to make a
string of length width.

A leading sign prefix ('+'/'-') is handled by inserting the padding
after the sign character rather than before. The original string is
returned if width is less than or equal to `len(s)`.

### Value

Expr

### Examples

```r
some_floats_expr = pl$lit(c(0,10,-5,5))

#cast to Utf8 and ljust alignment = 5, and view as R char vector
some_floats_expr$cast(pl$Utf8)$str$zfill(5)$to_r()

#cast to int and the to utf8 and then ljust alignment = 5, and view as R char vector
some_floats_expr$cast(pl$Int64)$cast(pl$Utf8)$str$zfill(5)$to_r()
```


---
## ExprStruct field

### Description

Retrieve a `Struct` field as a new Series. By default base 2.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>string, the Name of the struct field to retrieve.</p></td>
</tr>
</tbody>
</table>

### Value

Expr: Series of same and name selected field.

### Examples

```r
df = pl$DataFrame(
 aaa = c(1, 2),
 bbb = c("ab", "cd"),
 ccc = c(TRUE, NA),
 ddd = list(c(1, 2), 3)
)$select(
  pl$struct(pl$all())$alias("struct_col")
)
#struct field into a new Series
df$select(
  pl$col("struct_col")$struct$field("bbb"),
  pl$col("struct_col")$struct$field("ddd")
)
```


---
## ExprStruct rename fields

### Description

Rename the fields of the struct. By default base 2.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>names</code></td>
<td><p>char vec or list of strings given in the same order as the
struct's fields. Providing fewer names will drop the latter fields.
Providing too many names is ignored.</p></td>
</tr>
</tbody>
</table>

### Value

Expr: struct-series with new names for the fields

### Examples

```r
df = pl$DataFrame(
  aaa = 1:2,
  bbb = c("ab", "cd"),
  ccc = c(TRUE, NA),
  ddd = list(1:2, 3L)
)$select(
  pl$struct(pl$all())$alias("struct_col")
)$select(
  pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
)
df$unnest()
```


---
## Extendr method to pure functions

### Description

self is a global of extendr wrapper methods this function copies the
function into a new environment and modify formals to have a self
argument

### Usage

    extendr_method_to_pure_functions(env)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>env</code></td>
<td><p>environment object output from extendr-wrappers.R
classes</p></td>
</tr>
</tbody>
</table>

### Value

env of pure function calls to rust


---
## Extra auto completion

### Description

Extra polars auto completion

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>activate</code></td>
<td><p>bool default TRUE, enable chained auto-completion</p></td>
</tr>
</tbody>
</table>

### Details

polars always supports auto completetion via .DollarNames. However
chained methods like x$a()$b()$? are not supported vi .DollarNames.

This feature experimental and not perfect. Any feedback is appreciated.
Currently does not play that nice with Rstudio, as Rstudio backtick
quotes any custom suggestions.

### Examples

```r
#auto completion via .DollarNames method
e = pl$lit(42) # to autocomplete pl$lit(42) save to variable
# then write `e$`  and press tab to see available methods

# polars has experimental auto completetion for chain of methods if all on the same line
pl$extra_auto_completion() #first activate feature (this will 'annoy' the Rstudio auto-completer)
pl$lit(42)$lit_to_s() # add a $ and press tab 1-3 times
pl$extra_auto_completion(activate = FALSE) #deactivate
```


---
## Filter-open-paren-close-paren

### Description

DataFrame$filter(bool\_expr)

### Usage

    DataFrame_filter(bool_expr)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>bool_expr</code></td>
<td><p>Polars expression which will evaluate to a bool
pl$Series</p></td>
</tr>
</tbody>
</table>

### Value

filtered DataFrame

### Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
```


---
## Get method usages

### Description

Generate autocompletion suggestions for object

### Usage

    get_method_usages(env, pattern = "")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>env</code></td>
<td><p>environment to extract usages from</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>pattern</code></td>
<td><p>string passed to ls(pattern) to subset methods by
pattern</p></td>
</tr>
</tbody>
</table>

### Details

used internally for auto completion in .DollarNames methods

### Value

method usages

### Examples

```r
polars:::get_method_usages(polars:::DataFrame, pattern="col")
```


---
## GroupBy agg

### Description

Aggregatete a DataFrame over a groupby

### Usage

    GroupBy_agg(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>exprs to aggregate</p></td>
</tr>
</tbody>
</table>

### Value

aggregated DataFrame

### Examples

```r
pl$DataFrame(
  list(
foo = c("one", "two", "two", "one", "two"),
bar = c(5, 3, 2, 4, 1)
  )
)$groupby(
"foo"
)$agg(
 pl$col("bar")$sum()$alias("bar_sum"),
 pl$col("bar")$mean()$alias("bar_tail_sum")
)
```


---
## GroupBy as data frame

### Description

convert to data.frame

### Usage

    GroupBy_as_data_frame(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any opt param passed to R as.data.frame</p></td>
</tr>
</tbody>
</table>

### Value

R data.frame

### Examples

```r
pl$DataFrame(iris)$as_data_frame() #R-polars back and forth
```


---
## GroupBy first

### Description

Reduce the groups to the first value.

### Usage

    GroupBy_first()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$first()
```


---
## GroupBy last

### Description

Reduce the groups to the last value.

### Usage

    GroupBy_last()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$last()
```


---
## GroupBy max

### Description

Reduce the groups to the maximum value.

### Usage

    GroupBy_max()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$max()
```


---
## GroupBy mean

### Description

Reduce the groups to the mean value.

### Usage

    GroupBy_mean()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$mean()
```


---
## GroupBy median

### Description

Reduce the groups to the median value.

### Usage

    GroupBy_median()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$median()
```


---
## GroupBy min

### Description

Reduce the groups to the minimum value.

### Usage

    GroupBy_min()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$min()
```


---
## GroupBy null count

### Description

Create a new DataFrame that shows the null counts per column.

### Usage

    GroupBy_null_count()

### Value

DataFrame

### Examples

```r
x = mtcars
x[1:10, 3:5] = NA
pl$DataFrame(x)$groupby("cyl")$null_count()
```


---
## GroupBy std

### Description

Reduce the groups to the standard deviation value.

### Usage

    GroupBy_std()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$std()
```


---
## GroupBy sum

### Description

Reduce the groups to the sum value.

### Usage

    GroupBy_sum()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$sum()
```


---
## GroupBy var

### Description

Reduce the groups to the variance value.

### Usage

    GroupBy_var()

### Value

aggregated DataFrame

### Examples

```r
df = pl$DataFrame(
a = c(1, 2, 2, 3, 4, 5),
b = c(0.5, 0.5, 4, 10, 13, 14),
c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$var()
```


---
## Is DataFrame data input

### Description

The Dataframe constructors accepts data.frame inheritors or list of
vectors and/or Series.

### Usage

    is_DataFrame_data_input(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object to test if suitable as input to DataFrame</p></td>
</tr>
</tbody>
</table>

### Value

bool

### Examples

```r
polars:::is_DataFrame_data_input(iris)
polars:::is_DataFrame_data_input(list(1:5,pl$Series(1:5),letters[1:5]))
```


---
## Is err

### Description

check if x ss a result and an err

### Usage

    is_err(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>R object which could be a rust-like result of a list with two
elements, ok and err</p></td>
</tr>
</tbody>
</table>

### Value

bool if is a result object which is an err


---
## Is ok

### Description

check if x ss a result and an ok

### Usage

    is_ok(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>R object which could be a rust-like result of a list with two
elements, ok and err</p></td>
</tr>
</tbody>
</table>

### Value

bool if is a result object which is an ok


---
## Is polars dtype

### Description

chek if x is a valid RPolarsDataType

### Usage

    is_polars_dtype(x, include_unknown = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a candidate</p></td>
</tr>
</tbody>
</table>

### Value

a list DataType with an inner DataType

### Examples

```r
polars:::is_polars_dtype(pl$Int64)
```


---
## Is result

### Description

check if z is a result

### Usage

    is_result(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>R object which could be a rust-like result of a list with two
elements, ok and err</p></td>
</tr>
</tbody>
</table>

### Details

both ok and err being NULL encodes ok-value NULL. No way to encode an
err-value NULL If both ok and err has value then this is an invalid
result

### Value

bool if is a result object


---
## Is schema

### Description

check if schema

### Usage

    is_schema(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>objet to test if schema</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

bool

### Examples

```r
polars:::is_schema(pl$DataFrame(iris)$schema)
pl$is_schema(pl$DataFrame(iris)$schema)
polars:::is_schema(list("alice","bob"))
```


---
## L to vdf

### Description

lifecycle: DEPRECATE, imple on rust side as a function

### Usage

    l_to_vdf(l)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>l</code></td>
<td><p>list of DataFrame</p></td>
</tr>
</tbody>
</table>

### Value

VecDataFrame


---
## Lazy csv reader

### Description

will scan the csv when collect(), not now

### Usage

    lazy_csv_reader(
      path,
      sep = ",",
      has_header = TRUE,
      ignore_errors = FALSE,
      skip_rows = 0,
      n_rows = NULL,
      cache = FALSE,
      overwrite_dtype = NULL,
      low_memory = FALSE,
      comment_char = NULL,
      quote_char = "\"",
      null_values = NULL,
      infer_schema_length = 100,
      skip_rows_after_header = 0,
      encoding = "utf8",
      row_count_name = NULL,
      row_count_offset = 0,
      parse_dates = FALSE
    )

    csv_reader(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>path</code></td>
<td><p>string, Path to a file</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>sep</code></td>
<td><p>Single char to use as delimiter in the file.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>has_header</code></td>
<td><p>bool, indicate if the first row of dataset is a header or not. If
set to False, column names will be autogenerated in the following
format: column_x, with x being an enumeration over every column in the
dataset starting at 1.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>ignore_errors</code></td>
<td><p>bool, try to keep reading lines if some lines yield errors. First
try infer_schema_length=0 to read all columns as pl.Utf8 to check which
values might cause an issue.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>skip_rows</code></td>
<td><p>integer, Start reading after skip_rows lines. The header will be
parsed at this offset.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n_rows</code></td>
<td><p>int (NULL is disable),Stop reading from CSV file after reading
n_rows.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>cache</code></td>
<td><p>bool, cache the result after reading.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>overwrite_dtype</code></td>
<td><p>(NULL is disable) named list of dtypes OR dtype-names, where name
points to a column. Can overwrite dtypes during inference. Supported
types so far are: name | alias | polars side dtype "Boolean" | "logical"
=&gt; DataType::Boolean, "Float32" | "double" =&gt; DataType::Float32,
"Float64" | "float64" =&gt; DataType::Float64, "Int32" | "integer" =&gt;
DataType::Int32, "Int64" | "integer64" =&gt; DataType::Int64, "Utf8" |
"character" =&gt; DataType::Utf8,</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>low_memory</code></td>
<td><p>bool, reduce memory usage in expense of performance</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>comment_char</code></td>
<td><p>(NULL is disable) Single byte character that indicates the start
of a comment line, for instance #.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>quote_char</code></td>
<td><p>(NULL is disable) Single byte character used for csv quoting,
default = ". Set to None to turn off special handling and escaping of
quotes.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>null_values</code></td>
<td><p>(NULL is disable) Values to interpret as null values. You can
provide a String : All values equal to this string will be null. Unnamed
char vector: A null value per column. Named char vector. A mapping from
(names)column to a null value string(values).</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>infer_schema_length</code></td>
<td><p>Maximum number of rows to read to infer the column types. If set
to 0, all columns will be read as UTF-8. If <code>NULL</code>, a full
table scan will be done (slow).</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>skip_rows_after_header</code></td>
<td><p>bool Skip this number of rows when the header is parsed.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>encoding</code></td>
<td><p>either "utf8" or "utf8-lossy". Lossy means that invalid utf8
values are replaced with "?" characters.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>row_count_name</code></td>
<td><p>String(NULL is disable), name of a added row count
column</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>row_count_offset</code></td>
<td><p>integer, Offset to start the row_count column (only used if the
name is set).</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>parse_dates</code></td>
<td><p>bool Try to automatically parse dates. If this does not succeed,
the column remains of data type pl.Utf8.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any argument passed to lazy_csv_reader</p></td>
</tr>
</tbody>
</table>

### Details

Read a file from path into a polars lazy frame. Not yet supporting
eol\_char and with\_column\_names

### Value

lazyframe

DataFrame

### Examples

```r
my_file = tempfile()
write.csv(iris,my_file)
lazy_frame = polars:::lazy_csv_reader(path=my_file)
lazy_frame$collect()
unlink(my_file)
```


---
## LazyFrame class

### Description

The `LazyFrame`-class is simply two environments of respectively the
public and private methods/function calls to the polars rust side. The
instanciated `LazyFrame`-object is an `externalptr` to a lowlevel rust
polars LazyFrame object. The pointer address is the only statefullness
of the LazyFrame object on the R side. Any other state resides on the
rust side. The S3 method `.DollarNames.LazyFrame` exposes all public
`⁠$foobar()⁠`-methods which are callable onto the object. Most methods
return another `LazyFrame`-class instance or similar which allows for
method chaining. This class system in lack of a better name could be
called "environment classes" and is the same class system extendr
provides, except here there is both a public and private set of methods.
For implementation reasons, the private methods are external and must be
called from polars:::.pr.$LazyFrame$methodname(), also all private
methods must take any self as an argument, thus they are pure functions.
Having the private methods as pure functions solved/simplified
self-referential complications.

`DataFrame` and `LazyFrame` can both be said to be a `Frame`. To convert
use `DataFrame_object$lazy() -> LazyFrame_object` and
`LazyFrame_object$collect() -> DataFrame_object`. This is quite similar
to the lazy-collect syntax of the dplyrpackage to interact with database
connections such as SQL variants. Most SQL databases would be able to
perform the same otimizations as polars such Predicate Pushdown and
Projection. However polars can intertact and optimize queries with both
SQL DBs and other data sources such parquet files simultanously. (#TODO
implement r-polars SQL ;)

### Details

Check out the source code in R/LazyFrame\_\_lazy.R how public methods
are derived from private methods. Check out extendr-wrappers.R to see
the extendr-auto-generated methods. These are moved to .pr and converted
into pure external functions in after-wrappers.R. In zzz.R (named zzz to
be last file sourced) the extendr-methods are removed and replaced by
any function prefixed `LazyFrame_`.

### Examples

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


---
## LazyFrame collect background

### Description

collect DataFrame by lazy query

### Usage

    LazyFrame_collect_background()

### Value

collected `DataFrame`

### Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```


---
## LazyFrame collect

### Description

collect DataFrame by lazy query

### Usage

    LazyFrame_collect()

### Value

collected `DataFrame`

### Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```


---
## LazyFrame describe optimized plan

### Description

select on a LazyFrame

### Usage

    LazyFrame_describe_optimized_plan()


---
## LazyFrame describe plan

### Description

select on a LazyFrame

### Usage

    LazyFrame_describe_plan

### Format

An object of class `character` of length 1.


---
## LazyFrame filter

### Description

Filter rows with an Expression definining a boolean column

### Usage

    LazyFrame_filter(expr)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>expr</code></td>
<td><p>one Expr or string naming a column</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

A new `LazyFrame` object with add/modified column.

### Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```


---
## LazyFrame first

### Description

Get the first row of the DataFrame.

### Usage

    LazyFrame_first

### Format

function

### Value

A new `DataFrame` object with applied filter.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$first()$collect()
```


---
## LazyFrame groupby

### Description

apply groupby on LazyFrame, return LazyGroupBy

### Usage

    LazyFrame_groupby(..., maintain_order = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any single Expr or string naming a column</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>maintain_order</code></td>
<td><p>bool should an aggregate of groupby retain order of groups or
FALSE = random, slightly faster?</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyGroupBy` object with applied groups.


---
## LazyFrame join

### Description

join a LazyFrame

### Usage

    LazyFrame_join(
      other,
      left_on = NULL,
      right_on = NULL,
      on = NULL,
      how = c("inner", "left", "outer", "semi", "anti", "cross"),
      suffix = "_right",
      allow_parallel = TRUE,
      force_parallel = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>LazyFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>left_on</code></td>
<td><p>names of columns in self LazyFrame, order should match. Type, see
on param.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>right_on</code></td>
<td><p>names of columns in other LazyFrame, order should match. Type,
see on param.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>on</code></td>
<td><p>named columns as char vector of named columns, or list of
expressions and/or strings.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>how</code></td>
<td><p>a string selecting one of the following methods: inner, left,
outer, semi, anti, cross</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>suffix</code></td>
<td><p>name to added right table</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>allow_parallel</code></td>
<td><p>bool</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>force_parallel</code></td>
<td><p>bool</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object with applied join.


---
## LazyFrame last

### Description

Aggregate the columns in the DataFrame to their maximum value.

### Usage

    LazyFrame_last

### Format

function

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$last()$collect()
```


---
## LazyFrame limit

### Description

take limit of n rows of query

### Usage

    LazyFrame_limit(n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>positive numeric or integer number not larger than 2^32</p></td>
</tr>
</tbody>
</table>

### Details

any number will converted to u32. Negative raises error

### Value

A new `LazyFrame` object with applied filter.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$limit(4)$collect()
```


---
## LazyFrame max

### Description

Aggregate the columns in the DataFrame to their maximum value.

### Usage

    LazyFrame_max

### Format

function

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$max()$collect()
```


---
## LazyFrame mean

### Description

Aggregate the columns in the DataFrame to their mean value.

### Usage

    LazyFrame_mean

### Format

function

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$mean()$collect()
```


---
## LazyFrame median

### Description

Aggregate the columns in the DataFrame to their median value.

### Usage

    LazyFrame_median

### Format

function

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$median()$collect()
```


---
## LazyFrame min

### Description

Aggregate the columns in the DataFrame to their minimum value.

### Usage

    LazyFrame_min

### Format

function

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$min()$collect()
```


---
## LazyFrame print

### Description

can be used i the middle of a method chain

### Usage

    LazyFrame_print(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>LazyFrame</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

self

### Examples

```r
 pl$DataFrame(iris)$lazy()$print()
```


---
## LazyFrame reverse

### Description

Reverse the DataFrame.

### Usage

    LazyFrame_reverse

### Format

An object of class `character` of length 1.

### Value

LazyFrame

### Examples

```r
pl$DataFrame(mtcars)$lazy()$reverse()$collect()
```


---
## LazyFrame select

### Description

select on a LazyFrame

### Usage

    LazyFrame_select(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any single Expr or string naming a column</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object with applied filter.


---
## LazyFrame slice

### Description

Get a slice of this DataFrame.

### Usage

    LazyFrame_slice(offset, length = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>offset</code></td>
<td><p>integer</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>length</code></td>
<td><p>integer or NULL</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame

### Examples

```r
pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()
pl$DataFrame(mtcars)$lazy()$slice(30)$collect()
mtcars[2:6,]
```


---
## LazyFrame std

### Description

Aggregate the columns of this LazyFrame to their standard deviation
values.

### Usage

    LazyFrame_std(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer Delta Degrees of Freedom: the divisor used in the
calculation is N - ddof, where N represents the number of elements. By
default ddof is 1.</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$std()$collect()
```


---
## LazyFrame sum

### Description

Aggregate the columns of this DataFrame to their sum values.

### Usage

    LazyFrame_sum

### Format

function

### Value

LazyFrame

### Examples

```r
pl$DataFrame(mtcars)$lazy()$sum()$collect()
```


---
## LazyFrame tail

### Description

take last n rows of query

### Usage

    LazyFrame_tail(n)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>positive numeric or integer number not larger than 2^32</p></td>
</tr>
</tbody>
</table>

### Details

any number will converted to u32. Negative raises error

### Value

A new `LazyFrame` object with applied filter.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$tail(2)$collect()
```


---
## LazyFrame var

### Description

Aggregate the columns of this LazyFrame to their variance values.

### Usage

    LazyFrame_var(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>integer Delta Degrees of Freedom: the divisor used in the
calculation is N - ddof, where N represents the number of elements. By
default ddof is 1.</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object with applied aggregation.

### Examples

```r
pl$DataFrame(mtcars)$lazy()$var()$collect()
```


---
## LazyFrame with column

### Description

add or replace columns of LazyFrame

### Usage

    LazyFrame_with_column(expr)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>expr</code></td>
<td><p>one Expr or string naming a column</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

A new `LazyFrame` object with add/modified column.


---
## LazyFrame with columns

### Description

add or replace columns of LazyFrame

### Usage

    LazyFrame_with_columns(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any single Expr or string naming a column</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object with added/modified columns.


---
## LazyFrame-describe optimized plan

### Description

Describe the optimized collect plan of a Polars LazyFrame

### Usage

    <LazyFrame>$describe_optimized_plan()


---
## LazyFrame-describe plan

### Description

Describe the collect plan of a Polars LazyFrame

### Usage

    <LazyFrame>$describe_plan()


---
## LazyFrame-print

### Description

Print a Polars LazyFrame

### Usage

    <LazyFrame>$print()


---
## LazyGroupBy agg

### Description

aggregate a polar\_lazy\_groupby

### Usage

    LazyGroupBy_agg(...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any Expr or string</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object.


---
## LazyGroupBy apply

### Description

one day this will apply

### Usage

    LazyGroupBy_apply(f)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>f</code></td>
<td><p>R function to apply</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object.


---
## LazyGroupBy head

### Description

get n rows of head of group

### Usage

    LazyGroupBy_head(n = 1L)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>integer number of rows to get</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object.


---
## LazyGroupBy print

### Description

prints opague groupby, not much to show

### Usage

    LazyGroupBy_print()


---
## LazyGroupBy tail

### Description

get n tail rows of group

### Usage

    LazyGroupBy_tail(n = 1L)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>integer number of rows to get</p></td>
</tr>
</tbody>
</table>

### Value

A new `LazyFrame` object.


---
## Length.Series

### Description

Length of series

### Usage

    ## S3 method for class 'Series'
    length(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a Series</p></td>
</tr>
</tbody>
</table>

### Value

the length as a double


---
## Macro add syntax check to class

### Description

add syntax verification to class

### Usage

    macro_add_syntax_check_to_class(Class_name)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>Class_name</code></td>
<td><p>string name of env class</p></td>
</tr>
</tbody>
</table>

### Details

this function overrides dollarclass method of a extendr env\_class to
run first verify\_method\_call() to check for syntax error and return
more user friendly error if issues

All R functions coined 'macro'-functions use eval(parse()) but only at
package build time to solve some tricky self-referential problem. If
possible to deprecate a macro in a clean way , go ahead.

see zzz.R for usage examples

### Value

dollarsign method with syntax verification

### See Also

verify\_method\_call


---
## Macro new subnamespace

### Description

Bundle class methods into an environment (subname space)

### Usage

    macro_new_subnamespace(class_pattern, subclass_env = NULL, remove_f = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>class_pattern</code></td>
<td><p>regex to select functions</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>subclass_env</code></td>
<td><p>optional subclass of</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>remove_f</code></td>
<td><p>drop sourced functions from package ns after bundling into sub
ns</p></td>
</tr>
</tbody>
</table>

### Details

This function is used to emulate py-polars subnamespace-methods All R
functions coined 'macro\_'-functions use eval(parse()) but only at
package build time to solve some tricky self-referential problem. If
possible to deprecate a macro in a clean way , go ahead.

### Value

A function which returns a subclass environment of bundled class
functions.

### Examples

```r
#macro_new_subnamespace() is not exported, export for this toy example
#macro_new_subnamespace = polars:::macro_new_subnamespace

##define some new methods prefixed 'MyClass_'
#MyClass_add2 = function() self + 2
#MyClass_mul2 = function() self * 2

##grab any sourced function prefixed 'MyClass_'
#my_class_sub_ns = macro_new_subnamespace("^MyClass_", "myclass_sub_ns")

#here adding sub-namespace as a expr-class property/method during session-time,
#which only is for this demo.
#instead sourced method like Expr_arr() at package build time instead
#env = polars:::Expr #get env of the Expr Class
#env$my_sub_ns = method_as_property(function() { #add a property/method
# my_class_sub_ns(self)
#})
#rm(env) #optional clean up

#add user defined S3 method the subclass 'myclass_sub_ns'
#print.myclass_sub_ns = function(x, ...) { #add ... even if not used
#   print("hello world, I'm myclass_sub_ns")
#   print("methods in sub namespace are:")
#  print(ls(x))
#  }

#test
# e = pl$lit(1:5)  #make an Expr
#print(e$my_sub_ns) #inspect
#e$my_sub_ns$add2() #use the sub namespace
#e$my_sub_ns$mul2()
```


---
## Map err

### Description

map an Err part of Result

### Usage

    map_err(x, f)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>f</code></td>
<td><p>a closure that takes the err part as input</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Err-result


---
## Map

### Description

map an Err part of Result

### Usage

    map(x, f)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>f</code></td>
<td><p>a closure that takes the ok part as input</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Err-result


---
## Max

### Description

Folds the expressions from left to right, keeping the first non-null
value.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>is a: If one arg:</p>
<ul>
<li><p>Series or Expr, same as <code>column$sum()</code></p></li>
<li><p>string, same as <code>pl$col(column)$sum()</code></p></li>
<li><p>numeric, same as <code>pl$lit(column)$sum()</code></p></li>
<li><p>list of strings(column names) or exprressions to add up as expr1
+ expr2 + expr3 + ...</p></li>
</ul>
<p>If several args, then wrapped in a list and handled as
above.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(
  a = NA_real_,
  b = c(1:2,NA_real_,NA_real_),
  c = c(1:3,NA_real_)
)
#use coalesce to get first non Null value for each row, otherwise insert 99.9
df$with_column(
  pl$coalesce("a", "b", "c", 99.9)$alias("d")
)
```


---
## Mem address

### Description

mimics pl$mem\_address

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>robj</code></td>
<td><p>an R object</p></td>
</tr>
</tbody>
</table>

### Value

String of mem address

### Examples

```r
pl$mem_address(pl$Series(1:3))
```


---
## Method as property

### Description

Internal function, see use in source

### Usage

    method_as_property(f, setter = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>f</code></td>
<td><p>a function</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>setter</code></td>
<td><p>bool, if true a property method can be modified by user</p></td>
</tr>
</tbody>
</table>

### Value

function subclassed into c("property","function") or
c("setter","property","function")


---
## Min

### Description

Folds the expressions from left to right, keeping the first non-null
value.

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>is a: If one arg:</p>
<ul>
<li><p>Series or Expr, same as <code>column$sum()</code></p></li>
<li><p>string, same as <code>pl$col(column)$sum()</code></p></li>
<li><p>numeric, same as <code>pl$lit(column)$sum()</code></p></li>
<li><p>list of strings(column names) or exprressions to add up as expr1
+ expr2 + expr3 + ...</p></li>
</ul>
<p>If several args, then wrapped in a list and handled as
above.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
df = pl$DataFrame(
  a = NA_real_,
  b = c(2:1,NA_real_,NA_real_),
  c = c(1:3,NA_real_),
  d = c(1:2,NA_real_,-Inf)
)
#use min to get first non Null value for each row, otherwise insert 99.9
df$with_column(
  pl$min("a", "b", "c", 99.9)$alias("d")
)
```


---
## Move env elements

### Description

Move environment elements from one env to another

### Usage

    move_env_elements(from_env, to_env, element_names, remove = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>from_env</code></td>
<td><p>env from</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>to_env</code></td>
<td><p>env to</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>element_names</code></td>
<td><p>names of elements to move, if named names, then name of name is
to_env name</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>remove</code></td>
<td><p>bool, actually remove element in from_env</p></td>
</tr>
</tbody>
</table>


---
## Nanoarrow

### Description

Conversion via native apache arrow array stream (fast), THIS REQUIRES
´nanoarrow´

### Usage

    as_nanoarrow_array_stream.DataFrame(x, ..., schema = NULL)

    infer_nanoarrow_schema.DataFrame(x, ...)

    as_arrow_table.DataFrame(x, ...)

    as_record_batch_reader.DataFrame(x, ..., schema = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a polars DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used right now</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>schema</code></td>
<td><p>must stay at default value NULL</p></td>
</tr>
</tbody>
</table>

### Details

The following functions enable conversion to `nanoarrow` and `arrow`.
Conversion kindly provided by "paleolimbot / Dewey Dunnington" Author of
`nanoarrow`. Currently these conversions are the fastest way to convert
from polars to R.

### Value

-   a nanoarrow array stream

<!-- -->

-   a nanoarrow array schema

<!-- -->

-   an arrow table

<!-- -->

-   an arrow record batch reader

### Examples

```r
library(nanoarrow)
df = pl$DataFrame(mtcars)
nanoarrow_array_stream = as_nanoarrow_array_stream(df)
rdf = as.data.frame(nanoarrow_array_stream)
print(head(rdf))
nanoarrow_array_schema = infer_nanoarrow_schema(df)
print(nanoarrow_array_schema)
library(arrow)
arrow_table = as_arrow_table(df)
print(arrow_table)
arrow_record_batch_reader = as_record_batch_reader(df) #requires arrow
print(arrow_record_batch_reader)
```


---
## Object

### Description

One SEXP of Rtype: "externalptr" + a class attribute

### Usage

    object

### Format

An object of class `character` of length 1.

### Details

-   `object$method()` calls are facilitated by a `⁠$.ClassName⁠`- s3method
    see 'R/after-wrappers.R'

-   Code completion is facilitted by `.DollarNames.ClassName`-s3method
    see e.g. 'R/dataframe\_\_frame.R'

-   Implementation of property-methods as DataFrame\_columns() and
    syntax checking is an extension to `⁠$.ClassName⁠` See function
    macro\_add\_syntax\_check\_to\_class().

### Examples

```r
#all a polars object is made of:
some_polars_object = pl$DataFrame(iris)
str(some_polars_object) #External Pointer tagged with a class attribute.
```


---
## Ok

### Description

Wrap in Ok

### Usage

    Ok(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Ok-result


---
## Or else

### Description

map an Err part of Result

### Usage

    or_else(x, f)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any R object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>f</code></td>
<td><p>a closure that takes the ok part as input, must return a result
itself</p></td>
</tr>
</tbody>
</table>

### Value

same R object wrapped in a Err-result


---
## Pcase

### Description

Inspired by data.table::fcase + dplyr::case\_when. Used instead of
base::switch internally.

### Usage

    pcase(..., or_else = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>odd arugments are bool statements, a next even argument is
returned if prior bool statement is the first true</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>or_else</code></td>
<td><p>return this if no bool statements were true</p></td>
</tr>
</tbody>
</table>

### Details

Lifecycle: perhaps replace with something written in rust to speed up a
bit

### Value

any return given first true bool statement otherwise value of or\_else

### Examples

```r
n = 7
polars:::pcase(
 n<5,"nope",
 n>6,"yeah",
 or_else = stopf("failed to have a case for n=%s",n)
)
```


---
## Pl concat

### Description

Concat polars objects

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>l</code></td>
<td><p>list of DataFrame, or Series, LazyFrame or Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rechunk</code></td>
<td><p>perform a rechunk at last</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>how</code></td>
<td><p>choice of bind direction "vertical"(rbind) "horizontal"(cbind)
"diagnoal" diagonally</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>parallel</code></td>
<td><p>BOOL default TRUE, only used for LazyFrames</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame, or Series, LazyFrame or Expr

### Examples

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


---
## Pl date range

### Description

new date\_range

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>low</code></td>
<td><p>POSIXt or Date preferably with time_zone or double or
integer</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>high</code></td>
<td><p>POSIXt or Date preferably with time_zone or double or integer. If
high is and interval are missing, then single datetime is
constructed.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>interval</code></td>
<td><p>string pl_duration or R difftime. Can be missing if high is
missing also.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>lazy</code></td>
<td><p>bool, if TRUE return expression</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>closed</code></td>
<td><p>option one of 'both'(default), 'left', 'none' or 'right'</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>name</code></td>
<td><p>name of series</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>time_unit</code></td>
<td><p>option string ("ns" "us" "ms") duration of one int64 value on
polars side</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>time_zone</code></td>
<td><p>optional string describing a timezone.</p></td>
</tr>
</tbody>
</table>

### Details

If param time\_zone is not defined the Series will have no time zone.

NOTICE: R POSIXt without defined timezones(tzone/tz), so called naive
datetimes, are counter intuitive in R. It is recommended to always set
the timezone of low and high. If not output will vary between local
machine timezone, R and polars.

In R/r-polars it is perfectly fine to mix timezones of params
time\_zone, low and high.

### Value

a datetime

### Examples

```r
# All in GMT, straight forward, no mental confusion
s_gmt = pl$date_range(
  as.POSIXct("2022-01-01",tz = "GMT"),
  as.POSIXct("2022-01-02",tz = "GMT"),
  interval = "6h", time_unit = "ms", time_zone = "GMT"
)
s_gmt
s_gmt$to_r() #printed same way in R and polars becuase tagged with a time_zone/tzone

# polars assumes any input in GMT if time_zone = NULL, set GMT on low high to see same print
s_null = pl$date_range(
  as.POSIXct("2022-01-01",tz = "GMT"),
  as.POSIXct("2022-01-02",tz = "GMT"),
  interval = "6h", time_unit = "ms", time_zone = NULL
)
s_null$to_r() #back to R POSIXct. R prints non tzone tagged POSIXct in local timezone.


#Any mixing of timezones is fine, just set them all, and it works as expected.
t1 = as.POSIXct("2022-01-01", tz = "Etc/GMT+2")
t2 = as.POSIXct("2022-01-01 08:00:00", tz = "Etc/GMT-2")
s_mix = pl$date_range(low = t1, high = t2, interval = "1h", time_unit = "ms", time_zone = "CET")
s_mix
s_mix$to_r()


#use of ISOdate
t1 = ISOdate(2022,1,1,0) #preset GMT
t2 = ISOdate(2022,1,2,0) #preset GMT
pl$date_range(t1,t2,interval = "4h", time_unit = "ms", time_zone = "GMT")
```


---
## Pl Datetime

### Description

Datetime DataType constructor

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>tu</code></td>
<td><p>string option either "ms", "us" or "ns"</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>tz</code></td>
<td><p>string the Time Zone, see details</p></td>
</tr>
</tbody>
</table>

### Format

function

### Details

all allowed TimeZone designations can be found in `base::OlsonNames()`

### Value

Datetime DataType

### Examples

```r
pl$Datetime("ns","Pacific/Samoa")
```


---
## Pl Field

### Description

Create Field

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>string name</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>datatype</code></td>
<td><p>DataType</p></td>
</tr>
</tbody>
</table>

### Details

A Field is not a DataType but a name + DataType Fields are used in
Structs-datatypes and Schemas to represent everything of the
Series/Column except the raw values.

### Value

a list DataType with an inner DataType

### Examples

```r
#make a struct
pl$Field("city_names",pl$Utf8)

# find any DataType bundled pl$dtypes
print(pl$dtypes)
```


---
## Pl List

### Description

Create List DataType

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>datatype</code></td>
<td><p>an inner DataType</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

a list DataType with an inner DataType

### Examples

```r
pl$List(pl$List(pl$Boolean))
```


---
## Pl PTime

### Description

Store Time in R

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>an integer or double vector of n epochs since midnight OR a char
vector of char times passed to as.POSIXct converted to seconds.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>tu</code></td>
<td><p>timeunit either "s","ms","us","ns"</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>fmt</code></td>
<td><p>a format string passed to as.POSIXct format via ...</p></td>
</tr>
</tbody>
</table>

### Details

PTime should probably be replaced with package nanotime or similar.

base R is missing encoding of Time since midnight "s" "ms", "us" and
"ns". The latter "ns" is the standard for the polars Time type.

Use PTime to convert R doubles and integers and use as input to polars
functions which needs a time.

Loosely inspired by data.table::ITime which is i32 only. PTime must
support polars native timeunit is nanoseconds. The R double(float64) can
imitate a i64 ns with full precision within the full range of 24 hours.

PTime does not have a time zone and always prints the time as is no
matter local machine time zone.

An essential difference between R and polars is R prints POSIXct/lt
without a timezone in local time. Polars prints Datetime without a
timezone label as is (GMT). For POSIXct/lt taged with a timexone(tzone)
and Datetime with a timezone(tz) the behavior is the same conversion is
intuitive.

It appears behavior of R timezones is subject to change a bit in R
4.3.0, see polars unit test test-expr\_datetime.R/"pl$date\_range Date
lazy/eager".

### Value

a PTime vector either double or integer, with class "PTime" and
attribute "tu" being either "s","ms","us" or "ns"

### Examples

```r
#make PTime in all time units
pl$PTime(runif(5)*3600*24*1E0, tu = "s")
pl$PTime(runif(5)*3600*24*1E3, tu = "ms")
pl$PTime(runif(5)*3600*24*1E6, tu = "us")
pl$PTime(runif(5)*3600*24*1E9, tu = "ns")
pl$PTime("23:59:59")


pl$Series(pl$PTime(runif(5)*3600*24*1E0, tu = "s"))
pl$lit(pl$PTime("23:59:59"))$lit_to_s()

pl$lit(pl$PTime("23:59:59"))$to_r()
```


---
## Pl select

### Description

Select from an empty DataFrame

### Format

method

### Details

param ... expressions passed to select `pl$select` is a shorthand for
`pl$DataFrame(list())$select`

NB param of this function

### Value

DataFrame

### Examples

```r
pl$select(
  pl$lit(1:4)$alias("ints"),
  pl$lit(letters[1:4])$alias("letters")
)
```


---
## Pl Struct

### Description

Struct DataType Constructor

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>datatype</code></td>
<td><p>an inner DataType</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

a list DataType with an inner DataType

### Examples

```r
# create a Struct-DataType
pl$List(pl$List(pl$Boolean))

# Find any DataType via pl$dtypes
print(pl$dtypes)
```


---
## Pl-cash-from arrow

### Description

import Arrow Table or Array

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>data</code></td>
<td><p>arrow Table or Array or ChunkedArray</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool rewrite in one array per column, Implemented for
ChunkedArray Array is already contiguous. Not implemented for Table.
C</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>schema</code></td>
<td><p>named list of DataTypes or char vec of names. Same length as
arrow table. If schema names or types do not match arrow table, the
columns will be renamed/recasted. NULL default is to import columns as
is. Takes no effect for Array or ChunkedArray</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>schema_overrides</code></td>
<td><p>named list of DataTypes. Name some columns to recast by the
DataType. Takes not effect for Array or ChunkedArray</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame or Series

### Examples

```r
pl$from_arrow(
  data = arrow::arrow_table(iris),
  schema_overrides = list(Sepal.Length=pl$Float32, Species = pl$Utf8)
)

char_schema = names(iris)
char_schema[1] = "Alice"
pl$from_arrow(
  data = arrow::arrow_table(iris),
  schema = char_schema
)
```


---
## Pl

### Description

`pl`-object is a environment of all public functions and class
constructors. Public functions are not exported as a normal package as
it would be huge namespace collision with base:: and other functions.
All object-methods are accessed with object$method() via the new class
functions.

Having all functions in an namespace is similar to the rust- and python-
polars api.

### Usage

    pl

### Format

An object of class `environment` of length 57.

### Details

If someone do not particularly like the letter combination `pl`, they
are free to bind the environment to another variable name as
`simon_says = pl` or even do `attach(pl)`

### Examples

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


---
## Polars options

### Description

get, set, reset polars options

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>strictly_immutable</code></td>
<td><p>bool, default = TRUE, keep polars strictly immutable.
Polars/arrow is in general pro "immutable objects". However pypolars API
has some minor exceptions. All settable property elements of classes are
mutable. Why?, I guess python just do not have strong stance on
immutability. R strongly suggests immutable objects, so why not make
polars strictly immutable where little performance costs? However, if to
mimic pypolars as much as possible, set this to FALSE.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>named_exprs</code></td>
<td><p>bool, default = FALSE, allow named exprs in e.g. select,
with_columns, groupby, join. a named expresion will be extended with
$alias(name) wildcards or expression producing multiple are problematic
due to name collision the related option in py-polars is currently
called 'pl.Config.with_columns_kwargs' and only allow named exprs in
with_columns (or potentially any method derived there of)</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>no_messages</code></td>
<td><p>bool, default = FALSE, turn of messages</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>do_not_repeat_call</code></td>
<td><p>bool, default = FALSE, turn of messages</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>any options to modify</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>return_replaced_options</code></td>
<td><p>return previous state of modified options Convenient for
temporarily swapping of options during testing.</p></td>
</tr>
</tbody>
</table>

### Details

who likes polars package messages? use this option to turn them off.

do not print the call causing the error in error messages

modifing list takes no effect, pass it to pl$set\_polars\_options
get/set/resest interact with internal env `polars:::polars_optenv`

setting an options may be rejected if not passing opt\_requirements

### Value

current settings as list

current settings as list

list named by options of requirement function input must satisfy

### Examples

```r
#rename columns by naming expression, experimental requires option named_exprs = TRUE
pl$set_polars_options(named_exprs = TRUE)
pl$DataFrame(iris)$with_columns(
  pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
  SW_add_2 = (pl$col("Sepal.Width")+2)
)
 pl$get_polars_options()
pl$set_polars_options(strictly_immutable = FALSE)
pl$get_polars_options()


#setting strictly_immutable = 42 will be rejected as
tryCatch(
  pl$set_polars_options(strictly_immutable = 42),
  error= function(e) print(e)
)

#reset options like this
pl$reset_polars_options()
#use get_polars_opt_requirements() to requirements
pl$get_polars_opt_requirements()
```


---
## Polars runtime flags

### Description

This environment is used internally for the package to remember what has
been going on. Currently only used to throw one-time warnings()

### Usage

    runtime_state

### Format

An object of class `environment` of length 0.


---
## PolarsBackgroundHandle is exhausted

### Description

PolarsBackgroundHandle

### Usage

    PolarsBackgroundHandle_is_exhausted()

### Value

Bool

### Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
handle$is_exhausted()
df = handle$join()
handle$is_exhausted()
```


---
## PolarsBackgroundHandle join

### Description

PolarsBackgroundHandle

### Usage

    PolarsBackgroundHandle_join()

### Value

DataFrame

### Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
df = handle$join()
```


---
## Prepare alpha

### Description

internal function for emw\_x expressions

### Usage

    prepare_alpha(com = NULL, span = NULL, half_life = NULL, alpha = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>com</code></td>
<td><p>numeric or NULL</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>span</code></td>
<td><p>numeric or NULL</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>half_life</code></td>
<td><p>numeric or NULL</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>alpha</code></td>
<td><p>numeric or NULL</p></td>
</tr>
</tbody>
</table>

### Value

numeric


---
## Print env

### Description

print recursively an environment, used in some documentation

### Usage

    print_env(api, name, max_depth = 10)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>api</code></td>
<td><p>env</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>name</code></td>
<td><p>name of env</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>max_depth</code></td>
<td><p>numeric/int max levels to recursive iterate through</p></td>
</tr>
</tbody>
</table>


---
## Print-open-paren-close-paren

### Description

s3 method print DataFrame

### Usage

    ## S3 method for class 'DataFrame'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
pl$DataFrame(iris)
```


---
## Print.Expr

### Description

Print expr

### Usage

    ## S3 method for class 'Expr'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>Expr</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
pl$col("some_column")$sum()$over("some_other_column")
```


---
## Print.GroupBy

### Description

print GroupBy

### Usage

    ## S3 method for class 'GroupBy'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
pl$DataFrame(iris)$groupby("Species")
```


---
## Print.LazyFrame

### Description

print LazyFrame s3 method

### Usage

    ## S3 method for class 'LazyFrame'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
print(pl$DataFrame(iris)$lazy())
```


---
## Print.LazyGroupBy

### Description

print LazyGroupBy

### Usage

    ## S3 method for class 'LazyGroupBy'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>LazyGroupBy</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self


---
## Print.PolarsBackgroundHandle

### Description

print LazyFrame s3 method

### Usage

    ## S3 method for class 'PolarsBackgroundHandle'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataFrame</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
handle$is_exhausted()
df = handle$join()
handle$is_exhausted()
```


---
## Print.PTime

### Description

print PTime

### Usage

    ## S3 method for class 'PTime'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a PTime vector</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

invisible x


---
## Print.RField

### Description

Print a polars Field

### Usage

    ## S3 method for class 'RField'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataType</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
print(pl$Field("foo",pl$List(pl$UInt64)))
```


---
## Print.RPolarsDataType

### Description

print a polars datatype

### Usage

    ## S3 method for class 'RPolarsDataType'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>DataType</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
pl$dtypes$Boolean #implicit print
```


---
## Print.When

### Description

print When

### Usage

    ## S3 method for class 'When'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>When object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
print(pl$when(pl$col("a")>2))
```


---
## Print.WhenThen

### Description

print When

### Usage

    ## S3 method for class 'WhenThen'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>When object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
print(pl$when(pl$col("a")>2)$then(pl$lit("more than two")))
```


---
## Print.WhenThenThen

### Description

print When

### Usage

    ## S3 method for class 'WhenThenThen'
    print(x, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>When object</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

self

### Examples

```r
#
print(pl$when(pl$col("a")>2)$then(pl$lit("more than two"))$when(pl$col("b")<5))
```


---
## Pstop

### Description

DEPRECATED USE stopf instead

### Usage

    pstop(err, call = sys.call(1L))

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>err</code></td>
<td><p>error msg string</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>call</code></td>
<td><p>calling context</p></td>
</tr>
</tbody>
</table>

### Value

throws an error

### Examples

```r
f = function() polars:::pstop("this aint right!!")
tryCatch(f(), error = \(e) as.character(e))
```


---
## Read csv 

### Description

high level csv\_reader, will download if path is url

### Usage

    read_csv_(path, lazy = FALSE, reuse_downloaded = TRUE, ...)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>path</code></td>
<td><p>file or url</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>lazy</code></td>
<td><p>bool default FALSE, read csv lazy</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>reuse_downloaded</code></td>
<td><p>bool default TRUE, cache url downloaded files in session an
reuse</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>arguments forwarded to csv_reader or lazy_csv_reader</p></td>
</tr>
</tbody>
</table>

### Value

polars\_DataFrame or polars\_lazy\_DataFrame

### Examples

```r
df = pl$read_csv("https://j.mp/iriscsv")
```


---
## Replace private with pub methods

### Description

extendr places the naked internal calls to rust in env-classes. This
function can be used to delete them and replaces them with the public
methods. Which are any function matching pattern typically '^CLASSNAME'
e.g. '^DataFrame\_' or '^Series\_'. Likely only used in zzz.R

### Usage

    replace_private_with_pub_methods(
      env,
      class_pattern,
      keep = c(),
      remove_f = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>env</code></td>
<td><p>class envrionment to modify. Envs are mutable so no return
needed</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>class_pattern</code></td>
<td><p>a regex string matching declared public functions of that
class</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>keep</code></td>
<td><p>list of unmentioned methods to keep in public api</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>remove_f</code></td>
<td><p>bool if true, will move methods, not copy</p></td>
</tr>
</tbody>
</table>

### Value

side effects only


---
## Restruct list

### Description

lifecycle:: Deprecate Restruct an object where structs where previously
unnested

### Usage

    restruct_list(l)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>l</code></td>
<td><p>list</p></td>
</tr>
</tbody>
</table>

### Details

It was much easier impl export unnested struct from polars. This
function restructs exported unnested structs. This function should be
repalced with rust code writing this output directly before nesting.
This hack relies on rust uses the tag "is\_struct" to mark what should
be re-structed.

### Value

restructed list


---
## RField name

### Description

get/set Field name

### Usage

    RField_name()

### Value

name

### Examples

```r
field = pl$Field("Cities",pl$Utf8)

#get name / datatype
field$name
field$datatype

#set + get values
field$name = "CityPoPulations" #<- is fine too
field$datatype = pl$UInt32

print(field)
```


---
## RField print

### Description

Print a polars Field

### Usage

    RField_print()

### Value

self

### Examples

```r
print(pl$Field("foo",pl$List(pl$UInt64)))
```


---
## Same outer datatype

### Description

check if x is a valid RPolarsDataType

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>lhs</code></td>
<td><p>an RPolarsDataType</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rhs</code></td>
<td><p>an RPolarsDataType</p></td>
</tr>
</tbody>
</table>

### Value

bool TRUE if outer datatype is the same.

### Examples

```r
# TRUE
pl$same_outer_dt(pl$Datetime("us"),pl$Datetime("ms"))
pl$same_outer_dt(pl$List(pl$Int64),pl$List(pl$Float32))

#FALSE
pl$same_outer_dt(pl$Int64,pl$Float64)
```


---
## Scan arrow ipc

### Description

Import data in Apache Arrow IPC format

### Usage

    scan_arrow_ipc(
      path,
      n_rows = NULL,
      cache = TRUE,
      rechunk = TRUE,
      row_count_name = NULL,
      row_count_offset = 0L,
      memmap = TRUE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>path</code></td>
<td><p>string, path</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n_rows</code></td>
<td><p>integer, limit rows to scan</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>cache</code></td>
<td><p>bool, use cache</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool, rechunk reorganize memory layout, potentially make future
operations faster, however perform reallocation now.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>row_count_name</code></td>
<td><p>NULL or string, if a string add a rowcount column named by this
string</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>row_count_offset</code></td>
<td><p>integer, the rowcount column can be offst by this value</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>memmap</code></td>
<td><p>bool, mapped memory</p></td>
</tr>
</tbody>
</table>

### Details

Create new LazyFrame from Apache Arrow IPC file or stream

### Value

LazyFrame


---
## Scan parquet

### Description

new LazyFrame from parquet file

### Usage

    scan_parquet(
      file,
      n_rows = NULL,
      cache = TRUE,
      parallel = c("Auto", "None", "Columns", "RowGroups"),
      rechunk = TRUE,
      row_count_name = NULL,
      row_count_offset = 0L,
      low_memory = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>file</code></td>
<td><p>string filepath</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>n_rows</code></td>
<td><p>limit rows to scan</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>cache</code></td>
<td><p>bool use cache</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>parallel</code></td>
<td><p>String either Auto, None, Columns or RowGroups. The way to
parralize the scan.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool rechunk reorganize memory layout, potentially make future
operations faster , however perform reallocation now.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>row_count_name</code></td>
<td><p>NULL or string, if a string add a rowcount column named by this
string</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>row_count_offset</code></td>
<td><p>integer, the rowcount column can be offst by this value</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>low_memory</code></td>
<td><p>bool, try reduce memory footprint</p></td>
</tr>
</tbody>
</table>

### Value

LazyFrame

### Examples

```r
#TODO write parquet example
```


---
## Series abs

### Description

Take absolute value of Series

### Usage

    Series_abs()

### Value

Series

### Examples

```r
pl$Series(-2:2)$abs()
```


---
## Series add

### Description

Series arithmetics

### Usage

    Series_add(other)

    ## S3 method for class 'Series'
    s1 + s2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series or into Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>s1</code></td>
<td><p>lhs Series</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>s2</code></td>
<td><p>rhs Series or any into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:3)$add(11:13)
pl$Series(1:3)$add(pl$Series(11:13))
pl$Series(1:3)$add(1L)
1L + pl$Series(1:3)
pl$Series(1:3) + 1L
```


---
## Series alias

### Description

Change name of Series

### Usage

    Series_alias(name)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>a String as the new name</p></td>
</tr>
</tbody>
</table>

### Format

An object of class `character` of length 1.

### Value

Series

### Examples

```r
pl$Series(1:3,name = "alice")$alias("bob")
```


---
## Series all

### Description

Reduce Boolean Series with ALL

### Usage

    Series_all()

### Value

bool

### Examples

```r
pl$Series(c(TRUE,TRUE,NA))$all()
```


---
## Series any

### Description

Reduce Boolean Series with ANY

### Usage

    Series_any()

### Value

bool

### Examples

```r
pl$Series(c(TRUE,FALSE,NA))$any()
```


---
## Series append

### Description

append two Series, see details for mutability

### Usage

    Series_append(other, immutable = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series to append</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>immutable</code></td>
<td><p>bool should append be immutable, default TRUE as mutable
operations should be avoided in plain R API's.</p></td>
</tr>
</tbody>
</table>

### Details

if immutable = FLASE, the Series object will not behave as immutable.
This mean appending to this Series will affect any variable pointing to
this memory location. This will break normal scoping rules of R.
Polars-clones are cheap. Mutable operations are likely never needed in
any sense.

### Value

Series

### Examples

```r
#default immutable behaviour, s_imut and s_imut_copy stay the same
s_imut = pl$Series(1:3)
s_imut_copy = s_imut
s_new = s_imut$append(pl$Series(1:3))
identical(s_imut$to_r_vector(),s_imut_copy$to_r_vector())

#pypolars-like mutable behaviour,s_mut_copy become the same as s_new
s_mut = pl$Series(1:3)
s_mut_copy = s_mut
 #must deactivate this to allow to use immutable=FALSE
pl$set_polars_options(strictly_immutable = FALSE)
s_new = s_mut$append(pl$Series(1:3),immutable= FALSE)
identical(s_new$to_r_vector(),s_mut_copy$to_r_vector())
```


---
## Series apply

### Description

About as slow as regular non-vectorized R. Similar to using R sapply on
a vector.

### Usage

    Series_apply(
      fun,
      datatype = NULL,
      strict_return_type = TRUE,
      allow_fail_eval = FALSE
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>fun</code></td>
<td><p>r function, should take a scalar value as input and return
one.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>datatype</code></td>
<td><p>DataType of return value. Default NULL means same as
input.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict_return_type</code></td>
<td><p>bool, default TRUE: fail on wrong return type, FALSE: convert to
polars Null</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>allow_fail_eval</code></td>
<td><p>bool, default FALSE: raise R fun error, TRUE: convert to polars
Null</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
s = pl$Series(letters[1:5],"ltrs")
f = \(x) paste(x,":",as.integer(charToRaw(x)))
s$apply(f,pl$Utf8)

#same as
pl$Series(sapply(s$to_r(),f),s$name)
```


---
## Series arg max

### Description

idx to max value

### Usage

    Series_arg_max

### Format

An object of class `character` of length 1.

### Value

bool

### Examples

```r
pl$Series(c(5,1))$arg_max()
```


---
## Series arg min

### Description

idx to min value

### Usage

    Series_arg_min

### Format

An object of class `character` of length 1.

### Value

bool

### Examples

```r
pl$Series(c(5,1))$arg_min()
```


---
## Series arr

### Description

Create an object namespace of all list related methods. See the
individual method pages for full details

### Usage

    Series_arr()

### Value

Expr

### Examples

```r
s = pl$Series(list(1:3,1:2,NULL))
s
s$arr$first()
```


---
## Series ceil

### Description

Ceil of this Series

### Usage

    Series_ceil()

### Value

bool

### Examples

```r
pl$Series(c(.5,1.999))$ceil()
```


---
## Series chunk lengths

### Description

Get the Lengths of Series memory chunks as vector.

### Usage

    Series_chunk_lengths

### Format

An object of class `character` of length 1.

### Value

numeric vector. Length is number of chunks. Sum of lengths is equal to
size of Series.

### Examples

```r
chunked_series = c(pl$Series(1:3),pl$Series(1:10))
chunked_series$chunk_lengths()
```


---
## Series class

### Description

The `Series`-class is simply two environments of respectively the public
and private methods/function calls to the polars rust side. The
instanciated `Series`-object is an `externalptr` to a lowlevel rust
polars Series object. The pointer address is the only statefullness of
the Series object on the R side. Any other state resides on the rust
side. The S3 method `.DollarNames.Series` exposes all public
`⁠$foobar()⁠`-methods which are callable onto the object. Most methods
return another `Series`-class instance or similar which allows for
method chaining. This class system in lack of a better name could be
called "environment classes" and is the same class system extendr
provides, except here there is both a public and private set of methods.
For implementation reasons, the private methods are external and must be
called from polars:::.pr.$Series$methodname(), also all private methods
must take any self as an argument, thus they are pure functions. Having
the private methods as pure functions solved/simplified self-referential
complications.

### Details

Check out the source code in R/Series\_frame.R how public methods are
derived from private methods. Check out extendr-wrappers.R to see the
extendr-auto-generated methods. These are moved to .pr and converted
into pure external functions in after-wrappers.R. In zzz.R (named zzz to
be last file sourced) the extendr-methods are removed and replaced by
any function prefixed `Series_`.

### Examples

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


---
## Series clone

### Description

Rarely useful as Series are nearly 100% immutable Any modification of a
Series should lead to a clone anyways.

### Usage

    Series_clone

### Format

An object of class `character` of length 1.

### Value

Series

### Examples

```r
s1 = pl$Series(1:3);
s2 =  s1$clone();
s3 = s1
pl$mem_address(s1) != pl$mem_address(s2)
pl$mem_address(s1) == pl$mem_address(s3)
```


---
## Series compare

### Description

compare two Series

### Usage

    Series_compare(other, op)

    ## S3 method for class 'Series'
    s1 == s2

    ## S3 method for class 'Series'
    s1 != s2

    ## S3 method for class 'Series'
    s1 < s2

    ## S3 method for class 'Series'
    s1 > s2

    ## S3 method for class 'Series'
    s1 <= s2

    ## S3 method for class 'Series'
    s1 >= s2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>A Series or something a Series can be created from</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>op</code></td>
<td><p>the chosen operator a String either: 'equal', 'not_equal', 'lt',
'gt', 'lt_eq' or 'gt_eq'</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>s1</code></td>
<td><p>lhs Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>s2</code></td>
<td><p>rhs Series or any into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:5) == pl$Series(c(1:3,NA_integer_,10L))
```


---
## Series cumsum

### Description

Get an array with the cumulative sum computed at every element.

### Usage

    Series_cumsum(reverse = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool, default FALSE, if true roll over vector from back to
forth</p></td>
</tr>
</tbody>
</table>

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

### Value

Series

### Examples

```r
pl$Series(c(1:2,NA,3,NaN,4,Inf))$cumsum()
pl$Series(c(1:2,NA,3,Inf,4,-Inf,5))$cumsum()
```


---
## Series div

### Description

Series arithmetics

### Usage

    Series_div(other)

    ## S3 method for class 'Series'
    s1 / s2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series or into Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>s1</code></td>
<td><p>lhs Series</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>s2</code></td>
<td><p>rhs Series or any into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:3)$div(11:13)
pl$Series(1:3)$div(pl$Series(11:13))
pl$Series(1:3)$div(1L)
2L / pl$Series(1:3)
pl$Series(1:3) / 2L
```


---
## Series dtype

### Description

Get data type of Series

Get data type of Series

### Usage

    Series_dtype()

    Series_flags()

### Details

property sorted flags are not settable, use set\_sorted

### Value

DataType

DataType

### Examples

```r
pl$Series(1:4)$dtype
pl$Series(c(1,2))$dtype
pl$Series(letters)$dtype
pl$Series(1:4)$sort()$flags
```


---
## Series expr

### Description

Call an expression on a Series See the individual Expr method pages for
full details

### Usage

    Series_expr()

### Details

This is a shorthand of writing something like
`pl$DataFrame(s)$select(pl$col("sname")$expr)$to_series(0)`

This subnamespace is experimental. Submit an issue if anything
unexpected happend.

### Value

Expr

### Examples

```r
s = pl$Series(list(1:3,1:2,NULL))
s$expr$first()
s$expr$alias("alice")
```


---
## Series floor

### Description

Floor of this Series

### Usage

    Series_floor()

### Value

numeric

### Examples

```r
pl$Series(c(.5,1.999))$floor()
```


---
## Series is numeric

### Description

return bool whether series is numeric

### Usage

    Series_is_numeric()

### Format

method

### Details

true of series dtype is member of pl$numeric\_dtypes

### Value

bool

### Examples

```r
 pl$Series(1:4)$is_numeric()
 pl$Series(c("a","b","c"))$is_numeric()
 pl$numeric_dtypes
```


---
## Series is sorted

### Description

is\_sorted

### Usage

    Series_is_sorted(reverse = FALSE, nulls_last = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>order sorted</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>nulls_last</code></td>
<td><p>bool where to keep nulls, default same as reverse</p></td>
</tr>
</tbody>
</table>

### Details

property sorted flags are not settable, use set\_sorted

### Value

DataType

### Examples

```r
pl$Series(1:4)$sort()$is_sorted()
```


---
## Series len

### Description

Length of this Series.

### Usage

    Series_len

### Format

An object of class `character` of length 1.

### Value

numeric

### Examples

```r
pl$Series(1:10)$len()
```


---
## Series max

### Description

Reduce Series with max

### Usage

    Series_max

### Format

An object of class `character` of length 1.

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before maxming to
prevent overflow issues.

### Value

Series

### Examples

```r
pl$Series(c(1:2,NA,3,5))$max() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$max() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$max() # Inf-Inf is NaN
```


---
## Series min

### Description

Reduce Series with min

### Usage

    Series_min

### Format

An object of class `character` of length 1.

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before minming to
prevent overflow issues.

### Value

Series

### Examples

```r
pl$Series(c(1:2,NA,3,5))$min() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$min() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$min() # Inf-Inf is NaN
```


---
## Series mul

### Description

Series arithmetics

### Usage

    Series_mul(other)

    ## S3 method for class 'Series'
    s1 * s2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series or into Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>s1</code></td>
<td><p>lhs Series</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>s2</code></td>
<td><p>rhs Series or any into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:3)$mul(11:13)
pl$Series(1:3)$mul(pl$Series(11:13))
pl$Series(1:3)$mul(1L)
2L * pl$Series(1:3)
pl$Series(1:3) * 2L
```


---
## Series name

### Description

Get name of Series

### Usage

    Series_name()

### Value

String the name

### Examples

```r
pl$Series(1:3,name = "alice")$name
```


---
## Series print

### Description

Print Series

Print Series

### Usage

    ## S3 method for class 'Series'
    print(x, ...)

    Series_print()

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>...</code></td>
<td><p>not used</p></td>
</tr>
</tbody>
</table>

### Value

invisible(self)

self

### Examples

```r
print(pl$Series(1:3))
pl$Series(1:3)
```


---
## Series rem

### Description

Series arithmetics, remainder

### Usage

    Series_rem(other)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series or into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:4)$rem(2L)
pl$Series(1:3)$rem(pl$Series(11:13))
pl$Series(1:3)$rem(1L)
```


---
## Series rename

### Description

Rename a series

### Usage

    Series_rename(name, in_place = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>name</code></td>
<td><p>string the new name</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>in_place</code></td>
<td><p>bool rename in-place, breaks immutability If true will throw an
error unless this option has been set:
<code>pl$set_polars_options(strictly_immutable = FALSE)</code></p></td>
</tr>
</tbody>
</table>

### Format

method

### Value

bool

### Examples

```r
pl$Series(1:4,"bob")$rename("alice")
```


---
## Series rep

### Description

duplicate and concatenate a series

### Usage

    Series_rep(n, rechunk = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>n</code></td>
<td><p>number of times to repeat</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>rechunk</code></td>
<td><p>bool default true, reallocate object in memory. If FALSE the
Series will take up less space, If TRUE calculations might be
faster.</p></td>
</tr>
</tbody>
</table>

### Format

method

### Details

This function in not implemented in pypolars

### Value

bool

### Examples

```r
pl$Series(1:2,"bob")$rep(3)
```


---
## Series series equal

### Description

Check if series is equal with another Series.

### Usage

    Series_series_equal(other, null_equal = FALSE, strict = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series to compare with</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>null_equal</code></td>
<td><p>bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by
strict.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>strict</code></td>
<td><p>bool if TRUE, do not allow similar DataType comparison. Overrides
null_equal.</p></td>
</tr>
</tbody>
</table>

### Format

method

### Value

bool

### Examples

```r
pl$Series(1:4,"bob")$series_equal(pl$Series(1:4))
```


---
## Series set sorted

### Description

Set sorted

### Usage

    Series_set_sorted(reverse = FALSE, in_place = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool if TRUE, signals series is Descendingly sorted, otherwise
Ascendingly.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>in_place</code></td>
<td><p>if TRUE, will set flag mutably and return NULL. Remember to use
pl$set_polars_options(strictly_immutable = FALSE) otherwise an error
will be thrown. If FALSE will return a cloned Series with set_flag which
in the very most cases should be just fine.</p></td>
</tr>
</tbody>
</table>

### Value

Series invisible

### Examples

```r
s = pl$Series(1:4)$set_sorted()
s$flags
```


---
## Series shape

### Description

Shape of series

### Usage

    Series_shape()

### Value

dimension vector of Series

### Examples

```r
identical(pl$Series(1:2)$shape, 2:1)
```


---
## Series sort

### Description

Sort this Series

### Usage

    Series_sort(reverse = FALSE, in_place = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>reverse</code></td>
<td><p>bool reverse(descending) sort</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>in_place</code></td>
<td><p>bool sort mutable in-place, breaks immutability If true will
throw an error unless this option has been set:
<code>pl$set_polars_options(strictly_immutable = FALSE)</code></p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(c(1,NA,NaN,Inf,-Inf))$sort()
```


---
## Series std

### Description

Get the standard deviation of this Series.

### Usage

    Series_std(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>“Delta Degrees of Freedom”: the divisor used in the calculation
is N - ddof, where N represents the number of elements. By default ddof
is 1.</p></td>
</tr>
</tbody>
</table>

### Format

method

### Value

bool

### Examples

```r
pl$Series(1:4,"bob")$std()
```


---
## Series sub

### Description

Series arithmetics

### Usage

    Series_sub(other)

    ## S3 method for class 'Series'
    s1 - s2

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>other</code></td>
<td><p>Series or into Series</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>s1</code></td>
<td><p>lhs Series</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>s2</code></td>
<td><p>rhs Series or any into Series</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
pl$Series(1:3)$sub(11:13)
pl$Series(1:3)$sub(pl$Series(11:13))
pl$Series(1:3)$sub(1L)
1L - pl$Series(1:3)
pl$Series(1:3) - 1L
```


---
## Series sum

### Description

Reduce Series with sum

### Usage

    Series_sum

### Format

An object of class `character` of length 1.

### Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to
prevent overflow issues.

### Value

Series

### Examples

```r
pl$Series(c(1:2,NA,3,5))$sum() # a NA is dropped always
pl$Series(c(1:2,NA,3,NaN,4,Inf))$sum() # NaN carries / poisons
pl$Series(c(1:2,3,Inf,4,-Inf,5))$sum() # Inf-Inf is NaN
```


---
## Series to frames

### Description

Series to DataFrame

### Usage

    Series_to_frame()

### Format

method

### Value

Series

### Examples

```r
pl$Series(1:4,"bob")$to_frame()
```


---
## Series to lit

### Description

convert Series to literal to perform modification and return

### Usage

    Series_to_lit()

### Value

Expr

### Examples

```r
(
  pl$Series(list(1:1, 1:2, 1:3, 1:4))
  $print()
  $to_lit()
$arr$lengths()
$sum()
$cast(pl$dtypes$Int8)
  $lit_to_s()
)
```


---
## Series to r

### Description

return R list (if polars Series is list) or vector (any other polars
Series type)

return R vector (implicit unlist)

return R list (implicit as.list)

### Usage

    Series_to_r()

    Series_to_r_vector()

    Series_to_r_list()

### Details

Fun fact: Nested polars Series list must have same inner type, e.g.
List(List(Int32)) Thus every leaf(non list type) will be placed on the
same depth of the tree, and be the same type.

### Value

R list or vector

R vector

R list

### Examples

```r
#make polars Series_Utf8
series_vec = pl$Series(letters[1:3])

#Series_non_list
series_vec$to_r() #as vector because Series DataType is not list (is Utf8)
series_vec$to_r_list() #implicit call as.list(), convert to list
series_vec$to_r_vector() #implicit call unlist(), same as to_r() as already vector


#make nested Series_list of Series_list of Series_Int32
#using Expr syntax because currently more complete translated
series_list = pl$DataFrame(list(a=c(1:5,NA_integer_)))$select(
  pl$col("a")$list()$list()$append(
(
  pl$col("a")$head(2)$list()$append(
pl$col("a")$tail(1)$list()
  )
)$list()
  )
)$get_column("a") # get series from DataFrame

#Series_list
series_list$to_r() #as list because Series DataType is list
series_list$to_r_list() #implicit call as.list(), same as to_r() as already list
series_list$to_r_vector() #implicit call unlist(), append into a vector
 #
 #
```


---
## Series value count

### Description

Value Counts as DataFrame

### Usage

    Series_value_counts(sorted = TRUE, multithreaded = FALSE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>sorted</code></td>
<td><p>bool, default TRUE: sort table by value; FALSE: random</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>multithreaded</code></td>
<td><p>bool, default FALSE, process multithreaded. Likely faster to have
TRUE for a big Series. If called within an already multithreaded context
such calling apply on a GroupBy with many groups, then likely slightly
faster to leave FALSE.</p></td>
</tr>
</tbody>
</table>

### Value

DataFrame

### Examples

```r
pl$Series(iris$Species,"flower species")$value_counts()
```


---
## Series var

### Description

Get the standard deviation of this Series.

### Usage

    Series_var(ddof = 1)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>ddof</code></td>
<td><p>“Delta Degrees of Freedom”: the divisor used in the calculation
is N - ddof, where N represents the number of elements. By default ddof
is 1.</p></td>
</tr>
</tbody>
</table>

### Format

method

### Value

bool

### Examples

```r
pl$Series(1:4,"bob")$var()
```


---
## Series

### Description

found in api as pl$Series named Series\_constructor internally

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>any vector</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>name</code></td>
<td><p>string</p></td>
</tr>
</tbody>
</table>

### Value

Series

### Examples

```r
{
pl$Series(1:4)
}
```


---
## Str string

### Description

Simple viewer of an R object based on str()

### Usage

    str_string(x, collapse = " ")

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>object to view.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>collapse</code></td>
<td><p>word to glue possible multilines with</p></td>
</tr>
</tbody>
</table>

### Value

string

### Examples

```r
polars:::str_string(list(a=42,c(1,2,3,NA)))
```


---
## Struct

### Description

Collect several columns into a Series of dtype Struct.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>exprs</code></td>
<td><p>Columns/Expressions to collect into a Struct.</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>eager</code></td>
<td><p>Evaluate immediately.</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>schema</code></td>
<td><p>Optional schema named list that explicitly defines the struct
field dtypes. Each name must match a column name wrapped in the struct.
Can only be used to cast some or all dtypes, not to change the names.
NULL means to include keep columns into the struct by their current
DataType. If a column is not included in the schema it is removed from
the final struct.</p></td>
</tr>
</tbody>
</table>

### Details

pl$struct creates Expr or Series of DataType Struct() pl$Struct creates
the DataType Struct() In polars a schema is a named list of DataTypes.
\#' A schema describes e.g. a DataFrame. More formally schemas consist
of Fields. A Field is an object describing the name and DataType of a
column/Series, but same same. A struct is a DataFrame wrapped into a
Series, the DataType is Struct, and each sub-datatype within are Fields.
In a dynamic language schema and a Struct (the DataType) are quite the
same, except schemas describe DataFrame and Struct's describe some
Series.

### Value

Eager=FALSE: Expr of Series with dtype Struct | Eager=TRUE: Series with
dtype Struct

### Examples

```r
#isolated expression to wrap all columns in a struct aliased 'my_struct'
pl$struct(pl$all())$alias("my_struct")

#wrap all column into on column/Series
df = pl$DataFrame(
  int = 1:2,
  str = c("a", "b"),
  bool = c(TRUE, NA),
  list = list(1:2, 3L)
)$select(
  pl$struct(pl$all())$alias("my_struct")
)

print(df)
print(df$schema) #returns a schema, a named list containing one element a Struct named my_struct

# wrap two columns in a struct and provide a schema to set all or some DataTypes by name
e1 = pl$struct(
  pl$col(c("int","str")),
  schema = list(int=pl$Int64, str=pl$Utf8)
)$alias("my_struct")
# same result as e.g. wrapping the columns in a struct and casting afterwards
e2 = pl$struct(
  list(pl$col("int"),pl$col("str"))
)$cast(
  pl$Struct(int=pl$Int64,str=pl$Utf8)
)$alias("my_struct")

df = pl$DataFrame(
  int = 1:2,
  str = c("a", "b"),
  bool = c(TRUE, NA),
  list = list(1:2, 3L)
)

#verify equality in R
identical(df$select(e1)$to_list(),df$select(e2)$to_list())

df$select(e2)
df$select(e2)$as_data_frame()
```


---
## Sum

### Description

syntactic sugar for starting a expression with sum

### Arguments

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd" data-valign="top">
<td><code>...</code></td>
<td><p>is a: If one arg:</p>
<ul>
<li><p>Series or Expr, same as <code>column$sum()</code></p></li>
<li><p>string, same as <code>pl$col(column)$sum()</code></p></li>
<li><p>numeric, same as <code>pl$lit(column)$sum()</code></p></li>
<li><p>list of strings(column names) or exprressions to add up as expr1
+ expr2 + expr3 + ...</p></li>
</ul>
<p>If several args, then wrapped in a list and handled as
above.</p></td>
</tr>
</tbody>
</table>

### Value

Expr

### Examples

```r
#column as string
pl$DataFrame(iris)$select(pl$sum("Petal.Width"))

#column as Expr (prefer pl$col("Petal.Width")$sum())
pl$DataFrame(iris)$select(pl$sum(pl$col("Petal.Width")))

#column as numeric
pl$DataFrame()$select(pl$sum(1:5))

#column as list
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c")))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", 42L)))

#three eqivalent lines
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", pl$sum(list("a","b","c")))))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list(pl$col("a")+pl$col("b"),"c")))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("*")))
```


---
## To list

### Description

return polars DataFrame as R lit of vectors

### Usage

    DataFrame_to_list(unnest_structs = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>unnest_structs</code></td>
<td><p>bool default true, as calling $unnest() on any struct
column</p></td>
</tr>
</tbody>
</table>

### Details

This implementation for simplicity reasons relies on unnesting all
structs before exporting to R. unnest\_structs = FALSE, the previous
struct columns will be re- nested. A struct in a R is a lists of lists,
where each row is a list of values. Such a structure is not very typical
or efficient in R.

### Value

R list of vectors

### Examples

```r
pl$DataFrame(iris)$to_list()
```


---
## UnAsIs

### Description

Reverts wrapping in I

### Usage

    unAsIs(X)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>X</code></td>
<td><p>any Robj wrapped in 'I()“</p></td>
</tr>
</tbody>
</table>

### Details

https://stackoverflow.com/questions/12865218/getting-rid-of-asis-class-attribute

### Value

X without any AsIs subclass


---
## Unwrap

### Description

rust-like unwrapping of result. Useful to keep error handling on the R
side.

### Usage

    unwrap(result, context = NULL, call = sys.call(1L))

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>result</code></td>
<td><p>a list here either element ok or err is NULL, or both if ok is
litteral NULL</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>context</code></td>
<td><p>a msg to prefix a raised error with</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>call</code></td>
<td><p>context of error or string</p></td>
</tr>
</tbody>
</table>

### Value

the ok-element of list , or a error will be thrown

### Examples

```r
structure(list(ok = "foo", err = NULL), class = "extendr_result")

tryCatch(
  unwrap(
structure(
  list(ok = NULL, err = "something happen on the rust side"),
  class = "extendr_result"
)
  ),
  error = function(err) as.character(err)
)
```


---
## Verify method call

### Description

internal function to check method call of env\_classes

### Usage

    verify_method_call(
      Class_env,
      Method_name,
      call = sys.call(1L),
      class_name = NULL
    )

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>Class_env</code></td>
<td><p>env_class object (the classes created by
extendr-wrappers.R)</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>Method_name</code></td>
<td><p>name of method requested by user</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>call</code></td>
<td><p>context to throw user error, just use default</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>class_name</code></td>
<td><p>NULLs</p></td>
</tr>
</tbody>
</table>

### Value

invisible(NULL)


---
## When then otherwise

### Description

Start a “when, then, otherwise” expression.

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>predicate</code></td>
<td><p>Into Expr into a boolean mask to branch by</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>expr</code></td>
<td><p>Into Expr value to insert in when() or otherwise()</p></td>
</tr>
</tbody>
</table>

### Details

For the impl nerds: pl$when returns a whenthen object and whenthen
returns whenthenthen, except for otherwise(), which will terminate and
return an Expr. Otherwise may fail to return an Expr if e.g. two
consecutive `when(x)$when(y)`

### Value

Expr

### Examples

```r
  df = pl$DataFrame(mtcars)
  wtt =
pl$when(pl$col("cyl")<=4)$then("<=4cyl")$
when(pl$col("cyl")<=6)$then("<=6cyl")$
otherwise(">6cyl")$alias("cyl_groups")
  print(wtt)
  df$with_columns(wtt)
```


---
## Wrap e result

### Description

wrap as Expression capture ok/err as result

### Usage

    wrap_e_result(e, str_to_lit = TRUE, argname = NULL)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>e</code></td>
<td><p>an Expr(polars) or any R expression</p></td>
</tr>
<tr class="even" data-valign="top">
<td><code>str_to_lit</code></td>
<td><p>bool should string become a column name or not, then a literal
string</p></td>
</tr>
<tr class="odd" data-valign="top">
<td><code>argname</code></td>
<td><p>if error, blame argument of this name</p></td>
</tr>
</tbody>
</table>

### Details

used internally to ensure an object is an expression and to catch any
error

### Value

Expr

### Examples

```r
pl$col("foo") < 5
```


---
## Wrap e

### Description

wrap as literal

### Usage

    wrap_e(e, str_to_lit = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>e</code></td>
<td><p>an Expr(polars) or any R expression</p></td>
</tr>
</tbody>
</table>

### Details

used internally to ensure an object is an expression

### Value

Expr

### Examples

```r
pl$col("foo") < 5
```


---
## Wrap elist result

### Description

make sure all elementsof a list is wrapped as Expr Capture any
conversion error in the result

### Usage

    wrap_elist_result(elist, str_to_lit = TRUE)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>elist</code></td>
<td><p>a list Expr or any R object Into (passable to pl$lit)</p></td>
</tr>
</tbody>
</table>

### Details

Used internally to ensure an object is a list of expression The output
is wrapped in a result, which can contain an ok or err value.

### Value

Expr

### Examples

```r
polars:::wrap_elist_result(list(pl$lit(42),42,1:3))
```


---
## Wrap proto schema

### Description

wrap proto schema

### Usage

    wrap_proto_schema(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>either schema, or incomplete schema where dataType can be NULL or
schema is just char vec, implicitly the same as if all DataType are
NULL, mean undefinesd.</p></td>
</tr>
</tbody>
</table>

### Format

function

### Value

bool

### Examples

```r
polars:::wrap_proto_schema(c("alice","bob"))
polars:::wrap_proto_schema(list("alice"=pl$Int64,"bob"=NULL))
```


---
## Wrap s

### Description

input is either already a Series of will be passed to the Series
constructor

### Usage

    wrap_s(x)

### Arguments

<table>
<tbody>
<tr class="odd" data-valign="top">
<td><code>x</code></td>
<td><p>a Series or something-turned-into-Series</p></td>
</tr>
</tbody>
</table>

### Value

Series


---
