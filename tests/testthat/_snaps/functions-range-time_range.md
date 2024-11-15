# $time_range

    Code
      pl$time_range(start = hms::parse_hms("14:00:00"), interval = "2y")
    Condition
      Error in `pl$time_range()`:
      ! Evaluation failed in `$time_range()`.
      Caused by error in `pl$time_range()`:
      ! invalid unit in `interval`: found 'y'

# $time_ranges

    Code
      pl$time_ranges(start = hms::parse_hms("14:00:00"), interval = "2y")
    Condition
      Error in `pl$time_ranges()`:
      ! Evaluation failed in `$time_ranges()`.
      Caused by error in `pl$time_ranges()`:
      ! invalid unit in `interval`: found 'y'

