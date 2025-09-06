test_that("$first() works for series list namespace", {
  # list$first() is a special case because it calls another method of the same namespace
  expect_equal(
    as_polars_series(list(1:3))$list$first(),
    as_polars_series(1L)
  )
})

patrick::with_parameters_test_that(
  "list$to_struct with fields = {rlang::quo_text(fields)}, n_field_strategy = {rlang::quo_text(n_field_strategy)}", # nolint: line_length_linter
  .cases = {
    expand.grid(
      fields = list(
        NULL,
        \(x) sprintf("field-%s", x + 1),
        ~ paste0("field-", . + 1)
      ),
      n_field_strategy = c("first_non_null", "max_width"),
      stringsAsFactors = FALSE
    ) |>
      tibble::as_tibble() |>
      # Add character cases (ignoring n_field_strategy)
      vctrs::vec_rbind(tibble::tibble(fields = list(c("a"), c("a", "b", "c", "d"))))
  },
  code = {
    expect_snapshot(
      as_polars_series(list(c(1, 2), c(1, 2, 3), c(1)))$list$to_struct(
        fields = fields,
        n_field_strategy = n_field_strategy
      ) |>
        as_polars_df()
    )
  }
)
