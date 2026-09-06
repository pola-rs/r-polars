# alpha

    Code
      df$select(cs$alpha(TRUE, TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$alpha()`:
      ! Evaluation failed in `$alpha()`.
      Caused by error in `cs$alpha()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# alphanumeric

    Code
      df$select(cs$alphanumeric(TRUE, TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$alphanumeric()`:
      ! Evaluation failed in `$alphanumeric()`.
      Caused by error in `cs$alphanumeric()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# by_dtype

    Code
      df$select(cs$by_dtype(a = pl$String))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$by_dtype()`:
      ! Evaluation failed in `$by_dtype()`.
      Caused by error in `cs$by_dtype()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = pl$String

# by_name

    Code
      df$select(cs$by_name(a = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$by_name()`:
      ! Evaluation failed in `$by_name()`.
      Caused by error in `cs$by_name()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = "foo"

# single-argument selector interfaces deprecate dynamic dots

    Code
      cs$by_name("foo", "bar")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_name()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Output
      cs.by_name('foo', 'bar', require_all=true)

---

    Code
      cs$by_name(!!!c("foo", "bar"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_name()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Output
      cs.by_name('foo', 'bar', require_all=true)

---

    Code
      cs$by_name()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `cs$by_name()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.
    Output
      cs.by_name(require_all=true)

---

    Code
      cs$by_dtype(pl$Date, pl$String)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_dtype()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `dtypes` argument instead.
    Output
      cs.by_dtype([Date, String])

---

    Code
      cs$by_dtype(!!!list(pl$Date, pl$String))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_dtype()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `dtypes` argument instead.
    Output
      cs.by_dtype([Date, String])

---

    Code
      cs$by_dtype()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `cs$by_dtype()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `dtypes` instead.
    Output
      cs.by_dtype([])

---

    Code
      cs$by_name("bar", names = "foo")
    Condition <rlang_error>
      Error in `cs$by_name()`:
      ! Evaluation failed in `$by_name()`.
      Caused by error in `cs$by_name()`:
      ! Can't combine `names` with positional values in `...`.

---

    Code
      cs$by_name(c("foo", "bar"), "baz")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_name()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `cs$by_name()`:
      ! Evaluation failed in `$by_name()`.
      Caused by error in `cs$by_name()`:
      ! `...` must be a list of single strings, not a list.

---

    Code
      cs$by_dtype(list(pl$Date), pl$String)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `cs$by_dtype()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `dtypes` argument instead.
    Condition <rlang_error>
      Error in `cs$by_dtype()`:
      ! Evaluation failed in `$by_dtype()`.
      Caused by error in `cs$by_dtype()`:
      ! Dynamic dots `...` must be polars data types, got a list

# contains

    Code
      df$select(cs$contains("ba", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$contains()`:
      ! Evaluation failed in `$contains()`.
      Caused by error in `cs$contains()`:
      ! `...` must be a list of single strings, not a list.

---

    Code
      df$select(cs$contains("ba", NA_character_))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$contains()`:
      ! Evaluation failed in `$contains()`.
      Caused by error in `cs$contains()`:
      ! `...` must be a list of single strings, not a list.

# ends_with

    Code
      df$select(cs$ends_with("z", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$ends_with()`:
      ! Evaluation failed in `$ends_with()`.
      Caused by error in `cs$ends_with()`:
      ! `...` must be a list of single strings, not a list.

# exclude

    Code
      df$select(cs$exclude("^b.*$", pl$Int32, 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$exclude()`:
      ! Evaluation failed in `$exclude()`.
      Caused by error in `cs$exclude()`:
      ! `...` can only contain column names, regexes, polars data types or polars selectors.

# starts_with

    Code
      df$select(cs$starts_with("b", 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `cs$starts_with()`:
      ! Evaluation failed in `$starts_with()`.
      Caused by error in `cs$starts_with()`:
      ! `...` must be a list of single strings, not a list.

