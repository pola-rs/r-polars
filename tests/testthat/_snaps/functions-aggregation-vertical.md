# vertical aggregation helper dynamic dots are deprecated

    Code
      invisible(pl$all(!!!names))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$all()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$all(!!!character()))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$all()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      invisible(pl$any("a", "b"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$any()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$max(!!!names))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$max()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$min("a", "b"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$min()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$sum(!!!names))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$sum()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$cum_sum("a", "b"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$cum_sum()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

---

    Code
      invisible(pl$sum(!!!dtypes))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$sum()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.

# vertical aggregation helper empty selection is deprecated

    Code
      invisible(pl$any())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$any()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      invisible(pl$max())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$max()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      invisible(pl$min())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$min()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      invisible(pl$sum())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$sum()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      invisible(pl$cum_sum())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$cum_sum()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.

---

    Code
      pl$any(names = character())
    Output
      cs.by_name(require_all=true).any_ignore_nulls()

---

    Code
      pl$max(names = character())
    Output
      cs.by_name(require_all=true).max()

# vertical aggregation helper inputs are validated

    Code
      pl$all(a = "a")
    Condition <rlib_error_dots_named>
      Error in `parse_vertical_agg_input()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = "a"

---

    Code
      pl$all(names = NULL)
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$sum("a", names = "b")
    Condition <rlang_error>
      Error in `parse_vertical_agg_input()`:
      ! Can't combine `names` with positional values in `...`.

---

    Code
      pl$sum("a", 1)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$sum()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$sum(pl$Int64, "a")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$sum()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

