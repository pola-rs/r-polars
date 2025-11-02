# roundtrip around serialization empty

    Code
      serialized
    Output
        [1] 44 53 4c 5f 56 45 52 53 49 4f 4e 18 00 00 00 36 32 38 36 62 61 64 37 62 35
       [26] 39 63 36 64 66 66 62 61 62 63 62 37 65 64 61 30 64 33 61 31 63 33 38 36 63
       [51] 63 36 35 31 61 64 38 62 32 34 37 39 62 32 65 34 65 34 36 38 36 31 39 39 65
       [76] 30 34 65 31 83 a4 72 6f 6f 74 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01
      [101] aa 64 61 74 61 66 72 61 6d 65 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73
      [126] 69 6f 6e 00 82 a5 76 61 6c 75 65 c4 80 ff ff ff ff 70 00 00 00 04 00 00 00
      [151] f2 ff ff ff 14 00 00 00 04 00 01 00 00 00 0a 00 0b 00 08 00 0a 00 04 00 f2
      [176] ff ff ff 48 00 00 00 10 00 00 00 00 00 0a 00 0c 00 00 00 04 00 08 00 01 00
      [201] 00 00 04 00 00 00 f4 ff ff ff 18 00 00 00 0c 00 00 00 08 00 0c 00 04 00 08
      [226] 00 02 00 00 00 5b 5d 00 00 09 00 00 00 5f 50 4c 5f 46 4c 41 47 53 00 00 00
      [251] 00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00 a7 76 65 72 73 69 6f 6e 01
      [276] a9 64 73 6c 5f 70 6c 61 6e 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73 69
      [301] 6f 6e 00 82 a5 76 61 6c 75 65 81 ad 44 61 74 61 46 72 61 6d 65 53 63 61 6e
      [326] 82 a2 64 66 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01 a6 73 63 68 65 6d
      [351] 61 81 a6 66 69 65 6c 64 73 80 a7 76 65 72 73 69 6f 6e 01

# roundtrip around serialization dataframe

    Code
      serialized
    Output
        [1] 44 53 4c 5f 56 45 52 53 49 4f 4e 18 00 00 00 36 32 38 36 62 61 64 37 62 35
       [26] 39 63 36 64 66 66 62 61 62 63 62 37 65 64 61 30 64 33 61 31 63 33 38 36 63
       [51] 63 36 35 31 61 64 38 62 32 34 37 39 62 32 65 34 65 34 36 38 36 31 39 39 65
       [76] 30 34 65 31 83 a4 72 6f 6f 74 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01
      [101] aa 64 61 74 61 66 72 61 6d 65 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73
      [126] 69 6f 6e 00 82 a5 76 61 6c 75 65 c5 02 48 ff ff ff ff e8 00 00 00 04 00 00
      [151] 00 f2 ff ff ff 14 00 00 00 04 00 01 00 00 00 0a 00 0b 00 08 00 0a 00 04 00
      [176] f2 ff ff ff 4c 00 00 00 10 00 00 00 00 00 0a 00 0c 00 00 00 04 00 08 00 01
      [201] 00 00 00 04 00 00 00 f4 ff ff ff 1c 00 00 00 0c 00 00 00 08 00 0c 00 04 00
      [226] 08 00 05 00 00 00 5b 30 2c 30 5d 00 00 00 09 00 00 00 5f 50 4c 5f 46 4c 41
      [251] 47 53 00 00 00 02 00 00 00 30 00 00 00 04 00 00 00 c4 ff ff ff 1c 00 00 00
      [276] 10 00 00 00 08 00 00 00 01 18 00 00 00 00 00 00 fc ff ff ff 04 00 04 00 01
      [301] 00 00 00 62 00 00 00 ec ff ff ff 38 00 00 00 20 00 00 00 18 00 00 00 01 02
      [326] 00 00 10 00 12 00 04 00 10 00 11 00 08 00 00 00 0c 00 00 00 00 00 f4 ff ff
      [351] ff 20 00 00 00 01 00 00 00 08 00 09 00 04 00 08 00 01 00 00 00 61 00 00 00
      [376] 00 00 00 00 ff ff ff ff c8 00 00 00 04 00 00 00 ec ff ff ff 80 00 00 00 00
      [401] 00 00 00 14 00 00 00 04 00 03 00 0c 00 13 00 10 00 12 00 0c 00 04 00 e6 ff
      [426] ff ff 03 00 00 00 00 00 00 00 74 00 00 00 28 00 00 00 14 00 00 00 00 00 0e
      [451] 00 18 00 04 00 0c 00 10 00 00 00 14 00 01 00 00 00 00 00 00 00 00 00 00 00
      [476] 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [501] 00 00 00 00 00 00 00 0c 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00
      [526] 00 00 00 00 00 00 40 00 00 00 00 00 00 00 30 00 00 00 00 00 00 00 00 00 00
      [551] 00 02 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00
      [576] 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 02 00 00 00 03 00 00 00 00
      [601] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [626] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [651] 00 01 00 00 00 61 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 62 00 00 00
      [676] 00 00 00 00 00 00 00 00 01 00 00 00 63 00 00 00 00 00 00 00 00 00 00 00 00
      [701] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff ff 00 00 00 00 a7 76
      [726] 65 72 73 69 6f 6e 01 a9 64 73 6c 5f 70 6c 61 6e 73 92 82 a5 76 61 6c 75 65
      [751] c0 a7 76 65 72 73 69 6f 6e 00 82 a5 76 61 6c 75 65 81 ad 44 61 74 61 46 72
      [776] 61 6d 65 53 63 61 6e 82 a2 64 66 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e
      [801] 01 a6 73 63 68 65 6d 61 81 a6 66 69 65 6c 64 73 82 a1 61 a5 49 6e 74 33 32
      [826] a1 62 a6 53 74 72 69 6e 67 a7 76 65 72 73 69 6f 6e 01

