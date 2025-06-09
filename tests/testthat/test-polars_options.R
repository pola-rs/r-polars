patrick::with_parameters_test_that(
  "options are validated by polars_options()",
  .cases = tibble::tribble(
    ~.test_name,
    "polars.df_knitr_print",
    "polars.to_r_vector.uint8",
    "polars.to_r_vector.int64",
    "polars.to_r_vector.date",
    "polars.to_r_vector.time",
    "polars.to_r_vector.struct",
    "polars.to_r_vector.decimal",
    "polars.to_r_vector.as_clock_class",
    "polars.to_r_vector.ambiguous",
    "polars.to_r_vector.non_existent",
  ),
  {
    withr::with_options(
      list("foo") |>
        rlang::set_names(.test_name),
      expect_snapshot(print(polars_options()), error = TRUE)
    )
  }
)

patrick::with_parameters_test_that(
  "options for to_r_vector() works: {opt_name} = {opt_value}",
  .cases = {
    skip_if_not_installed("vctrs")
    skip_if_not_installed("bit64")
    skip_if_not_installed("data.table")
    skip_if_not_installed("hms")
    skip_if_not_installed("clock")

    tibble::tribble(
      ~opt_name, ~opt_value,
      "duppy", NULL, # work around for creating a list column
      "polars.to_r_vector.uint8", "integer",
      "polars.to_r_vector.uint8", "raw",
      "polars.to_r_vector.int64", "double",
      "polars.to_r_vector.int64", "character",
      "polars.to_r_vector.int64", "integer",
      "polars.to_r_vector.int64", "integer64",
      "polars.to_r_vector.date", "Date",
      "polars.to_r_vector.date", "IDate",
      "polars.to_r_vector.time", "hms",
      "polars.to_r_vector.time", "ITime",
      "polars.to_r_vector.struct", "dataframe",
      "polars.to_r_vector.struct", "tibble",
      "polars.to_r_vector.decimal", "double",
      "polars.to_r_vector.decimal", "character",
      "polars.to_r_vector.as_clock_class", FALSE,
      "polars.to_r_vector.as_clock_class", TRUE,
      "polars.to_r_vector.ambiguous", "raise",
      "polars.to_r_vector.ambiguous", "earliest",
      "polars.to_r_vector.ambiguous", "latest",
      "polars.to_r_vector.ambiguous", "null",
      "polars.to_r_vector.non_existent", "raise",
      "polars.to_r_vector.non_existent", "null",
    )[-1, ] # remove the first dummy row
  },
  {
    # Since the default value of each argument is "raise",
    # if we do not exclude the naive time columns, all the tests will raise an error.
    columns_to_drop <- switch(
      opt_name,
      # If the option `as_clock_class` is `TRUE`, all naive datetime can be exported safely.
      # Otherwise, may be error by default.
      polars.to_r_vector.as_clock_class = ifelse(opt_value, "", "^datetime_naive_may_.*$"),
      # If the option `ambiguous` is specified, naive datetime which is ambiguous in the timezone
      # may be exported safely. But non existent datetime causes error.
      polars.to_r_vector.ambiguous = "datetime_naive_may_non_existent",
      # If the option `non_existent` is specified, naive datetime which is non existent
      # in the timezone may be exported safely. But ambiguous datetime causes error.
      polars.to_r_vector.non_existent = "datetime_naive_may_ambiguous",
      # By default, naive datetime can't be exported safely in timezone which has DST.
      "^datetime_naive_may_.*$"
    )
    df <- pl$DataFrame(
      uint8 = as_polars_series(1:3)$cast(pl$UInt8),
      int64 = as_polars_series(1:3)$cast(pl$Int64),
      date = as_polars_series(1:3)$cast(pl$Date),
      time = as_polars_series(1:3)$cast(pl$Time),
      struct = as_polars_series(data.frame(a = 1:3)),
      decimal = as_polars_series(1:3)$cast(pl$Decimal(10, 2)),
      duration = as_polars_series(1:3)$cast(pl$Duration("ms")),
      datetime_with_tz = as_polars_series(1:3)$cast(pl$Datetime("ms", "Europe/London")),
      datetime_naive_should_not_raise = as_polars_series(1:3)$cast(pl$Datetime("ms")),
      datetime_naive_may_ambiguous = as_polars_series(c(
        "2020-11-01 00:00:00",
        "2020-11-01 01:00:00",
        "2020-11-01 02:00:00"
      ))$str$strptime(pl$Datetime("ms")),
      datetime_naive_may_non_existent = as_polars_series(c(
        "2020-03-08 00:00:00",
        "2020-03-08 01:00:00",
        "2020-03-08 02:00:00"
      ))$str$strptime(pl$Datetime("ms")),
    )$select(cs$exclude(columns_to_drop))

    series <- df$to_struct()
    # Expect the following cases, the naive columns are dropped or treated without error
    error <- identical(opt_value, "raise")
    withr::with_options(
      c(
        opt_value |>
          rlang::set_names(opt_name),
        list(width = 200) # To print all columns of tibble
      ),
      withr::with_timezone("America/New_York", {
        expect_snapshot(series$to_r_vector(), error = error)
        expect_snapshot(as.vector(series), error = error)
        expect_snapshot(as.data.frame(df), error = error)
        expect_snapshot(as.list(df, as_series = FALSE), error = error)
        expect_snapshot(tibble::as_tibble(df), error = error)
      })
    )
  }
)
