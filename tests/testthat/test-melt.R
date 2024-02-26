patrick::with_parameters_test_that("melt example",
  {
    df_1 = pl[[create_func]](
      a = c("x", "y", "z"),
      b = c(1, 3, 5),
      c = c(2, 4, 6)
    )

    expect_true(is_func(df_1))

    expect_identical(
      df_1$melt(id_vars = "a", value_vars = c("b", "c")) |> as.data.frame(),
      data.frame(
        a = c("x", "y", "z", "x", "y", "z"),
        variable = c("b", "b", "b", "c", "c", "c"),
        value = c(1, 3, 5, 2, 4, 6)
      )
    )
    expect_identical(
      df_1$melt(id_vars = c("c", "b"), value_vars = "a") |> as.data.frame(),
      data.frame(
        c = c(2, 4, 6),
        b = c(1, 3, 5),
        variable = rep("a", 3),
        value = c("x", "y", "z")
      )
    )
    expect_identical(
      df_1$melt(id_vars = c("a", "b"), value_vars = "c") |> as.data.frame(),
      data.frame(
        a = c("x", "y", "z"),
        b = c(1, 3, 5),
        variable = rep("c", 3),
        value = c(2, 4, 6)
      )
    )

    expect_identical(
      df_1$melt(
        id_vars = c("a", "b"),
        value_vars = c("c"),
        value_name = "alice",
        variable_name = "bob"
      ) |> as.data.frame(),
      data.frame(
        a = c("x", "y", "z"),
        b = c(1, 3, 5),
        bob = rep("c", 3),
        alice = c(2, 4, 6)
      )
    )
  },
  create_func = c("DataFrame", "LazyFrame"),
  is_func = list(is_polars_df, is_polars_lf),
  .test_name = create_func
)