# Can't serialize lazyframe includes map function

    Code
      pl$LazyFrame()$select(pl$lit(1)$map_batches(function(x) x + 1))$serialize()
    Condition
      Error:
      ! Evaluation failed in `$serialize()`.
      Caused by error:
      ! serialization failed
      
      error: serialization not supported for this 'opaque' function

# deserialize lazyframe' error

    Code
      pl$deserialize_lf(0L)
    Condition
      Error in `pl$deserialize_lf()`:
      ! Evaluation failed in `$deserialize_lf()`.
      Caused by error:
      ! Argument `data` must be raw, not integer

---

    Code
      pl$deserialize_lf(raw(0))
    Condition
      Error in `pl$deserialize_lf()`:
      ! Evaluation failed in `$deserialize_lf()`.
      Caused by error:
      ! failed to read incoming DSL_VERSION: failed to fill whole buffer

---

    Code
      pl$deserialize_lf(as.raw(1:100))
    Condition
      Error in `pl$deserialize_lf()`:
      ! Evaluation failed in `$deserialize_lf()`.
      Caused by error:
      ! dsl magic bytes not found

# $to_dot() works

    Code
      cat(lf$to_dot())
    Output
      digraph polars_query {
        rankdir="BT"
        node [fontname="Monospace", shape="box"]
        p1[label="TABLE\nπ */11"]
      }

---

    Code
      cat(lf$select("am")$to_dot())
    Output
      digraph polars_query {
        rankdir="BT"
        node [fontname="Monospace", shape="box"]
        p1[label="TABLE\nπ 1/11"]
      }

