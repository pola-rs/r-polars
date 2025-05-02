# `[` operator works to subset columns only

    Code
      test[1, drop = TRUE]$collect()
    Condition
      Warning:
      ! `drop = TRUE` is not supported for LazyFrame.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘

---

    Code
      test[, 1, drop = TRUE]$collect()
    Condition
      Warning:
      ! `drop = TRUE` is not supported for LazyFrame.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘

---

    Code
      test[, 10:12]
    Condition
      Error in `test[, 10:12]`:
      ! Can't subset columns past the end.
      i Location(s) 10, 11, and 12 don't exist.
      i There are only 3 columns.

---

    Code
      test[, -2:1]
    Condition
      Error in `test[, -2:1]`:
      ! Can't subset columns with `-2:1`.
      x Negative and positive locations can't be mixed.
      i Subscript `-2:1` has a positive value at location 4.

---

    Code
      test[, 1:-2]
    Condition
      Error in `test[, 1:-2]`:
      ! Can't subset columns with `1:-2`.
      x Negative and positive locations can't be mixed.
      i Subscript `1:-2` has a negative value at location 3.

---

    Code
      test[, 1.5]
    Condition
      Error in `test[, 1.5]`:
      ! Can't subset columns with `1.5`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      test["a", drop = TRUE]$collect()
    Condition
      Warning:
      ! `drop = TRUE` is not supported for LazyFrame.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘

---

    Code
      test[, "a", drop = TRUE]$collect()
    Condition
      Warning:
      ! `drop = TRUE` is not supported for LazyFrame.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘

---

    Code
      test[c("a", "foo")]
    Condition
      Error in `test[c("a", "foo")]`:
      ! Can't subset columns that don't exist.
      x Columns `foo` don't exist.

---

    Code
      test[mean]
    Condition
      Error in `test[mean]`:
      ! Can't subset columns with `mean`.
      i `mean` must be logical, numeric, or character, not a function.

---

    Code
      test[list(1)]
    Condition
      Error in `test[list(1)]`:
      ! Can't subset columns with `list(1)`.
      i `list(1)` must be logical, numeric, or character, not a list.

---

    Code
      test[NA]
    Condition
      Error in `test[NA]`:
      ! Can't subset columns with `NA`.
      x Subscript `NA` can't contain missing values.
      x It has missing value(s) at location 1.

---

    Code
      test[c(1, NA, NA)]
    Condition
      Error in `test[c(1, NA, NA)]`:
      ! Can't subset columns with `c(1, NA, NA)`.
      x Subscript `c(1, NA, NA)` can't contain missing values.
      x It has missing value(s) at location 2 and 3.

---

    Code
      test[c("a", NA)]
    Condition
      Error in `test[c("a", NA)]`:
      ! Can't subset columns with `c("a", NA)`.
      x Subscript `c("a", NA)` can't contain missing values.
      x It has missing value(s) at location 2.

# `[` operator cannot subset rows

    Code
      test[1:2, ]
    Condition
      Error in `test[1:2, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

---

    Code
      test[1:2, "a"]
    Condition
      Error in `test[1:2, "a"]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

---

    Code
      test[c(FALSE, FALSE), ]
    Condition
      Error in `test[c(FALSE, FALSE), ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

