# Development

This package has a unique structure for several reasons,
so here are some points that may help with development.

For more general information on development, please refer to the following documents:

- [Savvy User Guide](https://yutannihilation.github.io/savvy/guide/): How to create R packages using savvy.
- [Tidyverse style guide](https://style.tidyverse.org/): Coding style for the R part.
- [Tidy design principles](https://design.tidyverse.org/): Principles for designing R packages in the Tidyverse ecosystem.

## System Requirements

To install the development version of Polars or develop new features, you must install some tools outside of R.

- [rustup](https://rustup.rs/)
- [CMake](https://cmake.org/)

Note that the `Taskfile.yml` used by [Task](https://taskfile.dev/) in the root directory of the repository
provides some useful commands (e.g. `task build-documents` to build all R documents).

If you have access to a [Dev Container](https://containers.dev/) execution environment
such as [GitHub Codespaces](https://github.com/features/codespaces) or [DevPod](https://devpod.sh/),
you can work within a container that contains all of the above tools.

## Translation from Python Polars

### Basic Translation

R Polars is an R binding for Polars, which mimics Python Polars using savvy instead of pyo3 and R instead of Python.
Let's briefly check the differences between them and see how to implement functions/methods that exist in Python Polars in R Polars.

For example, the `sum` method of Expr in Python Polars is defined as follows in the Rust side:

```rust
use polars::lazy::dsl::Expr;
use pyo3::prelude::*;

#[pyclass]
#[repr(transparent)]
#[derive(Clone)]
pub struct PyExpr {
    pub inner: Expr,
}

#[pymethods]
impl PyExpr {
    fn sum(&self) -> Self {
        self.inner.clone().sum().into()
    }
}
```

_source: `crates/polars-python/src/expr/general.rs` of <https://github.com/pola-rs/polars>_

The equivalent in R Polars would be:

```rust
use polars::lazy::dsl::Expr;
use savvy::{savvy, Result};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRExpr {
    pub inner: Expr,
}

#[savvy]
impl PlRExpr {
    fn sum(&self) -> Result<Self> {
        Ok(self.inner.clone().sum().into())
    }
}
```

_source: `src/rust/src/expr/general.rs` of this repository_

These two look almost the same except for the difference in the name of the struct (`PyExpr` and `PlRExpr`).

One of the differences between the two is that in savvy, all functions must return `savvy::Result`,
so we need to wrap the result with `Ok` here.

In Python Polars, classes that are tied to structs defined on the Rust side (`PyExpr` here) are not directly exposed to users.
Instead, classes that wrap the classes defined on the Rust side are defined on the Python side.
The same structure is followed in R Polars as well.
So let's compare the definition of the `sum` method of the Python `Expr` class that wraps `PyExpr`
and the R `polars_expr` class that wraps `PlRExpr`.

The `Expr` class and the `sum` method are defined as follows in Python Polars:

```python
class Expr:
    _pyexpr: PyExpr = None

    @classmethod
    def _from_pyexpr(cls, pyexpr: PyExpr) -> Expr:
        expr = cls.__new__(cls)
        expr._pyexpr = pyexpr
        return expr

    def sum(self) -> Expr:
        return self._from_pyexpr(self._pyexpr.sum())
```

_source: `py-polars/polars/expr/expr.py` of <https://github.com/pola-rs/polars>_

That `Expr` class stores a `PyExpr` as a member `_pyexpr` and calls the `sum` method of `PyExpr`
(defined on the Rust side) in the `sum` method.

R Polars follows the same structure as Python Polars,
and the `polars_expr` class is defined as follows:

```r
wrap.PlRExpr <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x

  # snip

  class(self) <- c("polars_expr", "polars_object")
  self
}

expr__sum <- function() {
  self$`_rexpr`$sum() |>
    wrap()
}
```

_source: `R/expr-expr.R` of this repository_

Some points:

1. Just like `PyExpr` was stored in `Expr` as `_pyexpr`, `polars_expr` also stores `PlRExpr` in `_rexpr`.
2. `polars_expr` objects are constructed by passing `PlRExpr` to the generic function `wrap()`.
   So, calling a function that returns `PlRExpr` defined on the Rust side and passing it to `wrap()` will result in a `polars_expr` object.
3. Methods must be defined as functions with a specific prefix, such as `expr__sum`.
   This is because the prefix `expr__` is a marker for registering the function as a member of the `polars_expr__methods` environment
   (done in `zzz.R`), so the `sum` method is defined as the `expr__sum` function.
   Members of the `polars_expr__methods` environment are called via the `$` operator on `polars_expr` objects.

Check that the `sum` method works using the `pl$lit()` function that returns a `polars_expr` object.

```r
pl$lit(1)$sum
#> function() {
#>   self$`_rexpr`$sum() |>
#>     wrap()
#> }
#> <environment: 0x55a0ade0d368>

pl$lit(1)$sum()
#> dyn float: 1.0.sum()
```

### Rust Function Arguments

Functions created with savvy have very limited types that can be used as arguments.

For example, let's look at the `select` method of `LazyFrame` defined in Python Polars.

```rust
use crate::prelude::*;
use crate::PyExpr;
use pyo3::prelude::*;

#[pyclass]
#[repr(transparent)]
#[derive(Clone)]
pub struct PyLazyFrame {
    pub ldf: LazyFrame,
}

#[pymethods]
impl PyLazyFrame {
    fn select(&mut self, exprs: Vec<PyExpr>) -> Self {
        let ldf = self.ldf.clone();
        let exprs = exprs.to_exprs();
        ldf.select(exprs).into()
    }
}
```

_source: `crates/polars-python/src/lazyframe/general.rs` of <https://github.com/pola-rs/polars>_

The `expr` argument of this method is a vector of `PyExpr`. `exprs` is converted from `Vec<PyExpr>` to `Vec<Expr>`
by the `to_exprs` method and used.

To translate this, we need to use `ListSexp`, which is an R list, as an argument in savvy,
and we need to convert `ListSexp` to `Vec<Expr>`.

Such conversion is done through a thin `Wrap` struct defined in the `conversion` module.
(This strategy is the same in Python Polars.)

```rust
use crate::prelude::*;
use crate::PlRExpr;
use savvy::{savvy, ListSexp, Result};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRLazyFrame {
    pub ldf: LazyFrame,
}

#[savvy]
impl PlRLazyFrame {
    fn select(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select(exprs).into())
    }
}
```

_source: `src/rust/src/lazyframe/general.rs` of this repository_

The `Wrap` struct and type conversion implementation are as follows:

```rust
use crate::prelude::*;
use savvy::ListSexp;

#[repr(transparent)]
pub struct Wrap<T>(pub T);

impl From<ListSexp> for Wrap<Vec<Expr>> {
    fn from(list: ListSexp) -> Self {
        // snip
    }
}
```

_source: `src/rust/src/conversion/mod.rs` of this repository_

### R Function Arguments

#### Arguments Should Be Named

When mimicking _keyword-only_ arguments (arguments that must be specified as named arguments) in Python Polars,
we place these arguments after the `...` argument and use `rlang::check_dots_empty0()` function
to raise an error if any arguments are passed by position.

For example, the `Expr.any()` method in Python Polars is defined as follows:

```python
class Expr:
    # snip
    def any(self, *, ignore_nulls: bool = True) -> Expr:
        return self._from_pyexpr(self._pyexpr.any(ignore_nulls))
```

_source: `py-polars/polars/expr/expr.py` of <https://github.com/pola-rs/polars>_

This is defined as follows in R Polars:

```r
expr__any <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$any(ignore_nulls)
  })
}
```

_source: `R/expr-expr.R` of this repository_

Thanks to `rlang::check_dots_empty0()`, if we try to pass the argument by position, an error will be raised.

```r
pl$lit(1)$any(TRUE)
#> Error:
#> ! Evaluation failed in `$any()`.
#> Caused by error:
#> ! `...` must be empty.
#> ✖ Problematic argument:
#> • ..1 = TRUE
#> ℹ Did you forget to name an argument?
#> Run `rlang::last_trace()` to see where the error occurred.
```

#### Dynamic Dots

Variable length arguments in Python (like `*args` or `**kwargs`) can be implemented in R using `...`.
In R, we can use `rlang::list2()` to handle these arguments, which is a feature known as Dynamic Dots.

For example, the `LazyFrame.select()` method in Python Polars is defined as follows:

```python
class LazyFrame:
    # snip
    def select(
        self, *exprs: IntoExpr | Iterable[IntoExpr], **named_exprs: IntoExpr
    ) -> LazyFrame:
        structify = bool(int(os.environ.get("POLARS_AUTO_STRUCTIFY", 0)))

        pyexprs = parse_into_list_of_expressions(
            *exprs, **named_exprs, __structify=structify
        )
        return self._from_pyldf(self._ldf.select(pyexprs))
```

_source: `py-polars/polars/lazyframe/frame.py` of <https://github.com/pola-rs/polars>_

The `parse_into_list_of_expressions` function is responsible for converting the variable-length arguments
(`*exprs` and `**named_exprs`) into a list of expressions.

In R Polars, `parse_into_list_of_expressions` is implemented as follows:

```r
parse_into_list_of_expressions <- function(..., `__structify` = FALSE) {
  list2(...) |>
    lapply(\(x) as_polars_expr(x, structify = `__structify`)$`_rexpr`)
}
```

_source: `R/utils-parse-expr.R` of this repository_

This function is called in the `select` method, handling variable-length arguments,
as same as in Python Polars:

```r
lazyframe__select <- function(...) {
  wrap({
    structify <- parse_env_auto_structify()

    parse_into_list_of_expressions(..., `__structify` = structify) |>
      self$`_ldf`$select()
  })
}
```

_source: `R/lazyframe-frame.R` of this repository_

## Value Conversion between Polars and R

Value conversion between Polars and R is quite different from Python Polars.
This is related to the fact that R is centered around vectors, while Polars is centered around Series.

- R to Polars: via the generic function `as_polars_series()`
- Polars to R: via `PlRSeries::to_r_vector()`

### R to Polars

For example, the method to convert an R double vector to a Series is defined as follows,
calling a function defined on the Rust side:

```r
#' @export
as_polars_series <- function(x, name = NULL, ...) {
  UseMethod("as_polars_series")
}

#' @export
as_polars_series.double <- function(x, name = NULL, ...) {
  PlRSeries$new_f64(name %||% "", x) |>
    wrap()
}
```

_source: `R/as_polars_series.R` of this repository_

Rust side implementation of `PlRSeries::new_f64` is as follows:

```rust
use crate::{PlRSeries, prelude::*};
use savvy::{RealSexp, Result, savvy};

#[savvy]
impl PlRSeries {
    fn new_f64(name: &str, values: RealSexp) -> Result<Self> {
        let ca: Float64Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }
}
```

_source: `src/rust/src/series/construction.rs` of this repository_

This function should be the only one that generates Polars' Float64 type values by referencing R values.

Thus, operations like creating a Float64 literal Expression using the `lit()`
function will internally call `as_polars_series()` to generate the Expression via Series.

```r
pl$lit(1.0)
#> 1.0
```

### Polars to R

Exporting a Series to an R vector is done through a single large Rust function.

```rust
#[savvy]
impl PlRSeries {
    pub fn to_r_vector(
        &self,
        // snip
    ) -> Result<Sexp> {
        // snip
    }
}
```

_source: `src/rust/src/series/export.rs` of this repository_

This is called from the following function on the R side:

```r
series__to_r_vector <- function(
  ...,
  # snip
) {
  wrap({
    check_dots_empty0(...)
    # snip
    self$`_s`$to_r_vector(
      # snip
    )
  })
}
```

_source: `R/series-to_r_vector.R` of this repository_

Exporting R values from Polars is always done through this function.
The class of the exported R vector can be controlled by the arguments passed to this function.
For example, the `int64` argument controls how Int64 dtype Series are exported to R vectors.

```r
series__to_r_vector <- function(
  ...,
  # snip
  int64 = c("double", "character", "integer", "integer64"),
  # snip
) {
  # snip
}
```

_source: `R/series-to_r_vector.R` of this repository_

```rust
#[savvy]
impl PlRSeries {
    pub fn to_r_vector(
        // snip
        int64: &str,
        // snip
    ) -> Result<Sexp> {
        // snip
    }
}
```

_source: `src/rust/src/series/export.rs` of this repository_

## Writing and Running Tests

The tests in this package are written using the [testthat](https://testthat.r-lib.org/) package,
and parameterized tests use the [patrick](https://github.com/google/patrick) package.

For example, we can write parameterized tests like this:

```r
patrick::with_parameters_test_that(
  "arrow RecordBatchReader and Tabular objects support",
  .cases = {
    skip_if_not_installed("arrow")
    tibble::tribble(
      ~.test_name, ~construct_function,
      "table", arrow::as_arrow_table,
      "record_batch", arrow::as_record_batch,
      "record_batch_reader", arrow::as_record_batch_reader,
    )
  },
  code = {
    obj <- data.frame(
      int = 1:2,
      chr = letters[1:2],
      lst = I(list(TRUE, NA))
    ) |>
      construct_function()

    series_default <- as_polars_series(obj)
    series_named <- as_polars_series(obj, name = "foo")

    expect_s3_class(series_default, "polars_series")
    expect_identical(series_named$name, "foo")
    expect_snapshot(print(series_default))
  }
)
```

_source: `tests/testthat/test-as_polars_series.R` of this repository_

There are several helper functions to write concise tests for LazyFrame and DataFrame,
so please use them when testing the behavior of queries.

```r
test_that("select works lazy/eager", {
  .data <- pl$DataFrame(
    int32 = 1:5,
    int64 = as_polars_series(1:5)$cast(pl$Int64),
    string = letters[1:5],
  )

  expect_query_equal(
    .input$select("int32"),
    .data,
    pl$DataFrame(int32 = 1:5)
  )
})
```

_source: `tests/testthat/test-lazyframe-frame.R` of this repository_
