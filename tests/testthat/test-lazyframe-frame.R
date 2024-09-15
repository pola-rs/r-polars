test_that("POLARS_AUTO_STRUCTIFY works for select", {
  lf <- pl$LazyFrame(
    foo = 1:3,
    bar = 6:8,
    ham = letters[1:3],
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "foo"),
    {
      expect_error(
        lf$select(1),
        r"(Environment variable `POLARS_AUTO_STRUCTIFY` must be one of \('0', '1'\), got 'foo')"
      )
    }
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "0"),
    {
      expect_error(
        lf$select(
          is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd"),
        )$collect(),
        "`keep`, `suffix`, `prefix` should be last expression"
      )

      expect_equal(
        withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
          lf$select(
            is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd"),
          )$collect()
        }),
        lf$select(
          is_odd = pl$struct(((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd")),
        )$collect()
      )
    }
  )
})
