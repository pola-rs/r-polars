
### Major

- Evaluate examples in "Reference" pages
- Code autolinking? It is not possible to autolink `polars` functions because they are not exported by `polars` (e.g `polars::DataFrame()` errors). This is also a problem with `pkgdown`. It is possible to autolink functions from other packages but do we actually use other packages in docs?
- Some minor formatting issues in the "Reference" pages, e.g there's the word "data" before the page title sometimes
- Finish categorizing docs (how do we classify `Expr_` fns, or `arr_fns`?)
- Clean docs in R files so that they work without problems with `mkdocs` (see template below)
- See if it is possible to replace usage section in md files and not in R files so that R CMD check doesn't complain about those 
- Do we keep a `vignettes` folder and automatically convert vignettes to markdown for the docs or do we write vignettes/articles directly in the docs?
- Deal with strange formatting of tables 


### Minor

- use same color theme as the py-polars docs?
- same logo?


### Function documentation in R files


#### General class

Template:

```
#' Title + description
#'
#' @params
#'
#' @return 
#'
#' @rdname CATEGORY_class <----------- IMPORTANT
#'
#' @examples

foo = function()
```

Example:
```
#' Create polars DataFrame
#' 
#' Some description if needed...
#'
#' @return data.frame
#'
#' @rdname DataFrame_class <----------- IMPORTANT
#'
#' @examples
#' df = pl$DataFrame(iris[1:3,])
#' df$as_data_frame()

DataFrame = function(...) {
  ...
}
```


#### Method

Template for method:

```
#' Title + description
#'
#' @params
#'
#' @return 
#'
#' @rdname CATEGORY_function_name <----------- IMPORTANT
#'
#' @examples

foo = function()
```

Example:

```
#' Return polars DataFrame as R data.frame
#' 
#' Some description if needed...
#'
#' @param ... any args pased to as.data.frame()
#'
#' @return data.frame
#'
#' @rdname DataFrame_as_data_frame <----------- IMPORTANT
#'
#' @examples
#' df = pl$DataFrame(iris[1:3,])
#' df$as_data_frame()

DataFrame_as_data_frame = function(...) {
  ...
}
```

