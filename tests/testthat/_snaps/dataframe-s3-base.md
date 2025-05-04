# Row subsetting with `[` raise error for positive not integer-ish: 1.005

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      x Can't convert from `i` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for mixed positive and negative (positive first): c(1, 0, -2)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `first_arg` has a negative value at location 3.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for mixed positive and negative (negative first): c(-2, 0, 1)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `first_arg` has a positive value at location 3.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for negative not integer-ish: -1.005

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      x Can't convert from `i` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for negative includes NA: c(NA, -2, NA)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      x Negative locations can't have missing values.
      i Subscript `first_arg` has 2 missing values at location 1 and 3.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for logical with not the same length to the height: c(TRUE, FALSE)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      i Logical subscript `first_arg` must be size 1 or 3, not 2

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for logical includes NA with not the same length to the height: c(NA, TRUE)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      i Logical subscript `first_arg` must be size 1 or 3, not 2

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for not supported object (function): function (x, ...) UseMethod("mean")

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      i `first_arg` must be logical, numeric, or character, not a function.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for not supported object (Date): structure(1:2, class = "Date")

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      i `first_arg` must be logical, numeric, or character, not a <Date> object.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Row subsetting with `[` raise error for not supported object (list): list(1)

    Code
      pl_df[first_arg, ]
    Condition
      Error in `pl_df[first_arg, ]`:
      ! Can't subset rows with `first_arg`.
      i `first_arg` must be logical, numeric, or character, not a list.

---

    Code
      pl_df$lazy()[first_arg, ]
    Condition
      Error in `pl_df$lazy()[first_arg, ]`:
      ! Cannot subset rows of a LazyFrame with `[`.
      i There are several functions that can be used to get a specific rows.
      * `$slice()` can be used to get a slice of rows with start index and length.
      * `$gather_every()` can be used to take every nth row.
      * `$filter()` can be used to filter rows based on a condition.
      * `$reverse()` can be used to reverse the order of rows.

# Column subsetting with `[` raise error for positive not integer-ish: 1.005

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

# Column subsetting with `[` raise error for positive out of bounds: c(1, 2, 10)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns past the end.
      i Location(s) 10 don't exist.
      i There are only 3 columns.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns past the end.
      i Location(s) 10 don't exist.
      i There are only 3 columns.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns past the end.
      i Location(s) 10 don't exist.
      i There are only 3 columns.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns past the end.
      i Location(s) 10 don't exist.
      i There are only 3 columns.

# Column subsetting with `[` raise error for positive includes NA: c(1, NA, 2)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

# Column subsetting with `[` raise error for positive includes the same column twice: c(1, 2, 2)

    Code
      pl_df[, second_arg]
    Condition
      Error in `x$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `x$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

# Column subsetting with `[` raise error for mixed positive and negative (positive first): c(1, 0, -2)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a negative value at location 3.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a negative value at location 3.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a negative value at location 3.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a negative value at location 3.

# Column subsetting with `[` raise error for mixed positive and negative (negative first): c(-2, 0, 1)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a positive value at location 3.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a positive value at location 3.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a positive value at location 3.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Negative and positive locations can't be mixed.
      i Subscript `second_arg` has a positive value at location 3.

# Column subsetting with `[` raise error for negative not integer-ish: -1.005

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Can't convert from `j` <double> to <integer> due to loss of precision.

# Column subsetting with `[` raise error for negative includes NA: c(NA, -2, NA)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 1 and 3.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 1 and 3.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 1 and 3.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 1 and 3.

# Column subsetting with `[` raise error for character includes NA: c("a", NA, "b")

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

# Column subsetting with `[` raise error for character includes non-existing: c("foo", "a", "bar", "b")

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `foo` and `bar` don't exist.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `foo` and `bar` don't exist.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `foo` and `bar` don't exist.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `foo` and `bar` don't exist.

# Column subsetting with `[` raise error for character wildcard (valid for pl$col()): "*"

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `*` don't exist.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `*` don't exist.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `*` don't exist.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns that don't exist.
      x Columns `*` don't exist.

# Column subsetting with `[` raise error for character includes the same column twice: c("a", "b", "b")

    Code
      pl_df[, second_arg]
    Condition
      Error in `x$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `x$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Duplicated column(s): the name 'b' is duplicate
      
      It's possible that multiple expressions are returning the same default column name. If this is the case, try renaming the columns with `.alias("new_name")` to avoid duplicate column names.

# Column subsetting with `[` raise error for logical includes NA: c(TRUE, NA, FALSE)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      x Subscript `second_arg` can't contain missing values.
      x It has missing value(s) at location 2.

# Column subsetting with `[` raise error for logical with not the same length to the width: c(TRUE, FALSE)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 2

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 2

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 2

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 2

# Column subsetting with `[` raise error for logical length 0: logical(0)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 0

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 0

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 0

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i Logical subscript `second_arg` must be size 1 or 3, not 0

# Column subsetting with `[` raise error for not supported object (function): function (x, ...) UseMethod("mean")

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a function.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a function.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a function.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a function.

# Column subsetting with `[` raise error for not supported object (Date): structure(1:2, class = "Date")

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a <Date> object.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a <Date> object.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a <Date> object.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a <Date> object.

# Column subsetting with `[` raise error for not supported object (list): list(1)

    Code
      pl_df[, second_arg]
    Condition
      Error in `pl_df[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a list.

---

    Code
      pl_df$lazy()[, second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[, second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a list.

---

    Code
      pl_df[second_arg]
    Condition
      Error in `pl_df[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a list.

---

    Code
      pl_df$lazy()[second_arg]$collect()
    Condition
      Error in `pl_df$lazy()[second_arg]`:
      ! Can't subset columns with `second_arg`.
      i `second_arg` must be logical, numeric, or character, not a list.

# `[`'s drop argument works correctly

    Code
      pl_df[1, drop = TRUE]
    Condition
      Warning:
      ! `drop` argument ignored for subsetting a DataFrame with `x[j]`.
      i It has an effect only for `x[i, j]`.
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
      pl_df["a", drop = TRUE]
    Condition
      Warning:
      ! `drop` argument ignored for subsetting a DataFrame with `x[j]`.
      i It has an effect only for `x[i, j]`.
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

