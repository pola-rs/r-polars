# list$to_struct with fields = NULL, n_field_strategy = "first_non_null"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ f64     ┆ f64     │
      ╞═════════╪═════════╡
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ null    │
      └─────────┴─────────┘

# list$to_struct with fields = function (x) sprintf("field-%s", x + 1), n_field_strategy = "first_non_null"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field-1 ┆ field-2 │
      │ ---     ┆ ---     │
      │ f64     ┆ f64     │
      ╞═════════╪═════════╡
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ null    │
      └─────────┴─────────┘

# list$to_struct with fields = ~paste0("field-", . + 1), n_field_strategy = "first_non_null"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field-1 ┆ field-2 │
      │ ---     ┆ ---     │
      │ f64     ┆ f64     │
      ╞═════════╪═════════╡
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ null    │
      └─────────┴─────────┘

# list$to_struct with fields = NULL, n_field_strategy = "max_width"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field_0 ┆ field_1 ┆ field_2 │
      │ ---     ┆ ---     ┆ ---     │
      │ f64     ┆ f64     ┆ f64     │
      ╞═════════╪═════════╪═════════╡
      │ 1.0     ┆ 2.0     ┆ null    │
      │ 1.0     ┆ 2.0     ┆ 3.0     │
      │ 1.0     ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with fields = function (x) sprintf("field-%s", x + 1), n_field_strategy = "max_width"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field-1 ┆ field-2 ┆ field-3 │
      │ ---     ┆ ---     ┆ ---     │
      │ f64     ┆ f64     ┆ f64     │
      ╞═════════╪═════════╪═════════╡
      │ 1.0     ┆ 2.0     ┆ null    │
      │ 1.0     ┆ 2.0     ┆ 3.0     │
      │ 1.0     ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with fields = ~paste0("field-", . + 1), n_field_strategy = "max_width"

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 3)
      ┌─────────┬─────────┬─────────┐
      │ field-1 ┆ field-2 ┆ field-3 │
      │ ---     ┆ ---     ┆ ---     │
      │ f64     ┆ f64     ┆ f64     │
      ╞═════════╪═════════╪═════════╡
      │ 1.0     ┆ 2.0     ┆ null    │
      │ 1.0     ┆ 2.0     ┆ 3.0     │
      │ 1.0     ┆ null    ┆ null    │
      └─────────┴─────────┴─────────┘

# list$to_struct with fields = "a", n_field_strategy = NA_character_

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ f64 │
      ╞═════╡
      │ 1.0 │
      │ 1.0 │
      │ 1.0 │
      └─────┘

# list$to_struct with fields = c("a", "b", "c", "d"), n_field_strategy = NA_character_

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
    Condition
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (3, 4)
      ┌─────┬──────┬──────┬──────┐
      │ a   ┆ b    ┆ c    ┆ d    │
      │ --- ┆ ---  ┆ ---  ┆ ---  │
      │ f64 ┆ f64  ┆ f64  ┆ f64  │
      ╞═════╪══════╪══════╪══════╡
      │ 1.0 ┆ 2.0  ┆ null ┆ null │
      │ 1.0 ┆ 2.0  ┆ 3.0  ┆ null │
      │ 1.0 ┆ null ┆ null ┆ null │
      └─────┴──────┴──────┴──────┘

# series list$to_struct accepts future-compatible fields

    Code
      as_polars_df(series$list$to_struct())
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (2, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ f64     ┆ f64     │
      ╞═════════╪═════════╡
      │ 1.0     ┆ 2.0     │
      │ 1.0     ┆ 2.0     │
      └─────────┴─────────┘

---

    Code
      as_polars_df(series$list$to_struct("max_width"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Legacy arguments of `<series>$list$to_struct()` are deprecated as of polars 1.16.0.
      i Use an explicit character vector for `fields`.
    Output
      shape: (2, 3)
      ┌─────────┬─────────┬─────────┐
      │ field_0 ┆ field_1 ┆ field_2 │
      │ ---     ┆ ---     ┆ ---     │
      │ f64     ┆ f64     ┆ f64     │
      ╞═════════╪═════════╪═════════╡
      │ 1.0     ┆ 2.0     ┆ null    │
      │ 1.0     ┆ 2.0     ┆ 3.0     │
      └─────────┴─────────┴─────────┘

---

    Code
      series$list$to_struct("first_non_null", c("a"), 2)
    Condition
      Error in `series$list$to_struct()`:
      ! Evaluation failed in `$to_struct()`.
      Caused by error in `parse_to_struct_args()`:
      ! Too many positional arguments supplied to <series>$list$to_struct().

---

    Code
      series$list$to_struct(fields = "a", "first_non_null", 2)
    Condition
      Error in `series$list$to_struct()`:
      ! Evaluation failed in `$to_struct()`.
      Caused by error in `parse_to_struct_args()`:
      ! Arguments were supplied more than once to <series>$list$to_struct().

---

    Code
      series$list$to_struct(upper_bound = 2)
    Condition
      Error in `series$list$to_struct()`:
      ! Evaluation failed in `$to_struct()`.
      Caused by error in `parse_to_struct_args()`:
      ! `upper_bound` is not supported by <series>$list$to_struct().

