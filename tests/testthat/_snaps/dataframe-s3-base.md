# `[` operator works to subset columns only

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
      test[c("foo", "a", "bar", "baz")]
    Condition
      Error in `test[c("foo", "a", "bar", "baz")]`:
      ! Can't subset columns that don't exist.
      x Columns `foo`, `bar`, and `baz` don't exist.

---

    Code
      test["*"]
    Condition
      Error in `test["*"]`:
      ! Can't subset columns that don't exist.
      x Columns `*` don't exist.

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

# `[` operator works to subset rows only

    Code
      test[c(-1, NA), ]
    Condition
      Error in `test[c(-1, NA), ]`:
      ! Can't subset rows with `c(-1, NA)`.
      x Negative locations can't have missing values.
      i Subscript `c(-1, NA)` has 1 missing values at location 2.

---

    Code
      test[-2:1, ]
    Condition
      Error in `test[-2:1, ]`:
      ! Can't subset rows with `-2:1`.
      x Negative and positive locations can't be mixed.
      i Subscript `-2:1` has a positive value at location 4.

---

    Code
      test[1:-2, ]
    Condition
      Error in `test[1:-2, ]`:
      ! Can't subset rows with `1:-2`.
      x Negative and positive locations can't be mixed.
      i Subscript `1:-2` has a negative value at location 3.

---

    Code
      test[1.5, ]
    Condition
      Error in `test[1.5, ]`:
      ! Can't subset rows with `1.5`.
      x Can't convert from `i` <double> to <integer> due to loss of precision.

---

    Code
      test[c(TRUE, FALSE), ]
    Condition
      Error in `test[c(TRUE, FALSE), ]`:
      ! Can't subset rows with `c(TRUE, FALSE)`.
      i Logical subscript `c(TRUE, FALSE)` must be size 1 or 3, not 2

---

    Code
      test[c(NA, FALSE), ]
    Condition
      Error in `test[c(NA, FALSE), ]`:
      ! Can't subset rows with `c(NA, FALSE)`.
      i Logical subscript `c(NA, FALSE)` must be size 1 or 3, not 2

---

    Code
      test[mean, ]
    Condition
      Error in `test[mean, ]`:
      ! Can't subset rows with `mean`.
      i `mean` must be logical, numeric, or character, not a function.

---

    Code
      test[list(1), ]
    Condition
      Error in `test[list(1), ]`:
      ! Can't subset rows with `list(1)`.
      i `list(1)` must be logical, numeric, or character, not a list.

