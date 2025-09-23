patrick::with_parameters_test_that(
  "sink_batches works",
  {
    lf <- as_polars_lf(mtcars)

    expect_snapshot(
      lf$sink_batches(\(df) print(df), chunk_size = 10, maintain_order = TRUE, engine = engine)
    )
    expect_snapshot(
      lf$sort("cyl")$sink_batches(
        \(df) {
          print(df)
          if (max(df[["cyl"]])$to_r_vector() > 4) TRUE else FALSE
        },
        chunk_size = 10,
        maintain_order = TRUE,
        engine = engine
      )
    )
  },
  engine = c("streaming", "in-memory")
)