# $unique's argument deprecation NULL

    Code
      df$lazy()$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      shape: (3, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      │ 2.0 ┆ a   ┆ b   │
      │ 3.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

---

    Code
      df$lazy()$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error in `df$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$lazy()$unique(value, maintain_order = TRUE)
    Condition
      Warning:
      ! Passing `NULL` to the first argument of `$unique()` is deprecated as of polars 1.1.0.
      i Passing `cs$all()` to `...` instead.
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(value, maintain_order = TRUE)
    Condition
      Warning:
      ! Passing `NULL` to the first argument of `$unique()` is deprecated as of polars 1.1.0.
      i Passing `cs$all()` to `...` instead.
    Output
      shape: (3, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      │ 2.0 ┆ a   ┆ b   │
      │ 3.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

# $unique's argument deprecation list of strings

    Code
      df$lazy()$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      shape: (1, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

---

    Code
      df$lazy()$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error in `df$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$lazy()$unique(value, maintain_order = TRUE)
    Condition
      Warning:
      ! Passing a list to the first argument of `$unique()` is deprecated as of polars 1.1.0.
      i Passing `!!!my_list` to `...` instead.
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(value, maintain_order = TRUE)
    Condition
      Warning:
      ! Passing a list to the first argument of `$unique()` is deprecated as of polars 1.1.0.
      i Passing `!!!my_list` to `...` instead.
    Output
      shape: (1, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

# $unique's argument deprecation expr

    Code
      df$lazy()$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
    Output
      shape: (1, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

---

    Code
      df$lazy()$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$unique("foo", subset = value, maintain_order = TRUE)
    Condition
      Warning:
      ! The `subset` argument of `$unique()` is deprecated and replaced by `...` as of polars 1.1.0.
      Error in `df$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! Evaluation failed in `$unique()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      df$lazy()$unique(value, maintain_order = TRUE)
    Output
      <polars_lazy_frame>

---

    Code
      df$unique(value, maintain_order = TRUE)
    Output
      shape: (1, 3)
      ┌─────┬─────┬─────┐
      │ foo ┆ bar ┆ ham │
      │ --- ┆ --- ┆ --- │
      │ f64 ┆ str ┆ str │
      ╞═════╪═════╪═════╡
      │ 1.0 ┆ a   ┆ b   │
      └─────┴─────┴─────┘

# explain() works

    Code
      cat(lazy_query$explain(optimized = FALSE))
    Output
      FILTER [(col("Species")) != ("setosa")]
      FROM
        SORT BY [col("Species")]
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", ...]; PROJECT */5 COLUMNS

---

    Code
      cat(lazy_query$explain())
    Output
      SORT BY [col("Species")]
        FILTER [(col("Species")) != ("setosa")]
        FROM
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", ...]; PROJECT */5 COLUMNS

---

    Code
      cat(lazy_query$explain(format = "tree", optimized = FALSE))
    Output
                             0                            1                                               2
         ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
         │
         │               ╭────────╮
       0 │               │ FILTER │
         │               ╰───┬┬───╯
         │                   ││
         │                   │╰───────────────────────────╮
         │                   │                            │
         │  ╭────────────────┴─────────────────╮     ╭────┴────╮
         │  │ predicate:                       │     │ FROM:   │
       1 │  │ [(col("Species")) != ("setosa")] │     │ SORT BY │
         │  ╰──────────────────────────────────╯     ╰────┬┬───╯
         │                                                ││
         │                                                │╰──────────────────────────────────────────────╮
         │                                                │                                               │
         │                                        ╭───────┴────────╮  ╭───────────────────────────────────┴────────────────────────────────────╮
         │                                        │ expression:    │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", ...] │
       2 │                                        │ col("Species") │  │ PROJECT */5 COLUMNS                                                    │
         │                                        ╰────────────────╯  ╰────────────────────────────────────────────────────────────────────────╯

---

    Code
      cat(lazy_query$explain(format = "tree", ))
    Output
                    0                            1                                                        2
         ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
         │
         │     ╭─────────╮
       0 │     │ SORT BY │
         │     ╰────┬┬───╯
         │          ││
         │          │╰───────────────────────────╮
         │          │                            │
         │  ╭───────┴────────╮                   │
         │  │ expression:    │               ╭───┴────╮
       1 │  │ col("Species") │               │ FILTER │
         │  ╰────────────────╯               ╰───┬┬───╯
         │                                       ││
         │                                       │╰───────────────────────────────────────────────────────╮
         │                                       │                                                        │
         │                      ╭────────────────┴─────────────────╮  ╭───────────────────────────────────┴────────────────────────────────────╮
         │                      │ predicate:                       │  │ FROM:                                                                  │
       2 │                      │ [(col("Species")) != ("setosa")] │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", ...] │
         │                      ╰──────────────────────────────────╯  │ PROJECT */5 COLUMNS                                                    │
         │                                                            ╰────────────────────────────────────────────────────────────────────────╯

# describe() works

    Code
      df$describe()
    Output
      shape: (9, 6)
      ┌────────────┬──────────┬────────┬────────────────────────────┬──────┬──────┐
      │ statistic  ┆ float    ┆ string ┆ date                       ┆ cat  ┆ bool │
      │ ---        ┆ ---      ┆ ---    ┆ ---                        ┆ ---  ┆ ---  │
      │ str        ┆ f64      ┆ str    ┆ str                        ┆ str  ┆ f64  │
      ╞════════════╪══════════╪════════╪════════════════════════════╪══════╪══════╡
      │ count      ┆ 2.0      ┆ 2      ┆ 2                          ┆ 2    ┆ 2.0  │
      │ null_count ┆ 1.0      ┆ 1      ┆ 1                          ┆ 1    ┆ 1.0  │
      │ mean       ┆ 1.75     ┆ null   ┆ 2024-01-20 12:00:00.000000 ┆ null ┆ 0.5  │
      │ std        ┆ 0.353553 ┆ null   ┆ null                       ┆ null ┆ null │
      │ min        ┆ 1.5      ┆ a      ┆ 2024-01-20                 ┆ a    ┆ 0.0  │
      │ 25%        ┆ 1.5      ┆ null   ┆ 2024-01-20                 ┆ null ┆ null │
      │ 50%        ┆ 2.0      ┆ null   ┆ 2024-01-21                 ┆ null ┆ null │
      │ 75%        ┆ 2.0      ┆ null   ┆ 2024-01-21                 ┆ null ┆ null │
      │ max        ┆ 2.0      ┆ b      ┆ 2024-01-21                 ┆ zz   ┆ 1.0  │
      └────────────┴──────────┴────────┴────────────────────────────┴──────┴──────┘

---

    Code
      df$lazy()$describe()
    Output
      shape: (9, 6)
      ┌────────────┬──────────┬────────┬────────────────────────────┬──────┬──────┐
      │ statistic  ┆ float    ┆ string ┆ date                       ┆ cat  ┆ bool │
      │ ---        ┆ ---      ┆ ---    ┆ ---                        ┆ ---  ┆ ---  │
      │ str        ┆ f64      ┆ str    ┆ str                        ┆ str  ┆ f64  │
      ╞════════════╪══════════╪════════╪════════════════════════════╪══════╪══════╡
      │ count      ┆ 2.0      ┆ 2      ┆ 2                          ┆ 2    ┆ 2.0  │
      │ null_count ┆ 1.0      ┆ 1      ┆ 1                          ┆ 1    ┆ 1.0  │
      │ mean       ┆ 1.75     ┆ null   ┆ 2024-01-20 12:00:00.000000 ┆ null ┆ 0.5  │
      │ std        ┆ 0.353553 ┆ null   ┆ null                       ┆ null ┆ null │
      │ min        ┆ 1.5      ┆ a      ┆ 2024-01-20                 ┆ a    ┆ 0.0  │
      │ 25%        ┆ 1.5      ┆ null   ┆ 2024-01-20                 ┆ null ┆ null │
      │ 50%        ┆ 2.0      ┆ null   ┆ 2024-01-21                 ┆ null ┆ null │
      │ 75%        ┆ 2.0      ┆ null   ┆ 2024-01-21                 ┆ null ┆ null │
      │ max        ┆ 2.0      ┆ b      ┆ 2024-01-21                 ┆ zz   ┆ 1.0  │
      └────────────┴──────────┴────────┴────────────────────────────┴──────┴──────┘

---

    Code
      pl$DataFrame()$describe()
    Condition
      Error:
      ! Evaluation failed in `$describe()`.
      Caused by error:
      ! Can't describe a DataFrame without any columns

---

    Code
      pl$LazyFrame()$describe()
    Condition
      Error:
      ! Evaluation failed in `$describe()`.
      Caused by error:
      ! Can't describe a LazyFrame without any columns

---

    Code
      df$describe(percentiles = 0.1)
    Output
      shape: (7, 6)
      ┌────────────┬──────────┬────────┬────────────────────────────┬──────┬──────┐
      │ statistic  ┆ float    ┆ string ┆ date                       ┆ cat  ┆ bool │
      │ ---        ┆ ---      ┆ ---    ┆ ---                        ┆ ---  ┆ ---  │
      │ str        ┆ f64      ┆ str    ┆ str                        ┆ str  ┆ f64  │
      ╞════════════╪══════════╪════════╪════════════════════════════╪══════╪══════╡
      │ count      ┆ 2.0      ┆ 2      ┆ 2                          ┆ 2    ┆ 2.0  │
      │ null_count ┆ 1.0      ┆ 1      ┆ 1                          ┆ 1    ┆ 1.0  │
      │ mean       ┆ 1.75     ┆ null   ┆ 2024-01-20 12:00:00.000000 ┆ null ┆ 0.5  │
      │ std        ┆ 0.353553 ┆ null   ┆ null                       ┆ null ┆ null │
      │ min        ┆ 1.5      ┆ a      ┆ 2024-01-20                 ┆ a    ┆ 0.0  │
      │ 10%        ┆ 1.5      ┆ null   ┆ 2024-01-20                 ┆ null ┆ null │
      │ max        ┆ 2.0      ┆ b      ┆ 2024-01-21                 ┆ zz   ┆ 1.0  │
      └────────────┴──────────┴────────┴────────────────────────────┴──────┴──────┘

---

    Code
      df$select(pl$col("cat")$cast(pl$Categorical()))$describe()
    Output
      shape: (9, 2)
      ┌────────────┬──────┐
      │ statistic  ┆ cat  │
      │ ---        ┆ ---  │
      │ str        ┆ str  │
      ╞════════════╪══════╡
      │ count      ┆ 2    │
      │ null_count ┆ 1    │
      │ mean       ┆ null │
      │ std        ┆ null │
      │ min        ┆ a    │
      │ 25%        ┆ null │
      │ 50%        ┆ null │
      │ 75%        ┆ null │
      │ max        ┆ zz   │
      └────────────┴──────┘

# error and warning from collect engines

    Code
      as_polars_lf(mtcars)$collect(engine = "gpu")
    Condition
      Error in `as_polars_lf(mtcars)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error in `as_polars_lf(mtcars)$collect()`:
      ! `engine` must be one of "auto", "in-memory", or "streaming", not "gpu".

---

    Code
      as_polars_lf(mtcars)$collect(engine = "old-streaming")
    Condition
      Error in `as_polars_lf(mtcars)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error in `as_polars_lf(mtcars)$collect()`:
      ! `engine` must be one of "auto", "in-memory", or "streaming", not "old-streaming".
      i Did you mean "streaming"?

# group_by() warns with arg maintain_order

    Code
      dat$group_by("a", maintain_order = TRUE)$agg()
    Condition
      Warning:
      ! In `$group_by()`, `...` contain an argument named `maintain_order`.
      i You may want to specify the argument `.maintain_order` instead.
    Output
      shape: (1, 2)
      ┌─────┬────────────────┐
      │ a   ┆ maintain_order │
      │ --- ┆ ---            │
      │ i32 ┆ bool           │
      ╞═════╪════════════════╡
      │ 1   ┆ true           │
      └─────┴────────────────┘

# active bindings

    Code
      as_polars_lf(mtcars)$width
    Condition
      Warning:
      ! Potentially expensive operation.
      * Determining the width of a LazyFrame requires resolving its schema,
      * so this calls `$collect_schema()` internally.
      i Use `length(<lazyframe>)` to get the width without this warning.
    Output
      [1] 11

---

    Code
      as_polars_lf(mtcars)$columns
    Condition
      Warning:
      ! Potentially expensive operation.
      * Determining the column names of a LazyFrame requires resolving its schema,
      * so this calls `$collect_schema()` internally.
      i Use `names(<lazyframe>)` to get the column names without this warning.
    Output
       [1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear"
      [11] "carb"

