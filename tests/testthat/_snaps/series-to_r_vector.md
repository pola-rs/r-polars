# Optional package suggestion

    Code
      as_polars_series(1)$to_r_vector()
    Message
      i The `vctrs` package is not installed.
      i Return value may not be printed correctly.
      i The `blob` package is not installed.
      i The blob class vector will not be printed correctly.
    Condition
      Warning:
      ! The `hms` package is not installed.
      i The hms class vector will be printed as difftime.
    Output
      [1] 1

# int64 argument error

    Code
      as_polars_series(1)$to_r_vector(int64 = "integer64")
    Condition
      Error in `as_polars_series(1)$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error in `as_polars_series(1)$to_r_vector()`:
      ! The `bit64` package is not installed.
      * If `int64 = "integer64"`, the `bit64` package must be installed.

# time argument error

    Code
      as_polars_series(1)$to_r_vector(time = "ITime")
    Condition
      Error in `as_polars_series(1)$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error in `as_polars_series(1)$to_r_vector()`:
      ! The `data.table` package is not installed.
      * If `time = "ITime"`, the `data.table` package must be installed.

# struct conversion dataframe

    Code
      df_out
    Output
        a    b
      1 1 a, b
      2 2 c, d

# struct conversion tibble

    Code
      df_out
    Output
      # A tibble: 2 x 2
            a                  b
        <int> <list<tibble[,1]>>
      1     1            [2 x 1]
      2     2            [2 x 1]

# ambiguous argument 'raise'

    Code
      series_ambiguous$to_r_vector(ambiguous = ambiguous)
    Condition
      Error in `series_ambiguous$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

# ambiguous argument 'earliest'

    Code
      series_ambiguous$to_r_vector(ambiguous = ambiguous)
    Output
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EDT"
      [3] "2020-11-01 02:00:00 EST"

# ambiguous argument 'latest'

    Code
      series_ambiguous$to_r_vector(ambiguous = ambiguous)
    Output
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EST"
      [3] "2020-11-01 02:00:00 EST"

# ambiguous argument 'null'

    Code
      series_ambiguous$to_r_vector(ambiguous = ambiguous)
    Output
      [1] "2020-11-01 00:00:00 EDT" NA                       
      [3] "2020-11-01 02:00:00 EST"

# non_existent argument 'raise'

    Code
      series_non_existent$to_r_vector(non_existent = non_existent)
    Condition
      Error in `series_non_existent$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

# non_existent argument 'null'

    Code
      series_non_existent$to_r_vector(non_existent = non_existent)
    Output
      [1] NA                        "2020-03-08 03:00:00 EDT"

