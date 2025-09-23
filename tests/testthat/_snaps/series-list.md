# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=NULL, n_field_strategy=first_non_null

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=function (x) , sprintf("field-%s", x + 1), n_field_strategy=first_non_null

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=~paste0("field-", . + 1), n_field_strategy=first_non_null

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=NULL, n_field_strategy=max_width

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=function (x) , sprintf("field-%s", x + 1), n_field_strategy=max_width

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=~paste0("field-", . + 1), n_field_strategy=max_width

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=a, n_field_strategy=NA

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

# list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)} fields=a, b, c, d, n_field_strategy=NA

    Code
      as_polars_df(as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields, n_field_strategy = n_field_strategy))
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

