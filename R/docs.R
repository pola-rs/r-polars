

#' Translation definitions across python, R and polars.
#' @description  The meaning and naming differencies of values across languages.
#' @param limit Number of consecutive null values to fill. Default R NULL is no limit.
#' @keywords docs
#' @name docs_translations
#' @aliases docs_translations
#' @format info
#' @details
#'
#' Comments for how R and python world translates into polars:
#'
#' R and python are both high-level glue languages great for DataScience.
#' Rust is a pedantic low-level language with similar use cases as C and C++.
#' Polars is written in ~100k lines of rust and has a rust API. Py-polars the python API for polars,
#' is implemented as an interface with the rust API. Rust is statically typed, and much
#' of the 20k py-polars code is about providing the dynamic coding experience of polars.
#' Minipolars is very parallel to py-polars except it interfaces with R. The performance and behavior
#' are unexpectedly quite similar as the 'engine' is the exact same rust code.
#'
#' # Translation details
#'
#' ## Missingness
#' R has allocated a value in every vector type  to signal missingness, these are collectively called `NAs`.
#' Polars uses a bool bitmask to signal `NA`-like missing value and it is called `Null` and `Nulls` in plural.
#' Not to confuse with R `NULL` (see paragraph below).
#' Polars supports missingness for any possible type as it kept separately in the bitmask.
#' Inside python lists of values uses the symbol `None` as a similar meaning.
#' R NA ~ polars Null ~ py-polars [None] (in a py list) #any R vector type that has a NA

#' ## Sorting and comparisons
#' Writing Tests for all implemetations have brought me to the conclusions that polars does not have a
#' fully concistent nor well documented behavior when it comes to comparisons and sorting of floats.
#' Though some genereal thumb rules do apply:
#' Polars have chosen to define in sorting that `Null` is a value lower than -Inf.
#' `NaN` is sometimes a value higher than Inf, sometimes regarded as `Null` sometimes ignored,
#' Polars conventions  NaN > Inf > 99 > -99 > -Inf > Null
#' `Null == Null` yields often times false, sometimes true, sometimes `Null`.
#'
#'
#' ## Floating points
#' R NaN is similar to Polars NaN and py-polars float("NaN"). However polars NaN is a part of the
#' floating point standard, and is not as fast as the `Null`-bitmask, nor is it vsuper concistently implmented
#' across polars sorting methods. It is best to minimize use of NaN values for speed and clarity. If you
#' decide to use both NaN, just spend the extra time to test-out the NaN-behavior, as the documentation
#' will not hint too much. Inf translates quite as is. NaN's are sometimes bigger than Inf, sometimes dropped and
#' sometimes something else.
#' R NaN ~ polars NaN ~ python [float("NaN")] #only in floats
#' R Inf ~ polars inf  ~ python [float("inf")] #only floats
#'
#' ## NULL IS NOT Null is not NULL
#' The R NULL does not exist inside polars frames and series and so on. It resembles a Option::None in
#' the hidden rust code. It resembles the python `None`. In all three langues the NULL/None/None
#' are used as a function argument to signal default behavior or perhaps a deactivated feature.
#' R `NULL` is very much NOT like polars `Null`.
#' R NULL ~ rust-polars Option::None ~ pypolars None  #typically used for function argument
#'
#' ## LISTS, FRAMES and DICTs
#' The following translations are relevant when loading data into polars. The R list appears
#' similar to python dictionary, but is implemented more similar to the python list.
#' However, in minipolars both lists and data.frame can be used to construct a polars DataFrame, just a
#' dictionaries would be used in python.
#' R data.frame/list ~ polars DataFrame ~ python dictonary
#'
#' ## Series and Vectors
#' The R vector (Integer, Double, Character, ...) resembles the Series as both aew free floating from any
#' frame and can be of any length. The implementaion is quite different. E.g. for-loop appending to an R
#' is considered quite bad for performance, as the vector will be rewritten in memory for every append.
#' The polars Series support chunked memory allocation, which allows any new data to be written only.
#' However fragmented memory is not great for fast computations and polars objects have a rechunk()-method,
#' to reallocate chunks into one. Rechunk might be called implicitly by polars.
#' R vector ~ polars Series/column ~ python list
#'
#' ## Expressions
#' The polars Expr do not have any base R counterpart. Expr are analogous to how ggplot split plotting instructions from
#' the rendering. Base R plot immediately pushes any instruction by adding e.g. pixels to a .png canvas. `ggplot` collects
#' instructions and in the end when executed the rendering can be performed with optimization across all instructions.
#' Btw `ggplot` command-syntax is a monoid meaning the order does not matter, that is not the case for polars Expr.
#' Polars Expr's can be understood as a DSL (domain specific language) that expresses syntax trees of instructions. R
#' expressions evaluate to syntax trees also, but it difficult to optimize the execution order automaticly, without rewriting the
#' code. A great selling point of Polars is that any query will be optimized. Expr are very light-weight symbols chained together.
NULL
