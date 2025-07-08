# list$unique list$sort

    Code
      df$select(pl$all()$list$unique(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$all()$list$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error in `pl$all()$list$unique()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

---

    Code
      df$select(pl$all()$list$sort(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$all()$list$sort()`:
      ! Evaluation failed in `$sort()`.
      Caused by error in `pl$all()$list$sort()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# gather

    Code
      dat$with_columns(pl$col("x")$list$gather(1L, null_on_oob = TRUE))
    Output
      shape: (3, 1)
      ┌───────────┐
      │ x         │
      │ ---       │
      │ list[i32] │
      ╞═══════════╡
      │ [2]       │
      │ [5]       │
      │ [null]    │
      └───────────┘

---

    Code
      dat$with_columns(pl$col("x")$list$gather(list(1), null_on_oob = TRUE))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: list.gather operation not supported for dtypes `list[i32]` and `list[f64]`

---

    Code
      dat$with_columns(pl$col("x")$list$gather(list(c(0:3), 0L, 0L)))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! gather indices are out of bounds

---

    Code
      dat$with_columns(pl$col("x")$list$gather(1, TRUE))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$list$gather()`:
      ! Evaluation failed in `$gather()`.
      Caused by error in `pl$col("x")$list$gather()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# gather_every

    Code
      df$select(out = pl$col("a")$list$gather_every(-1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]

---

    Code
      df$select(out = pl$col("a")$list$gather_every())
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$list$gather_every()`:
      ! Evaluation failed in `$gather_every()`.
      Caused by error in `pl$col("a")$list$gather_every()`:
      ! argument "n" is missing, with no default

---

    Code
      df$select(out = pl$col("a")$list$gather_every(n = 2, offset = -1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]

# join

    Code
      df$select(pl$col("s")$list$join(pl$col("separator"), TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("s")$list$join()`:
      ! Evaluation failed in `$join()`.
      Caused by error in `pl$col("s")$list$join()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# $list$explode() works

    Code
      df$with_columns(pl$col("a")$list$explode())
    Condition
      Error in `df$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 6 to a DataFrame of height 2

# $list$sample() works

    Code
      df$select(pl$col("values")$list$sample(fraction = 2))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: cannot take a larger sample than the total population when `with_replacement=false`

# list$to_struct with field = NULL, n_field_strategy = "first_non_null", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field_0 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = function (x) sprintf("field-%s", x + 1), n_field_strategy = "first_non_null", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field-1 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = ~paste0("field-", . + 1), n_field_strategy = "first_non_null", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field-1 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = NULL, n_field_strategy = "max_width", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field_0 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = function (x) sprintf("field-%s", x + 1), n_field_strategy = "max_width", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field-1 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = ~paste0("field-", . + 1), n_field_strategy = "max_width", upper_bound = 1

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────────┐
      │ field-1 │
      │ ---     │
      │ i64     │
      ╞═════════╡
      │ 1       │
      │ 1       │
      │ 1       │
      └─────────┘

# list$to_struct with field = NULL, n_field_strategy = "first_non_null", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 2       │
      │ 1       ┆ null    │
      └─────────┴─────────┘

# list$to_struct with field = function (x) sprintf("field-%s", x + 1), n_field_strategy = "first_non_null", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field-1 ┆ field-2 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 2       │
      │ 1       ┆ null    │
      └─────────┴─────────┘

# list$to_struct with field = ~paste0("field-", . + 1), n_field_strategy = "first_non_null", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field-1 ┆ field-2 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 2       │
      │ 1       ┆ null    │
      └─────────┴─────────┘

# list$to_struct with field = NULL, n_field_strategy = "max_width", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field_0 ┆ field_1 ┆ field_2 │
      │ ---     ┆ ---     ┆ ---     │
      │ i64     ┆ i64     ┆ i64     │
      ╞═════════╪═════════╪═════════╡
      │ 1       ┆ 2       ┆ null    │
      │ 1       ┆ 2       ┆ 3       │
      │ 1       ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with field = function (x) sprintf("field-%s", x + 1), n_field_strategy = "max_width", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field-1 ┆ field-2 ┆ field-3 │
      │ ---     ┆ ---     ┆ ---     │
      │ i64     ┆ i64     ┆ i64     │
      ╞═════════╪═════════╪═════════╡
      │ 1       ┆ 2       ┆ null    │
      │ 1       ┆ 2       ┆ 3       │
      │ 1       ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with field = ~paste0("field-", . + 1), n_field_strategy = "max_width", upper_bound = 5

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field-1 ┆ field-2 ┆ field-3 │
      │ ---     ┆ ---     ┆ ---     │
      │ i64     ┆ i64     ┆ i64     │
      ╞═════════╪═════════╪═════════╡
      │ 1       ┆ 2       ┆ null    │
      │ 1       ┆ 2       ┆ 3       │
      │ 1       ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with field = "a", n_field_strategy = NA_character_, upper_bound = NA_real_

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i64 │
      ╞═════╡
      │ 1   │
      │ 1   │
      │ 1   │
      └─────┘

# list$to_struct with field = c("a", "b", "c", "d"), n_field_strategy = NA_character_, upper_bound = NA_real_

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields,
        n_field_strategy = n_field_strategy, upper_bound = upper_bound))$unnest(
        "values")
    Output
      shape: (3, 4)
      ┌─────┬──────┬──────┬──────┐
      │ a   ┆ b    ┆ c    ┆ d    │
      │ --- ┆ ---  ┆ ---  ┆ ---  │
      │ i64 ┆ i64  ┆ i64  ┆ i64  │
      ╞═════╪══════╪══════╪══════╡
      │ 1   ┆ 2    ┆ null ┆ null │
      │ 1   ┆ 2    ┆ 3    ┆ null │
      │ 1   ┆ null ┆ null ┆ null │
      └─────┴──────┴──────┴──────┘

