# deserialize dataframe' error

    Code
      pl$deserialize_df(0L)
    Condition
      Error in `pl$deserialize_df()`:
      ! Evaluation failed in `$deserialize_df()`.
      Caused by error:
      ! Argument `data` must be raw, not integer

---

    Code
      pl$deserialize_df(raw(0))
    Condition
      Error in `pl$deserialize_df()`:
      ! Evaluation failed in `$deserialize_df()`.
      Caused by error:
      ! The input value is not a valid serialized DataFrame.

---

    Code
      pl$deserialize_df(as.raw(1:100))
    Condition
      Error in `pl$deserialize_df()`:
      ! Evaluation failed in `$deserialize_df()`.
      Caused by error:
      ! The input value is not a valid serialized DataFrame.

# sample() works

    Code
      df$sample(n = 2, fraction = 0.1)
    Condition
      Error in `df$sample()`:
      ! Evaluation failed in `$sample()`.
      Caused by error in `df$sample()`:
      ! Can't specify both `n` and `fraction`.

---

    Code
      df$sample(frac = 0.1)
    Condition
      Error in `df$sample()`:
      ! Evaluation failed in `$sample()`.
      Caused by error in `df$sample()`:
      ! `...` must be empty.
      x Problematic argument:
      * frac = 0.1

# unstack() works

    Code
      df$unstack(cs$numeric(), step = 5, fill_values = c(0, 1))
    Condition
      Error in `df$unstack()`:
      ! Evaluation failed in `$unstack()`.
      Caused by error:
      ! Expanding the DataFrame failed.
      Caused by error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! value and n should have unit length.

---

    Code
      df$unstack(cs$numeric(), step = 5, fill_values = list(0, 1))
    Condition
      Error in `df$unstack()`:
      ! Evaluation failed in `$unstack()`.
      Caused by error:
      ! Expanding the DataFrame failed.
      Caused by error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! value and n should have unit length.

---

    Code
      df$unstack(cs$numeric(), step = 5, fill_values = list(x = 0, 1))
    Condition
      Error in `df$unstack()`:
      ! Evaluation failed in `$unstack()`.
      Caused by error:
      ! Expanding the DataFrame failed.
      Caused by error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! value and n should have unit length.

---

    Code
      df$unstack(cs$numeric(), step = 5, fill_values = list(y = 1:2))
    Condition
      Error in `df$unstack()`:
      ! Evaluation failed in `$unstack()`.
      Caused by error:
      ! Expanding the DataFrame failed.
      Caused by error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! value and n should have unit length.

# $glimpse() works

    Code
      df$glimpse()
    Output
      Rows: 150
      Columns: 7
      $ Sepal.Length <f64>: 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9
      $ Sepal.Width  <f64>: 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1
      $ Petal.Length <f64>: 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5
      $ Petal.Width  <f64>: 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1
      $ Species      <cat>: setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa
      $ int8          <i8>: 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
      $ int64        <i64>: 42, 42, 42, 42, 42, 42, 42, 42, 42, 42

---

    Code
      df$glimpse(max_items_per_column = 2)
    Output
      Rows: 150
      Columns: 7
      $ Sepal.Length <f64>: 5.1, 4.9
      $ Sepal.Width  <f64>: 3.5, 3.0
      $ Petal.Length <f64>: 1.4, 1.4
      $ Petal.Width  <f64>: 0.2, 0.2
      $ Species      <cat>: setosa, setosa
      $ int8          <i8>: 42, 42
      $ int64        <i64>: 42, 42

---

    Code
      df$glimpse(max_colname_length = 2)
    Output
      Rows: 150
      Columns: 7
      $ S... <f64>: 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9
      $ S... <f64>: 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1
      $ P... <f64>: 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5
      $ P... <f64>: 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1
      $ S... <cat>: setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa, setosa
      $ i...  <i8>: 42, 42, 42, 42, 42, 42, 42, 42, 42, 42
      $ i... <i64>: 42, 42, 42, 42, 42, 42, 42, 42, 42, 42

