# tests for vctrs_rcrd

    Code
      pl$DataFrame(foo = vec)$dtypes
    Output
      [[1]]
      DataType: Struct(
          [
              Field {
                  name: "lat",
                  dtype: Float64,
              },
              Field {
                  name: "lon",
                  dtype: Float64,
              },
          ],
      )
      

# clock package class support precision=nanosecond

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌───────────────────────────────┬───────────────────────────────────┬───────────────────────────────────┐
      │ naive_time                    ┆ sys_time                          ┆ zoned_time_1                      │
      │ ---                           ┆ ---                               ┆ ---                               │
      │ datetime[ns]                  ┆ datetime[ns, UTC]                 ┆ datetime[ns, America/New_York]    │
      ╞═══════════════════════════════╪═══════════════════════════════════╪═══════════════════════════════════╡
      │ 1900-01-01 12:34:56.123456789 ┆ 1900-01-01 12:34:56.123456789 UT… ┆ 1900-01-01 12:34:56.123456789 ES… │
      │ 2012-01-01 12:34:56.123456789 ┆ 2012-01-01 12:34:56.123456789 UT… ┆ 2012-01-01 12:34:56.123456789 ES… │
      │ 2212-01-01 12:34:56.123456789 ┆ 2212-01-01 12:34:56.123456789 UT… ┆ 2212-01-01 12:34:56.123456789 ES… │
      └───────────────────────────────┴───────────────────────────────────┴───────────────────────────────────┘

# clock package class support precision=microsecond

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌────────────────────────────┬────────────────────────────────┬────────────────────────────────┐
      │ naive_time                 ┆ sys_time                       ┆ zoned_time_1                   │
      │ ---                        ┆ ---                            ┆ ---                            │
      │ datetime[μs]               ┆ datetime[μs, UTC]              ┆ datetime[μs, America/New_York] │
      ╞════════════════════════════╪════════════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 12:34:56.123456 ┆ 1900-01-01 12:34:56.123456 UTC ┆ 1900-01-01 12:34:56.123456 EST │
      │ 2012-01-01 12:34:56.123456 ┆ 2012-01-01 12:34:56.123456 UTC ┆ 2012-01-01 12:34:56.123456 EST │
      │ 2212-01-01 12:34:56.123456 ┆ 2212-01-01 12:34:56.123456 UTC ┆ 2212-01-01 12:34:56.123456 EST │
      └────────────────────────────┴────────────────────────────────┴────────────────────────────────┘

# clock package class support precision=millisecond

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌─────────────────────────┬─────────────────────────────┬────────────────────────────────┐
      │ naive_time              ┆ sys_time                    ┆ zoned_time_1                   │
      │ ---                     ┆ ---                         ┆ ---                            │
      │ datetime[ms]            ┆ datetime[ms, UTC]           ┆ datetime[ms, America/New_York] │
      ╞═════════════════════════╪═════════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 12:34:56.123 ┆ 1900-01-01 12:34:56.123 UTC ┆ 1900-01-01 12:34:56.123 EST    │
      │ 2012-01-01 12:34:56.123 ┆ 2012-01-01 12:34:56.123 UTC ┆ 2012-01-01 12:34:56.123 EST    │
      │ 2212-01-01 12:34:56.123 ┆ 2212-01-01 12:34:56.123 UTC ┆ 2212-01-01 12:34:56.123 EST    │
      └─────────────────────────┴─────────────────────────────┴────────────────────────────────┘

# clock package class support precision=second

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌─────────────────────┬─────────────────────────┬────────────────────────────────┐
      │ naive_time          ┆ sys_time                ┆ zoned_time_1                   │
      │ ---                 ┆ ---                     ┆ ---                            │
      │ datetime[ms]        ┆ datetime[ms, UTC]       ┆ datetime[ms, America/New_York] │
      ╞═════════════════════╪═════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 12:34:56 ┆ 1900-01-01 12:34:56 UTC ┆ 1900-01-01 12:34:56 EST        │
      │ 2012-01-01 12:34:56 ┆ 2012-01-01 12:34:56 UTC ┆ 2012-01-01 12:34:56 EST        │
      │ 2212-01-01 12:34:56 ┆ 2212-01-01 12:34:56 UTC ┆ 2212-01-01 12:34:56 EST        │
      └─────────────────────┴─────────────────────────┴────────────────────────────────┘

# clock package class support precision=minute

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌─────────────────────┬─────────────────────────┬────────────────────────────────┐
      │ naive_time          ┆ sys_time                ┆ zoned_time_1                   │
      │ ---                 ┆ ---                     ┆ ---                            │
      │ datetime[ms]        ┆ datetime[ms, UTC]       ┆ datetime[ms, America/New_York] │
      ╞═════════════════════╪═════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 12:34:00 ┆ 1900-01-01 12:34:00 UTC ┆ 1900-01-01 12:34:00 EST        │
      │ 2012-01-01 12:34:00 ┆ 2012-01-01 12:34:00 UTC ┆ 2012-01-01 12:34:00 EST        │
      │ 2212-01-01 12:34:00 ┆ 2212-01-01 12:34:00 UTC ┆ 2212-01-01 12:34:00 EST        │
      └─────────────────────┴─────────────────────────┴────────────────────────────────┘

# clock package class support precision=hour

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌─────────────────────┬─────────────────────────┬────────────────────────────────┐
      │ naive_time          ┆ sys_time                ┆ zoned_time_1                   │
      │ ---                 ┆ ---                     ┆ ---                            │
      │ datetime[ms]        ┆ datetime[ms, UTC]       ┆ datetime[ms, America/New_York] │
      ╞═════════════════════╪═════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 12:00:00 ┆ 1900-01-01 12:00:00 UTC ┆ 1900-01-01 12:00:00 EST        │
      │ 2012-01-01 12:00:00 ┆ 2012-01-01 12:00:00 UTC ┆ 2012-01-01 12:00:00 EST        │
      │ 2212-01-01 12:00:00 ┆ 2212-01-01 12:00:00 UTC ┆ 2212-01-01 12:00:00 EST        │
      └─────────────────────┴─────────────────────────┴────────────────────────────────┘

# clock package class support precision=day

    Code
      pl$DataFrame(naive_time = clock_naive_time, sys_time = clock_sys_time,
        zoned_time_1 = clock_zoned_time_1)
    Output
      shape: (3, 3)
      ┌─────────────────────┬─────────────────────────┬────────────────────────────────┐
      │ naive_time          ┆ sys_time                ┆ zoned_time_1                   │
      │ ---                 ┆ ---                     ┆ ---                            │
      │ datetime[ms]        ┆ datetime[ms, UTC]       ┆ datetime[ms, America/New_York] │
      ╞═════════════════════╪═════════════════════════╪════════════════════════════════╡
      │ 1900-01-01 00:00:00 ┆ 1900-01-01 00:00:00 UTC ┆ 1900-01-01 00:00:00 EST        │
      │ 2012-01-01 00:00:00 ┆ 2012-01-01 00:00:00 UTC ┆ 2012-01-01 00:00:00 EST        │
      │ 2212-01-01 00:00:00 ┆ 2212-01-01 00:00:00 UTC ┆ 2212-01-01 00:00:00 EST        │
      └─────────────────────┴─────────────────────────┴────────────────────────────────┘

