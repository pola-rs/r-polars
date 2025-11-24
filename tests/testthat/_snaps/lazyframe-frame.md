# roundtrip around serialization empty

    Code
      serialized
    Output
        [1] 44 53 4c 5f 56 45 52 53 49 4f 4e 18 00 00 00 39 63 31 34 37 36 32 36 37 37
       [26] 61 35 64 37 64 64 33 66 64 65 38 31 34 38 63 38 39 36 38 64 34 62 65 63 31
       [51] 63 64 61 64 61 31 63 35 31 39 62 34 65 39 36 66 36 62 32 31 66 64 31 37 38
       [76] 65 31 33 62 83 a4 72 6f 6f 74 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01
      [101] aa 64 61 74 61 66 72 61 6d 65 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73
      [126] 69 6f 6e 00 82 a5 76 61 6c 75 65 91 dc 00 80 cc ff cc ff cc ff cc ff 70 00
      [151] 00 00 04 00 00 00 cc f2 cc ff cc ff cc ff 14 00 00 00 04 00 01 00 00 00 0a
      [176] 00 0b 00 08 00 0a 00 04 00 cc f2 cc ff cc ff cc ff 48 00 00 00 10 00 00 00
      [201] 00 00 0a 00 0c 00 00 00 04 00 08 00 01 00 00 00 04 00 00 00 cc f4 cc ff cc
      [226] ff cc ff 18 00 00 00 0c 00 00 00 08 00 0c 00 04 00 08 00 02 00 00 00 5b 5d
      [251] 00 00 09 00 00 00 5f 50 4c 5f 46 4c 41 47 53 00 00 00 00 00 00 00 00 00 00
      [276] 00 cc ff cc ff cc ff cc ff 00 00 00 00 a7 76 65 72 73 69 6f 6e 01 a9 64 73
      [301] 6c 5f 70 6c 61 6e 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73 69 6f 6e 00
      [326] 82 a5 76 61 6c 75 65 81 ad 44 61 74 61 46 72 61 6d 65 53 63 61 6e 82 a2 64
      [351] 66 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01 a6 73 63 68 65 6d 61 81 a6
      [376] 66 69 65 6c 64 73 80 a7 76 65 72 73 69 6f 6e 01

