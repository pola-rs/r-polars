

#' Translation definitions across python, R and polars.
#' @keywords docs
#' @name docs_translations
#' @aliases docs_translations
#' @format info
#' @description
#'
#' #Comments for how the R and python world translates into polars:
#'
#' R and python are both high-level glue languages great for Data Science.
#' Rust is a pedantic low-level language with similar use cases as C and C++.
#' Polars is written in ~100k lines of rust and has a rust API. Py-polars the python API for polars,
#' is implemented as an interface with the rust API.
#' Minipolars is very parallel to py-polars except it interfaces with R. The performance and behavior
#' are unexpectedly quite similar as the 'engine' is the exact same rust code and data structures.
#'
#' # Translation details
#'
#' ## R and the integerish
#' R only has a native Int32 type, no Uint32, Int64, Uint64 , ... types. These days Int32 is getting a bit small, to
#' refer to more rows than ~ 2^31-1. There are packages which provide int64, but the most normal 'hack' is to
#' just use floats as 'integerish'. There is an unique float64 value for every integer up to about 2^52 which is
#' plenty for all practical concerns. Some minipolars methods may accept or return a floats even though an
#' integer ideally would be more accurate. Most R functions intermix Int32 (integer) and Float64 (double)
#' seamlessly.
#'
#' ## Missingness
#' R has allocated a value in every vector type  to signal missingness, these are collectively called `NAs`.
#' Polars uses a bool bitmask to signal `NA`-like missing value and it is called `Null` and `Nulls` in plural.
#' Not to confuse with R `NULL` (see paragraph below).
#' Polars supports missingness for any possible type as it kept separately in the bitmask.
#' In python lists the symbol `None` can carry a similar meaning.
#' R `NA` ~ polars `Null` ~ py-polars `[None]` (in a py list)
#'
#' ## Sorting and comparisons
#' From writing alot of tests for all implementations, it appears polars does not have a
#' fully consistent nor well documented behavior, when it comes to comparisons and sorting of floats.
#' Though some general thumb rules do apply:
#' Polars have chosen to define in sorting that `Null` is a value lower than `-Inf` as in
#' `Expr.arg_min()` However except when `Null` is ignored `Expr.min()`, there is a `Expr.nan_min()`
#' but no `Expr.nan_min()`.
#' `NaN` is sometimes a value higher than Inf and sometimes regarded as a `Null`.
#' Polars conventions  `NaN` > `Inf` > `99` > `-99` > `-Inf` > `Null`
#' `Null == Null` yields often times false, sometimes true, sometimes `Null`.
#' The documentation or examples do not reveal this variations. The best to do, when in doubt, is  to do
#' test sort on a small Series/Column of all values.
#'
#' #' R `NaN` ~ polars `NaN` ~ python `[float("NaN")]` #only floats have `NaN`s
#'
#' R `Inf` ~ polars `inf`  ~ python [float("inf")] #only floats have `Inf`
#'
#'
#' ## NULL IS NOT Null is not NULL
#' The R NULL does not exist inside polars frames and series and so on. It resembles the Option::None in
#' the hidden rust code. It resembles the python `None`. In all three langues the `NULL`/`None`/`None`
#' are used in this context as function argument to signal default behavior or perhaps a deactivated feature.
#' R `NULL` does NOT translate into the polars bitmask `Null`, that is `NA`.
#' R `NULL` ~ rust-polars `Option::None` ~ pypolars `None`  #typically used for function arguments
#'
#' ## LISTS, FRAMES AND DICTS
#' The following translations are relevant when loading data into polars. The R list appears
#' similar to python dictionary (hashmap), but is implemented more similar to the python list (array of pointers).
#' R list do support string naming elements via a string vector.
#' In minipolars both lists (of vectors or series) and data.frames can be used to construct a polars DataFrame, just a
#' as dictionaries would be used in python. In terms of loading in/out data the follow tranlation holds:
#' R `data.frame`/`list` ~ polars `DataFrame` ~ python `dictonary`
#'
#' ## Series and Vectors
#' The R vector (Integer, Double, Character, ...) resembles the Series as both are external from any
#' frame and can be of any length. The implementation is quite different. E.g. `for`-loop appending to an R
#' vector is considered quite bad for performance. The vector will be fully rewritten in memory for every append.
#' The polars Series has chunked memory allocation, which allows any appened data to be written only.
#' However fragmented memory is not great for fast computations and polars objects have a `rechunk`()-method,
#' to reallocate chunks into one. Rechunk might be called implicitly by polars. In the context of constructing
#' Series and extracting data , the following translation holds:
#' R `vector` ~ polars `Series`/`column` ~ python `list`
#'
#' ## Expressions
#' The polars Expr do not have any base R counterpart. Expr are analogous to how ggplot split plotting instructions from
#' the rendering. Base R plot immediately pushes any instruction by adding e.g. pixels to a .png canvas. `ggplot` collects
#' instructions and in the end when executed the rendering can be performed with optimization across all instructions.
#' Btw `ggplot` command-syntax is a monoid meaning the order does not matter, that is not the case for polars Expr.
#' Polars Expr's can be understood as a DSL (domain specific language) that expresses syntax trees of instructions. R
#' expressions evaluate to syntax trees also, but it difficult to optimize the execution order automaticly, without rewriting the
#' code. A great selling point of Polars is that any query will be optimized. Expr are very light-weight symbols chained together.
#'
NULL
