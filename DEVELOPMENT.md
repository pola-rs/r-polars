# Development

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

Some points:

1. Just like `PyExpr` was stored in `Expr` as `_pyexpr`, `polars_expr` also stores `PlRExpr` in `_rexpr`.
2. `polars_expr` objects are constructed by passing `PlRExpr` to the generic function `wrap()`.
   So, calling a function that returns `PlRExpr` defined on the Rust side and passing it to `wrap()` will result in a `polars_expr` object.
3. Methods must be defined as functions with a specific prefix, such as `expr__sum`.
   This is because the prefix `expr__` is a marker for registering the function as a member of the `polars_expr` class object,
   so the `sum` method is defined as the `expr__sum` function.
   The part that registers these functions as members of `wrap.PlRExpr()` is written in the snipped part of the `wrap.PlRExpr()` function.

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

### Type Conversion on the Rust Side

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

### Argument check on the R side

Want to check arguments on the R side, use functions from the imported `rlang` package.
One common function is `check_dots_empty0()`, which checks that `...` is empty.

When using such functions, wrap the entire process with `wrap({})` and catch errors that occur on the R side with the `wrap()` function.
This will display more informative error messages.

Cases where we need to check that `...` is empty are when simulating methods with keyword-only arguments,
such as the `Expr.any()` method in Python Polars below.

```python
class Expr:
    # snip
    def any(self, *, ignore_nulls: bool = True) -> Expr:
        return self._from_pyexpr(self._pyexpr.any(ignore_nulls))
```

For example, if you pass a value to `...` in the `any()` method of Expr defined as follows in R Polars:

```r
expr__any <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$any(ignore_nulls)
  })
}
```

Display an error message like this:

```r
pl$lit(1)$any(foo = 1)
#> Error:
#> ! Evaluation failed in `$any()`.
#> Caused by error:
#> ! `...` must be empty.
#> ✖ Problematic argument:
#> • foo = 1
#> Run `rlang::last_trace()` to see where the error occurred.
```

Note that `ignore_nulls` is directly passed to the Rust side and checked there, so there is no need to check it on the R side.

```r
pl$lit(1)$any(ignore_nulls = 1)
#> Error:
#> ! Evaluation failed in `$any()`.
#> Caused by error:
#> ! Argument `ignore_nulls` must be logical, not double
#> Run `rlang::last_trace()` to see where the error occurred.
```