# roundtrip around serialization dataframe

    Code
      serialized
    Output
        [1] 44 53 4c 5f 56 45 52 53 49 4f 4e 18 00 00 00 39 63 31 34 37 36 32 36 37 37
       [26] 61 35 64 37 64 64 33 66 64 65 38 31 34 38 63 38 39 36 38 64 34 62 65 63 31
       [51] 63 64 61 64 61 31 63 35 31 39 62 34 65 39 36 66 36 62 32 31 66 64 31 37 38
       [76] 65 31 33 62 83 a4 72 6f 6f 74 82 a3 69 64 78 01 a7 76 65 72 73 69 6f 6e 01
      [101] aa 64 61 74 61 66 72 61 6d 65 73 92 82 a5 76 61 6c 75 65 c0 a7 76 65 72 73
      [126] 69 6f 6e 00 82 a5 76 61 6c 75 65 91 dc 02 48 cc ff cc ff cc ff cc ff cc e8
      [151] 00 00 00 04 00 00 00 cc f2 cc ff cc ff cc ff 14 00 00 00 04 00 01 00 00 00
      [176] 0a 00 0b 00 08 00 0a 00 04 00 cc f2 cc ff cc ff cc ff 4c 00 00 00 10 00 00
      [201] 00 00 00 0a 00 0c 00 00 00 04 00 08 00 01 00 00 00 04 00 00 00 cc f4 cc ff
      [226] cc ff cc ff 1c 00 00 00 0c 00 00 00 08 00 0c 00 04 00 08 00 05 00 00 00 5b
      [251] 30 2c 30 5d 00 00 00 09 00 00 00 5f 50 4c 5f 46 4c 41 47 53 00 00 00 02 00
      [276] 00 00 30 00 00 00 04 00 00 00 cc c4 cc ff cc ff cc ff 1c 00 00 00 10 00 00
      [301] 00 08 00 00 00 01 18 00 00 00 00 00 00 cc fc cc ff cc ff cc ff 04 00 04 00
      [326] 01 00 00 00 62 00 00 00 cc ec cc ff cc ff cc ff 38 00 00 00 20 00 00 00 18
      [351] 00 00 00 01 02 00 00 10 00 12 00 04 00 10 00 11 00 08 00 00 00 0c 00 00 00
      [376] 00 00 cc f4 cc ff cc ff cc ff 20 00 00 00 01 00 00 00 08 00 09 00 04 00 08
      [401] 00 01 00 00 00 61 00 00 00 00 00 00 00 cc ff cc ff cc ff cc ff cc c8 00 00
      [426] 00 04 00 00 00 cc ec cc ff cc ff cc ff cc 80 00 00 00 00 00 00 00 14 00 00
      [451] 00 04 00 03 00 0c 00 13 00 10 00 12 00 0c 00 04 00 cc e6 cc ff cc ff cc ff
      [476] 03 00 00 00 00 00 00 00 74 00 00 00 28 00 00 00 14 00 00 00 00 00 0e 00 18
      [501] 00 04 00 0c 00 10 00 00 00 14 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
      [526] 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [551] 00 00 00 00 00 0c 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00
      [576] 00 00 00 00 40 00 00 00 00 00 00 00 30 00 00 00 00 00 00 00 00 00 00 00 02
      [601] 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00
      [626] 00 00 00 00 00 00 00 00 00 00 01 00 00 00 02 00 00 00 03 00 00 00 00 00 00
      [651] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [676] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01
      [701] 00 00 00 61 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 62 00 00 00 00 00
      [726] 00 00 00 00 00 00 01 00 00 00 63 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      [751] 00 00 00 00 00 00 00 00 00 00 00 00 00 cc ff cc ff cc ff cc ff 00 00 00 00
      [776] a7 76 65 72 73 69 6f 6e 01 a9 64 73 6c 5f 70 6c 61 6e 73 92 82 a5 76 61 6c
      [801] 75 65 c0 a7 76 65 72 73 69 6f 6e 00 82 a5 76 61 6c 75 65 81 ad 44 61 74 61
      [826] 46 72 61 6d 65 53 63 61 6e 82 a2 64 66 82 a3 69 64 78 01 a7 76 65 72 73 69
      [851] 6f 6e 01 a6 73 63 68 65 6d 61 81 a6 66 69 65 6c 64 73 82 a1 61 a5 49 6e 74
      [876] 33 32 a1 62 a6 53 74 72 69 6e 67 a7 76 65 72 73 69 6f 6e 01

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
      cat(lazy_query$explain(optimizations = pl$QueryOptFlags(predicate_pushdown = FALSE)))
    Output
      FILTER [(col("Species")) != ("setosa")]
      FROM
        SORT BY [col("Species")]
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", ...]; PROJECT */5 COLUMNS

---

    Code
      cat(lazy_query$explain(predicate_pushdown = FALSE))
    Condition
      Warning:
      ! `predicate_pushdown` is deprecated.
      i Use `optimizations` instead.
    Output
      FILTER [(col("Species")) != ("setosa")]
      FROM
        SORT BY [col("Species")]
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

# group_by() + len()

    Code
      df$group_by("a", .maintain_order = TRUE)$len(1)
    Condition
      Error:
      ! Evaluation failed in `$len()`.
      Caused by error in `len_expr$alias()`:
      ! Evaluation failed in `$alias()`.
      Caused by error:
      ! Argument `name` must be character, not double

---

    Code
      df$group_by("a", .maintain_order = TRUE)$len(TRUE)
    Condition
      Error:
      ! Evaluation failed in `$len()`.
      Caused by error in `len_expr$alias()`:
      ! Evaluation failed in `$alias()`.
      Caused by error:
      ! Argument `name` must be character, not logical

